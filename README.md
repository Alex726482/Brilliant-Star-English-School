# Brilliant Star English School website

A lightweight, mobile-first website for Brilliant Star English School in Punarbas, Kanchanpur. It uses plain HTML, CSS, and JavaScript, with Supabase for the admissions inbox, staff login, news, events, and gallery uploads. There is no local build step or package installation.

## What is included

- Home, About, Academics, Admissions, Facilities, Staff, Gallery, News & Events, and Contact pages.
- The supplied logo and 16 supplied school images, compressed as local JPEGs and sorted into gallery sections.
- Initial posts about Nepali New Year 2083, Holi, BLE 2081 recognition, and the 2082 BS annual exam schedule. Older notices are marked as archive material; the timetable is not presented as current.
- An admissions form that stores parent name, phone, class of interest, message, and submission time in Supabase. Only authorized school staff can read submissions.
- A private staff admin page (`#/admin`) to add, edit, publish, and delete news and events; upload and sort gallery photos; and mark admissions inquiries reviewed.
- A responsive navigation, keyboard skip link, labeled form fields, reduced-motion handling, page descriptions, and school location metadata for search engines.

## Run it on your computer

1. Open the `brilliant-star-english-school` folder.
2. Open `index.html` in a browser. Pages and the supplied photo gallery display without a database. The inquiry form and staff login show setup guidance until Supabase is connected.
3. For best local testing, use VS Code's Live Server extension or another static file server. No `npm install` is needed.

## Create the free Supabase database

1. Create a Supabase account and a new project. Choose a strong database password and save it somewhere safe.
2. In the Supabase project, open **SQL Editor** and run [`supabase/schema.sql`](supabase/schema.sql) once. This creates the tables, access policies, photo bucket, starter gallery, and starter news. It is safe to share this SQL file; it contains no secrets.
3. In **Authentication → Users**, create one staff user with an email and a strong password. Use **Add user** so you can set its password directly.
4. Copy the user's UUID from the Users list. In **SQL Editor**, add that account to the admin allow-list by running:

   ```sql
   insert into public.school_admins (user_id)
   values ('PASTE-THE-USER-UUID-HERE');
   ```

5. In **Authentication → Settings**, turn off public sign-ups. Only accounts explicitly added to `school_admins` can use admin actions, even if someone has a Supabase login.
6. Open **Project Settings → API** (or the project's Connect/API settings) and copy the project URL and the public `anon`/publishable key. In [`supabase-config.js`](supabase-config.js), paste them here:

   ```js
   window.SCHOOL_CONFIG = {
     supabaseUrl: "https://YOUR-PROJECT.supabase.co",
     supabaseAnonKey: "YOUR-PUBLIC-ANON-KEY"
   };
   ```

   The public key is meant to be visible in a website. **Never** paste the `service_role` key or database password into this file. Row-level security and the admin allow-list protect the data.

7. Refresh the site. Open `#/admin`, sign in with the staff account, and confirm the starter gallery and news are present. Submit a sample inquiry and check that it appears under **Admissions inquiries**.

## Deploy for free with Cloudflare Pages

Cloudflare Pages is the recommended free static host for this school site. Vercel's free Hobby plan is limited by its terms to personal, non-commercial use; a public school website may not fit that plan. Cloudflare Pages provides a free `*.pages.dev` address, which works like the Vercel subdomain you said is acceptable.

1. Put this project folder in a GitHub repository. If this `Apps` workspace already has a Git repository, commit the `brilliant-star-english-school` folder to it. Otherwise, create a repository and push this folder using GitHub Desktop or Git.
2. In Cloudflare, open **Workers & Pages → Create application → Pages → Connect to Git** and choose the repository.
3. Set the project root directory to `brilliant-star-english-school` if the repository contains other folders. Leave **Build command** blank. Set **Build output directory** to `.` (the project folder itself).
4. Click **Save and Deploy**. Cloudflare will publish the static website and give it an address such as `brilliant-star-school.pages.dev`.
5. Open the Pages address on a phone. Check the home, admissions, contact, and admin pages. The Supabase URL and public anon key are included in `supabase-config.js`; no private server key belongs in Cloudflare or the website.
6. Later updates are simple: edit the content or code, commit, and push. Cloudflare will redeploy it automatically. School staff can change news, events, and gallery photos from `your-site.pages.dev/#/admin` without editing code.

To use Vercel instead, the static files can be deployed with no build command and the website folder as the output directory. Review the current Vercel plan terms first; do not use Hobby for the school site if its personal/non-commercial restriction applies. Free hosting addresses are not custom domains. A custom `.com` or `.edu.np` address usually requires a paid registration.

## Free-tier limits and practical safeguards

Limits and plan rules change, so check each provider's dashboard before relying on a quota.

- **Supabase Free:** the current plan lists 500 MB database size, 1 GB file storage, 50,000 monthly active users, and 5 GB uncached plus 5 GB cached egress. Free projects can pause after a week of inactivity. This site keeps its own files on the static host; only images uploaded through the admin use Supabase storage. Keep admin uploads below 5 MB each, resize photos before uploading, and remove unused images. Visit the site or dashboard regularly, and expect the database to need waking if it has been idle. The free plan does not include automatic backups: periodically export the inquiries and keep copies of important photos elsewhere.
- **Cloudflare Pages Free:** the current static-site limits include 500 builds per month, 20,000 files per site, and a 25 MiB maximum for one asset. This project is small and has no build step. Very frequent code pushes or unusually large media could reach those limits; keep full-resolution originals outside the deployed site and publish compressed copies.
- **Vercel Hobby:** Vercel currently says Hobby is for personal, non-commercial use. Its terms may not suit a school website. Use Cloudflare Pages for the free deployment, or confirm an eligible Vercel plan before relying on a `vercel.app` address.
- **Inquiry spam and data retention:** the form has basic browser validation and a honeypot, but a public form can still receive junk submissions. Review the inbox, delete spam, and export useful inquiries regularly. Store only the information needed to respond.
- **Photo privacy:** the gallery storage bucket is public so school photos can load without a staff login. A hidden gallery item may still be reachable if someone has its direct image URL. Upload only photos approved for public viewing, especially images of students.
- **Email delivery:** inquiries are saved in Supabase for staff to review; this starter does not send email notifications. Add an email later if desired.

## Photo captions and Nepal context

Captions stick to details visible in the supplied photos. Holi is also called Fagu Purnima and is widely celebrated in Nepal, especially in the southern Terai. The New Year poster says 2083; Nepal's 2083 BS New Year fell on 14 April 2026. The BLE poster and 2082 exam timetable are preserved as school history, not upcoming notices. The cultural dress photo is described generally because no specific community or event name was provided.

References: [Nepal Tourism Board on Holi / Fagu Purnima](https://trade.ntb.gov.np/vol-xi-issue-iii/), [Embassy of Nepal: 2083 holiday calendar](https://eg.nepalembassy.gov.np/pages/holidays/), [Cloudflare Pages limits](https://developers.cloudflare.com/pages/platform/limits/), [Supabase pricing](https://supabase.com/pricing), [Vercel Hobby plan](https://vercel.com/docs/plans/hobby).

## Companion app later

The current site establishes a small set of school content (news, events, gallery) and an admissions inbox in Supabase. A future mobile app can reuse those tables and authentication model. Before planning the app, decide whether it should only show public updates or also handle parent accounts, student records, attendance, or fee data; those features change the security and privacy design substantially.
