package com.diario_intimidad.dto;

import java.util.List;

public class DailyEntryRequest {
    private String fecha;
    private List<CampoValor> valoresCampo;

    public static class CampoValor {
        private Long campoDiarioId;
        private String valorTexto;
        private String valorAudioUrl;

        // Getters and setters
        public Long getCampoDiarioId() { return campoDiarioId; }
        public void setCampoDiarioId(Long campoDiarioId) { this.campoDiarioId = campoDiarioId; }

        public String getValorTexto() { return valorTexto; }
        public void setValorTexto(String valorTexto) { this.valorTexto = valorTexto; }

        public String getValorAudioUrl() { return valorAudioUrl; }
        public void setValorAudioUrl(String valorAudioUrl) { this.valorAudioUrl = valorAudioUrl; }
    }

    // Getters and setters
    public String getFecha() { return fecha; }
    public void setFecha(String fecha) { this.fecha = fecha; }

    public List<CampoValor> getValoresCampo() { return valoresCampo; }
    public void setValoresCampo(List<CampoValor> valoresCampo) { this.valoresCampo = valoresCampo; }
}