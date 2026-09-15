// Compiles the unmodified upstream DES implementation, not the MoonBit port.
#[path = "../vendor/upstream-des.rs"]
mod upstream;
fn next(seed: &mut u32) -> u8 {
    *seed = seed.wrapping_mul(1664525).wrapping_add(1013904223);
    (*seed >> 24) as u8
}
fn hex(bytes: &[u8]) -> String { bytes.iter().map(|b| format!("{:02x}", b)).collect() }
fn main() {
    let mut seed = 42673u32;
    for _ in 0..1000 {
        let mut password = [0u8;8];
        let mut challenge = [0u8;16];
        for b in &mut password { *b = next(&mut seed); }
        for b in &mut challenge { *b = next(&mut seed); }
        let mut key = password;
        for b in &mut key { *b = b.reverse_bits(); }
        let result = upstream::encrypt(&challenge, &key);
        println!("{} {} {}",hex(&password),hex(&challenge),hex(&result));
    }
}
