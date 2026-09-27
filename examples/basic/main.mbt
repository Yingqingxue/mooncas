///|
fn main {
  let store = @cas.MemoryStore::new()
  let id = store.put(b"repeatable artifact")
  let duplicate = store.put(b"repeatable artifact")
  println("same digest: \{id.to_string() == duplicate.to_string()}")
  println("unique objects: \{store.length()}")
  println("verified: \{store.verify(id)}")
}
