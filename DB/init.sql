-- =======================================================
-- ESQUEMA DE BASE DE DATOS PARA "DIARIO DE INTIMIDAD"
-- Tecnología: PostgreSQL
-- =======================================================

-- 1. Tablas de Usuario y Autenticación
CREATE TABLE Usuario (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL, -- Almacenar el hash de la contraseña (ej. BCrypt)
    rol VARCHAR(50) NOT NULL DEFAULT 'USER', -- 'USER', 'ADMIN'
    fecha_registro TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tablas de Contenido Maestro (Diario Anual)

-- Almacena información de cada edición del diario (ej. 2026, 2027)
CREATE TABLE Diario_Anual (
    id SERIAL PRIMARY KEY,
    anio INTEGER UNIQUE NOT NULL,
    titulo VARCHAR(255) NOT NULL, -- Título principal (ej. "Avivamiento")
    portada_url VARCHAR(255),
    tema_principal TEXT -- Versículo principal del año (ej. Jeremías 32:17)
);

-- Almacena los temas y versículos por mes para un año específico
CREATE TABLE Mes_Maestro (
    id SERIAL PRIMARY KEY,
    diario_id INTEGER NOT NULL REFERENCES Diario_Anual(id),
    mes_numero INTEGER NOT NULL, -- 1 a 12
    nombre VARCHAR(50) NOT NULL, -- Nombre del mes (ej. "ENERO")
    tema_mes VARCHAR(255),
    versiculo_mes TEXT, -- Versículo temático del mes (ej. Hechos 2:3)
    UNIQUE (diario_id, mes_numero)
);

-- Almacena el contenido fijo para cada día del diario
CREATE TABLE Dia_Maestro (
    id SERIAL PRIMARY KEY,
    mes_id INTEGER NOT NULL REFERENCES Mes_Maestro(id),
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
    id SERIAL PRIMARY KEY,
    diario_id INTEGER NOT NULL REFERENCES Diario_Anual(id), -- A qué diario anual aplica
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
    usuario_id INTEGER NOT NULL REFERENCES Usuario(id),
    diario_id INTEGER NOT NULL REFERENCES Diario_Anual(id),
    dia_maestro_id INTEGER NOT NULL REFERENCES Dia_Maestro(id),
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
    campo_diario_id INTEGER NOT NULL REFERENCES Campos_Diario(id),
    valor_texto TEXT, -- Para entradas de texto y transcripciones de audio
    valor_audio_url VARCHAR(255), -- URL al archivo de audio almacenado (si aplica)
    UNIQUE (entrada_diaria_id, campo_diario_id)
);

-- 5. Tablas de Metas y Pagos (Sin cambios significativos de la propuesta anterior)

-- Metas Anuales del usuario
CREATE TABLE Meta_Anual (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES Usuario(id),
    diario_id INTEGER NOT NULL REFERENCES Diario_Anual(id),
    tipo_meta VARCHAR(50) NOT NULL, -- 'Personal', 'Familiar', 'Económica', 'Ministerial'
    descripcion TEXT NOT NULL,
    estado VARCHAR(50) NOT NULL DEFAULT 'PENDIENTE',
    fecha_creacion TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Metas Mensuales del usuario
CREATE TABLE Meta_Mensual (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES Usuario(id),
    diario_id INTEGER NOT NULL REFERENCES Diario_Anual(id),
    mes_numero INTEGER NOT NULL, -- Mes al que pertenece la meta
    descripcion TEXT NOT NULL,
    cumplida BOOLEAN NOT NULL DEFAULT FALSE,
    pasa_siguiente_mes BOOLEAN NOT NULL DEFAULT FALSE, -- Se arrastra al siguiente mes si no se cumple
    fecha_creacion TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Registro de transacciones
CREATE TABLE Pago (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES Usuario(id),
    monto NUMERIC(10, 2) NOT NULL,
    fecha_pago TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(50) NOT NULL, -- 'COMPLETADO', 'FALLIDO', 'PENDIENTE'
    metodo_pago VARCHAR(50)
);

-- Insertar datos de prueba
-- Password: 'password' encriptado con BCrypt
INSERT INTO usuario (email, password, rol, fecha_registro) VALUES ('Sithgto@gmail.com', 'S@1thgto.2@25', 'ADMIN', CURRENT_TIMESTAMP);
INSERT INTO usuario (email, password, rol, fecha_registro) VALUES ('user@diario.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'USER', CURRENT_TIMESTAMP);

-- Usuario por defecto ADMIN
-- Email: Sithgto@gmail.com
-- Password: S@1thgto.2@25


-- =======================================================
-- CARGA DE DATOS INICIALES - DIARIO 2026: AÑO COMPLETO
-- =======================================================

-- Limpiar datos existentes para recargar desde cero
TRUNCATE TABLE Pago CASCADE;
TRUNCATE TABLE Meta_Mensual CASCADE;
TRUNCATE TABLE Meta_Anual CASCADE;
TRUNCATE TABLE Valores_Campo CASCADE;
TRUNCATE TABLE Entrada_Diaria CASCADE;
TRUNCATE TABLE Dia_Maestro CASCADE;
TRUNCATE TABLE Mes_Maestro CASCADE;
TRUNCATE TABLE Campos_Diario CASCADE;
TRUNCATE TABLE Diario_Anual CASCADE;

-- Datos de ejemplo para probar consultas
-- INSERT INTO Usuario (id, email, password_hash, rol) VALUES (101, 'usuario@ejemplo.com', 'hash_ejemplo', 'USER') ON CONFLICT (id) DO NOTHING;

-- 1. Asegurar la inserción del Diario Anual (Se asume ID=1)
INSERT INTO Diario_Anual (id, anio, titulo, tema_principal) VALUES
(1, 2026, 'Avivamiento', '\"¡Oh Señor Jehová! He aquí que tú hiciste el cielo y la tierra con tu gran poder, y con tu brazo extendido, ni hay nada que sea dificil para ti\". Jeremías 32:17')
ON CONFLICT (id) DO NOTHING;

-- Datos iniciales para el Diario 2026 basados en el ejemplo proporcionado
--INSERT INTO Campos_Diario (diario_id, orden, nombre_campo, tipo_entrada, tipo_input, es_requerido) VALUES
--(1, 1, 'Versículo Escogido', 'VERSICULO', 'TEXTO', TRUE),
--(1, 2, 'Meditación del Versículo', 'APLICACION', 'TEXTAREA', TRUE),
--(1, 3, 'Aplicación Práctica (Avivamiento)', 'APLICACION', 'TEXTAREA', TRUE),
--(1, 4, 'Oración/Agradecimiento', 'ORACION', 'AUDIO', TRUE), -- Se sugiere AUDIO/TEXTAREA
--(1, 5, 'Prioridades del Día', 'PRIORIDADES', 'TEXTAREA', FALSE); -- No requerido, puede ser opcional

-- =======================================================
-- DATOS PARA ENERO (mes_id = 1)
-- =======================================================
INSERT INTO Mes_Maestro (diario_id, mes_numero, nombre, tema_mes, versiculo_mes) VALUES
(1, 1, 'ENERO', 'Avivamiento en Pentecostés', 'Y se les aparecieron lenguas repartidas, como de fuego, asentándose sobre cada uno de ellos. Hechos 2:3')
ON CONFLICT (diario_id, mes_numero) DO UPDATE SET tema_mes = EXCLUDED.tema_mes;

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
