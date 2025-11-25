import React, { useContext } from 'react';
import { Link } from 'react-router-dom';
import { FaHome, FaSignOutAlt, FaCalendarAlt, FaBookOpen, FaUsers, FaUser, FaArchive, FaCalendar, FaShoppingCart, FaBible } from 'react-icons/fa';
import { AuthContext } from '../contexts/AuthContext';

const Menu: React.FC = () => {
  const { user, logout } = useContext(AuthContext)!;

  console.log('Menu: User role:', user?.rol);

  return (
    <nav className="header-nav">
      <Link to="/" className="nav-icon"><FaHome /> Inicio</Link>
      <Link to="/tienda" className="nav-icon"><FaShoppingCart /> Tienda</Link>
      <Link to="/calendario" className="nav-icon" title="seguimiento de dias completados/pendientes"><FaCalendarAlt /> Calendario</Link>
      {user && user.rol !== 'USER' && (console.log('Rendering Días Maestro for role:', user.rol), <Link to="/dia-maestro" className="nav-icon" title="incluir los versiculos/lectura del Diario Intimidad"><FaCalendar /> Días Maestro</Link>)}
      {user && user.rol !== 'USER' && (console.log('Rendering Diario Anual for role:', user.rol), <Link to="/diario-anual" className="nav-icon" title="dar de alta un nuevo diario de intimidad"><FaArchive /> Diario Anual</Link>)}
      <Link to="/biblia" className="nav-icon"><FaBible /> Biblia</Link>
      <Link to="/daily-entry" className="nav-icon" title="el pasage/versiculo para leer hoy"><FaBookOpen /> Hoy</Link>
      {user && user.rol !== 'USER' && <Link to="/users" className="nav-icon" title="gestion de usuarios"><FaUsers /> Usuarios</Link>}
      {user && <Link to="/users" className="nav-icon" title="Gestionar usuarios"><FaUser /> {user.email}</Link>}
      <button className="nav-icon logout-btn" onClick={logout}><FaSignOutAlt /> Logout</button>
    </nav>
  );
};

export default Menu;