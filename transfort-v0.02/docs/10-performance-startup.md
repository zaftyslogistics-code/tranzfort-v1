# Performance & Startup Plan (v0.02)

## Objective
Fast startup and responsive UI. No “stuck” splash/loading states.

## Targets (Acceptance)
- Cold start (P95): <= 2.0s on mid-range Android.
- Time-to-first-frame: <= 800ms.
- Any loading screen must time out with retry within 10s.

## Startup Rules
- Do not block `runApp()` on:
  - SharedPreferences reads
  - network calls
  - heavy dependency initialization
- Initialize heavy services after first frame.

## Theme System (Current Pain Point)
- Theme preference should be loaded asynchronously.
- App should render immediately with a default theme, then apply stored theme without blocking splash.

## Technical Strategy
- Lazy initialization for analytics/cache/background services.
- Avoid large synchronous work during app bootstrap.
- Use isolated rebuild scopes for theme changes.

## Diagram
- Startup sequence: `diagrams/startup-sequence.mmd`
