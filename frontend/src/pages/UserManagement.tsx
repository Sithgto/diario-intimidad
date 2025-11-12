import React, { useEffect, useState, useContext } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import axios from 'axios';
import { AuthContext } from '../contexts/AuthContext';
import { getErrorMessage } from '../constants/errors';

interface Usuario {
  id?: number;
  email: string;
  password?: string;
  rol: string;
}

const UserManagement: React.FC = () => {
  const [usuarios, setUsuarios] = useState<Usuario[]>([]);
  const [newUser, setNewUser] = useState<Usuario>({ email: '', password: '', rol: 'USER' });
  const [editingUser, setEditingUser] = useState<Usuario | null>(null);
  const { token, user, logout } = useContext(AuthContext)!;
  const navigate = useNavigate();

  useEffect(() => {
    const fetchUsuarios = async () => {
      try {
        const response = await axios.get('http://localhost:8085/api/usuarios', {
          headers: { Authorization: `Bearer ${token}` }
        });
        let filteredUsuarios = response.data;
        if (user?.rol === 'USER') {
          filteredUsuarios = response.data.filter((u: Usuario) => u.email === user.email);
        }
        setUsuarios(filteredUsuarios);
      } catch (error) {
        alert(getErrorMessage('NETWORK_ERROR'));
      }
    };
    fetchUsuarios();
  }, [token, user]);

  const updateRol = async (id: number, newRol: string) => {
    try {
      await axios.put(`http://localhost:8085/api/usuarios/${id}`, { rol: newRol }, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setUsuarios(usuarios.map(u => u.id === id ? { ...u, rol: newRol } : u));
    } catch (error) {
      alert(getErrorMessage('USER_UPDATE_FAILED'));
    }
  };

  const createUser = async () => {
    try {
      const response = await axios.post('http://localhost:8085/api/usuarios', newUser, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setUsuarios([...usuarios, response.data]);
      setNewUser({ email: '', password: '', rol: 'USER' });
    } catch (error) {
      alert(getErrorMessage('USER_CREATE_FAILED'));
    }
  };

  const editUser = async () => {
    if (!editingUser || !editingUser.id) return;
    try {
      const { password, ...userToUpdate } = editingUser; // No enviar password en edición
      await axios.put(`http://localhost:8085/api/usuarios/${editingUser.id}`, userToUpdate, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setUsuarios(usuarios.map(u => u.id === editingUser.id ? editingUser : u));
      setEditingUser(null);
    } catch (error) {
      alert(getErrorMessage('USER_UPDATE_FAILED'));
    }
  };

  const deleteUser = async (id: number) => {
    // eslint-disable-next-line no-restricted-globals
    if (!confirm('¿Estás seguro de eliminar este usuario?')) return;
    try {
      await axios.delete(`http://localhost:8085/api/usuarios/${id}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setUsuarios(usuarios.filter(u => u.id !== id));
    } catch (error) {
      alert(getErrorMessage('USER_DELETE_FAILED'));
    }
  };

  const isAdmin = user?.rol === 'ADMIN';

  return (
    <div className="app-container">
      <header className="header">
        <div className="header-title">Diario de Intimidad</div>
        <nav className="header-nav">
          <Link to="/" className="nav-icon">🏠 Inicio</Link>
          {user?.rol === 'ADMIN' && (
            <>
              <Link to="/users" className="nav-icon">👥 Gestionar Usuarios</Link>
              <Link to="/api-docs" className="nav-icon">📚 Documentación APIs</Link>
            </>
          )}
          <span className="nav-icon">👤 {user?.email}</span>
          <button className="nav-icon logout-btn" onClick={logout}>🚪 Logout</button>
        </nav>
      </header>
      <div className="card">
        <h2>Gestión de Usuarios</h2>

      {/* Crear Usuario - Solo ADMIN */}
      {isAdmin && (
        <div style={{ marginBottom: '20px' }}>
          <h3>Crear Usuario</h3>
          <input
            className="input"
            type="email"
            placeholder="Email"
            value={newUser.email}
            onChange={(e) => setNewUser({ ...newUser, email: e.target.value })}
          />
          <input
            className="input"
            type="password"
            placeholder="Password"
            value={newUser.password}
            onChange={(e) => setNewUser({ ...newUser, password: e.target.value })}
          />
          <select
            className="input"
            value={newUser.rol}
            onChange={(e) => setNewUser({ ...newUser, rol: e.target.value })}
          >
            <option value="USER">USER</option>
            <option value="ADMIN">ADMIN</option>
          </select>
          <button className="btn" onClick={createUser}>Crear</button>
        </div>
      )}

      {/* Editar Usuario */}
      {editingUser && (
        <div style={{ marginBottom: '20px' }}>
          <h3>Editar Usuario</h3>
          <input
            className="input"
            type="email"
            placeholder="Email"
            value={editingUser.email}
            onChange={(e) => setEditingUser({ ...editingUser, email: e.target.value })}
          />
          {!isAdmin && (
            <input
              className="input"
              type="password"
              placeholder="Nueva Contraseña (opcional)"
              value={editingUser.password || ''}
              onChange={(e) => setEditingUser({ ...editingUser, password: e.target.value })}
            />
          )}
          {isAdmin && (
            <select
              className="input"
              value={editingUser.rol}
              onChange={(e) => setEditingUser({ ...editingUser, rol: e.target.value })}
            >
              <option value="USER">USER</option>
              <option value="ADMIN">ADMIN</option>
            </select>
          )}
          <button className="btn" onClick={editUser}>Guardar</button>
          <button className="btn" onClick={() => setEditingUser(null)}>Cancelar</button>
        </div>
      )}

      {/* Listar Usuarios - Solo ADMIN */}
      {isAdmin && (
        <>
          <h3>Lista de Usuarios</h3>
          <ul>
            {usuarios.map(u => (
              <li key={u.id} style={{ marginBottom: '10px' }}>
                {u.email} - {u.rol}
                <select className="input" value={u.rol} onChange={(e) => updateRol(u.id!, e.target.value)} style={{ marginLeft: '10px', width: 'auto' }}>
                  <option value="USER">USER</option>
                  <option value="ADMIN">ADMIN</option>
                </select>
                <button className="btn" onClick={() => setEditingUser(u)} style={{ marginLeft: '10px' }}>Editar</button>
                <button className="btn" onClick={() => deleteUser(u.id!)} style={{ marginLeft: '10px', backgroundColor: 'red' }}>Eliminar</button>
              </li>
            ))}
          </ul>
        </>
      )}

      {/* Para USER: Solo mostrar opción de editar perfil */}
      {!isAdmin && usuarios.length > 0 && (
        <div>
          <h3>Mi Perfil</h3>
          <p>Email: {usuarios[0].email}</p>
          <p>Rol: {usuarios[0].rol}</p>
          <button className="btn" onClick={() => setEditingUser(usuarios[0])}>Editar Mi Perfil</button>
        </div>
      )}
      </div>
    </div>
  );
};

export default UserManagement;