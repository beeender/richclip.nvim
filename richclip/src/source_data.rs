pub struct SourceDataItem {
    pub mime_type: Vec<String>,
    pub content: Vec<u8>,
}

pub trait SourceData {
    fn content_by_mime_type(&self, mime_type: &str) -> Option<&Vec<u8>>;
    // TODO: Can we have something like below to avoid copying?
    //fn mime_types_for_each(&self, f: &Fn(&String));
    fn mime_types(&self) -> Vec<String>;
}

impl SourceData for Vec<SourceDataItem> {
    fn content_by_mime_type(&self, mime_type: &str) -> Option<&Vec<u8>> {
        log::debug!("content_by_mime_type was called with '{}'", mime_type);
        let mut filter_it = self
            .iter()
            .filter(|item| {
                item.mime_type
                    .iter()
                    .filter(|mt| mt.contains(&mime_type.to_lowercase()))
                    .peekable()
                    .peek()
                    .is_some()
            })
            .peekable();

        match filter_it.peek() {
            Some(src_data) => Some(&src_data.content),
            _ => None,
        }
    }

    fn mime_types(&self) -> Vec<String> {
        let mut v = Vec::new();
        self.iter().for_each(|item| {
            item.mime_type
                .iter()
                .for_each(|mime_type| v.push(mime_type.clone()));
        });
        v
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::recv::receive_data;
    use crate::recv::PROTOCAL_VER;

    #[test]
    fn test_content_by_mime_type() {
        #[rustfmt::skip]
        let buf =
            [0x20, 0x09, 0x02, 0x14, PROTOCAL_VER,
            b'M', 0, 0, 0, 10, b't', b'e', b'x', b't', b'/', b'p', b'l', b'a', b'i', b'n',
            b'M', 0, 0, 0, 4, b'T', b'E', b'X', b'T',
            b'C', 0, 0, 0, 4, b'G', b'O', b'O', b'D',
            b'M', 0, 0, 0, 9, b't', b'e', b'x', b't', b'/', b'h', b't', b'm', b'l',
            b'C', 0, 0, 0, 3, b'B', b'A', b'D',
            ];
        let r = receive_data(&mut &buf[..]).unwrap();

        let content = r.content_by_mime_type("text/plain").unwrap();
        assert_eq!(content.as_slice(), b"GOOD");
        let content = r.content_by_mime_type("text").unwrap();
        assert_eq!(content.as_slice(), b"GOOD");
        let content = r.content_by_mime_type("html").unwrap();
        assert_eq!(content.as_slice(), b"BAD");
        let content = r.content_by_mime_type("no_mime");
        assert!(content.is_none());
    }
}
