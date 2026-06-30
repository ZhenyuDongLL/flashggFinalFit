# flashggFinalFit Tutorial

Mini end-to-end final fit: **resolved**, **boosted**, and **all** (boosted+resolved) limits for MX1000 MY125.

| Script | Output |
|--------|--------|
| `scripts/run_resolved.sh` | `outputs/resolved/.../combine/combine_resolved.log` |
| `scripts/run_boosted.sh` | `outputs/boosted/.../combine/combine_boosted.log` |
| `scripts/run_all.sh` | `outputs/all/.../combine/combine_all.log` |

## [TUTORIAL.md](TUTORIAL.md) 目录

| § | 内容 |
|---|------|
| 0 | 阅读导引、pipeline 图 |
| 1–3 | 环境、样本、一键运行 |
| 7 | 物理背景（bbgg, MX/MY, PNN cat） |
| 8 | 统计框架（likelihood, r, multipdf, syst 分类） |
| 9 | **Resolved 分步命令**（与 `run_resolved.sh` 对齐） |
| 10 | Signal 建模（含 calcPhotonSyst 可选链） |
| 11 | Background multipdf |
| 12 | Datacard 与 combine limit |
| 13 | Boosted / combined 差异 |
| 14 | Trees2WS / Signal / Background **config** 字段说明 |
| 15 | FAQ |

Golden limits: [`outputs/GOLDEN.md`](outputs/GOLDEN.md).
