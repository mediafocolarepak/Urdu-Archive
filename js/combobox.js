// A free-typing input with a native suggestion dropdown (HTML <datalist>), backed by
// option_lists + SessionCache. Used where a field is deliberately open-ended (Hayat Editor's
// Autore/Categoria/Branca/Argomento) rather than a fixed enum with its own <select> elsewhere
// in the app. A <datalist> was chosen over a custom dropdown widget because it gives typing,
// filtering and keyboard navigation for free from the browser - no positioning/click-outside
// code to maintain for what is otherwise just an <input>.
//
// Two pieces, since callers sometimes need to build a combobox cell as part of a larger HTML
// string (e.g. one row of a grid) and wire it up only after the whole table is in the DOM:
//   comboboxHtml(opts)  -> HTML string, embed anywhere
//   wireCombobox(opts)  -> call once the element is in the DOM, attaches the change handler
// renderCombobox(container, opts) is a convenience for the simple case: build + wire in one call.

import { esc, SessionCache } from './core.js?v=20260901211255';

export function comboboxHtml({ id, listName, value, placeholder }) {
  const options = SessionCache.getAll(listName);
  return `<input id="${esc(id)}" list="${esc(id)}-list" value="${esc(value || '')}" placeholder="${esc(placeholder || '')}" autocomplete="off">
    <datalist id="${esc(id)}-list">${options.map(([c, l]) => `<option value="${esc(c)}">${esc(l)}</option>`).join('')}</datalist>`;
}

export function wireCombobox({ id, listName, onChange, allowNew = true }) {
  const input = document.getElementById(id);
  if (!input) return null;
  input.addEventListener('change', () => {
    const val = input.value.trim();
    const options = SessionCache.getAll(listName);
    if (val && allowNew && !options.some(([c]) => c === val)) {
      SessionCache.add(listName, val, val);
    }
    if (onChange) onChange(val);
  });
  return input;
}

export function renderCombobox(container, opts) {
  container.innerHTML = comboboxHtml(opts);
  return wireCombobox(opts);
}
