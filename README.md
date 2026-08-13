# LifeTrack

A unified habit, journal, and budget tracker — with an AI coach that looks across all three at once.

Most tracking apps live in silos: one app for habits, another for mood, another for spending. LifeTrack keeps them together so patterns across domains are actually visible — like a skipped workout streak lining up with a rough week in the journal, or spending spikes on low-mood days.

**Live demo:** https://lifetrack.philmathieu.com

## How it works

The app is organized around four screens:

- **Today** — a daily dashboard: today's habit checklist, the day's journal entry, and a running budget summary, all in one glance.
- **Lifestyles** — log habits, journal entries, and transactions day-to-day.
- **All Data** — browse full history across habits, journal, and transactions.
- **Insights** — an AI coach (powered by Claude) that reads your recent habits, mood, and spending together and surfaces a weekly summary, cross-domain patterns, and a suggested focus area. You can also ask it free-form questions about your own data.

Data is stored locally on-device (via `shared_preferences`), so nothing is persisted server-side except the request made to generate an insight. The live demo seeds realistic sample data on first load so you can explore it immediately without creating anything yourself.

## Architecture

- **App** — Flutter, targeting web, iOS, and Android from a single codebase.
- **AI insights** — an AWS Lambda function calls the Claude API and returns a weekly summary or chat response; the app never talks to Claude directly.
- **Infrastructure** — API Gateway (HTTP API) in front of the Lambda, S3 + CloudFront serving the built Flutter web app, all provisioned with Terraform (`infra/`).
- **Deploy** — `deploy.sh` builds the Flutter web app with the current API Gateway URL baked in, syncs it to S3, and invalidates the CloudFront cache.

## Project structure

```
lib/
  models/       Habit, JournalEntry, Transaction data models
  providers/    App-wide state (LifeTrackProvider)
  screens/      Today, Lifestyles, All Data, Insights, and entry-add screens
  services/     Local storage, Claude API client, demo data seeding
lambda/         AI insights Lambda (Node.js, calls the Claude API)
infra/          Terraform-managed AWS infrastructure
```

## Running locally

```bash
flutter pub get
flutter run -d chrome   # or a connected device/simulator
```

The AI insights feature requires the Lambda backend; without `--dart-define=API_URL=...`, it falls back to the deployed demo endpoint.
