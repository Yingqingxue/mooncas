///|
/// A logical blob split into independently deduplicated chunks.
pub struct ChunkedBlob {
  chunks : Array[Digest]
  length : Int
}

///|
pub fn ChunkedBlob::chunk_count(self : ChunkedBlob) -> Int {
  self.chunks.length()
}

///|
pub fn ChunkedBlob::length(self : ChunkedBlob) -> Int {
  self.length
}

///|
/// Split a blob into fixed-size chunks and store each chunk by digest.
pub fn MemoryStore::put_chunked(
  self : MemoryStore,
  data : Bytes,
  chunk_size? : Int = 65536,
) -> ChunkedBlob {
  let size = if chunk_size < 1 { 1 } else { chunk_size }
  let ids : Array[Digest] = []
  for start = 0; start < data.length(); start = start + size {
    let end = (start + size).min(data.length())
    ids.push(self.put(data[start:end].to_owned()))
  }
  ChunkedBlob::{ chunks: ids, length: data.length(), }
}

///|
/// Reassemble a chunked blob, returning None if any chunk is unavailable.
pub fn MemoryStore::get_chunked(
  self : MemoryStore,
  manifest : ChunkedBlob,
) -> Bytes? {
  let output : Array[Byte] = []
  for id in manifest.chunks {
    match self.get(id) {
      Some(chunk) =>
        for byte in chunk {
          output.push(byte)
        }
      None => return None
    }
  }
  if output.length() != manifest.length {
    return None
  }
  Some(Bytes::from_array(output))
}
