# Golden limits (MX=1000, MY=125)

Tutorial validation on lxplus (Jun 2026). Expected asymptotic CLs upper limits at mH=125 GeV:

| Channel | Log | Expected 50% limit |
|---------|-----|-------------------|
| Resolved (cat0+cat1) | `outputs/resolved/MX1000/MY125/combine/combine_resolved.log` | r < 0.2148 |
| Boosted | `outputs/boosted/MX1000/MY125/combine/combine_boosted.log` | r < 0.0806 |
| All (boosted+resolved) | `outputs/all/MX1000/MY125/combine/combine_all.log` | r < 0.0698 |

Reproduce: `./run_tutorial.sh all` from `tutorial/` after `sync_tutorial_samples.sh fetch`.
