import { createHash, timingSafeEqual } from 'node:crypto';
import { createReadStream } from 'node:fs';

function integrityError(code, message) {
  const error = new Error(message);
  error.code = code;
  return error;
}

/**
 * Check a staged file against metadata from a trusted source, without altering it.
 * This does not authenticate the metadata or install the file. Callers must
 * prevent the verified file from being replaced before it is used.
 */
export async function verifyPayload(file, expected) {
  if (!expected || typeof expected.sha256 !== 'string' ||
      !/^[a-f0-9]{64}$/.test(expected.sha256) ||
      !Number.isSafeInteger(expected.bytes) || expected.bytes < 0) {
    throw integrityError('ERR_METADATA', 'Expected a lowercase SHA-256 and a non-negative safe byte count');
  }

  const hash = createHash('sha256');
  let bytes = 0;
  for await (const chunk of createReadStream(file)) {
    bytes += chunk.length;
    if (!Number.isSafeInteger(bytes)) {
      throw integrityError('ERR_CHECKSUM', 'File size exceeds the supported range');
    }
    hash.update(chunk);
  }
  const digest = hash.digest();
  if (bytes !== expected.bytes || !timingSafeEqual(digest, Buffer.from(expected.sha256, 'hex'))) {
    throw integrityError('ERR_CHECKSUM', 'Downloaded file size or SHA-256 does not match trusted metadata');
  }
  return true;
}
