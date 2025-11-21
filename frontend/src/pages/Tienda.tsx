import React, { useState, useEffect } from 'react';
import { API_BASE_URL } from '../constants/api';

interface DiarioAnual {
  id: number;
  anio: number;
  titulo: string;
  nombrePortada?: string;
  nombreLogo?: string;
  temaPrincipal: string;
  status: string;
  precio?: number;
}

const Tienda: React.FC = () => {
  const [diarios, setDiarios] = useState<DiarioAnual[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedDiario, setSelectedDiario] = useState<DiarioAnual | null>(null);
  const [email, setEmail] = useState('');
  const [message, setMessage] = useState('');

  useEffect(() => {
    fetchDiarios();
  }, []);

  const fetchDiarios = async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/api/diarios-anuales`);
      const data = await response.json();
      setDiarios(data);
    } catch (error) {
      console.error('Error fetching diarios:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleCompra = async () => {
    if (!selectedDiario || !email) return;

    try {
      const response = await fetch(`${API_BASE_URL}/api/pedidos`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          diarioId: selectedDiario.id,
          email: email,
        }),
      });

      if (response.ok) {
        setMessage('Compra simulada exitosamente. Revisa tu email para validar.');
        setSelectedDiario(null);
        setEmail('');
      } else {
        setMessage('Error en la compra.');
      }
    } catch (error) {
      console.error('Error:', error);
      setMessage('Error en la compra.');
    }
  };

  if (loading) return <div>Cargando...</div>;

  return (
    <div className="tienda">
      <h1>Tienda de Diarios Anuales</h1>
      <div className="diarios-grid">
        {diarios.map((diario) => (
          <div key={diario.id} className="diario-card">
            <h3>{diario.titulo} - {diario.anio}</h3>
            <p>{diario.temaPrincipal}</p>
            <p>Precio: ${diario.precio || 'N/A'}</p>
            <button onClick={() => setSelectedDiario(diario)}>Comprar</button>
          </div>
        ))}
      </div>

      {selectedDiario && (
        <div className="compra-form">
          <h2>Comprar {selectedDiario.titulo}</h2>
          <input
            type="email"
            placeholder="Tu email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
          <button onClick={handleCompra}>Confirmar Compra</button>
          <button onClick={() => setSelectedDiario(null)}>Cancelar</button>
        </div>
      )}

      {message && <p>{message}</p>}
    </div>
  );
};

export default Tienda;