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
- Use dependency injection for `ModelContext`, `ModelContainer`, clocks/dates, and other collaborators so code remains testable.
- Keep SwiftData model types small and explicit. Add migrations deliberately when persisted schema changes.
- Prefer simple architecture until complexity proves it needs another layer. Add repositories/services only when they reduce duplication or isolate real complexity.
- Avoid putting business logic in previews, views, or app entry points.

## SwiftData Guidelines

- Use SwiftData as the source of truth for persisted app data.
- Use in-memory `ModelContainer` configurations for previews and tests.
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
- Prefer clear names over comments. Add comments only when they explain non-obvious decisions.
- Avoid unrelated refactors, file moves, formatting churn, or generated project changes.
- Keep previews working when changing views.
- Do not leave placeholder code, dead code, or commented-out experiments.
- Ask before changing the app's architecture, persistence strategy, minimum OS target, package dependencies, or product scope.

## Suggested File Organization

- `Models/`: SwiftData `@Model` types and lightweight domain types.
- `ViewModels/`: `@Observable` MVVM types and presentation logic.
- `Views/`: SwiftUI screens, rows, forms, and reusable view components.
- `Services/`: Only for real cross-cutting behavior such as import/export, scoring rules, or integrations.
- `Tests/`: Swift Testing unit tests grouped by feature or type.

The current project is small, so do not reorganize files just to match this structure. Move files only when it makes the code easier to navigate.
