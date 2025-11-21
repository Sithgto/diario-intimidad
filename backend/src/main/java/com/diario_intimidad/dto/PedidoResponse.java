package com.diario_intimidad.dto;

import java.time.LocalDateTime;

public class PedidoResponse {

    private Long id;
    private Long diarioId;
    private String tituloDiario;
    private String email;
    private String estado;
    private LocalDateTime createdAt;

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getDiarioId() { return diarioId; }
    public void setDiarioId(Long diarioId) { this.diarioId = diarioId; }

    public String getTituloDiario() { return tituloDiario; }
    public void setTituloDiario(String tituloDiario) { this.tituloDiario = tituloDiario; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}