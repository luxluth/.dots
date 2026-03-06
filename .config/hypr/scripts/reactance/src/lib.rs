use std::io::{Read, Write};
use std::os::unix::net::UnixStream;
use std::sync::mpsc::Sender;
use std::thread;
use std::time::Duration;

pub fn hyprland_sock_path(ipc_name: &str) -> String {
    let runtime_dir = std::env::var("XDG_RUNTIME_DIR").unwrap();
    if let Ok(sig) = std::env::var("HYPRLAND_INSTANCE_SIGNATURE") {
        format!("{runtime_dir}/hypr/{}/{}", sig, ipc_name)
    } else {
        String::new()
    }
}

#[derive(Debug)]
pub enum HyprEvent {
    WORKSPACE(String),
    FOCUSEDMON(String, String),
    ACTIVEWINDOW(String, String),
    ACTIVEWINDOWV2(i64),
    FULLSCREEN(bool),
    MONITORREMOVED(String),
    MONITORADDED(String),
    CREATEWORKSPACE(String),
    DESTROYWORKSPACE(String),
    MOVEWORKSPACE(String, String),
    RENAMEWORKSPACE(u32, String),
    ACTIVESPECIAL(String, String),
    ACTIVELAYOUT(String, String),
    OPENWINDOW(i64, String, String, String),
    CLOSEWINDOW(i64),
    MOVEWINDOW(i64, String),
    OPENLAYER(String),
    CLOSELAYER(String),
    SUBMAP(String),
    CHANGEFLOATINGMODE(i64, bool),
    URGENT(i64),
    MINIMIZE(i64, bool),
    SCREENCAST(u8, u8),
    WINDOWTITLE(i64),
    IGNOREGROUPLOCK(u8),
    LOCKGROUPS(u8),
}

pub struct HyprlandRequestSender;

impl HyprlandRequestSender {
    pub fn send(action: &str) -> std::io::Result<String> {
        let mut sock = UnixStream::connect(hyprland_sock_path("/.socket.sock"))?;
        sock.write_all(action.as_bytes())?;

        let mut buff: Vec<u8> = vec![0; 8192];
        sock.read(&mut buff)?;
        Ok(String::from_utf8_lossy(&buff).to_string())
    }
}

pub struct HyprlandEventPoll {
    sender: Sender<HyprEvent>,
    stop: bool,
}

impl HyprlandEventPoll {
    pub fn new(sender: Sender<HyprEvent>) -> Self {
        HyprlandEventPoll {
            sender,
            stop: false,
        }
    }

    pub fn stop(&mut self) {
        self.stop = true;
    }

    pub fn pull(&mut self) -> std::io::Result<()> {
        let mut stream = UnixStream::connect(hyprland_sock_path(".socket2.sock"))?;

        'getting_the_event: loop {
            let mut data = Vec::new();
            loop {
                let mut byte = [0; 1];
                match stream.read_exact(&mut byte) {
                    Ok(_) => {
                        if byte[0] == b'\n' {
                            break;
                        }
                        data.push(byte[0]);
                    }
                    Err(e) => {
                        eprintln!("{e}");
                        break 'getting_the_event;
                    }
                }
            }

            if self.stop {
                break 'getting_the_event;
            }

            if let Ok(raw_str) = String::from_utf8(data) {
                if let Some((event_kind, values)) = raw_str.split_once(">>") {
                    match event_kind {
                        "workspace" => {
                            let _ = self.sender.send(HyprEvent::WORKSPACE(values.to_string()));
                        }

                        "focusedmon" => {
                            if let Some((monname, workspacename)) = values.split_once(',') {
                                let _ = self.sender.send(HyprEvent::FOCUSEDMON(
                                    monname.to_string(),
                                    workspacename.to_string(),
                                ));
                            }
                        }

                        "activewindow" => {
                            if let Some((class, title)) = values.split_once(',') {
                                let _ = self.sender.send(HyprEvent::ACTIVEWINDOW(
                                    class.to_string(),
                                    title.to_string(),
                                ));
                            }
                        }

                        "activewindowv2" => {
                            if let Ok(windowaddress) = i64::from_str_radix(values, 16) {
                                let _ = self.sender.send(HyprEvent::ACTIVEWINDOWV2(windowaddress));
                            }
                        }

                        "fullscreen" => {
                            let enter_fullscreen = matches!(values, "1");
                            let _ = self.sender.send(HyprEvent::FULLSCREEN(enter_fullscreen));
                        }

                        "monitorremoved" => {
                            let _ = self
                                .sender
                                .send(HyprEvent::MONITORREMOVED(values.to_string()));
                        }

                        "monitoradded" => {
                            let _ = self
                                .sender
                                .send(HyprEvent::MONITORADDED(values.to_string()));
                        }

                        "createworkspace" => {
                            let _ = self
                                .sender
                                .send(HyprEvent::CREATEWORKSPACE(values.to_string()));
                        }

                        "destroyworkspace" => {
                            let _ = self
                                .sender
                                .send(HyprEvent::DESTROYWORKSPACE(values.to_string()));
                        }

                        "moveworkspace" => {
                            if let Some((workspacename, monname)) = values.split_once(',') {
                                let _ = self.sender.send(HyprEvent::MOVEWORKSPACE(
                                    workspacename.to_string(),
                                    monname.to_string(),
                                ));
                            }
                        }

                        "renameworkspace" => {
                            if let Some((workspaceid, newname)) = values.split_once(',') {
                                if let Ok(id) = workspaceid.parse() {
                                    let _ = self
                                        .sender
                                        .send(HyprEvent::RENAMEWORKSPACE(id, newname.to_string()));
                                }
                            }
                        }

                        "activespecial" => {
                            if let Some((workspacename, monname)) = values.split_once(',') {
                                let _ = self.sender.send(HyprEvent::ACTIVESPECIAL(
                                    workspacename.to_string(),
                                    monname.to_string(),
                                ));
                            }
                        }

                        "activelayout" => {
                            if let Some((keyboardname, layoutname)) = values.split_once(',') {
                                let _ = self.sender.send(HyprEvent::ACTIVELAYOUT(
                                    keyboardname.to_string(),
                                    layoutname.to_string(),
                                ));
                            }
                        }

                        "openwindow" => {
                            // TODO: Cannot just split `,` need for sanitization. Mabye using hyprctl
                            eprintln!("[TODO::] openwindow>>{}", values);
                        }

                        "closewindow" => {
                            if let Ok(windowaddress) = i64::from_str_radix(values, 16) {
                                let _ = self.sender.send(HyprEvent::CLOSEWINDOW(windowaddress));
                            }
                        }

                        "movewindow" => {
                            if let Some((windowaddress, workspacename)) = values.split_once(',') {
                                if let Ok(addr) = i64::from_str_radix(windowaddress, 16) {
                                    let _ = self.sender.send(HyprEvent::MOVEWINDOW(
                                        addr,
                                        workspacename.to_string(),
                                    ));
                                }
                            }
                        }

                        "openlayer" => {
                            let _ = self.sender.send(HyprEvent::OPENLAYER(values.to_string()));
                        }

                        "closelayer" => {
                            let _ = self.sender.send(HyprEvent::CLOSELAYER(values.to_string()));
                        }

                        "submap" => {
                            let _ = self.sender.send(HyprEvent::SUBMAP(values.to_string()));
                        }

                        "changefloatingmode" => {
                            if let Some((windowaddress, floating)) = values.split_once(',') {
                                if let Ok(addr) = i64::from_str_radix(windowaddress, 16) {
                                    let floating = matches!(floating, "1");
                                    let _ = self
                                        .sender
                                        .send(HyprEvent::CHANGEFLOATINGMODE(addr, floating));
                                }
                            }
                        }

                        "urgent" => {
                            if let Ok(windowaddress) = i64::from_str_radix(values, 16) {
                                let _ = self.sender.send(HyprEvent::URGENT(windowaddress));
                            }
                        }

                        "minimize" => {
                            if let Some((windowaddress, minimized)) = values.split_once(',') {
                                if let Ok(addr) = i64::from_str_radix(windowaddress, 16) {
                                    let minimized = matches!(minimized, "1");
                                    let _ = self.sender.send(HyprEvent::MINIMIZE(addr, minimized));
                                }
                            }
                        }

                        "screencast" => {
                            if let Some((state, owner)) = values.split_once(',') {
                                let _ = self.sender.send(HyprEvent::SCREENCAST(
                                    state.parse().unwrap(),
                                    owner.parse().unwrap(),
                                ));
                            }
                        }

                        "windowtitle" => {
                            if let Ok(windowaddress) = i64::from_str_radix(values, 16) {
                                let _ = self.sender.send(HyprEvent::WINDOWTITLE(windowaddress));
                            }
                        }

                        "ignoregrouplock" => {
                            let _ = self
                                .sender
                                .send(HyprEvent::IGNOREGROUPLOCK(values.parse().unwrap()));
                        }

                        "lockgroups" => {
                            let _ = self
                                .sender
                                .send(HyprEvent::LOCKGROUPS(values.parse().unwrap()));
                        }

                        _ => {
                            eprintln!("[UNHANDLED::] {}>>{}", event_kind, values);
                        }
                    }
                }
            }
            thread::sleep(Duration::from_millis(1));
        }

        Ok(())
    }
}
