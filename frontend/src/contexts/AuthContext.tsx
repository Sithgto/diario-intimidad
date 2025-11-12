import React, { createContext, useState, ReactNode } from 'react';

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