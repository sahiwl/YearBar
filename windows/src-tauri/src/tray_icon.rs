use std::f64::consts::TAU;

/// Windows tray slots are square, so the percent goes inside the ring instead of beside it.
pub const SIZE: u32 = 32;

const DIGITS: [[u8; 7]; 10] = [
    [0b01110, 0b10001, 0b10011, 0b10101, 0b11001, 0b10001, 0b01110],
    [0b00100, 0b01100, 0b00100, 0b00100, 0b00100, 0b00100, 0b01110],
    [0b01110, 0b10001, 0b00001, 0b00010, 0b00100, 0b01000, 0b11111],
    [0b11111, 0b00010, 0b00100, 0b00010, 0b00001, 0b10001, 0b01110],
    [0b00010, 0b00110, 0b01010, 0b10010, 0b11111, 0b00010, 0b00010],
    [0b11111, 0b10000, 0b11110, 0b00001, 0b00001, 0b10001, 0b01110],
    [0b00110, 0b01000, 0b10000, 0b11110, 0b10001, 0b10001, 0b01110],
    [0b11111, 0b00001, 0b00010, 0b00100, 0b01000, 0b01000, 0b01000],
    [0b01110, 0b10001, 0b10001, 0b01110, 0b10001, 0b10001, 0b01110],
    [0b01110, 0b10001, 0b10001, 0b01111, 0b00001, 0b00010, 0b01100],
];

fn set(buf: &mut [u8], x: u32, y: u32, alpha: f64) {
    let i = ((y * SIZE + x) * 4) as usize;
    let a = (alpha * 255.0) as u8;
    if a > buf[i + 3] {
        buf[i..i + 3].copy_from_slice(&[240, 240, 240]);
        buf[i + 3] = a;
    }
}

/// 32x32 RGBA: progress ring (from 12 o'clock, clockwise) with whole percent inside.
pub fn render_tray_icon(progress: f64) -> Vec<u8> {
    let mut buf = vec![0u8; (SIZE * SIZE * 4) as usize];
    let p = progress.clamp(0.0, 100.0);
    let sweep = p / 100.0 * TAU;
    let c = (SIZE as f64 - 1.0) / 2.0;
    let (radius, half_stroke) = (14.5, 1.25);

    for y in 0..SIZE {
        for x in 0..SIZE {
            let (dx, dy) = (x as f64 - c, y as f64 - c);
            let d = ((dx * dx + dy * dy).sqrt() - radius).abs();
            let alpha = (half_stroke + 0.5 - d).clamp(0.0, 1.0);
            if alpha == 0.0 {
                continue;
            }
            let mut angle = dx.atan2(-dy);
            if angle < 0.0 {
                angle += TAU;
            }
            set(&mut buf, x, y, if angle <= sweep { alpha } else { alpha * 0.35 });
        }
    }

    // Year progress resets on Jan 1, so it never reaches 100; cap keeps it at two digits.
    let text = (p.floor() as u32).min(99).to_string();
    let scale = 2;
    let width = text.len() as u32 * 6 * scale - scale;
    let (x0, y0) = ((SIZE - width) / 2, (SIZE - 7 * scale) / 2);
    for (i, ch) in text.bytes().enumerate() {
        for (row, bits) in DIGITS[(ch - b'0') as usize].iter().enumerate() {
            for col in 0..5 {
                if (bits >> (4 - col)) & 1 == 1 {
                    for sy in 0..scale {
                        for sx in 0..scale {
                            let x = x0 + i as u32 * 6 * scale + col * scale + sx;
                            set(&mut buf, x, y0 + row as u32 * scale + sy, 1.0);
                        }
                    }
                }
            }
        }
    }
    buf
}

#[cfg(test)]
mod tests {
    use super::*;

    fn alpha(buf: &[u8], x: u32, y: u32) -> u8 {
        buf[((y * SIZE + x) * 4 + 3) as usize]
    }

    #[test]
    fn half_progress_fills_top_not_left() {
        let buf = render_tray_icon(50.0);
        assert_eq!(buf.len(), (SIZE * SIZE * 4) as usize);
        assert_eq!(alpha(&buf, 16, 1), 255);
        assert!(alpha(&buf, 1, 16) < 128);
    }
}
