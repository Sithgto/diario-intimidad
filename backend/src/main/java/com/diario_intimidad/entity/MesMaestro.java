package com.diario_intimidad.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "mes_maestro")
public class MesMaestro {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "diario_id")
    private DiarioAnual diarioAnual;

    @Column(name = "nombre")
    private String nombre;

    @Column(name = "tema_mes")
    private String temaMes;

    @Column(name = "versiculo_mes")
    private String versiculoMes;

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public DiarioAnual getDiarioAnual() { return diarioAnual; }
    public void setDiarioAnual(DiarioAnual diarioAnual) { this.diarioAnual = diarioAnual; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getTemaMes() { return temaMes; }
    public void setTemaMes(String temaMes) { this.temaMes = temaMes; }

    public String getVersiculoMes() { return versiculoMes; }
    public void setVersiculoMes(String versiculoMes) { this.versiculoMes = versiculoMes; }
}