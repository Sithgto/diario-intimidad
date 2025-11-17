import React from 'react';

const Footer: React.FC = () => {
  return (
    <footer className="footer">
      © {new Date().getFullYear()} Torre de Gracia Barcelona - Diario de Intimidad
    </footer>
  );
};

export default Footer;