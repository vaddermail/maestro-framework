# Multi-Repository Product · truth in files, conversation in the tracker

How to coordinate a product — or an ecosystem of products — split across multiple repositories,
each with its own STATE.md, its own agent sessions and its own lifecycle, without the owner turning
into the mailman between them. Maestro assumes everywhere that one product equals one repository;
this module is what kicks in when that stops being true.

## The problem it solves

Each piece only changes in its own repository — the rule is sound, the organizational mirror of
"integration only through contracts." But it has an undesigned consequence: all communication
between repositories ends up traveling as hand-pasted prose from the owner, session after session,
and carried prose has no state. Measured in the origin ecosystem: the same commitment agreed in one
handover and not honored in the next repeated four times; a blocker raised three minutes after being
declared stopped another repository for three days, because nobody ever said it had fallen; a fix
applied in one repository and not in its twin reopened the same defect weeks later.

## The model (concepts and entities, stack-agnostic)

Traffic between repositories has **two natures**, and they are handled in separate layers:

| Nature | Examples | Essential property | Where it lives |
| --- | --- | --- | --- |
| **Truth** — what stays | decisions, ADRs, contracts between services, standards, consolidated facts | versioned, owned, permanent | files, in the repository that **owns the subject area** |
| **Conversation** — what flows | requests, questions and answers, change notices, dependencies to reconcile | has state (open/closed), a recipient and a notification | items in a tracker (issues), in the repository of **whoever has to act** |

- **Precedence table by subject area:** for each subject area (global architecture, each service,
  the boundary between them, infrastructure), a single repository decides and a single file records
  it. Whoever disagrees does not edit in their own repository: they open an item in the owning
  repository. The rule that generates the table for a case it doesn't yet list: a piece's subject
  area belongs to its own repository; while that repository doesn't exist yet, it lives in the
  coordination one; when it is born, precedence transfers on day one.
- **Mesh, not star:** any repository talks directly to any other. The coordination repository owns
  the process specification and the "global architecture" subject area — it is never a mail relay.
  The only central thing is a view (a board), and it is a view, not a warehouse.
- **Typed item with a closing criterion:** each conversation item is one of four types — request,
  question, fact, dependency —, states where it comes from in the title, and carries an objective
  closing criterion ("ADR merged", "section X updated"). Whoever executes closes it, referencing the
  commit or document that fulfills it; whoever requested it reopens if the criterion is not met.
- **Code twins:** shared logic that exists in two repositories (guards, validations, adapters) is
  adopted **by clause, never by copying the file** — the executable body is compared before
  copying, and every patch on one side is compared against the other's integration branch before
  merging.

## Non-negotiable rules (numbered, verifiable)

1. **A conversation item is never a source of truth.** What gets decided lands in a file in the
   owning repository; the item carries it and dies closed, pointing at the commit or document that
   fulfilled it. An item open for weeks with the decision sitting inside it is the rule failing.
2. **Communicating is part of finishing the task.** Whoever changes something that impacts another
   piece — a contract, observable behavior, a name, scope — opens the item on the affected piece
   **in the same session** that made the change. It is not "we'll get to it later."
3. **A question whose answer is another repository's subject area is not answered from memory.**
   Open the question there: the owning repository answers better than a session's memory of it.
4. **Whoever closes a blocker notifies whoever is waiting on it.** Before closing, find whoever
   cited it as a blocker and comment on each one that it has fallen, with the concrete path forward.
   The obligation belongs to whoever closes it: whoever is blocked, by definition, does not know
   they stopped being blocked. One notice too many costs a comment; one too few costs days of
   stalled work.
5. **The boundary of what a session may write outside its own repository is spelled out in full** —
   typically: creating, commenting on, closing, reopening and editing tracker items, and nothing
   else. Never commits, branches, PRs, releases, workflows or configuration in another repository.
   Where there is an automated guard, the guard reflects exactly this list and has a test case.
6. **Without a label, an item does not exist for the process.** Every inbound item leaves its source
   already labeled with its type; an unlabeled item is invisible to all triage, not just "poorly
   filed."
7. **A fact about another repository's state is recorded as the command that resolves it, not as
   the value.** The value rots within minutes when the other side is working in parallel; the
   command does not.

## How to adopt it in a new product (steps)

1. **Decide early whether the product will span more than one repository** — in W00, with the user.
   If so, the coordination repository is born (or a coordination section in the main one) with the
   initial precedence table.
2. **Write the precedence table** with the subject areas that already exist; each new repository
   adds its row when its onboarding item closes.
3. **Create the type labels** (request, question, fact, dependency) in every participating
   repository, and the item body template: where it comes from, context with links, the subject (a
   single one), closing criterion, references.
4. **Wire rule 2 into session close:** each repository's STATE.md records, in §In progress, the
   items open in other repositories that block it and the ones it owes to others.
5. **Wire the guard** against writes outside the repository wherever the tool supports it
   (`adapters/claude-code.md` §Permissions and autonomy), with the list from rule 5.
6. **Record the decision** as an ADR in the repository that owns the global architecture.

## Variations and trade-offs

- **Star (everything goes through coordination)** — simpler to watch, but turns the coordination
  repository into a mailman and whoever operates it into the bottleneck; it was the option rejected,
  with measurement, in the origin ecosystem.
- **Monorepo** — solves the transport problem by construction (one STATE.md, one Git), at the cost
  of merging the lifecycles and permissions of pieces that evolve at different paces; it is the
  right choice for a small team with coupled pieces.
- **Two copies of the framework, one per repository**, synced independently — the normal case; one
  copy shared by two products is the opposite of this module and is not supported
  (`playbooks/sync-framework.md`).

## Example (1–2, multi-domain)

- **Data platform with three services** (ingestion, catalog, portal): the catalog changes an
  identifier's format. In the same PR it opens a dependency item on ingestion and on the portal,
  each with the criterion "client regenerated and contract tests green." The portal closes its own
  item referencing the commit; ingestion asks back, and the answer lands in a catalog ADR — not in
  the item.
- **SaaS product with a gateway to a third-party system in its own repository:** the product
  discovers that a third-party field changed semantics. It does not fix its own copy of the rule: it
  opens a fact in the gateway repository, the subject area's owner; the gateway updates the
  documentation and notifies the two other consumers that had cited it as a blocker.

## Known pitfalls

- **The owner as transport.** If decisions travel as pasted prose between sessions, the process has
  the person's memory and no state of its own — it is the problem this module exists to solve.
- **Copying the twin's file.** A literal cp of a fix from the sibling repository opened, in the
  origin ecosystem, false negatives in a credentials guard and undid an encoding fix on this side.
  Adopt the clause, compare the body first.
- **Closing without notifying.** See rule 4; it is the costliest and most silent failure.
- **A territory reservation written inside the PR of the work itself** only shows up once it no
  longer protects anything (`core/orchestrator.md` §Parallelism).

## Related

- `core/orchestrator.md` §Parallelism — concurrent sessions in the same repository, this module's
  sibling within a single repository.
- `core/project-memory.md` — each repository's STATE.md and what it records about the others.
- `core/decision-engine.md` — the ADRs where truth lands.
- `modules/readonly-external-integrations.md` — contract-based integration between pieces.
- `playbooks/sync-framework.md` — one copy of the framework per repository.
- `workflows/W00-project-kickoff.md` — where it is decided whether the product will span multiple
  repositories.
