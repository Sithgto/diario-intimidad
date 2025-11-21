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
      // Ordenar por año ascendente
      const sortedData = data.sort((a: DiarioAnual, b: DiarioAnual) => a.anio - b.anio);
      setDiarios(sortedData);
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
      <p>Descubre nuestros diarios espirituales para guiar tu caminar con Dios a lo largo del año.</p>
      <div className="diarios-grid">
        {diarios.map((diario) => (
          <div key={diario.id} className="diario-card">
            <img
              src={diario.nombrePortada ? `/uploads/images/${diario.nombrePortada}` : '/images/default-cover.jpg'}
              alt={`Portada de ${diario.titulo}`}
              className="diario-imagen"
              onError={(e) => {
                console.log('Image failed to load:', e.currentTarget.src);
                e.currentTarget.src = '/images/default-cover.jpg';
              }}
            />
            <div className="diario-info">
              <h3>{diario.titulo}</h3>
              <p className="diario-anio">{diario.anio}</p>
              <p className="diario-tema">{diario.temaPrincipal}</p>
              <p className="diario-precio">
                Precio: {diario.precio ? `$${diario.precio}` : 'Precio no disponible'}
              </p>
              <button className="btn-comprar" onClick={() => setSelectedDiario(diario)}>
                Comprar Ahora
              </button>
            </div>
          </div>
        ))}
      </div>

      {selectedDiario && (
        <div className="compra-modal">
          <div className="compra-content">
            <h2>Comprar {selectedDiario.titulo}</h2>
            {selectedDiario.nombrePortada && (
              <img
                src={`/uploads/images/${selectedDiario.nombrePortada}`}
                alt={`Portada de ${selectedDiario.titulo}`}
                className="compra-imagen"
              />
            )}
            <p><strong>Año:</strong> {selectedDiario.anio}</p>
            <p><strong>Tema:</strong> {selectedDiario.temaPrincipal}</p>
            <p><strong>Precio:</strong> {selectedDiario.precio ? `$${selectedDiario.precio}` : 'Precio no disponible'}</p>
            <input
              type="email"
              placeholder="Ingresa tu email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="email-input"
            />
            <div className="compra-buttons">
              <button className="btn-confirmar" onClick={handleCompra}>Confirmar Compra</button>
              <button className="btn-cancelar" onClick={() => setSelectedDiario(null)}>Cancelar</button>
            </div>
          </div>
        </div>
      )}

      {message && <div className="mensaje">{message}</div>}
    </div>
  );
};

export default Tienda;