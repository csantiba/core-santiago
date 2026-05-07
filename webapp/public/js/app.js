const MESES = ['enero','febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre'];

export async function api(path) {
  const res = await fetch(`/api/${path}`);
  if (!res.ok) throw new Error(`Error ${res.status}`);
  return res.json();
}

export function formatFecha(iso) {
  if (!iso) return '';
  const d = new Date(iso);
  return `${d.getUTCDate()} de ${MESES[d.getUTCMonth()]} de ${d.getUTCFullYear()}`;
}

export function formatHora(t) {
  if (!t) return '';
  return t.slice(0, 5);
}

export function formatMonto(val, moneda) {
  if (val == null) return '';
  const n = Number(val);
  if (moneda === 'UF') return `UF ${n.toLocaleString('es-CL', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
  if (moneda === 'USD') return `USD ${n.toLocaleString('es-CL', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
  if (moneda === 'UTM') return `UTM ${n.toLocaleString('es-CL', { minimumFractionDigits: 1, maximumFractionDigits: 1 })}`;
  return `$${Math.round(n).toLocaleString('es-CL')}`;
}

export function badgeVotacion(tipo) {
  if (!tipo) return '';
  const t = tipo.toLowerCase();
  let cls = 'badge-cat';
  if (t.includes('unanimidad')) cls = 'badge-unanimidad';
  else if (t.includes('mayoria') || t.includes('aprueba') || t.includes('aprobado')) cls = 'badge-mayoria';
  else if (t.includes('rechaz')) cls = 'badge-rechazado';
  return `<span class="badge ${cls}">${esc(tipo.replace(/_/g, ' '))}</span>`;
}

export function badgeTipo(tipo) {
  return tipo === 'extraordinaria'
    ? '<span class="badge badge-ext">Extraordinaria</span>'
    : '<span class="badge badge-primary">Ordinaria</span>';
}

export function esc(s) {
  if (s == null) return '';
  const d = document.createElement('div');
  d.textContent = String(s);
  return d.innerHTML;
}

export function truncar(text, max = 200) {
  if (!text || text.length <= max) return text || '';
  return text.slice(0, max) + '...';
}

export function $(sel) { return document.querySelector(sel); }
export function $$(sel) { return document.querySelectorAll(sel); }
