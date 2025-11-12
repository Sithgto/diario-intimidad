-- Script de inicialización de la base de datos para Diario de Intimidad
-- Base de datos: PostgreSQL

-- Crear base de datos si no existe (ejecutar fuera de la base de datos)
-- CREATE DATABASE diario_intimidad;

-- Conectar a la base de datos
-- \c diario_intimidad;

-- Tabla Diario_Anual
CREATE TABLE Diario_Anual (
    id SERIAL PRIMARY KEY,
    anio INT NOT NULL,
    titulo VARCHAR(255),
    portada_url VARCHAR(500),
    tema_principal VARCHAR(255)
);

-- Tabla Mes_Maestro
CREATE TABLE Mes_Maestro (
    id SERIAL PRIMARY KEY,
    diario_id INT REFERENCES Diario_Anual(id),
    nombre VARCHAR(50),
    tema_mes VARCHAR(255),
    versiculo_mes VARCHAR(500)
);

-- Tabla Dia_Maestro
CREATE TABLE Dia_Maestro (
    id SERIAL PRIMARY KEY,
    mes_id INT REFERENCES Mes_Maestro(id),
    dia_numero INT,
    tipo_dia VARCHAR(10) CHECK (tipo_dia IN ('NORMAL', 'DOMINGO')),
    lectura_biblica TEXT,
    versiculo_diario VARCHAR(500),
    link_lectura VARCHAR(500)
);

-- Tabla Campos_Diario
CREATE TABLE Campos_Diario (
    id SERIAL PRIMARY KEY,
    nombre_campo VARCHAR(100),
    tipo_entrada VARCHAR(20) CHECK (tipo_entrada IN ('TEXTO', 'TEXTAREA', 'AUDIO')),
    es_requerido BOOLEAN DEFAULT FALSE,
    diario_id INT REFERENCES Diario_Anual(id)
);

-- Tabla Usuario
CREATE TABLE Usuario (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    rol VARCHAR(10) CHECK (rol IN ('USER', 'ADMIN')) DEFAULT 'USER',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla Entrada_Diaria
CREATE TABLE Entrada_Diaria (
    id SERIAL PRIMARY KEY,
    usuario_id INT REFERENCES Usuario(id),
    diario_id INT REFERENCES Diario_Anual(id),
    dia_maestro_id INT REFERENCES Dia_Maestro(id),
    fecha_entrada DATE NOT NULL,
    estado_llenado DOUBLE PRECISION DEFAULT 0.00,
    completado BOOLEAN DEFAULT FALSE
);

-- Tabla Valores_Campo
CREATE TABLE Valores_Campo (
    id SERIAL PRIMARY KEY,
    entrada_diaria_id INT REFERENCES Entrada_Diaria(id),
    campo_diario_id INT REFERENCES Campos_Diario(id),
    valor_texto TEXT,
    valor_audio_url VARCHAR(500)
);

-- Tabla Meta_Anual
CREATE TABLE Meta_Anual (
    id SERIAL PRIMARY KEY,
    usuario_id INT REFERENCES Usuario(id),
    diario_id INT REFERENCES Diario_Anual(id),
    descripcion TEXT,
    estado VARCHAR(50),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla Meta_Mensual
CREATE TABLE Meta_Mensual (
    id SERIAL PRIMARY KEY,
    usuario_id INT REFERENCES Usuario(id),
    diario_id INT REFERENCES Diario_Anual(id),
    mes_numero INT,
    descripcion TEXT,
    cumplida BOOLEAN DEFAULT FALSE,
    pasa_siguiente_mes BOOLEAN DEFAULT FALSE
);

-- Tabla Pago
CREATE TABLE Pago (
    id SERIAL PRIMARY KEY,
    usuario_id INT REFERENCES Usuario(id),
    monto DECIMAL(10,2),
    fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(50),
    metodo_pago VARCHAR(50)
);

-- Insertar datos de prueba
-- Password: 'password' encriptado con BCrypt
INSERT INTO usuario (email, password, rol, fecha_registro) VALUES ('sithgto@gmail.com', 'adminuser', 'ADMIN', CURRENT_TIMESTAMP);
INSERT INTO usuario (email, password, rol, fecha_registro) VALUES ('user@diario.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'USER', CURRENT_TIMESTAMP);

-- Usuario por defecto ADMIN
-- Email: sithgto@gmail.com
-- Password: adminuser