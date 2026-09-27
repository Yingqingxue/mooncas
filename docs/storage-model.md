# MoonCAS 存储模型

## 对象

一个对象由 `(digest, bytes)` 表示，其中：

```text
digest = lowercase_hex(SHA-256(bytes))
```

同一个 `digest` 对应同一份内容。当前内存后端使用摘要字符串作为哈希表键。

## 分块对象

`ChunkedBlob` 保存有序块摘要和原始总长度：

```text
ChunkedBlob {
  chunks: [digest_0, digest_1, ...]
  length: original_byte_length
}
```

重组时必须按数组顺序读取每个块，任一块缺失或重组长度不符都返回 `None`。当前清单本身不是存储对象，因此调用方需要保存它；这也是后续版本需要补齐的持久化边界。

## 不变量

- `put(data)` 返回的摘要必须等于重新计算 `digest(data)` 的结果。
- `put_verified(expected, data)` 只在二者相等时修改存储。
- 被引用对象不能由 `delete` 删除。
- `collect` 不删除任何仍有引用的对象。
- 分块清单持有的每个块必须在创建时增加一次引用。
- `get_chunked` 成功时返回字节长度必须等于清单记录的总长度。
