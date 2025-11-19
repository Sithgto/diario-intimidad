import React, { useEffect, useState, useContext } from 'react';
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
  const [showModal, setShowModal] = useState(false);
  const [modalType, setModalType] = useState<'create' | 'edit' | 'profile'>('create');
  const [currentUser, setCurrentUser] = useState<Usuario | null>(null);
  const { token, user } = useContext(AuthContext)!;
  const isAdmin = user?.rol === 'ADMIN';

  useEffect(() => {
    fetchUsuarios();
  }, [token, user]);

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

  const openModal = (type: 'create' | 'edit' | 'profile', userData?: Usuario) => {
    setModalType(type);
    setCurrentUser(userData || { email: '', password: '', rol: 'USER' });
    setShowModal(true);
  };

  const closeModal = () => {
    setShowModal(false);
    setCurrentUser(null);
  };

  const handleSave = async () => {
    if (!currentUser) return;

    try {
      if (modalType === 'create') {
        if (!currentUser.email || !currentUser.password) {
          alert('Email y contraseña son obligatorios');
          return;
        }
        await axios.post('http://localhost:8085/api/usuarios', currentUser, {
          headers: { Authorization: `Bearer ${token}` }
        });
      } else if (modalType === 'edit' || modalType === 'profile') {
        if (!currentUser.id) return;
        const { password, ...userToUpdate } = currentUser;
        if (password) userToUpdate.password = password; // Include password if provided
        await axios.put(`http://localhost:8085/api/usuarios/${currentUser.id}`, userToUpdate, {
          headers: { Authorization: `Bearer ${token}` }
        });
      }
      fetchUsuarios();
      closeModal();
    } catch (error) {
      alert(getErrorMessage(modalType === 'create' ? 'USER_CREATE_FAILED' : 'USER_UPDATE_FAILED'));
    }
  };

  const handleDelete = async (id: number) => {
    // eslint-disable-next-line no-restricted-globals
    if (!confirm('¿Estás seguro de eliminar este usuario?')) return;
    try {
      await axios.delete(`http://localhost:8085/api/usuarios/${id}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      fetchUsuarios();
    } catch (error) {
      alert(getErrorMessage('USER_DELETE_FAILED'));
    }
  };

  return (
    <div className="app-container">
      <div className="card">
        <h2>Gestión de Usuarios</h2>

        {isAdmin && (
          <div style={{ marginBottom: '20px', textAlign: 'right' }}>
            <button className="btn" onClick={() => openModal('create')}>Agregar Usuario</button>
          </div>
        )}

        {!isAdmin && usuarios.length > 0 && (
          <div className="user-card" style={{ marginBottom: '20px' }}>
            <h3>Mi Perfil</h3>
            <p><strong>Email:</strong> {usuarios[0].email}</p>
            <p><strong>Rol:</strong> {usuarios[0].rol}</p>
            <button className="btn" onClick={() => openModal('profile', usuarios[0])}>Editar Perfil</button>
          </div>
        )}

        {isAdmin && (
          <div className="user-list">
            {usuarios.map(u => (
              <div key={u.id} className="user-card" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px', border: '1px solid #ddd', borderRadius: '8px', marginBottom: '10px' }}>
                <div>
                  <p><strong>Email:</strong> {u.email}</p>
                  <p><strong>Rol:</strong> {u.rol}</p>
                </div>
                <div>
                  <button className="btn" onClick={() => openModal('edit', u)} style={{ marginRight: '10px' }}>Editar</button>
                  <button className="btn" onClick={() => handleDelete(u.id!)} style={{ backgroundColor: 'red', color: 'white' }}>Eliminar</button>
                </div>
              </div>
            ))}
          </div>
        )}

        {showModal && (
          <div className="modal" style={{ position: 'fixed', top: 0, left: 0, width: '100%', height: '100%', backgroundColor: 'rgba(0,0,0,0.5)', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
            <div className="modal-content" style={{ backgroundColor: 'white', padding: '20px', borderRadius: '8px', width: '400px' }}>
              <h3>{modalType === 'create' ? 'Crear Usuario' : modalType === 'edit' ? 'Editar Usuario' : 'Editar Perfil'}</h3>
              <input
                className="input"
                type="email"
                placeholder="Email"
                value={currentUser?.email || ''}
                onChange={(e) => setCurrentUser({ ...currentUser!, email: e.target.value })}
                disabled={modalType === 'profile'}
              />
              {(modalType === 'create' || (modalType === 'edit' && isAdmin) || modalType === 'profile') && (
                <select
                  className="input"
                  value={currentUser?.rol || 'USER'}
                  onChange={(e) => setCurrentUser({ ...currentUser!, rol: e.target.value })}
                  disabled={modalType === 'profile' && !isAdmin}
                >
                  <option value="USER">USER</option>
                  <option value="ADMIN">ADMIN</option>
                </select>
              )}
              <input
                className="input"
                type="password"
                placeholder={modalType === 'create' ? 'Contraseña' : 'Nueva Contraseña (opcional)'}
                value={currentUser?.password || ''}
                onChange={(e) => setCurrentUser({ ...currentUser!, password: e.target.value })}
              />
              <div style={{ marginTop: '20px', textAlign: 'right' }}>
                <button className="btn" onClick={closeModal} style={{ marginRight: '10px' }}>Cancelar</button>
                <button className="btn" onClick={handleSave}>Guardar</button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default UserManagement;