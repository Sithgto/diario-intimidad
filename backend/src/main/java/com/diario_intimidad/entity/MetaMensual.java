package com.diario_intimidad.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "meta_mensual")
public class MetaMensual {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "usuario_id")
    private Usuario usuario;

    @ManyToOne
    @JoinColumn(name = "diario_id")
    private DiarioAnual diarioAnual;

    @Column(name = "mes_numero")
    private Integer mesNumero;

    @Column(name = "descripcion")
    private String descripcion;

    @Column(name = "cumplida")
    private Boolean cumplida = false;

    @Column(name = "pasa_siguiente_mes")
    private Boolean pasaSiguienteMes = false;

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Usuario getUsuario() { return usuario; }
    public void setUsuario(Usuario usuario) { this.usuario = usuario; }

    public DiarioAnual getDiarioAnual() { return diarioAnual; }
    public void setDiarioAnual(DiarioAnual diarioAnual) { this.diarioAnual = diarioAnual; }

    public Integer getMesNumero() { return mesNumero; }
    public void setMesNumero(Integer mesNumero) { this.mesNumero = mesNumero; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public Boolean getCumplida() { return cumplida; }
    public void setCumplida(Boolean cumplida) { this.cumplida = cumplida; }

    public Boolean getPasaSiguienteMes() { return pasaSiguienteMes; }
    public void setPasaSiguienteMes(Boolean pasaSiguienteMes) { this.pasaSiguienteMes = pasaSiguienteMes; }
}