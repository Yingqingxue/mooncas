///|
/// An in-memory content-addressed blob store for tests and ephemeral caches.
pub struct MemoryStore {
  blobs : @hashmap.HashMap[String, Bytes]
  pins : @hashmap.HashMap[String, Int]
}

///|
pub fn MemoryStore::new() -> MemoryStore {
  MemoryStore::{ blobs: @hashmap.HashMap([]), pins: @hashmap.HashMap([]), }
}

///|
/// Store bytes and return their SHA-256 content identifier.
pub fn MemoryStore::put(self : MemoryStore, data : Bytes) -> Digest {
  let id = digest(data)
  self.blobs.set(id.to_string(), data)
  id
}

///|
/// Store data only when it matches an expected digest.
pub fn MemoryStore::put_verified(
  self : MemoryStore,
  expected : Digest,
  data : Bytes,
) -> Bool {
  let actual = digest(data)
  if actual.to_string() != expected.to_string() {
    return false
  }
  self.blobs.set(expected.to_string(), data)
  true
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
/// Re-hash a stored blob to detect accidental or hostile corruption.
pub fn MemoryStore::verify(self : MemoryStore, id : Digest) -> Bool {
  match self.get(id) {
    Some(data) => digest(data).to_string() == id.to_string()
    None => false
  }
}

///|
/// Delete an unpinned blob. Returns false when live references still exist.
pub fn MemoryStore::delete(self : MemoryStore, id : Digest) -> Bool {
  let key = id.to_string()
  if self.pins.contains(key) {
    return false
  }
  let existed = self.blobs.contains(key)
  self.blobs.remove(key)
  self.pins.remove(key)
  existed
}

///|
pub fn MemoryStore::length(self : MemoryStore) -> Int {
  self.blobs.length()
}

///|
/// Add a live reference. Returns false when the blob is unknown.
pub fn MemoryStore::pin(self : MemoryStore, id : Digest) -> Bool {
  let key = id.to_string()
  if !self.blobs.contains(key) {
    return false
  }
  let count = self.pins.get(key).unwrap_or(0)
  self.pins.set(key, count + 1)
  true
}

///|
/// Release one live reference without allowing a negative count.
pub fn MemoryStore::unpin(self : MemoryStore, id : Digest) -> Unit {
  let key = id.to_string()
  match self.pins.get(key) {
    Some(count) if count > 1 => self.pins.set(key, count - 1)
    Some(_) => self.pins.remove(key)
    None => ()
  }
}

///|
/// Delete every unpinned blob and return the number collected.
pub fn MemoryStore::collect(self : MemoryStore) -> Int {
  let before = self.blobs.length()
  self.blobs.retain(fn(key, _) { self.pins.contains(key) })
  before - self.blobs.length()
}
