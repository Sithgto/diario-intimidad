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
    logoUrl: ''
  });
  const [selectedPortadaFile, setSelectedPortadaFile] = useState<File | null>(null);
  const [selectedLogoFile, setSelectedLogoFile] = useState<File | null>(null);
  const [portadaPreview, setPortadaPreview] = useState<string>('');
  const [logoPreview, setLogoPreview] = useState<string>('');
  const [originalForm, setOriginalForm] = useState<DiarioAnual | null>(null);
  const { token } = useContext(AuthContext)!;

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

  const handlePortadaSelect = (e: ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setSelectedPortadaFile(file);
      setPortadaPreview(URL.createObjectURL(file));
    }
  };

  const handlePortadaUpload = async () => {
    if (!selectedPortadaFile) return;
    const formData = new FormData();
    formData.append('file', selectedPortadaFile);
    try {
      const response = await fetch('http://localhost:8085/api/diarios-anuales/upload', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`
        },
        body: formData
      });
      if (!response.ok) throw new Error('Error al subir la carátula');
      const data = await response.json();
      setForm({ ...form, portadaUrl: data.url });
      setSelectedPortadaFile(null);
      setPortadaPreview('');
    } catch (err) {
      setError('NETWORK_ERROR');
    }
  };

  const handleLogoSelect = (e: ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setSelectedLogoFile(file);
      setLogoPreview(URL.createObjectURL(file));
    }
  };

  const handleLogoUpload = async () => {
    if (!selectedLogoFile) return;
    const formData = new FormData();
    formData.append('file', selectedLogoFile);
    try {
      const response = await fetch('http://localhost:8085/api/diarios-anuales/upload', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`
        },
        body: formData
      });
      if (!response.ok) throw new Error('Error al subir el logo');
      const data = await response.json();
      setForm({ ...form, logoUrl: data.url });
      setSelectedLogoFile(null);
      setLogoPreview('');
    } catch (err) {
      setError('NETWORK_ERROR');
    }
  };

  const handleCreate = async () => {
    if (!form.anio || !form.titulo.trim() || !form.temaPrincipal.trim()) {
      setError('VALIDATION_REQUIRED');
      return;
    }
    try {
      if (selectedPortadaFile) {
        await handlePortadaUpload();
      }
      if (selectedLogoFile) {
        await handleLogoUpload();
      }
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
      setForm({ anio: new Date().getFullYear(), titulo: '', portadaUrl: '', temaPrincipal: '', logoUrl: '' });
      setSelectedPortadaFile(null);
      setSelectedLogoFile(null);
      setPortadaPreview('');
      setLogoPreview('');
      setShowForm(false);
    } catch (err) {
      setError('NETWORK_ERROR');
    }
  };

  const handleUpdate = async () => {
    if (!editing) return;
    if (!form.anio || !form.titulo.trim() || !form.temaPrincipal.trim()) {
      setError('VALIDATION_REQUIRED');
      return;
    }
    try {
      if (selectedPortadaFile) {
        await handlePortadaUpload();
      }
      if (selectedLogoFile) {
        await handleLogoUpload();
      }
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
      setForm({ anio: new Date().getFullYear(), titulo: '', portadaUrl: '', temaPrincipal: '', logoUrl: '' });
      setSelectedPortadaFile(null);
      setSelectedLogoFile(null);
      setPortadaPreview('');
      setLogoPreview('');
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
    setForm({ anio: new Date().getFullYear(), titulo: '', portadaUrl: '', temaPrincipal: '', logoUrl: '' });
    setSelectedPortadaFile(null);
    setSelectedLogoFile(null);
    setPortadaPreview('');
    setLogoPreview('');
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

        <button className="btn" onClick={() => setShowForm(true)}>Crear Nuevo Diario</button>

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
          <label>Carátula:</label>
          <input
            className="input"
            type="file"
            accept="image/*"
            onChange={handlePortadaSelect}
          />
          {portadaPreview && <img src={portadaPreview} alt="Previsualización Carátula" style={{ maxWidth: '200px', marginTop: '10px' }} />}
          {form.portadaUrl && <img src={`http://localhost:8085${form.portadaUrl}`} alt="Carátula" style={{ maxWidth: '200px', marginTop: '10px' }} />}
          <input
            className="input"
            type="text"
            placeholder="Ejemplo: Reflexiones Personales"
            value={form.temaPrincipal}
            onChange={(e: ChangeEvent<HTMLInputElement>) => setForm({ ...form, temaPrincipal: e.target.value })}
            required
          />
          <label>Logo:</label>
          <input
            className="input"
            type="file"
            accept="image/*"
            onChange={handleLogoSelect}
          />
          {logoPreview && <img src={logoPreview} alt="Previsualización Logo" style={{ maxWidth: '200px', marginTop: '10px' }} />}
          {form.logoUrl && <img src={`http://localhost:8085${form.logoUrl}`} alt="Logo" style={{ maxWidth: '200px', marginTop: '10px' }} />}
          {!editing && <button className="btn" onClick={handleCreate}>Crear</button>}
          {editing && hasChanges() && <button className="btn" onClick={handleUpdate}>Actualizar</button>}
          {editing && <button className="btn" onClick={cancelEdit}>Cancelar</button>}
        </div>
        )}

        {/* Lista de diarios */}
        {!editing && (
          <>
            <h3>Lista de Diarios Anuales</h3>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(250px, 1fr))', gap: '20px' }}>
              {diarios.map((diario: DiarioAnual) => (
                <div key={diario.id} className="diario-card" style={{ border: '1px solid #ccc', padding: '10px', cursor: 'pointer' }} onClick={() => startEdit(diario)}>
                  <img src={diario.portadaUrl ? `http://localhost:8085${diario.portadaUrl}` : '/images/default-cover.jpg'} alt="Carátula" style={{ width: '100px', height: '150px', objectFit: 'cover' }} />
                  <h4>{diario.titulo}</h4>
                  <p>Año: {diario.anio}</p>
                  <p>Tema: {diario.temaPrincipal}</p>
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