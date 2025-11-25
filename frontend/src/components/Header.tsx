import React from 'react';
import Menu from './Menu';

const Header: React.FC = () => {
  return (
    <header className="header">
      <div className="logo-section">
        <img src="/images/LOGOTIPOPRINCIPAL-SINFONDO.png" alt="Logo Diario de Intimidad" className="logo" />
        <div className="header-title">Diario de Intimidad</div>
      </div>
      <Menu />
    </header>
  );
};

export default Header;