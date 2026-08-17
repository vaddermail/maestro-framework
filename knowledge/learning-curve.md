# Ecosystem Learning Curve

The instrument of the framework's central promise: **every product cheaper and better than the
previous one**. One row per product, with the numbers from its genesis dossier
(`templates/project/GENESIS.md.template`), aggregated by the curator at each product's F8 close
(`playbooks/framework-curation.md`) — always by **project codename** (rule 5 of
`knowledge/candidates.md`), never by name. This file travels inside the copies: it is how a new
project fills the "previous product" column of its own genesis dossier.

## The curve

| Product | F0→production period | Days | AI cost | F7 findings (critical+high) | Rework | Source |
| --- | --- | --- | --- | --- | --- | --- |
| — | *(no products measured in this edition yet — the first genesis dossier starts the curve)* | — | — | — | — | — |

> The upstream ecosystem this edition derives from already showed the curve working: late-audit
> findings dropped by an order of magnitude between its second and third product once
> specification-before-construction took hold. This edition starts its own measurement from zero.

## How to read it, and what it feeds

- **Trend, not points:** a product worse than the previous one is not a framework failure — it is
  a signal for curation to ask why (harder domain? a new rule that did not pay off? a missing
  starter?).
- **Where to invest:** cost concentrated in F6 → the starter is the answer; high F7 findings →
  evals and earlier review; rework from spec divergence → reinforce F5.
- Each close's reading goes in the curation round's PR; deciding where to invest is the
  maintainer's call.

## Related

- `templates/project/GENESIS.md.template` — the source of the numbers, project by project.
- `playbooks/framework-curation.md` — who updates this curve and when.
- `knowledge/candidates.md` — the provenance-by-codename rule this table follows.
- `agents/13-guardians/value-guardian.md` — the twin instrument, inside each product.
