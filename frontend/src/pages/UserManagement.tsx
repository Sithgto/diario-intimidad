import React, { useEffect, useState, useContext } from 'react';
import { useNavigate } from 'react-router-dom';
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
        setUsuarios(response.data);
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
    if (!newUser.email || !newUser.password) {
      alert('Email y contraseña son obligatorios');
      return;
    }
    try {
      const response = await axios.post('http://localhost:8085/api/usuarios', newUser, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setUsuarios([...usuarios, response.data]);
      setNewUser({ email: '', password: '', rol: 'USER' });
      setView('list'); // Cambiar a vista de lista después de crear
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

  const [view, setView] = useState<'profile' | 'list' | 'create'>('profile');

  return (
    <div className="app-container">
      <div className="card">
        <h2>Gestión de Usuarios</h2>

        {view !== 'create' && (
          <>
            {/* Navegación */}
            <div style={{ marginBottom: '20px' }}>
              <button className="btn" onClick={() => setView('profile')}>Mi Perfil</button>
              {isAdmin && <button className="btn" onClick={() => setView('list')} style={{ marginLeft: '10px' }}>Ver Usuarios</button>}
              {isAdmin && <button className="btn" onClick={() => setView('create')} style={{ marginLeft: '10px' }}>Crear Usuario</button>}
            </div>
          </>
        )}

        {/* Mi Perfil */}
        {view === 'profile' && user && !editingUser && (
          <div style={{ marginBottom: '20px' }}>
            <h3>Mi Perfil</h3>
            <p><strong>Email:</strong> {user.email}</p>
            <p><strong>Rol:</strong> {user.rol}</p>
            <button className="btn" onClick={() => setEditingUser(user)}>Editar Mi Perfil</button>
          </div>
        )}

      {/* Crear Usuario - Solo ADMIN */}
      {view === 'create' && isAdmin && (
        <div style={{ marginBottom: '20px' }}>
          <h3>Crear Nuevo Usuario</h3>
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
          <button className="create-btn" onClick={createUser}>Crear</button>
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
          {editingUser.email !== user?.email && isAdmin && (
            <select
              className="input"
              value={editingUser.rol}
              onChange={(e) => setEditingUser({ ...editingUser, rol: e.target.value })}
            >
              <option value="USER">USER</option>
              <option value="ADMIN">ADMIN</option>
            </select>
          )}
          <input
            className="input"
            type="password"
            placeholder="Nueva Contraseña (opcional)"
            value={editingUser.password || ''}
            onChange={(e) => setEditingUser({ ...editingUser, password: e.target.value })}
          />
          <button className="btn" onClick={editUser}>Guardar</button>
          <button className="btn" onClick={() => setEditingUser(null)}>Cancelar</button>
        </div>
      )}

      {/* Listar Usuarios - Solo ADMIN */}
      {view === 'list' && isAdmin && (
        <>
          <h3>Lista de Usuarios</h3>
          <ul>
            {usuarios.map(u => (
              <li key={u.id} style={{ marginBottom: '10px' }}>
                <span style={{ cursor: 'pointer', color: 'blue' }} onClick={() => setEditingUser(u)}>{u.email}</span> - {u.rol}
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

      </div>
    </div>
  );
};

export default UserManagement;