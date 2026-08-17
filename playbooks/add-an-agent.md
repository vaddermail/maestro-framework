# Playbook — Add an Agent

Extend the framework with a new agent **by addition, never by surgery** on the existing ones
(open-closed principle — `core/extensibility.md`). This is the step-by-step that
`agents/_template/AGENT-TEMPLATE.md` and `core/extensibility.md` describe; following it guarantees
the new agent becomes discoverable by the Orchestrator without breaking anything.

**When it runs:** when a **responsibility no existing agent has** appears and it does not fit as a
section of an existing agent spec. **Who:** whoever extends the framework (typically in a
maintenance session of Maestro itself), on a dedicated branch with a green PR
(`knowledge/permanent-rules.md` §8).

## Preconditions

- [ ] The need is described in one sentence (a "one-liner" in the style of `_meta/INVENTORY.md`).
- [ ] You know the target **category** (`agents/NN-category/`) and the agent's dominant **phase**
      (`core/lifecycle.md`).

## Steps

### 1. Confirm it really is a new agent
**Do:** sweep `_meta/INVENTORY.md` and the category README looking for overlap. Apply the
MANIFESTO's rule: if the responsibility needs an "and" to be described (two independent things),
it is two agents; if it fits as a section of an existing agent spec, it is **not** a new agent.
**Verify:** you can name the **single** responsibility in one sentence and point out why no current
agent covers it.
**If it fails:** if there is overlap with an existing agent, **stop** — either the need is a
clarification in the existing spec (PATCH, not a new agent), or the boundary between the two must
be redrawn before moving on. Never create an agent that duplicates responsibility (`MANIFESTO.md`
§1, `knowledge/ai-pitfalls.md` §7).

### 2. Copy the template into the right category
**Do:** copy `agents/_template/AGENT-TEMPLATE.md` to `agents/NN-category/agent-name.md`
(kebab-case name, international alias in the title if one exists — `_meta/STYLE-GUIDE.md`).
**Verify:** the file exists in the right place with a name following the convention.
**If it fails:** if the right category does not exist, you must **add a category** first (new
folder + README + index entries — `core/extensibility.md`), not force the agent into a category
that is not its own.

### 3. Fill in **all** the sections
**Do:** complete Identification · Objective · When it starts · When it ends · Inputs · Outputs ·
Questions to the user · Rules · Limitations · Workflow · Examples · Best practices · Anti-patterns ·
Interactions · Done criteria. None is optional; if one does not apply, write "Not applicable,
because …". Declare inputs/outputs in terms of **existing artifacts** (`core/artifact-protocol.md`);
pick the model tier in `core/model-routing.md`.
**Verify:** no section still has *placeholder* text from the template; the **Limitations** name the
neighboring agent responsible for each excluded item (explicit boundaries, no overlap).
**If it fails:** a section you cannot fill in is a sign the responsibility is still fuzzy — go back
to step 1.

### 4. Handle new artifacts (if any)
**Do:** if the agent **creates** an artifact that does not yet exist, add it to
`core/artifact-protocol.md` as a **new row** (never change the existing rows).
**Verify:** the new artifact has an owner, a location and declared consumers; the existing ones
remained intact.
**If it fails:** if it seems necessary to **change** an existing artifact, that is a contract change
(MAJOR — the exception path of step 7 in `core/extensibility.md`), not a simple "add an agent".

### 5. Register in the indexes **in the same step**
**Do:** add the agent's row to the category README (`agents/NN-category/README.md`) **and** to
`_meta/INVENTORY.md`, with the same one-liner. If the agent joins a workflow, add the step in the
respective workflow as a **new step**, without reordering the existing ones unless a reason is
recorded.
**Verify:** the agent appears in **both** indexes with mutually consistent descriptions;
registering = existing (`core/extensibility.md`). An agent outside the inventory is invisible to
the Orchestrator.
**If it fails:** if it only landed in one index, the agent is half-registered — fix it before
closing (it is the classic cause of broken cross-refs).

### 6. Check the cross-references
**Do:** confirm that **all** paths cited in the new spec exist in `_meta/INVENTORY.md`, and that
the declared **Interactions** line up with the specs of the neighboring agents (upstream/
downstream/parallel). Confirm that **no existing spec was edited** to accommodate the new one.
**Verify:** a `grep` of the cited paths against the inventory leaves no orphan; `git diff` shows
**only** new files + the additions to the indexes/protocol, never changes to existing agent
specs.
**If it fails:** if the addition required editing another spec, the Orchestrator or the template,
**the design is wrong** — go back to step 1 (`core/extensibility.md`: "what is never needed").

### 7. Bump the framework version
**Do:** increment the **MINOR** version in `_meta/VERSION.md` (new agent = additive extension) and
record the entry in the framework changelog.
**Verify:** `_meta/VERSION.md` reflects the new MINOR version with the added agent's line.
**If it fails:** if the change turns out to break a contract between agents, it is not MINOR — it
is MAJOR, and needs the written justification and the expand-contract path of
`core/extensibility.md`.

## Rollback

Pure addition is trivially reversible: remove the agent's file and the **two** index rows
(category README + inventory), the artifact row (if created) and the VERSION bump — nothing else
was touched, by construction. If an agent stops making sense later, **it is not deleted blindly**:
mark it `obsolete` at the top with a pointer to its replacement and take it out of the active
indexes (`core/extensibility.md` §Deprecating).

## Related

- `agents/_template/AGENT-TEMPLATE.md` — the mold to copy and fill in completely.
- `core/extensibility.md` — why the addition is safe and what never needs touching.
- `_meta/INVENTORY.md` · `agents/README.md` — the indexes where registering = existing.
- `core/artifact-protocol.md` — where new artifacts are declared (by addition).
- `_meta/VERSION.md` — the MINOR bump and the framework changelog.
- `core/model-routing.md` — the new agent's model tier.
- `MANIFESTO.md` — one agent, one responsibility (the test in step 1).
