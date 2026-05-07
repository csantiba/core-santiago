import { api, formatFecha, formatHora, formatMonto, badgeVotacion, badgeTipo, esc, $ } from './app.js';

async function init() {
  const id = new URLSearchParams(location.search).get('id');
  if (!id) { $('#contenido').innerHTML = '<p>Sesi&oacute;n no especificada.</p>'; return; }

  const data = await api(`sesiones/${id}`);
  const { sesion: s, asistencia, temas } = data;

  document.title = `Sesión N°${s.numero_sesion} - CORE Metropolitano`;

  const secciones = { cuenta: [], tabla: [], comision: [], varios: [] };
  for (const t of temas) {
    (secciones[t.seccion] || (secciones.tabla)).push(t);
  }

  const year = new Date(s.fecha).getUTCFullYear();
  const pdfHref = s.archivo_pdf
    ? `/actas/${year}/${encodeURIComponent(s.archivo_pdf)}`
    : null;

  $('#contenido').innerHTML = `
    <div class="sesion-header">
      <h2>Sesi&oacute;n ${s.tipo_sesion === 'extraordinaria' ? 'Extraordinaria' : 'Ordinaria'} N&deg;${s.numero_sesion} ${badgeTipo(s.tipo_sesion)}</h2>
      <div class="meta" style="margin-top:0.5rem; display:flex; gap:1rem; flex-wrap:wrap; color:var(--text-light); font-size:0.9rem">
        <span>${formatFecha(s.fecha)}</span>
        ${s.hora_inicio ? `<span>${formatHora(s.hora_inicio)}${s.hora_termino ? ' - ' + formatHora(s.hora_termino) : ''} hrs</span>` : ''}
        <span>Preside: ${esc(s.presidente || '')}</span>
        <span>Secretario Ejecutivo: ${esc(s.secretario_ejecutivo || '')}</span>
      </div>
      ${s.resumen_general ? `<div class="resumen-general">${esc(s.resumen_general)}</div>` : ''}
    </div>

    <div class="asistencia">
      <div>
        <h4>Presentes (${(asistencia.presente||[]).length})</h4>
        <ul>${(asistencia.presente||[]).map(n => `<li><span class="badge badge-presente">P</span> ${esc(n)}</li>`).join('')}</ul>
      </div>
      ${(asistencia.licencia||[]).length ? `
      <div>
        <h4>Con licencia (${asistencia.licencia.length})</h4>
        <ul>${asistencia.licencia.map(n => `<li><span class="badge badge-licencia">L</span> ${esc(n)}</li>`).join('')}</ul>
      </div>` : ''}
      ${(asistencia.ausente||[]).length ? `
      <div>
        <h4>Ausentes (${asistencia.ausente.length})</h4>
        <ul>${asistencia.ausente.map(n => `<li><span class="badge badge-ausente">A</span> ${esc(n)}</li>`).join('')}</ul>
      </div>` : ''}
      ${(asistencia.inhabilidad||[]).length ? `
      <div>
        <h4>Inhabilidad (${asistencia.inhabilidad.length})</h4>
        <ul>${asistencia.inhabilidad.map(n => `<li><span class="badge badge-inhabilidad">I</span> ${esc(n)}</li>`).join('')}</ul>
      </div>` : ''}
    </div>

    ${renderSeccion('Cuenta del Gobernador', secciones.cuenta)}
    ${renderSeccion('Informes de Comisiones', secciones.comision)}
    ${renderSeccion('Tabla', secciones.tabla)}
    ${renderSeccion('Varios', secciones.varios)}

    ${pdfHref ? `<div style="margin-top:2rem; text-align:center">
      <a href="${pdfHref}" target="_blank" class="btn" style="display:inline-flex; align-items:center; gap:0.4rem; text-decoration:none; padding:0.7rem 2rem; font-size:1rem">
        &#128196; Descargar acta en PDF
      </a>
    </div>` : ''}
  `;

  document.querySelectorAll('.tema-header').forEach(h => {
    h.addEventListener('click', () => h.parentElement.classList.toggle('open'));
  });
}

function renderSeccion(titulo, temas) {
  if (!temas.length) return '';
  return `
    <h3 style="margin:1.5rem 0 0.8rem; color:var(--primary); font-size:1.1rem">${titulo}</h3>
    ${temas.map(renderTema).join('')}
  `;
}

function renderTema(t) {
  const label = t.numero_tabla ? `${t.seccion} ${t.numero_tabla}` : t.seccion;
  return `
    <div class="tema">
      <div class="tema-header">
        <span class="seccion-label">${esc(label)}</span>
        <h4>${esc(t.titulo)}</h4>
        <span class="arrow">&#9654;</span>
      </div>
      <div class="tema-body">
        ${(t.categorias || t.comision_nombre || t.presentado_por_nombre) ? `
          <div class="cats">
            ${t.comision_nombre ? `<span class="badge badge-comision">${esc(t.comision_nombre)}</span>` : ''}
            ${(t.categorias || []).filter(Boolean).map(c => `<span class="badge badge-cat">${esc(c)}</span>`).join('')}
          </div>` : ''}
        ${t.presentado_por_nombre ? `<div class="presentado">Presenta: <strong>${esc(t.presentado_por_nombre)}</strong></div>` : ''}
        ${t.resumen ? `<p class="resumen">${esc(t.resumen)}</p>` : ''}
        ${(t.acuerdos || []).map(renderAcuerdo).join('')}
        ${(t.intervenciones || []).length ? '<h5 style="margin-top:1rem;font-size:0.85rem;color:var(--text-light)">Intervenciones</h5>' : ''}
        ${(t.intervenciones || []).map(renderIntervencion).join('')}
      </div>
    </div>
  `;
}

function renderAcuerdo(a) {
  const votos = [];
  if (a.votos_favor != null) votos.push(`<span style="background:#d5f5e3;color:#1e8449">A favor: ${a.votos_favor}</span>`);
  if (a.votos_contra) votos.push(`<span style="background:#fadbd8;color:#c0392b">En contra: ${a.votos_contra}</span>`);
  if (a.abstenciones) votos.push(`<span style="background:#fef9e7;color:#b7950b">Abstenciones: ${a.abstenciones}</span>`);
  if (a.inhabilidades) votos.push(`<span style="background:#eaf2f8;color:var(--primary)">Inhabilidades: ${a.inhabilidades}</span>`);

  return `
    <div class="acuerdo-box">
      <h5>${a.numero_acuerdo ? 'Acuerdo N&deg;' + a.numero_acuerdo : 'Acuerdo'} ${badgeVotacion(a.resultado_votacion)}</h5>
      <p>${esc(a.texto_acuerdo)}</p>
      ${votos.length ? `<div class="votos-grid">${votos.join('')}</div>` : ''}
      <div class="acuerdo-meta">
        ${a.monto_involucrado ? `<span>Monto: <strong>${formatMonto(a.monto_involucrado, a.moneda)}</strong></span>` : ''}
        ${a.fuente_financiamiento ? `<span>Fuente: ${esc(a.fuente_financiamiento)}</span>` : ''}
        ${a.beneficiario ? `<span>Beneficiario: ${esc(a.beneficiario)}</span>` : ''}
        ${a.rut_beneficiario ? `<span>RUT: ${esc(a.rut_beneficiario)}</span>` : ''}
        ${a.cumplimiento_inmediato ? '<span class="badge badge-unanimidad">Cumplimiento inmediato</span>' : ''}
      </div>
    </div>
  `;
}

function renderIntervencion(i) {
  return `<div class="intervencion"><strong>${esc(i.nombre_completo)}:</strong> ${esc(i.resumen_intervencion)}</div>`;
}

init().catch(err => {
  $('#contenido').innerHTML = `<p style="color:var(--danger)">Error: ${err.message}</p>`;
});
