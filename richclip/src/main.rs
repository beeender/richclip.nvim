use std::io::{Write, stdin};


mod recv;
mod source_data;
mod clipboard;


fn main() {
    let stdin = stdin();
    let source_data = recv::receive_data(&stdin).unwrap();
    clipboard::copy_wayland(source_data);
}
