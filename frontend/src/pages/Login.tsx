import React, { useState, useContext } from 'react';
import axios from 'axios';
import { AuthContext } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import { getErrorMessage } from '../constants/errors';
import { API_BASE_URL } from '../constants/api';
import { FaEye, FaEyeSlash } from 'react-icons/fa';

const Login: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const { login } = useContext(AuthContext)!;
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    console.log('Login: Attempting login with email:', email);
    try {
      const response = await axios.post(`${API_BASE_URL}/api/auth/login`, { email, password });
      console.log('Login: Response received:', response.data);
      login(response.data.token, response.data.email, response.data.rol, response.data.userId);
      console.log('Login: AuthContext login called, navigating to /daily-entry');
      navigate('/daily-entry');
    } catch (error) {
      console.error('Login: Error during login:', error);
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