# Go-Live

Gate P8 (F8 → production) — the lifecycle's only **always-human** approval
(`core/quality-gates.md`). Execution owner: `agents/07-devops/deployment-strategist.md`; the
final decision to promote is always the user's, never delegable to an agent.

## Target reconnaissance and environment pre-flight

Runs **before** provisioning — never assume a green field. A poorly characterized target is where
deploys break what was already there, or where the app fails to start over a dependency that was
never tested.

- [ ] Target characterized: is it dedicated or **shared**? What already runs there? Does the new
      service come in **isolated** (own DB/network) and what is the *blast-radius* on what already
      exists? Is the only change to what is already there additive and reversible?
- [ ] Target's resource headroom checked and monitored (disk, memory, ports) — a target near its
      limit before starting is a risk.
- [ ] **Outbound dependencies** the app needs at runtime (e-mail/SMTP ports, external APIs,
      queues) tested **from the target itself** — many providers block ports or egress by
      default; find out now, not with the first user. Extra attention when authentication or a
      critical flow depends on that egress.
- [ ] Target platform's particularities checked: behavior changes between **major versions** of
      images/services, and that the mounted configuration is really the one the service **reads**
      (not a stuck/old copy).
- [ ] Operational access to the target stable during the deploy (reuse connections; avoid
      tripping protections through excess attempts) — so the deploy itself does not self-sabotage.
- [ ] Access-diagnosis decided before it is needed: if the machine answers ping but every TCP
      port times out, it is almost always **path blocking** (the provider throttling the source
      IP after repeated attempts), not a dead machine — confirm in seconds from a third vantage
      point before rebooting or entering recovery mode; repeated access attempts trigger the
      provider's own mitigation.

## Preparation

- [ ] Build/artifact green, with the quality and security gates already passed
      (`checklists/pre-merge.md`, `checklists/pre-production-security.md`).
- [ ] **Deploy path exercised end-to-end** at least once before the day (staging or rehearsal) —
      deploy artifacts existing is **not** the path being exercised; only real production exposes
      what is missing.
- [ ] Backup of the current state (data and infra) taken and **verified** immediately before the
      launch; restore **rehearsed** at least once — a backup that was never restored does not
      count (`agents/06-data/backup-specialist.md`,
      `agents/08-infrastructure/infra-backup-specialist.md`).
- [ ] **Production** authentication flow genuinely exercised (real login, not the development
      shortcut) before there are users.
- [ ] **Production configuration exercised, not only written**
      (`knowledge/proven-patterns.md` §Production configuration): production-environment keys
      compared against dev's, every difference justified; startup refuses a misconfigured
      production; every component with a production-only privilege or flag exercised under the
      real configuration, including the suite on a production profile against the commit being
      launched.
- [ ] **Path played by real concurrent actors** against an environment with engine parity: N
      users in parallel on the flows that write shared state (numbering, reservations,
      counters), including several on the same network and with the same source identity; the
      invariant is read from the DB at the end. This is not a load test, and it is not replaced
      by sequential tests (`knowledge/ai-pitfalls.md` §AR-15).
- [ ] DB migration, if any, done expand-contract — nothing dropped/renamed while still in use
      (`playbooks/expand-contract-db-migration.md`).
- [ ] **Long run left nearly idle** (≥ one cycle of the product's clock — midnight, scheduled
      tasks) with periodic sampling of memory, connections and queues, before the first go-live
      (`agents/10-quality/performance-test-engineer.md` §Rules).

## Rollback

- [ ] Rollback procedure **rehearsed in an equivalent environment**, not just written in the
      runbook (`playbooks/release-and-rollback.md`).
- [ ] Objective rollback criterion defined before the launch (e.g. error rate > X%, latency >
      Yms) — never eyeballed during the incident.
- [ ] Release/rollback runbook updated and accessible (`templates/technical/runbook.md.template`).

## Monitoring

- [ ] Error, latency and availability alerts active and pointing at the right owners before real
      traffic starts.
- [ ] Observation dashboard available to follow the launch window in real time.

## People and communication

- [ ] Owners reachable during the launch window **confirmed**, not just named on a list.
- [ ] Communication plan defined: who tells whom, on success and on rollback.
- [ ] Explicit human approval for production recorded in `STATE.md`, with name and date — never
      implicit or assumed.

## Infra and hard-block

- [ ] Pipeline confirms the destination environment/account/cluster and **aborts** if it does not
      match the intended one — tested to abort on purpose at least once
      (`agents/07-devops/deployment-strategist.md`).
- [ ] Production secrets injected at runtime, never baked into the artifact
      (`agents/07-devops/secrets-manager.md`).

## Related

- `agents/07-devops/deployment-strategist.md` — owner of the release strategy and execution.
- `playbooks/release-and-rollback.md` — the detailed procedure this checklist verifies.
- `core/quality-gates.md` — gate P8, always-human approval.
- `checklists/pre-production-security.md` — precondition of this gate.
- `pipelines/cd-delivery.md` — the delivery automation and the hard-block.
- `workflows/W08-launch.md` — the full F8 workflow.
