# Feature Flags and Kill-Switches · turning risk off without a deploy

Reusable module to **separate deploy from activation**: new or risky code ships to production turned
off, gets turned on in a controlled way and — most importantly — **turns off without a new deploy**
when things go wrong. It operationalizes reversibility by default
(`knowledge/permanent-rules.md` §3).

## The problem it solves

Without flags, every risky change is coupled to the deploy cycle: turning it off means reverting
code, rebuilding and networkploying — minutes or hours during which the incident goes on. And there is
no way to expose a feature to 5% of users, nor to cut off an expensive integration in seconds.

Flags give **three levers** that deploys alone do not: roll out gradually, cut off immediately, and
experiment with a subset — all reversible at the flip of a switch. The risk is managing **hygiene**:
a forgotten flag is technical debt nobody dares to remove.

## The model (concepts and entities, stack-agnostic)

Two natures of flag, which **must not be confused**:

- **Release flag** — temporary. Hides incomplete or risky code until it is ready; it exists to be
  **removed** once the feature stabilizes. Expected lifetime: days to weeks.
- **Operational flag (kill-switch)** — permanent. An operations switch that stays forever: turning
  off a notification channel, an AI model (`modules/ai-observability.md`), an external integration
  under maintenance. It exists to be **used**, not removed.

Entities:

- **Flag** — `key`, `nature` (release|operational), `state`, `owner`, `removalDate` (on release
  flags), `description`, `safe default`.
- **Resolution rule** — how the value for a request is decided: global, by percentage, by
  segment/role/organization, by user.
- **Evaluator** — the single point that answers `isEnabled(key, context)`. Flags are never read in a
  scattered way; every read goes **through** the evaluator.
- **Safe default** — the value assumed when the flag service **fails** or the key does not exist. On
  a release flag it is usually **off** (the new feature does not appear); on a protective
  kill-switch it may be **on** (the safety cutoff stays active). Decided per flag.

## Non-negotiable rules (numbered, verifiable)

1. **Every risky change ships behind a flag.** Verifiable in review: a slice that changes critical
   behavior without a flag does not pass the gate (`core/quality-gates.md`).
2. **Every flag has an owner and (if a release flag) a removal date.** Verifiable: a registry/test
   that lists flags without an owner or without a removal date and fails if any exist — the same
   guardrail discipline as `knowledge/proven-patterns.md` §7.
3. **Safe default when the flag service fails.** Verifiable: simulate evaluator unavailability and
   assert that each flag resolves to its documented default, never crashes nor assumes "on" by
   omission.
4. **Release ≠ operational, explicitly marked.** A flag declares its nature; release flags go on the
   removal clock, operational ones do not.
5. **Reads go through the evaluator only.** No code reads the flag source directly; a single point
   resolves, so the kill-switch is reliable and testable.
6. **Kill-switch takes effect immediately, without a deploy.** Verifiable: toggling the flag changes
   behavior on the next request (no restart).
7. **Flag state is auditable.** Who turned what on/off and when is recorded
   (`modules/audit-and-provenance.md`) — a kill-switch flipped during an incident is evidence.
8. **Removing the flag removes both paths.** When retiring a release flag, the dead-branch code is
   deleted **and** so is the key — no always-true `if` and no orphan key left behind.

## How to adopt it in a new product (steps)

1. **Pick the mechanism** (`core/decision-engine.md`): start simple — a configuration table in the
   DB with an in-memory evaluator covers most products. A dedicated service
   (LaunchDarkly/Unleash/Flagsmith/…) only when fine-grained targeting and scale justify it.
2. **Define the Flag registry** with `owner` and `removalDate` mandatory per nature.
3. **Implement the single evaluator** `isEnabled(key, context)` with a safe default and fail-safe.
4. **Wire up the hygiene guardrail:** a test that fails if any flag has no owner, or is an expired
   release flag (`removalDate` in the past and still on).
5. **Integrate with the other modules' kill-switches:** channels from `modules/job-queue.md`,
   models from `modules/ai-observability.md`, integrations from
   `modules/readonly-external-integrations.md`.
6. **Document each flag** in the single source of content if it affects UI
   (`modules/single-source-of-content.md`).
7. **Close the loop:** when a feature stabilizes, schedule the flag's removal as a technical-debt
   task (`loops/L08-technical-debt.md`).

## Variations and trade-offs

- **Config in the DB vs dedicated service.** DB: zero new infra, transactional, versionable; limited
  targeting. Service: percentages, segments, A/B experiments, but one more runtime dependency —
  which is why rule 3 (safe default on failure) becomes critical.
- **Boolean vs multivariate flag.** Start boolean. Multivariate (choosing between several
  implementations) only when running real experiments; until then it is complexity with no return.
- **Static (build-time) vs dynamic (runtime).** Build-time flags strip the dead branch from the
  bundle but do **not** turn off without a deploy — they cannot serve as kill-switches.
  Kill-switches are always runtime.
- **Targeting by percentage vs by segment.** Percentage is the simplest rollout; segment (role,
  organization, region) aligns with `modules/rbac-and-scoping.md` and is preferable when risk is
  unequal across groups.

## Example (multi-domain)

**B2B SaaS — new billing engine.** The invoice-calculation rewrite ships behind `billing-engine-v2`
(release, owner: Billing team, removal: end of quarter). It is turned on for 5% of organizations;
a rounding error shows up; it is flipped back to 0% in seconds, without reverting a deploy that
already carries other fixes. Fixed and gradually re-enabled up to 100%, the flag is removed along
with the old branch.

**Internal app — email integration.** `email-sending` is an operational kill-switch (permanent).
During SMTP provider maintenance, it is turned off: the email jobs from `modules/job-queue.md` pile
up in `pending` instead of failing in cascade; it is turned back on and the queue drains. If the
flag evaluator becomes unavailable, the **safe default** of `email-sending` is "on", so as not to
silence notifications by accident — a decision recorded because it deviates from the release
default.

## Known pitfalls

- **Zombie flag:** the feature stabilized months ago and the flag lives on, with both branches alive
  — nobody knows if it is safe to remove. Rule 2 (removal date) and the technical-debt loop exist
  for this.
- **Dangerous fail-open default:** assuming "on" when the flag service goes down can expose
  incomplete code — it echoes the `?? "ADMIN"` of `knowledge/origin-lessons.md` §C1. The default is
  a conscious decision per flag.
- **Scattered reads:** reading the flag in ten different places makes the kill-switch unreliable;
  centralize in the evaluator (rule 5).
- **Flag standing in for business configuration:** approval thresholds, rates and permissions are
  **not** flags — they are domain configuration data (`modules/approval-engine.md`). Flags turn code
  paths on/off; they do not hold business parameters.
- **Combinatorial explosion:** many interdependent flags create states impossible to test; keep them
  few, independent and short-lived.

## Related

- `agents/07-devops/feature-flags-specialist.md` — the agent that designs and implements flags.
- `agents/07-devops/deployment-strategist.md` — flags as rollback's counterpart at launch.
- `knowledge/permanent-rules.md` — §3 reversibility by default.
- `modules/ai-observability.md` — per-AI-model kill-switch.
- `modules/job-queue.md` — per-channel/job-type kill-switch.
- `modules/audit-and-provenance.md` — trail of who turned what on/off.
- `loops/L08-technical-debt.md` — deliberate removal of expired release flags.
