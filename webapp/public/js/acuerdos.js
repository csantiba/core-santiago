import { api, formatFecha, formatMonto, badgeVotacion, esc, truncar, $ } from './app.js';

async function init() {
  const categorias = await api('categorias');
  const sel = $('#categoria');
  for (const c of categorias) {
    sel.innerHTML += `<option value="${c.id}">${esc(c.nombre)}</option>`;
  }

  await cargar();

  $('#filtros').addEventListener('submit', (e) => { e.preventDefault(); cargar(); });
  $('#limpiar').addEventListener('click', () => {
    $('#q').value = '';
    $('#categoria').value = '';
    $('#fuente').value = '';
    $('#fecha_desde').value = '';
    $('#fecha_hasta').value = '';
    cargar();
  });
}

async function cargar() {
  const params = new URLSearchParams();
  const q = $('#q').value.trim();
  const cat = $('#categoria').value;
  const fuente = $('#fuente').value;
  const desde = $('#fecha_desde').value;
  const hasta = $('#fecha_hasta').value;
  if (q) params.set('q', q);
  if (cat) params.set('categoria_id', cat);
  if (fuente) params.set('fuente', fuente);
  if (desde) params.set('fecha_desde', desde);
  if (hasta) params.set('fecha_hasta', hasta);

  const acuerdos = await api('acuerdos?' + params);
  renderStats(acuerdos);
  renderTabla(acuerdos);
}

function renderStats(acuerdos) {
  const unanimes = acuerdos.filter(a => a.resultado_votacion && a.resultado_votacion.toLowerCase().includes('unanimidad')).length;
  const totalCLP = acuerdos
    .filter(a => a.monto_involucrado && a.moneda === 'CLP')
    .reduce((s, a) => s + Number(a.monto_involucrado), 0);

  $('#stats').innerHTML = `
    <div class="stat-box"><div class="num">${acuerdos.length}</div><div class="label">Acuerdos</div></div>
    <div class="stat-box"><div class="num">${unanimes}</div><div class="label">Por unanimidad</div></div>
    <div class="stat-box"><div class="num">${totalCLP ? formatMonto(totalCLP, 'CLP') : '-'}</div><div class="label">Monto total CLP</div></div>
  `;
}

function renderTabla(acuerdos) {
  if (!acuerdos.length) {
    $('#contenido').innerHTML = '<p>No se encontraron acuerdos.</p>';
    return;
  }

  $('#contenido').innerHTML = `
    <table class="acuerdos-table">
      <thead>
        <tr>
          <th>N&deg;</th>
          <th>Sesi&oacute;n</th>
          <th>Tema</th>
          <th>Votaci&oacute;n</th>
          <th>Monto</th>
          <th>Fuente</th>
          <th>Beneficiario</th>
        </tr>
      </thead>
      <tbody>
        ${acuerdos.map(a => `
          <tr class="acuerdo-row" style="cursor:pointer">
            <td><strong>${a.numero_acuerdo || '-'}</strong></td>
            <td><a href="/sesion.html?id=${a.sesion_id}">${a.tipo_sesion === 'extraordinaria' ? 'Ext. ' : ''}N&deg;${a.numero_sesion}<br><small>${formatFecha(a.fecha)}</small></a></td>
            <td>${esc(truncar(a.titulo_tema, 80))} <span class="arrow">&#9654;</span></td>
            <td>${badgeVotacion(a.resultado_votacion)}</td>
            <td class="monto">${a.monto_involucrado ? formatMonto(a.monto_involucrado, a.moneda) : ''}</td>
            <td>${a.fuente_financiamiento ? esc(a.fuente_financiamiento) : ''}</td>
            <td>${a.beneficiario ? esc(truncar(a.beneficiario, 40)) : ''}</td>
          </tr>
          <tr class="acuerdo-detail" style="display:none">
            <td colspan="7">
              <div class="acuerdo-detail-body">
                <p>${esc(a.texto_acuerdo || 'Sin texto disponible.')}</p>
                <div class="acuerdo-meta">
                  ${a.rut_beneficiario ? `<span>RUT: ${esc(a.rut_beneficiario)}</span>` : ''}
                  ${a.votos_favor != null ? `<span>A favor: ${a.votos_favor}</span>` : ''}
                  ${a.votos_contra ? `<span>En contra: ${a.votos_contra}</span>` : ''}
                  ${a.abstenciones ? `<span>Abstenciones: ${a.abstenciones}</span>` : ''}
                  ${a.inhabilidades ? `<span>Inhabilidades: ${a.inhabilidades}</span>` : ''}
                  ${a.cumplimiento_inmediato ? '<span class="badge badge-unanimidad">Cumplimiento inmediato</span>' : ''}
                </div>
              </div>
            </td>
          </tr>
        `).join('')}
      </tbody>
    </table>
  `;

  document.querySelectorAll('.acuerdo-row').forEach(row => {
    row.addEventListener('click', (e) => {
      if (e.target.closest('a')) return;
      const detail = row.nextElementSibling;
      const open = detail.style.display !== 'none';
      detail.style.display = open ? 'none' : 'table-row';
      row.classList.toggle('open', !open);
    });
  });
}

init().catch(err => {
  $('#contenido').innerHTML = `<p style="color:var(--danger)">Error: ${err.message}</p>`;
});
