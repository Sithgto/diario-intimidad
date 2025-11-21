package com.diario_intimidad.service;

import com.diario_intimidad.entity.Pedido;
import com.diario_intimidad.repository.PedidoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class PedidoService {

    @Autowired
    private PedidoRepository pedidoRepository;

    public List<Pedido> findAll() {
        return pedidoRepository.findAll();
    }

    public Optional<Pedido> findById(Long id) {
        return pedidoRepository.findById(id);
    }

    public Pedido save(Pedido pedido) {
        return pedidoRepository.save(pedido);
    }

    public void deleteById(Long id) {
        pedidoRepository.deleteById(id);
    }

    public List<Pedido> findByEmail(String email) {
        return pedidoRepository.findByEmail(email);
    }

    public Optional<Pedido> findByTokenValidacion(String token) {
        return pedidoRepository.findByTokenValidacion(token);
    }

    public List<Pedido> findByEstado(String estado) {
        return pedidoRepository.findByEstado(estado);
    }
}