package com.diario_intimidad.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "entrada_diaria")
public class EntradaDiaria {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "usuario_id")
    private Usuario usuario;

    @ManyToOne
    @JoinColumn(name = "diario_id")
    private DiarioAnual diario;

    @ManyToOne
    @JoinColumn(name = "dia_maestro_id")
    private DiaMaestro diaMaestro;

    @Column(name = "fecha_entrada", nullable = false)
    private LocalDate fechaEntrada;

    @Column(name = "estado_llenado", precision = 5, scale = 2)
    private BigDecimal estadoLlenado = BigDecimal.ZERO;

    private Boolean completado = false;

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Usuario getUsuario() { return usuario; }
    public void setUsuario(Usuario usuario) { this.usuario = usuario; }

    public DiarioAnual getDiario() { return diario; }
    public void setDiario(DiarioAnual diario) { this.diario = diario; }

    public DiaMaestro getDiaMaestro() { return diaMaestro; }
    public void setDiaMaestro(DiaMaestro diaMaestro) { this.diaMaestro = diaMaestro; }

    public LocalDate getFechaEntrada() { return fechaEntrada; }
    public void setFechaEntrada(LocalDate fechaEntrada) { this.fechaEntrada = fechaEntrada; }

    public BigDecimal getEstadoLlenado() { return estadoLlenado; }
    public void setEstadoLlenado(BigDecimal estadoLlenado) { this.estadoLlenado = estadoLlenado; }

    public Boolean getCompletado() { return completado; }
    public void setCompletado(Boolean completado) { this.completado = completado; }
}