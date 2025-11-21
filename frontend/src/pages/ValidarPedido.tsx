import React, { useEffect, useState } from 'react';
import { useSearchParams, useNavigate } from 'react-router-dom';
import { API_BASE_URL } from '../constants/api';

const ValidarPedido: React.FC = () => {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const [message, setMessage] = useState('Validando tu compra...');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = searchParams.get('token');
    if (!token) {
      setMessage('Token de validación no encontrado.');
      setLoading(false);
      return;
    }

    validarCompra(token);
  }, [searchParams]);

  const validarCompra = async (token: string) => {
    try {
      const response = await fetch(`${API_BASE_URL}/api/pedidos/validar/${token}`, {
        method: 'GET',
      });

      if (response.ok) {
        const result = await response.text();
        setMessage(result + '\n\nRedirigiendo al login...');
        setTimeout(() => navigate('/login'), 3000);
      } else {
        const error = await response.text();
        setMessage('Error: ' + error);
      }
    } catch (error) {
      console.error('Error validating purchase:', error);
      setMessage('Error al validar la compra. Inténtalo de nuevo.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="validar-pedido">
      <h1>Validación de Compra</h1>
      <div className="mensaje">
        {loading ? (
          <div>Cargando...</div>
        ) : (
          <pre>{message}</pre>
        )}
      </div>
    </div>
  );
};

export default ValidarPedido;