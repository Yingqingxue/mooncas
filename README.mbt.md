# MoonCAS

MoonCAS is a small, pure-MoonBit content-addressed storage kernel. It turns
bytes into SHA-256 identifiers, deduplicates equal content, verifies imported
blobs, tracks live references, collects unreachable data, and splits large
objects into independently reusable chunks.

The current MVP is deliberately backend-neutral and ships an in-memory store.
The abstraction is intended to sit below build caches, package registries,
artifact managers, and reproducible pipelines.

## Highlights

- Portable SHA-256 implementation with standard test vectors
- Idempotent `put`, `get`, `has`, and `delete` operations
- Expected-digest verification for safe imports
- Reference counting, protected deletion, and garbage collection
- Fixed-size chunk manifests with cross-object deduplication and owned references
- Tests and CI for the Wasm, Wasm-GC, and JavaScript backends

## Run

```bash
moon test --deny-warn
moon run cmd/main
```

## Library example

```mbt check
///|
test {
  let store = @mooncas.MemoryStore::new()
  let id = store.put(b"hello")
  assert_true(store.has(id))
  assert_true(store.verify(id))
}
```

## Scope

This release is a verifiable in-memory reference implementation. Filesystem,
HTTP/S3-compatible backends, persisted manifests, and concurrent access are
roadmap items rather than claims of the current MVP. The project complements
object-store clients by defining content identity, integrity, chunking, reachability,
and collection semantics.

Licensed under Apache-2.0.
