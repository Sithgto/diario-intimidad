import React, { useEffect, useState, useContext, ChangeEvent } from 'react';
import { AuthContext } from '../contexts/AuthContext';
import { useError } from '../contexts/ErrorContext';

const API_BASE = 'http://localhost:8085';

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
  portadaFile?: File | null;
  logoFile?: File | null;
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
    status: 'Activo',
    portadaFile: null,
    logoFile: null
  });
  const [originalForm, setOriginalForm] = useState<DiarioAnual | null>(null);
  const [showAll, setShowAll] = useState<boolean>(false);
  const [uploadingPortada, setUploadingPortada] = useState<boolean>(false);
  const [uploadingLogo, setUploadingLogo] = useState<boolean>(false);
  const { token } = useContext(AuthContext)!;

  const uploadFile = async (file: File): Promise<string> => {
    const formData = new FormData();
    formData.append('file', file);
    const response = await fetch(`${API_BASE}/api/diarios-anuales/upload`, {
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

  useEffect(() => {
    fetchDiarios();
  }, [token]);

  useEffect(() => {
    const portadaUrl = form.portadaUrl;
    const logoUrl = form.logoUrl;

    return () => {
      if (portadaUrl && portadaUrl.startsWith('blob:')) {
        URL.revokeObjectURL(portadaUrl);
      }
      if (logoUrl && logoUrl.startsWith('blob:')) {
        URL.revokeObjectURL(logoUrl);
      }
    };
  }, [form.portadaUrl, form.logoUrl]);

  const handlePortadaChange = (e: ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const previewUrl = URL.createObjectURL(file);
      setForm({ ...form, portadaFile: file, portadaUrl: previewUrl });
    }
  };

  const handleLogoChange = (e: ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const previewUrl = URL.createObjectURL(file);
      setForm({ ...form, logoFile: file, logoUrl: previewUrl });
    }
  };

  const handleCreate = async () => {
    if (!form.anio || !form.titulo.trim() || !form.temaPrincipal.trim() || !form.status.trim()) {
      setError('VALIDATION_REQUIRED');
      return;
    }
    try {
      let portadaUrl = form.portadaUrl;
      let logoUrl = form.logoUrl;
      if (form.portadaFile) {
        portadaUrl = await uploadFile(form.portadaFile);
      }
      if (form.logoFile) {
        logoUrl = await uploadFile(form.logoFile);
      }
      const diarioData = { ...form, portadaUrl, logoUrl };
      const response = await fetch(`${API_BASE}/api/diarios-anuales`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(diarioData)
      });
      if (!response.ok) {
        throw new Error('Error al crear diario anual');
      }
      const newDiario: DiarioAnual = await response.json();
      setDiarios([...diarios, newDiario]);
      setForm({ anio: new Date().getFullYear(), titulo: '', portadaUrl: '', temaPrincipal: '', logoUrl: '', status: 'Activo', portadaFile: null, logoFile: null });
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
      let portadaUrl = form.portadaUrl;
      let logoUrl = form.logoUrl;
      if (form.portadaFile) {
        portadaUrl = await uploadFile(form.portadaFile);
      }
      if (form.logoFile) {
        logoUrl = await uploadFile(form.logoFile);
      }
      const diarioData = { ...form, portadaUrl, logoUrl };
      const response = await fetch(`${API_BASE}/api/diarios-anuales/${editing.id}`, {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(diarioData)
      });
      if (!response.ok) {
        throw new Error('Error al actualizar diario anual');
      }
      const updatedDiario: DiarioAnual = await response.json();
      setDiarios(diarios.map((d: DiarioAnual) => d.id === editing.id ? updatedDiario : d));
      setEditing(null);
      setOriginalForm(null);
      setForm({ anio: new Date().getFullYear(), titulo: '', portadaUrl: '', temaPrincipal: '', logoUrl: '', status: 'Activo', portadaFile: null, logoFile: null });
      setShowForm(false);
    } catch (err) {
      setError('NETWORK_ERROR');
    }
  };

  const handleDelete = async (id: number) => {
    // eslint-disable-next-line no-restricted-globals
    if (!confirm('¿Estás seguro de eliminar este diario anual?')) return;
    try {
      const response = await fetch(`${API_BASE}/api/diarios-anuales/${id}`, {
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
          <div style={{
            marginTop: '-10px',
            marginBottom: '20px',
            padding: '30px',
            border: '1px solid #e0e0e0',
            borderRadius: '12px',
            background: 'linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%)',
            boxShadow: '0 8px 32px rgba(0,0,0,0.1)',
            transition: 'all 0.3s ease',
            maxWidth: '1800px',
            marginLeft: 'auto',
            marginRight: 'auto'
          }}>
            <h3 style={{
              marginBottom: '20px',
              color: '#333',
              fontSize: '1.5em',
              textAlign: 'center',
              textShadow: '1px 1px 2px rgba(0,0,0,0.1)'
            }}>
              {editing ? 'Diario Anual' : 'Crear Nuevo Diario Anual'}
            </h3>

            {/* Header con Creado y Modificado */}
            {editing && (
              <div style={{
                display: 'flex',
                justifyContent: 'space-between',
                marginBottom: '20px',
                padding: '10px',
                background: 'rgba(255,255,255,0.8)',
                borderRadius: '8px',
                fontSize: '0.9em'
              }}>
                <span><strong>Creado:</strong> {form.createdAt ? new Date(form.createdAt).toLocaleString() : 'N/A'}</span>
                <span><strong>Modificado:</strong> {form.updatedAt ? new Date(form.updatedAt).toLocaleString() : 'N/A'}</span>
              </div>
            )}

            {/* Año y Título */}
            <div style={{
              display: 'grid',
              gridTemplateColumns: 'auto 1fr',
              gap: '15px',
              alignItems: 'center',
              marginBottom: '20px'
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <label style={{ fontWeight: 'bold', color: '#555' }}>Año:</label>
                <input
                  type="number"
                  maxLength={6}
                  style={{
                    width: '80px',
                    padding: '8px',
                    border: '1px solid #ccc',
                    borderRadius: '4px',
                    fontSize: '1em',
                    transition: 'border-color 0.3s'
                  }}
                  value={form.anio}
                  onChange={(e: ChangeEvent<HTMLInputElement>) => setForm({ ...form, anio: parseInt(e.target.value) })}
                  required
                />
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <label style={{ fontWeight: 'bold', color: '#555' }}>Título:</label>
                <input
                  type="text"
                  placeholder="Ejemplo: Mi Diario 2023"
                  style={{
                    flex: 1,
                    padding: '8px',
                    border: '1px solid #ccc',
                    borderRadius: '4px',
                    fontSize: '1em',
                    transition: 'border-color 0.3s'
                  }}
                  value={form.titulo}
                  onChange={(e: ChangeEvent<HTMLInputElement>) => setForm({ ...form, titulo: e.target.value })}
                  required
                />
              </div>
            </div>

            {/* Carátula y Logo */}
            <div style={{
              display: 'flex',
              gap: '20px',
              justifyContent: 'center',
              marginBottom: '20px'
            }}>
              <div style={{ position: 'relative', textAlign: 'center' }}>
                <label style={{ display: 'block', marginBottom: '10px', fontWeight: 'bold', color: '#555' }}>Carátula</label>
                <div style={{
                  position: 'relative',
                  width: '150px',
                  height: '200px',
                  border: '2px dashed #ccc',
                  borderRadius: '8px',
                  overflow: 'hidden',
                  cursor: 'pointer',
                  transition: 'border-color 0.3s'
                }}
                onClick={() => document.getElementById('portada-input')?.click()}
                >
                  <img
                    src={form.portadaUrl ? form.portadaUrl : '/images/default-cover.jpg'}
                    alt="Carátula"
                    style={{
                      width: '100%',
                      height: '100%',
                      objectFit: 'cover',
                      transition: 'transform 0.3s'
                    }}
                  />
                  <div style={{
                    position: 'absolute',
                    top: '50%',
                    left: '50%',
                    transform: 'translate(-50%, -50%)',
                    background: 'rgba(0,0,0,0.7)',
                    color: 'white',
                    padding: '5px 10px',
                    borderRadius: '50%',
                    fontSize: '1.5em',
                    opacity: 0,
                    transition: 'opacity 0.3s'
                  }}
                  onMouseEnter={(e) => e.currentTarget.style.opacity = '1'}
                  onMouseLeave={(e) => e.currentTarget.style.opacity = '0'}
                  >
                    📷
                  </div>
                </div>
                <input
                  id="portada-input"
                  type="file"
                  accept="image/*"
                  onChange={handlePortadaChange}
                  style={{ display: 'none' }}
                />
                {uploadingPortada && <p style={{ marginTop: '10px', color: '#007bff' }}>Subiendo imagen...</p>}
              </div>

              <div style={{ position: 'relative', textAlign: 'center' }}>
                <label style={{ display: 'block', marginBottom: '10px', fontWeight: 'bold', color: '#555' }}>Logo</label>
                <div style={{
                  position: 'relative',
                  width: '200px',
                  height: '200px',
                  border: '2px dashed #ccc',
                  borderRadius: '8px',
                  overflow: 'hidden',
                  cursor: 'pointer',
                  transition: 'border-color 0.3s'
                }}
                onClick={() => document.getElementById('logo-input')?.click()}
                >
                  <img
                    src={form.logoUrl ? form.logoUrl : '/images/default-logo.jpg'}
                    alt="Logo"
                    style={{
                      width: '100%',
                      height: '100%',
                      objectFit: 'contain',
                      transition: 'transform 0.3s'
                    }}
                  />
                  <div style={{
                    position: 'absolute',
                    top: '50%',
                    left: '50%',
                    transform: 'translate(-50%, -50%)',
                    background: 'rgba(0,0,0,0.7)',
                    color: 'white',
                    padding: '5px 10px',
                    borderRadius: '50%',
                    fontSize: '1.5em',
                    opacity: 0,
                    transition: 'opacity 0.3s'
                  }}
                  onMouseEnter={(e) => e.currentTarget.style.opacity = '1'}
                  onMouseLeave={(e) => e.currentTarget.style.opacity = '0'}
                  >
                    📷
                  </div>
                </div>
                <input
                  id="logo-input"
                  type="file"
                  accept="image/*"
                  onChange={handleLogoChange}
                  style={{ display: 'none' }}
                />
                {uploadingLogo && <p style={{ marginTop: '10px', color: '#007bff' }}>Subiendo imagen...</p>}
              </div>
            </div>

            {/* Tema */}
            <div style={{ marginBottom: '20px' }}>
              <label style={{ display: 'block', marginBottom: '10px', fontWeight: 'bold', color: '#555' }}>Tema / Lema:</label>
              <textarea
                placeholder="Ejemplo: Reflexiones Personales&#10;&#10;Lema: 'Crecer cada día'"
                style={{
                  width: '100%',
                  height: '100px',
                  padding: '10px',
                  border: '1px solid #ccc',
                  borderRadius: '4px',
                  fontSize: '1em',
                  resize: 'vertical',
                  transition: 'border-color 0.3s'
                }}
                value={form.temaPrincipal}
                onChange={(e: ChangeEvent<HTMLTextAreaElement>) => setForm({ ...form, temaPrincipal: e.target.value })}
                required
              />
            </div>

            {/* Status */}
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '20px' }}>
              <label style={{ fontWeight: 'bold', color: '#555' }}>Activo:</label>
              <select
                style={{
                  padding: '8px',
                  border: '1px solid #ccc',
                  borderRadius: '4px',
                  fontSize: '1em',
                  minWidth: '120px',
                  transition: 'border-color 0.3s'
                }}
                value={form.status}
                onChange={(e: ChangeEvent<HTMLSelectElement>) => setForm({ ...form, status: e.target.value })}
                required
              >
                <option value="Desarrollo">Desarrollo</option>
                <option value="Descatalogado">Descatalogado</option>
                <option value="Activo">Activo</option>
              </select>
            </div>

            {/* Botones */}
            <div style={{ display: 'flex', gap: '10px', justifyContent: 'center' }}>
              {!editing && <button className="btn" onClick={handleCreate} style={{ background: '#28a745', color: 'white', padding: '10px 20px', border: 'none', borderRadius: '5px', cursor: 'pointer' }}>Crear</button>}
              {editing && hasChanges() && <button className="btn" onClick={handleUpdate} disabled={uploadingPortada || uploadingLogo} style={{ background: '#007bff', color: 'white', padding: '10px 20px', border: 'none', borderRadius: '5px', cursor: 'pointer' }}>Actualizar</button>}
              {editing && <button className="btn" onClick={cancelEdit} style={{ background: '#6c757d', color: 'white', padding: '10px 20px', border: 'none', borderRadius: '5px', cursor: 'pointer' }}>Cancelar</button>}
            </div>
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
                  <img src={diario.portadaUrl ? diario.portadaUrl : '/images/default-cover.jpg'} alt="Carátula" style={{ width: '100px', height: '150px', objectFit: 'cover' }} />
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