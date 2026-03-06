use std::{
    sync::mpsc::{self, Receiver, Sender},
    thread,
};

use reactance::{HyprEvent, HyprlandEventPoll, HyprlandRequestSender};

fn main() -> std::io::Result<()> {
    let (tx, rx): (Sender<HyprEvent>, Receiver<HyprEvent>) = mpsc::channel();
    let mut poll = HyprlandEventPoll::new(tx);

    thread::spawn(move || {
        let _ = poll.pull();
    });

    while let Ok(data) = rx.recv() {
        match data {
            HyprEvent::URGENT(win_id) => {
                match HyprlandRequestSender::send(&format!(
                    "/dispatch focuswindow address:0x{:x}",
                    win_id
                )) {
                    Ok(resp) => {
                        eprintln!("{resp}");
                    }
                    Err(e) => eprintln!("{e}"),
                }
            }
            _ => {}
        }
    }

    Ok(())
}
