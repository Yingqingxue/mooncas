///|
test "SHA-256 standard vectors" {
  inspect(
    @mooncas.digest(b"").to_string(),
    content="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  )
  inspect(
    @mooncas.digest(b"abc").to_string(),
    content="ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
  )
}

///|
test "memory store deduplicates equal content" {
  let store = @mooncas.MemoryStore::new()
  let first = store.put(b"same payload")
  let second = store.put(b"same payload")
  inspect(first.to_string() == second.to_string(), content="true")
  inspect(store.length(), content="1")
  let found = match store.get(first) {
    Some(bytes) => bytes == b"same payload"
    None => false
  }
  inspect(found, content="true")
  store.delete(first)
  inspect(store.length(), content="0")
}

///|
test "reference-aware collection keeps pinned blobs" {
  let store = @mooncas.MemoryStore::new()
  let live = store.put(b"live")
  let dead = store.put(b"dead")
  inspect(store.pin(live), content="true")
  inspect(store.collect(), content="1")
  inspect(store.has(live), content="true")
  inspect(store.has(dead), content="false")
  store.unpin(live)
  inspect(store.collect(), content="1")
}

///|
test "verified writes reject mismatched content" {
  let store = @mooncas.MemoryStore::new()
  let expected = @mooncas.digest(b"expected")
  inspect(store.put_verified(expected, b"tampered"), content="false")
  inspect(store.length(), content="0")
  inspect(store.put_verified(expected, b"expected"), content="true")
  inspect(store.verify(expected), content="true")
}

///|
test "chunked blobs round-trip and deduplicate repeated chunks" {
  let store = @mooncas.MemoryStore::new()
  let manifest = store.put_chunked(b"abcdabcd", chunk_size=4)
  inspect(manifest.chunk_count(), content="2")
  inspect(manifest.length(), content="8")
  inspect(store.length(), content="1")
  let restored = match store.get_chunked(manifest) {
    Some(bytes) => bytes == b"abcdabcd"
    None => false
  }
  inspect(restored, content="true")
}
