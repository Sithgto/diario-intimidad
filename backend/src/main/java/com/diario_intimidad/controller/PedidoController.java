package com.diario_intimidad.controller;

import com.diario_intimidad.dto.PedidoRequest;
import com.diario_intimidad.dto.PedidoResponse;
import com.diario_intimidad.entity.DiarioAnual;
import com.diario_intimidad.entity.Pedido;
import com.diario_intimidad.entity.Usuario;
import com.diario_intimidad.service.DiarioAnualService;
import com.diario_intimidad.service.EmailService;
import com.diario_intimidad.service.PedidoService;
import com.diario_intimidad.service.UsuarioService;
// import com.mailjet.client.errors.MailjetException; // Se activará cuando las dependencias se descarguen
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/api/pedidos")
@CrossOrigin(origins = "http://localhost:3005")
public class PedidoController {

    @Autowired
    private PedidoService pedidoService;

    @Autowired
    private DiarioAnualService diarioAnualService;

    @Autowired
    private UsuarioService usuarioService;

    @Autowired
    private EmailService emailService;

    @PostMapping
    public ResponseEntity<PedidoResponse> crearPedido(@RequestBody PedidoRequest request) {
        Optional<DiarioAnual> diarioOpt = diarioAnualService.findById(request.getDiarioId());
        if (diarioOpt.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }

        Pedido pedido = new Pedido();
        pedido.setDiarioAnual(diarioOpt.get());
        pedido.setEmail(request.getEmail());
        pedido.setEstado("PENDIENTE");
        pedido.setTokenValidacion(UUID.randomUUID().toString());

        Pedido saved = pedidoService.save(pedido);

        // Enviar email de validación
        try {
            emailService.enviarEmailValidacion(saved.getEmail(), saved.getTokenValidacion(), saved.getDiarioAnual().getTitulo());
        } catch (Exception e) {
            // Log error but don't fail the request
            System.err.println("Error sending email via Mailjet: " + e.getMessage());
        }

        PedidoResponse response = new PedidoResponse();
        response.setId(saved.getId());
        response.setDiarioId(saved.getDiarioAnual().getId());
        response.setTituloDiario(saved.getDiarioAnual().getTitulo());
        response.setEmail(saved.getEmail());
        response.setEstado(saved.getEstado());
        response.setCreatedAt(saved.getCreatedAt());

        return ResponseEntity.ok(response);
    }

    @GetMapping("/validar/{token}")
    public ResponseEntity<String> validarPedido(@PathVariable String token) {
        Optional<Pedido> pedidoOpt = pedidoService.findByTokenValidacion(token);
        if (pedidoOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("Token inválido");
        }

        Pedido pedido = pedidoOpt.get();
        if (!"PENDIENTE".equals(pedido.getEstado())) {
            return ResponseEntity.badRequest().body("Pedido ya validado");
        }

        // Crear usuario
        Usuario savedUser = usuarioService.createUserFromPurchase(pedido.getEmail());

        // Asignar usuario al pedido
        pedido.setUsuario(savedUser);
        pedido.setEstado("CONFIRMADO");
        pedidoService.save(pedido);

        return ResponseEntity.ok("Compra confirmada. Usuario creado con email: " + pedido.getEmail());
    }

    @GetMapping("/usuario/{usuarioId}")
    public List<Pedido> getPedidosByUsuario(@PathVariable Long usuarioId) {
        // Obtener pedidos confirmados del usuario
        return pedidoService.findByEstado("CONFIRMADO").stream()
                .filter(p -> p.getUsuario() != null && p.getUsuario().getId().equals(usuarioId))
                .toList();
    }
}