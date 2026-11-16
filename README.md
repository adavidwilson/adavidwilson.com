# adavidwilson.com

A minimal [Zola](https://www.getzola.org/) blog (the **still** theme) deployed as
a static site on **Cloudflare Workers** via **Terraform**, built and released
through **GitHub Actions** using **HCP Terraform** CLI-driven remote runs.

## TODO

- Fix page titles to include descriptions after "|"
- Continue refactoring/cleaning up after Hermes

## How it works

```
push / PR  ──▶  GitHub Actions
                 │  1. install pinned Zola
                 │  2. zola check --skip-external-links  +  zola build
                 │  3. stage output → infrastructure/generated/public
                 │  4. terraform fmt -check + validate
                 ▼
   pull request        push to main
   (non-fork only)         │
   │                     5. terraform init (HCP backend)
   │                     6. terraform plan  ← speculative plan in HCP
   │                     7. terraform apply → HCP runs it remotely
   ▼                         │
speculative plan        Cloudflare provider creates/updates:
in HCP Terraform          • cloudflare_worker (the Worker)
                          • cloudflare_worker_version (assets = generated/public)
                          • cloudflare_workers_deployment (routes traffic)
                          • cloudflare_workers_route (adavidwilson.com/*)
```

Terraform is the single source of truth for the Cloudflare infrastructure.
State lives remotely in HCP Terraform (not in the repo).

## Repository layout

```
zola.toml                     Site config; base_url = https://adavidwilson.com
content/                      Blog content (pages + posts)
templates/, static/, themes/  Theme files (still is a git submodule)
infrastructure/               Terraform config (Cloudflare Workers)
  versions.tf                 Provider pin (cloudflare 5.29.0) + HCP `cloud` block
  variables.tf                account_id (required), zone/domain/worker/date
  main.tf                     Worker / version / deployment / route / zone lookup
  outputs.tf                  worker_name, domain, deployment_id
  terraform.tfvars.example    Local-only template (git-ignored)
  .terraformignore            Excludes .terraform/ and state; NOT generated/
  README.md                   This file
.github/workflows/deploy.yml  Zola build + Terraform plan/apply via HCP
```

---

## Prerequisites

- A Cloudflare account that owns (or will own) the `adavidwilson.com` zone.
- An [HCP Terraform](https://app.terraform.io/) account.
- Write access to this GitHub repository.

---

## First-time setup

### 1. Create the HCP Terraform organization and a CLI-driven workspace

1. In [HCP Terraform](https://app.terraform.io), create an organization (or use
   an existing one). Note its **name**.
2. Create a **workspace** (e.g. `adavidwilson-com`) in that organization.
   - **Execution mode: `Remote`** (runs execute in HCP Terraform's infrastructure).
   - This is a **CLI-driven** workspace — do **not** connect a VCS repository.
     GitHub Actions is the source of the generated artifact.
3. Copy the organization name and workspace name into
   `infrastructure/versions.tf`, replacing the placeholders in the `cloud` block:

   ```hcl
   cloud {
     organization = "YOUR_ORG_NAME"
     workspaces {
       name = "adavidwilson-com"
     }
   }
   ```

   > `organization` and `workspaces.name` must be literal strings — they cannot
   > be Terraform variables.

### 2. Create a least-privilege Cloudflare API token and add it to HCP

1. In Cloudflare: **Account center → API Tokens → Create Token** using the
   **Edit** template (or a custom token) with these minimum permission groups,
   scoped to the `adavidwilson.com` zone / your account:

   | Permission group        | Access |
   |-------------------------|--------|
   | Workers Scripts         | Read + Write |
   | Workers Routes          | Read + Write |
   | Zone                    | Read |

   These let Terraform create/update the Worker, its versions, the deployment,
   and the route, and look up the zone — and nothing else (no DNS record
   edits, no account changes).
2. In the HCP workspace: **Variables → Environment variables → Add**, name
   `CLOUDFLARE_API_TOKEN`, paste the token, and toggle **Sensitive**.
   Set it as an **environment variable** (not a Terraform variable) so the
   Cloudflare provider picks it up automatically at run time.

### 3. Add the HCP team token to GitHub Actions

1. In HCP: **Organization Settings → API Tokens → Team tokens → Generate token**
   for a dedicated CI team (create a team first if needed, e.g. `ci`).
   - Grant that team **`write`** access to the workspace (allows plan **and**
     apply). For plan-only, use `plan`.
   - Set an **expiry** and give the token a description.
2. In GitHub: **Settings → Secrets and variables → Actions → New repository
   secret**, name it **`TF_API_TOKEN`**, value = the HCP team token.

   > GitHub does **not** expose repository secrets to workflows triggered by
   > fork pull requests, so the token never leaves trusted runs.

### 4. Set the non-secret workspace variables

In the HCP workspace (**Variables → Terraform variables**), set:

| Variable           | Value                     | Notes |
|--------------------|---------------------------|-------|
| `account_id`       | your Cloudflare account ID | **Required.** Get it from https://dash.cloudflare.com/account-summary |
| `zone_name`        | `adavidwilson.com`        | Defaults to this; override only if the zone differs. |
| `custom_domain`    | `adavidwilson.com`        | Domain served by the Worker. |
| `worker_name`      | `adavidwilson-site`       | Name of the Worker. |
| `compatibility_date` | `2025-01-01`            | Bump when adding new features; a new date replaces the version. |

(`account_id` is non-secret, so a workspace variable is fine. For local runs you
can instead copy `infrastructure/terraform.tfvars.example` to
`infrastructure/terraform.tfvars` and fill it in — that file is git-ignored.)

### 5. One-time DNS

The `adavidwilson.com` zone must already exist in Cloudflare. If you created a
new zone, point your registrar's nameservers at Cloudflare. **No DNS record is
needed for the apex** — the managed `cloudflare_workers_route` serves it. (Do
not also add a matching A/CNAME record; that would be duplicate ownership.)

---

## Deploying

Commit and push:

```bash
git add -A && git commit -m "..." && git push
```

- **On a pull request:** GitHub Actions builds the site, stages the output, and
  runs `terraform fmt -check`, `terraform validate`, and a **speculative plan**
  in HCP Terraform (non-fork PRs only). No changes are made to Cloudflare.
- **On a push to `main`:** the site is rebuilt and `terraform apply` runs
  remotely in HCP Terraform, creating/updating the Worker, version, deployment,
  and route. Applies are serialized (overlapping production applies are blocked).

### Where to look

- **Zola build/check logs:** the workflow run's *Build & plan* / *Deploy* steps.
- **Terraform plans & applies:** the run in the HCP workspace UI
  (`app.terraform.io` → organization → workspace → Runs). The generated site
  files uploaded as the run configuration are listed there too.
- **Terraform outputs** (worker name, domain, deployment id): on each run's
  *Outputs* tab.

---

## Local development

```bash
# Build the site
zola --config zola.toml build

# Validate the Terraform (no HCP/Cloudflare credentials needed)
cd infrastructure
terraform init -backend=false
terraform validate
terraform fmt -check -recursive
```

To run a real plan/apply locally, set `account_id` (see
`terraform.tfvars.example`) and `CLOUDFLARE_API_TOKEN`, then:

```bash
cd infrastructure
terraform init            # logs in to HCP using TF_API_TOKEN (or `terraform login`)
terraform plan
terraform apply
```

---

## Security notes

- The Cloudflare API token lives **only** in the HCP workspace as a sensitive
  environment variable — never in the repo or GitHub secrets.
- `TF_API_TOKEN` (HCP team token) is a GitHub Actions secret, narrowly scoped to
  the workspace and expiring; it is not available to fork PRs.
- `infrastructure/generated/`, `infrastructure/.terraform/`, and state files are
  git-ignored and excluded from the HCP upload via `.terraformignore`
  (`generated/` is intentionally **included** so the assets are deployed).
- Terraform runs from the `infrastructure/` directory; the Worker's assets point
  at `generated/public` relative to that directory.
