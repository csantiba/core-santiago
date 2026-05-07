"""Configuración centralizada del pipeline CORE Metropolitano."""
import os
from pathlib import Path
from dotenv import load_dotenv

PROJECT_ROOT = Path(__file__).resolve().parent.parent
load_dotenv(PROJECT_ROOT / '.env')

# Base de datos
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_NAME = os.getenv('DB_NAME', 'core_santiago')
DB_USER = os.getenv('DB_USER', 'postgres')
DB_PASSWORD = os.getenv('DB_PASSWORD', '')

# Rutas
SESIONES_DIR = Path(os.getenv('SESIONES_DIR', PROJECT_ROOT / 'sesiones'))
LOG_DIR = Path(os.getenv('LOG_DIR', PROJECT_ROOT / 'logs'))
LOG_DIR.mkdir(exist_ok=True)
TEXTOS_DIR = Path(os.getenv('TEXTOS_DIR', PROJECT_ROOT / 'textos'))
TEXTOS_DIR.mkdir(exist_ok=True)

# Claude API
CLAUDE_MODEL = os.getenv('CLAUDE_MODEL', 'claude-sonnet-4-5')

# Webapp
WEBAPP_BASE_URL = os.getenv('WEBAPP_BASE_URL', 'http://localhost:3003')

# Consejeros del CORE Metropolitano (período actual). Sin tildes para validación.
CONSEJEROS = [
    'Claudio Orrego Larrain',
    'Edith Aedo Meza',
    'Beatriz Albornoz Soto',
    'Nicole Aguilera Ramirez',
    'Alvaro Bellolio Avaria',
    'Sonja del Rio Becker',
    'Rodrigo Donoso Baeza',
    'Maricel Donoso Doria',
    'Ignacio Dulger Castillo',
    'Gabriela Gallardo Fuentes',
    'Jaime Gonzalez Kazazian',
    'Pedro Herreros Bejares',
    'Nicolas Jara Lira',
    'Karin Luck Urban',
    'Sadi Melo Moya',
    'Sergio Morales Mendez',
    'Claudina Nunez Jimenez',
    'Felipe Obal Duran',
    'Nebbia Otarola Leon',
    'Valeria Ortega Contreras',
    'Carolina Oteiza Fuenzalida',
    'Maria Valeria Ponti Risetti',
    'Danae Prado Carmona',
    'Maria Eugenia Puelma Alfaro',
    'Javier Ramirez Gonzalez',
    'Dioscoro Rojas Campos',
    'Felipe Serey Guerra',
    'Cristina Soto Messina',
    'Jose Soto Madrid',
    'Carlos Telleria Gonzalez',
    'Victor Valdes Landeros',
    'Leslie Venegas Venegas',
    'Alfredo Vergara Catalan',
    'Marcelo Zunino Poblete',
    'Ximena Peralta Fierro',
]

PRESIDENTE = 'Claudio Orrego Larrain'
SECRETARIO_EJECUTIVO = 'Jose Zuleta Bove'

# Categorías válidas (deben coincidir con database/create_schema.sql)
CATEGORIAS = [
    'fndr', 'fril', 'educacion', 'salud', 'transporte', 'vivienda',
    'seguridad', 'medioambiente', 'cultura_eventos', 'infraestructura',
    'urbanismo', 'legal', 'presupuesto', 'designaciones',
    'convenios_programacion', 'participacion',
]
