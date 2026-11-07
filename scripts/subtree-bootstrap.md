# Bootstrap the public `homebrew-tap` repo (git subtree)

**Source of truth:** `wrkos-mono` → path `packaging/homebrew-tap`  
**Public mirror:** `https://github.com/WrkOS-Enterprise/homebrew-tap` (Homebrew reads this)

We use a **git subtree** (not a submodule) so everyday edits stay in the monorepo
and one command publishes the tap. Submodules would make the public repo the
edit target and force SHA bumps in the mono on every change.

## One-time setup

1. On GitHub, create **`WrkOS-Enterprise/homebrew-tap`**:
   - Visibility: **Public**
   - Do **not** initialize with a README (empty repo)

2. In `wrkos-mono`, add the remote (SSH preferred for maintainers):

   ```bash
   git remote add homebrew-tap git@github.com:WrkOS-Enterprise/homebrew-tap.git
   ```

3. Commit the tap folder on your mono branch if it is not already tracked:

   ```bash
   git add packaging/homebrew-tap
   git commit -m "chore: add packaging/homebrew-tap for public Homebrew distribution"
   ```

4. First publish:

   ```bash
   node packaging/homebrew-tap/scripts/subtree-push.mjs
   ```

5. Confirm:

   ```bash
   brew untap WrkOS-Enterprise/tap 2>/dev/null || true
   brew tap WrkOS-Enterprise/tap
   brew install wrkos-local-agent   # after a real Formula sha256 is published
   ```

## Ongoing updates

Always edit files under `packaging/homebrew-tap/` **in wrkos-mono**, commit, then:

```bash
node packaging/homebrew-tap/scripts/subtree-push.mjs
```

Release CI (tag `local-agent-v*`) bumps the Formula in the mono; after that
commit lands on `master`/`main`, run the same push (or let CI push — see
`.github/workflows/local-agent-release.yml` when `HOMEBREW_TAP_TOKEN` is set).

## Do not

- Do not make day-to-day Formula edits only on `homebrew-tap` and forget the mono
  (the mono remains true). If someone must hotfix the public repo, pull it back:

  ```bash
  git fetch homebrew-tap
  git subtree pull --prefix=packaging/homebrew-tap homebrew-tap main -m "chore: sync homebrew-tap"
  ```

- Do not use a git submodule for this folder — it fights “mono is source of truth.”
