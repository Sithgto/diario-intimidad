import React, { useContext } from 'react';
import { Link } from 'react-router-dom';
import { AuthContext } from '../contexts/AuthContext';

const Menu: React.FC = () => {
  const { user, logout } = useContext(AuthContext)!;

  return (
    <header className="header">
      <div className="header-title">Diario de Intimidad</div>
      <nav className="header-nav">
        <Link to="/calendario" className="nav-icon">📅 Calendario</Link>
        <Link to="/daily-entry" className="nav-icon" title="el pasage/versiculo para leer hoy">📖 Hoy</Link>
        <Link to="/users" className="nav-icon">👥 Gestionar Usuarios</Link>
        {user && <span className="nav-icon">👤 {user.email}</span>}
        <button className="nav-icon logout-btn" onClick={logout}>🚪 Logout</button>
      </nav>
    </header>
  );
};

export default Menu;