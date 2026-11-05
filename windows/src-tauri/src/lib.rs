mod tray_icon;

use std::sync::atomic::{AtomicBool, Ordering};
use std::time::Duration;

use tauri::{
    menu::{Menu, MenuItem},
    tray::{MouseButton, MouseButtonState, TrayIconBuilder, TrayIconEvent},
    AppHandle, Manager, PhysicalPosition, PhysicalSize,
};
use tauri_plugin_autostart::MacosLauncher;
use tray_icon::{render_tray_icon, SIZE};

const TRAY_ID: &str = "yearbar-tray";
const PANEL_W: f64 = 320.0;
const PANEL_H: f64 = 480.0;
static IGNORE_FOCUS_LOSS: AtomicBool = AtomicBool::new(false);

#[tauri::command]
fn quit_app(app: AppHandle) {
    app.exit(0);
}

#[tauri::command]
fn update_tray(app: AppHandle, progress: f64, tooltip: String) -> Result<(), String> {
    let image = tauri::image::Image::new_owned(render_tray_icon(progress), SIZE, SIZE);
    if let Some(tray) = app.tray_by_id(TRAY_ID) {
        tray.set_icon(Some(image)).map_err(|e| e.to_string())?;
        tray.set_tooltip(Some(&tooltip)).map_err(|e| e.to_string())?;
    }
    Ok(())
}

fn position_panel_above(win: &tauri::WebviewWindow, anchor_pos: PhysicalPosition<f64>, anchor_size: PhysicalSize<f64>) {
    let scale = win.scale_factor().unwrap_or(1.0);
    let win_w = PANEL_W * scale;
    let win_h = PANEL_H * scale;

    let mut x = anchor_pos.x + anchor_size.width / 2.0 - win_w / 2.0;
    let mut y = anchor_pos.y - win_h - 12.0;

    if let Ok(Some(monitor)) = win.current_monitor() {
        let mpos = monitor.position();
        let msize = monitor.size();
        let left = mpos.x as f64;
        let right = left + msize.width as f64;
        let top = mpos.y as f64;
        x = x.clamp(left + 8.0, (right - win_w - 8.0).max(left + 8.0));
        if y < top + 8.0 {
            y = top + 8.0;
        }
    }

    let _ = win.set_size(tauri::LogicalSize::new(PANEL_W, PANEL_H));
    let _ = win.set_position(PhysicalPosition::new(x.round() as i32, y.round() as i32));
}

fn toggle_panel(app: &AppHandle, anchor_pos: PhysicalPosition<f64>, anchor_size: PhysicalSize<f64>) {
    if let Some(win) = app.get_webview_window("main") {
        if win.is_visible().unwrap_or(false) {
            let _ = win.hide();
            return;
        }

        IGNORE_FOCUS_LOSS.store(true, Ordering::SeqCst);
        position_panel_above(&win, anchor_pos, anchor_size);
        let _ = win.show();
        let _ = win.set_focus();

        let handle = app.clone();
        std::thread::spawn(move || {
            std::thread::sleep(Duration::from_millis(350));
            IGNORE_FOCUS_LOSS.store(false, Ordering::SeqCst);
            if let Some(w) = handle.get_webview_window("main") {
                let _ = w.set_focus();
            }
        });
    }
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_autostart::init(
            MacosLauncher::LaunchAgent,
            Some(vec!["--autostart"]),
        ))
        .invoke_handler(tauri::generate_handler![quit_app, update_tray])
        .setup(|app| {
            let quit = MenuItem::with_id(app, "quit", "Quit", true, None::<&str>)?;
            let menu = Menu::with_items(app, &[&quit])?;
            let icon = tauri::image::Image::new_owned(render_tray_icon(0.0), SIZE, SIZE);

            TrayIconBuilder::with_id(TRAY_ID)
                .icon(icon)
                .tooltip("YearBar")
                .menu(&menu)
                .show_menu_on_left_click(false)
                .on_menu_event(|app, event| {
                    if event.id.as_ref() == "quit" {
                        app.exit(0);
                    }
                })
                .on_tray_icon_event(|tray, event| {
                    if let TrayIconEvent::Click {
                        button: MouseButton::Left,
                        button_state: MouseButtonState::Up,
                        rect,
                        ..
                    } = event
                    {
                        let pos = rect.position.to_physical::<f64>(1.0);
                        let size = rect.size.to_physical::<f64>(1.0);
                        toggle_panel(tray.app_handle(), pos, size);
                    }
                })
                .build(app)?;

            if let Some(win) = app.get_webview_window("main") {
                let _ = win.set_size(tauri::LogicalSize::new(PANEL_W, PANEL_H));
                let app_handle = app.handle().clone();
                win.on_window_event(move |event| {
                    if let tauri::WindowEvent::Focused(false) = event {
                        if IGNORE_FOCUS_LOSS.load(Ordering::SeqCst) {
                            return;
                        }
                        if let Some(w) = app_handle.get_webview_window("main") {
                            let _ = w.hide();
                        }
                    }
                });
            }

            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running YearBar");
}
