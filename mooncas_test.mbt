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
