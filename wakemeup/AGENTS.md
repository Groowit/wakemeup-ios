# AGENTS.md

## Project goals
- Build an iPhone-only native iOS app with SwiftUI.
- Optimize for low manual effort: the user mainly reviews and approves changes.
- Prefer simple, reviewable code over clever abstractions.
- Build a product with a distinct personality instead of a generic polished app template.

## Source of truth
- Use PRODUCT.md as the primary product specification when it exists.
- Use Figma MCP as design context when available.
- Also consult files in `design/` such as screenshots, tokens, and notes.
- If design references conflict, explain the conflict and choose the simpler native iOS solution unless told otherwise.

## Platform and architecture rules
- SwiftUI only unless explicitly approved otherwise.
- Avoid UIKit unless there is a clear technical reason.
- Target iPhone first. Do not introduce iPad-specific layouts unless requested.
- Prefer a lightweight feature-first structure over heavy architecture.
- Use mock data first unless backend integration is explicitly requested.
- Do not add external dependencies without approval.

## Coding rules
- Follow standard Swift naming conventions.
- Keep one primary type per file when practical.
- Prefer small composable views over very large `body` blocks.
- Extract repeated UI into reusable components only when repetition is clear.
- Avoid force unwraps.
- Avoid premature abstractions and unnecessary protocols.

## UI implementation rules
- Prefer native iOS components and interaction patterns.
- Do not chase pixel-perfect parity if it harms native usability or increases complexity.
- Preserve clear visual hierarchy, spacing rhythm, and primary actions.
- When implementing from screenshots or Figma, explicitly note visible mismatches.
- Avoid an "AI-generated", overly safe, or generic startup-app look.
- The main visual direction is slightly kitschy, slightly cute, and pixel-led.
- Favor character, charm, and intentional roughness over glossy gradients and overly smooth surfaces.
- Use pixel-inspired elements selectively: type accents, badges, icons, dividers, stickers, dots, or game-like status displays.
- Keep interfaces playful without becoming noisy, childish, or hard to read.
- Do not over-rely on big rounded cards, soft shadows, purple gradients, or interchangeable dashboard tiles.
- Reuse components only when repetition is truly helpful. Do not force all screens into the same card/template system.

## UX priorities
- UX is a first-class requirement, not a finishing pass after visuals.
- Keep navigation shallow and obvious. Avoid deep tap depth, hidden actions, and multi-step flows when a shorter path works.
- Reduce fatigue: limit visual clutter, keep primary actions easy to find, and avoid interaction patterns that feel tiring or repetitive.
- Preserve comfortable touch targets and thumb-friendly layouts.
- Maintain readability and scanning speed even when using cute or pixel-styled visuals.
- If a visual idea hurts speed, clarity, or comfort, simplify it.
- Design for delight and low friction at the same time.

## Validation rules
- After meaningful changes, run the smallest relevant validation step.
- Prefer making flows reviewable in Xcode Preview or Simulator.
- If build commands become available, use them.
- If validation cannot be run, say so explicitly instead of implying success.

## Output format for every meaningful task
Summarize:
1. changed files
2. what was validated
3. remaining risks, assumptions, or design mismatches

## Review expectations
- Flag broken navigation or state flow.
- Flag unnecessary complexity.
- Flag UI regressions that are obvious in Preview or Simulator.
- Treat unclear assumptions as risks, not facts.

## Maintenance of this file
- Keep this file small and durable.
- When the same mistake or review feedback happens repeatedly, update this file.
- Add directory-specific AGENTS.md files only when a subdirectory needs special rules.
