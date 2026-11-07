# Security — WrkOS Homebrew tap

This public tap only distributes the **Local Agents** companion (`wrkos-local-agent`)
that connects a company Mac to WrkOS. It does **not** ship WrkOS secrets.

## What we protect against

| Risk | Mitigation |
|---|---|
| Tampered Homebrew download | Formula pins an **HTTPS** npm tarball + **sha256**. Brew refuses a mismatch. |
| Cleartext / MITM to WrkOS API | The CLI **rejects** remote `http://` API URLs. Pairing and the daemon require **`https://`** (loopback `http://localhost` only for local API). TLS certificates are verified (no custom insecure agents). |
| Credential theft via URL | API URLs must not embed username/password; pairing codes are short-lived and one-use. |
| Fake “inbound” laptop server | The bridge is **outbound-only** to WrkOS. Nothing in this tap opens a public port for WrkOS to dial into. Control UI binds **127.0.0.1** only. |
| Keys leaving the Mac | Cursor Ultra keys stay in Keychain / local store. Device private keys stay on disk under `~/.wrkos-local-agent`. They are never published in this tap. |

## Operator checklist

1. Install only via this tap or the published npm package — not random zip files.
2. Pair with the command from **your** WrkOS workspace (`https://…` API URL).
3. If WrkOS asks for a tunnel URL, use Cloudflare HTTPS — never paste an `http://` LAN IP from someone else.
4. Keep `wrkos-local-agent start` running only on Macs you trust.

## What stays private

- The WrkOS product monorepo and production API credentials are **not** in this tap.
- Organisation data, chat, and approvals live on WrkOS; the laptop only receives
  digest-bound commands after pairing and RBAC checks on the server.

## Reporting issues

If you find a supply-chain or transport issue in this tap or `wrkos-local-agent`,
contact your WrkOS administrator or the WrkOS Enterprise security contact. Do not
open public issues that include pairing codes, tokens, or Cursor keys.
