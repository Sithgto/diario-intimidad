import React, { useContext } from 'react';
import { Link } from 'react-router-dom';
import { FaHome, FaSignOutAlt, FaCalendarAlt, FaBookOpen, FaUsers, FaUser } from 'react-icons/fa';
import { AuthContext } from '../contexts/AuthContext';

const Menu: React.FC = () => {
  const { user, logout } = useContext(AuthContext)!;

  return (
    <nav className="header-nav">
      <Link to="/" className="nav-icon"><FaHome /> Inicio</Link>
      <Link to="/calendario" className="nav-icon"><FaCalendarAlt /> Calendario</Link>
      <Link to="/daily-entry" className="nav-icon" title="el pasage/versiculo para leer hoy"><FaBookOpen /> Hoy</Link>
      <Link to="/users" className="nav-icon"><FaUsers /> Gestionar Usuarios</Link>
      {user && <span className="nav-icon"><FaUser /> {user.email}</span>}
      <button className="nav-icon logout-btn" onClick={logout}><FaSignOutAlt /> Logout</button>
    </nav>
  );
};

export default Menu;