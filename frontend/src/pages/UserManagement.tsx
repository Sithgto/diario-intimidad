import React, { useEffect, useState, useContext } from 'react';
import axios from 'axios';
import { AuthContext } from '../contexts/AuthContext';
import { getErrorMessage } from '../constants/errors';

interface Usuario {
  id: number;
  email: string;
  rol: string;
}

const UserManagement: React.FC = () => {
  const [usuarios, setUsuarios] = useState<Usuario[]>([]);
  const { token } = useContext(AuthContext)!;

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
  }, [token]);

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

  return (
    <div className="card">
      <h2>Gestión de Usuarios</h2>
      <ul>
        {usuarios.map(u => (
          <li key={u.id} style={{ marginBottom: '10px' }}>
            {u.email} - {u.rol}
            <select className="input" value={u.rol} onChange={(e) => updateRol(u.id, e.target.value)} style={{ marginLeft: '10px', width: 'auto' }}>
              <option value="USER">USER</option>
              <option value="ADMIN">ADMIN</option>
            </select>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default UserManagement;