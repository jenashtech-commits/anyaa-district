# The COP AAAYM Camp App — Catalyst 2026

Live registration app for **The Catalyst Camp 2026**
The Church of Pentecost · Anyaa-Ablekuma Area Youth Ministry
Anagkazo Campus, Mampong · Wed 4 – Sat 8 August 2026

Members register from any device. The admin sees every registration live and
privately. Built with React + Vite, hosted free on GitHub + Vercel, with a
Supabase database doing the live sync and security.

---

## What you'll set up (about 20 minutes, all free)

1. A **Supabase** project — the live database (free tier).
2. A **GitHub** repo — holds the code.
3. A **Vercel** project — puts the app online at a public link.

You do not need to write any code. Just follow the steps.

---

## STEP 1 — Create the database (Supabase)

1. Go to https://supabase.com and sign up (free). Click **New project**.
2. Give it a name (e.g. `catalyst-camp`), set a database password, pick a region
   close to Ghana (e.g. EU West), and create it. Wait ~2 minutes.
3. In the left menu open **SQL Editor → New query**.
4. Open the file `supabase_setup.sql` from this project, copy everything,
   paste it into the editor, and click **Run**. You should see "Success".
   (If you ran an older version before, the top of that file has three short
   `alter table` lines to add the new Area and check-in columns — run those.)
5. Create the admin login: left menu **Authentication → Users → Add user**.
   - Email: `thecopaaaym@gmail.com`
   - Password: choose a strong password (this is your admin password — keep it safe)
   - Turn ON **Auto Confirm User** so it works immediately, then **Create user**.
6. Get your keys: left menu **Project Settings → API**. Copy these two:
   - **Project URL** (looks like `https://abcd1234.supabase.co`)
   - **anon public** key (a long string). The anon key is safe to share publicly —
     your data stays private because of the rules set in step 4.

> If you ever want a different admin email, change `thecopaaaym@gmail.com` in
> BOTH `supabase_setup.sql` (line in policy 4) and `src/App.jsx` (the
> `ADMIN_EMAIL` line), and create that user in step 5.

---

## STEP 2 — Put the code on GitHub

If you have Git installed, from inside this folder run:

```bash
git init
git add .
git commit -m "COP AAAYM Camp App"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/copaaaym-camp-app.git
git push -u origin main
```

(Create the empty repo first at https://github.com/new — do not add a README there.)

No Git? On github.com click **New repository**, then **uploading an existing file**,
and drag in everything from this folder EXCEPT the `node_modules` folder.

---

## STEP 3 — Deploy on Vercel

1. Go to https://vercel.com and sign up with your GitHub account.
2. **Add New → Project**, then **Import** your `copaaaym-camp-app` repo.
3. Vercel detects Vite automatically — leave the build settings as they are.
4. Open **Environment Variables** and add these two (from Step 1.6):
   - `VITE_SUPABASE_URL` = your Project URL
   - `VITE_SUPABASE_ANON_KEY` = your anon public key
5. Click **Deploy**. After a minute you get a public link like
   `https://copaaaym-camp-app.vercel.app`.

Share that link with members. They register; you watch it fill up live.

---

## Using the app

- **Members:** open the link → **Register** (one person) or
  **Bulk register a district** (a leader signs up many members at once).
  Each person captures Name, Age, Gender, Phone, Email, **Area**, District,
  Assembly, any allergy/medical note, and an emergency contact. After
  registering they get a **camp pass** (a QR name tag) they can screenshot.
- **Admin (you):** open the link → **Admin console →**, log in with
  `thecopaaaym@gmail.com` and your password. Three tabs:
  - **Overview** — live total, breakdown by district, the full searchable
    table, medical-note flags, and **CSV export**.
  - **Check-in** — at the gate, tap **Scan QR pass** to read a member's tag
    with the camera, or check people in manually. A scan shows only the
    member's **Name, Area, District and the camp theme**, then marks them in.
  - **Name tags** — generate printable name tags for everyone (or filter by
    district) and hit **Print tags**. Each tag shows only **Name, Area,
    District and the theme** ("The Catalyst Camp 2026"), plus the QR code.

The admin console refreshes the instant anyone registers.

> **Privacy of tags & scanner:** by design the printed tags and the scan result
> show only Name, Area, District and the theme — never phone, email or medical
> notes. Those stay inside the admin Overview table and CSV. (If you'd rather
> the gate scanner also flag allergies for safety, that's a one-line change —
> just ask.)

---

## Run it on your own computer first (optional)

```bash
npm install
cp .env.example .env      # then edit .env with your two Supabase keys
npm run dev               # opens http://localhost:5173
```

---

---

## Arrival-day tools (QR passes, name tags, check-in)

After registering, every member gets a **camp pass** with a QR code they can
screenshot or download. On arrival day, the admin console has two extra tabs:

- **Check-in** — tap **Scan QR pass** to scan a member's QR with the phone/laptop
  camera and check them in instantly, or search by name and check people in
  manually. The screen shows a live "X / Y checked in" count and pops a red
  **medical/allergy alert** the moment someone with a noted condition arrives.
- **Name tags** — print badges (with each person's QR) for the whole camp or one
  district at a time. Tap **Print tags** and your browser's print dialog opens,
  showing only the tags.

Notes:
- The camera scanner needs a secure (https) page and camera permission. Your
  Vercel link is https by default — just allow the camera when the browser asks.
  If a camera isn't available, use the manual search check-in instead.
- If you set up your database **before** this update, open Supabase -> SQL Editor
  and run `supabase_setup.sql` again. It is safe to re-run; it only adds the new
  check-in fields and leaves your existing registrations untouched.

---

## Privacy & security notes

- Personal details (name, phone, email, allergies) can be read **only** after
  logging in as `thecopaaaym@gmail.com`. This is enforced by the database, not
  just hidden on screen.
- The public homepage shows only the **count** of registrations, never names.
- Keep the admin password private and don't create extra users in Supabase Auth.
- The `anon public` key in your env vars is meant to be public — it grants no
  access to personal rows.

---

## Camp facts baked into the app

- Name: **The Catalyst Camp 2026**
- Venue: **Anagkazo Campus, Mampong**
- Dates: **Wednesday 4th – Saturday 8th August 2026**
- Colours & logo: Church of Pentecost Youth Ministry ("Arise & Shine")

To edit any wording or dates later, change `src/App.jsx` and push to GitHub —
Vercel redeploys automatically.
