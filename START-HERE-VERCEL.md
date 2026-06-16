# ⭐ START HERE — Go live with Supabase + Vercel (no command line)

Everything below is done by clicking in websites. Plan about 30–40 minutes.
You'll use: **Supabase** (the engine), **GitHub** (holds your files), and
**Vercel** (puts the site online with a free address).

Do the parts in order. ✅ each step as you finish.

---

## PART A — Supabase (members, content, AI assistant)

### A1. Create the project
1. **supabase.com** → Start your project → sign in.
2. **New project**. Name it (e.g. "Anyaa District"), set a database password
   (write it down), free plan, **Create**. Wait ~2 minutes.

### A2. Copy your two keys (paste somewhere temporary)
- **Project Settings (gear) → API**:
  - **Project URL** (e.g. `https://abcd1234.supabase.co`)
  - **anon public** key (a long string)

### A3. Build the database
1. **SQL Editor → New query**.
2. Open `supabase/schema.sql`, copy **all** of it, paste into the box, click
   **Run**. It should say "Success". ✅

### A4. Create your admin login
- **Authentication → Users → Add user → Create new user**:
  - Email `copanyaadistrict@gmail.com`, choose a password, tick
    **Auto Confirm User**, **Create**. ✅

### A5. Let members sign up instantly (recommended)
- **Authentication → Providers → Email** → turn **OFF** "Confirm email" → Save.

### A6. Turn on the AI assistant
1. **Edge Functions → Create a function**, name it exactly **chat**.
2. Open `supabase/functions/chat/index.ts`, copy all of it, paste into the code
   box, **Deploy**. ✅
3. Open the **chat** function → **Settings** → turn **Verify JWT** **OFF** → Save.
4. Add the secret: **Edge Functions → Secrets** (or **Project Settings → Edge
   Functions → Add secret**):
   - Name `ANTHROPIC_API_KEY`, value = your key from **console.anthropic.com**
     (starts with `sk-ant-`). Save. ✅

> No Anthropic key yet? Skip A6 for now — the site works; only the chat button
> stays quiet until you add it.

---

## PART B — Put your keys into the website
1. Open **`website/config.js`** in any text editor.
2. Replace the placeholders with your values from **A2**:
   ```js
   window.SUPABASE_URL = "https://abcd1234.supabase.co";
   window.SUPABASE_ANON_KEY = "your-anon-public-key";
   ```
3. **Save**. (The anon key is meant to be public; your data is protected by the
   rules from A3.) ✅

---

## PART C — GitHub (holds your files, in the browser)
1. Create a free account at **github.com**.
2. Top-right **+** → **New repository**. Name it `anyaa-district`, leave it
   Public or Private (both work), click **Create repository**.
3. On the new repo page click **uploading an existing file**.
4. Open your unzipped project folder, select the **`website`** folder and the
   **`supabase`** folder (and the .md files) and **drag them into the page**.
   Wait for them to finish uploading.
5. Click **Commit changes**. ✅
   (Your files now live in GitHub.)

---

## PART D — Vercel (go live, free address)
1. Go to **vercel.com** → **Sign Up** → **Continue with GitHub** (authorize it).
2. **Add New… → Project**. Find your `anyaa-district` repo → **Import**.
3. On the configure screen:
   - **Framework Preset:** choose **Other**.
   - **Root Directory:** click **Edit** → choose the **`website`** folder → Continue.
   - Leave Build Command and Output empty.
4. Click **Deploy**. After ~1 minute you get a live address like
   `https://anyaa-district.vercel.app`. ✅
5. (Optional) Project → **Settings → Domains** to rename it or add your own
   custom domain.

---

## PART E — One Supabase setting for production
- In Supabase: **Authentication → URL Configuration** → set **Site URL** to your
  Vercel address (e.g. `https://anyaa-district.vercel.app`) → Save.
  (Mainly matters if you kept email confirmation ON; harmless either way.)

---

## You're live — quick test
- Open the Vercel address on a phone; tap **Install App** (Android) or
  **Share → Add to Home Screen** (iPhone).
- **Sign In → Sign Up** to create a test member.
- Footer → **Admin Login** with `copanyaadistrict@gmail.com` + your password →
  turn on **Edit Mode** (gold ✎) and edit an assembly.
- Tap the gold robot button and ask the assistant something.

## Updating later
- **Wording/photos:** just log in as admin and edit inside the app (saves to
  Supabase instantly — no redeploy needed).
- **Website files (rare):** upload the changed file to GitHub again; Vercel
  **auto-redeploys** within a minute.

## If a step fails, tell me which one
Common fixes:
- Chat says "not configured" → check the secret name is exactly
  `ANTHROPIC_API_KEY` and the function is named exactly `chat` with Verify JWT OFF.
- Admin can't log in → the user's email in A4 must be `copanyaadistrict@gmail.com`.
- Edits don't save → re-run **all** of `schema.sql` (A3) and confirm "Success".
- Page loads but is blank/old → in the phone browser, fully close and reopen, or
  clear the site data (the app caches itself for offline use).
