-- Schema: Consejo Regional Metropolitano de Santiago (CORE)
-- Base de datos para análisis temático de actas

CREATE EXTENSION IF NOT EXISTS unaccent;

-- Sesiones del consejo regional
CREATE TABLE sesiones (
    id SERIAL PRIMARY KEY,
    numero_sesion INTEGER NOT NULL,
    tipo_sesion VARCHAR(50) NOT NULL DEFAULT 'ordinaria', -- ordinaria | extraordinaria
    fecha DATE NOT NULL,
    hora_inicio TIME,
    hora_termino TIME,
    presidente VARCHAR(200),
    secretario_ejecutivo VARCHAR(200),
    archivo_pdf VARCHAR(500),
    archivo_texto VARCHAR(500),
    resumen_general TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(numero_sesion, tipo_sesion, fecha)
);

-- Consejeros regionales (incluye al gobernador como presidente)
CREATE TABLE consejeros (
    id SERIAL PRIMARY KEY,
    nombre_completo VARCHAR(200) NOT NULL UNIQUE,
    es_presidente BOOLEAN DEFAULT FALSE,
    activo BOOLEAN DEFAULT TRUE
);

-- Asistencia: estados ampliados respecto a un concejo comunal
CREATE TABLE asistencia (
    id SERIAL PRIMARY KEY,
    sesion_id INTEGER REFERENCES sesiones(id) ON DELETE CASCADE,
    consejero_id INTEGER REFERENCES consejeros(id),
    estado VARCHAR(20) NOT NULL DEFAULT 'presente', -- presente | ausente | licencia | inhabilidad
    UNIQUE(sesion_id, consejero_id)
);

-- Comisiones permanentes del CORE (se descubren desde las actas)
CREATE TABLE comisiones (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL UNIQUE,
    descripcion TEXT,
    presidente_id INTEGER REFERENCES consejeros(id)
);

-- Categorías temáticas regionales
CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
);

-- Temas tratados en cada sesión
CREATE TABLE temas (
    id SERIAL PRIMARY KEY,
    sesion_id INTEGER REFERENCES sesiones(id) ON DELETE CASCADE,
    numero_tabla VARCHAR(20),
    seccion VARCHAR(50) NOT NULL, -- cuenta | tabla | comision | varios
    titulo VARCHAR(500) NOT NULL,
    resumen TEXT,
    texto_completo TEXT,
    comision_id INTEGER REFERENCES comisiones(id),
    presentado_por INTEGER REFERENCES consejeros(id),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Relación temas-categorías
CREATE TABLE temas_categorias (
    tema_id INTEGER REFERENCES temas(id) ON DELETE CASCADE,
    categoria_id INTEGER REFERENCES categorias(id) ON DELETE CASCADE,
    PRIMARY KEY (tema_id, categoria_id)
);

-- Acuerdos votados
CREATE TABLE acuerdos (
    id SERIAL PRIMARY KEY,
    tema_id INTEGER REFERENCES temas(id) ON DELETE CASCADE,
    numero_acuerdo INTEGER,
    sesion_id INTEGER REFERENCES sesiones(id) ON DELETE CASCADE,
    texto_acuerdo TEXT NOT NULL,
    resultado_votacion VARCHAR(50), -- unanimidad | mayoria | aprobado_con_votos_en_contra | rechazado
    votos_favor INTEGER,
    votos_contra INTEGER,
    abstenciones INTEGER,
    inhabilidades INTEGER,
    monto_involucrado NUMERIC(15,2),
    moneda VARCHAR(10) DEFAULT 'CLP',
    beneficiario VARCHAR(300),       -- municipio, organización, empresa beneficiada
    rut_beneficiario VARCHAR(20),
    fuente_financiamiento VARCHAR(100), -- FNDR, FRIL, 6%, etc.
    cumplimiento_inmediato BOOLEAN DEFAULT FALSE
);

-- Detalle de votación individual por consejero (opcional, útil para inhabilidades)
CREATE TABLE votos_consejero (
    id SERIAL PRIMARY KEY,
    acuerdo_id INTEGER REFERENCES acuerdos(id) ON DELETE CASCADE,
    consejero_id INTEGER REFERENCES consejeros(id),
    voto VARCHAR(20) NOT NULL, -- favor | contra | abstencion | inhabilidad
    UNIQUE(acuerdo_id, consejero_id)
);

-- Intervenciones de consejeros
CREATE TABLE intervenciones (
    id SERIAL PRIMARY KEY,
    tema_id INTEGER REFERENCES temas(id) ON DELETE CASCADE,
    consejero_id INTEGER REFERENCES consejeros(id),
    resumen_intervencion TEXT,
    orden INTEGER
);

-- Suscriptores
CREATE TABLE suscriptores (
    id SERIAL PRIMARY KEY,
    nombre_completo VARCHAR(200),
    email VARCHAR(200) UNIQUE,
    token_baja VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE,
    fecha_suscripcion TIMESTAMP DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_temas_titulo_fts ON temas USING gin(to_tsvector('spanish', titulo));
CREATE INDEX idx_temas_resumen_fts ON temas USING gin(to_tsvector('spanish', resumen));
CREATE INDEX idx_acuerdos_texto_fts ON acuerdos USING gin(to_tsvector('spanish', texto_acuerdo));
CREATE INDEX idx_sesiones_fecha ON sesiones(fecha);
CREATE INDEX idx_temas_sesion ON temas(sesion_id);
CREATE INDEX idx_temas_comision ON temas(comision_id);
CREATE INDEX idx_acuerdos_sesion ON acuerdos(sesion_id);

-- Datos iniciales: Consejeros Regionales del período
INSERT INTO consejeros (nombre_completo, es_presidente) VALUES
    ('Claudio Orrego Larrain', TRUE),
    ('Edith Aedo Meza', FALSE),
    ('Beatriz Albornoz Soto', FALSE),
    ('Nicole Aguilera Ramirez', FALSE),
    ('Alvaro Bellolio Avaria', FALSE),
    ('Sonja del Rio Becker', FALSE),
    ('Rodrigo Donoso Baeza', FALSE),
    ('Maricel Donoso Doria', FALSE),
    ('Ignacio Dulger Castillo', FALSE),
    ('Gabriela Gallardo Fuentes', FALSE),
    ('Jaime Gonzalez Kazazian', FALSE),
    ('Pedro Herreros Bejares', FALSE),
    ('Nicolas Jara Lira', FALSE),
    ('Karin Luck Urban', FALSE),
    ('Sadi Melo Moya', FALSE),
    ('Sergio Morales Mendez', FALSE),
    ('Claudina Nunez Jimenez', FALSE),
    ('Felipe Obal Duran', FALSE),
    ('Nebbia Otarola Leon', FALSE),
    ('Valeria Ortega Contreras', FALSE),
    ('Carolina Oteiza Fuenzalida', FALSE),
    ('Maria Valeria Ponti Risetti', FALSE),
    ('Danae Prado Carmona', FALSE),
    ('Maria Eugenia Puelma Alfaro', FALSE),
    ('Javier Ramirez Gonzalez', FALSE),
    ('Dioscoro Rojas Campos', FALSE),
    ('Felipe Serey Guerra', FALSE),
    ('Cristina Soto Messina', FALSE),
    ('Jose Soto Madrid', FALSE),
    ('Carlos Telleria Gonzalez', FALSE),
    ('Victor Valdes Landeros', FALSE),
    ('Leslie Venegas Venegas', FALSE),
    ('Alfredo Vergara Catalan', FALSE),
    ('Marcelo Zunino Poblete', FALSE),
    ('Ximena Peralta Fierro', FALSE);

-- Categorías temáticas regionales
INSERT INTO categorias (nombre, descripcion) VALUES
    ('fndr', 'Fondo Nacional de Desarrollo Regional, proyectos FNDR'),
    ('fril', 'Fondo Regional de Iniciativa Local, proyectos comunitarios'),
    ('educacion', 'SLEP, colegios, becas, infraestructura educativa, designaciones de comites'),
    ('salud', 'Hospitales, CESFAM, equipamiento medico, salud regional'),
    ('transporte', 'Transporte publico, vialidad, conectividad, Metro, EFE'),
    ('vivienda', 'Vivienda social, campamentos, urbanizacion'),
    ('seguridad', 'Seguridad ciudadana, camaras, equipamiento policial'),
    ('medioambiente', 'Areas verdes, residuos, calidad del aire, gestion hidrica'),
    ('cultura_eventos', 'Festivales, deportes, fiestas patrias, eventos comunales'),
    ('infraestructura', 'Sedes sociales, multicanchas, edificios publicos, obras viales'),
    ('urbanismo', 'Planes reguladores, plan regulador metropolitano, ordenamiento territorial'),
    ('legal', 'Convenios, oficios, recursos legales, modificaciones normativas'),
    ('presupuesto', 'Presupuesto regional, modificaciones presupuestarias, distribucion de fondos'),
    ('designaciones', 'Designacion de representantes en comites y directorios'),
    ('convenios_programacion', 'Convenios de programacion con ministerios y servicios'),
    ('participacion', 'Participacion ciudadana, organizaciones territoriales, dirigentes');
