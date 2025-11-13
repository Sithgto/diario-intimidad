package com.diario_intimidad.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "campos_diario")
public class CamposDiario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "nombre_campo")
    private String nombreCampo;

    @Column(name = "tipo_entrada")
    private String tipoEntrada;

    @Column(name = "es_requerido")
    private Boolean esRequerido = false;

    @ManyToOne
    @JoinColumn(name = "diario_id")
    private DiarioAnual diarioAnual;


    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNombreCampo() { return nombreCampo; }
    public void setNombreCampo(String nombreCampo) { this.nombreCampo = nombreCampo; }

    public String getTipoEntrada() { return tipoEntrada; }
    public void setTipoEntrada(String tipoEntrada) { this.tipoEntrada = tipoEntrada; }

    public Boolean getEsRequerido() { return esRequerido; }
    public void setEsRequerido(Boolean esRequerido) { this.esRequerido = esRequerido; }

    public DiarioAnual getDiarioAnual() { return diarioAnual; }
    public void setDiarioAnual(DiarioAnual diarioAnual) { this.diarioAnual = diarioAnual; }
}