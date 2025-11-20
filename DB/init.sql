-- =======================================================
-- ESQUEMA DE BASE DE DATOS PARA "DIARIO DE INTIMIDAD"
-- Tecnología: PostgreSQL
-- =======================================================

-- 1. Tablas de Usuario y Autenticación
CREATE TABLE Usuario (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL, -- Almacenar el hash de la contraseña (ej. BCrypt)
    rol VARCHAR(50) NOT NULL DEFAULT 'USER', -- 'USER', 'ADMIN'
    fecha_registro TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
 );

-- 2. Tablas de Contenido Maestro (Diario Anual)

-- Almacena información de cada edición del diario (ej. 2026, 2027)
CREATE TABLE Diario_Anual (
    id BIGSERIAL PRIMARY KEY,
    anio INTEGER UNIQUE NOT NULL,
    titulo VARCHAR(255) NOT NULL, -- Título principal (ej. "Avivamiento")
    nombre_portada VARCHAR(255),
    nombre_logo VARCHAR(255),
    tema_principal TEXT, -- Versículo principal del año (ej. Jeremías 32:17)
    status VARCHAR(50) NOT NULL, -- 'Desarrollo', 'Descatalogado', 'Activo'
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Agregar columnas nuevas si no existen (para migración de esquema)
ALTER TABLE Diario_Anual ADD COLUMN IF NOT EXISTS nombre_portada VARCHAR(255);
ALTER TABLE Diario_Anual ADD COLUMN IF NOT EXISTS nombre_logo VARCHAR(255);
ALTER TABLE Diario_Anual ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'Activo';
ALTER TABLE Diario_Anual ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE Diario_Anual ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP;
-- Almacena los temas y versículos por mes para un año específico
CREATE TABLE Mes_Maestro (
    id BIGSERIAL PRIMARY KEY,
    diario_id BIGINT NOT NULL REFERENCES Diario_Anual(id) ON DELETE CASCADE,
    mes_numero INTEGER NOT NULL, -- 1 a 12
    nombre VARCHAR(50) NOT NULL, -- Nombre del mes (ej. "ENERO")
    tema_mes VARCHAR(255),
    versiculo_mes TEXT, -- Versículo temático del mes (ej. Hechos 2:3)
    UNIQUE (diario_id, mes_numero)
 );

-- Almacena el contenido fijo para cada día del diario
CREATE TABLE Dia_Maestro (
    id BIGSERIAL PRIMARY KEY,
    mes_id BIGINT NOT NULL REFERENCES Mes_Maestro(id),
    dia_numero INTEGER NOT NULL, -- 1 a 31
    tipo_dia VARCHAR(20) NOT NULL DEFAULT 'NORMAL', -- 'NORMAL', 'DOMINGO'
    lectura_biblica VARCHAR(100), -- Referencia (ej. "Hechos 10:34-48")
    versiculo_diario TEXT, -- El texto sugerido para el versículo del día (si aplica)
    -- link_lectura se genera en la aplicación usando la API de la Biblia
    UNIQUE (mes_id, dia_numero)
 );

-- 3. Tabla para la flexibilidad de los campos a rellenar (CLAVE)
-- Define la estructura de la entrada que verá el usuario
CREATE TABLE Campos_Diario (
    id BIGSERIAL PRIMARY KEY,
    diario_id BIGINT NOT NULL REFERENCES Diario_Anual(id) ON DELETE CASCADE, -- A qué diario anual aplica
    orden INTEGER NOT NULL, -- Orden de aparición en el frontend
    nombre_campo VARCHAR(100) NOT NULL, -- Título/etiqueta del campo (ej. 'Aplicación Práctica')
    tipo_entrada VARCHAR(50) NOT NULL, -- 'VERSICULO', 'APLICACION', 'ORACION', 'PRIORIDADES'
    tipo_input VARCHAR(50) NOT NULL, -- Tipo de input en el frontend: 'TEXTO', 'TEXTAREA', 'AUDIO'
    es_requerido BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE (diario_id, nombre_campo)
 );

-- 4. Tablas de Entrada de Usuario (Progreso)
-- Registra el intento o la entrada de un usuario en un día específico
CREATE TABLE Entrada_Diaria (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL REFERENCES Usuario(id),
    diario_id BIGINT NOT NULL REFERENCES Diario_Anual(id) ON DELETE CASCADE,
    dia_maestro_id BIGINT NOT NULL REFERENCES Dia_Maestro(id),
    fecha_entrada DATE NOT NULL,
    estado_llenado NUMERIC(5, 2) DEFAULT 0.00, -- Porcentaje de campos rellenados (0.00 a 100.00)
    completado BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_creacion TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    fecha_ultima_edicion TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (usuario_id, dia_maestro_id)
 );

-- Almacena los valores reales de los campos rellenados por el usuario
CREATE TABLE Valores_Campo (
    id BIGSERIAL PRIMARY KEY,
    entrada_diaria_id BIGINT NOT NULL REFERENCES Entrada_Diaria(id),
    campo_diario_id BIGINT NOT NULL REFERENCES Campos_Diario(id),
    valor_texto TEXT, -- Para entradas de texto y transcripciones de audio
    valor_audio_url VARCHAR(255), -- URL al archivo de audio almacenado (si aplica)
    UNIQUE (entrada_diaria_id, campo_diario_id)
 );

-- 5. Tablas de Metas y Pagos (Sin cambios significativos de la propuesta anterior)

-- Metas Anuales del usuario
CREATE TABLE Meta_Anual (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL REFERENCES Usuario(id),
    diario_id BIGINT NOT NULL REFERENCES Diario_Anual(id) ON DELETE CASCADE,
    tipo_meta VARCHAR(50) NOT NULL, -- 'Personal', 'Familiar', 'Económica', 'Ministerial'
    descripcion TEXT NOT NULL,
    estado VARCHAR(50) NOT NULL DEFAULT 'Activo',
    fecha_creacion TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
 );

-- Metas Mensuales del usuario
CREATE TABLE Meta_Mensual (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL REFERENCES Usuario(id),
    diario_id BIGINT NOT NULL REFERENCES Diario_Anual(id) ON DELETE CASCADE,
    mes_numero INTEGER NOT NULL, -- Mes al que pertenece la meta
    descripcion TEXT NOT NULL,
    cumplida BOOLEAN NOT NULL DEFAULT FALSE,
    pasa_siguiente_mes BOOLEAN NOT NULL DEFAULT FALSE, -- Se arrastra al siguiente mes si no se cumple
    fecha_creacion TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
 );

-- Registro de transacciones
CREATE TABLE Pago (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL REFERENCES Usuario(id),
    monto NUMERIC(10, 2) NOT NULL,
    fecha_pago TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(50) NOT NULL, -- 'COMPLETADO', 'FALLIDO', 'PENDIENTE'
    metodo_pago VARCHAR(50)
 );

-- Insertar datos de prueba
-- Password: 'password' encriptado con BCrypt
INSERT INTO usuario (email, password, rol, fecha_registro) VALUES ('Sithgto@gmail.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'ADMIN', CURRENT_TIMESTAMP);
INSERT INTO usuario (email, password, rol, fecha_registro) VALUES ('user@diario.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'USER', CURRENT_TIMESTAMP);


-- =======================================================
-- CARGA DE DATOS INICIALES - DIARIO 2026: AÑO COMPLETO
-- =======================================================

-- Limpiar datos existentes para recargar desde cero
--TRUNCATE TABLE Pago CASCADE;
--TRUNCATE TABLE Meta_Mensual CASCADE;
--TRUNCATE TABLE Meta_Anual CASCADE;
--TRUNCATE TABLE Valores_Campo CASCADE;
--TRUNCATE TABLE Entrada_Diaria CASCADE;
TRUNCATE TABLE Dia_Maestro CASCADE;
TRUNCATE TABLE Mes_Maestro CASCADE;
TRUNCATE TABLE Campos_Diario CASCADE;
TRUNCATE TABLE Diario_Anual CASCADE;

-- 1. Asegurar la inserción del Diario Anual (Se asume ID=1)
INSERT INTO Diario_Anual (id, anio, titulo, tema_principal, status) VALUES
(1, 2026, 'Avivamiento', '\"¡Oh Señor Jehová! He aquí que tú hiciste el cielo y la tierra con tu gran poder, y con tu brazo extendido, ni hay nada que sea dificil para ti\". Jeremías 32:17', 'Activo')
ON CONFLICT (id) DO NOTHING;

-- =======================================================
-- DATOS PARA ENERO (mes_id = 1)
-- =======================================================
INSERT INTO Mes_Maestro (diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(1, 1, 'ENERO', 'Avivamiento en Pentecostés', 'Y se les aparecieron lenguas repartidas, como de fuego, asentándose sobre cada uno de ellos. Hechos 2:3')
ON CONFLICT (diario_id, mes_numero) DO UPDATE SET tema_mes = EXCLUDED.tema_mes;

-- Campos del diario para 2026
INSERT INTO Campos_Diario (diario_id, orden, nombre_campo, tipo_entrada, tipo_input, es_requerido) VALUES
(1, 1, 'Escoge un versiculo para meditar en el día y escribelo:', 'VERSICULO', 'TEXTO', TRUE),
(1, 2, '¿Cómo puedes aplicarlo en tu vida y así desarrollar nuestro avivamiento?', 'APLICACION', 'TEXTAREA', TRUE),
(1, 3, 'Oración: Utilice este espacio para agradecer.', 'ORACION', 'AUDIO', TRUE),
(1, 4, 'Prioridades para este Día', 'PRIORIDADES', 'TEXTAREA', TRUE)
ON CONFLICT (diario_id, nombre_campo) DO NOTHING;

-- Días NORMALES (ENERO)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(1, 1, 'NORMAL', 'Hechos 10:34-48'), (1, 2, 'NORMAL', 'Hechos 1:1-9'), (1, 3, 'NORMAL', 'Juan 16:5-15'), (1, 5, 'NORMAL', 'Lucas 24:36-49'),
(1, 6, 'NORMAL', 'Hechos 10:34-48'), (1, 7, 'NORMAL', 'Hechos 4:1-12'), (1, 8, 'NORMAL', 'Hechos 4:13-22'), (1, 9, 'NORMAL', '2 Crónicas 20:1-30'),
(1, 10, 'NORMAL', 'Hechos 2:43-47'), (1, 12, 'NORMAL', 'Hechos 2:14-21'), (1, 13, 'NORMAL', 'Hechos 19:1-12'), (1, 14, 'NORMAL', 'Hechos 2:36-42'),
(1, 15, 'NORMAL', 'Hechos 3'), (1, 16, 'NORMAL', 'Hechos 13:44-52'), (1, 17, 'NORMAL', 'Hechos 8:26-40'), (1, 19, 'NORMAL', 'Hechos 8:9-25'),
(1, 20, 'NORMAL', 'Marcos 16:14-18'), (1, 21, 'NORMAL', 'Hechos 9:26-31'), (1, 22, 'NORMAL', 'Hechos 5:12-16'), (1, 23, 'NORMAL', 'Hechos 18:24-28'),
(1, 24, 'NORMAL', 'Hechos 6:8-15'), (1, 26, 'NORMAL', 'Hechos 13:4-12'), (1, 27, 'NORMAL', 'Hechos 11:1-18'), (1, 28, 'NORMAL', 'Hechos 14:1-7'),
(1, 29, 'NORMAL', 'Hechos 8:1-8'), (1, 30, 'NORMAL', 'Hechos 9:32-35'), (1, 31, 'NORMAL', 'Hechos 9:36-43')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (ENERO)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(1, 4, 'DOMINGO', NULL, 'Avivamiento en Pentecostés (Siglo I Jerusalén, Israel)'),
(1, 11, 'DOMINGO', NULL, 'El poder del Espíritu Santo y el Denuedo (Hechos 4:31)'),
(1, 18, 'DOMINGO', NULL, 'Comunión y Multiplicación de la Primera Iglesia (Hechos 2:44-47)'),
(1, 25, 'DOMINGO', NULL, 'Manifestación del Poder de Dios (Hechos 5:15-16)')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA FEBRERO (mes_id = 2)
-- =======================================================
INSERT INTO Mes_Maestro (diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(1, 2, 'FEBRERO', 'Avivamiento Primer Gran Despertar', 'Y fueron todos llenos del Espíritu Santo, y comenzaron a hablar en otras lenguas, según el Espíritu les daba que hablasen. Hechos 2:4')
ON CONFLICT (diario_id, mes_numero) DO UPDATE SET tema_mes = EXCLUDED.tema_mes;

-- Días NORMALES (FEBRERO)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(2, 2, 'NORMAL', '1 Juan 2:7-17'), (2, 3, 'NORMAL', 'Romanos 3:21-31'), (2, 4, 'NORMAL', '2 Timoteo 2:14-26'), (2, 5, 'NORMAL', '2 Pedro 3'),
(2, 6, 'NORMAL', 'Isaías 61'), (2, 7, 'NORMAL', 'Lucas 4:16-21'), (2, 9, 'NORMAL', 'Romanos 10:1-13'), (2, 10, 'NORMAL', '2 Corintios 1:19-24'),
(2, 11, 'NORMAL', 'Efesios 4:17-32'), (2, 12, 'NORMAL', 'Filipenses 2:1-11'), (2, 13, 'NORMAL', 'Romanos 12:9-21'), (2, 14, 'NORMAL', 'Isaías 52:1-8'),
(2, 16, 'NORMAL', 'Romanos 12:1-8'), (2, 17, 'NORMAL', 'Mateo 6:25-34'), (2, 18, 'NORMAL', 'Filipenses 3:7-14'), (2, 19, 'NORMAL', 'Proverbios 4:10-19'),
(2, 20, 'NORMAL', 'Colosenses 3:18-25'), (2, 21, 'NORMAL', '2 Pedro 1:1-8'), (2, 23, 'NORMAL', '3 Juan 1:1-4'), (2, 24, 'NORMAL', '1 Pedro 4:1-11'),
(2, 25, 'NORMAL', 'Mateo 28:16-20'), (2, 26, 'NORMAL', 'Santiago 1:2-11'), (2, 27, 'NORMAL', 'Proverbios 3:5-8'), (2, 28, 'NORMAL', '1 Corintios 6:12-20')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (FEBRERO)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(2, 1, 'DOMINGO', NULL, 'Avivamiento Primer Gran Despertar (1730-1755 colonias Americanas EEUU y Reino Unido)'),
(2, 8, 'DOMINGO', NULL, 'George Whitefield: El megáfono del avivamiento (Filipenses 2:3)'),
(2, 15, 'DOMINGO', NULL, 'Impacto del Primer Gran Despertar (Romanos 12:2)'),
(2, 22, 'DOMINGO', NULL, 'Errores del Primer Gran Despertar (3 Juan 1:2 y Mateo 28:19-20)')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA MARZO (mes_id = 3)
-- =======================================================
INSERT INTO Mes_Maestro (diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(1, 3, 'MARZO', 'Avivamiento Segundo Gran Despertar', 'Moraban entonces en Jerusalén judíos, varones piadosos, de todas las naciones bajo el cielo. Y hecho este estruendo, se juntó la multitud; y estaban confusos, porque cada uno les oía hablar en su propia lengua. Hechos 2:5-6')
ON CONFLICT (diario_id, mes_numero) DO UPDATE SET tema_mes = EXCLUDED.tema_mes;

-- Días NORMALES (MARZO)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(3, 2, 'NORMAL', '1 Crónicas 29:8-14'), (3, 3, 'NORMAL', 'Isaías 45:1-7'), (3, 4, 'NORMAL', 'Mateo 22:34-40'), (3, 5, 'NORMAL', 'Deuteronomio 6:1-9'),
(3, 6, 'NORMAL', 'Colosenses 2:1-10'), (3, 7, 'NORMAL', '2 Corintios 10:1-7'), (3, 9, 'NORMAL', 'Joel 2:28-32'), (3, 10, 'NORMAL', 'Ezequiel 36:22-30'),
(3, 11, 'NORMAL', 'Isaías 32:9-20'), (3, 12, 'NORMAL', 'Isaías 44:1-8'), (3, 13, 'NORMAL', 'Tito 3:1-11'), (3, 14, 'NORMAL', 'Juan 7:37-39'),
(3, 16, 'NORMAL', 'Proverbios 31:1-9'), (3, 17, 'NORMAL', 'Salmos 82:3-5'), (3, 18, 'NORMAL', 'Efesios 5:1-10'), (3, 19, 'NORMAL', '1 Pedro 2:11-25'),
(3, 20, 'NORMAL', 'Salmos 51'), (3, 21, 'NORMAL', '2 Corintios 5:11-21'), (3, 23, 'NORMAL', 'Romanos 8'), (3, 24, 'NORMAL', '2 Timoteo 4:1-8'),
(3, 25, 'NORMAL', 'Efesios 6:10-20'), (3, 26, 'NORMAL', 'Jeremías 1:1-10'), (3, 27, 'NORMAL', 'Salmos 33:1-15'), (3, 28, 'NORMAL', 'Salmos 96'),
(3, 30, 'NORMAL', 'Salmos 1:1-6'), (3, 31, 'NORMAL', 'Lucas 12:13-21')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (MARZO)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(3, 1, 'DOMINGO', NULL, 'Avivamiento Segundo Gran Despertar (1790-1840 EEUU) - Sector Intelectual'),
(3, 8, 'DOMINGO', NULL, 'Avivamiento Segundo Gran Despertar - Sector Rural (Isaías 32:15)'),
(3, 15, 'DOMINGO', NULL, 'Avivamiento Segundo Gran Despertar - Sector Urbano (Gálatas 5:22-23)'),
(3, 22, 'DOMINGO', NULL, 'Avivamiento Segundo Gran Despertar - Predicadores Itinerantes (Romanos 10:15)'),
(3, 29, 'DOMINGO', NULL, 'Errores del Segundo Gran Despertar (Juan 14:26 y 1 Timoteo 6:10)')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA ABRIL (mes_id = 4)
-- =======================================================
INSERT INTO Mes_Maestro (diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(1, 4, 'ABRIL', 'Avivamiento en Gales', 'Y no hizo allí muchos milagros, a causa de la incredulidad de ellos. Mateo 13:58')
ON CONFLICT (diario_id, mes_numero) DO UPDATE SET tema_mes = EXCLUDED.tema_mes;

-- Días NORMALES (ABRIL)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(4, 1, 'NORMAL', 'Salmos 145:14-21'), (4, 2, 'NORMAL', '1 Timoteo 2:1-6'), (4, 3, 'NORMAL', 'Isaías 26:1-9'), (4, 4, 'NORMAL', '1 Pedro 5'),
(4, 6, 'NORMAL', 'Jeremías 29:1-14'), (4, 7, 'NORMAL', '1 Corintios 12'), (4, 8, 'NORMAL', 'Isaías 55:6-13'), (4, 9, 'NORMAL', 'Filipenses 4:1-7'),
(4, 10, 'NORMAL', 'Romanos 13:10-14'), (4, 11, 'NORMAL', 'Salmos 62:5-8'), (4, 13, 'NORMAL', 'Lamentaciones 3:19-26'), (4, 14, 'NORMAL', '2 Crónicas 7:11-18'),
(4, 15, 'NORMAL', 'Job 42:1-6'), (4, 16, 'NORMAL', 'Salmos 139:19-24'), (4, 17, 'NORMAL', 'Gálatas 2:11-21'), (4, 18, 'NORMAL', 'Romanos 1:8-17'),
(4, 20, 'NORMAL', 'Mateo 11:25-30'), (4, 21, 'NORMAL', 'Isaías 40:12-31'), (4, 22, 'NORMAL', 'Hebreos 13'), (4, 23, 'NORMAL', 'Hebreos 3:7-15'),
(4, 24, 'NORMAL', 'Hebreos 10:19-25'), (4, 25, 'NORMAL', 'Salmos 133'), (4, 27, 'NORMAL', '1 Tesalonicenses 5:12-24'), (4, 28, 'NORMAL', 'Salmos: 119:9-16'),
(4, 29, 'NORMAL', 'Colosenses 4:1-6'), (4, 30, 'NORMAL', '2 Tesalonicenses 2:13-17')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (ABRIL)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(4, 5, 'DOMINGO', NULL, 'Avivamiento en Gales (1904-1905 Gales, Reino Unido) - Evan Roberts (1 Timoteo 2:1-4)'),
(4, 12, 'DOMINGO', NULL, 'Manifestaciones del Avivamiento de Gales (1 Corintios 12:7-11)'),
(4, 19, 'DOMINGO', NULL, 'Claves del Avivamiento de Gales (2 Crónicas 7:14)'),
(4, 26, 'DOMINGO', NULL, 'Errores del Avivamiento de Gales (Hebreos 13:17 y Hebreo 10:24-25)')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA MAYO (mes_id = 5)
-- =======================================================
INSERT INTO Mes_Maestro (diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(1, 5, 'MAYO', 'Avivamiento en la Calle Azuza', 'Y me buscaréis y me hallaréis, porque me buscaréis de todo vuestro corazón. Jeremías 29:13')
ON CONFLICT (diario_id, mes_numero) DO UPDATE SET tema_mes = EXCLUDED.tema_mes;

-- Días NORMALES (MAYO)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(5, 1, 'NORMAL', 'Gálatas 3:19-29'), (5, 2, 'NORMAL', 'Isaías 41:1-13'), (5, 4, 'NORMAL', 'Zacarías 1:1-6'), (5, 5, 'NORMAL', 'Efesios 2:1-10'),
(5, 6, 'NORMAL', 'Oseas 14:1-9'), (5, 7, 'NORMAL', 'Lucas 15:1-32'), (5, 8, 'NORMAL', 'Filipenses 1:3-11'), (5, 9, 'NORMAL', 'Mateo 3:1-12'),
(5, 11, 'NORMAL', 'Hechos 9:1-19'), (5, 12, 'NORMAL', '1 Corintios 14'), (5, 13, 'NORMAL', 'Judas 1:17-23'), (5, 14, 'NORMAL', 'Efesios 5:15-20'),
(5, 15, 'NORMAL', '2 Corintios 3:14-18'), (5, 16, 'NORMAL', '1 Pedro 2:4-10'), (5, 18, 'NORMAL', 'Efesios 1:3-14'), (5, 19, 'NORMAL', 'Colosenses 1:3-14'),
(5, 20, 'NORMAL', 'Hebreos 10:8-18'), (5, 21, 'NORMAL', 'Juan 1:1-18'), (5, 22, 'NORMAL', 'Efesios 3:14-21'), (5, 23, 'NORMAL', 'Romanos 5:1-11'),
(5, 25, 'NORMAL', 'Gálatas 4:1-7'), (5, 26, 'NORMAL', 'Efesios 4:1-7'), (5, 27, 'NORMAL', 'Romanos 6:15-23'), (5, 28, 'NORMAL', 'Colosenses 1:24-29'),
(5, 29, 'NORMAL', 'Salmos 103:1-13'), (5, 30, 'NORMAL', 'Miqueas 7:14-20'), (5, 31, 'NORMAL', 'Tito 3:4-5')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (MAYO)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(5, 3, 'DOMINGO', NULL, 'Avivamiento en la Calle Azuza (1906-1915 Los Ángeles, EEUU) - William J. Seymour (Gálatas 3:26-28)'),
(5, 10, 'DOMINGO', NULL, 'El Pentecostés Restaurado (Hechos 2:17)'),
(5, 17, 'DOMINGO', NULL, 'Error de William J. Seymour: Salvación por Obras (Efesios 2:8-9)'),
(5, 24, 'DOMINGO', NULL, 'Error de William J. Seymour: Bautismo vs. Llenura (Mateo 3:11 y 1 Corintios 14:2-4)')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA JUNIO (mes_id = 6)
-- =======================================================
INSERT INTO Mes_Maestro (diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(1, 6, 'JUNIO', 'Avivamiento en Argentina', 'Porque todos los que son guiados por el Espíritu de Dios, éstos son hijos de Dios. Romanos 8:14')
ON CONFLICT (diario_id, mes_numero) DO UPDATE SET tema_mes = EXCLUDED.tema_mes;

-- Días NORMALES (JUNIO)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(6, 1, 'NORMAL', 'Hechos 20:17-24'), (6, 2, 'NORMAL', '2 Corintios 4:1-6'), (6, 3, 'NORMAL', '2 Corintios 6:1-13'), (6, 4, 'NORMAL', 'Mateo 6:5-15'),
(6, 5, 'NORMAL', 'Juan 9:35-41'), (6, 6, 'NORMAL', 'Lucas 4:22-30'), (6, 8, 'NORMAL', 'Gálatas 3:1-5'), (6, 9, 'NORMAL', 'Hebreos 12:1-2'),
(6, 10, 'NORMAL', 'Romanos 4:13-25'), (6, 11, 'NORMAL', 'Lucas 17:1-6'), (6, 12, 'NORMAL', 'Romanos 1:18-32'), (6, 13, 'NORMAL', 'Juan 4:43-54'),
(6, 15, 'NORMAL', 'Mateo 18:18-22'), (6, 16, 'NORMAL', '1 Corintios 15:54-58'), (6, 17, 'NORMAL', 'Mateo 7:15-27'), (6, 18, 'NORMAL', 'Mateo 21:18-22'),
(6, 19, 'NORMAL', 'Salmos 36'), (6, 20, 'NORMAL', 'Marcos 6:1-6'), (6, 22, 'NORMAL', 'Isaías 29:9-16'), (6, 23, 'NORMAL', 'Josué 24:14-25'),
(6, 24, 'NORMAL', 'Juan 6:25-40'), (6, 25, 'NORMAL', 'Isaías 55:1-5'), (6, 26, 'NORMAL', '2 Corintios 7:2-11'), (6, 27, 'NORMAL', 'Sofonías 3:9-20'),
(6, 29, 'NORMAL', 'Mateo 13:53-58'), (6, 30, 'NORMAL', 'Colosenses 3:5-17')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (JUNIO)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(6, 7, 'DOMINGO', NULL, 'Avivamiento en Argentina (1954-1960 y 1980-1990) - Tommy Hicks (Romanos 8:14)'),
(6, 14, 'DOMINGO', NULL, 'Sanidades y Milagros con Tommy Hicks (Hechos 9:33-35)'),
(6, 21, 'DOMINGO', NULL, 'Avivamiento con Carlos Annacondia (1 Corintios 12:7)'),
(6, 28, 'DOMINGO', NULL, 'Errores del Avivamiento en Argentina (Isaías 29:13 y Mateo 6:1)')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA JULIO (mes_id = 7)
-- =======================================================
INSERT INTO Mes_Maestro (diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(1, 7, 'JULIO', 'Avivamiento en Guatemala', 'Y el Señor añadia cada día a la iglesia los que habían de ser salvos. Hechos 2:47')
ON CONFLICT (diario_id, mes_numero) DO UPDATE SET tema_mes = EXCLUDED.tema_mes;

-- Días NORMALES (JULIO)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(7, 1, 'NORMAL', '1 Corintios 6:1-11'), (7, 2, 'NORMAL', '1 Pedro 1:13-25'), (7, 3, 'NORMAL', '2 Crónicas 5:2-14'), (7, 4, 'NORMAL', 'Santiago 5:7-20'),
(7, 6, 'NORMAL', '1 Corintios 4:1-21'), (7, 7, 'NORMAL', 'Efesios 5:21-33'), (7, 8, 'NORMAL', 'Juan 14:15-23'), (7, 9, 'NORMAL', '1 Corintios 1:10-17'),
(7, 10, 'NORMAL', 'Éxodo 33:9-19'), (7, 11, 'NORMAL', 'Lucas 10:17-20'), (7, 13, 'NORMAL', 'Efesios 1:15-23'), (7, 14, 'NORMAL', '1 Tesalonicenses 4:1-12'),
(7, 15, 'NORMAL', 'Isaías 54:8-17'), (7, 16, 'NORMAL', 'Salmos 16'), (7, 17, 'NORMAL', 'Juan 17'), (7, 18, 'NORMAL', '1 Tesalonicenses 2:1-16'),
(7, 20, 'NORMAL', 'Hechos 12:1-5'), (7, 21, 'NORMAL', 'Isaías 1:10-20'), (7, 22, 'NORMAL', 'Hechos 16:11-32'), (7, 23, 'NORMAL', 'Hechos 4:23-31'),
(7, 24, 'NORMAL', 'Gálatas 6:1-10'), (7, 25, 'NORMAL', 'Mateo 21:18-22'), (7, 27, 'NORMAL', 'Hechos 12:6-19'), (7, 28, 'NORMAL', 'Josué 3:1-5'),
(7, 29, 'NORMAL', 'Juan 14:1-14'), (7, 30, 'NORMAL', 'Mateo 16:13-20'), (7, 31, 'NORMAL', 'Efesios 4:11-16')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (JULIO)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(7, 5, 'DOMINGO', NULL, 'Avivamiento en Guatemala (1959-1990 Guatemala) - Otoniel Ríos (1 Corintios 6:11)'),
(7, 12, 'DOMINGO', NULL, 'Avivamiento de la Iglesia Elim (Hechos 2:46-47)'),
(7, 19, 'DOMINGO', NULL, 'Error de Otoniel Ríos: Falta de Paternidad (1 Corintios 4:15)'),
(7, 26, 'DOMINGO', NULL, 'Error de Otoniel Ríos: Falta de Autoridad Espiritual (Efesios 1:19-23)')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA AGOSTO (mes_id = 8)
-- =======================================================
INSERT INTO Mes_Maestro (diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(1, 8, 'AGOSTO', 'Avivamiento en Cali', 'Bienaventurados aquellos siervos a los cuales su señor, cuando venga, halle velando; de cierto os digo que se ceñirá, y hará que se sienten a la mesa, y vendrá a servirles. Lucas 12:37')
ON CONFLICT (diario_id, mes_numero) DO UPDATE SET tema_mes = EXCLUDED.tema_mes;

-- Días NORMALES (AGOSTO)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(8, 1, 'NORMAL', 'Mateo 10:1-15'), (8, 2, 'NORMAL', 'Juan 14:24-31'), (8, 3, 'NORMAL', 'Salmos 143'), (8, 4, 'NORMAL', 'Juan 3:1-21'),
(8, 5, 'NORMAL', 'Salmos 139:1-18'), (8, 7, 'NORMAL', '1 Corintios 1:18-31'), (8, 8, 'NORMAL', 'Romanos 15:1-6'), (8, 10, 'NORMAL', '2 Corintios 12:1-13'),
(8, 11, 'NORMAL', 'Salmos 122'), (8, 12, 'NORMAL', 'Lucas 18:1-8'), (8, 13, 'NORMAL', 'Hechos 19:13-22'), (8, 14, 'NORMAL', '1 Pedro 3:8-22'),
(8, 15, 'NORMAL', 'Mateo 12:22-37'), (8, 17, 'NORMAL', 'Jueces 6:1-16'), (8, 18, 'NORMAL', '2 Corintios 13'), (8, 19, 'NORMAL', 'Isaías 58:1-12'),
(8, 20, 'NORMAL', '1 Juan 3'), (8, 21, 'NORMAL', 'Proverbios 11:23-31'), (8, 22, 'NORMAL', 'Mateo 25:31-46'), (8, 24, 'NORMAL', 'Éxodo 4:1-17'),
(8, 25, 'NORMAL', 'Mateo 26:36-46'), (8, 26, 'NORMAL', 'Proverbios 11:1-11'), (8, 27, 'NORMAL', '1 Timoteo 6:11-21'), (8, 28, 'NORMAL', 'Salmos 101'),
(8, 29, 'NORMAL', 'Mateo 23:1-12'), (8, 31, 'NORMAL', 'Mateo 6:1-4')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (AGOSTO)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(8, 6, 'DOMINGO', NULL, 'Avivamiento en Cali (1978-1995 Cali, Colombia) - Julio y Ruth Ruibal (Hechos 16:9-10)'),
(8, 9, 'DOMINGO', NULL, 'La Unidad Pastoral como Arma (Mateo 18:19-20)'),
(8, 16, 'DOMINGO', NULL, 'Guerra Espiritual en los Encuentros de Amistad (Marcos 16:17-18)'),
(8, 23, 'DOMINGO', NULL, 'Impacto Social y Económico del Avivamiento (Jeremías 29:7)'),
(8, 30, 'DOMINGO', NULL, 'Error: Afán de Reconocimiento (Mateo 6:1)')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA SEPTIEMBRE (mes_id = 9)
-- =======================================================
INSERT INTO Mes_Maestro (diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(1, 9, 'SEPTIEMBRE', 'Avivamiento en África', 'El avivamiento empieza en ti, apasionado por Su Presencia. Jeremías 32:17')
ON CONFLICT (diario_id, mes_numero) DO UPDATE SET tema_mes = EXCLUDED.tema_mes;

-- Días NORMALES (SEPTIEMBRE)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(9, 1, 'NORMAL', 'Efesios 2:11-22'), (9, 2, 'NORMAL', 'Romanos 15:7-21'), (9, 3, 'NORMAL', '2 Samuel 23:1-7'), (9, 4, 'NORMAL', 'Isaías 63:7-14'),
(9, 5, 'NORMAL', '1 Juan 4:7-21'), (9, 7, 'NORMAL', 'Lucas 16:1-15'), (9, 8, 'NORMAL', 'Deuteronomio 18:9-14'), (9, 9, 'NORMAL', '1 Corintios 2'),
(9, 10, 'NORMAL', 'Santiago 3:13-18'), (9, 11, 'NORMAL', 'Éxodo 31:1-11'), (9, 12, 'NORMAL', 'Salmos 37:1-6'), (9, 14, 'NORMAL', 'Isaías 42:1-9'),
(9, 15, 'NORMAL', 'Éxodo 34:11-17'), (9, 16, 'NORMAL', '2 Timoteo 1:3-18'), (9, 17, 'NORMAL', 'Proverbios 1:8-33'), (9, 18, 'NORMAL', 'Jeremías 31:27-40'),
(9, 19, 'NORMAL', 'Éxodo 20:1-17'), (9, 21, 'NORMAL', 'Deuteronomio 4:15-31'), (9, 22, 'NORMAL', 'Juan 20:19-23'), (9, 23, 'NORMAL', 'Hebreos 2:1-4'),
(9, 24, 'NORMAL', 'Salmos 27'), (9, 25, 'NORMAL', 'Proverbios 14:24-35'), (9, 26, 'NORMAL', '2 Corintios 4:7-18'), (9, 28, 'NORMAL', 'Eclesiastés 4:8-16'),
(9, 29, 'NORMAL', 'Lucas 10:1-12'), (9, 30, 'NORMAL', 'Apocalipsis 2:1-7')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (SEPTIEMBRE)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(9, 6, 'DOMINGO', NULL, 'Avivamiento en Nigeria: William F. Kumuyi (Salmos 119:9-11)'),
(9, 13, 'DOMINGO', NULL, 'Avivamiento en Ghana: Nicholas Duncan-Williams (Mateo 10:1)'),
(9, 20, 'DOMINGO', NULL, 'Avivamiento en Sudáfrica: Ray McCauley (Efesios 2:16)'),
(9, 27, 'DOMINGO', NULL, 'Error: Falta de Claridad en el Evangelio (Deuteronomio 18:10-12)')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA OCTUBRE (mes_id = 10)
-- =======================================================
INSERT INTO Mes_Maestro (diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(1, 10, 'OCTUBRE', 'Avivamiento en Assembly of God y Toronto Airport Vineyard Church', 'El que busca, halla. Lucas 11:10')
ON CONFLICT (diario_id, mes_numero) DO UPDATE SET tema_mes = EXCLUDED.tema_mes;

-- Días NORMALES (OCTUBRE)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(10, 1, 'NORMAL', 'Lucas 11:1-13'), (10, 2, 'NORMAL', 'Salmos 80'), (10, 3, 'NORMAL', 'Miqueas 4:1-5'), (10, 5, 'NORMAL', 'Joel 2:12-27'),
(10, 6, 'NORMAL', 'Salmos 67'), (10, 7, 'NORMAL', 'Isaías 43:14-28'), (10, 8, 'NORMAL', '1 Samuel 15:13-29'), (10, 9, 'NORMAL', 'Hechos 6:1-7'),
(10, 10, 'NORMAL', 'Salmos 34'), (10, 12, 'NORMAL', 'Salmos 42'), (10, 13, 'NORMAL', '1 Tesalonicenses 1:2-10'), (10, 14, 'NORMAL', 'Salmos 73'),
(10, 15, 'NORMAL', 'Números 12'), (10, 16, 'NORMAL', '2 Timoteo 3'), (10, 17, 'NORMAL', 'Mateo 9:35-38'), (10, 19, 'NORMAL', 'Mateo 7:7-12'),
(10, 20, 'NORMAL', 'Salmos 2'), (10, 21, 'NORMAL', 'Gálatas 5:16-26'), (10, 22, 'NORMAL', 'Santiago 4:1-10'), (10, 23, 'NORMAL', 'Marcos 1:35-39'),
(10, 24, 'NORMAL', 'Hechos 12:20-29'), (10, 26, 'NORMAL', 'Salmos 24'), (10, 27, 'NORMAL', 'Proverbios 14:24-35'), (10, 28, 'NORMAL', '2 Corintios 4:7-18'),
(10, 29, 'NORMAL', 'Eclesiastés 4:8-16'), (10, 30, 'NORMAL', 'Lucas 10:1-12'), (10, 31, 'NORMAL', 'Apocalipsis 2:1-7')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (OCTUBRE)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(10, 4, 'DOMINGO', NULL, 'Avivamiento en Pensacola: Assembly of God (Jeremías 29:13)'),
(10, 11, 'DOMINGO', NULL, 'Impacto Global del Avivamiento de Pensacola'),
(10, 18, 'DOMINGO', NULL, 'Avivamiento de Toronto Airport Vineyard Church (Lucas 11:9-10)'),
(10, 25, 'DOMINGO', NULL, 'Error: Falta de Honra al Espíritu Santo y a los Dones (1 Tesalonicenses 5:12-13)')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA NOVIEMBRE (mes_id = 11)
-- =======================================================
INSERT INTO Mes_Maestro (diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(1, 11, 'NOVIEMBRE', 'Avivamiento en Europa', 'La Gloria de Jehová ha nacido sobre ti. Isaías 60:1')
ON CONFLICT (diario_id, mes_numero) DO UPDATE SET tema_mes = EXCLUDED.tema_mes;

-- Días NORMALES (NOVIEMBRE)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(11, 2, 'NORMAL', 'Isaías 57:14-21'), (11, 3, 'NORMAL', 'Salmos 147:1-6'), (11, 4, 'NORMAL', 'Isaías 60:1-9'), (11, 5, 'NORMAL', 'Salmos 72'),
(11, 6, 'NORMAL', 'Habacuc 2:6-14'), (11, 7, 'NORMAL', 'Mateo 24:29-51'), (11, 9, 'NORMAL', 'Marcos 13:3-23'), (11, 10, 'NORMAL', 'Proverbios 22:1-16'),
(11, 11, 'NORMAL', 'Mateo 4:12-25'), (11, 12, 'NORMAL', 'Isaías 6'), (11, 13, 'NORMAL', 'Lucas 21:25-38'), (11, 14, 'NORMAL', '1 Corintios 1:1-9'),
(11, 16, 'NORMAL', 'Lucas 12:35-40'), (11, 17, 'NORMAL', 'Juan 12:27-36'), (11, 18, 'NORMAL', 'Miqueas 6:6-16'), (11, 19, 'NORMAL', 'Romanos 6:1-14'),
(11, 20, 'NORMAL', 'Isaías 66:18-23'), (11, 21, 'NORMAL', 'Filipenses 3:15-21'), (11, 23, 'NORMAL', '2 Tesalonicenses 3:1-5'), (11, 24, 'NORMAL', 'Zacarías 14:1-11'),
(11, 25, 'NORMAL', 'Proverbios 3:21-35'), (11, 26, 'NORMAL', 'Marcos 13:24-37'), (11, 27, 'NORMAL', 'Salmos 85'), (11, 28, 'NORMAL', 'Mateo 16:21-28'),
(11, 30, 'NORMAL', 'Apocalipsis 3:7-13')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (NOVIEMBRE)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(11, 1, 'DOMINGO', NULL, 'Avivamiento en Suiza (Hechos 19:20)'),
(11, 8, 'DOMINGO', NULL, 'Avivamiento en Hungría y Países Bajos (Isaías 57:15)'),
(11, 15, 'DOMINGO', NULL, 'Avivamiento en Francia e Italia (Romanos 13:11)'),
(11, 22, 'DOMINGO', NULL, 'Avivamiento en Alemania (Isaías 60:1)'),
(11, 29, 'DOMINGO', NULL, 'Avivamiento en España (Lucas 12:37)')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA DICIEMBRE (mes_id = 12)
-- =======================================================
INSERT INTO Mes_Maestro (diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(1, 12, 'DICIEMBRE', 'Pastor Gustavo Marto: El futuro del Avivamiento', 'He aquí, yo estoy a la puerta y llamo. Apocalipsis 3:20')
ON CONFLICT (diario_id, mes_numero) DO UPDATE SET tema_mes = EXCLUDED.tema_mes;

-- Días NORMALES (DICIEMBRE)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(12, 1, 'NORMAL', 'Hechos 13:1-3'), (12, 2, 'NORMAL', 'Isaías 11:1-5'), (12, 3, 'NORMAL', '2 Corintios 3:1-13'), (12, 4, 'NORMAL', 'Jonás 3'),
(12, 5, 'NORMAL', 'Éxodo 3'), (12, 7, 'NORMAL', 'Romanos 10:14-21'), (12, 8, 'NORMAL', '1 Corintios 9:15-27'), (12, 9, 'NORMAL', 'Hechos 17:16-34'),
(12, 10, 'NORMAL', 'Marcos 6:7-13'), (12, 11, 'NORMAL', 'Lucas 9:1-6'), (12, 12, 'NORMAL', 'Génesis 6:9-22'), (12, 14, 'NORMAL', 'Mateo 8:5-13'),
(12, 15, 'NORMAL', 'Mateo 17:14-21'), (12, 16, 'NORMAL', 'Marcos 9:14-29'), (12, 17, 'NORMAL', 'Juan 20:24-31'), (12, 18, 'NORMAL', 'Hebreos 11:1-12'),
(12, 19, 'NORMAL', 'Santiago 2:14-26'), (12, 21, 'NORMAL', 'Números 27:12-23'), (12, 22, 'NORMAL', '2 Reyes 2'), (12, 23, 'NORMAL', 'Marcos 3:13-19'),
(12, 24, 'NORMAL', 'Juan 15:1-17'), (12, 25, 'NORMAL', '2 Timoteo 2:1-13'), (12, 26, 'NORMAL', 'Hechos 14:8-23'), (12, 28, 'NORMAL', 'Deuteronomio 5:1-21'),
(12, 29, 'NORMAL', 'Lucas 2:41-52'), (12, 30, 'NORMAL', '1 Timoteo 5:1-9'), (12, 31, 'NORMAL', 'Proverbios 15:20-33')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (DICIEMBRE)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(12, 6, 'DOMINGO', NULL, 'Pastor Gustavo Marto: Seguir la dirección del Espíritu Santo (Romanos 8:14)'),
(12, 13, 'DOMINGO', NULL, 'Pastor Gustavo Marto: Una visión clara para alcanzar los perdidos (Hechos 5:42)'),
(12, 20, 'DOMINGO', NULL, 'Pastor Gustavo Marto: Enseñanza de fe clara y práctica; Preparar discípulos (Jeremías 23:4; Mateo 9:37-38)'),
(12, 27, 'DOMINGO', NULL, 'Pastor Gustavo Marto: Crear un ambiente de honra y familia espiritual (Romanos 12:10)')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;

-- =======================================================
-- SIMULACIÓN DE CARGA DE DATOS - DIARIO 2027: AÑO COMPLETO
-- Diario ID = 2.
-- El contenido es inventado para demostrar la modularidad.
-- =======================================================

-- 1. Inserción del nuevo Diario Anual (ID = 2)
INSERT INTO Diario_Anual (id, anio, titulo, tema_principal, status) VALUES
(2, 2027, 'Crecimiento y Multiplicación', '\"He aquí, yo hago cosa nueva; pronto saldrá a luz; ¿no la conoceréis? Otra vez abriré camino en el desierto, y ríos en la soledad.\" Isaías 43:19', 'Activo')
ON CONFLICT (id) DO NOTHING;

-- 2. Estructura de Campos_Diario para 2027 (Copiada del ID=1 y modificada)

INSERT INTO Campos_Diario (diario_id, orden, nombre_campo, tipo_entrada, tipo_input, es_requerido) VALUES
(2, 1, '2027 Escoge un versículo para meditar en el día y escribelo:', 'VERSICULO', 'TEXTO', TRUE),
(2, 2, '2027 ¿Comó puedes aplicarlo en tu vida y asi desarrollar nuestro avivamiento?', 'APLICACION', 'TEXTAREA', TRUE),
(2, 3, 'Oración: Utilice este espacio para agradecer.', 'ORACION', 'AUDIO', TRUE),
(2, 4, 'Prioridades para este Día', 'PRIORIDADES', 'TEXTAREA', TRUE)
ON CONFLICT (diario_id, nombre_campo) DO NOTHING;


-- =======================================================
-- DATOS PARA ENERO 2027 (Asumimos mes_id = 13)
-- El 1 de Enero de 2027 es Viernes.
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(13, 2, 1, 'ENERO', 'El Fundamento Apostólico', '\"Así que ya no sois extranjeros ni advenedizos, sino conciudadanos de los santos, y miembros de la familia de Dios.\" Efesios 2:19')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (ENERO 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(13, 1, 'NORMAL', 'Salmos 90:1-12'), (13, 2, 'NORMAL', 'Hechos 4:23-31'), (13, 4, 'NORMAL', '2 Timoteo 3:10-17'), (13, 5, 'NORMAL', 'Juan 14:15-26'),
(13, 6, 'NORMAL', 'Mateo 25:14-30'), (13, 7, 'NORMAL', 'Filipenses 4:4-9'), (13, 8, 'NORMAL', 'Éxodo 14:1-14'), (13, 9, 'NORMAL', '1 Pedro 2:1-10'),
(13, 11, 'NORMAL', 'Colosenses 3:1-11'), (13, 12, 'NORMAL', 'Isaías 58:6-12'), (13, 13, 'NORMAL', 'Romanos 12:9-21'), (13, 14, 'NORMAL', 'Gálatas 5:22-26'),
(13, 15, 'NORMAL', '2 Corintios 5:17-21'), (13, 16, 'NORMAL', 'Proverbios 4:20-27'), (13, 18, 'NORMAL', 'Hebreos 12:1-13'), (13, 19, 'NORMAL', 'Santiago 1:19-27'),
(13, 20, 'NORMAL', '1 Tesalonicenses 5:12-22'), (13, 21, 'NORMAL', 'Lucas 10:25-37'), (13, 22, 'NORMAL', 'Efesios 4:1-6'), (13, 23, 'NORMAL', 'Hechos 2:42-47'),
(13, 25, 'NORMAL', 'Romanos 10:9-17'), (13, 26, 'NORMAL', 'Hebreos 4:12-16'), (13, 27, 'NORMAL', 'Salmos 119:105-112'), (13, 28, 'NORMAL', 'Jeremías 29:11-14'),
(13, 29, 'NORMAL', 'Malaquías 3:10-12'), (13, 30, 'NORMAL', 'Hechos 13:4-12'), (13, 31, 'NORMAL', 'Mateo 6:19-24')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (ENERO 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(13, 3, 'DOMINGO', NULL, 'Reflexión: El poder de un fundamento sólido en la Palabra.'),
(13, 10, 'DOMINGO', NULL, 'Reflexión: La unidad de la Iglesia como motor de crecimiento.'),
(13, 17, 'DOMINGO', NULL, 'Reflexión: Preparando el corazón para la siembra y la cosecha.'),
(13, 24, 'DOMINGO', NULL, 'Reflexión: Liderazgo de servicio y multiplicación.'),
(13, 31, 'DOMINGO', NULL, 'Reflexión: El gozo en la obediencia y la generosidad.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA FEBRERO 2027 (Asumimos mes_id = 14)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(14, 2, 2, 'FEBRERO', 'El Espíritu de Sabiduría', '\"Y manifiéstese en nosotros la hermosura de Jehová nuestro Dios; y la obra de nuestras manos confirma sobre nosotros; sí, la obra de nuestras manos confirma.\" Salmos 90:17')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (FEBRERO 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(14, 1, 'NORMAL', 'Efesios 1:15-23'), (14, 2, 'NORMAL', 'Santiago 3:13-18'), (14, 3, 'NORMAL', 'Proverbios 2:1-11'), (14, 4, 'NORMAL', '1 Corintios 1:18-31'),
(14, 5, 'NORMAL', 'Juan 16:12-15'), (14, 6, 'NORMAL', 'Romanos 12:1-3'), (14, 8, 'NORMAL', 'Isaías 11:2-5'), (14, 9, 'NORMAL', 'Colosenses 2:2-3'),
(14, 10, 'NORMAL', 'Proverbios 8:12-21'), (14, 11, 'NORMAL', '1 Reyes 3:5-14'), (14, 12, 'NORMAL', 'Efesios 5:15-17'), (14, 13, 'NORMAL', 'Salmos 14:1-7'),
(14, 15, 'NORMAL', 'Jeremías 9:23-24'), (14, 16, 'NORMAL', 'Hechos 6:1-7'), (14, 17, 'NORMAL', 'Lucas 6:46-49'), (14, 18, 'NORMAL', 'Proverbios 16:16-24'),
(14, 19, 'NORMAL', '2 Timoteo 2:7-13'), (14, 20, 'NORMAL', 'Santiago 5:13-18'), (14, 22, 'NORMAL', 'Daniel 2:20-23'), (14, 23, 'NORMAL', 'Proverbios 3:13-18'),
(14, 24, 'NORMAL', 'Eclesiastés 7:11-12'), (14, 25, 'NORMAL', 'Salmos 111:10'), (14, 26, 'NORMAL', 'Mateo 7:24-27'), (14, 27, 'NORMAL', 'Gálatas 6:7-10'),
(14, 28, 'NORMAL', 'Romanos 11:33-36')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (FEBRERO 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(14, 7, 'DOMINGO', NULL, 'Reflexión: La Sabiduría de Dios para los Negocios y la Familia.'),
(14, 14, 'DOMINGO', NULL, 'Reflexión: La Ciencia del Reino y su aplicación práctica.'),
(14, 21, 'DOMINGO', NULL, 'Reflexión: Entendimiento y Espíritu de Consejo para el liderazgo.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA MARZO 2027 (Asumimos mes_id = 15)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(15, 2, 3, 'MARZO', 'El Fuego del Evangelismo', '\"Pero recibiréis poder, cuando haya venido sobre vosotros el Espíritu Santo, y me seréis testigos en Jerusalén, en toda Judea, en Samaria, y hasta lo último de la tierra.\" Hechos 1:8')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (MARZO 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(15, 1, 'NORMAL', 'Romanos 10:11-17'), (15, 2, 'NORMAL', '2 Timoteo 4:1-5'), (15, 3, 'NORMAL', 'Marcos 16:15-18'), (15, 4, 'NORMAL', 'Isaías 6:8-10'),
(15, 5, 'NORMAL', 'Hechos 8:26-38'), (15, 6, 'NORMAL', 'Mateo 9:35-38'), (15, 8, 'NORMAL', 'Juan 4:31-38'), (15, 9, 'NORMAL', '1 Corintios 9:19-23'),
(15, 10, 'NORMAL', 'Hechos 13:1-3'), (15, 11, 'NORMAL', 'Lucas 19:1-10'), (15, 12, 'NORMAL', 'Romanos 1:16-17'), (15, 13, 'NORMAL', 'Hechos 2:37-41'),
(15, 15, 'NORMAL', '2 Corintios 4:3-6'), (15, 16, 'NORMAL', 'Hechos 17:16-34'), (15, 17, 'NORMAL', '1 Pedro 3:15-17'), (15, 18, 'NORMAL', 'Juan 3:16-21'),
(15, 19, 'NORMAL', 'Jeremías 1:4-10'), (15, 20, 'NORMAL', 'Ezequiel 3:17-21'), (15, 22, 'NORMAL', 'Salmos 96:1-13'), (15, 23, 'NORMAL', 'Apocalipsis 22:16-17'),
(15, 24, 'NORMAL', 'Hechos 14:19-28'), (15, 25, 'NORMAL', 'Lucas 10:1-12'), (15, 26, 'NORMAL', 'Mateo 28:18-20'), (15, 27, 'NORMAL', 'Hechos 20:24-38'),
(15, 29, 'NORMAL', '2 Corintios 5:18-20'), (15, 30, 'NORMAL', 'Isaías 49:6-7'), (15, 31, 'NORMAL', 'Hechos 11:19-26')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (MARZO 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(15, 7, 'DOMINGO', NULL, 'Reflexión: La urgencia de la Gran Comisión.'),
(15, 14, 'DOMINGO', NULL, 'Reflexión: El Espíritu Santo como capacitador para el testimonio.'),
(15, 21, 'DOMINGO', NULL, 'Reflexión: Superando el temor y la vergüenza al predicar.'),
(15, 28, 'DOMINGO', NULL, 'Reflexión: El fruto de la obediencia en el evangelismo.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA ABRIL 2027 (Asumimos mes_id = 16)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(16, 2, 4, 'ABRIL', 'Desarrollo de Liderazgo', '\"Lo que has oído de mí ante muchos testigos, esto encarga a hombres fieles que sean idóneos para enseñar también a otros.\" 2 Timoteo 2:2')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (ABRIL 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(16, 1, 'NORMAL', 'Hechos 6:1-7'), (16, 2, 'NORMAL', 'Éxodo 18:13-26'), (16, 3, 'NORMAL', 'Nehemías 2:11-20'), (16, 5, 'NORMAL', '1 Timoteo 3:1-13'),
(16, 6, 'NORMAL', 'Tito 1:5-9'), (16, 7, 'NORMAL', 'Proverbios 11:14'), (16, 8, 'NORMAL', '2 Timoteo 2:14-19'), (16, 9, 'NORMAL', 'Romanos 12:4-8'),
(16, 10, 'NORMAL', '1 Pedro 5:1-4'), (16, 12, 'NORMAL', 'Jeremías 3:15'), (16, 13, 'NORMAL', 'Mateo 20:25-28'), (16, 14, 'NORMAL', 'Marcos 10:42-45'),
(16, 15, 'NORMAL', 'Filipenses 2:3-8'), (16, 16, 'NORMAL', 'Hechos 20:28-31'), (16, 17, 'NORMAL', '1 Tesalonicenses 5:12-13'), (16, 19, 'NORMAL', 'Juan 10:11-18'),
(16, 20, 'NORMAL', 'Efesios 4:11-16'), (16, 21, 'NORMAL', 'Hechos 14:21-23'), (16, 22, 'NORMAL', '2 Corintios 10:4-6'), (16, 23, 'NORMAL', 'Proverbios 27:17'),
(16, 24, 'NORMAL', 'Hebreos 13:7'), (16, 26, 'NORMAL', 'Hechos 15:1-21'), (16, 27, 'NORMAL', 'Gálatas 6:1-5'), (16, 28, 'NORMAL', 'Lucas 22:24-27'),
(16, 29, 'NORMAL', '1 Corintios 11:1'), (16, 30, 'NORMAL', 'Juan 13:12-17')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (ABRIL 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(16, 4, 'DOMINGO', NULL, 'Reflexión: La selección y capacitación de hombres fieles.'),
(16, 11, 'DOMINGO', NULL, 'Reflexión: El liderazgo es influencia, no posición.'),
(16, 18, 'DOMINGO', NULL, 'Reflexión: La humildad como marca del verdadero siervo.'),
(16, 25, 'DOMINGO', NULL, 'Reflexión: La multiplicación del ministerio y la delegación.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA MAYO 2027 (Asumimos mes_id = 17)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(17, 2, 5, 'MAYO', 'Sanidad y Restauración', '\"Mas él herido fue por nuestras rebeliones, molido por nuestros pecados; el castigo de nuestra paz fue sobre él, y por su llaga fuimos nosotros curados.\" Isaías 53:5')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (MAYO 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(17, 1, 'NORMAL', 'Marcos 16:17-18'), (17, 2, 'NORMAL', 'Santiago 5:14-16'), (17, 3, 'NORMAL', 'Mateo 8:14-17'), (17, 4, 'NORMAL', 'Salmos 103:1-5'),
(17, 5, 'NORMAL', 'Éxodo 15:26'), (17, 6, 'NORMAL', '3 Juan 1:2'), (17, 7, 'NORMAL', 'Hechos 3:1-10'), (17, 8, 'NORMAL', 'Marcos 1:40-45'),
(17, 10, 'NORMAL', 'Jeremías 30:17'), (17, 11, 'NORMAL', 'Salmos 41:1-3'), (17, 12, 'NORMAL', 'Romanos 8:11'), (17, 13, 'NORMAL', 'Mateo 9:1-8'),
(17, 14, 'NORMAL', 'Proverbios 4:20-22'), (17, 15, 'NORMAL', 'Lucas 4:18-19'), (17, 16, 'NORMAL', 'Juan 10:10'), (17, 18, 'NORMAL', 'Isaías 41:10'),
(17, 19, 'NORMAL', 'Isaías 58:8-9'), (17, 20, 'NORMAL', 'Hechos 9:32-35'), (17, 21, 'NORMAL', 'Lucas 13:10-17'), (17, 22, 'NORMAL', 'Gálatas 3:13-14'),
(17, 23, 'NORMAL', 'Hechos 4:29-31'), (17, 25, 'NORMAL', 'Juan 5:1-9'), (17, 26, 'NORMAL', 'Salmos 34:17-20'), (17, 27, 'NORMAL', 'Mateo 15:29-31'),
(17, 28, 'NORMAL', '1 Pedro 2:24'), (17, 29, 'NORMAL', 'Mateo 10:7-8'), (17, 30, 'NORMAL', 'Apocalipsis 21:4'), (17, 31, 'NORMAL', 'Juan 11:40')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (MAYO 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(17, 9, 'DOMINGO', NULL, 'Reflexión: La fe y la sanidad divina en el ministerio.'),
(17, 16, 'DOMINGO', NULL, 'Reflexión: Sanidad integral (cuerpo, alma y espíritu).'),
(17, 23, 'DOMINGO', NULL, 'Reflexión: La liberación de opresión y enfermedades crónicas.'),
(17, 30, 'DOMINGO', NULL, 'Reflexión: La unción del Espíritu Santo para la restauración.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA JUNIO 2027 (Asumimos mes_id = 18)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(18, 2, 6, 'JUNIO', 'Honra y Paternidad', '\"Amaos los unos a los otros con amor fraternal; en cuanto a honra, prefiriéndoos los unos a los otros.\" Romanos 12:10')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (JUNIO 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(18, 1, 'NORMAL', 'Éxodo 20:12'), (18, 2, 'NORMAL', 'Proverbios 3:9-10'), (18, 3, 'NORMAL', '1 Timoteo 5:17-18'), (18, 4, 'NORMAL', 'Filipenses 2:3-4'),
(18, 5, 'NORMAL', 'Romanos 13:7'), (18, 7, 'NORMAL', '1 Corintios 4:15-16'), (18, 8, 'NORMAL', 'Proverbios 27:18'), (18, 9, 'NORMAL', 'Hebreos 13:7'),
(18, 10, 'NORMAL', '2 Reyes 2:9-15'), (18, 11, 'NORMAL', 'Efesios 6:1-3'), (18, 12, 'NORMAL', 'Colosenses 3:20'), (18, 14, 'NORMAL', '1 Pedro 2:17'),
(18, 15, 'NORMAL', 'Romanos 12:13'), (18, 16, 'NORMAL', 'Gálatas 6:6'), (18, 17, 'NORMAL', '1 Tesalonicenses 5:12-13'), (18, 18, 'NORMAL', 'Lucas 14:12-14'),
(18, 19, 'NORMAL', 'Proverbios 15:33'), (18, 21, 'NORMAL', 'Salmos 133:1-3'), (18, 22, 'NORMAL', 'Juan 13:34-35'), (18, 23, 'NORMAL', 'Romanos 14:10'),
(18, 24, 'NORMAL', '1 Corintios 10:24'), (18, 25, 'NORMAL', 'Efesios 4:2-3'), (18, 26, 'NORMAL', 'Hebreos 13:17'), (18, 28, 'NORMAL', 'Proverbios 22:4'),
(18, 29, 'NORMAL', '1 Pedro 5:5-6'), (18, 30, 'NORMAL', 'Malaquías 1:6')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (JUNIO 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(18, 6, 'DOMINGO', NULL, 'Reflexión: La Honra a Dios con nuestros bienes.'),
(18, 13, 'DOMINGO', NULL, 'Reflexión: Paternidad espiritual y la visión de la Iglesia.'),
(18, 20, 'DOMINGO', NULL, 'Reflexión: Honra a los líderes y la bendición de la sujeción.'),
(18, 27, 'DOMINGO', NULL, 'Reflexión: El amor fraternal como el más alto nivel de honra.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA JULIO 2027 (Asumimos mes_id = 19)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(19, 2, 7, 'JULIO', 'Guerra Espiritual y Victoria', '\"Porque las armas de nuestra milicia no son carnales, sino poderosas en Dios para la destrucción de fortalezas.\" 2 Corintios 10:4')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (JULIO 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(19, 1, 'NORMAL', 'Efesios 6:10-18'), (19, 2, 'NORMAL', 'Santiago 4:7-10'), (19, 3, 'NORMAL', '1 Pedro 5:8-10'), (19, 5, 'NORMAL', 'Hechos 19:11-20'),
(19, 6, 'NORMAL', 'Mateo 18:18-20'), (19, 7, 'NORMAL', 'Marcos 3:23-27'), (19, 8, 'NORMAL', 'Lucas 10:19'), (19, 9, 'NORMAL', '2 Timoteo 4:18'),
(19, 10, 'NORMAL', 'Romanos 8:37-39'), (19, 12, 'NORMAL', 'Isaías 54:17'), (19, 13, 'NORMAL', 'Apocalipsis 12:10-11'), (19, 14, 'NORMAL', 'Juan 14:30-31'),
(19, 15, 'NORMAL', '2 Tesalonicenses 3:3'), (19, 16, 'NORMAL', 'Colosenses 2:15'), (19, 17, 'NORMAL', 'Zacarías 3:1-7'), (19, 19, 'NORMAL', 'Deuteronomio 28:7'),
(19, 20, 'NORMAL', 'Salmos 91:1-16'), (19, 21, 'NORMAL', 'Hebreos 2:14-15'), (19, 22, 'NORMAL', 'Juan 8:36'), (19, 23, 'NORMAL', 'Isaías 41:10-13'),
(19, 24, 'NORMAL', 'Hechos 16:25-34'), (19, 26, 'NORMAL', '1 Juan 4:4'), (19, 27, 'NORMAL', 'Romanos 16:20'), (19, 28, 'NORMAL', 'Josué 1:9'),
(19, 29, 'NORMAL', 'Salmos 59:1-5'), (19, 30, 'NORMAL', '2 Corintios 2:14'), (19, 31, 'NORMAL', 'Mateo 16:18')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (JULIO 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(19, 4, 'DOMINGO', NULL, 'Reflexión: Las armas espirituales y la armadura de Dios.'),
(19, 11, 'DOMINGO', NULL, 'Reflexión: Autoridad del creyente sobre el reino de las tinieblas.'),
(19, 18, 'DOMINGO', NULL, 'Reflexión: La Palabra, la Sangre y el Testimonio como estrategia.'),
(19, 25, 'DOMINGO', NULL, 'Reflexión: El poder de la intercesión y la liberación.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA AGOSTO 2027 (Asumimos mes_id = 20)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(20, 2, 8, 'AGOSTO', 'Finanzas del Reino', '\"El que siembra escasamente, también segará escasamente; y el que siembra generosamente, generosamente también segará.\" 2 Corintios 9:6')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (AGOSTO 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(20, 1, 'NORMAL', 'Malaquías 3:8-12'), (20, 2, 'NORMAL', 'Proverbios 3:9-10'), (20, 3, 'NORMAL', 'Lucas 6:38'), (20, 4, 'NORMAL', '2 Corintios 9:6-11'),
(20, 5, 'NORMAL', 'Filipenses 4:19'), (20, 6, 'NORMAL', 'Génesis 26:12-14'), (20, 7, 'NORMAL', 'Deuteronomio 8:18'), (20, 9, 'NORMAL', 'Mateo 6:24-34'),
(20, 10, 'NORMAL', 'Salmos 23:1-6'), (20, 11, 'NORMAL', 'Proverbios 10:4'), (20, 12, 'NORMAL', '1 Timoteo 6:10-12'), (20, 13, 'NORMAL', 'Hebreos 13:5'),
(20, 14, 'NORMAL', 'Mateo 25:14-30'), (20, 16, 'NORMAL', 'Gálatas 6:7-10'), (20, 17, 'NORMAL', 'Lucas 16:10-13'), (20, 18, 'NORMAL', 'Proverbios 22:7'),
(20, 19, 'NORMAL', 'Deuteronomio 28:1-14'), (20, 20, 'NORMAL', 'Isaías 1:19'), (20, 21, 'NORMAL', 'Romanos 13:8'), (20, 23, 'NORMAL', 'Proverbios 11:24-25'),
(20, 24, 'NORMAL', '2 Corintios 8:7'), (20, 25, 'NORMAL', 'Hechos 4:32-35'), (20, 26, 'NORMAL', 'Efesios 4:28'), (20, 27, 'NORMAL', '1 Crónicas 29:11-12'),
(20, 28, 'NORMAL', 'Mateo 7:11'), (20, 30, 'NORMAL', 'Salmos 37:25-26'), (20, 31, 'NORMAL', 'Juan 15:5')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (AGOSTO 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(20, 8, 'DOMINGO', NULL, 'Reflexión: La prioridad del Reino sobre las finanzas.'),
(20, 15, 'DOMINGO', NULL, 'Reflexión: Siembra y Cosecha: Principios de la mayordomía.'),
(20, 22, 'DOMINGO', NULL, 'Reflexión: Deudas, Préstamos y Sabiduría Financiera.'),
(20, 29, 'DOMINGO', NULL, 'Reflexión: La Generosidad como herramienta de multiplicación.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA SEPTIEMBRE 2027 (Asumimos mes_id = 21)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(21, 2, 9, 'SEPTIEMBRE', 'La Oración Ferviente', '\"La oración eficaz del justo puede mucho.\" Santiago 5:16')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (SEPTIEMBRE 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(21, 1, 'NORMAL', 'Mateo 6:5-15'), (21, 2, 'NORMAL', 'Lucas 11:1-13'), (21, 3, 'NORMAL', 'Santiago 5:13-18'), (21, 4, 'NORMAL', '1 Juan 5:14-15'),
(21, 6, 'NORMAL', 'Marcos 11:24'), (21, 7, 'NORMAL', 'Juan 15:7'), (21, 8, 'NORMAL', 'Colosenses 4:2'), (21, 9, 'NORMAL', 'Efesios 6:18'),
(21, 10, 'NORMAL', 'Hechos 4:31'), (21, 11, 'NORMAL', 'Romanos 8:26-27'), (21, 13, 'NORMAL', 'Lucas 18:1-8'), (21, 14, 'NORMAL', '1 Tesalonicenses 5:17'),
(21, 15, 'NORMAL', 'Salmos 5:1-3'), (21, 16, 'NORMAL', 'Jeremías 33:3'), (21, 17, 'NORMAL', 'Hebreos 4:16'), (21, 18, 'NORMAL', 'Filipenses 4:6-7'),
(21, 20, 'NORMAL', 'Mateo 21:21-22'), (21, 21, 'NORMAL', 'Isaías 59:1-2'), (21, 22, 'NORMAL', 'Ezequiel 22:30'), (21, 23, 'NORMAL', 'Nehemías 1:1-11'),
(21, 24, 'NORMAL', 'Hechos 12:5-19'), (21, 25, 'NORMAL', '2 Crónicas 7:14'), (21, 27, 'NORMAL', 'Juan 17:1-26'), (21, 28, 'NORMAL', 'Salmos 42:1-11'),
(21, 29, 'NORMAL', 'Daniel 9:3-19'), (21, 30, 'NORMAL', 'Hechos 1:14')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (SEPTIEMBRE 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(21, 5, 'DOMINGO', NULL, 'Reflexión: La intercesión por nuestra ciudad y nación.'),
(21, 12, 'DOMINGO', NULL, 'Reflexión: Orar en el Espíritu y la oración por misterios.'),
(21, 19, 'DOMINGO', NULL, 'Reflexión: El ayuno y la oración como disciplinas de poder.'),
(21, 26, 'DOMINGO', NULL, 'Reflexión: La unidad en la oración y la respuesta de Dios.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA OCTUBRE 2027 (Asumimos mes_id = 22)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(22, 2, 10, 'OCTUBRE', 'Excelencia en el Servicio', '\"Todo lo que te viniere a la mano para hacer, hazlo según tus fuerzas.\" Eclesiastés 9:10')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (OCTUBRE 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(22, 1, 'NORMAL', 'Colosenses 3:23-24'), (22, 2, 'NORMAL', '1 Corintios 10:31'), (22, 4, 'NORMAL', '2 Timoteo 2:15'), (22, 5, 'NORMAL', 'Mateo 25:21'),
(22, 6, 'NORMAL', 'Proverbios 12:24'), (22, 7, 'NORMAL', 'Romanos 12:11'), (22, 8, 'NORMAL', '1 Corintios 15:58'), (22, 9, 'NORMAL', 'Efesios 4:1-3'),
(22, 11, 'NORMAL', 'Filipenses 2:14-16'), (22, 12, 'NORMAL', 'Tito 2:7-8'), (22, 13, 'NORMAL', '1 Pedro 4:10-11'), (22, 14, 'NORMAL', 'Romanos 12:6-8'),
(22, 15, 'NORMAL', '1 Corintios 12:4-7'), (22, 16, 'NORMAL', 'Efesios 2:10'), (22, 18, 'NORMAL', 'Hebreos 6:10'), (22, 19, 'NORMAL', 'Gálatas 6:9-10'),
(22, 20, 'NORMAL', 'Proverbios 22:29'), (22, 21, 'NORMAL', '1 Timoteo 4:12'), (22, 22, 'NORMAL', 'Lucas 19:17'), (22, 23, 'NORMAL', 'Juan 13:1-5'),
(22, 25, 'NORMAL', 'Salmos 100:1-5'), (22, 26, 'NORMAL', 'Mateo 5:16'), (22, 27, 'NORMAL', '2 Corintios 8:12'), (22, 28, 'NORMAL', '1 Corintios 9:24-27'),
(22, 29, 'NORMAL', 'Proverbios 14:23'), (22, 30, 'NORMAL', 'Hebreos 10:24-25'), (22, 31, 'NORMAL', 'Lucas 17:10')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (OCTUBRE 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(22, 3, 'DOMINGO', NULL, 'Reflexión: El trabajo con excelencia como forma de adoración.'),
(22, 10, 'DOMINGO', NULL, 'Reflexión: Descubriendo y usando nuestros dones espirituales en el servicio.'),
(22, 17, 'DOMINGO', NULL, 'Reflexión: Servir con diligencia y pasión, no por obligación.'),
(22, 24, 'DOMINGO', NULL, 'Reflexión: El servicio al prójimo y el testimonio.'),
(22, 31, 'DOMINGO', NULL, 'Reflexión: La recompensa de la fidelidad y la perseverancia.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA NOVIEMBRE 2027 (Asumimos mes_id = 23)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(23, 2, 11, 'NOVIEMBRE', 'La Vida en Comunidad', '\"Mirad cuán bueno y cuán delicioso es habitar los hermanos juntos en armonía!\" Salmos 133:1')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (NOVIEMBRE 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(23, 1, 'NORMAL', 'Hechos 2:42-47'), (23, 2, 'NORMAL', 'Romanos 15:5-7'), (23, 3, 'NORMAL', 'Efesios 4:31-32'), (23, 4, 'NORMAL', 'Colosenses 3:12-14'),
(23, 5, 'NORMAL', '1 Pedro 3:8-9'), (23, 6, 'NORMAL', 'Romanos 12:10'), (23, 8, 'NORMAL', 'Hebreos 10:24-25'), (23, 9, 'NORMAL', 'Filipenses 2:1-4'),
(23, 10, 'NORMAL', '1 Corintios 12:12-27'), (23, 11, 'NORMAL', 'Efesios 4:11-16'), (23, 12, 'NORMAL', 'Juan 13:34-35'), (23, 13, 'NORMAL', 'Gálatas 6:1-2'),
(23, 15, 'NORMAL', '1 Tesalonicenses 5:11'), (23, 16, 'NORMAL', 'Proverbios 27:6'), (23, 17, 'NORMAL', 'Santiago 5:16'), (23, 18, 'NORMAL', 'Mateo 18:15-17'),
(23, 19, 'NORMAL', 'Romanos 14:19'), (23, 20, 'NORMAL', '1 Corintios 1:10'), (23, 22, 'NORMAL', '2 Corintios 13:11'), (23, 23, 'NORMAL', '1 Juan 1:7'),
(23, 24, 'NORMAL', 'Hebreos 3:12-13'), (23, 25, 'NORMAL', 'Colosenses 3:15'), (23, 26, 'NORMAL', 'Romanos 15:13'), (23, 27, 'NORMAL', '1 Corintios 13:4-7'),
(23, 29, 'NORMAL', 'Salmos 34:12-14'), (23, 30, 'NORMAL', 'Proverbios 17:17')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (NOVIEMBRE 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(23, 7, 'DOMINGO', NULL, 'Reflexión: La importancia de los encuentros de amistad.'),
(23, 14, 'DOMINGO', NULL, 'Reflexión: Los dones en la comunidad y el Cuerpo de Cristo.'),
(23, 21, 'DOMINGO', NULL, 'Reflexión: Resolución de conflictos en el amor.'),
(23, 28, 'DOMINGO', NULL, 'Reflexión: La armonía, la paz y la unción de la unidad.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA DICIEMBRE 2027 (Asumimos mes_id = 24)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(24, 2, 12, 'DICIEMBRE', 'Visión y Futuro', '\"Donde no hay visión, el pueblo se desenfrena; mas el que guarda la ley es bienaventurado.\" Proverbios 29:18')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (DICIEMBRE 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(24, 1, 'NORMAL', 'Habacuc 2:2-3'), (24, 2, 'NORMAL', 'Proverbios 16:3'), (24, 3, 'NORMAL', 'Isaías 42:9'), (24, 4, 'NORMAL', 'Efesios 3:20-21'),
(24, 6, 'NORMAL', 'Jeremías 29:11'), (24, 7, 'NORMAL', 'Filipenses 3:13-14'), (24, 8, 'NORMAL', 'Proverbios 4:25-27'), (24, 9, 'NORMAL', 'Salmos 37:4-5'),
(24, 10, 'NORMAL', 'Hechos 1:8'), (24, 11, 'NORMAL', 'Mateo 6:10'), (24, 12, 'NORMAL', 'Isaías 54:2-3'), (24, 13, 'NORMAL', 'Marcos 11:24'),
(24, 14, 'NORMAL', 'Romanos 5:5'), (24, 15, 'NORMAL', '1 Corintios 2:9-10'), (24, 16, 'NORMAL', '2 Pedro 3:13'), (24, 17, 'NORMAL', 'Apocalipsis 21:1-5'),
(24, 18, 'NORMAL', 'Colosenses 1:9-10'), (24, 19, 'NORMAL', '1 Corintios 3:6-9'), (24, 21, 'NORMAL', 'Isaías 43:18-19'), (24, 22, 'NORMAL', 'Lucas 12:48'),
(24, 23, 'NORMAL', 'Mateo 24:14'), (24, 24, 'NORMAL', 'Proverbios 28:18'), (24, 25, 'NORMAL', 'Juan 1:12'), (24, 26, 'NORMAL', '2 Timoteo 1:7'),
(24, 27, 'NORMAL', 'Hechos 2:17'), (24, 28, 'NORMAL', 'Mateo 25:31-46'), (24, 29, 'NORMAL', 'Gálatas 5:1'), (24, 30, 'NORMAL', 'Hebreos 10:35-36'),
(24, 31, 'NORMAL', 'Apocalipsis 22:20')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (DICIEMBRE 2027)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(24, 5, 'DOMINGO', NULL, 'Reflexión: Escribir la visión y correr con ella.'),
(24, 12, 'DOMINGO', NULL, 'Reflexión: Planificación intencional para la multiplicación.'),
(24, 19, 'DOMINGO', NULL, 'Reflexión: La fe y la paciencia para ver el cumplimiento.'),
(24, 26, 'DOMINGO', NULL, 'Reflexión: Resumen del año y declaración de avance para el próximo año.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- SIMULACIÓN DE CARGA DE DATOS - DIARIO 2025: AÑO COMPLETO
-- Diario ID = 3.
-- Título: "Héroes de la Fe"
-- El contenido es inventado para demostrar la modularidad.
-- =======================================================

-- 1. Inserción del nuevo Diario Anual (ID = 3)
INSERT INTO Diario_Anual (id, anio, titulo, tema_principal, status) VALUES
(3, 2025, 'Héroes de la Fe', '\"Prepárate para obtener tu gálardon.\" 2 Corintios 12:18b NTV, 1 Pedro 2:21 RVR 1960', 'Activo')
ON CONFLICT (id) DO NOTHING;
SELECT setval('diario_anual_id_seq', (SELECT MAX(id) FROM diario_anual));

-- 2. Estructura de Campos_Diario para 2025

INSERT INTO Campos_Diario (diario_id, orden, nombre_campo, tipo_entrada, tipo_input, es_requerido) VALUES
(3, 1, '¿Qué versiculó de este pasaje te impactó más? Ecríbelo.', 'VERSICULO', 'TEXTO', TRUE),
(3, 2, '¿Qué cosas tomas de este personaje para imitarlo y de esta manera seguir sus pisadas?', 'APLICACION', 'TEXTAREA', TRUE),
(3, 3, 'Oración: Utilice este espacio para agradecer.', 'ORACION', 'AUDIO', TRUE),
(3, 4, 'Prioridades para este Día', 'PRIORIDADES', 'TEXTAREA', TRUE)
ON CONFLICT (diario_id, nombre_campo) DO NOTHING;


-- =======================================================
-- DATOS PARA ENERO 2025 (Asumimos mes_id = 25)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(25, 3, 1, 'ENERO', 'Cimentando la Base', '\"Si la fe tuviereis como un grano de mostaza.\" Mateo 17:20')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (ENERO 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(25, 1, 'NORMAL', 'Salmos 1:1-6'), (25, 2, 'NORMAL', 'Proverbios 3:5-6'), (25, 3, 'NORMAL', 'Mateo 7:24-27'), (25, 4, 'NORMAL', 'Lucas 6:46-49'),
(25, 6, 'NORMAL', 'Isaías 40:28-31'), (25, 7, 'NORMAL', 'Romanos 5:3-5'), (25, 8, 'NORMAL', 'Hebreos 10:35-36'), (25, 9, 'NORMAL', 'Santiago 1:2-4'),
(25, 10, 'NORMAL', '2 Corintios 4:16-18'), (25, 11, 'NORMAL', 'Efesios 3:14-19'), (25, 13, 'NORMAL', 'Colosenses 2:6-7'), (25, 14, 'NORMAL', 'Salmos 92:12-15'),
(25, 15, 'NORMAL', 'Jeremías 17:7-8'), (25, 16, 'NORMAL', 'Juan 15:4-5'), (25, 17, 'NORMAL', 'Filipenses 4:13'), (25, 18, 'NORMAL', 'Gálatas 5:22-23'),
(25, 20, 'NORMAL', '1 Pedro 5:7'), (25, 21, 'NORMAL', 'Mateo 6:25-34'), (25, 22, 'NORMAL', 'Salmos 37:23-24'), (25, 23, 'NORMAL', 'Proverbios 16:3'),
(25, 24, 'NORMAL', 'Romanos 8:28'), (25, 25, 'NORMAL', '1 Corintios 15:58'), (25, 27, 'NORMAL', 'Isaías 55:10-11'), (25, 28, 'NORMAL', '2 Timoteo 2:15'),
(25, 29, 'NORMAL', 'Salmos 119:105'), (25, 30, 'NORMAL', 'Hebreos 4:12'), (25, 31, 'NORMAL', 'Juan 8:31-32')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (ENERO 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(25, 5, 'DOMINGO', NULL, 'Reflexión: La Disciplina de la Lectura y Meditación.'),
(25, 12, 'DOMINGO', NULL, 'Reflexión: Paciencia y Perseverancia en la Formación del Carácter.'),
(25, 19, 'DOMINGO', NULL, 'Reflexión: Viviendo sin Ansiedad: La Confianza en el Proveedor.'),
(25, 26, 'DOMINGO', NULL, 'Reflexión: La Palabra como Fundamento Inmutable para el Futuro.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA FEBRERO 2025 (Asumimos mes_id = 26)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(26, 3, 2, 'FEBRERO', 'Crecimiento en la Oración', '\"Pedid, y se os dará; buscad, y hallaréis; llamad, y se os abrirá.\" Mateo 7:7')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (FEBRERO 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(26, 1, 'NORMAL', 'Lucas 11:1-13'), (26, 2, 'NORMAL', 'Mateo 6:6-8'), (26, 3, 'NORMAL', 'Santiago 5:16'), (26, 4, 'NORMAL', '1 Juan 5:14-15'),
(26, 5, 'NORMAL', 'Marcos 11:24'), (26, 6, 'NORMAL', 'Hechos 4:31'), (26, 7, 'NORMAL', 'Romanos 8:26-27'), (26, 9, 'NORMAL', 'Lucas 18:1-8'),
(26, 10, 'NORMAL', '1 Tesalonicenses 5:17'), (26, 11, 'NORMAL', 'Salmos 4:1-8'), (26, 12, 'NORMAL', 'Jeremías 33:3'), (26, 13, 'NORMAL', 'Hebreos 4:16'),
(26, 14, 'NORMAL', 'Filipenses 4:6-7'), (26, 15, 'NORMAL', 'Mateo 21:22'), (26, 16, 'NORMAL', 'Isaías 59:1-2'), (26, 17, 'NORMAL', 'Ezequiel 22:30'),
(26, 18, 'NORMAL', 'Nehemías 1:1-11'), (26, 19, 'NORMAL', 'Hechos 12:5-19'), (26, 20, 'NORMAL', '2 Crónicas 7:14'), (26, 21, 'NORMAL', 'Juan 17:1-5'),
(26, 22, 'NORMAL', 'Salmos 42:1-11'), (26, 23, 'NORMAL', 'Daniel 9:3-19'), (26, 24, 'NORMAL', 'Hechos 1:12-14'), (26, 25, 'NORMAL', 'Colosenses 4:2'),
(26, 26, 'NORMAL', 'Efesios 6:18'), (26, 27, 'NORMAL', 'Mateo 9:38'), (26, 28, 'NORMAL', 'Salmos 141:1-10')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (FEBRERO 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(26, 8, 'DOMINGO', NULL, 'Reflexión: La Oración con Fervor y Fe.'),
(26, 15, 'DOMINGO', NULL, 'Reflexión: La Intercesión Profética y Escuchando la Voz de Dios.'),
(26, 22, 'DOMINGO', NULL, 'Reflexión: La Oración por la Nación y el Liderazgo.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA MARZO 2025 (Asumimos mes_id = 27)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(27, 3, 3, 'MARZO', 'Servicio con Excelencia', '\"Todo lo que te viniere a la mano para hacer, hazlo según tus fuerzas.\" Eclesiastés 9:10')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (MARZO 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(27, 1, 'NORMAL', 'Colosenses 3:23-24'), (27, 2, 'NORMAL', '1 Corintios 10:31'), (27, 3, 'NORMAL', '2 Timoteo 2:15'), (27, 4, 'NORMAL', 'Mateo 25:21'),
(27, 5, 'NORMAL', 'Proverbios 12:24'), (27, 6, 'NORMAL', 'Romanos 12:11'), (27, 7, 'NORMAL', '1 Corintios 15:58'), (27, 8, 'NORMAL', 'Efesios 4:1-3'),
(27, 10, 'NORMAL', 'Filipenses 2:14-16'), (27, 11, 'NORMAL', 'Tito 2:7-8'), (27, 12, 'NORMAL', '1 Pedro 4:10-11'), (27, 13, 'NORMAL', 'Romanos 12:6-8'),
(27, 14, 'NORMAL', '1 Corintios 12:4-7'), (27, 15, 'NORMAL', 'Efesios 2:10'), (27, 17, 'NORMAL', 'Hebreos 6:10'), (27, 18, 'NORMAL', 'Gálatas 6:9-10'),
(27, 19, 'NORMAL', 'Proverbios 22:29'), (27, 20, 'NORMAL', '1 Timoteo 4:12'), (27, 21, 'NORMAL', 'Lucas 19:17'), (27, 22, 'NORMAL', 'Juan 13:1-5'),
(27, 24, 'NORMAL', 'Salmos 100:1-5'), (27, 25, 'NORMAL', 'Mateo 5:16'), (27, 26, 'NORMAL', '2 Corintios 8:12'), (27, 27, 'NORMAL', '1 Corintios 9:24-27'),
(27, 28, 'NORMAL', 'Proverbios 14:23'), (27, 29, 'NORMAL', 'Hebreos 10:24-25'), (27, 31, 'NORMAL', 'Lucas 17:10')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (MARZO 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(27, 9, 'DOMINGO', NULL, 'Reflexión: Descubriendo tus dones y el lugar en el Cuerpo.'),
(27, 16, 'DOMINGO', NULL, 'Reflexión: Motivación y actitud del siervo fiel.'),
(27, 23, 'DOMINGO', NULL, 'Reflexión: Excelencia: Honrando a Dios con nuestro trabajo.'),
(27, 30, 'DOMINGO', NULL, 'Reflexión: La obediencia y el servicio como culto racional.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA ABRIL 2025 (Asumimos mes_id = 28)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(28, 3, 4, 'ABRIL', 'Finanzas Bajo Principio', '\"El que siembra generosamente, generosamente también segará.\" 2 Corintios 9:6')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (ABRIL 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(28, 1, 'NORMAL', 'Malaquías 3:8-12'), (28, 2, 'NORMAL', 'Proverbios 3:9-10'), (28, 3, 'NORMAL', 'Lucas 6:38'), (28, 4, 'NORMAL', '2 Corintios 9:6-11'),
(28, 5, 'NORMAL', 'Filipenses 4:19'), (28, 7, 'NORMAL', 'Génesis 26:12-14'), (28, 8, 'NORMAL', 'Deuteronomio 8:18'), (28, 9, 'NORMAL', 'Mateo 6:24-34'),
(28, 10, 'NORMAL', 'Salmos 23:1-6'), (28, 11, 'NORMAL', 'Proverbios 10:4'), (28, 12, 'NORMAL', '1 Timoteo 6:10-12'), (28, 14, 'NORMAL', 'Hebreos 13:5'),
(28, 15, 'NORMAL', 'Mateo 25:14-30'), (28, 16, 'NORMAL', 'Gálatas 6:7-10'), (28, 17, 'NORMAL', 'Lucas 16:10-13'), (28, 18, 'NORMAL', 'Proverbios 22:7'),
(28, 19, 'NORMAL', 'Deuteronomio 28:1-14'), (28, 21, 'NORMAL', 'Isaías 1:19'), (28, 22, 'NORMAL', 'Romanos 13:8'), (28, 23, 'NORMAL', 'Proverbios 11:24-25'),
(28, 24, 'NORMAL', '2 Corintios 8:7'), (28, 25, 'NORMAL', 'Hechos 4:32-35'), (28, 26, 'NORMAL', 'Efesios 4:28'), (28, 28, 'NORMAL', '1 Crónicas 29:11-12'),
(28, 29, 'NORMAL', 'Mateo 7:11'), (28, 30, 'NORMAL', 'Salmos 37:25-26')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (ABRIL 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(28, 6, 'DOMINGO', NULL, 'Reflexión: El principio del Diezmo y la Fidelidad.'),
(28, 13, 'DOMINGO', NULL, 'Reflexión: La Fe para la Provisión y la Mayordomía.'),
(28, 20, 'DOMINGO', NULL, 'Reflexión: El Orden Financiero y la Liberación de Deudas.'),
(28, 27, 'DOMINGO', NULL, 'Reflexión: La Generosidad y la Multiplicación en el Reino.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA MAYO 2025 (Asumimos mes_id = 29)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(29, 3, 5, 'MAYO', 'Visión y Propósito', '\"Donde no hay visión, el pueblo se desenfrena; mas el que guarda la ley es bienaventurado.\" Proverbios 29:18')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (MAYO 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(29, 1, 'NORMAL', 'Habacuc 2:2-3'), (29, 2, 'NORMAL', 'Proverbios 16:3'), (29, 3, 'NORMAL', 'Isaías 42:9'), (29, 5, 'NORMAL', 'Jeremías 29:11'),
(29, 6, 'NORMAL', 'Filipenses 3:13-14'), (29, 7, 'NORMAL', 'Proverbios 4:25-27'), (29, 8, 'NORMAL', 'Salmos 37:4-5'), (29, 9, 'NORMAL', 'Hechos 1:8'),
(29, 10, 'NORMAL', 'Mateo 6:10'), (29, 12, 'NORMAL', 'Isaías 54:2-3'), (29, 13, 'NORMAL', 'Marcos 11:24'), (29, 14, 'NORMAL', 'Romanos 5:5'),
(29, 15, 'NORMAL', '1 Corintios 2:9-10'), (29, 16, 'NORMAL', '2 Pedro 3:13'), (29, 17, 'NORMAL', 'Apocalipsis 21:1-5'), (29, 19, 'NORMAL', 'Colosenses 1:9-10'),
(29, 20, 'NORMAL', '1 Corintios 3:6-9'), (29, 21, 'NORMAL', 'Isaías 43:18-19'), (29, 22, 'NORMAL', 'Lucas 12:48'), (29, 23, 'NORMAL', 'Mateo 24:14'),
(29, 24, 'NORMAL', 'Proverbios 28:18'), (29, 26, 'NORMAL', 'Juan 1:12'), (29, 27, 'NORMAL', '2 Timoteo 1:7'), (29, 28, 'NORMAL', 'Hechos 2:17'),
(29, 29, 'NORMAL', 'Mateo 25:31-46'), (29, 30, 'NORMAL', 'Gálatas 5:1'), (29, 31, 'NORMAL', 'Hebreos 10:35-36')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (MAYO 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(29, 4, 'DOMINGO', NULL, 'Reflexión: Escribiendo la Visión y el Propósito de Dios.'),
(29, 11, 'DOMINGO', NULL, 'Reflexión: La Fe para Ver lo Invisible.'),
(29, 18, 'DOMINGO', NULL, 'Reflexión: El Legado y la Ley de la Multiplicación.'),
(29, 25, 'DOMINGO', NULL, 'Reflexión: Vivir con Perspectiva Eterna y Recompensa.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA JUNIO 2025 (Asumimos mes_id = 30)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(30, 3, 6, 'JUNIO', 'Paz en la Familia', '\"...Y a Jehová serviréis a él y a su casa.\" Josué 24:15')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (JUNIO 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(30, 2, 'NORMAL', 'Efesios 5:22-33'), (30, 3, 'NORMAL', 'Efesios 6:1-4'), (30, 4, 'NORMAL', 'Colosenses 3:18-21'), (30, 5, 'NORMAL', 'Proverbios 31:10-31'),
(30, 6, 'NORMAL', '1 Pedro 3:1-7'), (30, 7, 'NORMAL', 'Malaquías 4:5-6'), (30, 9, 'NORMAL', 'Salmos 127:1-5'), (30, 10, 'NORMAL', 'Deuteronomio 6:4-9'),
(30, 11, 'NORMAL', 'Proverbios 22:6'), (30, 12, 'NORMAL', '1 Corintios 7:1-5'), (30, 13, 'NORMAL', 'Hechos 16:31-34'), (30, 14, 'NORMAL', 'Génesis 2:24'),
(30, 16, 'NORMAL', 'Romanos 12:17-21'), (30, 17, 'NORMAL', 'Efesios 4:26-27'), (30, 18, 'NORMAL', 'Proverbios 15:1'), (30, 19, 'NORMAL', 'Colosenses 3:13'),
(30, 20, 'NORMAL', 'Hebreos 12:14'), (30, 21, 'NORMAL', 'Mateo 5:9'), (30, 23, 'NORMAL', 'Proverbios 18:22'), (30, 24, 'NORMAL', 'Marcos 10:9'),
(30, 25, 'NORMAL', 'Tito 2:3-5'), (30, 26, 'NORMAL', '1 Timoteo 3:4-5'), (30, 27, 'NORMAL', 'Salmos 128:1-6'), (30, 28, 'NORMAL', 'Hechos 10:1-2'),
(30, 30, 'NORMAL', 'Proverbios 17:1')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (JUNIO 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(30, 1, 'DOMINGO', NULL, 'Reflexión: El Fundamento del Matrimonio en Cristo.'),
(30, 8, 'DOMINGO', NULL, 'Reflexión: Criando Hijos en el temor del Señor.'),
(30, 15, 'DOMINGO', NULL, 'Reflexión: La Resolución de Conflictos y el Perdón.'),
(30, 22, 'DOMINGO', NULL, 'Reflexión: La Paz de Dios en el Hogar.'),
(30, 29, 'DOMINGO', NULL, 'Reflexión: Estableciendo un Altar Familiar de Adoración.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA JULIO 2025 (Asumimos mes_id = 31)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(31, 3, 7, 'JULIO', 'El Poder del Espíritu Santo', '\"Y seréis bautizados con el Espíritu Santo dentro de no muchos días.\" Hechos 1:5')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (JULIO 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(31, 1, 'NORMAL', 'Hechos 2:1-4'), (31, 2, 'NORMAL', 'Hechos 19:1-7'), (31, 3, 'NORMAL', '1 Corintios 12:7-11'), (31, 4, 'NORMAL', 'Hechos 10:44-48'),
(31, 5, 'NORMAL', 'Juan 14:16-17'), (31, 7, 'NORMAL', 'Hechos 4:29-31'), (31, 8, 'NORMAL', 'Efesios 5:18-21'), (31, 9, 'NORMAL', 'Romanos 8:9-11'),
(31, 10, 'NORMAL', 'Gálatas 5:22-25'), (31, 11, 'NORMAL', '1 Corintios 14:14-15'), (31, 12, 'NORMAL', 'Romanos 8:26-27'), (31, 14, 'NORMAL', 'Lucas 11:13'),
(31, 15, 'NORMAL', 'Juan 16:7-11'), (31, 16, 'NORMAL', 'Joel 2:28-29'), (31, 17, 'NORMAL', 'Ezequiel 36:26-27'), (31, 18, 'NORMAL', 'Hechos 8:14-17'),
(31, 19, 'NORMAL', '1 Corintios 2:4-5'), (31, 21, 'NORMAL', 'Hechos 5:32'), (31, 22, 'NORMAL', '2 Timoteo 1:7'), (31, 23, 'NORMAL', 'Isaías 61:1-3'),
(31, 24, 'NORMAL', 'Miqueas 3:8'), (31, 25, 'NORMAL', 'Hechos 13:52'), (31, 26, 'NORMAL', 'Zacarías 4:6'), (31, 28, 'NORMAL', 'Efesios 1:13-14'),
(31, 29, 'NORMAL', 'Juan 7:38-39'), (31, 30, 'NORMAL', 'Mateo 3:11'), (31, 31, 'NORMAL', 'Hechos 11:15-18')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (JULIO 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(31, 6, 'DOMINGO', NULL, 'Reflexión: El Bautismo en el Espíritu Santo y sus Evidencias.'),
(31, 13, 'DOMINGO', NULL, 'Reflexión: El Espíritu como Consolador, Guía e Intercesor.'),
(31, 20, 'DOMINGO', NULL, 'Reflexión: El Fruto del Espíritu vs. las Obras de la Carne.'),
(31, 27, 'DOMINGO', NULL, 'Reflexión: Viviendo la Plenitud del Espíritu Diariamente.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA AGOSTO 2025 (Asumimos mes_id = 32)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(32, 3, 8, 'AGOSTO', 'Identidad y Autoridad', '\"Todo lo puedo en Cristo que me fortalece.\" Filipenses 4:13')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (AGOSTO 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(32, 1, 'NORMAL', 'Romanos 8:14-17'), (32, 2, 'NORMAL', 'Gálatas 3:26-29'), (32, 4, 'NORMAL', '2 Corintios 5:17-21'), (32, 5, 'NORMAL', 'Efesios 2:4-10'),
(32, 6, 'NORMAL', 'Juan 1:12-13'), (32, 7, 'NORMAL', 'Colosenses 1:13-14'), (32, 8, 'NORMAL', '1 Pedro 2:9-10'), (32, 9, 'NORMAL', 'Efesios 1:19-23'),
(32, 11, 'NORMAL', 'Mateo 10:1'), (32, 12, 'NORMAL', 'Lucas 10:19-20'), (32, 13, 'NORMAL', 'Marcos 16:17-18'), (32, 14, 'NORMAL', 'Efesios 6:10-17'),
(32, 15, 'NORMAL', '2 Corintios 10:4-5'), (32, 16, 'NORMAL', 'Santiago 4:7-8'), (32, 18, 'NORMAL', 'Hechos 5:12-16'), (32, 19, 'NORMAL', 'Isaías 54:17'),
(32, 20, 'NORMAL', 'Jeremías 1:10'), (32, 21, 'NORMAL', 'Romanos 8:37-39'), (32, 22, 'NORMAL', 'Mateo 18:18-20'), (32, 23, 'NORMAL', 'Apocalipsis 12:11'),
(32, 25, 'NORMAL', 'Juan 8:31-36'), (32, 26, 'NORMAL', 'Gálatas 5:1'), (32, 27, 'NORMAL', 'Colosenses 2:6-7'), (32, 28, 'NORMAL', 'Hebreos 13:8'),
(32, 29, 'NORMAL', 'Juan 14:12'), (32, 30, 'NORMAL', 'Hechos 4:13'), (32, 31, 'NORMAL', '2 Timoteo 1:7')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (AGOSTO 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(32, 3, 'DOMINGO', NULL, 'Reflexión: Hijos de Dios: Nuestra Nueva Identidad.'),
(32, 10, 'DOMINGO', NULL, 'Reflexión: La Autoridad Delegada y el Poder para Sanar y Liberar.'),
(32, 17, 'DOMINGO', NULL, 'Reflexión: La Guerra Espiritual: Armadura y Estrategia.'),
(32, 24, 'DOMINGO', NULL, 'Reflexión: La Sangre y el Testimonio: Claves de la Victoria.'),
(32, 31, 'DOMINGO', NULL, 'Reflexión: Viviendo como más que Vencedores en Cristo.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA SEPTIEMBRE 2025 (Asumimos mes_id = 33)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(33, 3, 9, 'SEPTIEMBRE', 'La Adoración y Alabanza', '\"Buscad a Jehová y su poder; buscad siempre su rostro.\" 1 Crónicas 16:11')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (SEPTIEMBRE 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(33, 1, 'NORMAL', 'Salmos 95:1-7'), (33, 2, 'NORMAL', 'Salmos 100:1-5'), (33, 3, 'NORMAL', 'Salmos 150:1-6'), (33, 4, 'NORMAL', 'Juan 4:23-24'),
(33, 5, 'NORMAL', 'Hechos 16:25-34'), (33, 6, 'NORMAL', 'Salmos 34:1-8'), (33, 8, 'NORMAL', 'Hebreos 13:15'), (33, 9, 'NORMAL', 'Salmos 42:1-5'),
(33, 10, 'NORMAL', 'Salmos 51:10-12'), (33, 11, 'NORMAL', 'Salmos 63:1-8'), (33, 12, 'NORMAL', 'Salmos 92:1-5'), (33, 13, 'NORMAL', 'Salmos 104:33-35'),
(33, 15, 'NORMAL', 'Filipenses 4:4-7'), (33, 16, 'NORMAL', 'Colosenses 3:16-17'), (33, 17, 'NORMAL', 'Efesios 5:18-20'), (33, 18, 'NORMAL', 'Apocalipsis 4:8-11'),
(33, 19, 'NORMAL', 'Salmos 22:3'), (33, 20, 'NORMAL', 'Isaías 6:1-8'), (33, 22, 'NORMAL', 'Salmos 29:1-11'), (33, 23, 'NORMAL', '2 Crónicas 20:18-22'),
(33, 24, 'NORMAL', 'Salmos 47:1-9'), (33, 25, 'NORMAL', 'Salmos 73:25-26'), (33, 26, 'NORMAL', 'Salmos 145:1-7'), (33, 29, 'NORMAL', 'Romanos 12:1'),
(33, 30, 'NORMAL', '1 Pedro 2:5')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (SEPTIEMBRE 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(33, 7, 'DOMINGO', NULL, 'Reflexión: Adoración en Espíritu y en Verdad.'),
(33, 14, 'DOMINGO', NULL, 'Reflexión: La Alabanza como Arma de Guerra.'),
(33, 21, 'DOMINGO', NULL, 'Reflexión: La Presencia de Dios y la Atmósfera de Adoración.'),
(33, 28, 'DOMINGO', NULL, 'Reflexión: Nuestro Cuerpo como Templo de Adoración.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA OCTUBRE 2025 (Asumimos mes_id = 34)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(34, 3, 10, 'OCTUBRE', 'Relaciones y Unidad', '\"Mirad cuán bueno y cuán delicioso es habitar los hermanos juntos en armonía!\" Salmos 133:1')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (OCTUBRE 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(34, 1, 'NORMAL', 'Romanos 15:5-7'), (34, 2, 'NORMAL', 'Efesios 4:31-32'), (34, 3, 'NORMAL', 'Colosenses 3:12-14'), (34, 4, 'NORMAL', '1 Pedro 3:8-9'),
(34, 6, 'NORMAL', 'Romanos 12:10'), (34, 7, 'NORMAL', 'Hebreos 10:24-25'), (34, 8, 'NORMAL', 'Filipenses 2:1-4'), (34, 9, 'NORMAL', '1 Corintios 12:12-27'),
(34, 10, 'NORMAL', 'Efesios 4:11-16'), (34, 11, 'NORMAL', 'Juan 13:34-35'), (34, 13, 'NORMAL', 'Gálatas 6:1-2'), (34, 14, 'NORMAL', '1 Tesalonicenses 5:11'),
(34, 15, 'NORMAL', 'Proverbios 27:6'), (34, 16, 'NORMAL', 'Santiago 5:16'), (34, 17, 'NORMAL', 'Mateo 18:15-17'), (34, 18, 'NORMAL', 'Romanos 14:19'),
(34, 20, 'NORMAL', '1 Corintios 1:10'), (34, 21, 'NORMAL', '2 Corintios 13:11'), (34, 22, 'NORMAL', '1 Juan 1:7'), (34, 23, 'NORMAL', 'Hebreos 3:12-13'),
(34, 24, 'NORMAL', 'Colosenses 3:15'), (34, 25, 'NORMAL', 'Romanos 15:13'), (34, 27, 'NORMAL', '1 Corintios 13:4-7'), (34, 28, 'NORMAL', 'Salmos 34:12-14'),
(34, 29, 'NORMAL', 'Proverbios 17:17'), (34, 30, 'NORMAL', 'Mateo 7:12'), (34, 31, 'NORMAL', 'Lucas 6:31')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (OCTUBRE 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(34, 5, 'DOMINGO', NULL, 'Reflexión: Perdón y Reconciliación en la Comunidad.'),
(34, 12, 'DOMINGO', NULL, 'Reflexión: La Unidad del Cuerpo de Cristo.'),
(34, 19, 'DOMINGO', NULL, 'Reflexión: Manejo Bíblico del Conflicto.'),
(34, 26, 'DOMINGO', NULL, 'Reflexión: La Caridad (Amor) como Vínculo Perfecto de la Unidad.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA NOVIEMBRE 2025 (Asumimos mes_id = 35)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(35, 3, 11, 'NOVIEMBRE', 'Vida con Propósito', '\"Porque somos hechura suya, creados en Cristo Jesús para buenas obras...\" Efesios 2:10')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (NOVIEMBRE 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(35, 1, 'NORMAL', 'Efesios 2:10'), (35, 3, 'NORMAL', 'Romanos 12:4-8'), (35, 4, 'NORMAL', '1 Corintios 12:1-11'), (35, 5, 'NORMAL', '2 Timoteo 1:9'),
(35, 6, 'NORMAL', 'Jeremías 1:5'), (35, 7, 'NORMAL', 'Isaías 43:7'), (35, 8, 'NORMAL', 'Juan 15:16'), (35, 10, 'NORMAL', 'Mateo 25:14-30'),
(35, 11, 'NORMAL', '1 Pedro 4:10-11'), (35, 12, 'NORMAL', 'Proverbios 19:21'), (35, 13, 'NORMAL', 'Salmos 57:2'), (35, 14, 'NORMAL', 'Efesios 4:11-13'),
(35, 15, 'NORMAL', 'Hebreos 10:24-25'), (35, 17, 'NORMAL', 'Romanos 8:28'), (35, 18, 'NORMAL', 'Proverbios 3:5-6'), (35, 19, 'NORMAL', 'Lucas 7:36-50'),
(35, 20, 'NORMAL', 'Lucas 10:38-42'), (35, 21, 'NORMAL', 'Lucas 19:1-10'), (35, 22, 'NORMAL', 'Juan 1:43-51'), (35, 24, 'NORMAL', 'Juan 3:1-21'),
(35, 25, 'NORMAL', 'Juan 4:1-42'), (35, 26, 'NORMAL', 'Juan 7:1-9'), (35, 27, 'NORMAL', 'Juan 8:1-11'), (35, 28, 'NORMAL', 'Juan 12:1-8'),
(35, 29, 'NORMAL', 'Juan 12:20-26')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (NOVIEMBRE 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(35, 2, 'DOMINGO', NULL, 'Reflexión: La Hechura de Dios y las Buenas Obras.'),
(35, 9, 'DOMINGO', NULL, 'Reflexión: Descubriendo tu Llamado Personal y Ministerial.'),
(35, 16, 'DOMINGO', NULL, 'Reflexión: La Conexión entre Propósito, Fe y Obediencia.'),
(35, 23, 'DOMINGO', NULL, 'Juan 2:23-25 Reflexión: Terminando la Carrera con Gozo y Perspectiva Eterna.'),
(35, 30, 'DOMINGO', NULL, 'Juan 20:11-18 Reflexión: Revisión del Año: Dones, Frutos y Oportunidades.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;


-- =======================================================
-- DATOS PARA DICIEMBRE 2025 (Asumimos mes_id = 36)
-- =======================================================
INSERT INTO Mes_Maestro (id, diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(36, 3, 12, 'DICIEMBRE', 'La Cosecha y el Legado', '\"De cierto, de cierto os digo, que el que en mí cree, las obras que yo hago, él las hará también; y aun mayores hará...\" Juan 14:12')
ON CONFLICT (id) DO NOTHING;

-- Días NORMALES (DICIEMBRE 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica) VALUES
(36, 1, 'NORMAL', 'Juan 5:19-47'), (36, 2, 'NORMAL', 'Juan 6:25-59'), (36, 3, 'NORMAL', 'Juan 6:60-71'), (36, 4, 'NORMAL', 'Juan 8:12-20'),
(36, 5, 'NORMAL', 'Juan 8:31-47'), (36, 6, 'NORMAL', 'Juan 8:48-59'), (36, 8, 'NORMAL', 'Juan 14'), (36, 9, 'NORMAL', 'Juan 15'),
(36, 10, 'NORMAL', 'Juan 16'), (36, 11, 'NORMAL', 'Mateo 5'), (36, 12, 'NORMAL', 'Mateo 6'), (36, 13, 'NORMAL', 'Mateo 7'),
(36, 15, 'NORMAL', 'Mateo 15:1-20'), (36, 16, 'NORMAL', 'Mateo 20:1-16'), (36, 17, 'NORMAL', 'Mateo 20:20-28'), (36, 18, 'NORMAL', 'Mateo 25:1-13'),
(36, 19, 'NORMAL', 'Mateo 25:14-30'), (36, 20, 'NORMAL', 'Mateo 25:31-46'), (36, 22, 'NORMAL', 'Marcos 12:28-34'), (36, 23, 'NORMAL', 'Lucas 10:25-37'),
(36, 24, 'NORMAL', 'Lucas 12:35-48'), (36, 25, 'NORMAL', 'Lucas 15:8-32'), (36, 26, 'NORMAL', 'Lucas 16:1-15'), (36, 27, 'NORMAL', 'Lucas 17:5-10'),
(36, 29, 'NORMAL', 'Marcos 14'), (36, 30, 'NORMAL', 'Marcos 15'), (36, 31, 'NORMAL', 'Marcos 16')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica;

-- Días DOMINGO (DICIEMBRE 2025)
INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) VALUES
(36, 7, 'DOMINGO', NULL, 'Juan 10:1-18 Reflexión: La Ley de la Siembra y la Cosecha.'),
(36, 14, 'DOMINGO', NULL, 'Mateo 13:1-52 Reflexión: El Discipulado como Única Multiplicación.'),
(36, 21, 'DOMINGO', NULL, 'Marcos 11:1-11 Reflexión: Celebrando el Legado y la Influencia.'),
(36, 28, 'DOMINGO', NULL, 'Lucas 20:1-8 Reflexión: Planificando 2026: Una Visión de Avivamiento.')
ON CONFLICT (mes_id, dia_numero) DO UPDATE SET versiculo_diario = EXCLUDED.versiculo_diario;

-- Otorgar permisos al usuario diario_user
GRANT SELECT, INSERT, UPDATE, DELETE ON diario_anual TO diario_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON mes_maestro TO diario_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON dia_maestro TO diario_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON campos_diario TO diario_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON entrada_diaria TO diario_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON valores_campo TO diario_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON usuario TO diario_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON meta_anual TO diario_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON meta_mensual TO diario_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON pago TO diario_user;