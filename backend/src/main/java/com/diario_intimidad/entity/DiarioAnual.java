 package com.diario_intimidad.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "diario_anual")
public class DiarioAnual {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Integer anio;

    @NotNull
    private String titulo;

    @Column(name = "nombre_portada")
    private String nombrePortada;

    @Column(name = "nombre_logo")
    private String nombreLogo;

    @Column(name = "tema_principal")
    @NotNull
    private String temaPrincipal;

    @Column(nullable = false)
    @NotNull
    private String status;

    @Column(name = "created_at")
    @CreationTimestamp
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    @UpdateTimestamp
    private LocalDateTime updatedAt;

    @JsonIgnore
    @OneToMany(mappedBy = "diarioAnual", cascade = CascadeType.ALL)
    private List<MesMaestro> mesesMaestro;

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Integer getAnio() { return anio; }
    public void setAnio(Integer anio) { this.anio = anio; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public String getNombrePortada() { return nombrePortada; }
    public void setNombrePortada(String nombrePortada) { this.nombrePortada = nombrePortada; }

    public String getNombreLogo() { return nombreLogo; }
    public void setNombreLogo(String nombreLogo) { this.nombreLogo = nombreLogo; }

    public String getTemaPrincipal() { return temaPrincipal; }
    public void setTemaPrincipal(String temaPrincipal) { this.temaPrincipal = temaPrincipal; }

    public List<MesMaestro> getMesesMaestro() { return mesesMaestro; }
    public void setMesesMaestro(List<MesMaestro> mesesMaestro) { this.mesesMaestro = mesesMaestro; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}