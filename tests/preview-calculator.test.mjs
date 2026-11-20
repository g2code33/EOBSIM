import { test } from 'node:test';
import assert from 'node:assert/strict';
import { finalConcentration } from '../preview/calculator.mjs';

test('computes a final dilution in the stock concentration units', () => {
  assert.equal(finalConcentration(1, 1, 10), 0.1);
  assert.equal(finalConcentration(0, 1, 10), 0);
  assert.equal(finalConcentration(3, 10, 10), 3);
});

test('rejects invalid inputs and impossible dilution', () => {
  for (const values of [[1, 1, 0], [1, -1, 10], [-1, 1, 10], [1, 11, 10], [NaN, 1, 10], [Infinity, 1, 10]]) {
    assert.throws(() => finalConcentration(...values), RangeError);
  }
});
