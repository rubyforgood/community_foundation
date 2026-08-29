# Journey walkthrough video

Records the member happy path (sign up → confirm email → About You → Your legacy story →
build and share a scenario → public view) as a video using Playwright against the local
dev server. Same flow as `test/system/user_journey_test.rb`, slowed down for
viewing.

## One-time setup

```sh
cd script/demo
npm install
npm run setup   # downloads Chromium for Playwright
```

## Record

In one terminal, from the app root, start the dev server without letter_opener
popping browser tabs for each email:

```sh
LAUNCHY_DRY_RUN=true bin/dev
```

In another:

```sh
cd script/demo
npm run record
```

Output lands in `script/demo/output/`: `journey.mp4` (if `ffmpeg` is installed)
plus the raw `part-N.webm` clips.

Each run signs up a fresh `demo-<timestamp>@example.com` user in the dev
database; the confirmation link is read from `tmp/letter_opener/`.

Tunables: `DEMO_BASE_URL` (default `http://arlington.localhost:3000`),
`DEMO_PAUSE_MS` (default 1200), `DEMO_TYPE_DELAY_MS` (default 45).
