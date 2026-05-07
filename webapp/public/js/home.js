import { api, formatFecha, formatHora, badgeTipo, esc, truncar, $ } from './app.js';

async function init() {
  const [sesiones, categorias] = await Promise.all([api('sesiones'), api('categorias')]);

  const sel = $('#categoria');
  for (const c of categorias) {
    sel.innerHTML += `<option value="${c.id}">${esc(c.nombre)}</option>`;
  }

  renderSesiones(sesiones);

  $('#filtros').addEventListener('submit', async (e) => {
    e.preventDefault();
    const q = $('#q').value.trim();
    const cat = $('#categoria').value;
    const desde = $('#fecha_desde').value;
    const hasta = $('#fecha_hasta').value;

    if (!q && !cat && !desde && !hasta) {
      renderSesiones(sesiones);
      return;
    }

    const params = new URLSearchParams();
    if (q) params.set('q', q);
    if (cat) params.set('categoria_id', cat);
    if (desde) params.set('fecha_desde', desde);
    if (hasta) params.set('fecha_hasta', hasta);

    const resultados = await api('buscar?' + params);
    renderBusqueda(resultados);
  });

  $('#limpiar').addEventListener('click', () => {
    $('#q').value = '';
    $('#categoria').value = '';
    $('#fecha_desde').value = '';
    $('#fecha_hasta').value = '';
    renderSesiones(sesiones);
  });
}

function renderSesiones(sesiones) {
  const el = $('#contenido');
  if (!sesiones.length) {
    el.innerHTML = '<p>No hay sesiones registradas.</p>';
    return;
  }

  el.innerHTML = sesiones.map(s => `
    <div class="card">
      <h3>
        <a href="/sesion.html?id=${s.id}">
          Sesi&oacute;n ${s.tipo_sesion === 'extraordinaria' ? 'Extraordinaria' : 'Ordinaria'} N&deg;${s.numero_sesion}
        </a>
        ${badgeTipo(s.tipo_sesion)}
      </h3>
      <div class="meta">
        <span>${formatFecha(s.fecha)}</span>
        <span>${formatHora(s.hora_inicio)}${s.hora_termino ? ' - ' + formatHora(s.hora_termino) : ''} hrs</span>
        <span>${s.total_temas} temas</span>
        <span>${s.total_acuerdos} acuerdos</span>
      </div>
      <p class="resumen">${esc(truncar(s.resumen_general, 320))}</p>
    </div>
  `).join('');
}

function renderBusqueda(temas) {
  const el = $('#contenido');
  if (!temas.length) {
    el.innerHTML = '<p>No se encontraron resultados.</p>';
    return;
  }

  el.innerHTML = `<p style="margin-bottom:1rem;color:var(--text-light)">${temas.length} resultado(s)</p>` +
    temas.map(t => `
    <div class="card">
      <h3><a href="/sesion.html?id=${t.sesion_id}">${esc(t.titulo)}</a></h3>
      <div class="meta">
        <span>Sesi&oacute;n N&deg;${t.numero_sesion} - ${formatFecha(t.fecha)}</span>
        <span class="badge badge-primary">${esc(t.seccion)}</span>
        ${t.comision_nombre ? `<span class="badge badge-comision">${esc(t.comision_nombre)}</span>` : ''}
        ${(t.categorias || []).map(c => `<span class="badge badge-cat">${esc(c)}</span>`).join('')}
      </div>
      <p class="resumen">${esc(truncar(t.resumen, 280))}</p>
    </div>
  `).join('');
}

init().catch(err => {
  $('#contenido').innerHTML = `<p style="color:var(--danger)">Error: ${err.message}</p>`;
});
