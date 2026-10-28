# Deploying RELCOWHEELS

GitHub holds the code. Vercel builds and serves it. Both free at this size.

---

## The one setting that matters

**The Next.js application is not at the repository root. It is in `site/`.**

So when Vercel asks for a **Root Directory**, it must be set to `site`. Leave it at the default and
the build fails with "no package.json found", which is the single most likely reason a first deploy
of this project goes wrong.

Everything else Vercel can work out for itself: the framework is Next.js, the build command is
`next build`, and the output is handled automatically. Do not set a custom build or output command.

---

## First deploy

### 1. Create the repository

On GitHub, create an empty repository. Do not initialise it with a README, a licence or a
`.gitignore`, because the files already exist here and a shared first commit causes a conflict.

Suggested name: `relco-wheels`

### 2. Give this machine permission to push

A new repository needs its own deploy key. GitHub will not let the same key be a deploy key on two
repositories, so an existing key from another project cannot be reused here.

```bash
# Generate one for this repository
ssh-keygen -t ed25519 -C "relcowheels deploy" -f ~/.ssh/id_ed25519_relcowheels -N ""
chmod 600 ~/.ssh/id_ed25519_relcowheels

# Print the public half to paste into GitHub
cat ~/.ssh/id_ed25519_relcowheels.pub
```

Then, in GitHub, on the **new repository**: Settings, Deploy keys, Add deploy key.

- Title: `mac`
- Key: paste the line printed above
- **Tick "Allow write access".** Without it the push is refused with "denied to deploy key", which
  looks like a permissions problem elsewhere and is not.

### 3. Push

```bash
cd ~/Documents/apps/RELCOWHEELS
git init
git branch -M main
git config core.sshCommand "ssh -i ~/.ssh/id_ed25519_relcowheels -o IdentitiesOnly=yes"
git add -A
git commit -m "RELCO Wheels: marketplace schema, scaffold and home page"
git remote add origin git@github.com:contact873/relco-wheels.git
git push -u origin main
```

### 4. Import into Vercel

Vercel, Add New, Project, import the repository, then:

| Field | Value |
|---|---|
| Framework Preset | Next.js (detected automatically) |
| **Root Directory** | **`site`** |
| Build Command | leave empty |
| Output Directory | leave empty |
| Install Command | leave empty |
| Environment Variables | none yet, see below |

Deploy. It will build and give you `relco-wheels.vercel.app`.

### 5. Add the domain

Once it is deployed, add `wheels.relcoai.com` in Vercel under Settings, Domains. Vercel will show a
CNAME record to create. `relcoai.com` is on Cloudflare, so add the record there and leave the proxy
off while it verifies.

The canonical URLs in the application point at `https://wheels.relcoai.com`, set through
`NEXT_PUBLIC_SITE_URL`. Until that domain is live, set the variable to the `.vercel.app` address
instead, or the canonical tags will point somewhere that does not resolve.

---

## Environment variables

The site builds and runs with none of them. Every page renders from seed data until Supabase is
connected. Add these in Vercel under Settings, Environment Variables when the database exists:

```
NEXT_PUBLIC_SUPABASE_URL          from Supabase, Project Settings, API
NEXT_PUBLIC_SUPABASE_ANON_KEY     from Supabase, Project Settings, API
SUPABASE_SERVICE_ROLE_KEY         from Supabase, Project Settings, API. Server only.
NEXT_PUBLIC_SITE_URL              https://wheels.relcoai.com
NEXT_PUBLIC_GA_ID                 optional. Analytics stays off until a visitor accepts cookies.
```

`SUPABASE_SERVICE_ROLE_KEY` must never be given a `NEXT_PUBLIC_` prefix. That prefix inlines the
value into JavaScript delivered to the browser, and this key bypasses every row level security
policy in the database.

---

## Every deploy after the first

Vercel watches the `main` branch. Push and it rebuilds and deploys automatically.

```bash
cd ~/Documents/apps/RELCOWHEELS
git add -A
git commit -m "what changed"
git push
```

---

## Before pushing, run these

```bash
cd ~/Documents/apps/RELCOWHEELS/site
npm run build                       # must pass with no type errors
node ../tools/check-identity.mjs     # must not collide with another RELCO property
```

If `check-identity.mjs` reports a collision, do not push. Two RELCO properties sharing a palette or
a typeface is the exact problem the design identity plan exists to prevent.

---

## Notes for a future session

- The repository root is `RELCOWHEELS/`. The application is `site/`. Do not move `package.json` to
  the root without also changing Vercel's Root Directory, or the deploy breaks.
- Photographs in `site/public/cars/` are three real car photographs, used as seed content. They are
  not licensed stock and they are not ours to publish indefinitely. Replace them with real listings.
- `site/.env.local` is gitignored and must stay that way.
