# Brilliant Star English School website

A lightweight, mobile-first website for Brilliant Star English School in Punarbas, Kanchanpur. It uses plain HTML, CSS, and JavaScript, with Supabase for the admissions inbox, staff login, news, events, and gallery uploads. There is no local build step or package installation.

## What is included

- Home, About, Academics, Admissions, Facilities, Staff, Gallery, News & Events, and Contact pages.
- The supplied logo and 16 supplied school images, compressed as local JPEGs and sorted into gallery sections.
- Two clearly labeled AI-made school illustrations for the home and academics pages, with compressed JPEG assets for faster loading.
- Gallery photos shown without card frames and open as full-screen originals when tapped.
- Initial posts about Nepali New Year 2083, Holi, BLE 2081 recognition, and the 2082 BS annual exam schedule. Older notices are marked as archive material; the timetable is not presented as current.
- An admissions form that stores parent name, phone, class of interest, message, and submission time in Supabase. Only authorized school staff can read submissions.
- A private staff admin page (`#/admin`) to add, edit, publish, and delete news and events; upload and sort gallery photos; and mark admissions inquiries reviewed.
- A floating school chatbot powered by Google Gemini 3.1 Flash-Lite through Netlify AI Gateway. Its server-side function uses a fixed school fact sheet and does not read the admissions database.
- A responsive navigation, keyboard skip link, labeled form fields, reduced-motion handling, page descriptions, and school location metadata for search engines.

## Run it on your computer

1. Open the `brilliant-star-english-school` folder.
2. Open `index.html` in a browser. Pages and the supplied photo gallery display without a database. The inquiry form and staff login show setup guidance until Supabase is connected. Live chatbot replies require deployment to Netlify with AI Gateway enabled.
3. For best local testing, use VS Code's Live Server extension or another static file server. No `npm install` is needed.

## Create the free Supabase database

1. Create a Supabase account and a new project. Choose a strong database password and save it somewhere safe.
2. In the Supabase project, open **SQL Editor** and run [`supabase/schema.sql`](supabase/schema.sql) once when creating the database. If you already ran the schema, run only [`supabase/migrations/add-parent-email.sql`](supabase/migrations/add-parent-email.sql) to add the optional parent email field without re-adding starter content. These SQL files contain no secrets.
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

## Deploy with Netlify

The project includes [`netlify.toml`](netlify.toml), which tells Netlify to publish this static folder and deploy the chatbot as a Netlify Function. The same setup supports Netlify's free `*.netlify.app` address.

1. Put this project folder in a GitHub repository. If the repository contains other folders, the Netlify **Base directory** should be `brilliant-star-english-school`. If the repository contains this project's files at its top level, leave **Base directory** blank.
2. In Netlify, choose **Add new project → Import an existing project**, connect GitHub, and select the repository. Netlify will read `netlify.toml`; the publish folder is `.` and the functions folder is `netlify/functions`. Leave the build command empty.
3. Deploy the site. If your current Netlify site was created by manually uploading static files, connect it to this Git repository or deploy with the Netlify CLI; a manual static upload by itself does not publish the chatbot function.
4. In Netlify's team settings, make sure **AI Features / AI Gateway** is enabled. Netlify injects the Gemini key and gateway URL into the server function automatically; do not add either key to `app.js`, `supabase-config.js`, or the repository.
5. Set up admission email notifications: in the Netlify site dashboard, open **Forms → Submission notifications → Add notification → Email notification**. Choose the `admission-inquiry` form and enter `rpsarki464@gmail.com`. Netlify's current rules require the notification recipient to be an active member of the Netlify team, so invite the founder's email to the team first if it is not already a member. Replies can go to a guardian's optional email address from the form.
6. After the first production deploy, open the live `*.netlify.app` site and send a sample question in the chatbot. AI Gateway activates after a production deploy. Also check that the Admissions form saves a sample inquiry in Supabase and appears in Netlify Forms, and that staff can sign in at `/#/admin`.
7. For updates, edit the files and push the changes to GitHub. Netlify redeploys the site and function automatically. Staff can manage news, events, gallery photos, and inquiries at `your-site.netlify.app/#/admin`.

The chatbot endpoint is [`netlify/functions/chat.mjs`](netlify/functions/chat.mjs), routed to `/api/chat`. Gemini credentials remain server-side. The Supabase URL and public anon key in `supabase-config.js` are designed to be public; never put the Supabase `service_role` key or database password in the website. A free hosting address is not a custom domain; registering a `.com` or `.edu.np` domain usually costs money.

## Free-tier limits and practical safeguards

Limits and plan rules change, so check each provider's dashboard before relying on a quota.

- **Supabase Free:** the current plan lists 500 MB database size, 1 GB file storage, 50,000 monthly active users, and 5 GB uncached plus 5 GB cached egress. Free projects can pause after a week of inactivity. This site keeps its own files on the static host; only images uploaded through the admin use Supabase storage. Keep admin uploads below 5 MB each, resize photos before uploading, and remove unused images. Visit the site or dashboard regularly, and expect the database to need waking if it has been idle. The free plan does not include automatic backups: periodically export the inquiries and keep copies of important photos elsewhere.
- **Netlify Free:** Netlify's current credit-based Free plan includes 300 credits per month with a hard limit and no automatic recharge. Bandwidth, function requests, builds, and AI usage may draw from the same monthly balance. When credits run out, deployments or dynamic features such as the chatbot can stop until the next cycle. Check **Usage & billing** in your Netlify team because older accounts may have different legacy plan terms.
- **Chatbot inference:** Netlify AI Gateway charges token usage against your Netlify credits. Gemini 3.1 Flash-Lite is a relatively lightweight model, but free use is not unlimited and costs can change. Keep the current limits of 500 characters per message, 8 recent chat messages, and a short reply; monitor AI Gateway usage in Netlify. The gateway does not store prompts or model outputs, but visitors should still avoid entering private student information. The chatbot does not save messages in Supabase.
- **Netlify Functions and Forms:** the chatbot needs Netlify to build and publish its function. A drag-and-drop upload containing only static files will not provide `/api/chat`; use Git-connected deployment or Netlify CLI. Admission inquiries are stored in Supabase and also submitted to Netlify Forms to trigger email alerts, so they are kept in both services. Check each service's usage and retention settings; form notification email requires an active Netlify team member as the recipient.
- **Inquiry spam and data retention:** the form has basic browser validation and a honeypot, but a public form can still receive junk submissions. Review the inbox, delete spam, and export useful inquiries regularly. Store only the information needed to respond.
- **Photo privacy:** the gallery storage bucket is public so school photos can load without a staff login. A hidden gallery item may still be reachable if someone has its direct image URL. Upload only photos approved for public viewing, especially images of students.
- **Email delivery:** Netlify Forms sends the inquiry notification after you add the founder's email under **Forms → Submission notifications**. Netlify currently requires that email address to belong to an active team member.

## Photo captions and Nepal context

Captions stick to details visible in the supplied photos. Holi is also called Fagu Purnima and is widely celebrated in Nepal, especially in the southern Terai. The New Year poster says 2083; Nepal's 2083 BS New Year fell on 14 April 2026. The BLE poster and 2082 exam timetable are preserved as school history, not upcoming notices. The cultural dress photo is described generally because no specific community or event name was provided.

References: [Nepal Tourism Board on Holi / Fagu Purnima](https://trade.ntb.gov.np/vol-xi-issue-iii/), [Embassy of Nepal: 2083 holiday calendar](https://eg.nepalembassy.gov.np/pages/holidays/), [Netlify AI Gateway](https://docs.netlify.com/build/ai-gateway/overview/), [Netlify Functions](https://docs.netlify.com/build/functions/overview/), [Netlify Forms setup](https://docs.netlify.com/manage/forms/setup/), [Netlify form notifications](https://docs.netlify.com/manage/forms/notifications/), [Netlify credit-based plan limits](https://docs.netlify.com/manage/accounts-and-billing/billing/billing-for-credit-based-plans/credit-based-pricing-plans/), [Netlify AI privacy](https://docs.netlify.com/build/build-with-ai/security-and-privacy-for-ai-features/), [Supabase pricing](https://supabase.com/pricing).

## Companion app later

The current site establishes a small set of school content (news, events, gallery) and an admissions inbox in Supabase. A future mobile app can reuse those tables and authentication model. Before planning the app, decide whether it should only show public updates or also handle parent accounts, student records, attendance, or fee data; those features change the security and privacy design substantially.
