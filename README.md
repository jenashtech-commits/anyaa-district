# The Church of Pentecost — Anyaa District
## Supabase + free static hosting

This version uses **Supabase** (free) for the database, member accounts, and the
AI assistant, and a **free static host** (Netlify / Vercel / Cloudflare / GitHub
Pages) for the website — which also gives you a free web address. No server to
run or maintain.

```
website/                 the website you upload to the static host
  index.html            the app
  config.js             <- paste your Supabase URL + anon key here
  logo.png, icons, manifest.webmanifest, sw.js
supabase/
  schema.sql            run this once in Supabase to create the database
  functions/chat/       the AI assistant function (keeps your API key secret)
```

If `config.js` is left with the placeholders, the site still runs in a local
demo mode, so it never looks broken.

---

## Step 1 — Create the Supabase project (free)
1. Go to https://supabase.com → sign up → **New project**.
2. Pick a name and a strong database password; choose the free plan.
3. When it's ready, open **Project Settings → API** and copy:
   - **Project URL**
   - **anon public** key

## Step 2 — Create the database
1. In Supabase, open **SQL Editor → New query**.
2. Paste the entire contents of `supabase/schema.sql` and click **Run**.
   This creates the tables, security rules, and loads your district content.

## Step 3 — Create your admin login
1. **Authentication → Users → Add user**.
2. Email: `copanyaadistrict@gmail.com`, set a password, and tick
   **Auto Confirm User**. Click create.
   (This email is the admin — it's set in `schema.sql` in the `is_admin`
   function; add more admin emails there if needed.)

## Step 4 — (Optional but recommended) make member sign-up instant
By default Supabase emails a confirmation link on sign-up.
To let members use the site immediately:
- **Authentication → Providers → Email** → turn **off** "Confirm email".
(If you leave it on, new members get a "check your email" message and sign in
after confirming — that also works.)

## Step 5 — Deploy the AI assistant function
You need the Supabase CLI (https://supabase.com/docs/guides/cli). Then, in this
folder:
```
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase secrets set ANTHROPIC_API_KEY=sk-ant-your-key
supabase functions deploy chat --no-verify-jwt
```
- Get your Anthropic key at https://console.anthropic.com.
- `YOUR_PROJECT_REF` is the part of your Project URL before `.supabase.co`.
- `--no-verify-jwt` lets visitors who aren't signed in use the chat bot.

## Step 6 — Add your keys to the website
Open `website/config.js` and replace the placeholders with the values from
Step 1:
```js
window.SUPABASE_URL = "https://YOUR-PROJECT.supabase.co";
window.SUPABASE_ANON_KEY = "the-anon-public-key";
```
(The anon key is safe in the browser — security is enforced by the database
rules from Step 2.)

## Step 7 — Put the website online (free address)
Upload the **`website`** folder to any one of these:
- **Netlify** — easiest: https://app.netlify.com/drop → drag the `public` folder
  in → you get `https://your-name.netlify.app`.
- **Vercel**, **Cloudflare Pages**, or **GitHub Pages** also work and give a free
  address. (You can attach your own custom domain later for free in all of them.)

Open the address on a phone → use **Install App** (Android) or Share →
**Add to Home Screen** (iPhone) to install it like a native app.

---

## Using it
- **Members**: tap **Sign In** → **Sign Up** (name, email, phone, assembly, password).
- **Admin**: footer → **Admin Login** with `copanyaadistrict@gmail.com` + your
  password. Then turn on **Edit Mode** (gold ✎ buttons) to edit the About section
  and assemblies, manage **District Executives**, change **Settings**, view
  **members**, and change your admin **password**.
- The data (content, members) is shared for everyone, stored safely in Supabase.

## How it stays secure
- The **anon key** in the browser can only do what the database rules allow:
  read content, sign up/in, and read/write a member's own profile.
- Only the **admin email** can edit the site content (enforced by Postgres Row
  Level Security, not by the browser).
- The **Anthropic API key** lives only in the Supabase function's secrets, never
  in the website.

## Free-tier notes
Supabase free tier pauses a project after long inactivity — opening the site
wakes it. For a busy public site you can upgrade later. Everything here fits the
free plans of Supabase and the static hosts above.
