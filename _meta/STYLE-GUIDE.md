# Maestro Framework Style Guide

Mandatory conventions for **all** framework files. A reader must be able to jump from any
document to any other without switching "dialect".

## Language and tone

1. **English**, engineering register, direct voice — no marketing prose. Punctuation follows the
   repo's conventions: spaced em-dashes (` — `) for asides and straight double quotes. The
   Portuguese upstream edition is the source of record; this guide governs contributions to the
   English edition.
2. Direct, practical tone, addressed to whoever will **execute**: full sentences, no filler.
   Explain trade-offs in plain language — the reader may have no technical background (owner's
   mindset: warn about risks before moving on).
3. Every rule is **verifiable**: avoid "must be high quality"; write the criterion that can
   actually be checked.

## Names and structure

4. Files and folders in **English kebab-case** (`agents/09-security/exposed-secrets-hunter.md`).
5. Every file starts with `# Title` and one context line (what it is, who it is for). Agent
   documents follow `agents/_template/AGENT-TEMPLATE.md` **exactly** — every section, in the
   same order.
6. Workflows are numbered `Wnn-name.md`, loops `Lnn-name.md`, lifecycle phases `F0`–`F9`.
7. Cross-references always as a root-relative path between backticks: `core/orchestrator.md`,
   `agents/09-security/pentester.md`. Never "see the security document". **Every referenced
   path must exist** in `_meta/INVENTORY.md`.

## Content

8. **Never assume**: where user input is missing, the document points to
   `core/question-engine.md` with the concrete questions — it does not invent answers.
9. Examples are **realistic and multi-domain** (e-commerce, SaaS, internal app, data platform) —
   the framework is domain-agnostic; no examples tied to the origin domain.
10. Origin knowledge: when a practice comes from the origin project's experience, reference
    `knowledge/origin-lessons.md` instead of retelling the story.
11. Tables for enumerable facts; prose for reasoning. Checklists with `- [ ]`.
12. Where applicable, each document closes with **"Related"**: a list of 3–8 paths where the
    reader naturally goes next.

## Principles that cut across everything (reference, do not repeat)

13. Reversibility by default → `knowledge/permanent-rules.md`.
14. Honesty about data/results — zero tolerance for invention → `knowledge/permanent-rules.md`.
15. Human approval before destructive/bulk actions → `core/quality-gates.md`.
16. Project memory in local, versionable files → `core/project-memory.md`.
17. One agent, one responsibility → `MANIFESTO.md`.

## What the framework does not do

18. The framework **executes nothing on its own** — it describes how AI agents (in any tool:
    Claude Code, Cowork, others) should work. Coupling to concrete tools lives only in
    `adapters/`.
19. No document assumes domain, stack, cloud, or budget — everything is decided with the user
    via the question engine and the decision engines.
