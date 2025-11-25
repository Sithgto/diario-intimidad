import React, { useEffect, useState, useContext } from 'react';
import { AuthContext } from '../contexts/AuthContext';
import { useError } from '../contexts/ErrorContext';

import { API_BASE_URL } from '../constants/api';
const API_BASE = API_BASE_URL;

interface DiarioAnual {
  id: number;
  titulo: string;
  anio: number;
}

interface MesMaestro {
  id: number;
  nombre: string;
  mesNumero: number;
}

interface DiaMaestro {
  id?: number;
  mesMaestro: MesMaestro;
  diaNumero: number;
  tipoDia: 'NORMAL' | 'DOMINGO';
  lecturaBiblica: string;
  versiculoDiario: string;
}

const DiaMaestro: React.FC = () => {
  const [diarios, setDiarios] = useState<DiarioAnual[]>([]);
  const [selectedDiario, setSelectedDiario] = useState<DiarioAnual | null>(null);
  const [meses, setMeses] = useState<MesMaestro[]>([]);
  const [dias, setDias] = useState<DiaMaestro[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [editing, setEditing] = useState<DiaMaestro | null>(null);
  const [showForm, setShowForm] = useState<boolean>(false);
  const { setError } = useError();
  const [form, setForm] = useState<DiaMaestro>({
    mesMaestro: { id: 0, nombre: '', mesNumero: 0 },
    diaNumero: 1,
    tipoDia: 'NORMAL',
    lecturaBiblica: '',
    versiculoDiario: ''
  });
  const { token } = useContext(AuthContext)!;

  const fetchDiarios = async () => {
    setLoading(true);
    try {
      const response = await fetch(`${API_BASE}/api/diarios-anuales`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
      if (!response.ok) {
        throw new Error('Error al cargar diarios anuales');
      }
      const data: DiarioAnual[] = await response.json();
      setDiarios(data);
    } catch (err) {
      setError('NETWORK_ERROR');
    } finally {
      setLoading(false);
    }
  };

  const fetchMeses = async (diarioId: number) => {
    try {
      const response = await fetch(`${API_BASE}/api/meses-maestro/diario/${diarioId}`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
      if (!response.ok) {
        throw new Error('Error al cargar meses');
      }
      const data: MesMaestro[] = await response.json();
      setMeses(data);
    } catch (err) {
      setError('NETWORK_ERROR');
    }
  };

  const fetchDias = async (diarioId: number) => {
    setLoading(true);
    try {
      const response = await fetch(`${API_BASE}/api/dias-maestro/diario/${diarioId}`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
      if (!response.ok) {
        throw new Error('Error al cargar días maestro');
      }
      const data: DiaMaestro[] = await response.json();
      setDias(data);
    } catch (err) {
      setError('NETWORK_ERROR');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDiarios();
  }, [token]);

  const handleDiarioChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const diarioId = parseInt(e.target.value);
    const diario = diarios.find(d => d.id === diarioId);
    setSelectedDiario(diario || null);
    if (diario) {
      fetchMeses(diario.id);
      fetchDias(diario.id);
    } else {
      setMeses([]);
      setDias([]);
    }
  };

  const handleCreate = async () => {
    if (!selectedDiario || !form.mesMaestro.id || !form.diaNumero || !form.lecturaBiblica.trim() || !form.versiculoDiario.trim()) {
      setError('VALIDATION_REQUIRED');
      return;
    }
    try {
      const response = await fetch(`${API_BASE}/api/dias-maestro`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(form)
      });
      if (!response.ok) {
        throw new Error('Error al crear día maestro');
      }
      const newDia: DiaMaestro = await response.json();
      setDias([...dias, newDia]);
      setForm({
        mesMaestro: { id: 0, nombre: '', mesNumero: 0 },
        diaNumero: 1,
        tipoDia: 'NORMAL',
        lecturaBiblica: '',
        versiculoDiario: ''
      });
      setShowForm(false);
    } catch (err) {
      setError('NETWORK_ERROR');
    }
  };

  const handleUpdate = async () => {
    if (!editing) return;
    if (!form.mesMaestro.id || !form.diaNumero || !form.lecturaBiblica.trim() || !form.versiculoDiario.trim()) {
      setError('VALIDATION_REQUIRED');
      return;
    }
    try {
      const response = await fetch(`${API_BASE}/api/dias-maestro/${editing.id}`, {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(form)
      });
      if (!response.ok) {
        throw new Error('Error al actualizar día maestro');
      }
      const updatedDia: DiaMaestro = await response.json();
      setDias(dias.map(d => d.id === editing.id ? updatedDia : d));
      setEditing(null);
      setForm({
        mesMaestro: { id: 0, nombre: '', mesNumero: 0 },
        diaNumero: 1,
        tipoDia: 'NORMAL',
        lecturaBiblica: '',
        versiculoDiario: ''
      });
      setShowForm(false);
    } catch (err) {
      setError('NETWORK_ERROR');
    }
  };

  const handleDelete = async (id: number) => {
    if (!window.confirm('¿Estás seguro de eliminar este día maestro?')) return;
    try {
      const response = await fetch(`${API_BASE}/api/dias-maestro/${id}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      if (!response.ok) {
        throw new Error('Error al eliminar día maestro');
      }
      setDias(dias.filter(d => d.id !== id));
    } catch (err) {
      setError('NETWORK_ERROR');
    }
  };

  const startEdit = (dia: DiaMaestro) => {
    setEditing(dia);
    setForm(dia);
    setShowForm(true);
  };

  const cancelEdit = () => {
    setEditing(null);
    setForm({
      mesMaestro: { id: 0, nombre: '', mesNumero: 0 },
      diaNumero: 1,
      tipoDia: 'NORMAL',
      lecturaBiblica: '',
      versiculoDiario: ''
    });
    setShowForm(false);
  };

  return (
    <div className="card">
        <h2>Días Maestro</h2>
        {loading && <p>Cargando...</p>}

        <div style={{ marginBottom: '20px' }}>
          <label style={{ fontWeight: 'bold', marginRight: '10px' }}>Seleccionar Diario Anual:</label>
          <select onChange={handleDiarioChange} value={selectedDiario?.id || ''}>
            <option value="">Selecciona un diario</option>
            {diarios.map(diario => (
              <option key={diario.id} value={diario.id}>{diario.titulo} ({diario.anio})</option>
            ))}
          </select>
        </div>

        {selectedDiario && (
          <>
            {!editing && <button className="btn" onClick={() => setShowForm(true)}>Crear Nuevo Día Maestro</button>}

            {showForm && (
              <div style={{
                marginTop: '20px',
                padding: '20px',
                border: '1px solid #e0e0e0',
                borderRadius: '8px',
                background: '#f9f9f9'
              }}>
                <h3>{editing ? 'Editar Día Maestro' : 'Crear Nuevo Día Maestro'}</h3>

                <div style={{ marginBottom: '10px' }}>
                  <label>Mes Maestro:</label>
                  <select
                    value={form.mesMaestro.id}
                    onChange={(e) => {
                      const mesId = parseInt(e.target.value);
                      const mes = meses.find(m => m.id === mesId);
                      setForm({ ...form, mesMaestro: mes || { id: 0, nombre: '', mesNumero: 0 } });
                    }}
                    style={{ width: '100%', padding: '8px' }}
                  >
                    <option value={0}>Selecciona un mes</option>
                    {meses.map(mes => (
                      <option key={mes.id} value={mes.id}>{mes.nombre} (Mes {mes.mesNumero})</option>
                    ))}
                  </select>
                </div>

                <div style={{ marginBottom: '10px' }}>
                  <label>Día Número:</label>
                  <input
                    type="number"
                    value={form.diaNumero}
                    onChange={(e) => setForm({ ...form, diaNumero: parseInt(e.target.value) })}
                    style={{ width: '100%', padding: '8px' }}
                  />
                </div>

                <div style={{ marginBottom: '10px' }}>
                  <label>Tipo de Día:</label>
                  <select
                    value={form.tipoDia}
                    onChange={(e) => setForm({ ...form, tipoDia: e.target.value as 'NORMAL' | 'DOMINGO' })}
                    style={{ width: '100%', padding: '8px' }}
                  >
                    <option value="NORMAL">Normal</option>
                    <option value="DOMINGO">Domingo</option>
                  </select>
                </div>

                <div style={{ marginBottom: '10px' }}>
                  <label>Lectura Bíblica:</label>
                  <input
                    type="text"
                    value={form.lecturaBiblica}
                    onChange={(e) => setForm({ ...form, lecturaBiblica: e.target.value })}
                    style={{ width: '100%', padding: '8px' }}
                  />
                </div>

                <div style={{ marginBottom: '10px' }}>
                  <label>Versículo Diario:</label>
                  <input
                    type="text"
                    value={form.versiculoDiario}
                    onChange={(e) => setForm({ ...form, versiculoDiario: e.target.value })}
                    style={{ width: '100%', padding: '8px' }}
                  />
                </div>

                <div style={{ display: 'flex', gap: '10px' }}>
                  {!editing && <button className="btn" onClick={handleCreate}>Crear</button>}
                  {editing && <button className="btn" onClick={handleUpdate}>Actualizar</button>}
                  <button className="btn" onClick={cancelEdit}>Cancelar</button>
                </div>
              </div>
            )}

            <h3>Lista de Días Maestro</h3>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: '10px' }}>
              {dias.map(dia => (
                <div key={dia.id} style={{ border: '1px solid #ccc', padding: '10px', cursor: 'pointer' }} onClick={() => startEdit(dia)}>
                  <p><strong>Mes:</strong> {dia.mesMaestro.nombre} (Día {dia.diaNumero})</p>
                  <p><strong>Tipo:</strong> {dia.tipoDia}</p>
                  <p><strong>Lectura:</strong> {dia.lecturaBiblica}</p>
                  <p><strong>Versículo:</strong> {dia.versiculoDiario}</p>
                  <button onClick={(e) => { e.stopPropagation(); handleDelete(dia.id!); }} style={{ background: 'red', color: 'white', border: 'none', padding: '5px' }}>Eliminar</button>
                </div>
              ))}
            </div>
          </>
        )}
      </div>
  );
};

export default DiaMaestro;