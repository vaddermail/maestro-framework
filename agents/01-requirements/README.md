# 01 — Requirements (F2): the what, without ambiguity

The category that turns the **discovery dossier** (F1) into a specification of intent that
architecture, build and tests can consume **without guessing**. Here the *what* and the *rules*
are decided — never the *how* (that is F3, `agents/02-architecture/`). The product of this phase
is the base of chained traceability (`core/artifact-protocol.md` §4): idea → `FR-nnn` → `BR-nnn` →
acceptance criteria → specification → code → test.

Dominant phase: **F2** (`workflows/W02-requirements.md`), with the `business-rules-modeler`
re-entering in **F5** (`workflows/W05-specification.md`). The gate this category must get through
is **P2** (`core/quality-gates.md`): zero open critical ambiguities, quantified NFRs, business
rules numbered and approved.

## Agents in this category

| Agent | One sentence | Produces |
| --- | --- | --- |
| `agents/01-requirements/requirements-engineer.md` | Elicits and structures the traceable functional requirements from discovery | `FR-nnn` |
| `agents/01-requirements/glossary-curator.md` | Fixes the domain's ubiquitous language and the forbidden synonyms | glossary |
| `agents/01-requirements/business-rules-modeler.md` | Makes the rules, invariants and state machines explicit | `BR-nnn` |
| `agents/01-requirements/nfr-specifier.md` | Quantifies performance, availability, security and compliance | `NFR-nnn` |
| `agents/01-requirements/acceptance-criteria-writer.md` | Writes, per requirement, the verifiable criteria that prove it got done | AC per `FR` |
| `agents/01-requirements/ambiguity-hunter.md` | Detects ambiguity, contradiction and gap; opens the loop `loops/L01-ambiguous-requirements.md` | question batch + marks |

## Recommended order of work

1. **Glossary first** (`glossary-curator`) — even if thin: without fixed terms, everyone else
   writes in a different dialect. It keeps growing throughout the phase.
2. **Functional requirements** (`requirements-engineer`) — the `FR-nnn` spine built from the use
   cases and the MVP.
3. **Business rules + NFRs in parallel** (`business-rules-modeler`, `nfr-specifier`) — the rules
   the `FR` must respect and the quality attributes that cut across them.
4. **Acceptance criteria** (`acceptance-criteria-writer`) — as soon as an `FR` stabilizes.
5. **Continuous ambiguity hunting** (`ambiguity-hunter`) — runs over everything the others produce
   and is the **last to give the OK**: while critical ambiguity remains, P2 does not pass.

The `ambiguity-hunter` is not a single final step — it fires whenever an F2 artifact changes,
feeding `loops/L01-ambiguous-requirements.md` until it closes.

## How the Orchestrator convenes it

`core/orchestrator.md` starts F2 when P1 passes (discovery dossier approved). It builds the graph
from the **Inputs**/**Interactions** sections of the agent specs, batches the questions the agents
raise (`core/question-engine.md`) and only declares P2 when the `ambiguity-hunter` confirms zero
critical pending items and the user has approved requirements, rules and NFRs. Divergences that
only show up in F5 send work back to this category — that is the cycle at work
(`core/lifecycle.md` §2).

## Related

- `agents/00-discovery/README.md` — upstream: provides use cases, MVP and priorities.
- `agents/02-architecture/README.md` — downstream: consumes requirements and NFRs to decide the
  *how*.
- `workflows/W02-requirements.md` · `workflows/W05-specification.md` — the processes that run the
  phase.
- `core/artifact-protocol.md` — the `product/01-requirements/` tree and the ID chain.
