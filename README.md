# Consejo Regional Metropolitano de Santiago — Visor Ciudadano

Plataforma de consulta ciudadana sobre la actividad del **Consejo Regional Metropolitano de Santiago (CORE)**: sesiones plenarias, acuerdos aprobados, distribución de fondos regionales (FNDR, FRIL, 6%), asistencia de consejeras y consejeros, e informes de las comisiones permanentes.

La información se obtiene de las actas oficiales del CORE en formato PDF, se procesa con OCR y se estructura mediante la API de Claude (Anthropic).

## Arquitectura

```
core-santiago/
├── database/
│   └── create_schema.sql      # Schema PostgreSQL (sesiones, consejeros, acuerdos, comisiones, …)
├── pipeline/                  # Pipeline Python: PDF → texto → JSON estructurado → BD
│   ├── ocr.py                 # pdfplumber con fallback a Tesseract
│   ├── extractor.py           # Llamada a Claude API (streaming, max_tokens=32K)
│   ├── loader.py              # Inserción en PostgreSQL (idempotente)
│   └── runner.py              # Orquestador con CLI (--latest, --years, --files)
├── sesiones/                  # PDFs originales del CORE (no versionado)
│   └── <año>/                 #   ej: sesiones/2026/SESIÓN 07-26  (08-04).pdf
├── webapp/                    # Servidor Express + UI estática
│   ├── server.js              # API REST en puerto 3003
│   └── public/                # HTML/CSS/JS sin frameworks
└── textos/                    # Cache de textos extraídos (no versionado)
```

## Modelo de datos

- **`sesiones`**: ordinarias y extraordinarias, con presidente, secretario ejecutivo, hora, resumen.
- **`consejeros`**: 35 consejeros del período actual (incluye al Gobernador como presidente).
- **`asistencia`**: 4 estados (`presente`, `ausente`, `licencia`, `inhabilidad`).
- **`comisiones`**: descubiertas automáticamente desde las actas (ej. "Educación y Cultura", "SEIA"); el loader normaliza nombres para evitar duplicados.
- **`temas`**: separados por `seccion` (`cuenta`, `tabla`, `comision`, `varios`), enlazados a la comisión que los presentó.
- **`acuerdos`**: votación detallada (a favor / en contra / abstenciones / inhabilidades), monto, beneficiario, fuente de financiamiento (FNDR, FRIL, 6%, …).
- **`votos_consejero`**: detalle de votos individuales (útil para registrar inhabilidades específicas).
- **`intervenciones`**: aportes de consejeros por tema.
- **`categorias`**: 16 categorías regionales (FNDR, FRIL, educación, salud, transporte, vivienda, urbanismo, …).

## Requisitos

- **PostgreSQL** 14+ (probado con 18) con extensión `unaccent`.
- **Node.js** 18+ para la webapp.
- **Python** 3.10+ para el pipeline.
- **Tesseract OCR** (opcional, solo si las actas son escaneadas; las del CORE son nativas en texto).
- **API key de Anthropic** (`sk-ant-...` desde la [consola](https://console.anthropic.com/settings/keys)).

## Setup

1. **Configurar entorno**

   ```bash
   cp .env.example .env
   # Editar .env con DB_PASSWORD y ANTHROPIC_API_KEY
   ```

2. **Crear la base de datos**

   ```bash
   psql -U postgres -c "CREATE DATABASE core_santiago;"
   psql -U postgres -d core_santiago -f database/create_schema.sql
   ```

3. **Instalar dependencias**

   ```bash
   pip install -r pipeline/requirements.txt
   cd webapp && npm install
   ```

4. **Colocar las actas**

   Descargar los PDFs del CORE y organizarlos por año en `sesiones/<año>/`. Por ejemplo:

   ```
   sesiones/2026/SESIÓN 07-26  (08-04).pdf
   sesiones/2026/SESIÓN EXT. 02-26  (25-03).pdf
   ```

## Uso

### Pipeline (carga de actas)

```bash
# Procesar las 3 actas más recientes (por mtime)
python -m pipeline --latest 3

# Procesar un año completo
python -m pipeline --years 2026

# Procesar un archivo específico
python -m pipeline --files "SESIÓN 07-26  (08-04).pdf"
```

El pipeline es **idempotente**: si una sesión ya existe en la BD (mismo número, tipo y fecha), la omite. Los textos OCR se cachean en `textos/` y se reutilizan en corridas posteriores.

### Webapp

```bash
cd webapp && npm start
# → http://localhost:3003
```

Páginas disponibles:

| Ruta | Descripción |
|---|---|
| `/` | Dashboard con métricas globales y últimas sesiones |
| `/sesiones.html` | Listado completo con búsqueda por categoría y rango de fechas |
| `/sesion.html?id=N` | Detalle de una sesión: asistencia (4 estados), temas por sección, acuerdos con votos detallados, descarga del PDF original |
| `/acuerdos.html` | Tabla de acuerdos filtrable por categoría, fuente de financiamiento (FNDR/FRIL/6%) y fecha |
| `/comisiones.html` | Listado de comisiones permanentes con sus temas presentados |
| `/asistencia.html` | Gráfico canvas con asistencia por consejero (presente / licencia / ausente) |
| `/varios.html` | Temas planteados libremente con ranking por consejero |

### API REST

Endpoints principales (todos en `/api/...`):

- `GET /api/dashboard` — métricas globales
- `GET /api/sesiones`, `GET /api/sesiones/:id`
- `GET /api/acuerdos?q=&categoria_id=&fuente=&fecha_desde=&fecha_hasta=`
- `GET /api/comisiones`, `GET /api/comisiones/:id`
- `GET /api/consejeros`, `GET /api/consejeros/:id/asistencia`
- `GET /api/categorias`
- `GET /api/buscar?q=&categoria_id=&fecha_desde=&fecha_hasta=`
- `GET /api/varios?consejero_id=&q=`

## Calidad de la extracción

El extractor usa Claude Sonnet 4.5 con un prompt específico que:

- Reconoce la estructura del CORE (cuenta del Gobernador, tabla, informes de comisiones, varios).
- Distingue los 4 estados de asistencia, incluyendo **inhabilidades** (recusaciones legales por conflicto de interés, no presentes en concejos comunales).
- Identifica beneficiarios (municipios, organizaciones), fuentes de financiamiento (FNDR, FRIL, 6%) y montos en distintas monedas (CLP, UF, USD, UTM).
- Asigna automáticamente categorías de la taxonomía regional.

Las **comisiones se descubren automáticamente** al procesar; el loader normaliza nombres para evitar duplicados (p. ej. "Comisión de Coordinación" y "Coordinación" se consolidan).

## Notas

- Los PDFs originales del CORE no se versionan en este repositorio (tamaño y origen externo).
- El `.env` con credenciales reales está excluido del repo; usar `.env.example` como plantilla.
- Las actas largas (>150K caracteres de texto) se truncan al enviarlas a Claude; en la práctica esto no ha producido pérdida de datos relevantes en las 3 actas de prueba (sesiones 06, 07 y EXT. 02 de 2026).

## Licencia

[MIT](LICENSE)
