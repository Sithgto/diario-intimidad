import React, { createContext, useContext, useState, ReactNode } from 'react';
import { getErrorMessage, ErrorCode } from '../constants/errors';

interface ErrorContextType {
  error: string | null;
  setError: (error: string | ErrorCode) => void;
  clearError: () => void;
}

const ErrorContext = createContext<ErrorContextType | undefined>(undefined);

export const ErrorProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [error, setErrorState] = useState<string | null>(null);

  const setError = (error: string | ErrorCode) => {
    if (typeof error === 'string') {
      setErrorState(error);
    } else {
      setErrorState(getErrorMessage(error));
    }
  };

  const clearError = () => {
    setErrorState(null);
  };

  return (
    <ErrorContext.Provider value={{ error, setError, clearError }}>
      {children}
    </ErrorContext.Provider>
  );
};

export const useError = (): ErrorContextType => {
  const context = useContext(ErrorContext);
  if (!context) {
    throw new Error('useError must be used within an ErrorProvider');
  }
  return context;
};