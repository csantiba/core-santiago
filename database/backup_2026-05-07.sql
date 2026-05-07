--
-- PostgreSQL database dump
--

\restrict vt388myhsAoDdzcfG5Gdz9A7hKjJKNqExBYmXXkOtjzXd4RRMh4aNsWTUXWbT17

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.votos_consejero DROP CONSTRAINT IF EXISTS votos_consejero_consejero_id_fkey;
ALTER TABLE IF EXISTS ONLY public.votos_consejero DROP CONSTRAINT IF EXISTS votos_consejero_acuerdo_id_fkey;
ALTER TABLE IF EXISTS ONLY public.temas DROP CONSTRAINT IF EXISTS temas_sesion_id_fkey;
ALTER TABLE IF EXISTS ONLY public.temas DROP CONSTRAINT IF EXISTS temas_presentado_por_fkey;
ALTER TABLE IF EXISTS ONLY public.temas DROP CONSTRAINT IF EXISTS temas_comision_id_fkey;
ALTER TABLE IF EXISTS ONLY public.temas_categorias DROP CONSTRAINT IF EXISTS temas_categorias_tema_id_fkey;
ALTER TABLE IF EXISTS ONLY public.temas_categorias DROP CONSTRAINT IF EXISTS temas_categorias_categoria_id_fkey;
ALTER TABLE IF EXISTS ONLY public.intervenciones DROP CONSTRAINT IF EXISTS intervenciones_tema_id_fkey;
ALTER TABLE IF EXISTS ONLY public.intervenciones DROP CONSTRAINT IF EXISTS intervenciones_consejero_id_fkey;
ALTER TABLE IF EXISTS ONLY public.comisiones DROP CONSTRAINT IF EXISTS comisiones_presidente_id_fkey;
ALTER TABLE IF EXISTS ONLY public.asistencia DROP CONSTRAINT IF EXISTS asistencia_sesion_id_fkey;
ALTER TABLE IF EXISTS ONLY public.asistencia DROP CONSTRAINT IF EXISTS asistencia_consejero_id_fkey;
ALTER TABLE IF EXISTS ONLY public.acuerdos DROP CONSTRAINT IF EXISTS acuerdos_tema_id_fkey;
ALTER TABLE IF EXISTS ONLY public.acuerdos DROP CONSTRAINT IF EXISTS acuerdos_sesion_id_fkey;
DROP INDEX IF EXISTS public.idx_temas_titulo_fts;
DROP INDEX IF EXISTS public.idx_temas_sesion;
DROP INDEX IF EXISTS public.idx_temas_resumen_fts;
DROP INDEX IF EXISTS public.idx_temas_comision;
DROP INDEX IF EXISTS public.idx_sesiones_fecha;
DROP INDEX IF EXISTS public.idx_acuerdos_texto_fts;
DROP INDEX IF EXISTS public.idx_acuerdos_sesion;
ALTER TABLE IF EXISTS ONLY public.votos_consejero DROP CONSTRAINT IF EXISTS votos_consejero_pkey;
ALTER TABLE IF EXISTS ONLY public.votos_consejero DROP CONSTRAINT IF EXISTS votos_consejero_acuerdo_id_consejero_id_key;
ALTER TABLE IF EXISTS ONLY public.temas DROP CONSTRAINT IF EXISTS temas_pkey;
ALTER TABLE IF EXISTS ONLY public.temas_categorias DROP CONSTRAINT IF EXISTS temas_categorias_pkey;
ALTER TABLE IF EXISTS ONLY public.suscriptores DROP CONSTRAINT IF EXISTS suscriptores_pkey;
ALTER TABLE IF EXISTS ONLY public.suscriptores DROP CONSTRAINT IF EXISTS suscriptores_email_key;
ALTER TABLE IF EXISTS ONLY public.sesiones DROP CONSTRAINT IF EXISTS sesiones_pkey;
ALTER TABLE IF EXISTS ONLY public.sesiones DROP CONSTRAINT IF EXISTS sesiones_numero_sesion_tipo_sesion_fecha_key;
ALTER TABLE IF EXISTS ONLY public.intervenciones DROP CONSTRAINT IF EXISTS intervenciones_pkey;
ALTER TABLE IF EXISTS ONLY public.consejeros DROP CONSTRAINT IF EXISTS consejeros_pkey;
ALTER TABLE IF EXISTS ONLY public.consejeros DROP CONSTRAINT IF EXISTS consejeros_nombre_completo_key;
ALTER TABLE IF EXISTS ONLY public.comisiones DROP CONSTRAINT IF EXISTS comisiones_pkey;
ALTER TABLE IF EXISTS ONLY public.comisiones DROP CONSTRAINT IF EXISTS comisiones_nombre_key;
ALTER TABLE IF EXISTS ONLY public.categorias DROP CONSTRAINT IF EXISTS categorias_pkey;
ALTER TABLE IF EXISTS ONLY public.categorias DROP CONSTRAINT IF EXISTS categorias_nombre_key;
ALTER TABLE IF EXISTS ONLY public.asistencia DROP CONSTRAINT IF EXISTS asistencia_sesion_id_consejero_id_key;
ALTER TABLE IF EXISTS ONLY public.asistencia DROP CONSTRAINT IF EXISTS asistencia_pkey;
ALTER TABLE IF EXISTS ONLY public.acuerdos DROP CONSTRAINT IF EXISTS acuerdos_pkey;
ALTER TABLE IF EXISTS public.votos_consejero ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.temas ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.suscriptores ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.sesiones ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.intervenciones ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.consejeros ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.comisiones ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.categorias ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.asistencia ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.acuerdos ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.votos_consejero_id_seq;
DROP TABLE IF EXISTS public.votos_consejero;
DROP SEQUENCE IF EXISTS public.temas_id_seq;
DROP TABLE IF EXISTS public.temas_categorias;
DROP TABLE IF EXISTS public.temas;
DROP SEQUENCE IF EXISTS public.suscriptores_id_seq;
DROP TABLE IF EXISTS public.suscriptores;
DROP SEQUENCE IF EXISTS public.sesiones_id_seq;
DROP TABLE IF EXISTS public.sesiones;
DROP SEQUENCE IF EXISTS public.intervenciones_id_seq;
DROP TABLE IF EXISTS public.intervenciones;
DROP SEQUENCE IF EXISTS public.consejeros_id_seq;
DROP TABLE IF EXISTS public.consejeros;
DROP SEQUENCE IF EXISTS public.comisiones_id_seq;
DROP TABLE IF EXISTS public.comisiones;
DROP SEQUENCE IF EXISTS public.categorias_id_seq;
DROP TABLE IF EXISTS public.categorias;
DROP SEQUENCE IF EXISTS public.asistencia_id_seq;
DROP TABLE IF EXISTS public.asistencia;
DROP SEQUENCE IF EXISTS public.acuerdos_id_seq;
DROP TABLE IF EXISTS public.acuerdos;
DROP EXTENSION IF EXISTS unaccent;
--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: acuerdos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acuerdos (
    id integer NOT NULL,
    tema_id integer,
    numero_acuerdo integer,
    sesion_id integer,
    texto_acuerdo text NOT NULL,
    resultado_votacion character varying(50),
    votos_favor integer,
    votos_contra integer,
    abstenciones integer,
    inhabilidades integer,
    monto_involucrado numeric(15,2),
    moneda character varying(10) DEFAULT 'CLP'::character varying,
    beneficiario character varying(300),
    rut_beneficiario character varying(20),
    fuente_financiamiento character varying(100),
    cumplimiento_inmediato boolean DEFAULT false
);


--
-- Name: acuerdos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.acuerdos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: acuerdos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.acuerdos_id_seq OWNED BY public.acuerdos.id;


--
-- Name: asistencia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.asistencia (
    id integer NOT NULL,
    sesion_id integer,
    consejero_id integer,
    estado character varying(20) DEFAULT 'presente'::character varying NOT NULL
);


--
-- Name: asistencia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.asistencia_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: asistencia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.asistencia_id_seq OWNED BY public.asistencia.id;


--
-- Name: categorias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categorias (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text
);


--
-- Name: categorias_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categorias_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categorias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categorias_id_seq OWNED BY public.categorias.id;


--
-- Name: comisiones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comisiones (
    id integer NOT NULL,
    nombre character varying(200) NOT NULL,
    descripcion text,
    presidente_id integer
);


--
-- Name: comisiones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comisiones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comisiones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comisiones_id_seq OWNED BY public.comisiones.id;


--
-- Name: consejeros; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.consejeros (
    id integer NOT NULL,
    nombre_completo character varying(200) NOT NULL,
    es_presidente boolean DEFAULT false,
    activo boolean DEFAULT true
);


--
-- Name: consejeros_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.consejeros_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: consejeros_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.consejeros_id_seq OWNED BY public.consejeros.id;


--
-- Name: intervenciones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.intervenciones (
    id integer NOT NULL,
    tema_id integer,
    consejero_id integer,
    resumen_intervencion text,
    orden integer
);


--
-- Name: intervenciones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.intervenciones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: intervenciones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.intervenciones_id_seq OWNED BY public.intervenciones.id;


--
-- Name: sesiones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sesiones (
    id integer NOT NULL,
    numero_sesion integer NOT NULL,
    tipo_sesion character varying(50) DEFAULT 'ordinaria'::character varying NOT NULL,
    fecha date NOT NULL,
    hora_inicio time without time zone,
    hora_termino time without time zone,
    presidente character varying(200),
    secretario_ejecutivo character varying(200),
    archivo_pdf character varying(500),
    archivo_texto character varying(500),
    resumen_general text,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: sesiones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sesiones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sesiones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sesiones_id_seq OWNED BY public.sesiones.id;


--
-- Name: suscriptores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.suscriptores (
    id integer NOT NULL,
    nombre_completo character varying(200),
    email character varying(200),
    token_baja character varying(100),
    activo boolean DEFAULT true,
    fecha_suscripcion timestamp without time zone DEFAULT now()
);


--
-- Name: suscriptores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.suscriptores_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: suscriptores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.suscriptores_id_seq OWNED BY public.suscriptores.id;


--
-- Name: temas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.temas (
    id integer NOT NULL,
    sesion_id integer,
    numero_tabla character varying(20),
    seccion character varying(50) NOT NULL,
    titulo character varying(500) NOT NULL,
    resumen text,
    texto_completo text,
    comision_id integer,
    presentado_por integer,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: temas_categorias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.temas_categorias (
    tema_id integer NOT NULL,
    categoria_id integer NOT NULL
);


--
-- Name: temas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.temas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: temas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.temas_id_seq OWNED BY public.temas.id;


--
-- Name: votos_consejero; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.votos_consejero (
    id integer NOT NULL,
    acuerdo_id integer,
    consejero_id integer,
    voto character varying(20) NOT NULL
);


--
-- Name: votos_consejero_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.votos_consejero_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votos_consejero_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.votos_consejero_id_seq OWNED BY public.votos_consejero.id;


--
-- Name: acuerdos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acuerdos ALTER COLUMN id SET DEFAULT nextval('public.acuerdos_id_seq'::regclass);


--
-- Name: asistencia id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asistencia ALTER COLUMN id SET DEFAULT nextval('public.asistencia_id_seq'::regclass);


--
-- Name: categorias id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorias ALTER COLUMN id SET DEFAULT nextval('public.categorias_id_seq'::regclass);


--
-- Name: comisiones id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comisiones ALTER COLUMN id SET DEFAULT nextval('public.comisiones_id_seq'::regclass);


--
-- Name: consejeros id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consejeros ALTER COLUMN id SET DEFAULT nextval('public.consejeros_id_seq'::regclass);


--
-- Name: intervenciones id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intervenciones ALTER COLUMN id SET DEFAULT nextval('public.intervenciones_id_seq'::regclass);


--
-- Name: sesiones id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sesiones ALTER COLUMN id SET DEFAULT nextval('public.sesiones_id_seq'::regclass);


--
-- Name: suscriptores id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suscriptores ALTER COLUMN id SET DEFAULT nextval('public.suscriptores_id_seq'::regclass);


--
-- Name: temas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.temas ALTER COLUMN id SET DEFAULT nextval('public.temas_id_seq'::regclass);


--
-- Name: votos_consejero id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votos_consejero ALTER COLUMN id SET DEFAULT nextval('public.votos_consejero_id_seq'::regclass);


--
-- Data for Name: acuerdos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.acuerdos (id, tema_id, numero_acuerdo, sesion_id, texto_acuerdo, resultado_votacion, votos_favor, votos_contra, abstenciones, inhabilidades, monto_involucrado, moneda, beneficiario, rut_beneficiario, fuente_financiamiento, cumplimiento_inmediato) FROM stdin;
1	1	\N	1	Aprobar acta de Sesión Ordinaria N°6 del 25 de marzo de 2026	unanimidad	33	0	0	0	\N	\N	\N	\N	\N	f
2	2	\N	1	Aprobar acta de Sesión Extraordinaria N°02 del 25 de marzo de 2026	unanimidad	33	0	0	0	\N	\N	\N	\N	\N	f
3	6	\N	1	Aprobar concesión de uso gratuito de inmueble en Pucón 10819, depto 402, La Florida, a Municipalidad de Quirihue para residencia temporal de pacientes	unanimidad	33	0	0	1	\N	\N	Municipalidad de Quirihue	\N	\N	f
4	7	\N	1	Aprobar concesión de uso gratuito de inmueble en Camino Vecinal 4676, Estación Central, a Fundación Terapéutica Ciudad de Gosen para centro de rehabilitación de adicciones	unanimidad	32	0	0	2	\N	\N	Fundacion Terapeutica Ciudad de Gosen	\N	\N	f
5	8	\N	1	Aprobar concesión de uso gratuito de inmueble en Fray Camilo 1051, Santiago, a Sindicato Trabajadoras Sexuales Amanda Jofré para casa comunitaria	aprobado_con_votos_en_contra	18	13	2	1	\N	\N	Sindicato Independiente de Trabajadoras Sexuales Amanda Jofre	\N	\N	f
6	9	\N	1	Aprobar concesión de uso gratuito de inmueble en Géminis 1355, La Florida, a Fundación Elabora Chile para centro de formación cooperativa	mayoria	27	0	6	1	\N	\N	Fundacion Elabora Chile	\N	\N	f
7	10	\N	1	Aprobar pronunciamiento favorable proyecto inmobiliario DS49 Parque Infante 1 y 2, Renca	unanimidad	30	0	0	0	\N	\N	\N	\N	\N	f
8	11	\N	1	Aprobar pronunciamiento favorable proyecto inmobiliario Parque Central, Inmobiliaria Todos los Santos S.A., Puente Alto	unanimidad	30	0	0	0	\N	\N	Inmobiliaria Todos los Santos S.A.	\N	\N	f
9	12	\N	1	Aprobar cometidos de consejeros regionales del período 21 al 31 de marzo de 2026	unanimidad	32	0	0	0	\N	\N	\N	\N	\N	f
10	19	\N	2	Aprobar la designación de Patricia Jofré Cáceres como representante del Gobierno Regional Metropolitano ante el comité directivo del Servicio Local de Educación Pública SLEP Los Parques	mayoria	29	0	3	2	\N	\N	SLEP Los Parques	\N	\N	f
11	20	\N	2	Aprobar la designación de Ignacio Maldonado Blásquez como representante del Gobierno Regional Metropolitano ante el comité directivo del Servicio Local de Educación Pública SLEP Los Libertadores	mayoria	28	0	4	2	\N	\N	SLEP Los Libertadores	\N	\N	f
12	21	\N	3	Se aprueba el Acta N°5 de la sesion del 10 de marzo de 2026	unanimidad	32	0	0	0	\N	\N	\N	\N	\N	f
13	23	\N	3	Se aprueba concesion gratuita de corto plazo por 5 anos a la Municipalidad de Pudahuel para inmueble donde funciona COSAM y sede comunitaria	unanimidad	33	0	0	1	\N	\N	Municipalidad de Pudahuel	\N	\N	f
14	24	\N	3	Se aprueba concesion gratuita de largo plazo a Municipalidad de Maria Pinto para inmueble donde funcionan tres sedes comunitarias	unanimidad	33	0	0	1	\N	\N	Municipalidad de Maria Pinto	\N	\N	f
15	25	\N	3	Se aprueba concesion gratuita de corto plazo por 5 anos a Municipalidad de La Reina para Centro de Participacion Social CEPASO	unanimidad	33	0	0	1	\N	\N	Municipalidad de La Reina	\N	\N	f
16	26	\N	3	Se rechaza concesion gratuita de corto plazo a Sindicato Nacional Interempresa de Profesionales y Tecnicos de Cine y Audiovisual	rechazado	13	18	2	1	\N	\N	Sindicato Nacional Interempresa de Profesionales y Tecnicos de Cine y Audiovisual	\N	\N	f
17	27	\N	3	Se aprueba concesion gratuita de corto plazo por 5 anos a Corporacion Educacional Sonrisas de Nino para patio de escuela del lenguaje	unanimidad	32	0	0	1	\N	\N	Corporacion Educacional Sonrisas de Nino	\N	\N	f
18	28	\N	3	Se aprueba concesion gratuita de corto plazo por 5 anos a Corporacion Administrativa del Poder Judicial para Centro Judicial de Melipilla	unanimidad	33	0	0	1	\N	\N	Corporacion Administrativa del Poder Judicial	\N	\N	f
19	29	\N	3	Se aprueba concesion gratuita de largo plazo por 30 anos a Quinta Compania Cuerpo de Bomberos de San Bernardo para cuartel y ampliacion	unanimidad	33	0	0	1	\N	\N	Cuerpo de Bomberos de San Bernardo	\N	\N	f
20	30	\N	3	Se aprueba concesion gratuita de largo plazo por 30 anos a Comite APR Santa Sara para construccion de estanque de agua potable en Batuco	unanimidad	33	0	0	1	\N	\N	Comite de Agua Potable Rural Santa Sara	\N	\N	f
21	31	\N	3	Se aprueba concesion onerosa de largo plazo por 30 anos a Buses Metropolitana SA para deposito de buses urbanos en Lo Prado	unanimidad	33	0	0	1	\N	\N	Buses Metropolitana SA	\N	\N	f
22	32	\N	3	Se aprueba concesion gratuita de largo plazo por 30 anos a Comite APR Los Maitenes para proyecto de sistema sanitario rural	unanimidad	33	0	0	1	\N	\N	Comite de Agua Potable Rural Los Maitenes	\N	\N	f
23	33	\N	3	Se aprueba concesion gratuita de largo plazo por 15 anos a Club Deportivo Union San Carlos para sede social y deportiva	unanimidad	33	0	0	1	\N	\N	Club Deportivo Union San Carlos	\N	\N	f
24	34	\N	3	Se aprueba concesion gratuita de largo plazo por 15 anos a Iglesia Hermandad Pentecostal para templo y ayuda social comunitaria	unanimidad	33	0	0	1	\N	\N	Iglesia Hermandad Pentecostal	\N	\N	f
25	35	\N	3	Se aprueban en bloque 5 concesiones gratuitas incluyendo a Fundacion Circo Nacional Chileno para espacio de patrimonio circense	unanimidad	33	0	0	1	\N	\N	Fundacion Circo Nacional Chileno	\N	\N	f
26	36	\N	3	Se aprueban en bloque 5 concesiones gratuitas incluyendo a Corporacion Educacional Cades Barnea para Escuela Especial de Lenguaje	unanimidad	33	0	0	1	\N	\N	Corporacion Educacional Cades Barnea	\N	\N	f
27	37	\N	3	Se aprueban en bloque 5 concesiones gratuitas incluyendo a Fundacion Integra para jardin infantil en Penalolen	unanimidad	33	0	0	1	\N	\N	Fundacion Educacional para el Desarrollo Integral de la Ninez	\N	\N	f
28	38	\N	3	Se aprueban en bloque 5 concesiones gratuitas incluyendo a Junta de Vecinos Hermanos Carrera para sede social en Colina	unanimidad	33	0	0	1	\N	\N	Junta de Vecinos Hermanos Carrera	\N	\N	f
29	39	\N	3	Se aprueban en bloque 5 concesiones gratuitas incluyendo a Junta de Vecinos Poblacion O'Higgins para sede social en Colina	unanimidad	33	0	0	1	\N	\N	Junta de Vecinos Poblacion O'Higgins	\N	\N	f
30	40	\N	3	Se aprueba concesion gratuita de corto plazo por 5 anos a Iglesia Evangelica Pentecostal Monte de los Olivos para templo y ayuda social	mayoria	26	0	7	1	\N	\N	Iglesia Evangelica Pentecostal Monte de los Olivos	\N	\N	f
31	41	\N	3	Se aprueba transferencia de $110.000.000 a Corporacion Fondo de Agua Santiago-Maipo para Expo Agua Santiago 2026	unanimidad	33	0	0	1	110000000.00	CLP	Corporacion Fondo de Agua Santiago Maipo	\N	Crisis ambiental y climatica	f
32	42	\N	3	Se aprueba distribucion de $9.139.000.000 del Programa Mejoramiento Urbano PMU 2026 entre 47 comunas segun propuesta presentada	unanimidad	33	0	0	1	9139000000.00	CLP	47 municipalidades de la Region Metropolitana	\N	PMU	f
33	43	\N	3	Se aprueba Modificacion Presupuestaria N°4 creando asignacion 556 por $287.290.000 para proyecto Inspira STEM con reduccion de asignacion Fondo Productividad y Desarrollo sin distribuir	unanimidad	34	0	0	0	287290000.00	CLP	Universidad Metropolitana de Ciencias de la Educacion	\N	Fondo Regional para la Productividad y el Desarrollo	f
34	44	\N	3	Se aprueba convocatoria FRIL 2026 con distribucion de $1.000.000.000 para cada una de las 18 comunas rurales de la region	unanimidad	33	0	0	1	18000000000.00	CLP	18 municipalidades rurales de la Region Metropolitana	\N	FRIL	f
35	45	\N	3	Se aprueba distribucion de $1.255.110.992 del Programa de Mejoramiento de Barrios PMB 2026 entre comunas de la region segun propuesta presentada	unanimidad	34	0	0	0	1255110992.00	CLP	Municipalidades de la Region Metropolitana	\N	PMB SUBDERE	f
36	46	\N	3	Se aprueba pronunciamiento favorable SEIA para proyecto inmobiliario Modificacion Praderas de lo Aguirre Pudahuel	unanimidad	33	0	0	1	\N	\N	\N	\N	\N	f
37	47	\N	3	Se aprueba pronunciamiento favorable SEIA para proyecto inmobiliario DS49 Valle Merced Melipilla	unanimidad	33	0	0	1	\N	\N	\N	\N	\N	f
38	48	\N	3	Se aprueba pronunciamiento favorable SEIA para conjunto residencial de integracion social DS19 Paseo Las Aves Cerrillos	unanimidad	33	0	0	1	\N	\N	\N	\N	\N	f
39	49	\N	3	Se aprueba pronunciamiento favorable SEIA para continuidad operativa planta tratamiento residuos industriales Hidronor Pudahuel	mayoria	29	0	5	1	\N	\N	\N	\N	\N	f
40	50	\N	3	Se aprueba pronunciamiento favorable SEIA para conjuntos residenciales Vinedos Alto del Maipo 1, 2 y 3 Isla de Maipo	unanimidad	33	0	0	1	\N	\N	\N	\N	\N	f
41	51	\N	3	Se aprueba pronunciamiento favorable SEIA para condominio viviendas sociales DS49 Mirador Cerro Colorado I y II Renca	unanimidad	33	0	0	1	\N	\N	\N	\N	\N	f
42	52	\N	3	Se aprueba pronunciamiento favorable SEIA para proyecto Nueva Esperanza de Nos San Bernardo	unanimidad	33	0	0	1	\N	\N	\N	\N	\N	f
\.


--
-- Data for Name: asistencia; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.asistencia (id, sesion_id, consejero_id, estado) FROM stdin;
1	1	1	presente
2	1	2	presente
3	1	3	presente
4	1	4	presente
5	1	5	presente
6	1	6	presente
7	1	7	presente
8	1	8	presente
9	1	9	presente
10	1	10	presente
11	1	11	presente
12	1	12	presente
13	1	13	presente
14	1	14	presente
15	1	15	presente
16	1	16	presente
17	1	17	presente
18	1	18	presente
19	1	19	presente
20	1	20	presente
21	1	21	presente
22	1	22	presente
23	1	23	presente
24	1	24	presente
25	1	25	presente
26	1	26	presente
27	1	27	presente
28	1	28	presente
29	1	29	presente
30	1	30	presente
31	1	31	presente
32	1	32	presente
33	1	33	presente
34	1	34	presente
35	1	35	licencia
36	2	1	presente
37	2	2	presente
38	2	3	presente
39	2	4	presente
40	2	5	presente
41	2	6	presente
42	2	7	presente
43	2	8	presente
44	2	9	presente
45	2	10	presente
46	2	11	presente
47	2	12	presente
48	2	13	presente
49	2	14	presente
50	2	15	presente
51	2	16	presente
52	2	17	presente
53	2	18	presente
54	2	19	presente
55	2	20	presente
56	2	21	presente
57	2	22	presente
58	2	23	presente
59	2	24	presente
60	2	25	presente
61	2	26	presente
62	2	27	presente
63	2	28	presente
64	2	29	presente
65	2	30	presente
66	2	31	presente
67	2	32	presente
68	2	33	presente
69	2	34	presente
70	2	35	licencia
71	3	1	presente
72	3	2	presente
73	3	3	presente
74	3	4	presente
75	3	5	presente
76	3	6	presente
77	3	7	presente
78	3	8	presente
79	3	9	presente
80	3	10	presente
81	3	11	presente
82	3	12	presente
83	3	13	presente
84	3	14	presente
85	3	15	presente
86	3	16	presente
87	3	17	presente
88	3	18	presente
89	3	19	presente
90	3	20	presente
91	3	21	presente
92	3	22	presente
93	3	23	presente
94	3	24	presente
95	3	25	presente
96	3	26	presente
97	3	27	presente
98	3	28	presente
99	3	29	presente
100	3	30	presente
101	3	31	presente
102	3	32	presente
103	3	33	presente
104	3	34	presente
105	3	35	licencia
\.


--
-- Data for Name: categorias; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.categorias (id, nombre, descripcion) FROM stdin;
1	fndr	Fondo Nacional de Desarrollo Regional, proyectos FNDR
2	fril	Fondo Regional de Iniciativa Local, proyectos comunitarios
3	educacion	SLEP, colegios, becas, infraestructura educativa, designaciones de comites
4	salud	Hospitales, CESFAM, equipamiento medico, salud regional
5	transporte	Transporte publico, vialidad, conectividad, Metro, EFE
6	vivienda	Vivienda social, campamentos, urbanizacion
7	seguridad	Seguridad ciudadana, camaras, equipamiento policial
8	medioambiente	Areas verdes, residuos, calidad del aire, gestion hidrica
9	cultura_eventos	Festivales, deportes, fiestas patrias, eventos comunales
10	infraestructura	Sedes sociales, multicanchas, edificios publicos, obras viales
11	urbanismo	Planes reguladores, plan regulador metropolitano, ordenamiento territorial
12	legal	Convenios, oficios, recursos legales, modificaciones normativas
13	presupuesto	Presupuesto regional, modificaciones presupuestarias, distribucion de fondos
14	designaciones	Designacion de representantes en comites y directorios
15	convenios_programacion	Convenios de programacion con ministerios y servicios
16	participacion	Participacion ciudadana, organizaciones territoriales, dirigentes
\.


--
-- Data for Name: comisiones; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.comisiones (id, nombre, descripcion, presidente_id) FROM stdin;
4	Educacion y Cultura	\N	19
5	Desarrollo Social	\N	29
6	Medio Ambiente y Desarrollo Sustentable	\N	18
7	Infraestructura, Transporte y Aguas Lluvias	\N	18
8	Coordinacion	\N	22
9	Rural	\N	28
10	SEIA	\N	5
\.


--
-- Data for Name: consejeros; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.consejeros (id, nombre_completo, es_presidente, activo) FROM stdin;
1	Claudio Orrego Larrain	t	t
2	Edith Aedo Meza	f	t
3	Beatriz Albornoz Soto	f	t
4	Nicole Aguilera Ramirez	f	t
5	Alvaro Bellolio Avaria	f	t
6	Sonja del Rio Becker	f	t
7	Rodrigo Donoso Baeza	f	t
8	Maricel Donoso Doria	f	t
9	Ignacio Dulger Castillo	f	t
10	Gabriela Gallardo Fuentes	f	t
11	Jaime Gonzalez Kazazian	f	t
12	Pedro Herreros Bejares	f	t
13	Nicolas Jara Lira	f	t
14	Karin Luck Urban	f	t
15	Sadi Melo Moya	f	t
16	Sergio Morales Mendez	f	t
17	Claudina Nunez Jimenez	f	t
18	Felipe Obal Duran	f	t
19	Nebbia Otarola Leon	f	t
20	Valeria Ortega Contreras	f	t
21	Carolina Oteiza Fuenzalida	f	t
22	Maria Valeria Ponti Risetti	f	t
23	Danae Prado Carmona	f	t
24	Maria Eugenia Puelma Alfaro	f	t
25	Javier Ramirez Gonzalez	f	t
26	Dioscoro Rojas Campos	f	t
27	Felipe Serey Guerra	f	t
28	Cristina Soto Messina	f	t
29	Jose Soto Madrid	f	t
30	Carlos Telleria Gonzalez	f	t
31	Victor Valdes Landeros	f	t
32	Leslie Venegas Venegas	f	t
33	Alfredo Vergara Catalan	f	t
34	Marcelo Zunino Poblete	f	t
35	Ximena Peralta Fierro	f	t
\.


--
-- Data for Name: intervenciones; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.intervenciones (id, tema_id, consejero_id, resumen_intervencion, orden) FROM stdin;
1	4	27	Serey defendió la decisión ministerial argumentando que los convenios no son contratos y el Estado tiene facultades exorbitantes. Señaló que la administración carece de recursos y debe priorizar urgencias como reconstrucción post-incendios. Indicó que no se trata de no hacer el proyecto sino de repriorizar según disponibilidad presupuestaria. Propuso además trabajar en convenios escolares para infraestructura educativa dado el contexto de la tragedia de Calama.	1
2	4	22	Ponti solicitó no relativizar el proyecto solo como ciclovía sino verlo como dignidad para comunas históricamente rezagadas del eje Alameda-Pajaritos. Pidió que el gobernador invite a presidentes y vicepresidentes de comisiones a reuniones de prensa, enfatizando que el consejo es un órgano colegiado que debe participar en estas conversaciones.	2
3	4	13	Jara destacó dos dimensiones del problema: se perjudican los intereses regionales al faltar a un convenio donde ya se invirtió dinero, y se perjudica a comunas que más lo necesitan. Señaló que con otro proyecto aprobado se eliminará la ciclovía existente en Estación Central sin alternativa para ciclistas. Enfatizó que relativizar convenios debilita la institucionalidad y pidió compromiso del cuerpo colegiado para sacar adelante esta obra de justicia territorial.	3
4	4	21	Oteiza lamentó que el ministro Poduje hable de temas importantes solo por televisión sin conversaciones políticas previas. Criticó que el gobierno republicano, con 25 días, actúe como si llevara años gobernando, confundiendo gobernar con trabajar en el Estado. Expresó preocupación por cómo hacer futuros convenios si no se cumplen los existentes, y pidió a consejeros republicanos que hablen con sus autoridades para llegar a buen puerto.	4
5	4	26	Rojas planteó diferencias filosóficas sobre la concepción del Estado, señalando que el sector republicano busca achicarlo mientras la oposición quiere fortalecerlo. Argumentó que el problema no es falta de recursos sino evasión de impuestos empresariales, y que el gobierno debería cobrar impuestos correctamente en lugar de argumentar falta de caja.	5
6	4	24	Puelma valoró esta como una gran conversación sobre miradas político-ideológicas distintas respecto al rol del Estado. Propuso generar un momento especial para discutir a fondo estas diferencias. Cuestionó hasta qué punto son un órgano colegiado, señalando que deberían participar siempre en discusiones con el Estado mediante delegaciones, no solo ser informados. Mencionó temas pendientes como descentralización educativa y necesidad de reunión con ministra de Salud para definir prioridades en infraestructura sanitaria.	6
7	4	9	Dulger reconoció que los intereses del gobierno regional no siempre confluyen con los del gobierno central cuando hay recursos escasos. Señaló que el ministro Poduje fue claro en que debe reorganizar recursos por emergencias en Viña del Mar y Biobío. Propuso dos caminos: solicitar reuniones para aclaraciones vía el gobernador, o reorganizar proyectos regionales menos relevantes para financiar este que es importante.	7
8	4	15	Melo criticó el equívoco de confundir caja con presupuesto, señalando que existen instrumentos presupuestarios para emergencias (2%). Cuestionó el diagnóstico del gobierno republicano, mencionando que se suspendió discusión del paquete de 40 medidas por sospechas de diagnóstico erróneo. Señaló que el gobierno prometió seguridad ciudadana pero no hay plan concreto. Llamó a racionalidad en la política que requiere acuerdos, conversación y respeto a instrumentos de gestión como los convenios de programación que ningún gobierno anterior había rechazado.	8
9	4	23	Prado reflexionó sobre la necesidad de actuar como cuerpo colegiado representando a sus circunscripciones, no a un gobierno particular. Pidió coherencia al exigir fiscalizaciones y ejecución de unos proyectos mientras se justifica la detención de otros. Expresó preocupación por externalidades negativas de obras detenidas, incluyendo inseguridad para las personas.	9
10	4	3	Albornoz enfatizó que la ciclovía no es solo deporte sino también seguridad, relatando que su primo murió atropellado. Señaló que las ciclovías pueden evitar accidentes al dar espacios seguros fuera de las calles vehiculares.	10
11	5	24	Puelma explicó que su bancada no participó el lunes en coordinación por acompañar a Claudina Nuñez en actividad de la PDI. Solicitó respetuosamente tiempo para estudiar la propuesta ya que tienen dudas sobre su formación y no tienen condiciones para votar en ese momento.	1
12	5	22	Ponti aclaró que el requerimiento no nació solo el lunes sino que había sido conversado anteriormente, surgiendo de consejeros de Desarrollo Social por la gran cantidad de usos gratuitos. Explicó que se había revisado la voluntad previamente y el lunes el secretario ejecutivo expuso cómo implementarla. Indicó que funcionaría similar a SEIA.	2
13	5	21	Oteiza solicitó cinco minutos de receso para conversar entre jefes de bancada, señalando que el espíritu de coordinación siempre ha sido conversar y evitar que lleguen temas no vistos previamente.	3
14	6	4	Se inhabilitó por Ley 19.175 Artículo 35 referente a causas laborales, aplicando la inhabilidad a todas las concesiones de uso gratuito de la tabla.	1
15	6	11	González señaló que el mejor seguro de salud históricamente era Lan Chile porque permitía llegar a hospitales metropolitanos ante falta de especialistas en regiones. Destacó que pacientes y familias se enfrentan a murallas administrativas y suspensiones de procedimientos, requiriendo lugares dignos de espera. Felicitó la iniciativa como forma de dar dignidad en atención de salud.	2
16	6	34	Zunino felicitó al alcalde que cumplía años ese día, destacando la importancia de tener espacios de confort y tranquilidad para personas operadas o con problemas de salud, lo que mejora su estado de salud. Valoró el objetivo del lugar y envió abrazo al alcalde.	3
17	6	26	Rojas saludó al alcalde Redlich de Quirihue calificándolo como gran alcalde, celebrando las renovaciones que está realizando. Manifestó su cariño personal aunque reconociendo diferencias políticas, definiéndose como parte del lote de los amigos.	4
18	6	30	Tellería agradeció la iniciativa señalando que da gusto aprobar estas acciones. Destacó conocer bien la zona de Ñuble y Quirihue viniendo del mundo rural, señalando que es zona aislada y lejos de Chillán. Manifestó compromiso permanente con este tipo de iniciativas.	5
19	8	23	Prado agradeció a Anastasia y las integrantes del sindicato, destacando conocer su trabajo histórico en rescate de memoria de mujeres trans, protección, prevención de ETS/VIH. Señaló que realizan trabajo integral y es importante que el consejo destine bienes de uso público correctamente para uso comunitario y social, evitando que estén en desuso. Lamentó que haya discriminaciones y prejuicios en lugar de centrarse en el uso correcto de inmuebles. Su bancada PC-Independiente apoyó la solicitud.	1
20	8	22	Ponti saludó a las integrantes destacando haber trabajado con ellas como directora del Observatorio de No Discriminación en segundo gobierno Piñera, impulsando campaña de respeto y Ley de Identidad de Género. Destacó que es organización histórica en lucha de disidencias que trabaja nacional y regionalmente rescatando mujeres vulneradas por comercio sexual, acompañándolas psicológicamente, dando dignidad a la vejez, y tratando casos de silicona industrial. Enfatizó que no solo rescatan sino buscan otras formas de trabajo para vejez digna. Manifestó su apoyo absoluto.	2
21	8	32	Venegas hizo reconocimiento señalando que todas las mujeres saben lo que cuesta salir adelante, y las mujeres trans son para ella el grupo más postergado y excluido. Relató conocer mujeres trans profesionales y empatizar con su lucha contra exclusión diaria. Valoró su valentía para definir libremente su trayectoria de vida y ser diferentes. Lamentó falta de apoyo institucional recordando resultado anterior negativo para organización similar. Desde bancada Frente Amplio valoró su valentía y expresó deseo de mayor apoyo estatal.	3
22	13	3	Albornoz relató que su primo murió atropellado y enfatizó que las ciclovías no son solo para deporte sino también para seguridad, ya que evitan que ciclistas circulen por calles vehiculares reduciendo accidentes.	1
23	14	24	Puelma solicitó reproche político al ministro Poduje por ordinariez en opiniones sobre el consejo y gobernador, y pidió investigar si hay abandono de deberes al retirarse unilateralmente de convenio firmado. Criticó niveles de odiosidad hacia consejeros y pobladores.	1
24	15	12	Herreros reconoció esfuerzo del Gore en inversión rural pero propuso avanzar en convenio con INDAP para reducir costos energéticos de agricultura familiar, promover eficiencia energética e incorporar renovables. Fundamentó que aumento de costos de energía y combustibles reduce rentabilidad, limita producción y tensiona sistema agroalimentario. Citó ejemplo de Gore Maule que aprobó cartera con INDAP, llamando a articulación institucional para soluciones concretas de alto impacto.	1
25	16	30	Tellería se identificó como defensor de tradiciones chilenas e invitó al gobernador y consejeros al Cuasimodo del domingo 12 de abril, destacando que el de Colina es el más grande de Chile. Expresó que es gran fiesta y orgullo para el territorio.	1
26	16	11	González recordó a Tellería que uno de los Cuasimodo más antiguos está en Talagante, invitando a misa en parroquia Inmaculada Concepción y ofreciendo asistir también al de Colina. Describió la tradición de acompañar al sacerdote resguardando al santísimo, destacándola como hermosa tradición de zona central que rescata lo nuestro y culmina Cuaresma/Semana Santa con actividad familiar.	2
27	17	28	Soto pidió confirmación de que convenio Gore-MOP-DOH para mundo rural seguirá adelante. Criticó que sector republicano solo apoya gobierno nacional en lugar de pelear por institución regional, contrastando con periodo anterior donde había diálogo. Expresó preocupación por complicaciones venideras en mundo rural/urbano y por subida de UF que afectará créditos. Manifestó preocupación particular por bajo avance en temas de agua con MOP.	1
28	19	19	Presenta la propuesta de designación explicando el marco normativo según la Ley 21.040 y el Decreto N° 101 del Ministerio de Educación. Informa que la comisión se reunió el 17 de marzo con participación de 10 consejeros para entrevistar candidatos. Anuncia su inhabilitación para la votación del SLEP Los Libertadores por razones laborales. Presenta a Patricia Jofré Cáceres como candidata seleccionada con 307 puntos.	1
29	19	27	Declara su inhabilitación en virtud del Artículo 35 de la Ley de Gobiernos Regionales por razones laborales.	2
30	20	19	Presenta la propuesta de designación de Ignacio Maldonado Blásquez quien obtuvo la máxima puntuación con 281 puntos. Reitera su inhabilitación por trabajar en el SLEP Los Libertadores y solicita someter la propuesta a votación.	1
31	22	11	Felicito al Gobernador por la visita al puerto de San Antonio y destaco la importancia de planificar la infraestructura necesaria para manejar el aumento de flujo de camiones que generara la expansion portuaria, incluyendo puertos secos y servicios para camioneros, para evitar impactos negativos en las comunas.	1
32	22	34	Valoro la exposicion del administrador regional con datos duros sobre avances y situacion presupuestaria. Destaco la importancia de que los consejeros tengan informacion objetiva y fundamentada para responder a la opinion publica de manera responsable, sin caer en posiciones partidistas.	2
33	28	11	Felicito a la Corporacion de Asistencia Judicial y destaco su labor ardua en condiciones dificiles con pocos recursos. Recordo su experiencia como practicante en Huechuraba trabajando en oficina con piso de tierra y sin computador.	1
34	30	30	Destaco el trabajo del presidente Luis Parada y senalo que es el APR mas grande de Lampa, de Chacabuco, de la region metropolitana y posiblemente de Chile con casi 5.000 medidores. Reconocio su labor ante los problemas de agua en la provincia.	1
35	32	29	Destaco que Los Maitenes es una comunidad vapuleada por el desarrollo, con cortes de suministro de agua por canales y sin electricidad porque AES Gener corto el suministro. Senalo que esta concesion es un balsamo y un carino para que puedan seguir funcionando.	1
36	41	18	Destaco que en Expo Agua 2025 participaron 46 de 52 comunas, 95 dirigentes de APR, y municipalidades de otras regiones (Valparaiso, O'Higgins, Coquimbo, Araucania, Bio Bio), lo que muestra que somos punto neuralgico en gestion hidrica y capacitacion de equipos municipales.	1
37	41	24	Planteo necesidad de ver elementos de seguimiento a convenios realizados en 2025, como se estan concretizando en comunidades y resultados mas alla de seminarios. Enfatizo importancia de promocion del agua, agricultura y necesidad de producir alimentos.	2
38	41	8	Como bancada PS-PPD compuesta mayormente por consejeros rurales, valoro el informe de ejecucion 2025 y quedo satisfecha con respuesta. Destaco relevancia del agua para mundo rural y compromiso de apoyar difusion y promocion como puente con municipios, vecinos, comites y APR.	3
39	45	4	Cuestiono que proyecto N°1 de alcantarillado de Calera de Tango que cumple con bases (mismo que se aplico con FRIL 2025) no quedara segun evaluacion. Tambien que proyecto de Buin beneficia 6 familias con saneamiento y titulo de dominio, no solo una familia como se informo. Planteo que al votar a favor perjudica a Buin, Calera de Tango y zona rural de San Bernardo (Lo Herrera, Estancilla, Infante, Catemito, Nos) que no esta considerada.	1
40	45	2	Agradecio al Ejecutivo y a Mauricio la gestion con El Manzano, teniendo paciencia para que el comite se formara y no quedara fuera el proyecto.	2
41	45	11	Aclaro que el problema no es del Gobierno Regional sino de SUBDERE. Explico que GORE aprueba idea de proyecto y problema real es ejecucion presupuestaria de PMB. SUBDERE no es clara con municipalidades sobre requisitos y tiene mal manejo en gestion y ejecucion, pareciendo responsabilidad del GORE cuando compete exclusivamente a la subsecretaria.	3
42	45	8	Planteo que la comision fue conflictiva porque pone a consejeros entre espada y pared. Sugirio que GORE debe indicar en circular parametros de montos para distribuir mejor recursos. Municipios de Padre Hurtado y El Monte preguntan por que no quedaron y debe acreditarse en documento que fue por distribuir mejor la torta. Solicito que Comision Rural sea parte del proceso para proximo ano con mas tiempo, no en periodo estival ni cerca del pleno.	4
43	45	28	Se sumo a intervenciones anteriores y cuestiono donde estan los problemas: si alcaldes no logran entender el proyecto o si hay fallas en el sistema. Cito caso de Maria Pinto con emergencia en planta de tratamiento que no quedo por postular arriba de $300 millones. Sugirio revisar si dividir la torta en 18 municipios rurales podria ser accion a considerar.	5
44	49	19	Manifesto que se abstendra porque la planta Hidronor cerca del aeropuerto ha presentado varias irregularidades explosivas especialmente en traslado de material de residuos. No quiere que vuelva a ocurrir lo que ocurrio en Renca debido al traslado de material peligroso que pueda afectar a otras personas.	1
\.


--
-- Data for Name: sesiones; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sesiones (id, numero_sesion, tipo_sesion, fecha, hora_inicio, hora_termino, presidente, secretario_ejecutivo, archivo_pdf, archivo_texto, resumen_general, created_at) FROM stdin;
1	7	ordinaria	2026-04-08	09:45:00	\N	Claudio Orrego Larrain	Jose Zuleta Bove	SESIÓN 07-26  (08-04).pdf	sesion_07_26_08_04.txt	La sesión ordinaria N°7 del Consejo Regional Metropolitano abordó temas críticos de institucionalidad y desarrollo territorial. El punto más debatido fue la suspensión unilateral por parte del Ministerio de Vivienda del tercer tramo de la ciclovía Alameda, obra contemplada en un convenio de programación firmado por diez instituciones. El gobernador Orrego enfatizó que esta decisión afecta la legalidad de los convenios de programación como instrumento de descentralización, solicitó reunión con el ministro Poduje sin obtener respuesta, y llamó al consejo a defender la institucionalidad regional más allá de colores políticos. Se generó un debate entre consejeros republicanos que justificaron la decisión por prioridades presupuestarias post-emergencias, y otros sectores que cuestionaron dejar obras inconclusas en sectores vulnerables. En materia de concesiones de uso gratuito, se aprobaron cuatro solicitudes: una residencial para pacientes de Quirihue, un centro de rehabilitación de adicciones, una casa comunitaria para trabajadoras sexuales trans (con votación dividida), y un centro de formación cooperativa. También se aprobaron dos proyectos SEIA por unanimidad.	2026-05-07 11:53:47.676215
2	2	extraordinaria	2026-03-25	12:36:00	\N	Claudio Orrego Larrain	Jose Zuleta Bove	SESIÓN EXT. 02-26  (25-03).pdf	sesion_ext_02_26_25_03.txt	Sesión extraordinaria convocada exclusivamente para tratar designaciones de representantes del Gobierno Regional ante comités directivos de Servicios Locales de Educación Pública (SLEP). La Comisión de Educación y Cultura, presidida por la consejera Nebbia Otárola, presentó dos propuestas de designación para los SLEP Los Parques y Los Libertadores, ambas aprobadas por mayoría. Patricia Jofré Cáceres fue designada para el SLEP Los Parques con 29 votos a favor y 3 abstenciones, mientras que Ignacio Maldonado Blásquez fue designado para el SLEP Los Libertadores con 28 votos a favor y 4 abstenciones. La consejera Otárola se inhabilitó en la segunda votación por razones laborales, al igual que el consejero Serey en ambas votaciones.	2026-05-07 11:54:18.608333
3	6	ordinaria	2026-03-25	09:30:00	\N	Claudio Orrego Larrain	Jose Zuleta Bove	SESIÓN 06-03  (25-03).pdf	sesion_06_03_25_03.txt	La sesión ordinaria N°6 del CORE Metropolitano abordó múltiples temas estratégicos para la región. El Gobernador Orrego informó sobre recortes presupuestarios significativos (dieciocho mil millones en 2025 y similar monto en 2026), lo que ha generado retrasos en pagos a proveedores y la decisión de congelar el Subtítulo 29 (vehículos y equipamiento). Destacó también que la Fiscalía decidió no perseverar en la investigación por no encontrar vestigios de ilícito, y la Corte de Apelaciones rechazó el desafuero por 24 votos contra 0. El administrador regional presentó un completo diagnóstico del crecimiento institucional: el GORE pasó de 55 a 150 contratos administrados, de 26 a 53 procesos formalizados, y de 10 a 29 sistemas informáticos, todo con un aumento de solo 19 funcionarios permanentes. Se aprobaron múltiples concesiones de uso gratuito para municipalidades, organizaciones comunitarias, iglesias y establecimientos educacionales. También se aprobó el financiamiento de $110 millones para Expo Agua 2026, la distribución del PMU 2026 por $9.139 millones, el FRIL Rural 2026 por $18.000 millones para 18 comunas, y el PMB por $1.255 millones. La sesión reflejó tensiones por la reducción drástica de recursos disponibles y la necesidad de priorizar entre múltiples demandas territoriales.	2026-05-07 12:29:11.976485
\.


--
-- Data for Name: suscriptores; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.suscriptores (id, nombre_completo, email, token_baja, activo, fecha_suscripcion) FROM stdin;
\.


--
-- Data for Name: temas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.temas (id, sesion_id, numero_tabla, seccion, titulo, resumen, texto_completo, comision_id, presentado_por, created_at) FROM stdin;
1	1	\N	tabla	Aprobación Acta Sesión Ordinaria N°6	Se sometió a votación el acta de la Sesión Ordinaria N°6 celebrada el 25 de marzo de 2026. La aprobación fue unánime con 33 votos a favor.	\N	\N	\N	2026-05-07 11:53:47.676215
2	1	\N	tabla	Aprobación Acta Sesión Extraordinaria N°02	Se sometió a votación el acta de la Sesión Extraordinaria N°02 celebrada también el 25 de marzo de 2026. La aprobación fue unánime con 33 votos a favor.	\N	\N	\N	2026-05-07 11:53:47.676215
3	1	\N	cuenta	Cuenta del Gobernador: Actividades y reuniones institucionales	El gobernador Orrego presentó su cuenta de actividades destacando visitas en terreno a proyectos hídricos en Lo Espejo, reuniones con juntas vecinales, lanzamiento del fondo Comunidad Activa, inauguraciones de espacios públicos y obras viales. Reportó reuniones con nuevas autoridades de gobierno incluyendo ministros de Seguridad, Ciencias, Medio Ambiente y Obras Públicas. En esta última destacó compromisos de mantener convenios de programación en agua potable rural, colectores y Nueva Alameda, confirmación del parque Bueras y nudo Pajaritos, y acuerdo para transferir la intermodal La Cisterna al Metro. Expresó preocupación por la baja asignación del Fondo de Equidad Interregional a Santiago (solo 0.6% del total).	\N	\N	1	2026-05-07 11:53:47.676215
4	1	\N	cuenta	Situación Ciclovía Alameda y Convenio de Programación Nueva Alameda	El gobernador Orrego informó sobre la suspensión unilateral por parte del Ministerio de Vivienda del tercer tramo de la ciclovía Alameda (3.8 km, $6.000 millones), que forma parte del convenio de programación Nueva Alameda firmado en enero por diez instituciones con rango constitucional y legal. Enfatizó que el convenio tiene 70% de ejecución ($80.000 millones de $145.000 millones totales) y solo puede revocarse por acuerdo unánime de las partes. La ciclovía registra 160.000 viajes mensuales y conecta 44 km totales. Orrego criticó la falta de respuesta del ministro Poduje a solicitudes de reunión durante tres semanas y llamó a defender la institucionalidad de los convenios de programación como instrumento de descentralización. Manifestó disponibilidad a reprogramar pero rechazó incumplimiento unilateral.	\N	\N	1	2026-05-07 11:53:47.676215
12	1	\N	tabla	Aprobación cometidos de consejeros del 21 al 31 de marzo 2026	Se aprobaron por unanimidad los cometidos de consejeros regionales correspondientes al período del 21 al 31 de marzo de 2026. Los cometidos incluyen 77 actividades de participación en ceremonias de inicio, cierre e inauguración de proyectos comunitarios financiados por el Gobierno Regional, lanzamientos de programas, funciones culturales y teatrales, y eventos en las 52 comunas de la región. La votación fue unánime con 32 votos a favor.	\N	\N	\N	2026-05-07 11:53:47.676215
13	1	\N	varios	Ciclovía Alameda como tema de seguridad vial	La consejera Beatriz Albornoz intervino señalando que la ciclovía debe verse no solo como deporte sino también como tema de seguridad. Relató que su primo murió atropellado y que las ciclovías pueden evitar accidentes al permitir que ciclistas no tengan que andar por calles vehiculares.	\N	\N	\N	2026-05-07 11:53:47.676215
52	3	\N	tabla	Pronunciamiento SEIA Proyecto Nueva Esperanza de Nos San Bernardo	Se aprobo por unanimidad pronunciamiento favorable del CORE sobre proyecto Nueva Esperanza de Nos ubicado en la comuna de San Bernardo. Votado en bloque con otros tres proyectos.	\N	10	5	2026-05-07 12:29:11.976485
14	1	\N	varios	Reproche político al ministro Poduje y consulta legal sobre convenios	La consejera Puelma propuso un voto político de reproche al ministro Poduje por ordinariez en sus opiniones sobre el Consejo Regional y el gobernador, particularmente por usar el tema Procultura en argumentaciones. Solicitó averiguar si existe abandono de deberes cuando autoridad firma convenio y luego se retira unilateralmente, dado que el convenio es acto legal. Criticó niveles de odiosidad del ministro hacia consejeros y pobladores.	\N	\N	\N	2026-05-07 11:53:47.676215
15	1	\N	varios	Propuesta convenio Gore-INDAP para reducir costos energéticos agricultura	El consejero Pedro Herreros propuso trabajar en convenio entre Gobierno Regional e INDAP orientado a reducir costos energéticos de agricultura familiar campesina, promover eficiencia energética e incorporar energías renovables en sistemas productivos. Fundamentó que el aumento de costos de producción por energía y combustibles afecta directamente rentabilidad de pequeños agricultores. Citó como ejemplo el convenio aprobado por Gore Maule con INDAP abordando desarrollo productivo rural, sugiriendo replicar articulación institucional para generar soluciones concretas de alto impacto.	\N	\N	\N	2026-05-07 11:53:47.676215
16	1	\N	varios	Invitación Cuasimodo en Colina y comunas zona central	El consejero Carlos Tellería invitó al gobernador y consejeros a participar del Cuasimodo el domingo 12 de abril, destacando que en Colina se celebra el Cuasimodo más grande de Chile. Defendió esta tradición chilena de la zona central. El consejero Jaime González complementó recordando que uno de los más antiguos está en Talagante, invitando a misa en parroquia Inmaculada Concepción y ofreciendo asistir también al de Colina. Describió la tradición de acompañar al sacerdote resguardando al santísimo como actividad familiar que culmina Cuaresma y Semana Santa.	\N	\N	\N	2026-05-07 11:53:47.676215
17	1	\N	varios	Preocupación por continuidad de convenios regionales con gobierno nacional	La consejera Cristina Soto expresó preocupación por la continuidad de convenios ya establecidos con instituciones nacionales, particularmente el convenio Gore-MOP-DOH para el mundo rural. Solicitó confirmación de que no habrá problemas y criticó que en el período anterior se podía trabajar bien generando diálogos, mientras hoy ve un sector que solo apoya al gobierno nacional en lugar de pelear por la institución regional. Señaló que en tres meses habrá serias complicaciones en mundo rural y urbano, mencionando subida de UF que afectará créditos hipotecarios. Pidió confianza en que convenios en ejecución sigan adelante, expresando particular preocupación por bajo avance en temas de agua con el MOP.	\N	\N	\N	2026-05-07 11:53:47.676215
18	1	\N	varios	Reconocimiento a Dioscoro Rojas en diario El Mercurio	El gobernador Orrego destacó que el consejero Dioscoro Rojas apareció en portada del suplemento Mundo Mayor de El Mercurio con entrevista donde señala que lo importante es poder hacer lo que quiere. El artículo menciona que el cantautor retomó actividades como Core metropolitano tras complicaciones de salud y prepara su guaripola para resurgimiento del movimiento guachaca. Orrego recordó que se conocieron en fiestas guachacas antes de ser autoridades, felicitándolo por este reconocimiento como persona mayor de la cultura y autoridad regional.	\N	\N	\N	2026-05-07 11:53:47.676215
19	2	1	tabla	Designación de representante del GORE ante comité directivo del SLEP Los Parques	La Comisión de Educación y Cultura presentó la propuesta de designación de Patricia Jofré Cáceres como representante del Gobierno Regional ante el comité directivo del Servicio Local de Educación Pública (SLEP) Los Parques, que agrupa las comunas de Quinta Normal y Renca. La postulante obtuvo 307 puntos en el proceso de evaluación realizado por la comisión el 17 de marzo de 2026. El proceso cumple con lo establecido en la Ley 21.040 sobre educación pública y el Decreto N° 101 del Ministerio de Educación. La designación requiere aprobación del Consejo Regional según la normativa vigente.	\N	4	19	2026-05-07 11:54:18.608333
20	2	2	tabla	Designación de representante del GORE ante comité directivo del SLEP Los Libertadores	La Comisión de Educación y Cultura presentó la propuesta de designación de Ignacio Maldonado Blásquez como representante del Gobierno Regional ante el comité directivo del Servicio Local de Educación Pública (SLEP) Los Libertadores, que agrupa las comunas de Conchalí y Quilicura. El postulante obtuvo 281 puntos en el proceso de evaluación. La consejera Nebbia Otárola se inhabilitó en esta votación por trabajar en ese SLEP, junto con el consejero Felipe Serey por razones laborales. La designación fue aprobada por mayoría con 28 votos a favor y 4 abstenciones.	\N	4	19	2026-05-07 11:54:18.608333
21	3	1	tabla	Aprobacion del Acta N°5 de sesion del 10 de marzo 2026	El Consejo Regional aprobo por unanimidad el acta de la sesion ordinaria N°5 celebrada el 10 de marzo de 2026. No hubo observaciones ni debate sobre el contenido del acta.	\N	\N	\N	2026-05-07 12:29:11.976485
22	3	\N	cuenta	Cuenta del Presidente sobre actividades y gestion del Gobierno Regional	El Gobernador Orrego presento un extenso informe de actividades de las ultimas dos semanas, incluyendo visitas a terreno en provincias, inauguraciones de proyectos FRIL y entrega de equipamiento. Destaco la visita al puerto de San Antonio y la importancia estrategica de su expansion para la region. Informo sobre recortes presupuestarios significativos ($18.000 millones en 2025 y similar monto en 2026), lo que ha generado retrasos en pagos a proveedores por mas de $20.000 millones acumulados. Anuncio que se mantendra congelado el Subtitulo 29 (vehiculos y equipamiento) salvo excepciones justificadas. Comunico que la Fiscalia decidio no perseverar en la investigacion por no encontrar vestigios de ilicito, sumandose al rechazo del desafuero por 24-0 en la Corte de Apelaciones. El administrador regional Manuel Gallardo presento datos sobre el crecimiento institucional del GORE en los ultimos 5 anos: aumento del 272% en contratos administrados (de 55 a 150), del 104% en procesos formales (de 26 a 53), y de 190% en sistemas informaticos (de 10 a 29), todo con un aumento de solo 19 funcionarios permanentes en dotacion estable.	\N	\N	1	2026-05-07 12:29:11.976485
23	3	3.1	tabla	Concesion gratuita corto plazo Municipalidad de Pudahuel - COSAM	Se aprobo renovacion de concesion gratuita de corto plazo por 5 anos para inmueble ubicado en Santa Corina 8605, Pudahuel, donde funciona el Centro Comunitario de Salud Mental (COSAM) Pudahuel y sede comunitaria para organizaciones deportivas. El alcalde Italo Bravo explico que este COSAM, ubicado en Pudahuel Norte, atiende a la poblacion de Pudahuel Sur y es fundamental para la salud mental comunal.	\N	5	29	2026-05-07 12:29:11.976485
24	3	3.2	tabla	Concesion gratuita largo plazo Municipalidad de Maria Pinto - sedes comunitarias sector Santa Luisa	Se aprobo concesion gratuita de largo plazo para regularizar ocupacion de inmueble en Alquillay N°202, sector Santa Luisa, Maria Pinto, donde funcionan tres organizaciones comunitarias: junta de vecinos, club adulto mayor y centro cultural juvenil. La alcaldesa Jessica Mualim explico que son sedes con mas de 30 anos de antiguedad construidas en los anos 96-97 y requieren el largo plazo para postular a mejoramiento.	\N	5	29	2026-05-07 12:29:11.976485
25	3	3.3	tabla	Concesion gratuita corto plazo Municipalidad de La Reina - CEPASO	Se aprobo renovacion de concesion gratuita de corto plazo por 5 anos para Centro de Participacion Social (CEPASO) de La Reina, espacio comunitario donde se realizan talleres gratuitos, actividades comunitarias y se promueve la organizacion vecinal. El alcalde Jose Manuel Palacios destaco programas como la Escuela de Rock y capacitaciones en gastronomia focalizadas en sectores vulnerables.	\N	5	29	2026-05-07 12:29:11.976485
26	3	3.4	tabla	Concesion gratuita corto plazo Sindicato Profesionales Cine y Audiovisual - Casa Audiovisual	Se rechazo concesion gratuita de corto plazo solicitada por el Sindicato Nacional Interempresa de Profesionales y Tecnicos de Cine y Audiovisual para inmueble en Portales 3145-3149, Santiago, destinado a casa audiovisual para desarrollo sindical y gremial del sector. La votacion fue 13 a favor, 18 en contra y 2 abstenciones.	\N	5	29	2026-05-07 12:29:11.976485
27	3	3.5	tabla	Concesion gratuita corto plazo Corporacion Educacional Sonrisas de Nino - Escuela del Lenguaje Puente Alto	Se aprobo renovacion de concesion gratuita de corto plazo por 5 anos para patio de la Escuela del Lenguaje Sonrisas de Nino en Lope de Vega 592, Puente Alto, donde ademas se han desarrollado nuevos proyectos de infraestructura. El representante Jorge Espinoza destaco los 23 anos de trabajo en un sector vulnerable.	\N	5	29	2026-05-07 12:29:11.976485
28	3	3.6	tabla	Concesion gratuita corto plazo Corporacion Administrativa Poder Judicial - Centro Judicial Melipilla	Se aprobo renovacion de concesion gratuita de corto plazo por 5 anos para Centro Judicial de Melipilla en Merced 101 lote A3. El representante Edgardo Rodriguez destaco el proyecto de construccion en desarrollo. El consejero Gonzalez felicito la labor de la Corporacion de Asistencia Judicial en condiciones dificiles. El consejero Soto reconocio la lentitud del aparato estatal pero valoro el proyecto.	\N	5	29	2026-05-07 12:29:11.976485
29	3	3.7	tabla	Concesion gratuita largo plazo Cuerpo de Bomberos San Bernardo - Quinta Compania	Se aprobo concesion gratuita de largo plazo por 30 anos para Quinta Compania del Cuerpo de Bomberos de San Bernardo en Avenida Portales sitio 5, para dar continuidad al funcionamiento del cuartel y su ampliacion. El representante Paul Vasquez explico que beneficia al sector sur de San Bernardo (Pueblito de Nos) y se instalara campo de entrenamiento para cadetes.	\N	5	29	2026-05-07 12:29:11.976485
30	3	3.8	tabla	Concesion gratuita largo plazo Comite APR Santa Sara - estanque agua potable Batuco	Se aprobo concesion gratuita de largo plazo por 30 anos para Comite de Agua Potable Rural Santa Sara en Fundo Lo Fontecilla, Lampa, para construccion de estanque de almacenamiento de agua potable que cubrira deficit de factibilidad para cerca de 2.000 viviendas en Batuco. El consejero Telleria destaco el trabajo del presidente Luis Parada y senalo que es el APR mas grande de la comuna, provincia, region y posiblemente de Chile, con casi 5.000 medidores.	\N	5	29	2026-05-07 12:29:11.976485
31	3	3.9	tabla	Concesion onerosa largo plazo Buses Metropolitana - deposito Lo Prado	Se aprobo concesion onerosa (pagada) de largo plazo por 30 anos para Buses Metropolitana SA en Avenida General Bonilla 6100 lote A, Lo Prado, para normalizar ocupacion del deposito de buses urbanos. El representante Francisco Santander explico que operan desde 2014 con buses de dos pisos de Pudahuel a Penalolen y han colaborado con la municipalidad en punto seguro y estacionamiento municipal.	\N	5	29	2026-05-07 12:29:11.976485
32	3	3.10	tabla	Concesion gratuita largo plazo Comite APR Los Maitenes - sistema sanitario rural San Jose de Maipo	Se aprobo concesion gratuita de largo plazo por 30 anos para Comite de Agua Potable Rural Los Maitenes en Camino El Alfalfal km 13, poblacion Los Maitenes, San Jose de Maipo, para desarrollar proyecto de diseno, instalacion y servicio sanitario rural. El consejero Soto destaco que es una comunidad vapuleada por el desarrollo, con cortes de suministro de agua y electricidad por empresas, y que esta concesion es un balsamopara ellos.	\N	5	29	2026-05-07 12:29:11.976485
33	3	3.11	tabla	Concesion gratuita largo plazo Club Deportivo Union San Carlos - sede social y deportiva Penalolen/La Reina	Se aprobo concesion gratuita de largo plazo por 15 anos para Club Deportivo Union San Carlos en Tobias Barros 800, La Reina, para ocupar inmueble como sede social y desarrollo de actividades deportivas (futbol, ajedrez, domino, cartas, ping pong). El presidente Juan Carlos Gonzalez destaco que el club cumplio 82 anos y se haran cosas deportivas, sociales y culturales.	\N	5	29	2026-05-07 12:29:11.976485
34	3	3.12	tabla	Concesion gratuita largo plazo Iglesia Hermandad Pentecostal - templo San Bernardo Tejas de Chena	Se aprobo concesion gratuita de largo plazo por 15 anos para Iglesia Hermandad Pentecostal en Yungay 1090B, Poblacion Tejas de Chena, San Bernardo, para mantener administracion de propiedad donde se emplaza iglesia evangelica destinada al culto y actividad religiosa, con ayuda social y comunitaria a jovenes, adultos mayores y familias en riesgo social. El obispo Hector Rivera destaco el trabajo de rehabilitacion y colaboracion social.	\N	5	29	2026-05-07 12:29:11.976485
35	3	3.13	tabla	Concesion gratuita largo plazo Fundacion Circo Nacional Chileno - espacio patrimonio circense Santiago	Se aprobo en bloque (con otras 4 concesiones) concesion gratuita de largo plazo por 15 anos para Fundacion Circo Nacional Chileno en Balmaceda 1301 lotes 1C2B y 2C2D, Santiago, para dar continuidad al proyecto de proteccion del patrimonio circense. El director Angel Bruno destaco la designacion UNESCO como patrimonio inmaterial en 2025 y que sera espacio de investigacion y comunidad circense.	\N	5	29	2026-05-07 12:29:11.976485
36	3	3.14	tabla	Concesion gratuita largo plazo Corporacion Educacional Cades Barnea - Escuela Especial Lenguaje La Florida	Se aprobo en bloque concesion gratuita de largo plazo por 15 anos para Corporacion Educacional Cades Barnea en Blest Gana 10841, La Florida, para renovar uso donde se emplaza Escuela Especial de Lenguaje. La directora Ana Maria Soto destaco 26 anos de trayectoria rehabilitando ninos con trastornos de comunicacion de sectores vulnerables, con impacto en 100 familias.	\N	5	29	2026-05-07 12:29:11.976485
37	3	3.15	tabla	Concesion gratuita largo plazo Fundacion Educacional Desarrollo Integral Ninez - Jardin Infantil Penalolen	Se aprobo en bloque concesion gratuita de largo plazo por 8 anos para Fundacion Educacional para el Desarrollo Integral de la Ninez (Fundacion Integra) en Grecia 6891 lote A, Penalolen, para mantener funcionamiento de sala cuna y jardin infantil. La jefa de cobertura Gemita Hernandez destaco que atiende 312 ninos y ninas (60 bebes sala cuna, 252 parvulos) en sector Lo Hermida.	\N	5	29	2026-05-07 12:29:11.976485
38	3	3.16	tabla	Concesion gratuita corto plazo Junta de Vecinos Hermanos Carrera - sede social Colina	Se aprobo en bloque concesion gratuita de corto plazo por 5 anos para Junta de Vecinos Hermanos Carrera en Camino Los Ingleses 96, Colina, para renovar uso y continuar actividades comunales. La presidenta Maria Eloisa Quiroz destaco que es zona rural de Colina y la sede es muy importante para la comunidad.	\N	5	29	2026-05-07 12:29:11.976485
39	3	3.17	tabla	Concesion gratuita corto plazo Junta de Vecinos Poblacion O'Higgins - sede social Colina	Se aprobo en bloque concesion gratuita de corto plazo por 5 anos para Junta de Vecinos Poblacion O'Higgins en Arturo Prat 284, Colina, para renovar uso y continuar desarrollo de fines sociales. La presidenta Natalia Munoz destaco que son casi 3.000 pobladores, que es la tercera poblacion mas antigua de Colina y se sienten discriminados por estar detras de la carcel.	\N	5	29	2026-05-07 12:29:11.976485
40	3	3.18	tabla	Concesion gratuita corto plazo Iglesia Evangelica Pentecostal Monte de los Olivos - templo Penaflor	Se aprobo concesion gratuita de corto plazo por 5 anos para Iglesia Evangelica Pentecostal Monte de los Olivos en Pasaje Diez y Pasaje Nueve, Calle Dos y Calle Doce, Penaflor, para formalizar uso como espacio de culto y apoyo espiritual, familiar y social. El representante legal Emanuel Benjamin destaco 38 anos trabajando en sector vulnerable con rehabilitacion y ayuda en decisiones de vida.	\N	5	29	2026-05-07 12:29:11.976485
41	3	\N	tabla	Financiamiento Expo Agua Santiago 2026 - Corporacion Fondo de Agua Santiago Maipo	Se aprobo financiamiento de $110.000.000 para Expo Agua Santiago 2026 (proyecto total $241.500.000), ejecutado por la Corporacion Fondo de Agua Santiago-Maipo, bajo marco presupuestario Crisis Ambiental y Climatica. El evento surge como continuidad del exito de 2025 y busca fortalecer colaboracion publico-privada para enfrentar crisis hidrica, con foco especial en sector agricola y agroindustrial. Incluye exhibiciones de innovacion, seminario de alto nivel con especialistas nacionales e internacionales, y rueda de negocios para tecnologias hidricas. La consejera Puelma solicito ver elementos de seguimiento a convenios 2025 y resultados concretos en comunidades. La consejera Donoso destaco la importancia para el mundo rural y valoro el informe de ejecucion 2025. El Gobernador enfatizo que es la principal iniciativa de convergencia publico-privada en temas del agua y que se buscara mayor participacion de comunidades y organizaciones territoriales.	\N	6	18	2026-05-07 12:29:11.976485
42	3	\N	tabla	Distribucion recursos Programa Mejoramiento Urbano PMU 2026	Se aprobo por unanimidad distribucion de $9.139.000.000 del Programa Mejoramiento Urbano (PMU) linea tradicional 2026 entre 47 comunas de la region. La distribucion se realizo utilizando indicador compuesto que mide caracteristicas multidimensionales relacionadas con empleo, vulnerabilidad social, presupuesto municipal y capacidad de gestion. El detalle de asignacion por comuna fue presentado en documento adjunto a la convocatoria.	\N	7	18	2026-05-07 12:29:11.976485
43	3	\N	tabla	Modificacion Presupuestaria N°4 marzo 2026 - Proyecto Inspira STEM Universidad Metropolitana Ciencias Educacion	Se aprobo Modificacion Presupuestaria N°4 de marzo 2026 para financiar proyecto Inspira STEM de la Universidad Metropolitana de Ciencias de la Educacion por $287.290.000. La iniciativa busca abordar brechas de acceso y participacion en ciencias, tecnologia, ingenieria y matematicas, especialmente en estudiantes de mayor vulnerabilidad. Contempla formacion de 500 docentes en metodologias STEM con enfoque de genero, tres ferias cientificas territoriales y preuniversitario virtual gratuito que podria beneficiar hasta 20.000 estudiantes de ensenanza media. El Gobernador explico que el Fondo para la Productividad y Desarrollo se ha reducido en 70% desde 2024, disminuyendo la incidencia regional en determinar prioridades, lo que ahora se discute a nivel central.	\N	8	22	2026-05-07 12:29:11.976485
44	3	\N	tabla	Convocatoria FRIL 2026 - distribucion 18 mil millones entre 18 comunas rurales	Se aprobo por unanimidad convocatoria FRIL 2026 con distribucion equitativa de $1.000.000.000 para cada una de las 18 comunas rurales de la region, totalizando $18.000.000.000. El FRIL esta enfocado en financiar proyectos destinados a reducir brechas de transporte y conectividad, fortaleciendo equidad territorial y cohesion regional. Se propone postular iniciativas de conservacion y mejoramiento vial en comunas rurales.	\N	9	28	2026-05-07 12:29:11.976485
45	3	\N	tabla	Distribucion Programa Mejoramiento de Barrios PMB SUBDERE 2026	Se aprobo por unanimidad distribucion de $1.255.110.992 del Programa de Mejoramiento de Barrios (PMB) linea tradicional 2026, financiado con recursos SUBDERE. Los recursos se destinan a obras de agua potable, alcantarillado e infraestructura sanitaria para mejorar calidad de vida de poblacion con altos niveles de vulnerabilidad en marginalidad sanitaria. La consejera Soto destaco problematica de reduccion drastica del fondo: de $5.500 millones a $1.200 millones, dejando comunas fuera. Se solicito reunion con SUBDERE para explicar reduccion y trabajar con mayor anticipacion proximo ano. La consejera Aguilera cuestiono que proyectos de Calera de Tango y Buin que cumplian bases quedaran fuera, y que zona rural de San Bernardo no este considerada. La consejera Donoso planteo necesidad de establecer parametros de montos en circulares y participar mas activamente como Comision Rural en el proceso. El consejero Gonzalez aclaro que el problema es de SUBDERE en claridad de requisitos y manejo de gestion, no del GORE. El Gobernador explico que con reduccion de fondos, proyectos de $300 millones significan dejar fuera tres proyectos de otras comunas, y que se oficiara a SUBDERE para considerar proyectos no asignados.	\N	9	28	2026-05-07 12:29:11.976485
46	3	\N	tabla	Pronunciamiento SEIA Proyecto Inmobiliario Modificacion Praderas de lo Aguirre Pudahuel	Se aprobo por unanimidad pronunciamiento favorable del CORE sobre proyecto inmobiliario Modificacion Praderas de lo Aguirre ubicado en la comuna de Pudahuel. Votado en bloque con proyecto DS49 Valle Merced de Melipilla.	\N	10	5	2026-05-07 12:29:11.976485
47	3	\N	tabla	Pronunciamiento SEIA Proyecto Inmobiliario DS49 Valle Merced Melipilla	Se aprobo por unanimidad pronunciamiento favorable del CORE sobre proyecto inmobiliario DS49 Valle Merced ubicado en la comuna de Melipilla. Votado en bloque con proyecto Modificacion Praderas de lo Aguirre de Pudahuel.	\N	10	5	2026-05-07 12:29:11.976485
48	3	\N	tabla	Pronunciamiento SEIA Conjunto Residencial Integracion Social DS19 Paseo Las Aves Cerrillos	Se aprobo por unanimidad pronunciamiento favorable del CORE sobre conjunto residencial de integracion social DS19 Paseo Las Aves ubicado en la comuna de Cerrillos.	\N	10	5	2026-05-07 12:29:11.976485
49	3	\N	tabla	Pronunciamiento SEIA Continuidad Operativa Planta Tratamiento Residuos Industriales Hidronor Pudahuel	Se aprobo por mayoria pronunciamiento favorable del CORE sobre continuidad operativa de planta de tratamiento, disposicion y valorizacion de residuos industriales ubicada en Pudahuel. La consejera Otarola manifesto su abstencion senalando que la planta cerca del aeropuerto ha presentado irregularidades explosivas en traslado de material de residuos, y no quiere que vuelva a ocurrir lo de Renca. Votacion: 29 a favor, 5 abstenciones.	\N	10	5	2026-05-07 12:29:11.976485
50	3	\N	tabla	Pronunciamiento SEIA Conjuntos Residenciales Vinedos Alto del Maipo 1, 2 y 3 Isla de Maipo	Se aprobo por unanimidad pronunciamiento favorable del CORE sobre proyecto Conjuntos Residenciales Vinedos Alto del Maipo 1, 2 y 3 ubicado en la comuna de Isla de Maipo. Votado en bloque con otros tres proyectos.	\N	10	5	2026-05-07 12:29:11.976485
51	3	\N	tabla	Pronunciamiento SEIA Condominio Viviendas Sociales DS49 Mirador Cerro Colorado I y II Renca	Se aprobo por unanimidad pronunciamiento favorable del CORE sobre proyecto condominio de viviendas sociales DS49 Mirador Cerro Colorado I y II ubicado en la comuna de Renca. Votado en bloque con otros tres proyectos.	\N	10	5	2026-05-07 12:29:11.976485
5	1	\N	comision	Propuesta artículo transitorio: Subcomisión de Concesiones de Uso de Bienes Públicos	La Comisión de Coordinación propuso crear una subcomisión transitoria por tres meses dependiente de la Comisión de Desarrollo Social para abordar específicamente concesiones de uso gratuito de bienes fiscales. La propuesta busca optimizar el análisis técnico dado el alto volumen de solicitudes. La subcomisión sería abierta a los 34 consejeros con derecho a voz y voto, similar al modelo SEIA. Al finalizar el plazo presentaría informe evaluando pertinencia de continuidad. Fue aprobada por unanimidad en coordinación pero se retiró de votación en plenario a solicitud de la bancada PC que no participó en la reunión del lunes y solicitó tiempo para estudiarla.	\N	8	22	2026-05-07 11:53:47.676215
6	1	1	tabla	Concesión uso gratuito - Municipalidad de Quirihue	Se aprobó concesión de uso gratuito por cinco años del inmueble ubicado en Pucón 10819, departamento 402, La Florida, a favor de la Municipalidad de Quirihue. El objetivo es habilitar una residencia temporal para habitantes de Quirihue que viajan a la Región Metropolitana por motivos de salud, aliviando costos de alojamiento a familias de escasos recursos que enfrentan tratamientos médicos prolongados en Santiago. El alcalde Enrique Redlich relató casos concretos de familias endeudadas por estadías de meses en la capital. La votación fue unánime con 33 votos a favor.	\N	5	8	2026-05-07 11:53:47.676215
7	1	2	tabla	Concesión uso gratuito - Fundación Terapéutica Ciudad de Gosen	Se aprobó concesión de uso gratuito por cinco años del inmueble ubicado en Camino Vecinal 4676, Estación Central, a favor de la Fundación Terapéutica Ciudad de Gosen. El inmueble será habilitado como centro de tratamiento para prevención y rehabilitación de consumos de alcohol y drogas. La votación fue unánime con 32 votos a favor.	\N	5	8	2026-05-07 11:53:47.676215
8	1	3	tabla	Concesión uso gratuito - Sindicato Trabajadoras Sexuales Amanda Jofré	Se aprobó por mayoría concesión de uso gratuito por cinco años del inmueble en Fray Camilo 1051, Santiago, a favor del Sindicato Independiente de Trabajadoras Sexuales Amanda Jofré. El espacio será habilitado como Casa Comunitaria para desarrollar actividades de derechos humanos, salud comunitaria, formación y memoria, garantizando espacio seguro para población trans. La presidenta Anastasia Benavente explicó que no promueven trabajo sexual sino que se organizan para enfrentar violencias (expectativa de vida no supera 35 años), hacen alianzas con Minsal para prevención VIH/ETS con 0% de casos en 2025, y buscan dignidad y posibilidad de envejecer. La votación fue 18 a favor, 13 en contra, 2 abstenciones.	\N	5	8	2026-05-07 11:53:47.676215
9	1	4	tabla	Concesión uso gratuito - Fundación Elabora Chile	Se aprobó por mayoría concesión de uso gratuito por cinco años del inmueble ubicado en Géminis 1355, La Florida, a favor de la Fundación Elabora Chile. El inmueble será habilitado como centro comunitario y operativo para actividades de formación de cooperativas, educación continua, salud mental y emprendimiento laboral. El presidente José Baeza agradeció asegurando que el lugar cambiará y será espacio de encuentro, invitando a consejeros a fiscalizar día a día el trabajo mancomunado con el consejo regional. La votación fue 27 a favor con 6 abstenciones.	\N	5	8	2026-05-07 11:53:47.676215
10	1	5.1	tabla	Proyecto inmobiliario DS49 Parque Infante 1 y 2 - Renca	La Subcomisión SEIA analizó y aprobó por unanimidad el proyecto inmobiliario DS49 Parque Infante 1 y 2 ubicado en la comuna de Renca. El proyecto fue votado en conjunto con otro proyecto SEIA. La votación en plenario fue unánime con 30 votos a favor.	\N	10	5	2026-05-07 11:53:47.676215
11	1	5.2	tabla	Proyecto inmobiliario Parque Central - Puente Alto	La Subcomisión SEIA analizó y aprobó por unanimidad el proyecto inmobiliario Parque Central de la Inmobiliaria Todos los Santos S.A. ubicado en la comuna de Puente Alto. El proyecto fue votado en conjunto con otro proyecto SEIA. La votación en plenario fue unánime con 30 votos a favor.	\N	10	5	2026-05-07 11:53:47.676215
\.


--
-- Data for Name: temas_categorias; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.temas_categorias (tema_id, categoria_id) FROM stdin;
1	12
2	12
3	10
3	8
3	16
3	15
3	13
4	5
4	10
4	12
4	15
5	12
5	16
6	4
6	6
7	4
8	16
8	4
9	16
9	3
10	6
10	11
11	6
11	11
12	16
13	5
13	7
14	12
15	15
15	8
16	9
17	15
18	9
19	3
19	14
20	3
20	14
21	12
22	13
22	10
22	5
22	12
22	2
23	4
23	14
24	16
24	10
25	16
25	9
26	9
27	3
28	12
29	7
29	10
30	8
31	5
32	8
33	9
33	10
34	16
35	9
36	3
37	3
38	16
38	10
39	16
39	10
40	16
41	8
41	15
42	10
42	13
43	3
43	13
44	2
44	5
44	10
45	8
45	10
45	13
46	6
46	11
47	6
47	11
48	6
48	11
49	8
50	6
50	11
51	6
51	11
52	6
52	11
\.


--
-- Data for Name: votos_consejero; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.votos_consejero (id, acuerdo_id, consejero_id, voto) FROM stdin;
1	3	4	inhabilidad
2	4	4	inhabilidad
3	4	12	inhabilidad
4	5	4	inhabilidad
5	5	2	contra
6	5	6	contra
7	5	7	contra
8	5	9	contra
9	5	10	contra
10	5	11	contra
11	5	16	contra
12	5	18	contra
13	5	19	contra
14	5	27	contra
15	5	30	contra
16	5	31	contra
17	5	33	contra
18	5	29	abstencion
19	5	34	abstencion
20	6	4	inhabilidad
21	6	5	abstencion
22	6	12	abstencion
23	6	14	abstencion
24	6	18	abstencion
25	6	19	abstencion
26	6	25	abstencion
27	10	19	inhabilidad
28	10	27	inhabilidad
29	10	5	abstencion
30	10	4	abstencion
31	10	14	abstencion
32	11	19	inhabilidad
33	11	27	inhabilidad
34	11	4	abstencion
35	11	5	abstencion
36	11	12	abstencion
37	11	14	abstencion
38	13	4	inhabilidad
39	14	4	inhabilidad
40	15	4	inhabilidad
41	16	4	inhabilidad
42	17	4	inhabilidad
43	18	4	inhabilidad
44	19	4	inhabilidad
45	20	4	inhabilidad
46	21	4	inhabilidad
47	22	4	inhabilidad
48	23	4	inhabilidad
49	24	4	inhabilidad
50	25	4	inhabilidad
51	26	4	inhabilidad
52	27	4	inhabilidad
53	28	4	inhabilidad
54	29	4	inhabilidad
55	30	4	inhabilidad
56	30	3	abstencion
57	30	5	abstencion
58	30	17	abstencion
59	30	23	abstencion
60	30	20	abstencion
61	30	24	abstencion
62	30	32	abstencion
63	31	4	inhabilidad
64	32	4	inhabilidad
65	34	4	inhabilidad
66	36	4	inhabilidad
67	37	4	inhabilidad
68	38	4	inhabilidad
69	39	4	inhabilidad
70	39	3	abstencion
71	39	18	abstencion
72	39	19	abstencion
73	39	22	abstencion
74	39	29	abstencion
75	40	4	inhabilidad
76	41	4	inhabilidad
77	42	4	inhabilidad
\.


--
-- Name: acuerdos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.acuerdos_id_seq', 42, true);


--
-- Name: asistencia_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.asistencia_id_seq', 105, true);


--
-- Name: categorias_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categorias_id_seq', 16, true);


--
-- Name: comisiones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.comisiones_id_seq', 10, true);


--
-- Name: consejeros_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.consejeros_id_seq', 35, true);


--
-- Name: intervenciones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.intervenciones_id_seq', 44, true);


--
-- Name: sesiones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sesiones_id_seq', 3, true);


--
-- Name: suscriptores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.suscriptores_id_seq', 1, false);


--
-- Name: temas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.temas_id_seq', 52, true);


--
-- Name: votos_consejero_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.votos_consejero_id_seq', 77, true);


--
-- Name: acuerdos acuerdos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acuerdos
    ADD CONSTRAINT acuerdos_pkey PRIMARY KEY (id);


--
-- Name: asistencia asistencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asistencia
    ADD CONSTRAINT asistencia_pkey PRIMARY KEY (id);


--
-- Name: asistencia asistencia_sesion_id_consejero_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asistencia
    ADD CONSTRAINT asistencia_sesion_id_consejero_id_key UNIQUE (sesion_id, consejero_id);


--
-- Name: categorias categorias_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_nombre_key UNIQUE (nombre);


--
-- Name: categorias categorias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_pkey PRIMARY KEY (id);


--
-- Name: comisiones comisiones_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comisiones
    ADD CONSTRAINT comisiones_nombre_key UNIQUE (nombre);


--
-- Name: comisiones comisiones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comisiones
    ADD CONSTRAINT comisiones_pkey PRIMARY KEY (id);


--
-- Name: consejeros consejeros_nombre_completo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consejeros
    ADD CONSTRAINT consejeros_nombre_completo_key UNIQUE (nombre_completo);


--
-- Name: consejeros consejeros_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consejeros
    ADD CONSTRAINT consejeros_pkey PRIMARY KEY (id);


--
-- Name: intervenciones intervenciones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intervenciones
    ADD CONSTRAINT intervenciones_pkey PRIMARY KEY (id);


--
-- Name: sesiones sesiones_numero_sesion_tipo_sesion_fecha_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sesiones
    ADD CONSTRAINT sesiones_numero_sesion_tipo_sesion_fecha_key UNIQUE (numero_sesion, tipo_sesion, fecha);


--
-- Name: sesiones sesiones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sesiones
    ADD CONSTRAINT sesiones_pkey PRIMARY KEY (id);


--
-- Name: suscriptores suscriptores_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suscriptores
    ADD CONSTRAINT suscriptores_email_key UNIQUE (email);


--
-- Name: suscriptores suscriptores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suscriptores
    ADD CONSTRAINT suscriptores_pkey PRIMARY KEY (id);


--
-- Name: temas_categorias temas_categorias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.temas_categorias
    ADD CONSTRAINT temas_categorias_pkey PRIMARY KEY (tema_id, categoria_id);


--
-- Name: temas temas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.temas
    ADD CONSTRAINT temas_pkey PRIMARY KEY (id);


--
-- Name: votos_consejero votos_consejero_acuerdo_id_consejero_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votos_consejero
    ADD CONSTRAINT votos_consejero_acuerdo_id_consejero_id_key UNIQUE (acuerdo_id, consejero_id);


--
-- Name: votos_consejero votos_consejero_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votos_consejero
    ADD CONSTRAINT votos_consejero_pkey PRIMARY KEY (id);


--
-- Name: idx_acuerdos_sesion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_acuerdos_sesion ON public.acuerdos USING btree (sesion_id);


--
-- Name: idx_acuerdos_texto_fts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_acuerdos_texto_fts ON public.acuerdos USING gin (to_tsvector('spanish'::regconfig, texto_acuerdo));


--
-- Name: idx_sesiones_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sesiones_fecha ON public.sesiones USING btree (fecha);


--
-- Name: idx_temas_comision; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_temas_comision ON public.temas USING btree (comision_id);


--
-- Name: idx_temas_resumen_fts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_temas_resumen_fts ON public.temas USING gin (to_tsvector('spanish'::regconfig, resumen));


--
-- Name: idx_temas_sesion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_temas_sesion ON public.temas USING btree (sesion_id);


--
-- Name: idx_temas_titulo_fts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_temas_titulo_fts ON public.temas USING gin (to_tsvector('spanish'::regconfig, (titulo)::text));


--
-- Name: acuerdos acuerdos_sesion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acuerdos
    ADD CONSTRAINT acuerdos_sesion_id_fkey FOREIGN KEY (sesion_id) REFERENCES public.sesiones(id) ON DELETE CASCADE;


--
-- Name: acuerdos acuerdos_tema_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acuerdos
    ADD CONSTRAINT acuerdos_tema_id_fkey FOREIGN KEY (tema_id) REFERENCES public.temas(id) ON DELETE CASCADE;


--
-- Name: asistencia asistencia_consejero_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asistencia
    ADD CONSTRAINT asistencia_consejero_id_fkey FOREIGN KEY (consejero_id) REFERENCES public.consejeros(id);


--
-- Name: asistencia asistencia_sesion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asistencia
    ADD CONSTRAINT asistencia_sesion_id_fkey FOREIGN KEY (sesion_id) REFERENCES public.sesiones(id) ON DELETE CASCADE;


--
-- Name: comisiones comisiones_presidente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comisiones
    ADD CONSTRAINT comisiones_presidente_id_fkey FOREIGN KEY (presidente_id) REFERENCES public.consejeros(id);


--
-- Name: intervenciones intervenciones_consejero_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intervenciones
    ADD CONSTRAINT intervenciones_consejero_id_fkey FOREIGN KEY (consejero_id) REFERENCES public.consejeros(id);


--
-- Name: intervenciones intervenciones_tema_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intervenciones
    ADD CONSTRAINT intervenciones_tema_id_fkey FOREIGN KEY (tema_id) REFERENCES public.temas(id) ON DELETE CASCADE;


--
-- Name: temas_categorias temas_categorias_categoria_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.temas_categorias
    ADD CONSTRAINT temas_categorias_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES public.categorias(id) ON DELETE CASCADE;


--
-- Name: temas_categorias temas_categorias_tema_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.temas_categorias
    ADD CONSTRAINT temas_categorias_tema_id_fkey FOREIGN KEY (tema_id) REFERENCES public.temas(id) ON DELETE CASCADE;


--
-- Name: temas temas_comision_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.temas
    ADD CONSTRAINT temas_comision_id_fkey FOREIGN KEY (comision_id) REFERENCES public.comisiones(id);


--
-- Name: temas temas_presentado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.temas
    ADD CONSTRAINT temas_presentado_por_fkey FOREIGN KEY (presentado_por) REFERENCES public.consejeros(id);


--
-- Name: temas temas_sesion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.temas
    ADD CONSTRAINT temas_sesion_id_fkey FOREIGN KEY (sesion_id) REFERENCES public.sesiones(id) ON DELETE CASCADE;


--
-- Name: votos_consejero votos_consejero_acuerdo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votos_consejero
    ADD CONSTRAINT votos_consejero_acuerdo_id_fkey FOREIGN KEY (acuerdo_id) REFERENCES public.acuerdos(id) ON DELETE CASCADE;


--
-- Name: votos_consejero votos_consejero_consejero_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votos_consejero
    ADD CONSTRAINT votos_consejero_consejero_id_fkey FOREIGN KEY (consejero_id) REFERENCES public.consejeros(id);


--
-- PostgreSQL database dump complete
--

\unrestrict vt388myhsAoDdzcfG5Gdz9A7hKjJKNqExBYmXXkOtjzXd4RRMh4aNsWTUXWbT17

