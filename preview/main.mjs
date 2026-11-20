import { finalConcentration } from './calculator.mjs';

const tissue = document.querySelector('#tissue');
tissue.addEventListener('change', () => {
  document.querySelector('#tissue-name').textContent = tissue.value;
});
document.querySelector('#dilution-form').addEventListener('submit', (event) => {
  event.preventDefault();
  const value = (id) => {
    const input = document.querySelector(id);
    return input.value === '' ? NaN : Number(input.value);
  };
  const result = document.querySelector('#result');
  const note = document.querySelector('#result-note');
  try {
    result.textContent = Number(finalConcentration(value('#stock'), value('#added'), value('#total')).toPrecision(6)).toString();
    note.textContent = 'In the same units as stock concentration';
    note.classList.remove('error');
  } catch (error) {
    result.textContent = '—';
    note.textContent = error.message;
    note.classList.add('error');
  }
});
