// Records a slowed-down walkthrough of the member journey against a running
// dev server and writes output/journey.webm (plus journey.mp4 when ffmpeg is
// available). See README.md in this directory.

import { chromium } from "playwright";
import { execFileSync } from "node:child_process";
import { readdirSync, readFileSync, statSync, mkdirSync, renameSync, rmSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const appRoot = join(here, "..", "..");
const outDir = join(here, "output");

const BASE_URL = process.env.DEMO_BASE_URL ?? "http://arlington.localhost:3000";
const LETTER_OPENER_DIR = join(appRoot, "tmp", "letter_opener");
const PAUSE = Number(process.env.DEMO_PAUSE_MS ?? 1200);
const TYPE_DELAY = Number(process.env.DEMO_TYPE_DELAY_MS ?? 45);
const SIZE = { width: 1280, height: 800 };

const email = `demo-${Date.now()}@example.com`;
const password = "password123";

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const pause = (ms = PAUSE) => sleep(ms);

async function type(page, selector, text) {
  const field = page.locator(selector);
  await field.click();
  await field.pressSequentially(text, { delay: TYPE_DELAY });
  await pause(400);
}

function newestConfirmationPath() {
  const dirs = readdirSync(LETTER_OPENER_DIR)
    .map((name) => join(LETTER_OPENER_DIR, name))
    .filter((path) => statSync(path).isDirectory())
    .sort((a, b) => statSync(b).mtimeMs - statSync(a).mtimeMs);

  for (const dir of dirs) {
    const files = readdirSync(dir).filter((f) => f.endsWith(".html"));
    for (const file of files) {
      const html = readFileSync(join(dir, file), "utf8");
      const match = html.match(/\/email_confirmation\?token=[^"'\s<]+/);
      if (match) return match[0].replace(/&amp;/g, "&");
    }
  }
  throw new Error(`No confirmation email found under ${LETTER_OPENER_DIR}`);
}

async function run() {
  rmSync(outDir, { recursive: true, force: true });
  mkdirSync(outDir, { recursive: true });

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: SIZE,
    recordVideo: { dir: outDir, size: SIZE },
  });
  const page = await context.newPage();

  try {
    // Landing → sign up
    await page.goto(`${BASE_URL}/`);
    await pause(2000);
    await page.locator("nav").getByRole("link", { name: "Log in" }).click();
    await pause();
    await page.getByRole("link", { name: "Sign up" }).click();
    await pause();

    await type(page, "#user_name", "Journey Tester");
    await type(page, "#user_email_address", email);
    await type(page, "#user_password", password);
    await type(page, "#user_password_confirmation", password);
    await page.getByRole("button", { name: "Sign up" }).click();
    await page.getByText("Check your email to confirm your account").waitFor();
    await pause(2000);

    // Follow the confirmation link letter_opener wrote to disk
    await page.goto(`${BASE_URL}${newestConfirmationPath()}`);
    await page.getByRole("heading", { name: "Welcome to your workspace" }).waitFor();
    await pause(2000);

    // About You (autosaves as you type)
    await page.getByRole("link", { name: "About you" }).click();
    await page.getByRole("heading", { name: "About you" }).waitFor();
    await pause();
    await type(page, "#user_biography_birthplace", "Arlington, VA");
    await type(page, "#user_biography_background", "Grew up on a family farm just outside town.");
    await page.getByText("Saved.").first().waitFor();
    await pause(1500);
    await page.locator("#user_biography_hobbies").scrollIntoViewIfNeeded();
    await type(page, "#user_biography_hobbies", "Gardening, hiking, and mentoring students.");
    await page.getByText("Saved.").first().waitFor();
    await pause(1500);

    // Your legacy story (also autosaves)
    await page.getByRole("link", { name: "Dashboard" }).click();
    await pause();
    await page.getByRole("link", { name: "Your legacy story" }).click();
    await page.getByRole("heading", { name: "Your legacy" }).waitFor();
    await pause();
    await type(page, "#user_legacy_story_supported_organizations",
      "The local food bank and the county library, because no one should go hungry or without books.");
    await page.getByText("Saved.").first().waitFor();
    await pause(1500);
    await page.locator("#user_legacy_story_core_values").scrollIntoViewIfNeeded();
    await type(page, "#user_legacy_story_core_values", "Generosity, curiosity, and community.");
    await page.getByText("Saved.").first().waitFor();
    await pause(1500);

    // Build a scenario
    await page.getByRole("link", { name: "Dashboard" }).click();
    await pause();
    await page.getByRole("link", { name: "Explore options" }).click();
    await pause();
    await page.getByRole("link", { name: "Create scenario" }).click();
    await pause();
    await type(page, "#scenario_name", "Education focus");
    await page.getByRole("button", { name: "Create scenario" }).click();
    await page.getByRole("heading", { name: "Education focus" }).waitFor();
    await pause(1500);

    await page.getByRole("link", { name: "Add amount" }).click();
    await pause(600);
    await type(page, "#scenario_total_giving_amount", "100000");
    await page.getByRole("button", { name: "Save total giving amount" }).click();
    await page.getByText("$100,000").first().waitFor();
    await pause(1500);

    // Both allocation sections and the summary panel have a "... giving" heading;
    // only the allocation sections carry the dialog controller.
    const oneTime = page.locator("[data-controller='dialog']", { hasText: /one time giving/i }).first();
    const ongoing = page.locator("[data-controller='dialog']", { hasText: /ongoing giving/i }).first();
    await oneTime.getByRole("button", { name: "+ Add allocation" }).click();
    await pause();
    await oneTime.getByRole("button", { name: "Select a category" }).click();
    await pause();
    await oneTime.locator("button[data-name='Education']").click();
    await pause();
    await type(page, "dialog[open] #allocation_amount_one_time", "5000");
    await oneTime.getByRole("button", { name: "Create" }).click();
    await page.getByText("$5,000").first().waitFor();
    await pause(2000);

    // Ongoing allocation (percentage slider defaults to 20%)
    await ongoing.getByRole("button", { name: "+ Add allocation" }).click();
    await pause();
    await ongoing.getByRole("button", { name: "Select a category" }).click();
    await pause();
    await ongoing.locator("button[data-name='Education']").click();
    await pause(1500);
    await ongoing.getByRole("button", { name: "Create" }).click();
    await page.getByText("20% allocated across 2 causes").waitFor();
    await pause(2000);

    // Toggle the summary chart between bar and pie
    await page.getByRole("button", { name: "Pie" }).click();
    await pause(2500);
    await page.getByRole("button", { name: "Bar" }).click();
    await pause(1500);

    // Share → open the public link as an anonymous visitor
    await page.getByRole("button", { name: "Share" }).click();
    await pause();
    await page.getByRole("button", { name: "Create share link" }).click();
    const shareInput = page.locator("input[readonly][value*='/public/scenarios/']");
    await shareInput.waitFor();
    await pause(2000);
    const shareUrl = new URL(await shareInput.inputValue());
    await page.getByRole("button", { name: "Close" }).click();
    await pause();

    // Sign out, then open the public link as an anonymous visitor
    await page.locator("nav").getByRole("button", { name: "Journey Tester" }).click();
    await pause(600);
    await page.getByRole("button", { name: "Sign out" }).click();
    await page.getByRole("heading", { name: "Sign in" }).waitFor();
    await pause();
    await page.goto(`${BASE_URL}${shareUrl.pathname}`);
    await page.getByText("Read-only shared view").waitFor();
    await pause(3000);
  } finally {
    await context.close();
    await browser.close();
  }

  finalize();
}

// Playwright names the video by page id; rename it, then convert to mp4 when a
// working system ffmpeg is available (Playwright's bundled ffmpeg can't write mp4).
function finalize() {
  const [video] = readdirSync(outDir).filter((f) => f.endsWith(".webm"));
  if (!video) throw new Error(`No video written to ${outDir}`);

  const webm = join(outDir, "journey.webm");
  renameSync(join(outDir, video), webm);
  console.log(`Wrote ${webm}`);

  try {
    execFileSync("ffmpeg", ["-version"], { stdio: "ignore" });
  } catch {
    console.log("No working ffmpeg on PATH; skipping mp4 conversion.");
    return;
  }

  const mp4 = join(outDir, "journey.mp4");
  execFileSync("ffmpeg", [
    "-y", "-loglevel", "error", "-i", webm,
    "-c:v", "libx264", "-pix_fmt", "yuv420p", "-movflags", "+faststart",
    mp4,
  ]);
  console.log(`Wrote ${mp4}`);
}

run().catch((error) => {
  console.error(error);
  process.exit(1);
});
