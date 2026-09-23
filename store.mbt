///|
/// An in-memory content-addressed blob store for tests and ephemeral caches.
pub struct MemoryStore {
  blobs : @hashmap.HashMap[String, Bytes]
}

///|
pub fn MemoryStore::new() -> MemoryStore {
  MemoryStore::{ blobs: @hashmap.HashMap([]), }
}

///|
/// Store bytes and return their SHA-256 content identifier.
pub fn MemoryStore::put(self : MemoryStore, data : Bytes) -> Digest {
  let id = digest(data)
  self.blobs.set(id.to_string(), data)
  id
}

///|
pub fn MemoryStore::get(self : MemoryStore, id : Digest) -> Bytes? {
  self.blobs.get(id.to_string())
}

///|
pub fn MemoryStore::has(self : MemoryStore, id : Digest) -> Bool {
  self.blobs.contains(id.to_string())
}

///|
pub fn MemoryStore::delete(self : MemoryStore, id : Digest) -> Unit {
  self.blobs.remove(id.to_string())
}

///|
pub fn MemoryStore::length(self : MemoryStore) -> Int {
  self.blobs.length()
}
