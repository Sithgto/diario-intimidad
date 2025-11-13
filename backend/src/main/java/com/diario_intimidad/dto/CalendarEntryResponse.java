package com.diario_intimidad.dto;

import com.diario_intimidad.entity.CamposDiario;
import com.diario_intimidad.entity.DiarioAnual;

import java.time.LocalDate;
import java.util.List;

public class CalendarEntryResponse {
    private LocalDate fecha;
    private String tipoDia;
    private String lecturaBiblica;
    private String versiculoDiario;
    private DiarioAnual diarioAnual;
    private List<CamposDiario> camposDiario;

    // Getters and setters
    public LocalDate getFecha() { return fecha; }
    public void setFecha(LocalDate fecha) { this.fecha = fecha; }

    public String getTipoDia() { return tipoDia; }
    public void setTipoDia(String tipoDia) { this.tipoDia = tipoDia; }

    public String getLecturaBiblica() { return lecturaBiblica; }
    public void setLecturaBiblica(String lecturaBiblica) { this.lecturaBiblica = lecturaBiblica; }

    public String getVersiculoDiario() { return versiculoDiario; }
    public void setVersiculoDiario(String versiculoDiario) { this.versiculoDiario = versiculoDiario; }

    public DiarioAnual getDiarioAnual() { return diarioAnual; }
    public void setDiarioAnual(DiarioAnual diarioAnual) { this.diarioAnual = diarioAnual; }

    public List<CamposDiario> getCamposDiario() { return camposDiario; }
    public void setCamposDiario(List<CamposDiario> camposDiario) { this.camposDiario = camposDiario; }
}