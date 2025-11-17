import React from 'react';
import Menu from '../components/Menu';

const ApiDocs: React.FC = () => {
  return (
    <div className="app-container">
      <Menu />
      <div className="card">
      <h2>Documentación de APIs</h2>
      <h3>Autenticación</h3>
      <p><strong>POST /api/auth/login</strong> - Iniciar sesión. Envía email y password, retorna token JWT.</p>

      <h3>Usuarios</h3>
      <p><strong>GET /api/usuarios</strong> - Listar todos los usuarios (requiere token).</p>
      <p><strong>GET /api/usuarios/{id}</strong> - Obtener usuario por ID.</p>
      <p><strong>POST /api/usuarios</strong> - Crear nuevo usuario.</p>
      <p><strong>PUT /api/usuarios/{id}</strong> - Actualizar usuario (ej. cambiar rol).</p>
      <p><strong>DELETE /api/usuarios/{id}</strong> - Eliminar usuario.</p>

      <h3>Diarios Anuales</h3>
      <p><strong>GET /api/diarios-anuales</strong> - Listar diarios anuales.</p>
      <p><strong>GET /api/diarios-anuales/{id}</strong> - Obtener diario anual por ID.</p>
      <p><strong>POST /api/diarios-anuales</strong> - Crear nuevo diario anual.</p>
      <p><strong>PUT /api/diarios-anuales/{id}</strong> - Actualizar diario anual.</p>
      <p><strong>DELETE /api/diarios-anuales/{id}</strong> - Eliminar diario anual.</p>

      <h3>Días Maestro</h3>
      <p><strong>GET /api/dias-maestro</strong> - Listar días maestro.</p>
      <p><strong>GET /api/dias-maestro/{id}</strong> - Obtener día maestro por ID.</p>
      <p><strong>POST /api/dias-maestro</strong> - Crear nuevo día maestro.</p>
      <p><strong>PUT /api/dias-maestro/{id}</strong> - Actualizar día maestro.</p>
      <p><strong>DELETE /api/dias-maestro/{id}</strong> - Eliminar día maestro.</p>

      <h3>Entradas Diarias</h3>
      <p><strong>GET /api/entradas-diarias</strong> - Listar entradas diarias.</p>
      <p><strong>GET /api/entradas-diarias/{id}</strong> - Obtener entrada diaria por ID.</p>
      <p><strong>GET /api/entradas-diarias/usuario/{usuarioId}/diario/{diarioId}</strong> - Entradas por usuario y diario.</p>
      <p><strong>POST /api/entradas-diarias</strong> - Crear nueva entrada diaria.</p>
      <p><strong>PUT /api/entradas-diarias/{id}</strong> - Actualizar entrada diaria.</p>
      <p><strong>DELETE /api/entradas-diarias/{id}</strong> - Eliminar entrada diaria.</p>

      <h3>Daily Entry</h3>
      <p><strong>GET /api/daily-entry/diarios</strong> - Obtener diarios disponibles.</p>
      <p><strong>GET /api/daily-entry/today</strong> - Obtener entrada del día actual (parámetros opcionales: anio, mes, dia).</p>
      <p><strong>POST /api/daily-entry/save</strong> - Guardar entrada diaria (requiere autenticación).</p>
     </div>
   </div>
 );
};

export default ApiDocs;