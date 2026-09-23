# MoonCAS

MoonCAS 是纯 MoonBit 实现的内容寻址存储内核。它用 SHA-256 摘要标识内容，提供去重、完整性校验、引用保护、垃圾回收和分块复用，适合作为构建缓存、包仓库及制品系统的底层组件。

## 当前能力

- `put/get/has/delete` 与相同内容自动去重
- `put_verified/verify` 校验导入及已存内容
- `pin/unpin` 引用保护；活跃对象拒绝删除
- 大对象固定大小分块、跨对象块复用和安全回收
- Wasm、Wasm-GC、JavaScript 三后端 CI

## 安装与运行

当前可从源码运行；发布 Mooncakes 后可使用 `moon add Yingqingxue/mooncas`。

```bash
git clone https://github.com/Yingqingxue/mooncas.git
cd mooncas
moon check --deny-warn
moon build --deny-warn
moon test --deny-warn
moon run cmd/main
```

## 最小使用示例

```moonbit
let store = @mooncas.MemoryStore::new()
let id = store.put(b"hello")
assert_true(store.has(id))
assert_true(store.verify(id))
```

分块对象在创建时为每个块持有一次引用。使用完成后调用 `unpin_chunked`，再由 `collect` 回收无引用块。

## 工程边界

当前版本是内存参考实现，不宣称提供持久化、分布式一致性、加密或并发事务。文件系统原子写入、持久化清单、流式哈希和远端后端属于后续版本。

更多可类型检查的示例见 [README.mbt.md](README.mbt.md)，报名材料见 [PROJECT_PLAN.md](PROJECT_PLAN.md)，版本记录见 [CHANGELOG.md](CHANGELOG.md)。

Apache-2.0 licensed.
