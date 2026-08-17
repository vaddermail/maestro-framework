# AI Observability · account for, see, and cut consumption

Reusable module for products that **call AI models**: every use is accounted for (tokens, cost,
latency), attributed (feature, model, user/organization), visible on a dashboard, with anomaly
alerts and a **per-model kill-switch**. Without this, AI cost is a black box you only discover on
the invoice.

## The problem it solves

Calls to AI models have three dangerous properties: **they cost per use** (not a fixed cost),
**they vary widely** (a badly assembled prompt multiplies tokens) and **they proliferate easily**
(subagent fan-out, retries, bloated contexts). Without dedicated observability:

- nobody knows **which feature** consumes what, so there is no way to optimize;
- an anomaly (retry loop, giant prompt) only shows up in the bill at month's end;
- there is no way to **cut** a specific model without switching off the whole product.

The origin lesson is direct (`knowledge/origin-lessons.md` §E6): fan-out on the expensive tier is
what drains the budget — and what isn't measured isn't governed.

## The model (concepts and entities, stack-agnostic)

- **Usage event** — one record per model call: `model`, `feature`, `user/org`, `inputTokens`,
  `outputTokens`, `cacheTokens`, `cost`, `latency`, `outcome` (ok|error|cutoff), `fingerprint`
  (to deduplicate retries).
- **Attribution** — each event carries the dimensions it will be sliced by: **per feature**
  (which part of the product), **per model** (which one was used), **per user/organization** (who
  consumed). Without these dimensions up front, the dashboard can't answer the useful questions.
- **Tariff** — a `model → price per input/output/cache token` table, versioned; cost is computed
  from the tariff, not guessed. It aligns with the `modules/credit-management.md` ledger when the
  user is charged.
- **Dashboard** — queryable aggregations: cost per day × feature × model, top consumers, cache vs
  fresh tokens (to see whether *caching* is actually saving).
- **Anomaly alert** — a rule over the series: spend/hour above baseline, high error rate, average
  prompt growing. It triggers a notification, not silence.
- **Per-model kill-switch** — switching off a specific model without a deploy
  (`modules/feature-flags.md`), with a declared *fallback* (another model, or honest degradation).

## Non-negotiable rules (numbered, verifiable)

1. **Every AI call emits a usage event.** Verifiable: a test/guardrail that fails if there is a
   model-call path without instrumentation (a sweep as in `knowledge/proven-patterns.md` §7).
2. **Cost computed from the versioned tariff, never hardcoded.** Verifiable: changing the tariff
   changes the reported cost; a price embedded in the code is a bug.
3. **Every event is attributable to the three dimensions** (feature, model, user/org).
   Verifiable: no event with a missing dimension reaches the dashboard.
4. **A per-model kill-switch exists with immediate effect.** Verifiable: switching off a model
   redirects or degrades on the next request, without a deploy (`modules/feature-flags.md`).
5. **Anomalies alert, they don't pass in silence.** Verifiable: injecting a simulated spike fires
   the configured alert (`knowledge/proven-patterns.md` §10 — visible fallbacks).
6. **Optimization prerequisites are verified before being trusted.** Before assuming *prompt
   caching* saves, measure cache vs fresh tokens on the dashboard; an unconfirmed optimization is
   an assumption, not a saving.
7. **No secrets in the events.** Prompts/responses may contain sensitive data; what is recorded
   for cost includes no content by default, and never keys (`knowledge/permanent-rules.md` §5).
8. **Retries don't count double by mistake.** The `fingerprint` distinguishes a repeated call
   from two real uses; the cost reflects what was actually spent.

## How to adopt it in a new product (steps)

1. **Wrap all AI calls behind a single gateway** — one model client everything goes through; that
   is where the instrumentation lives (not scattered across every call-site).
2. **Define the usage event and the versioned tariff**; tie the tariff to the model provider's
   official pricing documentation (see the tool coupling in `adapters/claude-code.md`).
3. **Emit the event on every call** through the gateway, with the three attribution dimensions.
4. **Build the dashboard** of cost/tokens/latency per dimension
   (`agents/05-backend/observability-architect.md`).
5. **Configure anomaly alerts** with a baseline and thresholds agreed with the budget owner.
6. **Wire the per-model kill-switch** to the flags, with a declared *fallback* per feature.
7. **Review periodically** with `agents/13-guardians/cost-guardian.md`: where to save, which
   optimization to confirm, which model to swap via routing (`core/model-routing.md`).

## Variations and trade-offs

- **In-house instrumentation vs dedicated platform.** In-house (events in the DB + a simple
  dashboard): full control, zero dependencies, enough to start. Platform
  (Langfuse/Helicone/OpenTelemetry-GenAI/…): rich traces and ready-made dashboards, one more
  dependency and possibly content sent to third parties — weigh against rule 7.
- **Measuring only cost vs full traces.** Cost per dimension is the actionable minimum;
  prompt/response traces help debugging but raise privacy and volume concerns — sample instead of
  keeping everything.
- **Accounting vs charging.** Observing (this module) is seeing the cost; **charging** the user
  is the `modules/credit-management.md` ledger. They share the tariff and the usage event, but
  they are distinct responsibilities — not every product that observes also charges.
- **Hard kill-switch vs soft degradation.** Cutting a model can return an honest error or fall
  back to a cheaper model; the choice is per feature (an optional suggestion degrades; a critical
  extraction fails visibly).

## Example (multi-domain)

**Support SaaS — AI-generated summaries.** Each ticket summary emits an event
`{feature: ticket-summary, model: X, org: 88, tokens_in, tokens_out, cost}`. The dashboard shows
one organization generating 60% of the cost by reprocessing summaries in a loop; it gets
investigated and the loop is cut. When model X's provider has an incident, the kill-switch
redirects `ticket-summary` to model Y (cheaper, shorter summary) — honest degradation, signaled
in the UI.

**Data platform — record classification.** Before trusting that *prompt caching* would reduce the
bill, the cache-tokens/fresh-tokens ratio is measured on the dashboard: it sat at 5% (the prefix
wasn't stable). The prompt is adjusted to maximize the shared prefix and the jump to 70% is
confirmed — a **verified** optimization, not an assumed one (rule 6).

## Known pitfalls

- **Per-call-site instrumentation:** scattering the accounting across every call guarantees one
  escapes; the single gateway (step 1) is what makes rule 1 verifiable.
- **Trusting an unmeasured optimization:** *prompt caching* only saves if the prefix is stable
  and long enough — assuming the saving without seeing it on the dashboard is self-deception
  (rule 6).
- **Hardcoded cost that ages:** the provider changes prices; a number in the code drifts from the
  real invoice. The tariff is versioned data (rule 2).
- **Logging prompts with personal data/secrets:** it turns the cost log into a privacy risk;
  store metrics, not content (rule 7).
- **Retries counted as usage:** a backoff that re-calls the model inflates the apparent cost if
  not deduplicated by fingerprint (rule 8).
- **A dashboard without attribution:** a global cost total doesn't say **where** to cut; without
  the three dimensions, the dashboard is pretty and useless.

## Related

- `core/model-routing.md` — choosing the model per task is the biggest cost lever.
- `modules/credit-management.md` — the ledger that charges the observed consumption, when billing
  exists.
- `modules/feature-flags.md` — the per-model kill-switch.
- `agents/13-guardians/cost-guardian.md` — watches cost on a cadence and suggests optimizations.
- `agents/05-backend/observability-architect.md` — traces/logs/metrics these events fit into.
- `modules/single-source-of-content.md` — the catalog that grounds the AI assistant.
- `knowledge/origin-lessons.md` — §E6 (routing and fan-out on the expensive tier).
