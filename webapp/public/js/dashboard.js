import { api, formatFecha, formatMonto, esc, truncar, $ } from './app.js';

async function init() {
  const d = await api('dashboard');

  const pctUnanimes = d.acuerdos.total > 0
    ? Math.round((d.acuerdos.unanimes / d.acuerdos.total) * 100) : 0;

  $('#dashboard').innerHTML = `
    <div class="dashboard-stats">
      <div class="dash-card">
        <div class="icon">&#128218;</div>
        <div class="num">${d.sesiones}</div>
        <div class="label">Sesiones plenarias</div>
        <div class="sub">Ordinarias y extraordinarias</div>
      </div>
      <div class="dash-card accent">
        <div class="icon">&#9989;</div>
        <div class="num">${d.acuerdos.total}</div>
        <div class="label">Acuerdos aprobados</div>
        <div class="sub">${pctUnanimes}% por unanimidad</div>
      </div>
      <div class="dash-card warn">
        <div class="icon">&#128176;</div>
        <div class="num">${d.fndr.total}</div>
        <div class="label">Acuerdos con monto</div>
        <div class="sub">FNDR, FRIL y otros fondos</div>
      </div>
      <div class="dash-card" style="border-top-color:#16a085">
        <div class="icon">&#128101;</div>
        <div class="num" style="color:#16a085">${d.asistenciaPromedio}%</div>
        <div class="label">Asistencia promedio</div>
        <div class="sub"><a href="/asistencia.html" style="color:var(--primary-light)">Ver detalle por consejero(a)</a></div>
      </div>
      <div class="dash-card">
        <div class="icon">&#128181;</div>
        <div class="num monto">${formatMonto(d.fndr.total_clp, 'CLP')}</div>
        <div class="label">Monto total CLP</div>
        <div class="sub">Acuerdos con monto registrado</div>
      </div>
      ${d.fndr.total_uf > 0 ? `
      <div class="dash-card" style="border-top-color:#8e44ad">
        <div class="icon">&#128181;</div>
        <div class="num monto" style="color:#8e44ad">${formatMonto(d.fndr.total_uf, 'UF')}</div>
        <div class="label">Monto en UF</div>
        <div class="sub">Acuerdos en unidades de fomento</div>
      </div>
      ` : ''}
      <div class="dash-card" style="border-top-color:#6c3483">
        <div class="icon">&#127970;</div>
        <div class="num" style="color:#6c3483">${d.comisiones}</div>
        <div class="label">Comisiones</div>
        <div class="sub"><a href="/comisiones.html" style="color:var(--primary-light)">Ver comisiones</a></div>
      </div>
    </div>

    <h3 class="section-title">Actividad por a&ntilde;o</h3>
    <div class="anio-grid">
      ${d.porAnio.map(a => `
        <div class="anio-card">
          <div class="year">${a.anio}</div>
          <div class="details">
            <strong>${a.sesiones} sesiones</strong>
            <span>${Number(a.acuerdos)} acuerdos aprobados</span>
          </div>
        </div>
      `).join('')}
    </div>

    <h3 class="section-title">&Uacute;ltimas sesiones</h3>
    <div class="ultimas-list">
      ${d.ultimasSesiones.map(s => `
        <div class="ultima-item">
          <div class="info">
            <h4>
              <a href="/sesion.html?id=${s.id}">
                Sesi&oacute;n ${s.tipo_sesion === 'extraordinaria' ? 'Extraordinaria' : 'Ordinaria'} N&deg;${s.numero_sesion}
              </a>
            </h4>
            <div class="date">${formatFecha(s.fecha)}</div>
            ${s.resumen_general ? `<div class="resumen">${esc(truncar(s.resumen_general, 200))}</div>` : ''}
          </div>
          <div class="acuerdos-count">
            <div class="n">${s.total_acuerdos}</div>
            <div class="l">acuerdos</div>
          </div>
        </div>
      `).join('')}
    </div>

    <div class="accesos">
      <a href="/sesiones.html" class="acceso-btn"><span class="ico">&#128218;</span>Ver todas las sesiones</a>
      <a href="/acuerdos.html" class="acceso-btn"><span class="ico">&#9989;</span>Consultar acuerdos</a>
      <a href="/comisiones.html" class="acceso-btn"><span class="ico">&#127970;</span>Comisiones</a>
      <a href="/asistencia.html" class="acceso-btn"><span class="ico">&#128101;</span>Asistencia</a>
      <a href="/varios.html" class="acceso-btn"><span class="ico">&#128172;</span>Temas varios</a>
    </div>
  `;
}

init().catch(err => {
  $('#dashboard').innerHTML = `<p style="color:var(--danger)">Error cargando dashboard: ${err.message}</p>`;
});
