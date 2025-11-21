package com.diario_intimidad.repository;

import com.diario_intimidad.entity.Pedido;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PedidoRepository extends JpaRepository<Pedido, Long> {
    List<Pedido> findByEmail(String email);
    Optional<Pedido> findByTokenValidacion(String token);
    List<Pedido> findByEstado(String estado);
}