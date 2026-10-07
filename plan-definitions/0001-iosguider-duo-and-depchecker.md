# Plan 0001 — IOSGUIDER iPhone Duo update + new DEPCHECKER agent

> **Status: APPROVED** (2026-10-07) — ready for implementation. Suggested executor: `AGENT: ALPHA` following the task breakdown below.

## Context

This repository (`agents`) is a universal agent prompt registry. The single source
of truth is the plain-text definitions in `agents/*.txt`. Provider-specific files
(`.github/agents/*.agent.md`, `.opencode/agents/*.md`, `.cursor/agents/*.md`,
`.codex/agents/*.md`, `.claude/agents/*.md`) and the master index `AGENTS.md` are
generated from it by `scripts/generate.sh` (or `generate.bat`), so a definition
change is not complete until the generator is re-run for the relevant providers
and the output committed.

Scope of this plan (2 tasks):

1. **Update IOSGUIDER.** Two new responsibilities:
   - Review designs against the new **iPhone Duo** guidelines (Apple's first
     foldable iPhone, announced September 2026, running iOS 27). Key topics from
     Apple's "Designing for iPhone Duo" HIG page: dual displays, device poses,
     dynamic layouts, size classes (compact/regular), reserved regions
     (center fold region, vertical controls), vertical (side) toolbars/tab bars,
     split-view behavior, fold avoidance for interactive elements, safe areas and
     adaptive margins, and previewing poses via Device Hub in Xcode.
   - Review **App Store submission compliance** (App Review guidelines).
   - Explicit constraint: IOSGUIDER **must not fix issues** unless explicitly
     requested, because the reviewed project may be a proof of concept.

2. **New agent DEPCHECKER** — dependency reviewer. Responsibilities:
   1. List the dependencies attached to the project.
   2. Check whether each dependency is actually in use (unused ones flagged).
   3. Check the license of each dependency and whether the project complies with it.
   4. Detect any dependency whose license forces a specific license on the
      project code (copyleft / virality, e.g. GPL, AGPL, LGPL).
   5. List changes required to comply with those licenses (e.g. adding an
      "About"/acknowledgements page, notices redistribution).

## Current state (evidence)

- `agents/IOSGUIDER.txt` — current definition covers platform detection,
  evidence inspection, iOS HIG review, and conditional CarPlay review, plus a
  report template. **No iPhone Duo coverage, no App Store compliance check, and
  it does not explicitly forbid unsolicited fixes.**
- `agents/*.txt` — 9 agents exist (ALPHA, BIGBOSS, GOODREST, IOSGUIDER, OMEGA,
  PARANOIA, PERFO, PLANNER, UNCLEBOB). No DEPCHECKER.
- Generated outputs (`AGENTS.md`, `.opencode/agents/*.md`, etc.) will be out of
  date after the definition edits; they must be regenerated (see step 4).
- `tests/` currently contains paired `*_code.*` / `*_clean.*` sample inputs for
  ALPHA, BIGBOSS, GOODREST, OMEGA, PARANOIA, PERFO, UNCLEBOB. There are no
  samples for IOSGUIDER and PLANNER yet; this plan adds pair files for
  IOSGUIDER (Duo + App Store) and DEPCHECKER so the new review behaviors can be
  exercised manually.
- README lists agents; AGENTS.md is generated.
- There is a `check-sync.sh` script to verify generated files match `agents/`.

## Changes

### 1. Update `agents/IOSGUIDER.txt`

- Surgical edits, matching the file's existing plain-text style.

- **Description line.** Update to:
  `DESCRIPTION: iOS, iPhone Duo and CarPlay design-guidelines reviewer for projects and provided images; also checks App Store submission compliance.`
- **Agent definition section.** Reword opening to say the reviewer analyzes
  projects and supplied images against current Apple HIG **including the
  iPhone Duo guidance**, and **App Store submission compliance**, and state the
  non-remediation rule: *"Report findings and recommendations only. Do not
  modify, patch or fix anything unless the user explicitly asks for fixes
  (e.g. 'fix the issues', 'apply the recommendations'). An unreviewed project
  may be a proof of concept, so unsolicited fixes are out of scope. For each
  finding give a concrete recommendation for the user to apply.*"
- **New workflow step — "Review for iPhone Duo".** Inserted after the iOS HIG
  review step. Content:
  - Determine applicability from evidence in the project (e.g. SDK
    availability, target device settings, or screenshots/mockups of the Duo;
    the foldable API/device is new, so source-only projects may not show
    explicit flags — treat as: if the app targets iOS and does not eliminate
    Duo as a supported device, the Duo review applies as a *risk-based*
    section).
  - Review at least these areas (from Apple's Designing for iPhone Duo page):
    - dual-display experience continuity when opening/closing the device;
    - dynamic layout: layout margins, safe-area insets, no fixed widths, no
      attachment to a specific display;
    - size classes (compact outer / regular inner) driving adaptation rather
      than custom per-pose layouts;
    - reserved regions: center fold region, vertical control zones; use of
      Reserved Region API (SwiftUI `Reserved Region`, UIKit
      `UIView.reservedRegion`) when system components cannot and custom
      components sit near the fold;
    - vertical (side-positioned) toolbars/tab bars/nav controls on outer and
      landscape inner display; keep standard horizontal bars on inner portrait;
    - split-view behavior: expands on inner, collapses to single pane on
      outer, margins adapting to the fold;
    - fold avoidance: interactive elements nudged/positioned away from the
      hinge/crease when partially folded; prefer system components that get
      this behavior automatically;
    - sheet/alert/menu presentation around the fold (system components move
      to avoid the crease automatically; custom components are a risk);
    - games: playable in every pose, aspect-ratio change preferred over
      letterboxing/pillarboxing, artwork in padding areas if unavoidable;
    - pose support tested/previewed via Device Hub in Xcode (note missing
      previews as a limitation when absent).
  - Add per-finding fields: **Pose/Display** (outer, inner open, inner
    partially folded, landscape, etc.).
  - Any iPhone Duo finding is reported but its severity must consider that
    most standard-component-based apps risk little (Apple states apps built
    with standard components and designed for resizing adapt with little
    adjustment).
  - If evidence shows the app does not reach Duo devices or provides no Duo
    review material, state that the Duo review is not applicable (mirroring the
    CarPlay conditional logic).
- **New workflow step — "Check App Store submission compliance".** Separated
  from the design review, using public App Review Guideline areas as the
  checklist: app completeness (placeholder or beta content), crashes/bugs,
  accurate metadata and screenshots, accurate privacy details and data-use
  disclosure, permission/permission-purpose-string review (Info.plist usage
  description keys), privacy policy URL, compliance with legal requirements,
  minimum functionality, spam/duplicate app screening, correct age rating,
  correct handling of user-generated content, sign-in rules (Sign in with
  Apple where required, demo account availability for review, account deletion
  flow), IAP rules, export compliance references in the project, and category
  fit. Apply the same evidence-based approach: each compliance point is
  reported as **violation / risk / observation**, with the same severity scale
  and confidence levels already used, citing file/manifest/symbol or noting
  "not verifiable from supplied material". State clearly that this is not a
  guarantee of App Review approval.
  State clearly that a finding here is reported, not fixed, per the non-
  remediation rule.
- **Report format.** Extend the template:
  - Keep Platform determination, Summary, Findings, Limitations sections.
  - In Summary, include a line: *App Store submission readiness: [ready / at
    risk / not ready / not reviewed]*, clearly marked as informational, not a
    guarantee.
  - Add subsections **"App Store submission compliance"** and **"iPhone Duo"**
    (like the existing CarPlay sub-section rule) so each specialist area is
    clearly separate; Duo findings get the Pose/Display hint inside the
    existing finding schema.
- **Non-remediation rule (global).** After the workflow sections, one clear
  statement in the definition: *"Never modify or fix code/UI without an
  explicit request. If the user asks for fixes, confirm and address only what
  was requested."* (This is what makes it safe to review PoCs.)
- Keep the existing CarPlay block, report section/labels, and the final line
  about language/conciseness/limitations; extend the last paragraph to mention
  the new scope items rather than rewriting unrelated text (Rule 3).

### 2. New `agents/DEPCHECKER.txt`

New plain-text definition with the standard metadata header, following the
structure of existing agents (ID, NAME, DESCRIPTION, "## Agent definition",
workflow steps, report template, language note):

- Metadata:
  - `ID: DEPCHECKER`
  - `NAME: DEPCHECKER`
  - `DESCRIPTION: dependency reviewer. Lists project dependencies, detects those that are unused, verifies license compliance, flags copyleft/viral licenses, and lists license-compliance changes (e.g. notices/credits pages).`
- Agent definition opening:
  - You are a dependency and license compliance reviewer. Analyze the project
    and report; you **do not modify** the project unless explicitly requested.
  - Scope: direct dependencies. Transitive dependencies are covered when the
    ecosystem can enumerate them (lockfiles); otherwise noted as a limitation.
  - Ecosystem detection: manifest/lockfile-driven (package.json+lock,
    Package.swift, Podfile/Podfile.lock, Cartfile, pubspec.yaml, go.mod,
    requirements*.txt/pyproject.toml/uv.lock, *.csproj/packages.lock.json,
    Cargo.toml/Cargo.lock, Gemfile*.lock, composer.json/lock, pom.xml/build.*,
    vcpkg.json, etc. If none found, state clearly that no dependency manifest
    was found and stop the review.
  - Evidence-based, no invented facts. If a license cannot be determined
    from the project (e.g. no vendored licenses, or no network access), say
    so.
- Required workflow — exactly the five user-assigned duties, one section each:
  1. **List dependencies.** Enumerate direct dependencies from the manifest(s)
     (name, version constraint or pinned version, source/registry, type
     [runtime/dev/build]). If multiple manifests exist, list each and flag
     inconsistencies. For locked ecosystems also give the resolved versions
     from lockfiles.
  2. **Check actual usage.** For each dependency, search the codebase for
     imports/requires/includes/references (e.g. `grep` for module names in the
     right file types). Classify as used / unused / unclear (dynamic calls,
     plugins, reflection, build tooling, peer deps), with evidence and a
     confidence level. List candidates for removal but do not edit the
     manifest or code — recommend only.
  3. **License per dependency.** Try to determine the license of each
     dependency from the evidence available to the agent (vendored
     LICENSE/COPYING files, manifest metadata fields, declared license files
     in the repo, package metadata). Where network lookups are possible (e.g.
     registry APIs), the agent may use them; where not, mark as
     "needs verification". Map to SPDX identifier or exact name.
  4. **License compliance and virality check.** Compare each dependency's
     license against the project's own license (read the project's
     LICENSE/COPYING file and/or its package metadata license field). Classify
     compatibility (permissive / weak copyleft / strong copyleft / no license
     = all-rights reserved, treat as incompatible unless written permission).
     Flag dependencies whose license **forces a license onto the project code**
     (strong copyleft like GPL/AGPL for linked code; LGPL dynamic-linking
     conditions; copyleft-effected or network-copyleft like AGPL for
     server use) and explain how (e.g. "AGPL §13 source offer"). State
     explicitly any dependency that would require the project to change its
     own license or distribution terms.
  5. **Required changes to comply.** List the concrete compliance actions, as
     **proposals, not edits**: e.g. add an About/Legal/Acknowledgements page
     (or "Third-party notices" file) listing each dependency with name,
     author, license and its license text/notice; include attribution
     headers where required; redistribute license texts with binaries; add
     source-offer for GPL binaries; state license-compat conflicts that
     cannot be fixed by attribution alone (would need license swap or
     removal); note if a license requires "changes" notice (Apache-2.0 §4b).
     Mention that a generated notices file should be verified by a human,
     since a reviewer agent cannot guarantee legal accuracy.
  - Order the workflow as: detect ecosystem → list → usage → licenses →
    compatibility/virality → required changes. (This preserves the user's
    numbered order.)
- Report template (summary, then one section per duty above, then
  limitations):
  - **Summary** (counts: total, used, unused, unclear, license issues,
    viral-license findings, compliance actions needed);
  - **Dependencies** (table/section listing name, version, type, usage status
    + evidence, license + SPDX-like id, compatibility verdict);
  - **Unused and unclear dependencies** (recommended-for-removal list,
    proposals only);
  - **License compliance** (compatibility analysis and virality findings with
    severity High (must change license or remove), Medium (conditions apply),
    Low/observation);
  - **Required compliance changes** (the About/acknowledgements proposals,
    notice-text inclusions, source-offer obligations; these are proposals that
    a human must approve);
  - **Limitations** (what could not be verified: transitive deps not
    resolvable, licenses needing verification, network unavailable).
  - Also require: "If no dependency manifest is found, state this explicitly
    and stop." and "If everything complies and nothing is unused, state this
    explicitly" (positive-statement requirement like other reviewers).
  - Non-remediation rule: same as IOSGUIDER — list required changes only;
    do not edit manifests/code/licenses unless explicitly asked.

### 3. Aggregate references

- `AGENTS.md` master index: regenerated by the script (see step 4), which adds
  the DEPCHECKER entry and updates the IOSGUIDER entry automatically. No
  manual edits needed for it beyond running the generator (avoid manual edits
  since it is a generated file).
- `README.md`: update the "Available Agents" list:
  - IOSGUIDER entry → "iOS, iPhone Duo and CarPlay design-guidelines reviewer
    for projects and provided images; also checks App Store submission
    compliance."
  - Add entry: "**DEPCHECKER** — dependency reviewer (lists dependencies,
    detects unused ones, checks license compliance and copyleft/viral license
    risks, lists compliance changes)."
  - Keep list ordering consistent with the current file: ALPHA, OMEGA,
    PARANOIA, PERFO, BIGBOSS, GOODREST, UNCLEBOB, IOSGUIDER, DEPCHECKER
    appended last (it is the new one; alphabetical insertion would imply a
    sort rule the list does not currently follow).

### 4. Regenerate provider files

After steps 1–3, run the generator for each provider and commit the results
(also verifying with check-sync):

```bash
./scripts/generate.sh --provider github
./scripts/generate.sh --provider opencode
./scripts/generate.sh --provider cursor
./scripts/generate.sh --provider codex
./scripts/generate.sh --provider claude
./scripts/check-sync.sh --provider opencode   # etc.
```

Note (verified against `git ls-files`): of the generated outputs, only
`AGENTS.md` is tracked. Regeneration is required for two reasons:
- to update the committed `AGENTS.md` master index (DEPCHECKER entry + updated
  IOSGUIDER description must appear there);
- to refresh the local provider files (e.g. `.opencode/agents/`) that
  `install.sh` copies from, so the locally installed agents pick up the
  changes. All provider directories (`.github`, `.opencode`, `.cursor`,
  `.codex`, `.claude`) are gitignored.

### 5. Manual acceptance tests in `tests/`

Following the existing `*_code.*` / `*_clean.*` pair convention (non-compliant
input vs. compliant input). These are manual review inputs; the repo has no
test runner — `tests/` holds sample inputs for exercising the agents with a
provider:

- `tests/iosguider_duo.md` — an app description with a design intended for
  iPhone Duo with several deliberate issues: fixed widths instead of adaptive
  layout, custom controls not using the Reserved Region API, interactive
  buttons over the hinge, letterboxed game, no Device Hub previews, missing
  Info.plist purpose strings, no privacy policy URL, placeholder screenshot;
  plus a proof-of-concept note in the header to verify the agent reports but
  does not fix.
- `tests/iosguider_clean.md` — a Duo-ready compliant app description with
  adaptive layout, size classes, Reserved Region use, fold avoidance behaviors,
  proper purpose strings, privacy policy, screenshots, etc. Should yield
  minimal/no findings and a "ready, but no guarantee" App Store statement.
- `tests/depchecker_code.md` — a small project with a populated manifest
  and codebase: dependencies declared but some unused (e.g. a logging lib
  declared, never imported), one strong-copyleft dep with a known license that
  forces obligations (e.g. how a GPL library inside an MIT-licensed project
  should be handled), one permissive dep with a notice-redistribution
  requirement (Apache-2.0), one unknown-license dep, plus one dependency used
  only in build tooling (should be classified correctly as build/dev).
- `tests/depchecker_clean.md` — a manifest/codebase in which all deps are
  permissive (MIT/BSD/Apache-2.0), all used, an existing acknowledgements page,
  notices redistribution present, and `NOTICE`-style attribution kept. Should
  get a clean bill of health.

Sample content in these files does not need to compile; it is review input for
running against an installed agent, so keep it short but complete enough to
trigger the checks. Optionally, the two DEPCHECKER sample files can describe
the same small fictional project, one with problems and one clean.

## Out of scope

- Any change to `scripts/generate.sh` / `generate.bat` / `check-sync.*` /
  `install.*` (the generator already picks up new `agents/*.txt` files and
  preambles automatically and regenerates all providers; the scripts already
  sanitize agent IDs safely).
- Any change to the `preambles/compact-thinking.txt` preamble.
- Modifying any other agent definition.
- Creating a `tests/` runner or CI; the samples are review inputs only.
- Legal advice or guaranteed license determinations (DEPCHECKER must state
  this and flag "needs verification" when the license can't be determined
  from the evidence available).

## Risks and notes

- **Non-remediation rule context.** The current IOSGUIDER does not explicitly
  state that it must not fix issues. This plan adds that rule to both agents
  (IOSGUIDER and DEPCHECKER); it is essential for the user's proof-of-concept
  concern.
- **iOS 27/iPhone Duo HIG topic list.** The topic list is based on Apple's
  published "Designing for iPhone Duo" page and the Sept 2026 Tech Talk; if
  Apple extends it later, the definition can be extended afterwards
  (definitions are plain text, easy to amend).
- **App Store review guidelines change**; the definition names guideline
  *areas* rather than guideline numbers, so it stays valid across revisions.
- **Security/robustness:** agent IDs are sanitized by the generator; there is
  no shell-injection risk from the new name (alphanumeric only).
- **License-verification aspect of DEPCHECKER:** the definition requires
  evidence-based determinations and "needs verification" labels when evidence
  is absent, plus a disclaimer that it is not legal advice.
- AGENTS.md is generated; do not hand-edit it.

## Verification

1. `./scripts/generate.sh --provider <p>` runs for all five providers without
   warnings (all five providers: github, opencode, cursor, codex, claude).
2. `./scripts/check-sync.sh --provider <p>` exits 0 for each regenerated
   provider (opencode at minimum).
3. `agents/DEPCHECKER.txt` present with correct metadata;
   `AGENTS.md`, `.opencode/agents/DEPCHECKER.md` and equivalent per-provider
   files exist and contain the same body as `agents/DEPCHECKER.txt` (modulo
   preamble/header).
4. `agents/IOSGUIDER.txt` updated: contains "iPhone Duo" review section and
   "App Store submission compliance" section, and the non-remediation rule.
   Regenerated IOSGUIDER outputs contain the same content.
5. README's "Available Agents" list includes DEPCHECKER and the updated
   IOSGUIDER description.
6. The new test inputs in `tests/` exist and read as deliberate non-compliant
   and compliant samples.
7. Spot-run (optional but recommended): install to a provider and ask the
   agent to review the new test inputs, verifying that:
   - DEPCHECKER confirms manifest detection, lists deps, flags unused, checks
     licenses, flags the copyleft case, proposes compliance changes, and does
     not modify anything.
   - IOSGUIDER produces the Duo and App Store sections, marks severity and
     confidence, and does not modify or fix anything without being asked.

## Task breakdown (suggested commit sequence)

1. `chg: update IOSGUIDER with iPhone Duo design guidance and App Store compliance review` —
   `agents/IOSGUIDER.txt` edits only.
2. `add: DEPCHECKER agent for dependency and license compliance review` —
   `agents/DEPCHECKER.txt` (new).
3. `chg: add review test inputs for IOSGUIDER and DEPCHECKER` —
   test sample pair files in `tests/`.
4. `chg: regenerate agent outputs and update README` — run all five providers
   of generate.sh, run check-sync for opencode, update `README.md`, commit
   `AGENTS.md` (generated) and README changes.
