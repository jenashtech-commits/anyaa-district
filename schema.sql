-- =====================================================================
-- The Church of Pentecost, Anyaa District — Supabase database setup
-- Run this in the Supabase Dashboard -> SQL Editor -> New query -> Run.
-- =====================================================================

-- ---------- CONTENT (single editable row) ----------
create table if not exists public.site_content (
  id   int primary key default 1,
  data jsonb not null
);

insert into public.site_content (id, data)
values (1, $json${
  "hero": {
    "t1": "Worship. Fellowship.",
    "t2": "Win Souls.",
    "sub": "The Church of Pentecost — Anyaa District, in the Anyaa Ablekuma Area. A family of believers committed to spreading the Gospel and building disciples across our six local assemblies."
  },
  "whatsapp": "233000000000",
  "email": "copanyaadistrict@gmail.com",
  "stats": { "adults": 1854, "children": 823, "presbyters": 169, "assemblies": 6 },
  "about": [
    "The Church of Pentecost, Anyaa District began on 23rd October 1994 through house-to-house evangelism led by Eld. & Mrs. Yarquah, Eld. B. B. Akuamoah and the late Eld. Francis Owusu, which won thirteen souls.",
    "The young church first worshipped under a Nim tree, then in Mr. Okine's house, before Eld. Francis Owusu offered his land. A wooden structure was raised in January 1995, and in 1998 the Central Assembly building was begun.",
    "Anyaa became a District seat on 4th September 2004, carved out of Awoshie District by Aps. Alexander Nana Yaw Kumi-Larbi (then Pastor), with Ps. Paul K. Amoah as its first District Pastor. Today the district has about 1,854 adult and 823 children members with 169 presbyters."
  ],
  "pastors": [
    { "name": "Ps. Paul K. Amoah", "years": "2004 – 2010" },
    { "name": "Ps. Samuel K. Oteng", "years": "2010 – 2015" },
    { "name": "Ps. Seth Ohemeng Asiamah", "years": "2015 – 2021" },
    { "name": "Ps. Emmanuel Teye Sackitey", "years": "2021 – date" }
  ],
  "executives": [
    { "name": "Ps. Emmanuel Teye Sackitey", "role": "District Pastor", "img": "", "ic": "⛪" },
    { "name": "[Add name]", "role": "District Secretary", "img": "", "ic": "📖" },
    { "name": "[Add name]", "role": "District Finance Board Chairman", "img": "", "ic": "💼" },
    { "name": "[Add name]", "role": "Women's Ministry Leader", "img": "", "ic": "🤝" },
    { "name": "[Add name]", "role": "Youth Ministry Leader", "img": "", "ic": "🔥" },
    { "name": "[Add name]", "role": "Evangelism Coordinator", "img": "", "ic": "📣" }
  ],
  "assemblies": [
    { "name": "Central", "tag": "District Seat", "est": "28 Sept 1993", "status": "Permanent · Dedicated 2012", "pe": "Eld. Joseph K. Okyere", "adults": 434, "children": 136, "presbyters": 41, "hist": "Birthed from Odorkor District through the house-to-house evangelism that won 13 souls. Started under a Nim tree, then Mr. Okine's house, then Eld. Francis Owusu's land. The 1,000-seat building was dedicated on 30th December 2012. It is the District seat." },
    { "name": "Maranatha", "tag": "Assembly", "est": "30 Oct 2002", "status": "Permanent · In progress", "pe": "Eld. Gabriel Amoako", "adults": 327, "children": 194, "presbyters": 26, "hist": "Formerly 'Block Factory' Assembly, inaugurated 10th October 2002 with 7 members, first meeting at Eld. Boatey's residence. Land was purchased and a wooden structure built; the permanent building is under construction." },
    { "name": "NIC", "tag": "Assembly", "est": "14 Apr 2002", "status": "Permanent · In progress", "pe": "Eld. Godwin Awudu Tetteh", "adults": 323, "children": 109, "presbyters": 24, "hist": "Established 14th April 2002 with 27 members, first worshipping at Elder Yawson's house. The presbytery acquired land in 2006 and relocated the assembly; it now worships in an uncompleted permanent building." },
    { "name": "Nsumfa", "tag": "Assembly", "est": "31 Oct 2002", "status": "Permanent · 65% complete", "pe": "Eld. David Adjei", "adults": 209, "children": 140, "presbyters": 23, "hist": "Located in south-eastern Anyaa near Bethel. Established 31st October 2002 at Akuye Memorial School with Eld. Emmanuel Mensah as first presiding elder. The church building is in its finishing stage." },
    { "name": "Berea", "tag": "Assembly", "est": "08 Mar 2008", "status": "Permanent · In progress", "pe": "Eld. Benjamin Abradu", "adults": 271, "children": 119, "presbyters": 24, "hist": "Established March 2008 under Ps. Paul Amoah with about 21 members, first worshipping in a classroom at Christian Way International School. The presbytery has been acquiring and developing its permanent site." },
    { "name": "Bethel", "tag": "Assembly", "est": "2001", "status": "Permanent · In progress", "pe": "Eld. David Boakye Agyemang", "adults": 290, "children": 125, "presbyters": 22, "hist": "At Pallas Town. Grew out of a morning-devotion prayer group of 83 under Ps. D. D. Daye. Created around 2000 under Santa Maria District and joined Anyaa District in 2007. The permanent building is under construction." }
  ]
}$json$::jsonb)
on conflict (id) do nothing;

-- ---------- PROFILES (one per member) ----------
create table if not exists public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  name       text,
  email      text,
  phone      text,
  assembly   text,
  created_at timestamptz default now()
);

-- ---------- Admin check ----------
-- Anyone whose login email is listed here gets edit rights.
-- Add more admins by adding emails to the list (all lowercase).
create or replace function public.is_admin()
returns boolean
language sql stable security definer
set search_path = public
as $$
  select lower(coalesce(auth.jwt() ->> 'email','')) in (
    'copanyaadistrict@gmail.com'
  );
$$;

-- ---------- Create a profile automatically on sign up ----------
create or replace function public.handle_new_user()
returns trigger
language plpgsql security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, name, email, phone, assembly)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'name',''),
    new.email,
    coalesce(new.raw_user_meta_data ->> 'phone',''),
    coalesce(new.raw_user_meta_data ->> 'assembly','')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------- Row Level Security ----------
alter table public.site_content enable row level security;
alter table public.profiles     enable row level security;

-- content: everyone can read; only admins can update
drop policy if exists "content_read"   on public.site_content;
drop policy if exists "content_update" on public.site_content;
create policy "content_read"   on public.site_content for select using (true);
create policy "content_update" on public.site_content for update using (public.is_admin()) with check (public.is_admin());

-- profiles: a member sees/edits only their own row; admins can read all
drop policy if exists "profiles_read"   on public.profiles;
drop policy if exists "profiles_insert" on public.profiles;
drop policy if exists "profiles_update" on public.profiles;
create policy "profiles_read"   on public.profiles for select using (auth.uid() = id or public.is_admin());
create policy "profiles_insert" on public.profiles for insert with check (auth.uid() = id);
create policy "profiles_update" on public.profiles for update using (auth.uid() = id);

-- ---------- Privileges for the API roles ----------
grant usage on schema public to anon, authenticated;
grant select          on public.site_content to anon, authenticated;
grant update          on public.site_content to authenticated;
grant select, insert, update on public.profiles to authenticated;
grant execute on function public.is_admin() to anon, authenticated;

-- Done. Next: create your admin user (Authentication -> Users -> Add user,
-- email copanyaadistrict@gmail.com, tick "Auto Confirm User", set a password).
