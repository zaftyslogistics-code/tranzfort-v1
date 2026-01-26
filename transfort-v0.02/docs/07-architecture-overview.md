# Architecture Overview (v0.02)

## Architecture Goals
- Clear boundaries (UI / state / domain / data).
- Minimal global singletons.
- Easy to test and refactor.

## Proposed Layers
- Presentation: Flutter UI, routing, view models/notifiers.
- Domain: entities + use-cases.
- Data: repositories + datasources (Supabase, local cache).
- Core: logging, analytics, config, error types.

## Navigation
- Single routing system.
- Strict route ownership: user routes vs admin routes must be separated.

## Diagrams
- Context: `diagrams/architecture-context.mmd`
- Containers: `diagrams/architecture-container.mmd`
