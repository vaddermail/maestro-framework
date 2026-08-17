# Web Performance

Budgets and real measurements, not estimates. Defined in F4 by the
`agents/03-experience/web-performance-specialist.md`, measured throughout F6 and verified in F7
before the P7 gate (`core/quality-gates.md`). In production, continuous ownership passes to the
`agents/13-guardians/performance-guardian.md`.

## Budgets defined

- [ ] LCP, CLS, INP and TTFB targets defined per **route type** — never a single global target.
- [ ] Weight budget (KB of JS/CSS) and request count per route defined and treated as a
      **blocking** limit, not an aspirational one.
- [ ] Reference device and network confirmed with the user (e.g. mid-range + 4G for public
      routes; see `agents/03-experience/web-performance-specialist.md`).

## Measurement conditions

- [ ] Measured in a small viewport (~390px) **and** a large one — not just one of the two
      (`knowledge/permanent-rules.md` §7).
- [ ] Measured with CPU/network throttling active, simulating the reference device/network — never
      only on the developer's laptop on fiber.
- [ ] Measured with a cold cache (first visit), not just with resources already cached.

## Core Web Vitals

- [ ] LCP within budget on the measured route; the LCP resource never depends on lazy-load or JS.
- [ ] INP within budget on the critical interactions (forms, dense lists).
- [ ] TTFB within budget, with the source of the time confirmed (server vs. network).

## Images and bundles

- [ ] Images in a modern format, responsive dimensions, `lazy` outside the first screen.
- [ ] JS bundle per route within the defined budget; non-critical code deferred
      (code-splitting).
- [ ] Web fonts with `font-display` and a metric fallback, without blocking rendering.

## Visual stability

- [ ] CLS within budget (ideally near zero); dimensions reserved for
      images/embeds/ads before they load.
- [ ] Nothing visible jumps position after the initial load in the critical flows.

## Related

- `agents/03-experience/web-performance-specialist.md` — owner of the budgets and the verification.
- `agents/03-experience/responsiveness-specialist.md` — the layout the ~390px measurement covers.
- `agents/13-guardians/performance-guardian.md` — continuous monitoring from this baseline.
- `agents/12-reviewers/performance-reviewer.md` — who reviews against the budgets.
- `checklists/definition-of-done.md` — performance as an F4 criterion.
