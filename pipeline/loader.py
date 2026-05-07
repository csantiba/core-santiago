"""Carga datos estructurados en PostgreSQL."""
import logging

import psycopg2

from . import config

logger = logging.getLogger(__name__)


def _get_connection():
    return psycopg2.connect(
        host=config.DB_HOST, port=config.DB_PORT,
        database=config.DB_NAME, user=config.DB_USER,
        password=config.DB_PASSWORD
    )


def _get_cat_id(cur, nombre):
    cur.execute("SELECT id FROM categorias WHERE nombre = %s", (nombre,))
    row = cur.fetchone()
    if row:
        return row[0]
    cur.execute("SELECT id FROM categorias WHERE unaccent(nombre) ILIKE unaccent(%s)", (nombre,))
    row = cur.fetchone()
    if row:
        return row[0]
    logger.warning(f'Categoria no encontrada: {nombre}')
    return None


def _get_consejero_id(cur, nombre):
    if not nombre:
        return None
    cur.execute("SELECT id FROM consejeros WHERE nombre_completo = %s", (nombre,))
    row = cur.fetchone()
    if row:
        return row[0]
    cur.execute("SELECT id FROM consejeros WHERE unaccent(nombre_completo) ILIKE unaccent(%s)", (nombre,))
    row = cur.fetchone()
    if row:
        return row[0]
    apellido = nombre.split()[-1]
    cur.execute("SELECT id FROM consejeros WHERE unaccent(nombre_completo) ILIKE unaccent(%s)", (f'%{apellido}%',))
    row = cur.fetchone()
    if row:
        return row[0]
    logger.warning(f'Consejero no encontrado: {nombre}')
    return None


def _normalizar_comision(nombre):
    """Quita prefijos comunes para que 'Comision de X' y 'X' matcheen como la misma."""
    import re
    n = nombre.strip()
    # Quitar prefijos: "Comision de ", "Comisión de ", "Subcomision ", "Sub-comision "
    n = re.sub(r'^(sub-?comisi[oó]n|comisi[oó]n)\s+(de\s+|del\s+|de\s+la\s+)?', '', n, flags=re.IGNORECASE)
    return n.strip()


def _get_or_create_comision(cur, nombre, presidente_id=None):
    if not nombre:
        return None
    nombre_norm = nombre.strip()
    nombre_clave = _normalizar_comision(nombre_norm)

    # Buscar match exacto primero
    cur.execute("SELECT id, nombre FROM comisiones WHERE unaccent(nombre) ILIKE unaccent(%s)", (nombre_norm,))
    row = cur.fetchone()
    if row:
        if presidente_id:
            cur.execute("UPDATE comisiones SET presidente_id = COALESCE(presidente_id, %s) WHERE id = %s",
                        (presidente_id, row[0]))
        return row[0]

    # Match por nombre normalizado contra nombres existentes (también normalizados)
    cur.execute("SELECT id, nombre FROM comisiones")
    for cid, cnombre in cur.fetchall():
        if _normalizar_comision(cnombre).lower() == nombre_clave.lower():
            if presidente_id:
                cur.execute("UPDATE comisiones SET presidente_id = COALESCE(presidente_id, %s) WHERE id = %s",
                            (presidente_id, cid))
            logger.info(f'Comision matcheada por nombre normalizado: "{nombre_norm}" -> "{cnombre}" (id={cid})')
            return cid

    # Crear nueva, guardando el nombre normalizado (sin prefijos)
    cur.execute(
        "INSERT INTO comisiones (nombre, presidente_id) VALUES (%s, %s) RETURNING id",
        (nombre_clave, presidente_id)
    )
    new_id = cur.fetchone()[0]
    logger.info(f'Nueva comision creada: {nombre_clave} (id={new_id})')
    return new_id


def load_to_db(data, pdf_filename=None, txt_filename=None):
    """Carga los datos extraidos en la BD. Retorna sesion_id o None."""
    conn = _get_connection()
    cur = conn.cursor()

    try:
        sesion = data['sesion']

        cur.execute(
            "SELECT id FROM sesiones WHERE numero_sesion = %s AND tipo_sesion = %s AND fecha = %s",
            (sesion['numero_sesion'], sesion['tipo_sesion'], sesion['fecha'])
        )
        if cur.fetchone():
            logger.info(f'Sesion {sesion["tipo_sesion"]} N°{sesion["numero_sesion"]} ({sesion["fecha"]}) ya existe, omitiendo.')
            return None

        cur.execute("""
            INSERT INTO sesiones (numero_sesion, tipo_sesion, fecha, hora_inicio, hora_termino,
                                  presidente, secretario_ejecutivo, archivo_pdf, archivo_texto, resumen_general)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id
        """, (
            sesion['numero_sesion'],
            sesion['tipo_sesion'],
            sesion['fecha'],
            sesion.get('hora_inicio'),
            sesion.get('hora_termino'),
            config.PRESIDENTE,
            config.SECRETARIO_EJECUTIVO,
            pdf_filename,
            txt_filename,
            sesion.get('resumen_general', '')
        ))
        sesion_id = cur.fetchone()[0]
        logger.info(f'Sesion insertada con id={sesion_id}')

        # Asistencia
        asist_count = 0
        for a in data.get('asistencia', []):
            cid = _get_consejero_id(cur, a['nombre'])
            if cid:
                cur.execute(
                    "INSERT INTO asistencia (sesion_id, consejero_id, estado) VALUES (%s, %s, %s) "
                    "ON CONFLICT (sesion_id, consejero_id) DO NOTHING",
                    (sesion_id, cid, a.get('estado', 'presente'))
                )
                asist_count += 1

        # Temas, acuerdos, intervenciones
        tema_count = 0
        acuerdo_count = 0

        for tema_data in data.get('temas', []):
            presentado_por_nombre = tema_data.get('presentado_por')
            presentado_por_id = _get_consejero_id(cur, presentado_por_nombre) if presentado_por_nombre else None

            comision_nombre = tema_data.get('comision')
            comision_id = _get_or_create_comision(cur, comision_nombre, presentado_por_id) if comision_nombre else None

            cur.execute("""
                INSERT INTO temas (sesion_id, numero_tabla, seccion, titulo, resumen,
                                   comision_id, presentado_por)
                VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING id
            """, (
                sesion_id,
                tema_data.get('numero_tabla'),
                tema_data.get('seccion', 'tabla'),
                tema_data.get('titulo', ''),
                tema_data.get('resumen', ''),
                comision_id,
                presentado_por_id
            ))
            tema_id = cur.fetchone()[0]
            tema_count += 1

            # Categorias
            for cat_nombre in tema_data.get('categorias', []):
                cat_id = _get_cat_id(cur, cat_nombre)
                if cat_id:
                    cur.execute(
                        "INSERT INTO temas_categorias (tema_id, categoria_id) VALUES (%s, %s) "
                        "ON CONFLICT DO NOTHING",
                        (tema_id, cat_id)
                    )

            # Acuerdo
            acuerdo = tema_data.get('acuerdo')
            if acuerdo and acuerdo.get('texto_acuerdo'):
                cur.execute("""
                    INSERT INTO acuerdos (tema_id, numero_acuerdo, sesion_id, texto_acuerdo,
                                          resultado_votacion, votos_favor, votos_contra,
                                          abstenciones, inhabilidades,
                                          monto_involucrado, moneda,
                                          beneficiario, rut_beneficiario, fuente_financiamiento,
                                          cumplimiento_inmediato)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    RETURNING id
                """, (
                    tema_id,
                    acuerdo.get('numero_acuerdo'),
                    sesion_id,
                    acuerdo.get('texto_acuerdo', ''),
                    acuerdo.get('resultado_votacion'),
                    acuerdo.get('votos_favor'),
                    acuerdo.get('votos_contra'),
                    acuerdo.get('abstenciones'),
                    acuerdo.get('inhabilidades'),
                    acuerdo.get('monto_involucrado'),
                    acuerdo.get('moneda'),
                    acuerdo.get('beneficiario'),
                    acuerdo.get('rut_beneficiario'),
                    acuerdo.get('fuente_financiamiento'),
                    acuerdo.get('cumplimiento_inmediato', False)
                ))
                acuerdo_id = cur.fetchone()[0]
                acuerdo_count += 1

                # Votos detallados (solo registramos los no-favor para no inflar)
                for v in acuerdo.get('votos_detalle', []) or []:
                    cid = _get_consejero_id(cur, v.get('consejero'))
                    if cid and v.get('voto'):
                        cur.execute(
                            "INSERT INTO votos_consejero (acuerdo_id, consejero_id, voto) "
                            "VALUES (%s, %s, %s) ON CONFLICT DO NOTHING",
                            (acuerdo_id, cid, v['voto'])
                        )

            # Intervenciones
            for orden, interv in enumerate(tema_data.get('intervenciones', []) or [], 1):
                cid = _get_consejero_id(cur, interv.get('consejero'))
                if cid:
                    cur.execute("""
                        INSERT INTO intervenciones (tema_id, consejero_id, resumen_intervencion, orden)
                        VALUES (%s, %s, %s, %s)
                    """, (tema_id, cid, interv.get('resumen', ''), orden))

        conn.commit()
        logger.info(f'Carga completada: {asist_count} asistencia, {tema_count} temas, {acuerdo_count} acuerdos')
        return sesion_id

    except Exception as e:
        conn.rollback()
        logger.error(f'Error cargando datos: {e}')
        raise
    finally:
        cur.close()
        conn.close()
