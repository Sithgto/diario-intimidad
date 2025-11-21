import React, { createContext, useState, useEffect, ReactNode } from 'react';
import jwtDecode from 'jwt-decode';
import { API_BASE_URL } from '../constants/api';

interface AuthContextType {
  token: string | null;
  user: { email: string; rol: string; userId: number; diariosComprados: number[] } | null;
  login: (token: string, email: string, rol: string, userId: number) => void;
  logout: () => void;
}

export const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [token, setToken] = useState<string | null>(localStorage.getItem('token'));
  const [user, setUser] = useState<{ email: string; rol: string; userId: number; diariosComprados: number[] } | null>(null);

  useEffect(() => {
    console.log('AuthContext: Checking stored token');
    const storedToken = localStorage.getItem('token');
    const storedUserId = localStorage.getItem('userId');
    console.log('AuthContext: Stored token present:', storedToken ? 'yes' : 'no');
    if (storedToken && storedUserId) {
      try {
        const decoded: any = jwtDecode(storedToken);
        console.log('AuthContext: Decoded token:', decoded);
        const userId = parseInt(storedUserId);
        setUser({ email: decoded.sub, rol: decoded.rol, userId, diariosComprados: [] });
        console.log('AuthContext: User set without pedidos:', { email: decoded.sub, rol: decoded.rol, userId });
      } catch (error) {
        console.error('AuthContext: Token inválido:', error);
        logout();
      }
    } else {
      console.log('AuthContext: No token or userId, user not set');
    }
  }, []);

  const login = async (token: string, email: string, rol: string, userId: number) => {
    setToken(token);
    localStorage.setItem('token', token);
    localStorage.setItem('userId', userId.toString());
    // Obtener diarios comprados
    try {
      const response = await fetch(`${API_BASE_URL}/api/pedidos/usuario/${userId}`);
      const pedidos = await response.json();
      const diariosComprados = pedidos.map((p: any) => p.diarioAnual.id);
      setUser({ email, rol, userId, diariosComprados });
    } catch (error) {
      console.error('Error fetching pedidos:', error);
      setUser({ email, rol, userId, diariosComprados: [] });
    }
  };

  const logout = () => {
    setToken(null);
    setUser(null);
    localStorage.removeItem('token');
    localStorage.removeItem('userId');
  };

  return (
    <AuthContext.Provider value={{ token, user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};