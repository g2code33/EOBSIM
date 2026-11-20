/** Final concentration in the same concentration units as the stock. */
export function finalConcentration(stock, added, finalVolume) {
  if (![stock, added, finalVolume].every(Number.isFinite) ||
      stock < 0 || added < 0 || finalVolume <= 0 || added > finalVolume) {
    throw new RangeError('Enter non-negative values and a final volume at least as large as the volume added.');
  }
  const result = stock * (added / finalVolume);
  if (!Number.isFinite(result)) throw new RangeError('Result is outside the supported range.');
  return result;
}
