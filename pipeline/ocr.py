"""Extracción de texto de PDFs.

Intenta primero texto embebido con pdfplumber. Si el PDF es escaneado, usa Tesseract.
"""
import io
import logging
import re
from pathlib import Path

from . import config

logger = logging.getLogger(__name__)


def _slug_from_pdf_name(pdf_path: Path) -> str:
    """Convierte 'SESIÓN 07-26  (08-04).pdf' o 'SESIÓN EXT. 02-26  (25-03).pdf' en un slug."""
    name = pdf_path.stem.lower()
    name = name.replace('sesión', 'sesion').replace('ext.', 'ext')
    name = re.sub(r'[^a-z0-9]+', '_', name).strip('_')
    return name


def _extract_with_pdfplumber(pdf_path):
    import pdfplumber

    text_pages = []
    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            text_pages.append(page.extract_text() or '')

    full_text = '\n'.join(text_pages)
    clean = ' '.join(full_text.split())
    return full_text if len(clean) > 500 else None


def _extract_with_tesseract(pdf_path):
    import fitz
    import pytesseract
    from PIL import Image

    logger.info('Ejecutando OCR con Tesseract...')
    doc = fitz.open(str(pdf_path))
    total = doc.page_count
    all_text = []

    for i in range(total):
        page = doc[i]
        mat = fitz.Matrix(300 / 72, 300 / 72)
        pix = page.get_pixmap(matrix=mat)
        img = Image.open(io.BytesIO(pix.tobytes('png'))).convert('L')
        text = pytesseract.image_to_string(img, lang='spa')
        all_text.append(f'--- Pagina {i + 1} ---\n{text}')

        if (i + 1) % 20 == 0 or i == 0:
            logger.info(f'  OCR pagina {i + 1}/{total}')

    doc.close()
    return '\n\n'.join(all_text)


def extract_text(pdf_path, output_path=None):
    """Extrae texto de un PDF. Devuelve Path al .txt resultante."""
    pdf_path = Path(pdf_path)

    if output_path is None:
        slug = _slug_from_pdf_name(pdf_path)
        output_path = config.TEXTOS_DIR / f'{slug}.txt'
    else:
        output_path = Path(output_path)

    if output_path.exists() and output_path.stat().st_size > 500:
        logger.info(f'Texto ya existe: {output_path.name} ({output_path.stat().st_size // 1024} KB)')
        return output_path

    logger.info(f'Extrayendo texto de {pdf_path.name}...')

    text = _extract_with_pdfplumber(pdf_path)
    if text:
        logger.info(f'Texto extraido con pdfplumber ({len(text) // 1024} KB)')
    else:
        logger.info('PDF escaneado, usando Tesseract OCR...')
        text = _extract_with_tesseract(pdf_path)
        logger.info(f'OCR completado ({len(text) // 1024} KB)')

    output_path.write_text(text, encoding='utf-8')
    return output_path
