package com.diario_intimidad.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "valores_campo")
public class ValoresCampo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "entrada_diaria_id")
    private EntradaDiaria entradaDiaria;

    @ManyToOne
    @JoinColumn(name = "campo_diario_id")
    private CamposDiario camposDiario;

    @Column(name = "valor_texto")
    private String valorTexto;

    @Column(name = "valor_audio_url")
    private String valorAudioUrl;

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public EntradaDiaria getEntradaDiaria() { return entradaDiaria; }
    public void setEntradaDiaria(EntradaDiaria entradaDiaria) { this.entradaDiaria = entradaDiaria; }

    public CamposDiario getCamposDiario() { return camposDiario; }
    public void setCamposDiario(CamposDiario camposDiario) { this.camposDiario = camposDiario; }

    public String getValorTexto() { return valorTexto; }
    public void setValorTexto(String valorTexto) { this.valorTexto = valorTexto; }

    public String getValorAudioUrl() { return valorAudioUrl; }
    public void setValorAudioUrl(String valorAudioUrl) { this.valorAudioUrl = valorAudioUrl; }
}