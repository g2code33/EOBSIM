import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { verifyPayload } from '../scripts/update-integrity.mjs';

async function withFixture(run) {
  const dir = await mkdtemp(join(tmpdir(), 'eobsim-integrity-'));
  try {
    const file = join(dir, 'package.bin');
    const original = Buffer.from('EOSIM release fixture\n');
    await writeFile(file, original);
    const sha256 = createHash('sha256').update(original).digest('hex');
    await run(file, original, { sha256, bytes: original.length });
  } finally {
    await rm(dir, { recursive: true, force: true });
  }
}

test('accepts only an exact size and SHA-256 match', async () => {
  await withFixture(async (file, original, expected) => {
    assert.equal(await verifyPayload(file, expected), true);
    assert.deepEqual(await readFile(file), original);
  });
});

test('rejects tampering with a same-sized file without altering it', async () => {
  await withFixture(async (file, original, expected) => {
    const tampered = Buffer.from(original);
    tampered[0] ^= 1;
    await writeFile(file, tampered);
    await assert.rejects(verifyPayload(file, expected), { code: 'ERR_CHECKSUM' });
    assert.deepEqual(await readFile(file), tampered);
  });
});

test('rejects a wrong size even if the hash matches', async () => {
  await withFixture(async (file, original, expected) => {
    await assert.rejects(verifyPayload(file, { ...expected, bytes: expected.bytes + 1 }), { code: 'ERR_CHECKSUM' });
    assert.deepEqual(await readFile(file), original);
  });
});

test('rejects missing, malformed, or unsafe metadata', async () => {
  await withFixture(async (file, original, expected) => {
    for (const input of [undefined, {}, { ...expected, sha256: 'bad' },
      { ...expected, sha256: expected.sha256.toUpperCase() },
      { ...expected, bytes: -1 }, { ...expected, bytes: 1.5 },
      { ...expected, bytes: Number.MAX_SAFE_INTEGER + 1 }]) {
      await assert.rejects(verifyPayload(file, input), { code: 'ERR_METADATA' });
    }
    assert.deepEqual(await readFile(file), original);
  });
});

test('propagates missing-file errors instead of claiming success', async () => {
  await withFixture(async (file, _original, expected) => {
    await rm(file);
    await assert.rejects(verifyPayload(file, expected), { code: 'ENOENT' });
  });
});
