import express from 'express';
import pool from './db.js';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const app = express();
const PORT = process.env.PORT || 3003;

app.use(express.json());
app.use(express.static(join(__dirname, 'public')));

// --- Servir PDFs de actas ---
app.get('/actas/:year/:file', (req, res) => {
  const { year, file } = req.params;
  if (!/^\d{4}$/.test(year)) return res.status(400).send('Año inválido');
  const filePath = join(__dirname, '..', 'sesiones', year, decodeURIComponent(file));
  res.sendFile(filePath, (err) => {
    if (err) res.status(404).send('Archivo no encontrado');
  });
});

// --- API: Dashboard / Estadísticas generales ---
app.get('/api/dashboard', async (req, res) => {
  try {
    const [sesiones, acuerdos, fndr, porAnio, porCategoria, ultimas, asistPromedio, comisiones] = await Promise.all([
      pool.query('SELECT COUNT(*) AS total FROM sesiones'),
      pool.query("SELECT COUNT(*) AS total, COUNT(*) FILTER (WHERE resultado_votacion ILIKE '%unanimidad%') AS unanimes FROM acuerdos"),
      pool.query(`
        SELECT COUNT(*) AS total,
          SUM(CASE WHEN moneda = 'CLP' THEN monto_involucrado ELSE 0 END) AS total_clp,
          SUM(CASE WHEN moneda = 'UF' THEN monto_involucrado ELSE 0 END) AS total_uf
        FROM acuerdos
        WHERE monto_involucrado IS NOT NULL AND monto_involucrado > 0
      `),
      pool.query(`
        SELECT EXTRACT(YEAR FROM s.fecha)::int AS anio,
          COUNT(DISTINCT s.id) AS sesiones,
          COUNT(a.id) AS acuerdos
        FROM sesiones s
        LEFT JOIN acuerdos a ON a.sesion_id = s.id
        GROUP BY anio ORDER BY anio
      `),
      pool.query(`
        SELECT c.nombre, COUNT(*) AS total
        FROM temas_categorias tc JOIN categorias c ON tc.categoria_id = c.id
        GROUP BY c.nombre ORDER BY total DESC LIMIT 10
      `),
      pool.query(`
        SELECT s.id, s.numero_sesion, s.tipo_sesion, s.fecha, s.resumen_general,
          (SELECT COUNT(*) FROM acuerdos a WHERE a.sesion_id = s.id) AS total_acuerdos
        FROM sesiones s ORDER BY s.fecha DESC, s.numero_sesion DESC LIMIT 5
      `),
      pool.query(`
        SELECT ROUND(AVG(pct)::numeric, 1) AS promedio FROM (
          SELECT c.id,
            COUNT(*) FILTER (WHERE a.estado = 'presente') * 100.0 / NULLIF(COUNT(*), 0) AS pct
          FROM consejeros c
          LEFT JOIN asistencia a ON a.consejero_id = c.id
          WHERE c.activo = true
          GROUP BY c.id
        ) sub
      `),
      pool.query('SELECT COUNT(*) AS total FROM comisiones'),
    ]);

    res.json({
      sesiones: Number(sesiones.rows[0].total),
      asistenciaPromedio: Number(asistPromedio.rows[0].promedio || 0),
      acuerdos: {
        total: Number(acuerdos.rows[0].total),
        unanimes: Number(acuerdos.rows[0].unanimes),
      },
      fndr: {
        total: Number(fndr.rows[0].total),
        total_clp: Number(fndr.rows[0].total_clp || 0),
        total_uf: Number(fndr.rows[0].total_uf || 0),
      },
      comisiones: Number(comisiones.rows[0].total),
      porAnio: porAnio.rows,
      porCategoria: porCategoria.rows,
      ultimasSesiones: ultimas.rows,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- API: Todas las sesiones ---
app.get('/api/sesiones', async (req, res) => {
  try {
    const { rows } = await pool.query(`
      SELECT s.*,
        (SELECT COUNT(*) FROM temas t WHERE t.sesion_id = s.id) AS total_temas,
        (SELECT COUNT(*) FROM acuerdos a WHERE a.sesion_id = s.id) AS total_acuerdos
      FROM sesiones s ORDER BY s.fecha DESC, s.numero_sesion DESC
    `);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- API: Detalle de una sesión ---
app.get('/api/sesiones/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const [sesionRes, asistRes, temasRes, acuerdosRes, intervRes] = await Promise.all([
      pool.query('SELECT * FROM sesiones WHERE id = $1', [id]),
      pool.query(`
        SELECT c.nombre_completo, a.estado
        FROM asistencia a JOIN consejeros c ON a.consejero_id = c.id
        WHERE a.sesion_id = $1 ORDER BY c.nombre_completo
      `, [id]),
      pool.query(`
        SELECT t.*, com.nombre AS comision_nombre,
          c.nombre_completo AS presentado_por_nombre,
          array_agg(DISTINCT cat.nombre) FILTER (WHERE cat.nombre IS NOT NULL) AS categorias
        FROM temas t
        LEFT JOIN comisiones com ON t.comision_id = com.id
        LEFT JOIN consejeros c ON t.presentado_por = c.id
        LEFT JOIN temas_categorias tc ON t.id = tc.tema_id
        LEFT JOIN categorias cat ON tc.categoria_id = cat.id
        WHERE t.sesion_id = $1
        GROUP BY t.id, com.nombre, c.nombre_completo
        ORDER BY t.seccion, t.numero_tabla NULLS LAST, t.id
      `, [id]),
      pool.query('SELECT * FROM acuerdos WHERE sesion_id = $1 ORDER BY numero_acuerdo NULLS LAST, id', [id]),
      pool.query(`
        SELECT i.*, c.nombre_completo
        FROM intervenciones i JOIN consejeros c ON i.consejero_id = c.id
        WHERE i.tema_id IN (SELECT id FROM temas WHERE sesion_id = $1)
        ORDER BY i.tema_id, i.orden
      `, [id]),
    ]);

    if (sesionRes.rows.length === 0) return res.status(404).json({ error: 'Sesión no encontrada' });

    const asistencia = { presente: [], ausente: [], licencia: [], inhabilidad: [] };
    for (const r of asistRes.rows) {
      (asistencia[r.estado] || (asistencia[r.estado] = [])).push(r.nombre_completo);
    }

    const acuerdosPorTema = {};
    for (const a of acuerdosRes.rows) {
      (acuerdosPorTema[a.tema_id] || (acuerdosPorTema[a.tema_id] = [])).push(a);
    }

    const intervPorTema = {};
    for (const i of intervRes.rows) {
      (intervPorTema[i.tema_id] || (intervPorTema[i.tema_id] = [])).push(i);
    }

    const temas = temasRes.rows.map(t => ({
      ...t,
      acuerdos: acuerdosPorTema[t.id] || [],
      intervenciones: intervPorTema[t.id] || [],
    }));

    res.json({ sesion: sesionRes.rows[0], asistencia, temas });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- API: Todos los acuerdos ---
app.get('/api/acuerdos', async (req, res) => {
  try {
    const { q, fecha_desde, fecha_hasta, categoria_id, fuente } = req.query;
    const conditions = [];
    const params = [];
    let idx = 1;

    if (q) {
      conditions.push(`(
        to_tsvector('spanish', a.texto_acuerdo) @@ plainto_tsquery('spanish', $${idx})
        OR a.texto_acuerdo ILIKE '%' || $${idx} || '%'
        OR t.titulo ILIKE '%' || $${idx} || '%'
      )`);
      params.push(q);
      idx++;
    }
    if (fecha_desde) { conditions.push(`s.fecha >= $${idx}`); params.push(fecha_desde); idx++; }
    if (fecha_hasta) { conditions.push(`s.fecha <= $${idx}`); params.push(fecha_hasta); idx++; }
    if (categoria_id) {
      conditions.push(`t.id IN (SELECT tema_id FROM temas_categorias WHERE categoria_id = $${idx})`);
      params.push(categoria_id);
      idx++;
    }
    if (fuente) {
      conditions.push(`a.fuente_financiamiento ILIKE $${idx}`);
      params.push('%' + fuente + '%');
      idx++;
    }

    const where = conditions.length ? 'WHERE ' + conditions.join(' AND ') : '';

    const { rows } = await pool.query(`
      SELECT a.*, s.numero_sesion, s.fecha, s.tipo_sesion, t.titulo AS titulo_tema
      FROM acuerdos a
      JOIN sesiones s ON a.sesion_id = s.id
      JOIN temas t ON a.tema_id = t.id
      ${where}
      ORDER BY s.fecha DESC, a.numero_acuerdo DESC NULLS LAST
    `, params);

    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- API: Categorías ---
app.get('/api/categorias', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM categorias ORDER BY nombre');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- API: Comisiones ---
app.get('/api/comisiones', async (req, res) => {
  try {
    const { rows } = await pool.query(`
      SELECT com.id, com.nombre, com.descripcion,
        c.nombre_completo AS presidente,
        (SELECT COUNT(*) FROM temas t WHERE t.comision_id = com.id) AS total_temas,
        (SELECT COUNT(DISTINCT t.sesion_id) FROM temas t WHERE t.comision_id = com.id) AS total_sesiones
      FROM comisiones com
      LEFT JOIN consejeros c ON com.presidente_id = c.id
      ORDER BY com.nombre
    `);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/comisiones/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const com = await pool.query(`
      SELECT com.*, c.nombre_completo AS presidente
      FROM comisiones com LEFT JOIN consejeros c ON com.presidente_id = c.id
      WHERE com.id = $1
    `, [id]);
    if (!com.rows[0]) return res.status(404).json({ error: 'Comisión no encontrada' });

    const temas = await pool.query(`
      SELECT t.*, s.numero_sesion, s.tipo_sesion, s.fecha,
        c.nombre_completo AS presentado_por_nombre,
        array_agg(DISTINCT cat.nombre) FILTER (WHERE cat.nombre IS NOT NULL) AS categorias
      FROM temas t
      JOIN sesiones s ON t.sesion_id = s.id
      LEFT JOIN consejeros c ON t.presentado_por = c.id
      LEFT JOIN temas_categorias tc ON t.id = tc.tema_id
      LEFT JOIN categorias cat ON tc.categoria_id = cat.id
      WHERE t.comision_id = $1
      GROUP BY t.id, s.numero_sesion, s.tipo_sesion, s.fecha, c.nombre_completo
      ORDER BY s.fecha DESC, t.id
    `, [id]);

    res.json({ comision: com.rows[0], temas: temas.rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- API: Búsqueda general ---
app.get('/api/buscar', async (req, res) => {
  try {
    const { q, categoria_id, fecha_desde, fecha_hasta } = req.query;
    if (!q && !categoria_id && !fecha_desde) return res.json([]);

    const conditions = [];
    const params = [];
    let idx = 1;

    if (q) {
      conditions.push(`(
        to_tsvector('spanish', t.titulo) @@ plainto_tsquery('spanish', $${idx})
        OR to_tsvector('spanish', coalesce(t.resumen,'')) @@ plainto_tsquery('spanish', $${idx})
        OR t.titulo ILIKE '%' || $${idx} || '%'
        OR t.resumen ILIKE '%' || $${idx} || '%'
      )`);
      params.push(q);
      idx++;
    }
    if (categoria_id) {
      conditions.push(`t.id IN (SELECT tema_id FROM temas_categorias WHERE categoria_id = $${idx})`);
      params.push(categoria_id);
      idx++;
    }
    if (fecha_desde) { conditions.push(`s.fecha >= $${idx}`); params.push(fecha_desde); idx++; }
    if (fecha_hasta) { conditions.push(`s.fecha <= $${idx}`); params.push(fecha_hasta); idx++; }

    const where = conditions.length ? 'WHERE ' + conditions.join(' AND ') : '';

    const { rows } = await pool.query(`
      SELECT t.*, s.numero_sesion, s.fecha, s.tipo_sesion, s.id AS sesion_id,
        com.nombre AS comision_nombre,
        array_agg(DISTINCT cat.nombre) FILTER (WHERE cat.nombre IS NOT NULL) AS categorias
      FROM temas t
      JOIN sesiones s ON t.sesion_id = s.id
      LEFT JOIN comisiones com ON t.comision_id = com.id
      LEFT JOIN temas_categorias tc ON t.id = tc.tema_id
      LEFT JOIN categorias cat ON tc.categoria_id = cat.id
      ${where}
      GROUP BY t.id, s.numero_sesion, s.fecha, s.tipo_sesion, s.id, com.nombre
      ORDER BY s.fecha DESC, t.id
    `, params);

    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- API: Consejeros ---
app.get('/api/consejeros', async (req, res) => {
  try {
    const totalSesiones = (await pool.query('SELECT COUNT(*) FROM sesiones')).rows[0].count;
    const { rows } = await pool.query(`
      SELECT c.id, c.nombre_completo, c.es_presidente,
        (SELECT COUNT(*) FROM asistencia a WHERE a.consejero_id = c.id AND a.estado = 'presente') AS sesiones_presente,
        (SELECT COUNT(*) FROM asistencia a WHERE a.consejero_id = c.id AND a.estado = 'ausente') AS sesiones_ausente,
        (SELECT COUNT(*) FROM asistencia a WHERE a.consejero_id = c.id AND a.estado = 'licencia') AS sesiones_licencia,
        (SELECT COUNT(*) FROM asistencia a WHERE a.consejero_id = c.id) AS sesiones_registradas
      FROM consejeros c WHERE c.activo = true ORDER BY c.es_presidente DESC, c.nombre_completo
    `);
    res.json({ consejeros: rows, total_sesiones: Number(totalSesiones) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/consejeros/:id/asistencia', async (req, res) => {
  try {
    const { id } = req.params;
    const consejero = (await pool.query('SELECT * FROM consejeros WHERE id = $1', [id])).rows[0];
    if (!consejero) return res.status(404).json({ error: 'Consejero no encontrado' });

    const { rows } = await pool.query(`
      SELECT s.id AS sesion_id, s.numero_sesion, s.tipo_sesion, s.fecha,
        s.hora_inicio, s.hora_termino,
        COALESCE(a.estado, 'sin_registro') AS estado
      FROM sesiones s
      LEFT JOIN asistencia a ON a.sesion_id = s.id AND a.consejero_id = $1
      ORDER BY s.fecha
    `, [id]);

    res.json({ consejero, sesiones: rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- API: Varios (temas planteados libremente) ---
app.get('/api/varios', async (req, res) => {
  try {
    const { consejero_id, q, fecha_desde, fecha_hasta } = req.query;
    const conditions = ["t.seccion = 'varios'"];
    const params = [];
    let idx = 1;

    if (consejero_id) {
      conditions.push(`t.presentado_por = $${idx}`);
      params.push(consejero_id);
      idx++;
    }
    if (q) {
      conditions.push(`(
        to_tsvector('spanish', t.titulo) @@ plainto_tsquery('spanish', $${idx})
        OR t.titulo ILIKE '%' || $${idx} || '%'
        OR t.resumen ILIKE '%' || $${idx} || '%'
      )`);
      params.push(q);
      idx++;
    }
    if (fecha_desde) { conditions.push(`s.fecha >= $${idx}`); params.push(fecha_desde); idx++; }
    if (fecha_hasta) { conditions.push(`s.fecha <= $${idx}`); params.push(fecha_hasta); idx++; }

    const where = 'WHERE ' + conditions.join(' AND ');

    const { rows } = await pool.query(`
      SELECT t.id, t.titulo, t.resumen, t.sesion_id, t.presentado_por,
        s.numero_sesion, s.fecha, s.tipo_sesion,
        c.nombre_completo AS consejero,
        array_agg(DISTINCT cat.nombre) FILTER (WHERE cat.nombre IS NOT NULL) AS categorias
      FROM temas t
      JOIN sesiones s ON t.sesion_id = s.id
      LEFT JOIN consejeros c ON t.presentado_por = c.id
      LEFT JOIN temas_categorias tc ON t.id = tc.tema_id
      LEFT JOIN categorias cat ON tc.categoria_id = cat.id
      ${where}
      GROUP BY t.id, s.numero_sesion, s.fecha, s.tipo_sesion, c.nombre_completo
      ORDER BY s.fecha DESC, t.id
    `, params);

    const porConsejero = {};
    for (const r of rows) {
      const nombre = r.consejero || 'Sin asignar';
      porConsejero[nombre] = (porConsejero[nombre] || 0) + 1;
    }

    res.json({ temas: rows, porConsejero });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- API: Suscripción ---
app.post('/api/suscripcion', async (req, res) => {
  try {
    const { nombre, email } = req.body;
    if (!nombre || !email) return res.status(400).json({ error: 'Nombre y email son requeridos' });
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return res.status(400).json({ error: 'Email no válido' });

    const token = Math.random().toString(36).slice(2) + Date.now().toString(36);

    const existe = await pool.query('SELECT id, activo FROM suscriptores WHERE email = $1', [email]);
    if (existe.rows.length > 0) {
      if (existe.rows[0].activo) return res.json({ ok: true, mensaje: 'Este correo ya se encuentra suscrito.' });
      await pool.query(
        'UPDATE suscriptores SET activo = true, nombre_completo = $1, token_baja = $2, fecha_suscripcion = NOW() WHERE email = $3',
        [nombre, token, email]
      );
      return res.json({ ok: true, mensaje: 'Suscripción reactivada exitosamente.' });
    }

    await pool.query(
      'INSERT INTO suscriptores (nombre_completo, email, token_baja) VALUES ($1, $2, $3)',
      [nombre, email, token]
    );
    res.json({ ok: true, mensaje: 'Suscripción registrada exitosamente.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/suscripcion/baja', async (req, res) => {
  try {
    const { token } = req.query;
    if (!token) return res.status(400).send('Token requerido');
    const result = await pool.query(
      'UPDATE suscriptores SET activo = false WHERE token_baja = $1 AND activo = true',
      [token]
    );
    if (result.rowCount > 0) {
      res.send('<html><body style="font-family:sans-serif;text-align:center;padding:3rem"><h2>Suscripción cancelada</h2><p>Has sido dado de baja exitosamente.</p><a href="/">Volver al inicio</a></body></html>');
    } else {
      res.send('<html><body style="font-family:sans-serif;text-align:center;padding:3rem"><h2>Token no válido</h2><p>Este enlace ya fue utilizado o no es válido.</p><a href="/">Volver al inicio</a></body></html>');
    }
  } catch (err) {
    res.status(500).send('Error al procesar la baja');
  }
});

app.listen(PORT, () => {
  console.log(`CORE Metropolitano corriendo en http://localhost:${PORT}`);
});
