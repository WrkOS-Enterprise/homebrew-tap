#!/usr/bin/env node
/**
 * Push packaging/homebrew-tap from wrkos-mono (source of truth) → public tap repo.
 *
 * Setup (once):
 *   1. Create public empty repo WrkOS-Enterprise/homebrew-tap on GitHub
 *   2. git remote add homebrew-tap git@github.com:WrkOS-Enterprise/homebrew-tap.git
 *   3. Commit packaging/homebrew-tap on the mono branch
 *   4. node packaging/homebrew-tap/scripts/subtree-push.mjs
 *
 * Later updates:
 *   git add packaging/homebrew-tap && git commit -m "…"
 *   node packaging/homebrew-tap/scripts/subtree-push.mjs
 */
import { spawnSync } from 'node:child_process';
import { existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '../../..');
const prefix = 'packaging/homebrew-tap';
const remote = process.env.HOMEBREW_TAP_REMOTE || 'homebrew-tap';
const branch = process.env.HOMEBREW_TAP_BRANCH || 'main';

function run(cmd, args, opts = {}) {
  const result = spawnSync(cmd, args, {
    cwd: root,
    encoding: 'utf8',
    stdio: opts.stdio ?? ['ignore', 'pipe', 'pipe'],
  });
  if (result.status !== 0) {
    const err = (result.stderr || result.stdout || '').trim();
    throw new Error(err || `${cmd} ${args.join(' ')} failed (${result.status})`);
  }
  return (result.stdout || '').trim();
}

function main() {
  process.chdir(root);

  if (!existsSync(join(root, prefix))) {
    console.error(`Missing ${prefix}`);
    process.exit(1);
  }

  try {
    run('git', ['rev-parse', '--is-inside-work-tree']);
  } catch {
    console.error('Not a git repository');
    process.exit(1);
  }

  try {
    run('git', ['remote', 'get-url', remote]);
  } catch {
    console.error(`Remote '${remote}' is not configured.`);
    console.error(`  git remote add ${remote} git@github.com:WrkOS-Enterprise/homebrew-tap.git`);
    process.exit(1);
  }

  const dirty = run('git', ['status', '--porcelain', '--', prefix]);
  if (dirty) {
    console.error(`Uncommitted changes under ${prefix}. Commit them in wrkos-mono first.`);
    console.error(dirty);
    process.exit(1);
  }

  try {
    run('git', ['ls-files', '--error-unmatch', `${prefix}/Formula/wrkos-local-agent.rb`]);
  } catch {
    console.error(`${prefix} is not tracked yet. Commit it into wrkos-mono, then re-run.`);
    process.exit(1);
  }

  const splitBranch = `homebrew-tap-split-${process.pid}`;
  console.log(`Splitting ${prefix} …`);
  run('git', ['subtree', 'split', `--prefix=${prefix}`, '-b', splitBranch], { stdio: 'inherit' });

  console.log(`Pushing to ${remote} (${branch}) …`);
  run('git', ['push', remote, `${splitBranch}:${branch}`], { stdio: 'inherit' });

  try {
    run('git', ['branch', '-D', splitBranch]);
  } catch {
    /* ignore */
  }

  const url = run('git', ['remote', 'get-url', remote]);
  console.log(`Done. Public tap updated: ${url} (${branch})`);
  console.log('Operators: brew tap WrkOS-Enterprise/tap && brew install wrkos-local-agent');
}

try {
  main();
} catch (error) {
  console.error(error?.message || error);
  process.exit(1);
}
