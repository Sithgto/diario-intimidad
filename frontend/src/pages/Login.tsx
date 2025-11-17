import React, { useState, useContext } from 'react';
import axios from 'axios';
import { AuthContext } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import { getErrorMessage } from '../constants/errors';
import { FaEye, FaEyeSlash } from 'react-icons/fa';

const Login: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const { login } = useContext(AuthContext)!;
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const response = await axios.post('http://localhost:8085/api/auth/login', { email, password });
      login(response.data.token, response.data.email, response.data.rol);
      navigate('/');
    } catch (error) {
      alert(getErrorMessage('AUTH_INVALID_CREDENTIALS'));
    }
  };

  return (
    <div className="login-container">
      <div className="login-main">
        <div className="login-card">
          <h2>Diario de Intimidad</h2>
          <form onSubmit={handleSubmit}>
            <div>
              <label>Email:</label>
              <input className="input" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
            </div>
            <div>
              <label>Contraseña:</label>
              <div style={{ position: 'relative' }}>
                <input
                  className="input"
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  style={{ paddingRight: '40px' }}
                />
                {showPassword ? (
                  <FaEyeSlash
                    onClick={() => setShowPassword(false)}
                    style={{
                      position: 'absolute',
                      right: '10px',
                      top: '50%',
                      transform: 'translateY(-50%)',
                      cursor: 'pointer'
                    }}
                  />
                ) : (
                  <FaEye
                    onClick={() => setShowPassword(true)}
                    style={{
                      position: 'absolute',
                      right: '10px',
                      top: '50%',
                      transform: 'translateY(-50%)',
                      cursor: 'pointer'
                    }}
                  />
                )}
              </div>
            </div>
            <button className="btn" type="submit">Login</button>
          </form>
        </div>
      </div>
    </div>
  );
};

export default Login;