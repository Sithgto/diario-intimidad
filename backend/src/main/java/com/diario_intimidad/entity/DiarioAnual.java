package com.diario_intimidad.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "diario_anual")
public class DiarioAnual {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Integer anio;

    private String titulo;

    @Column(name = "portada_url")
    private String portadaUrl;

    @Column(name = "tema_principal")
    private String temaPrincipal;

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Integer getAnio() { return anio; }
    public void setAnio(Integer anio) { this.anio = anio; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public String getPortadaUrl() { return portadaUrl; }
    public void setPortadaUrl(String portadaUrl) { this.portadaUrl = portadaUrl; }

    public String getTemaPrincipal() { return temaPrincipal; }
    public void setTemaPrincipal(String temaPrincipal) { this.temaPrincipal = temaPrincipal; }
}