import React, { useContext } from 'react';
import { Link } from 'react-router-dom';
import { FaHome, FaSignOutAlt, FaCalendarAlt, FaBookOpen, FaUsers, FaUser, FaArchive, FaBible } from 'react-icons/fa';
import { AuthContext } from '../contexts/AuthContext';

const Header: React.FC = () => {
  const { user, logout } = useContext(AuthContext)!;

  return (
    <header className="header">
      <div className="header-title">Diario de Intimidad</div>
      <nav className="header-nav">
        <Link to="/" className="nav-icon"><FaHome /> Inicio</Link>
        <Link to="/calendario" className="nav-icon"><FaCalendarAlt /> Calendario</Link>
        <Link to="/diario-anual" className="nav-icon"><FaArchive /> Diario Anual</Link>
        <Link to="/biblia" className="nav-icon"><FaBible /> Biblia</Link>
        <Link to="/daily-entry" className="nav-icon" title="el pasage/versiculo para leer hoy"><FaBookOpen /> Hoy</Link>
        <Link to="/users" className="nav-icon"><FaUsers /> Usuarios</Link>
        {user && <Link to="/users" className="nav-icon"><FaUser /> {user.email}</Link>}
        <button className="nav-icon logout-btn" onClick={logout}><FaSignOutAlt /> Logout</button>
      </nav>
    </header>
  );
};

export default Header;