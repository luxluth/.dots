use std::{
    path::Path,
    process::Command,
    sync::atomic::{AtomicUsize, Ordering},
    time::Duration,
    usize,
};

use hd::job::{SchedulerMessage, Task, TaskScheduler};
use tokio::{io::AsyncReadExt, net::UnixListener};

static VOLUME_TASK_ID: AtomicUsize = AtomicUsize::new(0);
static BRIGHTNESS_TASK_ID: AtomicUsize = AtomicUsize::new(0);

fn run(cmd: &mut Command) {
    match cmd.spawn() {
        Ok(mut e) => {
            let _ = e.wait();
        }
        Err(e) => {
            eprintln!("[error]: unable to run this command: {e}");
        }
    }
}

fn update_brightness_widget(
    sx: tokio::sync::mpsc::UnboundedSender<SchedulerMessage>,
    value: usize,
) {
    use SchedulerMessage::*;
    if BRIGHTNESS_TASK_ID.load(Ordering::Relaxed) == 0 {
        run(Command::new("eww").args(["update", format!("brightness-level={value}").as_str()]));
        run(Command::new("eww").args(["open", "brightness"]));
    } else {
        let _ = sx.send(RemoveTask(BRIGHTNESS_TASK_ID.load(Ordering::Relaxed)));
        run(Command::new("eww").args(["update", format!("brightness-level={value}").as_str()]));
    }

    let task = Task::new(
        || {
            run(Command::new("eww").args(["close", "brightness"]));
            BRIGHTNESS_TASK_ID.store(0, Ordering::Relaxed);
        },
        Duration::new(1, 200000000),
    );

    BRIGHTNESS_TASK_ID.store(task.id, Ordering::Relaxed);
    let _ = sx.send(AddTask(task));
}

fn update_volume_widget(sx: tokio::sync::mpsc::UnboundedSender<SchedulerMessage>, value: usize) {
    use SchedulerMessage::*;
    if VOLUME_TASK_ID.load(Ordering::Relaxed) == 0 {
        run(Command::new("eww").args(["update", format!("volume-level={value}").as_str()]));
        run(Command::new("eww").args(["open", "volume"]));
    } else {
        let _ = sx.send(RemoveTask(VOLUME_TASK_ID.load(Ordering::Relaxed)));
        run(Command::new("eww").args(["update", format!("volume-level={value}").as_str()]));
    }

    let task = Task::new(
        || {
            run(Command::new("eww").args(["close", "volume"]));
            VOLUME_TASK_ID.store(0, Ordering::Relaxed);
        },
        Duration::new(1, 200000000),
    );

    VOLUME_TASK_ID.store(task.id, Ordering::Relaxed);
    let _ = sx.send(AddTask(task));
}

fn update_volume_widget_mute(
    sx: tokio::sync::mpsc::UnboundedSender<SchedulerMessage>,
    mute_status: bool,
) {
    use SchedulerMessage::*;
    if VOLUME_TASK_ID.load(Ordering::Relaxed) == 0 {
        run(Command::new("eww").args(["update", format!("volume-is-muted={mute_status}").as_str()]));
        run(Command::new("eww").args(["open", "volume"]));
    } else {
        let _ = sx.send(RemoveTask(VOLUME_TASK_ID.load(Ordering::Relaxed)));
        run(Command::new("eww").args(["update", format!("volume-is-muted={mute_status}").as_str()]));
    }

    let task = Task::new(
        || {
            run(Command::new("eww").args(["close", "volume"]));
            VOLUME_TASK_ID.store(0, Ordering::Relaxed);
        },
        Duration::new(1, 200000000),
    );

    VOLUME_TASK_ID.store(task.id, Ordering::Relaxed);
    let _ = sx.send(AddTask(task));
}

#[tokio::main]
async fn main() {
    let (tx, scheduler) = TaskScheduler::new();
    tokio::spawn(async move { scheduler.run().await });

    let path = Path::new("/tmp/hd");
    if path.exists() {
        let _ = std::fs::remove_file(path);
    }

    let listener = UnixListener::bind(path).unwrap();

    while let Ok((mut stream, _)) = listener.accept().await {
        let mut msg_buffer = [0u8; 256];
        match stream.read(&mut msg_buffer).await {
            Ok(read) => {
                if read > 0 {
                    let msg = String::from_utf8_lossy(&msg_buffer[0..read])
                        .trim()
                        .to_string();
                    if let Some((cmd, value)) = msg.split_once('@') {
                        match cmd {
                            "VOLUME" => match value {
                                "MUTED" => {
                                    update_volume_widget_mute(tx.clone(), true);
                                }
                                "NOTMUTED" => {
                                    update_volume_widget_mute(tx.clone(), false);
                                }
                                _ => {
                                    if let Ok(value) = value.parse() {
                                        update_volume_widget(tx.clone(), value);
                                    }
                                }
                            },
                            "BRIGHTNESS" => {
                                if let Ok(value) = value.parse() {
                                    update_brightness_widget(tx.clone(), value);
                                }
                            }
                            _ => {
                                eprintln!("[warn]: unkown command `{cmd}`");
                            }
                        }
                    }
                }
            }
            Err(e) => {
                eprintln!("[error] {e}");
                let _ = tx.send(SchedulerMessage::Stop);
                break;
            }
        }
    }
}
