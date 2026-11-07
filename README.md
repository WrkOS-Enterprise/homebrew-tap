# WrkOS Homebrew tap

This repository is the Homebrew tap for **WrkOS** — the platform teams use to plan work, sell, document, coordinate, and run AI employees in one workspace.

## How WrkOS helps

WrkOS keeps delivery, sales, docs, and day-to-day coordination in one organisation. People chat with AI agents that can act inside those apps (with permissions and approvals). When engineering work should run on a real Mac with Cursor Ultra, WrkOS can drive that from the same chat — without leaving the product.

## Why this tap matters

Local Agents need a small companion app on each company Mac: **`wrkos-local-agent`**. It pairs the laptop with WrkOS, keeps the Cursor API key on the device, and runs coding turns in local repos while progress stays visible in WrkOS.

This tap makes that companion easy to install:

```bash
brew tap WrkOS-Enterprise/tap
brew install wrkos-local-agent
```

No WrkOS source checkout, no GitHub login on the laptop — just Homebrew, then connect to your workspace.

## Connect a Mac to WrkOS

1. **Install** with the commands above (needs Node 22 via Homebrew).
2. In WrkOS → **Agents → Local Agents**, choose **Pair computer** and copy the command.
3. On the Mac:
   ```bash
   wrkos-local-agent pair --api <your-wrkos-api-url> --code <code>
   wrkos-local-agent ui      # set Cursor Ultra key + add repo folders
   wrkos-local-agent start   # leave running
   ```
4. Refresh WrkOS — the computer shows online; open a repo chat and work from there.

Your Cursor key and device credentials stay on the Mac. WrkOS holds the conversation, approvals, and audit trail.

## Safe connection to WrkOS

- Use an **`https://`** API URL from WrkOS (or a Cloudflare HTTPS tunnel). The companion
  refuses remote `http://` URLs so pairing tokens are not exposed on the network.
- Install only from this tap — the Formula pins the official **HTTPS npm** package and a
  **checksum** so a swapped download is rejected.
- The Mac dials **out** to WrkOS; nothing in this install opens a public inbound port.

## npm alternative

If you prefer not to use Homebrew:

```bash
npm install -g wrkos-local-agent   # Node >= 22.13
```

Then use the same `pair` / `ui` / `start` flow.

## Support

Pairing and Local Agents are available for organisations that use WrkOS Local Agents. For product access and workspace setup, use your WrkOS admin or [app.wrkos.com](https://app.wrkos.com).

## Maintainers — public repo via git subtree

This folder is the **source of truth inside `wrkos-mono`**. The public GitHub
repo `WrkOS-Enterprise/homebrew-tap` is a published mirror so operators can
`brew tap WrkOS-Enterprise/tap` without cloning the product monorepo.

We use a **git subtree** (not a submodule): edit here, commit in the mono, then
push the prefix to the public tap.

```bash
# once: create empty public WrkOS-Enterprise/homebrew-tap, then:
git remote add homebrew-tap git@github.com:WrkOS-Enterprise/homebrew-tap.git
node packaging/homebrew-tap/scripts/subtree-push.mjs
```

Full steps: [scripts/subtree-bootstrap.md](./scripts/subtree-bootstrap.md).
