# Accessibility

Practical WCAG verification, screen by screen. Defined in F4 by
`agents/03-experience/accessibility-specialist.md` (accessibility contract) and verified
in F7, before gate P7 (`core/quality-gates.md`). Feeds the review by
`agents/12-reviewers/ux-reviewer.md`.

## Semantic structure

- [ ] Coherent heading hierarchy (a single `h1` per screen, no skipped levels).
- [ ] Native elements used before ARIA (`button`, `nav`, `label`, `table`) — ARIA only where HTML
      falls short.
- [ ] Landmarks (`main`, `nav`, `header`, `footer`) present and without ambiguous duplication.

## Keyboard and focus

- [ ] Every action reachable and executable with the keyboard alone, with no focus trap outside a
      modal's deliberate focus-trap.
- [ ] Tab order follows the screen's visual/logical order.
- [ ] Focus always visible (outline or equivalent), never suppressed without a substitute
      (`outline: none` with no alternative is a fail).
- [ ] Modals/dialogs return focus to the element that opened them, on close.

## Contrast and color

- [ ] Normal text with a contrast ratio ≥ 4.5:1, large text ≥ 3:1 (WCAG 2.2 AA), computed on the
      design system's real tokens, not estimated.
- [ ] No information conveyed by color alone (error/success/selection also carry an icon or text).
- [ ] Touch targets ≥ 44×44px on interactive elements (stricter than WCAG 2.2 criterion 2.5.8's
      24×24 minimum — this covers it).

## Forms

- [ ] Every field has an associated visible `label` — never just a `placeholder`.
- [ ] Validation errors announced to the screen reader (`aria-describedby`, `role="alert"` or
      equivalent), not just signaled by color.
- [ ] Required fields identified in a non-visual way (text or `aria-required`, not just a colored
      asterisk).

## Screen readers

- [ ] Informative images with an `alt` describing the function/information; decorative ones with
      `alt=""`.
- [ ] Tested with a real screen reader on the critical flows — not just with an automated scanner.
- [ ] Dynamic content (toasts, counters, async validations) announced via the appropriate
      `aria-live`.

## WCAG 2.2 criteria

The six AA criteria introduced in 2.2 (October 2023); automated scanners do not catch them, so
they are checked by hand, screen by screen.

- [ ] Focused element never fully obscured by fixed content (sticky headers/footers, cookie
      banner, floating chat) — 2.4.11.
- [ ] Every drag action (reordering, sliders, maps) has a click/keyboard alternative — 2.5.7.
- [ ] Interactive targets ≥ 24×24px (already guaranteed by the 44×44 in the contrast and color
      section) — 2.5.8.
- [ ] Help (contact, chat, FAQ) in the same relative position across all screens — 3.2.6.
- [ ] Information already entered in the same flow is pre-filled or selectable, never asked for
      again — 3.3.7.
- [ ] Authentication without a cognitive test: pasting allowed in credential fields, password
      managers and passkeys work, CAPTCHA (if any) has a non-cognitive alternative — 3.3.8
      (coordinate with `agents/09-security/secure-authentication-specialist.md`).

## Verification

- [ ] Target WCAG level confirmed with the user (WCAG 2.2 AA by default) and legal obligation
      identified (European Accessibility Act — Directive (EU) 2019/882, transposed nationally
      where applicable — when the product is sold in the EU in the covered sectors) —
      `agents/03-experience/accessibility-specialist.md`.
- [ ] Automated scan run (catches ~30–40% of the issues) **and** manual verification by keyboard
      **and** screen reader (`knowledge/permanent-rules.md` §7).
- [ ] Per-screen result recorded in `product/99-records/`.

## Related

- `agents/03-experience/accessibility-specialist.md` — owner of the contract and the verification.
- `agents/12-reviewers/ux-reviewer.md` — who reviews the result in the real flow.
- `checklists/definition-of-done.md` — accessibility as an F4 criterion.
- `modules/single-source-of-content.md` — the copy that screen readers announce.
- `workflows/W04-experience.md` — where the accessibility contract is defined.
