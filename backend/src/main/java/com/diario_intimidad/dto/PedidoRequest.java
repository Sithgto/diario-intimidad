package com.diario_intimidad.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;

public class PedidoRequest {

    @NotNull
    private Long diarioId;

    @Email
    @NotNull
    private String email;

    // Getters and setters
    public Long getDiarioId() { return diarioId; }
    public void setDiarioId(Long diarioId) { this.diarioId = diarioId; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
}