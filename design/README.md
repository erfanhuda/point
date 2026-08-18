# Point — Wireframes

Low-fidelity wireframes for the Point iOS app, generated directly from the current SwiftUI implementation at [`../ios`](../ios). This folder holds design references only — the Xcode project lives entirely under `../ios/` so the two don't mix.

**Figma file:** https://www.figma.com/design/4H3TeoQU4CeMc72FRnMLzt

## What's here

A single "Wireframes" page with 9 screen frames (390×844, iPhone-sized), laid out in a 3×3 grid, one per screen in the app:

| Screen | Mirrors |
|---|---|
| Items List | `ios/Point/Views/Items/ItemListView.swift` |
| Item Form | `ios/Point/Views/Items/ItemFormView.swift` |
| Item Detail | `ios/Point/Views/Items/ItemDetailView.swift` |
| Stock Movement | `ios/Point/Views/Stock/StockMovementFormView.swift` |
| Sales List | `ios/Point/Views/Sales/TransactionListView.swift` |
| New Sale | `ios/Point/Views/Sales/TransactionFormView.swift` |
| Add Order Line | `ios/Point/Views/Sales/AddOrderLineView.swift` |
| Sale Details | `ios/Point/Views/Sales/TransactionDetailView.swift` |
| Settings | `ios/Point/Views/Settings/SettingsView.swift` |

Each frame reflects the actual SwiftUI structure — nav bar with `Cancel`/title/`Save` for sheets, grouped `List`/`Form` rows with section headers, the bottom tab bar with the active tab highlighted, and sample data standing in for what a real Item/Transaction would show.

## Fidelity — intentionally low

This is a **wireframe**, not a mockup: grayscale only, no brand color beyond a single blue accent for links/selection/active states, plain rectangles instead of icons or photos, system font (Inter) instead of SF Pro. It exists to communicate screen structure and content hierarchy, not final visual design. If/when this needs to become a high-fidelity mockup, that's a separate pass — importing the design system, real typography, and SF Symbols (see the `figma-swiftui` skill's code-to-design reference for that workflow).

## Regenerating

The wireframes aren't wired to auto-update — if the SwiftUI views change meaningfully, re-run the code → design translation by hand (or ask Claude Code to do it again) rather than assuming this file stays in sync.
