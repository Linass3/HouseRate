# CLAUDE.md

## Project Intent

HouseScore is an iOS app for locally tracking and reviewing house listings. Keep the product small, fast, private, and useful for repeated personal use.

In the future, the app may support sharing listings with friends online. Keep today's implementation local-first, but avoid decisions that would make future sync, account-based sharing, conflict handling, or privacy controls unnecessarily difficult.

## Core Technical Direction

- Use SwiftUI for UI, SwiftData for local persistence, Swift Testing for tests, and MVVM for app structure.
- Store data locally for now. Do not add cloud sync, backend services, analytics, authentication, or remote persistence unless explicitly requested.
- Design data models with future sharing in mind: prefer stable identifiers, clear ownership boundaries, explicit timestamps, and fields that can serialize cleanly later.
- Prefer Apple's modern APIs: Observation (`@Observable`), SwiftData (`@Model`, `ModelContainer`, `ModelContext`), Swift Concurrency, Swift Testing, and current SwiftUI patterns.
- Keep dependencies minimal. Ask before adding third-party libraries.
- Use relevant available skills/tools before implementation when they apply to concurrency, design, architecture, testing, or modern Apple API usage.

## Architecture

- Keep SwiftUI views focused on rendering and user interaction.
- Keep state changes, validation, sorting, filtering, and persistence coordination in view models.
- Persistence is isolated behind the `ListingStore` protocol; `SwiftDataListingStore` is the SwiftData-backed implementation and the single owner of `ModelContext`. View models depend on `ListingStore` (via DI), not on `ModelContext` directly, so SwiftData stays behind one seam and a future sync backend can conform to the same protocol.
- Use dependency injection for stores/`ModelContext`, `ModelContainer`, clocks/dates, and other collaborators so code remains testable.
- Keep SwiftData model types small and explicit. Add migrations deliberately when persisted schema changes.
- Prefer simple architecture until complexity proves it needs another layer. The `ListingStore` seam is the current persistence boundary; add further stores/services only when they reduce duplication or isolate real complexity.
- Avoid putting business logic in previews, views, or app entry points.

## SwiftData Guidelines

- Use SwiftData as the source of truth for persisted app data.
- Route SwiftData access through `SwiftDataListingStore` (the single `ModelContext` owner); keep new `ModelContext` calls out of view models and views.
- Use in-memory `ModelContainer` configurations for previews and tests. When retaining an in-memory container in a test, hold it in a stored property for the test's lifetime — returning `container.mainContext` from a helper lets the container deallocate and SwiftData will trap on first use.
- Keep `ModelContext` usage on the appropriate actor, usually the main actor for UI-driven flows.
- Handle persistence failures intentionally. Avoid silently swallowing errors in new code unless the UX has a clear fallback.
- Do not introduce Core Data, Realm, SQLite wrappers, files-as-database, or network storage without asking first.

## Concurrency Guidelines

- Prefer structured concurrency with `async`/`await`, task groups, and actor isolation.
- Avoid `Task.detached` unless there is a clear reason and actor/data boundaries are documented.
- Mark UI-facing view models or methods with `@MainActor` when they mutate UI-observed state.
- Keep non-Sendable SwiftData objects and model contexts inside their actor boundary.
- Cancel long-running tasks when views disappear or when new user input supersedes old work.

## UI And Design

- Follow Apple's Human Interface Guidelines and native iOS patterns.
- Prioritize clarity, accessibility, and fast repeated use over decorative UI.
- Support Dynamic Type, VoiceOver labels where needed, sensible empty states, and clear validation errors.
- Keep forms ergonomic: good keyboard types, default values, input validation, and predictable save/cancel behavior.
- Use SF Symbols for standard actions.

## Testing

- Use Swift Testing (`import Testing`, `@Test`, `#expect`) for unit tests.
- Add or update tests for view model logic, validation, sorting/filtering, persistence behavior, and bug fixes.
- Use in-memory SwiftData containers in tests so tests are isolated and repeatable.
- Keep UI tests for critical workflows only.
- Before finishing meaningful code changes, run the most relevant test target or explain why it could not be run.

## Code Quality

- Make focused changes that match the existing style.
- Do not add comments. Convey intent through precise, descriptive names and focused functions; a longer name or an extra helper is preferred over a comment when it makes the code easier to understand or removes ambiguity. Write a comment only when it records a critical, non-obvious detail the code cannot express on its own — a subtle invariant, a deliberate workaround, or a correctness-affecting gotcha — or when the user explicitly asks for one. Never add comments that restate the code, narrate steps, act as section banners, or repeat tutorial/boilerplate text.
- Avoid unrelated refactors, file moves, formatting churn, or generated project changes.
- Keep previews working when changing views.
- Do not leave placeholder code, dead code, or commented-out experiments.
- Ask before changing the app's architecture, persistence strategy, minimum OS target, package dependencies, or product scope.

## File Organization

Source lives under `HouseScore/`, grouped by responsibility:

- `App/`: App entry point (`HouseScoreApp.swift`) — wiring only, no business logic.
- `Models/`: SwiftData `@Model` types and lightweight domain types, one type per file (`HouseListing`, `ListingPhoto`, `PropertyType`).
- `ViewModels/`: `@Observable` MVVM types and presentation logic (`ListingsViewModel`, `ListingFormViewModel`; the `ListingFormType` mode enum lives with the form view model).
- `Views/`: SwiftUI screens, rows, and forms (`ListingsView`, `ListingDetailView`, `ListingRowView`, `ListingFormView`).
- `Persistence/`: The persistence seam — `ListingStore` protocol and `SwiftDataListingStore` implementation.
- `Services/`: Only for real cross-cutting behavior such as import/export, scoring rules, or integrations. None yet.
- Tests live in `HouseScoreTests/` (Swift Testing) and `HouseScoreUITests/`.

The Xcode project uses file-system synchronized groups, so adding, moving, or renaming a file under `HouseScore/<Folder>/` is included in the target automatically — do not hand-edit `HouseScore.xcodeproj/project.pbxproj` to register files. Keep types in the folder that matches their role; put a new type where its peers already live.
