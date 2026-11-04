-- Run once if the Supabase project was created before the parent-email field was added.
alter table public.inquiries
  add column if not exists parent_email text check (parent_email is null or char_length(parent_email) <= 160);
