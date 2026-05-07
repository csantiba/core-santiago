import { api, formatFecha, formatHora, esc, $ } from './app.js';

let totalSesiones = 0;

async function init() {
  const data = await api('consejeros');
  const consejeros = data.consejeros || [];
  totalSesiones = data.total_sesiones || 0;

  renderStats(consejeros);
  renderGrafico(consejeros);

  const hash = location.hash.replace('#', '');
  if (hash) await mostrarDetalle(hash);
}

function renderStats(consejeros) {
  if (!totalSesiones) {
    $('#stats').innerHTML = '<div class="stat-box"><div class="num">0</div><div class="label">Sesiones registradas</div></div>';
    return;
  }
  const promedio = consejeros.reduce((s, c) => s + Number(c.sesiones_presente), 0) / consejeros.length;
  const pctPromedio = Math.round((promedio / totalSesiones) * 100);
  const perfecta = consejeros.filter(c => Number(c.sesiones_presente) === totalSesiones).length;

  $('#stats').innerHTML = `
    <div class="stat-box"><div class="num">${totalSesiones}</div><div class="label">Sesiones registradas</div></div>
    <div class="stat-box"><div class="num">${consejeros.length}</div><div class="label">Consejeros(as)</div></div>
    <div class="stat-box"><div class="num">${pctPromedio}%</div><div class="label">Asistencia promedio</div></div>
    <div class="stat-box"><div class="num">${perfecta}</div><div class="label">Asistencia perfecta</div></div>
  `;
}

function renderGrafico(consejeros) {
  if (!totalSesiones) {
    $('#grafico').innerHTML = '<p style="color:var(--text-light); text-align:center; padding:2rem">A&uacute;n no hay datos de asistencia.</p>';
    return;
  }

  const datos = consejeros.map(c => ({
    id: c.id,
    nombre: c.nombre_completo,
    es_presidente: c.es_presidente,
    presente: Number(c.sesiones_presente),
    ausente: Number(c.sesiones_ausente),
    licencia: Number(c.sesiones_licencia),
    pct: Math.round((Number(c.sesiones_presente) / totalSesiones) * 100),
  })).sort((a, b) => b.pct - a.pct);

  const barHeight = 36;
  const labelWidth = 240;
  const chartPadding = 20;
  const barGap = 6;
  const canvasWidth = 980;
  const canvasHeight = chartPadding * 2 + datos.length * (barHeight + barGap) + 30;

  const container = $('#grafico');
  container.innerHTML = '';

  const canvas = document.createElement('canvas');
  canvas.width = canvasWidth;
  canvas.height = canvasHeight;
  canvas.style.width = '100%';
  canvas.style.maxWidth = canvasWidth + 'px';
  canvas.style.height = 'auto';
  canvas.style.cursor = 'pointer';
  canvas.style.background = 'white';
  canvas.style.borderRadius = '8px';
  canvas.style.boxShadow = '0 2px 8px rgba(0,0,0,0.08)';
  container.appendChild(canvas);

  const ctx = canvas.getContext('2d');
  const maxBarWidth = canvasWidth - labelWidth - chartPadding * 2 - 100;
  const rects = [];

  datos.forEach((d, i) => {
    const y = chartPadding + i * (barHeight + barGap);
    const presW = (d.presente / totalSesiones) * maxBarWidth;
    const ausW = (d.ausente / totalSesiones) * maxBarWidth;
    const licW = (d.licencia / totalSesiones) * maxBarWidth;

    ctx.fillStyle = d.es_presidente ? '#0e3a5f' : '#1a5276';
    ctx.font = `${d.es_presidente ? '700' : '600'} 12px -apple-system, "Segoe UI", Roboto, sans-serif`;
    ctx.textAlign = 'right';
    ctx.textBaseline = 'middle';
    const label = d.es_presidente ? `★ ${d.nombre}` : d.nombre;
    ctx.fillText(label, labelWidth - 10, y + barHeight / 2);

    const barX = labelWidth;
    let cx = barX;

    ctx.fillStyle = '#27ae60';
    roundedRect(ctx, cx, y + 4, presW, barHeight - 8, 3);
    ctx.fill();
    cx += presW;

    if (d.licencia) {
      ctx.fillStyle = '#3498db';
      ctx.fillRect(cx, y + 4, licW, barHeight - 8);
      cx += licW;
    }
    if (d.ausente) {
      ctx.fillStyle = '#f39c12';
      roundedRect(ctx, cx, y + 4, ausW, barHeight - 8, 3);
      ctx.fill();
      cx += ausW;
    }

    ctx.fillStyle = '#2c3e50';
    ctx.font = '700 13px -apple-system, "Segoe UI", Roboto, sans-serif';
    ctx.textAlign = 'left';
    ctx.fillText(`${d.pct}%`, cx + 10, y + barHeight / 2 - 6);
    ctx.fillStyle = '#7f8c8d';
    ctx.font = '400 10px -apple-system, "Segoe UI", Roboto, sans-serif';
    ctx.fillText(`${d.presente}/${totalSesiones}`, cx + 10, y + barHeight / 2 + 8);

    rects.push({ x: 0, y, w: canvasWidth, h: barHeight + barGap, id: d.id });
  });

  // Leyenda
  const ly = canvasHeight - 8;
  ctx.font = '400 11px -apple-system, "Segoe UI", Roboto, sans-serif';
  ctx.textAlign = 'left';
  let lx = labelWidth;
  const legend = [['#27ae60', 'Presente'], ['#3498db', 'Licencia'], ['#f39c12', 'Ausente']];
  for (const [color, text] of legend) {
    ctx.fillStyle = color;
    ctx.fillRect(lx, ly - 12, 12, 12);
    ctx.fillStyle = '#2c3e50';
    ctx.fillText(text, lx + 16, ly - 2);
    lx += 90;
  }

  canvas.addEventListener('click', (e) => {
    const rect = canvas.getBoundingClientRect();
    const sx = canvas.width / rect.width;
    const sy = canvas.height / rect.height;
    const mx = (e.clientX - rect.left) * sx;
    const my = (e.clientY - rect.top) * sy;
    for (const r of rects) {
      if (mx >= r.x && mx <= r.x + r.w && my >= r.y && my <= r.y + r.h) {
        mostrarDetalle(r.id);
        break;
      }
    }
  });
}

function roundedRect(ctx, x, y, w, h, r) {
  if (w < 2 * r) r = w / 2;
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  ctx.lineTo(x + w - r, y);
  ctx.quadraticCurveTo(x + w, y, x + w, y + r);
  ctx.lineTo(x + w, y + h - r);
  ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
  ctx.lineTo(x + r, y + h);
  ctx.quadraticCurveTo(x, y + h, x, y + h - r);
  ctx.lineTo(x, y + r);
  ctx.quadraticCurveTo(x, y, x + r, y);
  ctx.closePath();
}

async function mostrarDetalle(consejeroId) {
  location.hash = consejeroId;
  const data = await api(`consejeros/${consejeroId}/asistencia`);
  const { consejero, sesiones } = data;

  const presente = sesiones.filter(s => s.estado === 'presente').length;
  const ausente = sesiones.filter(s => s.estado === 'ausente').length;
  const licencia = sesiones.filter(s => s.estado === 'licencia').length;
  const total = sesiones.filter(s => s.estado !== 'sin_registro').length;
  const pct = total ? Math.round((presente / total) * 100) : 0;

  const el = $('#detalle');
  el.style.display = 'block';
  el.scrollIntoView({ behavior: 'smooth', block: 'start' });

  el.innerHTML = `
    <div style="margin-top:2rem">
      <a href="/asistencia.html" class="back" onclick="document.getElementById('detalle').style.display='none'; location.hash=''; return false;">&larr; Volver al resumen</a>
      <div class="sesion-header">
        <h2>${consejero.es_presidente ? '★ ' : ''}${esc(consejero.nombre_completo)}</h2>
        <div class="meta" style="margin-top:0.5rem">
          <span>Asistencia: <strong>${presente} de ${total} sesiones (${pct}%)</strong></span>
          ${ausente ? `<span>Ausencias: <strong>${ausente}</strong></span>` : ''}
          ${licencia ? `<span>Con licencia: <strong>${licencia}</strong></span>` : ''}
        </div>
        <div style="margin-top:1rem; height:20px; background:#ecf0f1; border-radius:10px; overflow:hidden">
          <div style="height:100%; width:${pct}%; background: ${pct === 100 ? '#27ae60' : pct >= 75 ? '#2ecc71' : pct >= 50 ? '#f39c12' : '#e74c3c'}; border-radius:10px; transition:width 0.5s"></div>
        </div>
      </div>

      <table class="acuerdos-table" style="margin-top:1rem">
        <thead>
          <tr>
            <th>Sesi&oacute;n</th>
            <th>Tipo</th>
            <th>Fecha</th>
            <th>Horario</th>
            <th>Estado</th>
          </tr>
        </thead>
        <tbody>
          ${sesiones.map(s => `
            <tr>
              <td><a href="/sesion.html?id=${s.sesion_id}">N&deg;${s.numero_sesion}</a></td>
              <td>${s.tipo_sesion === 'extraordinaria' ? '<span class="badge badge-ext">Ext.</span>' : '<span class="badge badge-primary">Ord.</span>'}</td>
              <td>${formatFecha(s.fecha)}</td>
              <td>${formatHora(s.hora_inicio)}${s.hora_termino ? ' - ' + formatHora(s.hora_termino) : ''}</td>
              <td>${badgeAsistencia(s.estado)}</td>
            </tr>
          `).join('')}
        </tbody>
      </table>
    </div>
  `;
}

function badgeAsistencia(estado) {
  const map = {
    'presente': ['badge-presente', 'Presente'],
    'ausente': ['badge-ausente', 'Ausente'],
    'licencia': ['badge-licencia', 'Licencia'],
    'inhabilidad': ['badge-inhabilidad', 'Inhabilidad'],
    'sin_registro': ['badge-cat', 'Sin registro'],
  };
  const [cls, label] = map[estado] || map['sin_registro'];
  return `<span class="badge ${cls}">${label}</span>`;
}

init().catch(err => {
  $('#stats').innerHTML = `<p style="color:var(--danger)">Error: ${err.message}</p>`;
});
