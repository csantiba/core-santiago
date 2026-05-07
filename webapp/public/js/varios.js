import { api, formatFecha, esc, truncar, $ } from './app.js';

async function init() {
  const [data, conData] = await Promise.all([api('varios'), api('consejeros')]);
  const consejeros = conData.consejeros || [];

  const sel = $('#consejero');
  for (const c of consejeros) {
    sel.innerHTML += `<option value="${c.id}">${esc(c.nombre_completo)}</option>`;
  }

  render(data);

  $('#filtros').addEventListener('submit', async (e) => { e.preventDefault(); await cargar(); });
  $('#limpiar').addEventListener('click', () => {
    $('#q').value = '';
    $('#consejero').value = '';
    $('#fecha_desde').value = '';
    $('#fecha_hasta').value = '';
    api('varios').then(render);
  });
}

async function cargar() {
  const params = new URLSearchParams();
  const q = $('#q').value.trim();
  const cid = $('#consejero').value;
  const desde = $('#fecha_desde').value;
  const hasta = $('#fecha_hasta').value;
  if (q) params.set('q', q);
  if (cid) params.set('consejero_id', cid);
  if (desde) params.set('fecha_desde', desde);
  if (hasta) params.set('fecha_hasta', hasta);
  const data = await api('varios?' + params);
  render(data);
}

function render(data) {
  const { temas, porConsejero } = data;
  renderStats(temas, porConsejero);
  renderRanking(porConsejero);
  renderTemas(temas);
}

function renderStats(temas, porConsejero) {
  const totalConsejeros = Object.keys(porConsejero).length;
  const cats = {};
  for (const t of temas) {
    for (const c of (t.categorias || [])) cats[c] = (cats[c] || 0) + 1;
  }
  const topCat = Object.entries(cats).sort((a, b) => b[1] - a[1])[0];

  $('#stats').innerHTML = `
    <div class="stat-box"><div class="num">${temas.length}</div><div class="label">Temas varios</div></div>
    <div class="stat-box"><div class="num">${totalConsejeros}</div><div class="label">Consejeros(as) activos</div></div>
    <div class="stat-box"><div class="num">${topCat ? esc(topCat[0]) : '-'}</div><div class="label">Tema m&aacute;s frecuente</div></div>
  `;
}

function renderRanking(porConsejero) {
  const sorted = Object.entries(porConsejero).sort((a, b) => b[1] - a[1]);
  if (!sorted.length) {
    $('#ranking').innerHTML = '';
    return;
  }
  const maxVal = sorted[0]?.[1] || 1;

  $('#ranking').innerHTML = `
    <div class="card" style="border-left-color:var(--warning); margin-top:1rem">
      <h4 style="margin-bottom:0.8rem; color:var(--text-light); font-size:0.85rem; text-transform:uppercase; letter-spacing:0.5px">Temas presentados por consejero(a)</h4>
      ${sorted.map(([nombre, count]) => {
        const pct = (count / maxVal) * 100;
        return `
          <div style="display:flex; align-items:center; gap:0.8rem; margin-bottom:0.5rem">
            <span style="min-width:220px; font-size:0.88rem; text-align:right; color:var(--primary)">${esc(nombre)}</span>
            <div style="flex:1; height:22px; background:#ecf0f1; border-radius:4px; overflow:hidden">
              <div style="height:100%; width:${pct}%; background:var(--primary-light); border-radius:4px; transition:width 0.4s"></div>
            </div>
            <span style="min-width:30px; font-size:0.88rem; font-weight:600">${count}</span>
          </div>
        `;
      }).join('')}
    </div>
  `;
}

function renderTemas(temas) {
  const el = $('#contenido');
  if (!temas.length) {
    el.innerHTML = '<p style="color:var(--text-light)">No se encontraron temas.</p>';
    return;
  }
  el.innerHTML = temas.map(t => `
    <div class="card">
      <h3><a href="/sesion.html?id=${t.sesion_id}">${esc(t.titulo)}</a></h3>
      <div class="meta">
        <span>Sesi&oacute;n N&deg;${t.numero_sesion} - ${formatFecha(t.fecha)}</span>
        ${t.consejero ? `<span><strong>${esc(t.consejero)}</strong></span>` : ''}
        ${(t.categorias || []).filter(Boolean).map(c => `<span class="badge badge-cat">${esc(c)}</span>`).join('')}
      </div>
      ${t.resumen ? `<p class="resumen">${esc(truncar(t.resumen, 320))}</p>` : ''}
    </div>
  `).join('');
}

init().catch(err => {
  $('#contenido').innerHTML = `<p style="color:var(--danger)">Error: ${err.message}</p>`;
});
