import React, { useEffect, useState, useContext } from 'react';
import axios from 'axios';
import { AuthContext } from '../contexts/AuthContext';
import { getErrorMessage } from '../constants/errors';

interface Usuario {
  id?: number;
  email: string;
  password?: string;
  rol: string;
  fechaRegistro?: string;
}

const UserManagement: React.FC = () => {
  const [usuarios, setUsuarios] = useState<Usuario[]>([]);
  const [showModal, setShowModal] = useState(false);
  const [modalType, setModalType] = useState<'create' | 'edit' | 'profile'>('create');
  const [currentUser, setCurrentUser] = useState<Usuario | null>(null);
  const [originalUser, setOriginalUser] = useState<Usuario | null>(null);
  const [showPassword, setShowPassword] = useState(false);
  const [emailError, setEmailError] = useState('');
  const [searchEmail, setSearchEmail] = useState('');
  const [filterRol, setFilterRol] = useState('');
  const [sortField, setSortField] = useState<'id' | 'email' | 'rol' | 'fechaRegistro'>('id');
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('asc');
  const { token, user } = useContext(AuthContext)!;
  const isAdmin = user?.rol === 'ADMIN';

  const handleSort = (field: 'id' | 'email' | 'rol' | 'fechaRegistro') => {
    if (sortField === field) {
      setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc');
    } else {
      setSortField(field);
      setSortDirection('asc');
    }
  };

  const filteredUsuarios = usuarios
    .filter(u =>
      u.email.toLowerCase().includes(searchEmail.toLowerCase()) &&
      (!filterRol || u.rol === filterRol)
    )
    .sort((a, b) => {
      let aVal: any = a[sortField];
      let bVal: any = b[sortField];
      if (sortField === 'fechaRegistro') {
        aVal = aVal ? new Date(aVal).getTime() : 0;
        bVal = bVal ? new Date(bVal).getTime() : 0;
      }
      if (aVal < bVal) return sortDirection === 'asc' ? -1 : 1;
      if (aVal > bVal) return sortDirection === 'asc' ? 1 : -1;
      return 0;
    });

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
    const user = userData || { email: '', password: '', rol: 'USER' };
    setCurrentUser(user);
    setOriginalUser({ ...user });
    setShowPassword(false);
    setEmailError('');
    setShowModal(true);
  };

  const closeModal = () => {
    setShowModal(false);
    setCurrentUser(null);
    setOriginalUser(null);
  };

  const hasChanges = () => {
    if (!currentUser || !originalUser) return false;
    return (
      currentUser.email !== originalUser.email ||
      currentUser.rol !== originalUser.rol ||
      (currentUser.password && currentUser.password !== originalUser.password)
    );
  };

  const validateEmail = (email: string) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };

  const isEmailDuplicated = (email: string) => {
    return usuarios.some(u => u.email === email && u.id !== currentUser?.id);
  };

  const isFormValid = () => {
    if (!currentUser) return false;
    const emailValid = validateEmail(currentUser.email);
    const emailNotDuplicated = !isEmailDuplicated(currentUser.email);
    const hasChangesCheck = hasChanges();
    return emailValid && emailNotDuplicated && hasChangesCheck;
  };

  const handleSave = async () => {
    console.log('handleSave called', { modalType, currentUser, originalUser });
    if (!currentUser) {
      console.error('No currentUser');
      return;
    }

    // Validaciones adicionales
    if (!validateEmail(currentUser.email)) {
      console.log('Email format invalid');
      setEmailError('Formato de email inválido');
      return;
    }
    if (isEmailDuplicated(currentUser.email)) {
      console.log('Email duplicated');
      setEmailError('El email ya está en uso');
      return;
    }
    if (currentUser.password && currentUser.password.length < 6) {
      console.log('Password too short');
      alert('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    try {
      if (modalType === 'create') {
        console.log('Creating user');
        console.log('Token being sent:', token);
        if (!currentUser.email || !currentUser.password || currentUser.password.trim() === '') {
          alert('Email y contraseña son obligatorios');
          return;
        }
        await axios.post('http://localhost:8085/api/usuarios', currentUser, {
          headers: { Authorization: `Bearer ${token}` }
        });
      } else if (modalType === 'edit' || modalType === 'profile') {
        console.log('Updating user');
        if (!currentUser.id) {
          console.error('No id for update');
          return;
        }
        const { password, ...userToUpdate } = currentUser;
        if (password) userToUpdate.password = password; // Include password if provided
        console.log('userToUpdate:', userToUpdate);
        await axios.put(`http://localhost:8085/api/usuarios/${currentUser.id}`, userToUpdate, {
          headers: { Authorization: `Bearer ${token}` }
        });
      }
      fetchUsuarios();
      closeModal();
    } catch (error) {
      console.error('Error in handleSave:', error);
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

        {isAdmin && (
          <div style={{ marginBottom: '20px', display: 'flex', gap: '10px', alignItems: 'center' }}>
            <input
              type="text"
              placeholder="Buscar por email..."
              value={searchEmail}
              onChange={(e) => setSearchEmail(e.target.value)}
              style={{ padding: '8px', width: '200px' }}
            />
            <select
              value={filterRol}
              onChange={(e) => setFilterRol(e.target.value)}
              style={{ padding: '8px' }}
            >
              <option value="">Todos los roles</option>
              <option value="USER">USER</option>
              <option value="ADMIN">ADMIN</option>
            </select>
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
          <table className="user-table" style={{ width: '100%', borderCollapse: 'collapse', marginTop: '20px' }}>
            <thead>
              <tr style={{ backgroundColor: '#f4f4f4' }}>
                <th onClick={() => handleSort('id')} style={{ border: '1px solid #ddd', padding: '8px', textAlign: 'left', cursor: 'pointer' }}>ID {sortField === 'id' && (sortDirection === 'asc' ? '↑' : '↓')}</th>
                <th onClick={() => handleSort('email')} style={{ border: '1px solid #ddd', padding: '8px', textAlign: 'left', cursor: 'pointer' }}>Email {sortField === 'email' && (sortDirection === 'asc' ? '↑' : '↓')}</th>
                <th onClick={() => handleSort('rol')} style={{ border: '1px solid #ddd', padding: '8px', textAlign: 'left', cursor: 'pointer' }}>Rol {sortField === 'rol' && (sortDirection === 'asc' ? '↑' : '↓')}</th>
                <th onClick={() => handleSort('fechaRegistro')} style={{ border: '1px solid #ddd', padding: '8px', textAlign: 'left', cursor: 'pointer' }}>Fecha de Creación {sortField === 'fechaRegistro' && (sortDirection === 'asc' ? '↑' : '↓')}</th>
              </tr>
            </thead>
            <tbody>
              {filteredUsuarios.map(u => (
                <tr key={u.id} onClick={() => openModal('edit', u)} style={{ cursor: 'pointer', borderBottom: '1px solid #eee' }}>
                  <td style={{ border: '1px solid #ddd', padding: '8px' }}>{u.id}</td>
                  <td style={{ border: '1px solid #ddd', padding: '8px' }}>{u.email}</td>
                  <td style={{ border: '1px solid #ddd', padding: '8px' }}>{u.rol}</td>
                  <td style={{ border: '1px solid #ddd', padding: '8px' }}>{u.fechaRegistro ? new Date(u.fechaRegistro).toLocaleDateString() : ''}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}

        {showModal && (
          <div className="modal" style={{ position: 'fixed', top: 0, left: 0, width: '100%', height: '100%', backgroundColor: 'rgba(0,0,0,0.5)', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
            <div className="modal-content" style={{ backgroundColor: 'white', padding: '20px', borderRadius: '8px', width: '400px', maxHeight: '80vh', overflowY: 'auto', boxSizing: 'border-box' }}>
              <form onSubmit={(e) => { e.preventDefault(); handleSave(); }}>
                <h3>{modalType === 'create' ? 'Crear Usuario' : modalType === 'edit' ? 'Editar Usuario' : 'Editar Perfil'}</h3>
                <div style={{ marginBottom: '15px' }}>
                  <input
                    className="input"
                    type="email"
                    placeholder="Email"
                    value={currentUser?.email || ''}
                    onChange={(e) => {
                      const email = e.target.value;
                      setCurrentUser({ ...currentUser!, email });
                      if (email) {
                        if (!validateEmail(email)) {
                          setEmailError('Formato de email inválido');
                        } else if (isEmailDuplicated(email)) {
                          setEmailError('El email ya está en uso');
                        } else {
                          setEmailError('');
                        }
                      } else {
                        setEmailError('');
                      }
                    }}
                    disabled={modalType === 'profile'}
                    style={{ width: 'calc(100% - 16px)', padding: '8px', marginBottom: '5px', boxSizing: 'border-box' }}
                  />
                  {emailError && <div style={{ color: 'red', fontSize: '12px' }}>{emailError}</div>}
                </div>
                {(modalType === 'create' || (modalType === 'edit' && isAdmin) || modalType === 'profile') && (
                  <div style={{ marginBottom: '15px' }}>
                    <select
                      className="input"
                      value={currentUser?.rol || 'USER'}
                      onChange={(e) => setCurrentUser({ ...currentUser!, rol: e.target.value })}
                      disabled={modalType === 'profile' && !isAdmin}
                      style={{ width: '150px', padding: '8px', marginBottom: '10px', boxSizing: 'border-box' }}
                    >
                      <option value="USER">USER</option>
                      <option value="ADMIN">ADMIN</option>
                    </select>
                  </div>
                )}
                <div style={{ marginBottom: '15px', position: 'relative' }}>
                  <input
                    className="input"
                    type={showPassword ? 'text' : 'password'}
                    placeholder={modalType === 'create' ? 'Contraseña' : 'Nueva Contraseña (opcional)'}
                    value={currentUser?.password || ''}
                    onChange={(e) => setCurrentUser({ ...currentUser!, password: e.target.value })}
                    style={{ width: 'calc(100% - 16px)', padding: '8px', paddingRight: '40px', boxSizing: 'border-box' }}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    style={{ position: 'absolute', right: '10px', top: '50%', transform: 'translateY(-50%)', background: 'none', border: 'none', cursor: 'pointer', fontSize: '16px' }}
                  >
                    {showPassword ? '🙈' : '👁️'}
                  </button>
                </div>
                <div style={{ marginTop: '20px', textAlign: 'right' }}>
                  {modalType === 'edit' && (
                    <button type="button" className="btn" onClick={() => { handleDelete(currentUser!.id!); closeModal(); }} style={{ backgroundColor: 'red', color: 'white', marginRight: '10px' }}>Eliminar</button>
                  )}
                  <button type="button" className="btn" onClick={closeModal} style={{ marginRight: '10px' }}>Cancelar</button>
                  {isFormValid() && (
                    <button type="submit" className="btn">
                      {modalType === 'create' ? 'Guardar' : 'Actualizar'}
                    </button>
                  )}
                </div>
              </form>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default UserManagement;