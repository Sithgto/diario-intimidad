package com.diario_intimidad.repository;

import com.diario_intimidad.entity.EntradaDiaria;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface EntradaDiariaRepository extends JpaRepository<EntradaDiaria, Long> {

    List<EntradaDiaria> findByUsuarioIdAndDiarioId(Long usuarioId, Long diarioId);

    List<EntradaDiaria> findByUsuarioIdAndFechaEntradaBetween(Long usuarioId, java.time.LocalDate start, java.time.LocalDate end);

}