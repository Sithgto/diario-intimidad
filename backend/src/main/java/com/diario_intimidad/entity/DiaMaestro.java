package com.diario_intimidad.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "dia_maestro")
public class DiaMaestro {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "mes_id")
    private MesMaestro mesMaestro;

    @Column(name = "dia_numero")
    private Integer diaNumero;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_dia")
    private TipoDia tipoDia;

    @Column(name = "lectura_biblica")
    private String lecturaBiblica;

    @Column(name = "versiculo_diario")
    private String versiculoDiario;

    public enum TipoDia {
        NORMAL, DOMINGO
    }

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public MesMaestro getMesMaestro() { return mesMaestro; }
    public void setMesMaestro(MesMaestro mesMaestro) { this.mesMaestro = mesMaestro; }

    public Integer getDiaNumero() { return diaNumero; }
    public void setDiaNumero(Integer diaNumero) { this.diaNumero = diaNumero; }

    public TipoDia getTipoDia() { return tipoDia; }
    public void setTipoDia(TipoDia tipoDia) { this.tipoDia = tipoDia; }

    public String getLecturaBiblica() { return lecturaBiblica; }
    public void setLecturaBiblica(String lecturaBiblica) { this.lecturaBiblica = lecturaBiblica; }

    public String getVersiculoDiario() { return versiculoDiario; }
    public void setVersiculoDiario(String versiculoDiario) { this.versiculoDiario = versiculoDiario; }
}