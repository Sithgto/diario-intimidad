package com.diario_intimidad.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import org.hibernate.annotations.CreationTimestamp;
import java.time.LocalDateTime;

@Entity
@Table(name = "pedido")
public class Pedido {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "diario_id", nullable = false)
    private DiarioAnual diarioAnual;

    @Email
    @NotNull
    private String email;

    @Column(nullable = false)
    private String estado; // PENDIENTE, CONFIRMADO, CANCELADO

    private String tokenValidacion;

    @ManyToOne
    @JoinColumn(name = "usuario_id")
    private Usuario usuario; // Asignado después de confirmación

    @Column(name = "created_at")
    @CreationTimestamp
    private LocalDateTime createdAt;

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public DiarioAnual getDiarioAnual() { return diarioAnual; }
    public void setDiarioAnual(DiarioAnual diarioAnual) { this.diarioAnual = diarioAnual; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public String getTokenValidacion() { return tokenValidacion; }
    public void setTokenValidacion(String tokenValidacion) { this.tokenValidacion = tokenValidacion; }

    public Usuario getUsuario() { return usuario; }
    public void setUsuario(Usuario usuario) { this.usuario = usuario; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}