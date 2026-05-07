import { api, formatFecha, esc, truncar, $ } from './app.js';

async function init() {
  const comisiones = await api('comisiones');
  renderLista(comisiones);

  const hash = location.hash.replace('#', '');
  if (hash) await mostrarDetalle(hash);
}

function renderLista(comisiones) {
  const el = $('#contenido');
  if (!comisiones.length) {
    el.innerHTML = '<p style="color:var(--text-light)">No se han registrado comisiones a&uacute;n. Las comisiones se descubren autom&aacute;ticamente al procesar las actas.</p>';
    return;
  }

  el.innerHTML = `
    <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 1rem">
      ${comisiones.map(c => `
        <div class="card" style="cursor:pointer; margin:0; border-left-color: #6c3483" onclick="location.hash='${c.id}'; window.dispatchEvent(new Event('hashchange'))">
          <h3 style="color:#6c3483">${esc(c.nombre)}</h3>
          <div class="meta" style="margin-bottom:0.6rem">
            ${c.presidente ? `<span>Preside: <strong>${esc(c.presidente)}</strong></span>` : '<span style="color:var(--text-light)">Sin presidente registrado</span>'}
          </div>
          <div style="display:flex; gap:1.5rem; font-size:0.88rem">
            <span><strong>${c.total_temas}</strong> temas</span>
            <span><strong>${c.total_sesiones}</strong> sesiones</span>
          </div>
        </div>
      `).join('')}
    </div>
  `;
}

async function mostrarDetalle(id) {
  const data = await api(`comisiones/${id}`);
  const { comision, temas } = data;

  const el = $('#detalle');
  el.style.display = 'block';
  el.scrollIntoView({ behavior: 'smooth', block: 'start' });

  el.innerHTML = `
    <div style="margin-top:2rem">
      <a href="/comisiones.html" class="back" onclick="document.getElementById('detalle').style.display='none'; location.hash=''; return false;">&larr; Volver al listado</a>
      <div class="sesion-header" style="border-top-color:#6c3483">
        <h2 style="color:#6c3483">${esc(comision.nombre)}</h2>
        ${comision.presidente ? `<div class="meta" style="margin-top:0.5rem"><span>Preside: <strong>${esc(comision.presidente)}</strong></span></div>` : ''}
        ${comision.descripcion ? `<p style="margin-top:0.8rem; color:#555">${esc(comision.descripcion)}</p>` : ''}
      </div>

      <h3 style="margin:1.5rem 0 0.8rem; color:var(--primary); font-size:1.1rem">Temas presentados (${temas.length})</h3>
      ${temas.length ? temas.map(t => `
        <div class="card">
          <h3><a href="/sesion.html?id=${t.sesion_id}">${esc(t.titulo)}</a></h3>
          <div class="meta">
            <span>Sesi&oacute;n N&deg;${t.numero_sesion} - ${formatFecha(t.fecha)}</span>
            ${t.presentado_por_nombre ? `<span>Presenta: <strong>${esc(t.presentado_por_nombre)}</strong></span>` : ''}
            ${(t.categorias || []).filter(Boolean).map(c => `<span class="badge badge-cat">${esc(c)}</span>`).join('')}
          </div>
          ${t.resumen ? `<p class="resumen">${esc(truncar(t.resumen, 280))}</p>` : ''}
        </div>
      `).join('') : '<p style="color:var(--text-light)">Esta comisi&oacute;n a&uacute;n no tiene temas registrados.</p>'}
    </div>
  `;
}

window.addEventListener('hashchange', () => {
  const hash = location.hash.replace('#', '');
  if (hash) mostrarDetalle(hash);
});

init().catch(err => {
  $('#contenido').innerHTML = `<p style="color:var(--danger)">Error: ${err.message}</p>`;
});
