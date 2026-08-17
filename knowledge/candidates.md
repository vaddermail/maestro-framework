# Knowledge Candidates

The **waiting room** between what one project learned and what the framework teaches. It solves
the chicken-and-egg of the rule "promote when proven general" (`knowledge/README.md`): a lesson
from **one** project is not general yet — but it needs a place to wait for a second confirmation
without getting lost. Maintained by the curator (`agents/14-meta/framework-curator.md`) during
curation rounds (`playbooks/framework-curation.md`); projects and contributors never edit this
file directly — they confirm or refute candidates through field reports (`CONTRIBUTING.md`).

| | |
| --- | --- |
| **Last curation round** | — (none yet in this edition) |
| **Issues processed to date** | 0 |
| **Active candidates (average age)** | 0 |
| **Cumulative outcomes** | 0 promoted · 0 declined · 0 dormant |

## Entry and exit rules

1. A lesson/pattern reported by one project (an `improvements` issue) **enters** as a candidate
   when the curator judges it potentially general but still unconfirmed.
2. It is **promoted** when **≥2 independent projects** confirm it — or with one confirmation when
   it is obviously general (written justification + maintainer approval). Promotion moves the
   content to its destination (`knowledge/`, modules, checklists, templates, …) as a MINOR
   release, and the row's state becomes `promoted`.
3. It is **declined** with a written why (domain-specific, contradicted by stronger evidence,
   cost above benefit). Declined rows are kept — the same debate never restarts from zero.
4. Every candidate has a **stable ID (C-nnn)** and a confirmation count linked to its source
   issues — "proven general" is countable, not subjective.
5. **Provenance by project codename only** — never names or stacks: this file travels inside
   every framework copy.
6. **Expiry:** a candidate with no new confirmation after **3 rounds or 12 months** forces a
   terminal decision — promote (with explicit maintainer approval), decline with reasons, or mark
   `dormant` (leaves the mandatory reading of each round; re-enters if a new report cites it).

## Candidates

| ID | Candidate (one-line summary) | Type | Origin (project · issue · date) | Confirmations | State |
| --- | --- | --- | --- | --- | --- |
| — | *(none yet — the first curation round of this edition fills this table)* | — | — | — | — |

Types: `trap` · `pattern` · `friction` · `block`. States: `awaiting-confirmation` ·
`promoted (version → destination)` · `declined (why)` · `dormant (since YYYY-MM — rule 6)`.

## Archive

At the close of each round, `promoted` and `declined` rows older than 2 rounds move here —
preserved in full for deduplication and for the "never reopen without new evidence" rule, out of
the mandatory per-round reading.

| ID | Candidate (one-line summary) | Type | Origin (project · issue · date) | Confirmations | State |
| --- | --- | --- | --- | --- | --- |
| — | *(empty)* | — | — | — | — |

## Related

- `knowledge/README.md` — the circuit this waiting room closes.
- `playbooks/framework-curation.md` — the procedure that writes and promotes candidates.
- `agents/14-meta/framework-curator.md` — who runs it.
- `templates/project/FRAMEWORK-IMPROVEMENTS.md.template` — where reports come from.
- `_meta/VERSION.md` — promotions are MINOR releases recorded in the changelog.
