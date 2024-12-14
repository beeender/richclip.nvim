use std::ffi::CString;
use std::fs::File;
use std::io::Write;
use wayrs_client::global::GlobalExt;
use wayrs_client::protocol::wl_seat::WlSeat;
use wayrs_client::{Connection, EventCtx, IoMode};

use crate::source_data::SourceData;
use wayrs_protocols::wlr_data_control_unstable_v1::{
    zwlr_data_control_source_v1::{self, ZwlrDataControlSourceV1},
    ZwlrDataControlManagerV1,
};

struct EventState<'a> {
    source_data: &'a dyn SourceData,
    finishied: bool
}

pub fn copy_wayland(source_data: impl SourceData) {
    let (mut conn, globals) = Connection::<EventState>::connect_and_collect_globals().unwrap();
    let mut seat: Option<WlSeat> = None;

    for g in &globals {
        if g.is::<WlSeat>() {
            if seat.is_none() {
                seat = Some(g.bind(&mut conn, 2..=4).unwrap());
            } else {
                println!("should not happen");
            }
        }
    }

    let data_control_manager: ZwlrDataControlManagerV1 = globals
        .iter()
        .find(|g| g.is::<ZwlrDataControlManagerV1>())
        .expect(
            "No zwlr_data_control_manager_v1 global found, \
			ensure compositor supports wlr-data-control-unstable-v1 protocol",
        )
        .bind(&mut conn, 2)
        .unwrap();

    let data_control_device = data_control_manager.get_data_device(&mut conn, seat.unwrap());

    let source = data_control_manager.create_data_source_with_cb(&mut conn, wl_source_cb);
    source_data.mime_types().iter().for_each(|mime| {
        let cstr = CString::new(mime.as_bytes()).unwrap();
        source.offer(&mut conn, cstr);
    });

    data_control_device.set_selection(&mut conn, Some(source));
    conn.flush(IoMode::Blocking).unwrap();

    let mut state = EventState{
        source_data: &source_data,
        finishied: false
    };
    loop {
        if state.finishied {
            break;
        }
        conn.recv_events(IoMode::Blocking).unwrap();
        conn.dispatch_events(&mut state);
    }
}

fn wl_source_cb(ctx: EventCtx<EventState, ZwlrDataControlSourceV1>) {
    match ctx.event {
        zwlr_data_control_source_v1::Event::Send(zwlr_data_control_source_v1::SendArgs {
            mime_type,
            fd,
        }) => {
            let src_data = ctx.state.source_data;
            let mut file = File::from(fd);
            let content = src_data.content_by_mime_type(mime_type.to_str().unwrap()).unwrap();
            file.write_all(content).unwrap();
        }
        zwlr_data_control_source_v1::Event::Cancelled => {
            ctx.conn.break_dispatch_loop();
            ctx.state.finishied = true;
        }
        _ => {}
    }
}
