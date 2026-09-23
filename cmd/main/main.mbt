///|
/// Entry point for the CLI or runnable program in this template.
/// Keep main focused; move logic into the library package.
/// Run with `moon run cmd/main` from the project root.
fn main {
  let store = @cas.MemoryStore::new()
  let manifest = store.put_chunked(
    b"MoonCAS stores repeated chunks only once.",
    chunk_size=8,
  )
  println("chunks: \{manifest.chunk_count()}")
  println("unique blobs: \{store.length()}")
  match store.get_chunked(manifest) {
    Some(data) => println("round trip ok: \{data == b\"MoonCAS stores repeated chunks only once.\"}")
    None => println("restore failed")
  }
}
