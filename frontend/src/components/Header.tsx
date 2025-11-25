import React from 'react';
import Menu from './Menu';

const Header: React.FC = () => {
  return (
    <header className="header">
      <div className="header-title">Diario de Intimidad</div>
      <Menu />
    </header>
  );
};

export default Header;