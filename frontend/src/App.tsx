import React, { useContext } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate, Link, useNavigate } from 'react-router-dom';
import { AuthProvider, AuthContext } from './contexts/AuthContext';
import Login from './pages/Login';
import UserManagement from './pages/UserManagement';
import ApiDocs from './pages/ApiDocs';

const PrivateRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { token } = useContext(AuthContext)!;
  return token ? <>{children}</> : <Navigate to="/login" />;
};

function App() {
  return (
    <AuthProvider>
      <Router>
        <div className="app-container">
          <Routes>
            <Route path="/login" element={<Login />} />
            <Route path="/" element={<Home />} />
            <Route path="/users" element={<PrivateRoute><UserManagement /></PrivateRoute>} />
            <Route path="/api-docs" element={<PrivateRoute><ApiDocs /></PrivateRoute>} />
          </Routes>
        </div>
      </Router>
    </AuthProvider>
  );
}

const Home: React.FC = () => {
  const { token, user, logout } = useContext(AuthContext)!;
  const navigate = useNavigate();
  return (
    <div className="home-container">
      <header className="header">
        <div className="header-title">Diario de Intimidad</div>
        <nav className="header-nav">
          <Link to="/" className="nav-icon">🏠 Inicio</Link>
          {token ? (
            <>
              <Link to="/users" className="nav-icon">👥 Gestionar Usuarios</Link>
              <Link to="/api-docs" className="nav-icon">📚 Documentación APIs</Link>
              <span className="nav-icon">👤 {user?.email}</span>
              <button className="nav-icon logout-btn" onClick={logout}>🚪 Logout</button>
            </>
          ) : (
            <Link to="/login" className="nav-icon">🔐 Login</Link>
          )}
        </nav>
      </header>
      <main className="main-content">
        <section className="hero">
          <div className="hero-text">
            <h1>Descubre el Poder de la Escritura Diaria</h1>
            <p>El Diario de Intimidad es tu compañero perfecto para reflexionar, crecer y mantener un registro personal de tus pensamientos, emociones y experiencias. Con esta herramienta, podrás:</p>
            <ul>
              <li>Registrar entradas diarias de manera sencilla y organizada.</li>
              <li>Explorar patrones en tus emociones y hábitos a lo largo del tiempo.</li>
              <li>Mantener un espacio privado y seguro para tu introspección.</li>
              <li>Mejorar tu bienestar mental mediante la práctica regular de la escritura.</li>
            </ul>
            <p>Únete a miles de personas que han transformado sus vidas a través de la escritura diaria. ¡Comienza hoy mismo!</p>
            {token ? (
              <p>Bienvenido de vuelta, {user?.email}!</p>
            ) : (
              <button className="btn" onClick={() => navigate('/login')}>Iniciar Sesión</button>
            )}
          </div>
          <div className="hero-image">
            <div className="diary-cover">
              <h2>Portada del Diario de Intimidad</h2>
              <p>Una herramienta elegante para tu viaje personal</p>
            </div>
          </div>
        </section>
      </main>
    </div>
  );
};

export default App;