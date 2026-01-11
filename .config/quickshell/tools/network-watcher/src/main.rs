use dbus::arg::RefArg;
use dbus::blocking::Connection;
use networkmanager::configs::{Ip4Config, Ip6Config};
use networkmanager::devices::{Any, Device, Wireless};
use networkmanager::NetworkManager;
use serde::{Deserialize, Serialize};
use std::path::Path;
use std::process::Command;
use std::thread;
use std::time::Duration;
use tokio::io::{AsyncBufReadExt, AsyncWriteExt, BufReader};
use tokio::net::{UnixListener, UnixStream};
use tokio::sync::broadcast;

#[derive(Serialize, Clone, Debug)]
struct NetworkState {
    wifi_enabled: bool,
    wifi_connected: bool,
    wifi_ssid: Option<String>,
    wifi_signal: u8,
    ethernet_connected: bool,
    iface_name: Option<String>,
    ipv4: Option<String>,
    ipv6: Option<String>,
}

#[derive(Deserialize, Debug)]
struct ClientCommand {
    action: String,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let home = std::env::var("HOME")?;
    let socket_path = format!("{home}/.config/quickshell/.net.sock");
    if Path::new(&socket_path).exists() {
        let _ = std::fs::remove_file(&socket_path);
    }

    let listener = UnixListener::bind(&socket_path)?;
    let (tx, _) = broadcast::channel::<NetworkState>(16);

    let tx_clone = tx.clone();
    thread::spawn(move || {
        monitor_loop(tx_clone);
    });

    loop {
        match listener.accept().await {
            Ok((stream, _)) => {
                let tx_clone = tx.clone();
                tokio::spawn(async move {
                    handle_client(stream, tx_clone).await;
                });
            }
            Err(e) => eprintln!("Accept error: {}", e),
        }
    }
}

fn monitor_loop(tx: broadcast::Sender<NetworkState>) {
    let mut last_state_json = String::new();

    loop {
        if let Err(e) = run_monitor_cycle(&tx, &mut last_state_json) {
            eprintln!("Monitor error: {}", e);
        }
        thread::sleep(Duration::from_secs(2));
    }
}

fn run_monitor_cycle(
    tx: &broadcast::Sender<NetworkState>,
    last_state_json: &mut String,
) -> Result<(), Box<dyn std::error::Error>> {
    let dbus_conn = Connection::new_system()?;
    let nm = NetworkManager::new(&dbus_conn);

    loop {
        let state = get_network_state(&nm)?;
        let state_json = serde_json::to_string(&state)?;

        if state_json != *last_state_json {
            let _ = tx.send(state.clone());
            *last_state_json = state_json;
        } else {
            let _ = tx.send(state);
        }

        thread::sleep(Duration::from_secs(2));
    }
}

fn get_network_state(nm: &NetworkManager) -> Result<NetworkState, Box<dyn std::error::Error>> {
    let wifi_enabled = nm.wireless_enabled().unwrap_or(false);
    let mut wifi_connected = false;
    let mut wifi_ssid = None;
    let mut wifi_signal = 0;
    let mut ethernet_connected = false;

    let mut iface_name = None;
    let mut ipv4 = None;
    let mut ipv6 = None;

    if let Ok(devices) = nm.get_devices() {
        for device in devices {
            match device {
                Device::WiFi(wifi_device) => {
                    if wifi_enabled {
                        if let Ok(state) = wifi_device.state() {
                            if state == 100 {
                                if !wifi_connected {
                                    if let Ok(active_ap) = wifi_device.active_access_point() {
                                        if let Ok(ssid) = active_ap.ssid() {
                                            wifi_connected = true;
                                            wifi_ssid = Some(ssid);
                                            wifi_signal = active_ap.strength().unwrap_or(0);
                                        }
                                    }
                                }

                                if iface_name.is_none() {
                                    iface_name = wifi_device.interface().ok();
                                    ipv4 = get_ipv4(&wifi_device);
                                    ipv6 = get_ipv6(&wifi_device);
                                }
                            }
                        }
                    }
                }
                Device::Ethernet(eth_device) => {
                    if let Ok(state) = eth_device.state() {
                        if state == 100 {
                            ethernet_connected = true;
                            iface_name = eth_device.interface().ok();
                            ipv4 = get_ipv4(&eth_device);
                            ipv6 = get_ipv6(&eth_device);
                        }
                    }
                }
                _ => {}
            }
        }
    }

    Ok(NetworkState {
        wifi_enabled,
        wifi_connected,
        wifi_ssid,
        wifi_signal,
        ethernet_connected,
        iface_name,
        ipv4,
        ipv6,
    })
}

fn get_ipv4<T: Any>(device: &T) -> Option<String> {
    let config: Ip4Config = device.ip4_config().ok()?;
    let addresses = config.address_data().ok()?;
    addresses
        .get(0)?
        .get("address")?
        .as_str()
        .map(|s| s.to_string())
}

fn get_ipv6<T: Any>(device: &T) -> Option<String> {
    let config: Ip6Config = device.ip6_config().ok()?;
    let addresses = config.address_data().ok()?;
    addresses
        .get(0)?
        .get("address")?
        .as_str()
        .map(|s| s.to_string())
}

async fn handle_client(mut stream: UnixStream, tx: broadcast::Sender<NetworkState>) {
    let (reader, mut writer) = stream.split();
    let mut buf_reader = BufReader::new(reader);
    let mut line = String::new();

    let mut rx = tx.subscribe();

    loop {
        tokio::select! {
            result = buf_reader.read_line(&mut line) => {
                if result.unwrap_or(0) == 0 {
                    break;
                }

                if let Ok(cmd) = serde_json::from_str::<ClientCommand>(&line) {
                    if cmd.action == "toggle_wifi" {
                         if let Ok(output) = Command::new("nmcli").args(["radio", "wifi"]).output() {
                             let status = String::from_utf8_lossy(&output.stdout).trim().to_string();
                             let new_state = if status == "enabled" { "off" } else { "on" };
                             let _ = Command::new("nmcli").args(["radio", "wifi", new_state]).spawn();
                         }
                    }
                }
                line.clear();
            }

            recv_result = rx.recv() => {
                match recv_result {
                    Ok(state) => {
                        if let Ok(json) = serde_json::to_string(&state) {
                            if writer.write_all(json.as_bytes()).await.is_err() ||
                               writer.write_all(b"\n").await.is_err() ||
                               writer.flush().await.is_err() {
                                break;
                            }
                        }
                    }
                    Err(broadcast::error::RecvError::Lagged(_)) => continue,
                    Err(broadcast::error::RecvError::Closed) => break,
                }
            }
        }
    }
}

