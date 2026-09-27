# MoonCAS 测试说明

## 运行方法

```bash
moon fmt --check
moon check --deny-warn
moon build --deny-warn
moon test --deny-warn --target wasm
moon test --deny-warn --target wasm-gc
moon test --deny-warn --target js
moon run examples/basic
```

GitHub Actions 对每次 push 和 pull request 执行相同的检查，并分别运行 wasm、wasm-gc、JavaScript 三个后端。

## 当前测试矩阵

| 范围 | 验证内容 |
|---|---|
| SHA-256 | 空输入及已知向量得到确定摘要 |
| 去重 | 重复写入相同字节只保留一个对象 |
| 校验写入 | 声明摘要与实际内容不一致时拒绝写入 |
| 内容校验 | 已存对象可重新计算摘要验证 |
| 引用保护 | 被 `pin` 的对象不能直接删除 |
| 回收 | `unpin` 后可由 `collect` 清理 |
| 分块 | 固定大小切分后可以按顺序完整重组 |
| 块复用 | 重复块共享内容对象，同时保持各自引用 |
| 缺块 | 任一块不可用时重组失败而非返回残缺数据 |

仓库目前共有 7 个测试用例；一个用例可能覆盖表中的多个断言。黑盒测试验证公开 API，白盒测试只检查不应公开的内部约束。

## 尚未覆盖

当前没有文件系统后端，因此尚无崩溃恢复、原子重命名、磁盘损坏注入和并发写入测试。0.1.0 也没有性能承诺；增加持久化后再提供容量与吞吐基准，避免用内存实现的数据推断磁盘表现。
