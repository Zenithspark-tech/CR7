# ZenithMax V31.2 — Railway deployment guide

This package uses the real V31 app entry point. The root `package.json` runs
`node server/server.js`; the root `Dockerfile` also runs `npm start` from `/app`.

## Deploy a staging copy first

1. Extract this ZIP on your computer.
2. Create a new GitHub repository for staging. Upload the **contents** of this
   extracted folder so that `package.json`, `Dockerfile`, `server/`, `client/`,
   and `scripts/` sit directly at the repository root. Do not upload only the ZIP
   and do not put all the files inside an extra nested folder.
3. In Railway, choose **New Project → Deploy from GitHub Repo** and select the
   new staging repository.
4. Use the project root as the service root (leave Root Directory blank). The
   Dockerfile should be detected at the repository root. Keep the start command
   as `npm start` (or let the Dockerfile's CMD run it).
5. Add a PostgreSQL service to the same Railway project for the staging test.
   Set the app service's `DATABASE_URL` to the Railway Postgres service's
   `DATABASE_URL` reference, following Railway's variable-reference UI.
6. Add a Railway Volume to the app service and mount it at `/data`. Set
   `DATA_DIR=/data` so uploads and local database files use persistent storage.
7. Add these environment variables to the app service:
   - `NODE_ENV=production`
   - `DATA_DIR=/data`
   - `DATABASE_URL` = reference to the staging Postgres `DATABASE_URL`
   - `JWT_SECRET` = unique random secret of at least 32 characters
   - `REFRESH_SECRET` = a different unique random secret of at least 32 characters
   - `DATABASE_PROVIDER=postgres`
   - `PGSSL_REJECT_UNAUTHORIZED=false` (for the managed PostgreSQL connection used by this configuration)
   - `MEDIA_STORAGE_PROVIDER=local` for a staging smoke test, or configure the existing S3-compatible storage variables for persistent uploaded media.
8. Set the app's health check path to `/api/ready`, deploy, then generate a public domain.
9. Test registration, login, page loading, uploads, video playback and persistence after a redeploy before calling the deployment successful.

## Protect current user data

A new staging database is empty. It will **not** contain the accounts and content
from the existing Render database unless you migrate them. Do not point production
traffic at a blank database. Before switching production, back up the existing
database and migrate its contents to the target PostgreSQL database; separately
migrate existing uploaded files or object-storage settings. Keep the current
Render service and database unchanged until the new deployment has been tested.

If you intend to use the existing Render database temporarily, use its External
Database URL only if external connections are enabled and you understand the
networking and security implications. Never use a Render Internal Database URL
from a service hosted elsewhere.

## Costs and limits

Railway documents a one-time $5 trial credit for new accounts; after the trial,
the Free plan has $1/month usage credit. The Hobby plan is $5/month minimum and
usage can cost more if it exceeds included usage. Review the current pricing before
committing to production hosting. See https://docs.railway.com/pricing/plans and
https://docs.railway.com/volumes/reference.

A Railway Volume provides persistence for files placed under its mount path, but
uploaded videos can outgrow the small free-tier volume. For production media, use
the S3-compatible storage already supported by the app.
