-- =======================================================
-- ESQUEMA DE BASE DE DATOS PARA "DIARIO DE INTIMIDAD"
-- Tecnología: PostgreSQL
-- Archivo de Inicialización (DDL Condicional + DML desde CSV via Stored Procedure)
-- =======================================================

-- -------------------------------------------------------
-- 1. DEFINICIÓN DE TABLAS (DDL Condicional)
-- -------------------------------------------------------

CREATE TABLE IF NOT EXISTS Usuario (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    rol VARCHAR(50) NOT NULL DEFAULT 'USER',
    fecha_registro TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Diario_Anual (
    id BIGSERIAL PRIMARY KEY,
    anio INTEGER UNIQUE NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    nombre_portada VARCHAR(255),
    nombre_logo VARCHAR(255),
    tema_principal TEXT,
    status VARCHAR(50) NOT NULL,
    precio NUMERIC(10, 2),
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Mes_Maestro (
    id BIGSERIAL PRIMARY KEY,
    diario_id BIGINT NOT NULL REFERENCES Diario_Anual(id) ON DELETE CASCADE,
    mes_numero INTEGER NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    tema_mes VARCHAR(255),
    versiculo_mes TEXT,
    UNIQUE (diario_id, mes_numero)
);

CREATE TABLE IF NOT EXISTS Dia_Maestro (
    id BIGSERIAL PRIMARY KEY,
    mes_id BIGINT NOT NULL REFERENCES Mes_Maestro(id),
    dia_numero INTEGER NOT NULL,
    tipo_dia VARCHAR(20) NOT NULL DEFAULT 'NORMAL',
    lectura_biblica VARCHAR(100),
    versiculo_diario TEXT,
    UNIQUE (mes_id, dia_numero)
);

CREATE TABLE IF NOT EXISTS Campos_Diario (
    id BIGSERIAL PRIMARY KEY,
    diario_id BIGINT NOT NULL REFERENCES Diario_Anual(id) ON DELETE CASCADE,
    orden INTEGER NOT NULL,
    nombre_campo VARCHAR(100) NOT NULL,
    tipo_entrada VARCHAR(50) NOT NULL,
    tipo_input VARCHAR(50) NOT NULL,
    es_requerido BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE (diario_id, nombre_campo)
);

CREATE TABLE IF NOT EXISTS Entrada_Diaria (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL REFERENCES Usuario(id),
    diario_id BIGINT NOT NULL REFERENCES Diario_Anual(id) ON DELETE CASCADE,
    dia_maestro_id BIGINT NOT NULL REFERENCES Dia_Maestro(id),
    fecha_entrada DATE NOT NULL,
    estado_llenado NUMERIC(5, 2) DEFAULT 0.00,
    completado BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_creacion TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    fecha_ultima_edicion TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (usuario_id, dia_maestro_id)
);

CREATE TABLE IF NOT EXISTS Valores_Campo (
    id BIGSERIAL PRIMARY KEY,
    entrada_diaria_id BIGINT NOT NULL REFERENCES Entrada_Diaria(id),
    campo_diario_id BIGINT NOT NULL REFERENCES Campos_Diario(id),
    valor_texto TEXT,
    valor_audio_url VARCHAR(255),
    UNIQUE (entrada_diaria_id, campo_diario_id)
);

CREATE TABLE IF NOT EXISTS Meta_Anual (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL REFERENCES Usuario(id),
    diario_id BIGINT NOT NULL REFERENCES Diario_Anual(id) ON DELETE CASCADE,
    tipo_meta VARCHAR(50) NOT NULL,
    descripcion TEXT NOT NULL,
    estado VARCHAR(50) NOT NULL DEFAULT 'Activo',
    fecha_creacion TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Meta_Mensual (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL REFERENCES Usuario(id),
    diario_id BIGINT NOT NULL REFERENCES Diario_Anual(id) ON DELETE CASCADE,
    mes_numero INTEGER NOT NULL,
    descripcion TEXT NOT NULL,
    cumplida BOOLEAN NOT NULL DEFAULT FALSE,
    pasa_siguiente_mes BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_creacion TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Pago (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL REFERENCES Usuario(id),
    monto NUMERIC(10, 2) NOT NULL,
    fecha_pago TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(50) NOT NULL,
    metodo_pago VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS Pedido (
    id BIGSERIAL PRIMARY KEY,
    diario_id BIGINT NOT NULL REFERENCES Diario_Anual(id),
    email VARCHAR(255) NOT NULL,
    estado VARCHAR(50) NOT NULL,
    token_validacion VARCHAR(255),
    usuario_id BIGINT REFERENCES Usuario(id),
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------
-- 2. CARGA DE DATOS BASE Y USUARIOS
-- -------------------------------------------------------

INSERT INTO usuario (email, password, rol, fecha_registro) VALUES 
('Sithgto@gmail.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'ADMIN', CURRENT_TIMESTAMP)
ON CONFLICT (email) DO NOTHING;

INSERT INTO usuario (email, password, rol, fecha_registro) VALUES 
('user@diario.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'USER', CURRENT_TIMESTAMP)
ON CONFLICT (email) DO NOTHING;


-- -------------------------------------------------------
-- 3. FUNCIONES DE CARGA MODULAR POR AÑO (CSV)
-- -------------------------------------------------------

-- FUNCIÓN FINAL CORREGIDA (Usa COPY y QUOTE/ESCAPE)
CREATE OR REPLACE PROCEDURE load_diario_anual(
    p_anio INTEGER,
    p_titulo VARCHAR,
    p_tema_principal TEXT,
    p_precio NUMERIC,
    p_csv_dir TEXT,
    p_campos_diario_data JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_diario_id BIGINT; -- Variable local
    campos_data JSONB;
    campo JSONB;
    sql_mes_copy TEXT;
    sql_dia_copy TEXT;
    -- Ruta base donde Docker monta el directorio ./DB
    v_base_path TEXT := '/docker-entrypoint-initdb.d'; 
BEGIN
    -- 1. Insertar/Actualizar Diario_Anual y obtener su ID
    INSERT INTO Diario_Anual (anio, titulo, tema_principal, status, precio) VALUES
    (p_anio, p_titulo, p_tema_principal, 'Activo', p_precio)
    ON CONFLICT (anio) DO UPDATE SET titulo = EXCLUDED.titulo, tema_principal = EXCLUDED.tema_principal, status = EXCLUDED.status, precio = EXCLUDED.precio
    RETURNING id INTO v_diario_id;

    -- 2. Insertar Campos_Diario
    FOR campo IN SELECT * FROM jsonb_array_elements(p_campos_diario_data)
    LOOP
        INSERT INTO Campos_Diario (diario_id, orden, nombre_campo, tipo_entrada, tipo_input, es_requerido) VALUES
        (v_diario_id, (campo->>'orden')::INTEGER, campo->>'nombre_campo', campo->>'tipo_entrada', campo->>'tipo_input', (campo->>'es_requerido')::BOOLEAN)
        ON CONFLICT (diario_id, nombre_campo) DO NOTHING;
    END LOOP;

    -- 3. Cargar Mes_Maestro desde CSV (USANDO COPY ESTÁNDAR + QUOTE/ESCAPE)
    CREATE TEMPORARY TABLE temp_mes_maestro (
        mes_numero INTEGER NOT NULL,
        nombre VARCHAR(50),
        tema_mes VARCHAR(255),
        versiculo_mes TEXT
    );
    
    -- CORRECCIÓN FINAL: Usamos QUOTE ''"'' y ESCAPE ''"'' para manejar comas y comillas dentro de los campos
    sql_mes_copy := format('COPY temp_mes_maestro (mes_numero, nombre, tema_mes, versiculo_mes) FROM ''%s/%s/mes_maestro.csv'' WITH (FORMAT csv, HEADER TRUE, DELIMITER '','', QUOTE ''"'' , ESCAPE ''"'' )', v_base_path, p_csv_dir);
    EXECUTE sql_mes_copy;
    
    -- Mover los datos a la tabla Mes_Maestro
    INSERT INTO Mes_Maestro (diario_id, mes_numero, nombre, tema_mes, versiculo_mes)
    SELECT v_diario_id, t.mes_numero, t.nombre, t.tema_mes, t.versiculo_mes
    FROM temp_mes_maestro t
    ON CONFLICT (diario_id, mes_numero) DO UPDATE SET tema_mes = EXCLUDED.tema_mes, versiculo_mes = EXCLUDED.versiculo_mes;
    DROP TABLE temp_mes_maestro;


    -- 4. Cargar Dia_Maestro desde CSV (USANDO COPY ESTÁNDAR + QUOTE/ESCAPE)
    CREATE TEMPORARY TABLE temp_dia_maestro (
        mes_numero INTEGER NOT NULL, -- Clave de búsqueda
        dia_numero INTEGER NOT NULL,
        tipo_dia VARCHAR(20),
        lectura_biblica VARCHAR(100),
        versiculo_diario TEXT
    );
    
    -- CORRECCIÓN FINAL: Usamos QUOTE ''"'' y ESCAPE ''"'' para manejar comas y comillas dentro de los campos
    sql_dia_copy := format('COPY temp_dia_maestro (mes_numero, dia_numero, tipo_dia, lectura_biblica, versiculo_diario) FROM ''%s/%s/dia_maestro.csv'' WITH (FORMAT csv, HEADER TRUE, DELIMITER '','', QUOTE ''"'' , ESCAPE ''"'' )', v_base_path, p_csv_dir);
    EXECUTE sql_dia_copy;

    -- Mover los datos a la tabla Dia_Maestro
    INSERT INTO Dia_Maestro (mes_id, dia_numero, tipo_dia, lectura_biblica, versiculo_diario)
    SELECT
        mm.id AS mes_id,
        tdm.dia_numero,
        COALESCE(tdm.tipo_dia, 'NORMAL'),
        tdm.lectura_biblica,
        tdm.versiculo_diario
    FROM temp_dia_maestro tdm
    JOIN Mes_Maestro mm ON mm.diario_id = v_diario_id AND mm.mes_numero = tdm.mes_numero
    ON CONFLICT (mes_id, dia_numero) DO UPDATE SET lectura_biblica = EXCLUDED.lectura_biblica, versiculo_diario = EXCLUDED.versiculo_diario;

    DROP TABLE temp_dia_maestro;

END;
$$;


-- -------------------------------------------------------
-- 4. EJECUCIÓN DE LA CARGA PARA CADA AÑO
-- -------------------------------------------------------

-- Carga 2026
CALL load_diario_anual(
    2026,
    'Avivamiento',
    '\"¡Oh Señor Jehová! He aquí que tú hiciste el cielo y la tierra con tu gran poder, y con tu brazo extendido, ni hay nada que sea dificil para ti\". Jeremías 32:17',
    12.00,
    'data_2026',
    '[
        {"orden": 1, "nombre_campo": "Escoge un versiculo para meditar en el día y escribelo:", "tipo_entrada": "VERSICULO", "tipo_input": "TEXTO", "es_requerido": true},
        {"orden": 2, "nombre_campo": "¿Cómo puedes aplicarlo en tu vida y así desarrollar nuestro avivamiento?", "tipo_entrada": "APLICACION", "tipo_input": "TEXTAREA", "es_requerido": true},
        {"orden": 3, "nombre_campo": "Oración: Utilice este espacio para agradecer.", "tipo_entrada": "ORACION", "tipo_input": "AUDIO", "es_requerido": true},
        {"orden": 4, "nombre_campo": "Prioridades para este Día", "tipo_entrada": "PRIORIDADES", "tipo_input": "TEXTAREA", "es_requerido": true}
    ]'::JSONB
);

-- Carga 2025
CALL load_diario_anual(
    2025,
    'Héroes de la Fe',
    '\"Prepárate para obtener tu gálardon.\" 2 Corintios 12:18b NTV, 1 Pedro 2:21 RVR 1960',
    10.00,
    'data_2025',
    '[
        {"orden": 1, "nombre_campo": "¿Qué versiculó de este pasaje te impactó más? Ecríbelo.", "tipo_entrada": "VERSICULO", "tipo_input": "TEXTO", "es_requerido": true},
        {"orden": 2, "nombre_campo": "¿Qué cosas tomas de este personaje para imitarlo y de esta manera seguir sus pisadas?", "tipo_entrada": "APLICACION", "tipo_input": "TEXTAREA", "es_requerido": true},
        {"orden": 3, "nombre_campo": "Oración: Utilice este espacio para agradecer.", "tipo_entrada": "ORACION", "tipo_input": "AUDIO", "es_requerido": true},
        {"orden": 4, "nombre_campo": "Prioridades para este Día", "tipo_entrada": "PRIORIDADES", "tipo_input": "TEXTAREA", "es_requerido": true}
    ]'::JSONB
);

-- Carga 2027
CALL load_diario_anual(
    2027,
    'Crecimiento y Multiplicación',
    '\"He aquí, yo hago cosa nueva; pronto saldrá a luz; ¿no la conoceréis? Otra vez abriré camino en el desierto, y ríos en la soledad.\" Isaías 43:19',
    30.00,
    'data_2027',
    '[
        {"orden": 1, "nombre_campo": "2027 Escoge un versículo para meditar en el día y escribelo:", "tipo_entrada": "VERSICULO", "tipo_input": "TEXTO", "es_requerido": true},
        {"orden": 2, "nombre_campo": "2027 ¿Comó puedes aplicarlo en tu vida y asi desarrollar nuestro avivamiento?", "tipo_entrada": "APLICACION", "tipo_input": "TEXTAREA", "es_requerido": true},
        {"orden": 3, "nombre_campo": "Oración: Utilice este espacio para agradecer.", "tipo_entrada": "ORACION", "tipo_input": "AUDIO", "es_requerido": true},
        {"orden": 4, "nombre_campo": "Prioridades para este Día", "tipo_entrada": "PRIORIDADES", "tipo_input": "TEXTAREA", "es_requerido": true}
    ]'::JSONB
);


-- -------------------------------------------------------
-- 5. PERMISOS
-- -------------------------------------------------------
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO diario_user;
GRANT EXECUTE ON PROCEDURE load_diario_anual(INTEGER, VARCHAR, TEXT, NUMERIC, TEXT, JSONB) TO diario_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO diario_user;