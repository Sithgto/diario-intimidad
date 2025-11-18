import React, { useEffect, useState, useContext, ChangeEvent } from 'react';
import { AuthContext } from '../contexts/AuthContext';
import { useError } from '../contexts/ErrorContext';

interface DiarioAnual {
  id?: number;
  anio: number;
  titulo: string;
  portadaUrl: string;
  temaPrincipal: string;
  logoUrl: string;
  status: string;
  createdAt?: string;
  updatedAt?: string;
}

const DiarioAnual: React.FC = () => {
  const [diarios, setDiarios] = useState<DiarioAnual[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [editing, setEditing] = useState<DiarioAnual | null>(null);
  const [showForm, setShowForm] = useState<boolean>(false);
  const { setError } = useError();
  const [form, setForm] = useState<DiarioAnual>({
    anio: new Date().getFullYear(),
    titulo: '',
    portadaUrl: '',
    temaPrincipal: '',
    logoUrl: '',
    status: 'Activo'
  });
  const [originalForm, setOriginalForm] = useState<DiarioAnual | null>(null);
  const [showAll, setShowAll] = useState<boolean>(false);
  const [uploadingPortada, setUploadingPortada] = useState<boolean>(false);
  const [uploadingLogo, setUploadingLogo] = useState<boolean>(false);
  const { token } = useContext(AuthContext)!;

  const uploadFile = async (file: File): Promise<string> => {
    const formData = new FormData();
    formData.append('file', file);
    const response = await fetch('http://localhost:8085/api/diarios-anuales/upload', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`
      },
      body: formData
    });
    if (!response.ok) throw new Error('Error al subir archivo');
    return await response.text();
  };

  const fetchDiarios = async () => {
    setLoading(true);
    try {
      const response = await fetch('http://localhost:8085/api/diarios-anuales', {
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

  useEffect(() => {
    fetchDiarios();
  }, [token]);

  const handlePortadaChange = async (e: ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setUploadingPortada(true);
      try {
        const url = await uploadFile(file);
        setForm({ ...form, portadaUrl: url });
      } catch (err) {
        setError('NETWORK_ERROR');
      } finally {
        setUploadingPortada(false);
      }
    }
  };

  const handleLogoChange = async (e: ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setUploadingLogo(true);
      try {
        const url = await uploadFile(file);
        setForm({ ...form, logoUrl: url });
      } catch (err) {
        setError('NETWORK_ERROR');
      } finally {
        setUploadingLogo(false);
      }
    }
  };

  const handleCreate = async () => {
    if (!form.anio || !form.titulo.trim() || !form.temaPrincipal.trim() || !form.status.trim()) {
      setError('VALIDATION_REQUIRED');
      return;
    }
    try {
      const response = await fetch('http://localhost:8085/api/diarios-anuales', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(form)
      });
      if (!response.ok) {
        throw new Error('Error al crear diario anual');
      }
      const newDiario: DiarioAnual = await response.json();
      setDiarios([...diarios, newDiario]);
      setForm({ anio: new Date().getFullYear(), titulo: '', portadaUrl: '', temaPrincipal: '', logoUrl: '', status: 'Activo' });
      setShowForm(false);
    } catch (err) {
      setError('NETWORK_ERROR');
    }
  };

  const handleUpdate = async () => {
    if (!editing) return;
    if (!form.anio || !form.titulo.trim() || !form.temaPrincipal.trim() || !form.status.trim()) {
      setError('VALIDATION_REQUIRED');
      return;
    }
    try {
      const response = await fetch(`http://localhost:8085/api/diarios-anuales/${editing.id}`, {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(form)
      });
      if (!response.ok) {
        throw new Error('Error al actualizar diario anual');
      }
      const updatedDiario: DiarioAnual = await response.json();
      setDiarios(diarios.map((d: DiarioAnual) => d.id === editing.id ? updatedDiario : d));
      setEditing(null);
      setOriginalForm(null);
      setForm({ anio: new Date().getFullYear(), titulo: '', portadaUrl: '', temaPrincipal: '', logoUrl: '', status: 'Activo' });
      setShowForm(false);
    } catch (err) {
      setError('NETWORK_ERROR');
    }
  };

  const handleDelete = async (id: number) => {
    // eslint-disable-next-line no-restricted-globals
    if (!confirm('¿Estás seguro de eliminar este diario anual?')) return;
    try {
      const response = await fetch(`http://localhost:8085/api/diarios-anuales/${id}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      if (!response.ok) {
        throw new Error('Error al eliminar diario anual');
      }
      setDiarios(diarios.filter((d: DiarioAnual) => d.id !== id));
    } catch (err) {
      setError('NETWORK_ERROR');
    }
  };

  const startEdit = (diario: DiarioAnual) => {
    setEditing(diario);
    setForm(diario);
    setOriginalForm(diario);
    setShowForm(true);
  };

  const cancelEdit = () => {
    setEditing(null);
    setForm({ anio: new Date().getFullYear(), titulo: '', portadaUrl: '', temaPrincipal: '', logoUrl: '', status: 'Activo' });
    setOriginalForm(null);
    setShowForm(false);
  };

  const hasChanges = () => {
    return originalForm && JSON.stringify(form) !== JSON.stringify(originalForm);
  };

  return (
    <div className="app-container">
      <div className="card">
        <h2>Diarios Anuales</h2>
        {loading && <p>Cargando...</p>}

        {!editing && <button className="btn" onClick={() => setShowForm(true)}>Crear Nuevo Diario</button>}

        {/* Formulario para crear/editar */}
        {showForm && (
        <div style={{ marginBottom: '20px' }}>
          <h3>{editing ? 'Editar Diario Anual' : 'Crear Nuevo Diario Anual'}</h3>
          <input
            className="input"
            type="number"
            placeholder="Ejemplo: 2023"
            value={form.anio}
            onChange={(e: ChangeEvent<HTMLInputElement>) => setForm({ ...form, anio: parseInt(e.target.value) })}
            required
          />
          <input
            className="input"
            type="text"
            placeholder="Ejemplo: Mi Diario 2023"
            value={form.titulo}
            onChange={(e: ChangeEvent<HTMLInputElement>) => setForm({ ...form, titulo: e.target.value })}
            required
          />
          <div style={{ display: 'flex', gap: '20px', alignItems: 'flex-start' }}>
            <div>
              <label>Carátula:</label>
              <input
                className="input"
                type="file"
                accept="image/*"
                onChange={handlePortadaChange}
              />
              <img src={form.portadaUrl ? `http://localhost:8085${form.portadaUrl}` : '/images/default-cover.jpg'} alt="Carátula" style={{ maxWidth: '200px', marginTop: '10px' }} />
              {uploadingPortada && <p>Subiendo imagen...</p>}
            </div>
            <div>
              <label>Logo:</label>
              <input
                className="input"
                type="file"
                accept="image/*"
                onChange={handleLogoChange}
              />
              <img src={form.logoUrl ? `http://localhost:8085${form.logoUrl}` : '/images/default-logo.jpg'} alt="Logo" style={{ maxWidth: '200px', marginTop: '10px' }} />
              {uploadingLogo && <p>Subiendo imagen...</p>}
            </div>
          </div>
          <input
            className="input"
            type="text"
            placeholder="Ejemplo: Reflexiones Personales"
            value={form.temaPrincipal}
            onChange={(e: ChangeEvent<HTMLInputElement>) => setForm({ ...form, temaPrincipal: e.target.value })}
            required
          />
          <select
            className="input"
            value={form.status}
            onChange={(e: ChangeEvent<HTMLSelectElement>) => setForm({ ...form, status: e.target.value })}
            required
          >
            <option value="Desarrollo">Desarrollo</option>
            <option value="Descatalogado">Descatalogado</option>
            <option value="Activo">Activo</option>
          </select>
          {editing && (
            <div>
              <p>Creado: {form.createdAt ? new Date(form.createdAt).toLocaleString() : ''}</p>
              <p>Modificado: {form.updatedAt ? new Date(form.updatedAt).toLocaleString() : ''}</p>
            </div>
          )}
          {!editing && <button className="btn" onClick={handleCreate}>Crear</button>}
          {editing && hasChanges() && <button className="btn" onClick={handleUpdate} disabled={uploadingPortada || uploadingLogo}>Actualizar</button>}
          {editing && <button className="btn" onClick={cancelEdit}>Cancelar</button>}
        </div>
        )}

        {/* Lista de diarios */}
        {!editing && (
          <>
            <h3>Lista de Diarios Anuales</h3>
            <label>
              <input
                type="checkbox"
                checked={showAll}
                onChange={(e: ChangeEvent<HTMLInputElement>) => setShowAll(e.target.checked)}
              />
              Mostrar todos los diarios
            </label>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(250px, 1fr))', gap: '20px' }}>
              {diarios.filter((diario: DiarioAnual) => showAll || diario.status === 'Activo').map((diario: DiarioAnual) => (
                <div key={diario.id} className="diario-card" style={{ border: '1px solid #ccc', padding: '10px', cursor: 'pointer' }} onClick={() => startEdit(diario)}>
                  <img src={diario.portadaUrl ? `http://localhost:8085${diario.portadaUrl}` : '/images/default-cover.jpg'} alt="Carátula" style={{ width: '100px', height: '150px', objectFit: 'cover' }} />
                  <h4>{diario.titulo}</h4>
                  <p>Año: {diario.anio}</p>
                  <p>Tema: {diario.temaPrincipal}</p>
                  <p>Status: {diario.status}</p>
                  <p>Creado: {diario.createdAt ? new Date(diario.createdAt).toLocaleString() : ''}</p>
                  <p>Modificado: {diario.updatedAt ? new Date(diario.updatedAt).toLocaleString() : ''}</p>
                </div>
              ))}
            </div>
          </>
        )}
      </div>
    </div>
  );
};

export default DiarioAnual;