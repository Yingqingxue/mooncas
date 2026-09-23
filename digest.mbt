///|
/// A SHA-256 content identifier encoded as lowercase hexadecimal.
pub(all) struct Digest {
  hex : String
}

///|
pub fn Digest::to_string(self : Digest) -> String {
  self.hex
}

///|
fn rotr(value : UInt, count : Int) -> UInt {
  (value >> count) | (value << (32 - count))
}

///|
fn sha256_constants() -> FixedArray[UInt] {
  [
    0x428a2f98U, 0x71374491U, 0xb5c0fbcfU, 0xe9b5dba5U, 0x3956c25bU, 0x59f111f1U,
    0x923f82a4U, 0xab1c5ed5U, 0xd807aa98U, 0x12835b01U, 0x243185beU, 0x550c7dc3U,
    0x72be5d74U, 0x80deb1feU, 0x9bdc06a7U, 0xc19bf174U, 0xe49b69c1U, 0xefbe4786U,
    0x0fc19dc6U, 0x240ca1ccU, 0x2de92c6fU, 0x4a7484aaU, 0x5cb0a9dcU, 0x76f988daU,
    0x983e5152U, 0xa831c66dU, 0xb00327c8U, 0xbf597fc7U, 0xc6e00bf3U, 0xd5a79147U,
    0x06ca6351U, 0x14292967U, 0x27b70a85U, 0x2e1b2138U, 0x4d2c6dfcU, 0x53380d13U,
    0x650a7354U, 0x766a0abbU, 0x81c2c92eU, 0x92722c85U, 0xa2bfe8a1U, 0xa81a664bU,
    0xc24b8b70U, 0xc76c51a3U, 0xd192e819U, 0xd6990624U, 0xf40e3585U, 0x106aa070U,
    0x19a4c116U, 0x1e376c08U, 0x2748774cU, 0x34b0bcb5U, 0x391c0cb3U, 0x4ed8aa4aU,
    0x5b9cca4fU, 0x682e6ff3U, 0x748f82eeU, 0x78a5636fU, 0x84c87814U, 0x8cc70208U,
    0x90befffaU, 0xa4506cebU, 0xbef9a3f7U, 0xc67178f2U,
  ]
}

///|
fn padded(input : Bytes) -> Bytes {
  let original = input.length()
  let total = (original + 9 + 63) / 64 * 64
  let bit_length = original.to_uint64() * 8UL
  Bytes::makei(total, fn(i) {
    if i < original {
      input[i]
    } else if i == original {
      0x80
    } else if i >= total - 8 {
      (bit_length >> ((total - 1 - i) * 8)).to_byte()
    } else {
      0
    }
  })
}

///|
fn hex_byte(value : Byte, output : StringBuilder) -> Unit {
  let digits : FixedArray[Char] = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f',
  ]
  output.write_char(digits[(value.to_int() >> 4) & 0x0f])
  output.write_char(digits[value.to_int() & 0x0f])
}

///|
/// Compute a deterministic SHA-256 digest without platform-specific APIs.
pub fn digest(data : Bytes) -> Digest {
  let k = sha256_constants()
  let h : FixedArray[UInt] = [
    0x6a09e667U, 0xbb67ae85U, 0x3c6ef372U, 0xa54ff53aU, 0x510e527fU, 0x9b05688cU,
    0x1f83d9abU, 0x5be0cd19U,
  ]
  let bytes = padded(data)
  for chunk = 0; chunk < bytes.length(); chunk = chunk + 64 {
    let w = FixedArray::make(64, 0U)
    for i = 0; i < 16; i = i + 1 {
      let p = chunk + i * 4
      w[i] = (bytes[p].to_uint() << 24) |
        (bytes[p + 1].to_uint() << 16) |
        (bytes[p + 2].to_uint() << 8) |
        bytes[p + 3].to_uint()
    }
    for i = 16; i < 64; i = i + 1 {
      let x = w[i - 15]
      let y = w[i - 2]
      let s0 = rotr(x, 7) ^ rotr(x, 18) ^ (x >> 3)
      let s1 = rotr(y, 17) ^ rotr(y, 19) ^ (y >> 10)
      w[i] = w[i - 16] + s0 + w[i - 7] + s1
    }
    let mut a = h[0]
    let mut b = h[1]
    let mut c = h[2]
    let mut d = h[3]
    let mut e = h[4]
    let mut f = h[5]
    let mut g = h[6]
    let mut hh = h[7]
    for i = 0; i < 64; i = i + 1 {
      let s1 = rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25)
      let choose = (e & f) ^ (e.lnot() & g)
      let t1 = hh + s1 + choose + k[i] + w[i]
      let s0 = rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22)
      let majority = (a & b) ^ (a & c) ^ (b & c)
      let t2 = s0 + majority
      hh = g
      g = f
      f = e
      e = d + t1
      d = c
      c = b
      b = a
      a = t1 + t2
    }
    h[0] += a
    h[1] += b
    h[2] += c
    h[3] += d
    h[4] += e
    h[5] += f
    h[6] += g
    h[7] += hh
  }
  let output = StringBuilder(size_hint=64)
  for word in h {
    hex_byte((word >> 24).to_byte(), output)
    hex_byte((word >> 16).to_byte(), output)
    hex_byte((word >> 8).to_byte(), output)
    hex_byte(word.to_byte(), output)
  }
  Digest::{ hex: output.to_string(), }
}
