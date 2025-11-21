import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { API_BASE_URL } from '../constants/api';

interface VerseData {
  reference: string;
  text: string;
  translation_id: string;
  translation_name: string;
}

interface Translation {
  id: string;
  name: string;
  language: string;
}

const Biblia: React.FC = () => {
  const [searchQuery, setSearchQuery] = useState('');
  const [verse, setVerse] = useState<VerseData | null>(null);
  const [loading, setLoading] = useState(false);
  const [translations, setTranslations] = useState<Translation[]>([]);
  const [selectedTranslation, setSelectedTranslation] = useState('rvr1960');
  const [isPlaying, setIsPlaying] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');

  useEffect(() => {
    fetchTranslations();
  }, []);

  const fetchTranslations = async () => {
    try {
      const response = await axios.get(`${API_BASE_URL}/api/bible/translations`);
      setTranslations(response.data);
    } catch (error) {
      console.error('Error fetching translations:', error);
      // Fallback a traducciones por defecto
      setTranslations([
        { id: 'rvr1960', name: 'Reina Valera 1960', language: 'es' },
        { id: 'rv', name: 'Reina Valera Antigua', language: 'es' },
        { id: 'nvi', name: 'Nueva Versión Internacional', language: 'es' },
        { id: 'lbla', name: 'La Biblia de las Américas', language: 'es' },
        { id: 'kjv', name: 'King James Version', language: 'en' },
        { id: 'esv', name: 'English Standard Version', language: 'en' }
      ]);
    }
  };

  const searchVerse = async () => {
    if (!searchQuery.trim()) return;

    setLoading(true);
    setErrorMessage('');
    try {
      const response = await axios.get(`${API_BASE_URL}/api/bible/verse/${searchQuery}`, {
        params: { translation: selectedTranslation }
      });
      setVerse(response.data);
    } catch (error) {
      console.error('Error fetching verse:', error);
      setErrorMessage('Versículo no encontrado. Intenta con un formato como "Juan 3:16"');
    } finally {
      setLoading(false);
    }
  };

  const speakVerse = (text: string) => {
    if ('speechSynthesis' in window) {
      if (isPlaying) {
        speechSynthesis.cancel();
        setIsPlaying(false);
        return;
      }

      const utterance = new SpeechSynthesisUtterance(text);
      utterance.lang = selectedTranslation.startsWith('rvr') || selectedTranslation.startsWith('rv') ||
                      selectedTranslation.startsWith('nvi') || selectedTranslation.startsWith('lbla')
                      ? 'es-ES' : 'en-US';

      utterance.onend = () => setIsPlaying(false);
      utterance.onerror = () => setIsPlaying(false);

      speechSynthesis.speak(utterance);
      setIsPlaying(true);
    } else {
      alert('Tu navegador no soporta síntesis de voz');
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      searchVerse();
    }
  };

  return (
    <div className="app-container">
      <div className="card">
        <h2>📖 Biblia</h2>

        <div style={{ marginBottom: '20px' }}>
          <div style={{ display: 'flex', gap: '10px', marginBottom: '10px' }}>
            <input
              className="input"
              type="text"
              placeholder="Buscar versículo (ej: Juan 3:16)"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              onKeyPress={handleKeyPress}
              style={{ flex: 1 }}
            />
            <select
              className="input"
              value={selectedTranslation}
              onChange={(e) => setSelectedTranslation(e.target.value)}
              style={{ width: '200px' }}
            >
              {translations.map(t => (
                <option key={t.id} value={t.id}>
                  {t.name} ({t.language.toUpperCase()})
                </option>
              ))}
            </select>
            <button className="btn" onClick={searchVerse} disabled={loading}>
              {loading ? 'Buscando...' : 'Buscar'}
            </button>
          </div>
          {errorMessage && <p style={{color: 'red', marginTop: '10px'}}>{errorMessage}</p>}
        </div>

        {verse && (
          <div className="verse-result" style={{
            border: '1px solid #ddd',
            borderRadius: '8px',
            padding: '20px',
            backgroundColor: '#f9f9f9'
          }}>
            <h3>{verse.reference}</h3>
            <p style={{ fontSize: '18px', lineHeight: '1.6', marginBottom: '15px' }}>
              {verse.text}
            </p>
            <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
              <small style={{ color: '#666' }}>
                {verse.translation_name}
              </small>
              <button
                className="btn"
                onClick={() => speakVerse(verse.text)}
                style={{
                  backgroundColor: isPlaying ? '#ff4444' : '#4CAF50',
                  color: 'white'
                }}
              >
                {isPlaying ? '⏹️ Detener' : '🔊 Escuchar'}
              </button>
            </div>
          </div>
        )}

        <div style={{ marginTop: '30px', padding: '20px', backgroundColor: '#f0f8ff', borderRadius: '8px' }}>
          <h4>💡 Consejos de búsqueda:</h4>
          <ul style={{ margin: 0, paddingLeft: '20px' }}>
            <li>Usa el formato: Libro Capítulo:Versículo (ej: Génesis 1:1)</li>
            <li>Puedes buscar rangos: Juan 3:16-20</li>
            <li>Libros completos: Juan 3</li>
            <li>Múltiples versículos: Juan 3:16,17,18</li>
          </ul>
        </div>
      </div>
    </div>
  );
};

export default Biblia;