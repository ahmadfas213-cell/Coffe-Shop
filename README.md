# BREWLY

BREWLY is a coffee shop management app with a dashboard for menus, orders, stock, and sales. It also has Google sign-in, dark and light themes, and a layout that works on desktop and mobile.

Live site: https://ahmadfas213-cell.github.io/Coffe-Shop/

## Built with

- HTML, CSS, and JavaScript
- Supabase Auth for Google sign-in
- Supabase Postgres for products, orders, order items, profiles, and stock
- GitHub Pages for the frontend

## Features

- Dashboard for sales and order summaries
- Menu catalog and quick orders
- Order and transaction records
- Inventory and sales reports
- Google sign-in through Supabase
- Dark and light themes
- Responsive layout
- Browser-based demo mode using localStorage when Supabase is not configured
- PWA installation support

## Set up Supabase

1. Create a project in the [Supabase dashboard](https://supabase.com/dashboard).
2. Open SQL Editor.
3. Run the full contents of `supabase/schema.sql`.
4. Open Project Settings → API.
5. Copy the Project URL and publishable key (or the legacy anon key).
6. In `index.html`, replace:
   - `YOUR_SUPABASE_PROJECT_URL` with the project URL.
   - `YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY` with the publishable or anon key.
7. Commit and push the changes to `main`.

The publishable/anon key can be used in a frontend when Row Level Security and database policies are configured correctly. Do not put the `service_role` key in frontend code or a public repository.

## Set up Google sign-in

1. In Supabase, open Authentication → Sign In / Providers → Google.
2. Enable Google and copy the callback URL shown by Supabase. It looks like `https://<project-ref>.supabase.co/auth/v1/callback`.
3. Open [Google Cloud Console](https://console.cloud.google.com/) and select or create a project.
4. Create an OAuth Client ID with the **Web application** type.
5. Add these JavaScript origins:
   - `https://ahmadfas213-cell.github.io`
   - `http://localhost:5500` for local testing
6. Add the Supabase callback URL to Authorized redirect URIs.
7. Copy the Google Client ID and Client Secret into the Google provider settings in Supabase.
8. In Supabase, open Authentication → URL Configuration.
9. Set the Site URL to `https://ahmadfas213-cell.github.io/Coffe-Shop/` and add it to Redirect URLs.
10. For local testing, add `http://localhost:5500/**`.

Keep the Google Client Secret in Supabase. Do not commit it to GitHub.

## Run locally

From the project directory, start a local server:

```bash
python -m http.server 5500
```

Then open:

```text
http://localhost:5500
```

## Deploy to GitHub Pages

The workflow in `.github/workflows/deploy.yml` runs on pushes to `main`.

In the repository settings, open Pages → Build and deployment and select **GitHub Actions** as the source.

## Extra modules

BREWLY also includes these operational modules:

1. POS / cashier
2. Customer CRM
3. Loyalty points
4. Promotions
5. Expense tracker
6. Supplier directory
7. Purchase orders
8. Recipe book
9. Menu costing
10. Staff directory
11. Shift planner
12. Attendance
13. Table management
14. Reservations
15. Kitchen display
16. Delivery tracker
17. Refund requests
18. Cash flow
19. Cash closing
20. Task checklist

### Save extra module data across devices

After running `supabase/schema.sql`, run the full contents of `supabase/brewly_v2_addons.sql` in Supabase SQL Editor.

This migration adds the `workspace_records` table and its RLS policy. Without it, the extra modules can still be tested in demo mode, but their data stays in the browser's localStorage.

## Current integration status

The app is prepared to read and write products, orders, order items, and stock through Supabase. Google sign-in still needs OAuth credentials from Google Cloud and Supabase. Run the SQL schema before adding the credentials.

The Install button is available on the login page and dashboard. Use a browser that supports PWA installation to add BREWLY to your device.
