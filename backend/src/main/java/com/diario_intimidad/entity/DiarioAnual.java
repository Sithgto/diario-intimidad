 package com.diario_intimidad.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
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

    @Column(name = "portada_url")
    private String portadaUrl;

    @Column(name = "logo_url")
    private String logoUrl;

    @Column(name = "tema_principal")
    @NotNull
    private String temaPrincipal;

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

    public String getPortadaUrl() { return portadaUrl; }
    public void setPortadaUrl(String portadaUrl) { this.portadaUrl = portadaUrl; }

    public String getLogoUrl() { return logoUrl; }
    public void setLogoUrl(String logoUrl) { this.logoUrl = logoUrl; }

    public String getTemaPrincipal() { return temaPrincipal; }
    public void setTemaPrincipal(String temaPrincipal) { this.temaPrincipal = temaPrincipal; }

    public List<MesMaestro> getMesesMaestro() { return mesesMaestro; }
    public void setMesesMaestro(List<MesMaestro> mesesMaestro) { this.mesesMaestro = mesesMaestro; }
}