# Response — sales-workforce-jk plan failure (repo.baseDir + semantics/dq syntax)

**Resource:** `sales-workforce-jk` · **Tenant:** `ct-sandbox` · **Instance:** `pacific-051426`  
**Git repo:** `https://github.com/jatjitendra/vulcan-sales-workforce.git`  
**Reference:** `practice-insights-v2` (working on same tenant)

---

## 1. What you reported

> `repo.baseDir` was `sales-workforce-jk/vulcan` (wrong). It should include the repo folder name first:  
> `vulcan-sales-workforce/sales-workforce-jk/vulcan`  
>  
> Because of that, Spark plan cannot find `config.yaml` and fails with:  
> *"Vulcan project config could not be found. Point the cli to the project path with vulcan -p."*  
>  
> Semantics and checks syntax also appear outdated.

---

## 2. What we changed

### A. `repo.baseDir` in deploy manifest

**Before (incorrect):**

```yaml
repo:
  url: https://github.com/jatjitendra/vulcan-sales-workforce.git
  baseDir: sales-workforce-jk/vulcan   # missing repo root folder prefix
```

**After (correct — matches practice-insights pattern):**

```yaml
repo:
  baseDir: vulcan-sales-workforce/sales-workforce-jk/vulcan
  secret: ct-sandbox:github-token
  syncFlags:
    - "--ref=main"
    - "--submodules=off"
  url: https://github.com/jatjitendra/vulcan-sales-workforce.git
```

**File:** `vulcan-sales-workforce/sales-workforce-jk/vulcan/sales-workforce-deploy.yaml`  
(same location as `practice-insights-deploy.yaml` in the reference project)

**Why:** Git-sync clones the full repo. Our repo root contains a `vulcan-sales-workforce/` directory; `config.yaml` lives at  
`vulcan-sales-workforce/sales-workforce-jk/vulcan/config.yaml`.  
Reference uses the same pattern: `baseDir: sgws-testing/practice-insights-v2/vulcan`.

**Also done:**

- Deleted the old `sales-workforce-jk` vulcan resource on Pacific
- Re-applied from the corrected manifest after pushing to `main`
- Aligned project layout with `practice-insights-v2` (`config.yaml`, deploy YAML inside `vulcan/`, `spark2` dialect)

---

### B. Semantics — updated to current Vulcan syntax

**Before (legacy `kind: semantic` block):**

```yaml
kind: semantic
name: orders
depends_on: analytics.orders_enriched
dimensions:
  - order_id
measures:
  - name: order_count
    type: count
    expression: "{orders.order_id}"
```

**After (model-keyed semantics — Vulcan book / project scaffold):**

```yaml
models:
  analytics.orders_enriched:
    alias: orders
    dimensions:
      includes:
        - order_id
        - order_date
        ...
    measures:
      order_count:
        type: count
        expression: "{orders.order_id}"
```

**Files updated:**

- `models/semantics/orders_enriched.yml`
- `models/semantics/sales_by_rep_daily.yml`

**Why:** Latest Vulcan semantics use a top-level `models:` map keyed by physical model name, with `alias`, `dimensions.includes`, and named `measures` blocks (not `kind: semantic` + flat lists).

---

### C. Data quality — checks renamed to `models/dq/` with current syntax

**Before (legacy `kind: dq` + `rules:`):**

```yaml
kind: dq
name: orders_enriched_dq
depends_on: analytics.orders_enriched
rules:
  - row_count > 0:
      name: orders_enriched_not_empty
      dimension: completeness
```

**After (current `checks:` keyed by model — former “checks”, now under `models/dq/`):**

```yaml
checks:
  analytics.orders_enriched:
    completeness:
      - row_count > 0:
          name: orders_enriched_not_empty
          attributes:
            description: Model must have at least one row
    validity:
      - failed rows:
          name: invalid_status_values
          fail query: |
            SELECT order_id, status
            FROM analytics.orders_enriched
            WHERE status NOT IN ('pending', 'completed', 'cancelled')
          samples limit: 10
```

**Files updated:**

- `models/dq/orders_enriched.yml`
- `models/dq/sales_by_rep_daily.yml`

**Why:** Vulcan book documents DQ as dimension-grouped `checks:` blocks (`completeness`, `validity`, `accuracy`) keyed by model name, not `kind: dq` / `rules:`.

**Unchanged:** SQL models (`raw.*`, `analytics.*`), seeds, Spark/compute/depot settings, workflow (`migrate` → `plan` → `run`).

---

## 3. Why plan may still show the same error

After fixing `baseDir`, updating syntax, deleting the resource, and re-applying:

| Observation | Detail |
|-------------|--------|
| Resource apply | Succeeds — `sales-workforce-jk:v1alpha:vulcan` **created** |
| Git sync | Succeeds — latest commit on `main` includes corrected `baseDir` |
| Plan runtime | Still ends in **`vulcan-plan:failed`** |
| Workflow logs | Show SparkApplication `FAILED`; driver-level Vulcan message not surfaced in DataOS workflow executor logs |

**Likely explanations if the error text is unchanged:**

1. **Stale plan pod / cached git volume** — Plan may still be reading a previous sync revision or wrong working directory until the platform remounts `/etc/dataos/work` with the new `baseDir`. A full delete + wait for `pending_delete` + re-apply was performed; if error persists, platform-side cache or volume mount should be checked.

2. **Resolved path differs from repo layout** — Please confirm on the plan pod that this file exists after sync:  
   `/etc/dataos/work/vulcan-sales-workforce/sales-workforce-jk/vulcan/config.yaml`  
   (Compare with working `practice-insights` at  
   `/etc/dataos/work/sgws-testing/practice-insights-v2/vulcan/config.yaml`.)

3. **Failure masked as “config not found”** — Spark plan driver may fail early (Spark version, env, `DATAOS_TENANT_ID`) and surface a generic Vulcan CLI message. Spark **driver** logs on `ct-sandbox-compute` (not workflow executor logs) are needed for the root cause.

4. **Local validation passes** — `make local-check` (`info` → `plan` → `audit`) succeeds on Postgres, so project config and model definitions are valid; issue appears specific to Pacific Spark plan runtime path resolution or cluster config.

---

## 4. Request to platform team

Please verify on the **sales-workforce-jk-plan** Spark driver (same checks done for **practice-insights**):

1. Git-sync target path and that `config.yaml` exists at  
   `vulcan-sales-workforce/sales-workforce-jk/vulcan/config.yaml` under the work volume.
2. Working directory / `vulcan -p` equivalent matches `repo.baseDir` in the applied spec.
3. Spark driver logs for the failed application (not only workflow executor “SparkApplication FAILED” wrapper).

---

## 5. Commits / apply commands used

```bash
# Repo fix + syntax updates on main
git push origin main

# Pacific redeploy
dataos-ctl resource delete -t vulcan -n sales-workforce-jk -v v1alpha
# wait until resource is gone
dataos-ctl resource apply -f vulcan-sales-workforce/sales-workforce-jk/vulcan/sales-workforce-deploy.yaml
```

---

## 6. Summary

| Item | Status |
|------|--------|
| `baseDir` corrected to `vulcan-sales-workforce/sales-workforce-jk/vulcan` | Done |
| Deploy manifest aligned with practice-insights-v2 | Done |
| Semantics updated to `models:` / `includes` syntax | Done |
| DQ updated to `checks:` dimension syntax under `models/dq/` | Done |
| Model SQL / business logic | Unchanged |
| Pacific plan | **Still failing** — needs platform verification of synced path + Spark driver logs |
