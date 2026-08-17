# Framework Version

**Current version: 1.0.0** (2026-08-17)

The framework is versioned with [SemVer](https://semver.org/) applied to executable documentation:

- **MAJOR** — changes that break the contract between agents (artifact protocol, lifecycle, agent
  template). Existing projects need a conscious migration.
- **MINOR** — new agents, workflows, loops, modules, templates or playbooks (additive extension —
  see `core/extensibility.md`).
- **PATCH** — fixes and clarifications that do not change behavior.

Every project that copies the framework records **which version it copied** in its `STATE.md`. The
framework evolves in this repository through pull requests and curation
(`playbooks/framework-curation.md`); projects re-synchronize deliberately from release ZIPs —
never automatically.

## Changelog

### 1.0.0 — 2026-08-17

- First public English edition, derived from the private upstream framework (Maestro 2.6.0, PT),
  where it was distilled from real products built from scratch and hardened by a 14-agent
  adversarial audit (43 recommendations implemented). Fully English: structure, paths, tooling
  and prose — verified by `_meta/verify.sh` and a repository-wide residue sweep.
- The ecosystem state starts fresh in this edition: the candidates ledger
  (`knowledge/candidates.md`) and the learning curve (`knowledge/learning-curve.md`) are empty —
  they will be filled by the first products built with this edition and by community field
  reports (`CONTRIBUTING.md`).
