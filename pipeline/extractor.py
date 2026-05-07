"""Extracción estructurada de datos de actas del CORE Metropolitano usando Claude."""
import json
import logging
from pathlib import Path

import anthropic

from . import config

logger = logging.getLogger(__name__)

SYSTEM_PROMPT = f"""Eres un experto en analisis de actas del Consejo Regional Metropolitano de Santiago (CORE Metropolitano), Chile.
Tu tarea es extraer datos estructurados de las actas de sesiones del consejo regional.

El presidente del CORE es {config.PRESIDENTE} (Gobernador Regional Metropolitano).
El Secretario Ejecutivo y Ministro de Fe es {config.SECRETARIO_EJECUTIVO}.

Los consejeros regionales del periodo (sin tildes para normalizacion) son:
{chr(10).join('- ' + c for c in config.CONSEJEROS)}

Las categorias tematicas disponibles son:
- fndr: Fondo Nacional de Desarrollo Regional, proyectos FNDR
- fril: Fondo Regional de Iniciativa Local, proyectos comunitarios
- educacion: SLEP, colegios, becas, infraestructura educativa, designaciones de comites
- salud: Hospitales, CESFAM, equipamiento medico, salud regional
- transporte: Transporte publico, vialidad, conectividad, Metro, EFE
- vivienda: Vivienda social, campamentos, urbanizacion
- seguridad: Seguridad ciudadana, camaras, equipamiento policial
- medioambiente: Areas verdes, residuos, calidad del aire, gestion hidrica
- cultura_eventos: Festivales, deportes, fiestas patrias, eventos comunales
- infraestructura: Sedes sociales, multicanchas, edificios publicos, obras viales
- urbanismo: Planes reguladores, plan regulador metropolitano, ordenamiento territorial
- legal: Convenios, oficios, recursos legales, modificaciones normativas
- presupuesto: Presupuesto regional, modificaciones presupuestarias, distribucion de fondos
- designaciones: Designacion de representantes en comites y directorios
- convenios_programacion: Convenios de programacion con ministerios y servicios
- participacion: Participacion ciudadana, organizaciones territoriales, dirigentes

Las secciones de una sesion son:
- "cuenta": cuenta del Gobernador / Presidente del consejo (informe de actividades, salidas en terreno, gestiones)
- "tabla": temas con votacion formal (acuerdos, designaciones, aprobacion de proyectos)
- "comision": informes de comisiones permanentes presentados por sus presidentes (Educacion y Cultura, Salud, Inversiones, etc.)
- "varios": temas planteados libremente por consejeros al final de la sesion (cuando aplique)

Las comisiones permanentes del CORE incluyen entre otras: "Educacion y Cultura", "Salud", "Inversiones",
"Ordenamiento Territorial y Urbanismo", "Medio Ambiente y Desarrollo Sustentable", "Transporte",
"Seguridad y Convivencia Ciudadana", "Fomento Productivo", "Hacienda", "Gobierno Interior". Si una comision
distinta aparece en el acta, usala tal como se nombre.

Para asistencia, los estados validos son: "presente", "ausente", "licencia" (justifica con licencia medica),
"inhabilidad" (se inhabilito para una votacion especifica - registrar tambien como presente si participo en otras).
Si un consejero esta presente y solo se inhabilita en algunos temas, registralo como "presente" en asistencia
y registra las inhabilidades a nivel de acuerdo.

Para votaciones, los resultados validos son:
- "unanimidad": todos los presentes votaron a favor
- "mayoria": aprobado con votos a favor + algunas abstenciones o inhabilidades, sin votos en contra
- "aprobado_con_votos_en_contra": aprobado pero con votos en contra
- "rechazado": no se aprobo"""


EXTRACTION_PROMPT = """Analiza el siguiente texto de un acta del Consejo Regional Metropolitano de Santiago (CORE) y extrae los datos estructurados en formato JSON.

IMPORTANTE:
- Extrae TODOS los temas tratados, no solo los acuerdos formales
- Para cada tema con numero de tabla, incluyelo (ej: "1", "2", "3.1")
- Los nombres de consejeros deben coincidir EXACTAMENTE con la lista proporcionada (sin tildes, sin caracteres especiales)
- Incluye todas las intervenciones significativas de consejeros con resumen
- El resumen general debe ser un parrafo completo que capture los puntos mas relevantes de la sesion (3-5 oraciones)
- Los resumenes de temas deben ser detallados (2-5 oraciones)
- Para acuerdos, identifica monto, moneda (CLP/UF/USD/UTM), beneficiario (municipio/organizacion/empresa), fuente_financiamiento (FNDR, FRIL, 6%, etc.)
- En "votos_detalle" registra los consejeros que se inhabilitaron, abstuvieron o votaron en contra (no es necesario listar todos los que votaron a favor si fue unanimidad)
- Si un tema fue presentado por una comision, registra el nombre de la comision tal como aparece y a su presidente como "presentado_por"

Responde SOLO con el JSON, sin texto adicional ni bloques de codigo markdown.

Esquema JSON:
{
  "sesion": {
    "numero_sesion": <int>,
    "tipo_sesion": "<ordinaria|extraordinaria>",
    "fecha": "<YYYY-MM-DD>",
    "hora_inicio": "<HH:MM>" o null,
    "hora_termino": "<HH:MM>" o null,
    "resumen_general": "<texto largo>"
  },
  "asistencia": [
    {"nombre": "<nombre sin tildes>", "estado": "<presente|ausente|licencia>"}
  ],
  "temas": [
    {
      "numero_tabla": "<1>" o null,
      "seccion": "<cuenta|tabla|comision|varios>",
      "comision": "<nombre de la comision>" o null,
      "titulo": "<titulo conciso>",
      "resumen": "<resumen de 2-5 oraciones>",
      "presentado_por": "<nombre sin tildes del consejero o presidente de comision>" o null,
      "categorias": ["<categoria1>", "<categoria2>"],
      "acuerdo": {
        "numero_acuerdo": <int> o null,
        "texto_acuerdo": "<texto del acuerdo>",
        "resultado_votacion": "<unanimidad|mayoria|aprobado_con_votos_en_contra|rechazado>",
        "votos_favor": <int>,
        "votos_contra": <int>,
        "abstenciones": <int>,
        "inhabilidades": <int>,
        "monto_involucrado": <float> o null,
        "moneda": "<CLP|UF|USD|UTM>" o null,
        "beneficiario": "<nombre>" o null,
        "rut_beneficiario": "<XX.XXX.XXX-X>" o null,
        "fuente_financiamiento": "<FNDR|FRIL|6%|etc>" o null,
        "cumplimiento_inmediato": <bool>,
        "votos_detalle": [
          {"consejero": "<nombre sin tildes>", "voto": "<favor|contra|abstencion|inhabilidad>"}
        ]
      } o null,
      "intervenciones": [
        {"consejero": "<nombre sin tildes>", "resumen": "<resumen>"}
      ]
    }
  ]
}

TEXTO DEL ACTA:
---
{texto}
---"""


def extract_with_claude(text_path):
    """Extrae datos estructurados de un acta usando Claude. Devuelve dict o None."""
    text_path = Path(text_path)
    texto = text_path.read_text(encoding='utf-8')

    if len(texto) < 100:
        logger.error(f'Texto demasiado corto ({len(texto)} chars): {text_path.name}')
        return None

    logger.info(f'Extrayendo datos con Claude ({len(texto) // 1024} KB)...')

    client = anthropic.Anthropic()

    # Truncar si excede ~150K chars (~50K tokens)
    if len(texto) > 150000:
        logger.warning(f'Texto truncado de {len(texto)} a 150000 chars')
        texto = texto[:150000]

    prompt = EXTRACTION_PROMPT.replace('{texto}', texto)

    try:
        with client.messages.stream(
            model=config.CLAUDE_MODEL,
            max_tokens=32000,
            system=SYSTEM_PROMPT,
            messages=[{'role': 'user', 'content': prompt}]
        ) as stream:
            response = stream.get_final_message()

        if response.stop_reason == 'max_tokens':
            logger.warning(f'Respuesta de Claude truncada por max_tokens. Reintentando con instrucciones reforzadas...')
            return _retry_extraction(client, texto)

        response_text = response.content[0].text.strip()

        if response_text.startswith('```'):
            lines = response_text.split('\n')
            response_text = '\n'.join(lines[1:-1] if lines[-1].startswith('```') else lines[1:])

        data = json.loads(response_text)
        logger.info(f'Extraccion exitosa: {len(data.get("temas", []))} temas, '
                    f'{sum(1 for t in data.get("temas", []) if t.get("acuerdo"))} acuerdos')

        if not _validate(data):
            logger.error('Validacion fallida, reintentando...')
            return _retry_extraction(client, texto)

        return data

    except json.JSONDecodeError as e:
        logger.error(f'Error parseando JSON de Claude: {e}')
        logger.debug(f'Respuesta: {response_text[:500]}...')
        return _retry_extraction(client, texto)
    except Exception as e:
        logger.error(f'Error llamando a Claude API: {e}')
        return None


def _validate(data):
    if 'sesion' not in data:
        logger.error('Falta campo "sesion"')
        return False
    if 'asistencia' not in data or len(data['asistencia']) == 0:
        logger.error('Falta campo "asistencia" o vacio')
        return False
    if 'temas' not in data:
        logger.error('Falta campo "temas"')
        return False

    sesion = data['sesion']
    for field in ['numero_sesion', 'tipo_sesion', 'fecha']:
        if field not in sesion:
            logger.error(f'Falta sesion.{field}')
            return False

    known = {c.lower() for c in config.CONSEJEROS}
    for a in data['asistencia']:
        if a['nombre'].lower() not in known:
            logger.warning(f'Consejero no reconocido en asistencia: {a["nombre"]}')

    valid_cats = set(config.CATEGORIAS)
    for tema in data['temas']:
        for cat in tema.get('categorias', []):
            if cat not in valid_cats:
                logger.warning(f'Categoria no valida: {cat}')

    return True


def _retry_extraction(client, texto):
    logger.info('Reintentando extraccion con instrucciones reforzadas...')
    prompt = (
        "Tu respuesta anterior no fue JSON valido. "
        "Responde UNICAMENTE con un objeto JSON valido, sin texto adicional, "
        "sin bloques de codigo markdown, sin explicaciones.\n\n"
        + EXTRACTION_PROMPT.replace('{texto}', texto)
    )

    try:
        with client.messages.stream(
            model=config.CLAUDE_MODEL,
            max_tokens=32000,
            system=SYSTEM_PROMPT,
            messages=[{'role': 'user', 'content': prompt}]
        ) as stream:
            response = stream.get_final_message()
        response_text = response.content[0].text.strip()
        if response_text.startswith('```'):
            lines = response_text.split('\n')
            response_text = '\n'.join(lines[1:-1] if lines[-1].startswith('```') else lines[1:])

        data = json.loads(response_text)
        if _validate(data):
            return data
    except Exception as e:
        logger.error(f'Reintento tambien fallo: {e}')

    return None
