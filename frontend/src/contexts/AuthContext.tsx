import React, { createContext, useState, useEffect, ReactNode } from 'react';
import jwtDecode from 'jwt-decode';

interface AuthContextType {
  token: string | null;
  user: { email: string; rol: string } | null;
  login: (token: string, email: string, rol: string) => void;
  logout: () => void;
}

export const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [token, setToken] = useState<string | null>(localStorage.getItem('token'));
  const [user, setUser] = useState<{ email: string; rol: string } | null>(null);

  useEffect(() => {
    console.log('AuthContext: Checking stored token');
    const storedToken = localStorage.getItem('token');
    console.log('AuthContext: Stored token present:', storedToken ? 'yes' : 'no');
    if (storedToken) {
      try {
        const decoded: any = jwtDecode(storedToken);
        console.log('AuthContext: Decoded token:', decoded);
        setUser({ email: decoded.email, rol: decoded.rol });
        console.log('AuthContext: User set:', { email: decoded.email, rol: decoded.rol });
      } catch (error) {
        console.error('AuthContext: Token inválido:', error);
        logout();
      }
    } else {
      console.log('AuthContext: No token, user not set');
    }
  }, []);

  const login = (token: string, email: string, rol: string) => {
    setToken(token);
    setUser({ email, rol });
    localStorage.setItem('token', token);
  };

  const logout = () => {
    setToken(null);
    setUser(null);
    localStorage.removeItem('token');
  };

  return (
    <AuthContext.Provider value={{ token, user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};