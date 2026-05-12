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
            HyprEvent::URGENT(_) => {
                match HyprlandRequestSender::send(
                    "/dispatch hl.dsp.focus({ urgent_or_last = true })",
                ) {
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
