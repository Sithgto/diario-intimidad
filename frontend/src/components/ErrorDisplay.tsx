import React from 'react';
import { useError } from '../contexts/ErrorContext';

const ErrorDisplay: React.FC = () => {
  const { error, clearError } = useError();

  if (!error) return null;

  return (
    <div style={{
      position: 'fixed',
      top: '20px',
      right: '20px',
      backgroundColor: '#f8d7da',
      color: '#721c24',
      padding: '10px 15px',
      border: '1px solid #f5c6cb',
      borderRadius: '5px',
      boxShadow: '0 2px 4px rgba(0,0,0,0.1)',
      zIndex: 1000,
      maxWidth: '300px'
    }}>
      <p style={{ margin: 0, fontSize: '14px' }}>{error}</p>
      <button
        onClick={clearError}
        style={{
          background: 'none',
          border: 'none',
          color: '#721c24',
          cursor: 'pointer',
          fontSize: '16px',
          position: 'absolute',
          top: '5px',
          right: '10px'
        }}
      >
        ×
      </button>
    </div>
  );
};

export default ErrorDisplay;