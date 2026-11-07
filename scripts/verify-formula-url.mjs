#!/usr/bin/env node
/** Maintainer check: Formula must pin HTTPS npm + non-placeholder sha256. */
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const formulaPath = join(dirname(fileURLToPath(import.meta.url)), '..', 'Formula', 'wrkos-local-agent.rb');
const text = readFileSync(formulaPath, 'utf8');

const urlMatch = text.match(/^\s*url "([^"]+)"/m);
const shaMatch = text.match(/^\s*sha256 "([^"]+)"/m);
const url = urlMatch?.[1] ?? '';
const sha = shaMatch?.[1] ?? '';

if (!url.startsWith('https://registry.npmjs.org/wrkos-local-agent/')) {
  console.error(`FAIL: url must be official HTTPS npm tarball, got: ${url}`);
  process.exit(1);
}
if (sha === '0'.repeat(64)) {
  console.error('FAIL: sha256 is still the all-zero placeholder — do not ship to operators');
  process.exit(1);
}
if (!/^[a-f0-9]{64}$/.test(sha)) {
  console.error(`FAIL: sha256 must be 64 hex chars, got: ${sha}`);
  process.exit(1);
}

console.log(`OK: ${url}`);
console.log(`OK: sha256=${sha}`);
