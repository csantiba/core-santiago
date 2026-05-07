"""Orquestador del pipeline: lee PDFs locales en sesiones/<año>/, los procesa y carga.

Uso:
    python -m pipeline                                      # procesa todos los PDFs no cargados aun
    python -m pipeline --files "SESIÓN 07-26  (08-04).pdf"  # archivo(s) especifico(s)
    python -m pipeline --years 2026                          # solo de cierto año
    python -m pipeline --latest 3                            # los N PDFs mas recientes
"""
import argparse
import logging
import sys
from datetime import datetime
from pathlib import Path

from . import config
from .ocr import extract_text
from .extractor import extract_with_claude
from .loader import load_to_db


def setup_logging():
    log_file = config.LOG_DIR / f'pipeline_{datetime.now():%Y%m%d_%H%M%S}.log'
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s [%(name)s] %(levelname)s: %(message)s',
        handlers=[
            logging.FileHandler(log_file, encoding='utf-8'),
            logging.StreamHandler(sys.stdout),
        ]
    )
    return logging.getLogger('pipeline')


def discover_pdfs(years=None):
    """Lista todos los PDFs en sesiones/<año>/, ordenados por mtime descendente."""
    base = config.SESIONES_DIR
    if not base.exists():
        return []

    pdfs = []
    for year_dir in sorted(base.iterdir()):
        if not year_dir.is_dir():
            continue
        if years and year_dir.name not in {str(y) for y in years}:
            continue
        for pdf in year_dir.glob('*.pdf'):
            pdfs.append(pdf)

    pdfs.sort(key=lambda p: p.stat().st_mtime, reverse=True)
    return pdfs


def process_pdf(pdf_path, logger):
    """Procesa una acta: OCR → Claude → BD. Retorna sesion_id o None."""
    try:
        txt_path = extract_text(pdf_path)
    except Exception as e:
        logger.error(f'Error en OCR de {pdf_path.name}: {e}')
        return None

    try:
        data = extract_with_claude(txt_path)
    except Exception as e:
        logger.error(f'Error extrayendo con Claude {pdf_path.name}: {e}')
        return None

    if data is None:
        logger.error(f'No se pudieron extraer datos de {pdf_path.name}')
        return None

    try:
        return load_to_db(data, pdf_filename=pdf_path.name, txt_filename=txt_path.name)
    except Exception as e:
        logger.error(f'Error cargando {pdf_path.name} en BD: {e}')
        return None


def run(files=None, years=None, latest=None):
    logger = setup_logging()
    logger.info('=' * 60)
    logger.info('Pipeline CORE Metropolitano - inicio')
    logger.info('=' * 60)

    start = datetime.now()

    if files:
        pdfs = []
        for f in files:
            p = Path(f)
            if not p.is_absolute():
                # Buscar dentro de sesiones/
                matches = list(config.SESIONES_DIR.rglob(p.name))
                if matches:
                    p = matches[0]
            if p.exists():
                pdfs.append(p)
            else:
                logger.warning(f'Archivo no encontrado: {f}')
    else:
        pdfs = discover_pdfs(years=years)
        if latest:
            pdfs = pdfs[:latest]

    if not pdfs:
        logger.info('No hay PDFs para procesar.')
        return

    logger.info(f'PDFs a procesar: {len(pdfs)}')
    for p in pdfs:
        logger.info(f'  - {p.name}')

    loaded = []
    errors = []
    skipped = []

    for pdf_path in pdfs:
        logger.info(f'--- Procesando {pdf_path.name} ---')
        try:
            sesion_id = process_pdf(pdf_path, logger)
            if sesion_id:
                loaded.append((pdf_path.name, sesion_id))
                logger.info(f'OK: {pdf_path.name} cargada (id={sesion_id})')
            else:
                skipped.append(pdf_path.name)
        except Exception as e:
            logger.error(f'Error procesando {pdf_path.name}: {e}')
            errors.append((pdf_path.name, str(e)))

    elapsed = (datetime.now() - start).total_seconds()
    logger.info('=' * 60)
    logger.info(f'Pipeline finalizado en {elapsed:.0f}s')
    logger.info(f'  Cargadas:   {len(loaded)}')
    logger.info(f'  Omitidas:   {len(skipped)}')
    logger.info(f'  Errores:    {len(errors)}')
    for name, err in errors:
        logger.info(f'    {name}: {err}')
    logger.info('=' * 60)


def main():
    parser = argparse.ArgumentParser(description='Pipeline de carga de actas - CORE Metropolitano')
    parser.add_argument('--files', nargs='+', help='Archivo(s) PDF especifico(s)')
    parser.add_argument('--years', type=int, nargs='+', help='Años a procesar (ej: 2025 2026)')
    parser.add_argument('--latest', type=int, help='Procesar solo los N PDFs mas recientes')
    args = parser.parse_args()
    run(files=args.files, years=args.years, latest=args.latest)


if __name__ == '__main__':
    main()
