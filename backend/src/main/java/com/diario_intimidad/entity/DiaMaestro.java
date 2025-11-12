package com.diario_intimidad.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "dia_maestro")
public class DiaMaestro {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "dia_numero")
    private Integer diaNumero;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_dia")
    private TipoDia tipoDia;

    @Column(name = "lectura_biblica")
    private String lecturaBiblica;

    @Column(name = "versiculo_diario")
    private String versiculoDiario;

    @Column(name = "link_lectura")
    private String linkLectura;

    public enum TipoDia {
        NORMAL, DOMINGO
    }

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Integer getDiaNumero() { return diaNumero; }
    public void setDiaNumero(Integer diaNumero) { this.diaNumero = diaNumero; }

    public TipoDia getTipoDia() { return tipoDia; }
    public void setTipoDia(TipoDia tipoDia) { this.tipoDia = tipoDia; }

    public String getLecturaBiblica() { return lecturaBiblica; }
    public void setLecturaBiblica(String lecturaBiblica) { this.lecturaBiblica = lecturaBiblica; }

    public String getVersiculoDiario() { return versiculoDiario; }
    public void setVersiculoDiario(String versiculoDiario) { this.versiculoDiario = versiculoDiario; }

    public String getLinkLectura() { return linkLectura; }
    public void setLinkLectura(String linkLectura) { this.linkLectura = linkLectura; }
}