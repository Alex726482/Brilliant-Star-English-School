-- Brilliant Star English School: database, public content, and access rules.
-- Run the whole file once in Supabase Dashboard > SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.school_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create or replace function public.is_school_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.school_admins where user_id = (select auth.uid())
  );
$$;
revoke all on function public.is_school_admin() from public, anon;
grant execute on function public.is_school_admin() to authenticated;

create table if not exists public.news (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 1 and 160),
  summary text not null default '',
  image_url text,
  published boolean not null default false,
  display_order integer not null default 100,
  published_at date,
  created_at timestamptz not null default now()
);

create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 1 and 160),
  summary text not null default '',
  event_date date not null,
  location text,
  published boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.gallery (
  id uuid primary key default gen_random_uuid(),
  caption text not null default '',
  image_url text not null,
  storage_path text,
  category text not null default 'School life',
  display_order integer not null default 100,
  published boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.inquiries (
  id uuid primary key default gen_random_uuid(),
  parent_name text not null check (char_length(parent_name) between 1 and 100),
  phone text not null check (char_length(phone) between 5 and 30),
  parent_email text check (parent_email is null or char_length(parent_email) <= 160),
  student_class text not null check (char_length(student_class) between 1 and 40),
  message text not null default '' check (char_length(message) <= 1500),
  status text not null default 'New' check (status in ('New','Reviewed')),
  created_at timestamptz not null default now()
);

-- Safe to rerun when upgrading a project that already has the inquiry table.
alter table public.inquiries
  add column if not exists parent_email text check (parent_email is null or char_length(parent_email) <= 160);

create index if not exists news_public_order on public.news (published, display_order asc, published_at desc, created_at desc);
create index if not exists events_public_order on public.events (published, event_date asc);
create index if not exists gallery_public_order on public.gallery (published, display_order asc, created_at desc);
create index if not exists inquiries_created_order on public.inquiries (created_at desc);

alter table public.school_admins enable row level security;
alter table public.news enable row level security;
alter table public.events enable row level security;
alter table public.gallery enable row level security;
alter table public.inquiries enable row level security;

drop policy if exists "admins can read their own admin record" on public.school_admins;
create policy "admins can read their own admin record" on public.school_admins
  for select to authenticated using (user_id = (select auth.uid()));

drop policy if exists "published news is public" on public.news;
create policy "published news is public" on public.news
  for select to anon, authenticated using (published);
drop policy if exists "admins manage news" on public.news;
create policy "admins manage news" on public.news
  for all to authenticated using ((select public.is_school_admin())) with check ((select public.is_school_admin()));

drop policy if exists "published events are public" on public.events;
create policy "published events are public" on public.events
  for select to anon, authenticated using (published);
drop policy if exists "admins manage events" on public.events;
create policy "admins manage events" on public.events
  for all to authenticated using ((select public.is_school_admin())) with check ((select public.is_school_admin()));

drop policy if exists "published gallery is public" on public.gallery;
create policy "published gallery is public" on public.gallery
  for select to anon, authenticated using (published);
drop policy if exists "admins manage gallery" on public.gallery;
create policy "admins manage gallery" on public.gallery
  for all to authenticated using ((select public.is_school_admin())) with check ((select public.is_school_admin()));

drop policy if exists "public can submit inquiries" on public.inquiries;
create policy "public can submit inquiries" on public.inquiries
  for insert to anon, authenticated with check (true);
drop policy if exists "admins can read inquiries" on public.inquiries;
create policy "admins can read inquiries" on public.inquiries
  for select to authenticated using ((select public.is_school_admin()));
drop policy if exists "admins can update inquiry status" on public.inquiries;
create policy "admins can update inquiry status" on public.inquiries
  for update to authenticated using ((select public.is_school_admin())) with check ((select public.is_school_admin()));

grant select on public.news, public.events, public.gallery to anon, authenticated;
grant insert, update, delete on public.news, public.events, public.gallery to authenticated;
grant insert on public.inquiries to anon, authenticated;
grant select, update on public.inquiries to authenticated;
grant select on public.school_admins to authenticated;

-- The bucket is public so the website can show photo URLs. Any uploaded object
-- is reachable if its URL is known, including items not currently listed in
-- the gallery. Upload and delete access is restricted to school admins.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('school-gallery', 'school-gallery', true, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "school gallery images are public" on storage.objects;
create policy "school gallery images are public" on storage.objects
  for select to anon, authenticated using (bucket_id = 'school-gallery');
drop policy if exists "admins upload school gallery images" on storage.objects;
create policy "admins upload school gallery images" on storage.objects
  for insert to authenticated with check (bucket_id = 'school-gallery' and (select public.is_school_admin()));
drop policy if exists "admins update school gallery images" on storage.objects;
create policy "admins update school gallery images" on storage.objects
  for update to authenticated using (bucket_id = 'school-gallery' and (select public.is_school_admin()))
  with check (bucket_id = 'school-gallery' and (select public.is_school_admin()));
drop policy if exists "admins delete school gallery images" on storage.objects;
create policy "admins delete school gallery images" on storage.objects
  for delete to authenticated using (bucket_id = 'school-gallery' and (select public.is_school_admin()));

-- First gallery items. Images are compressed local assets in /assets/gallery.
insert into public.gallery (caption, image_url, category, display_order, published) values
  ('School building during assembly', '/assets/gallery/01-school-assembly.jpg', 'School day', 10, true),
  ('Students taking part in an outdoor group activity', '/assets/gallery/04-outdoor-student-activity.jpg', 'School day', 20, true),
  ('School exercise gathering', '/assets/gallery/08-outdoor-exercise.jpg', 'School day', 30, true),
  ('Students sitting for an examination', '/assets/gallery/14-examinations.jpg', 'School day', 40, true),
  ('Principal Prem Bahadur B.K.', '/assets/gallery/10-principal-prem-bahadur-bk.jpg', 'School leaders', 10, true),
  ('Students and staff at a school gathering', '/assets/gallery/15-school-gathering.jpg', 'School leaders', 20, true),
  ('Student recognized at a school ceremony', '/assets/gallery/05-student-recognition.jpg', 'Achievements', 10, true),
  ('Students at a recognition gathering', '/assets/gallery/06-student-recognition-group.jpg', 'Achievements', 20, true),
  ('School felicitation following the BLE 2081 results', '/assets/gallery/12-ble-2081-recognition.jpg', 'Achievements', 30, true),
  ('Annual examination timetable for 2082 BS (archive)', '/assets/gallery/07-annual-exam-timetable-2082.jpg', 'School notices', 10, true),
  ('Admissions information poster shared by the school', '/assets/gallery/11-admissions-poster.jpg', 'School notices', 20, true),
  ('A festive moment at school', '/assets/gallery/02-school-celebration.jpg', 'Culture & celebrations', 10, true),
  ('Nepali New Year 2083 greeting', '/assets/gallery/03-nepali-new-year-2083.jpg', 'Culture & celebrations', 20, true),
  ('Students celebrating Holi with colours', '/assets/gallery/13-holi-celebration.jpg', 'Culture & celebrations', 30, true),
  ('Birthday celebration with classmates', '/assets/gallery/09-student-birthday.jpg', 'Culture & celebrations', 40, true),
  ('Students in traditional dress at a cultural gathering', '/assets/gallery/16-cultural-dress.jpg', 'Culture & celebrations', 50, true)
on conflict do nothing;

-- School news based on the provided photos/posters. No unknown event dates are
-- invented; dated school updates can be added in the admin area.
insert into public.news (title, summary, image_url, published, display_order, published_at) values
  ('Welcome, Nepali New Year 2083', 'The school’s greeting sends warm wishes for health, learning, and success to students, guardians, and future families. In Nepal, the Bikram Sambat calendar marks the New Year at the start of Baishakh.', '/assets/gallery/03-nepali-new-year-2083.jpg', true, 10, '2026-04-14'),
  ('Holi celebration at school', 'Students celebrated Holi with colours and a school gathering. Also known as Fagu Purnima, Holi is a spring festival celebrated across Nepal, with especially lively celebrations in the southern Terai.', '/assets/gallery/13-holi-celebration.jpg', true, 20, null),
  ('Recognizing student achievement: BLE 2081', 'The school shared a felicitation for students’ performance in the Basic Level Examination (BLE) 2081. The photo and poster record a school recognition ceremony; the date was not included in the material provided.', '/assets/gallery/12-ble-2081-recognition.jpg', true, 30, null),
  ('Annual examination schedule: 2082 BS (archive)', 'The supplied timetable lists annual examination subjects for several class groups in 2082 BS. It is kept here as an archive reference and is not a current exam schedule.', '/assets/gallery/07-annual-exam-timetable-2082.jpg', true, 40, null)
on conflict do nothing;
