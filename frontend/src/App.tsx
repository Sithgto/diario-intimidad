import React, { useContext } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate, Link, useNavigate } from 'react-router-dom';
import { AuthProvider, AuthContext } from './contexts/AuthContext';
import { ErrorProvider } from './contexts/ErrorContext';
import { FaUser } from 'react-icons/fa';
import Login from './pages/Login';
import UserManagement from './pages/UserManagement';
import ApiDocs from './pages/ApiDocs';
import DailyEntry from './pages/DailyEntry';
import Calendario from './pages/Calendario';
import DiarioAnual from './pages/DiarioAnual';
import Biblia from './pages/Biblia';
import Header from './components/Header';
import Footer from './components/Footer';
import ErrorDisplay from './components/ErrorDisplay';

const PrivateRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { token } = useContext(AuthContext)!;
  return token ? <Layout>{children}</Layout> : <Navigate to="/login" />;
};

const Layout: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  return (
    <div className="layout-wrapper">
      <Header />
      <div className="app-container">
        <main className="main-content">{children}</main>
      </div>
      <Footer />
      <ErrorDisplay />
    </div>
  );
};

function App() {
  console.log('App component rendering');
  return (
    <ErrorProvider>
      <AuthProvider>
        <Router>
          <Routes>
            <Route path="/login" element={<Login />} />
            <Route path="/" element={<Home />} />
            <Route path="/daily-entry" element={<PrivateRoute><DailyEntry /></PrivateRoute>} />
            <Route path="/calendario" element={<PrivateRoute><Calendario /></PrivateRoute>} />
            <Route path="/diario-anual" element={<PrivateRoute><DiarioAnual /></PrivateRoute>} />
            <Route path="/biblia" element={<PrivateRoute><Biblia /></PrivateRoute>} />
            <Route path="/users" element={<PrivateRoute><UserManagement /></PrivateRoute>} />
            <Route path="/api-docs" element={<PrivateRoute><ApiDocs /></PrivateRoute>} />
          </Routes>
        </Router>
      </AuthProvider>
    </ErrorProvider>
  );
}

const Home: React.FC = () => {
  const { token, user, logout } = useContext(AuthContext)!;
  const navigate = useNavigate();

  const content = (
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
          <button className="btn" onClick={() => navigate('/daily-entry')}>Ir al Diario</button>
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
  );

  if (token) {
    return <Layout>{content}</Layout>;
  } else {
    return (
      <div className="layout-wrapper">
        <div className="app-container">
          <header className="header">
            <div className="header-title">Diario de Intimidad</div>
            <nav className="header-nav">
              <Link to="/login" className="nav-icon"><FaUser /> Login</Link>
            </nav>
          </header>
          <main className="main-content">
            {content}
          </main>
          <Footer />
        </div>
      </div>
    );
  }
};

export default App;