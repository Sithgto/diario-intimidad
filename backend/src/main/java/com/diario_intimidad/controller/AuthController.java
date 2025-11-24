package com.diario_intimidad.controller;

import com.diario_intimidad.dto.LoginRequest;
import com.diario_intimidad.dto.LoginResponse;
import com.diario_intimidad.entity.Usuario;
import com.diario_intimidad.service.UsuarioService;
import com.diario_intimidad.config.JwtUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "http://localhost:3005")
public class AuthController {

    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

    @Autowired
    private UsuarioService usuarioService;

    @Autowired
    private JwtUtil jwtUtil;

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest loginRequest) {
        logger.info("Login attempt for email: {}", loginRequest.getEmail());
        Optional<Usuario> usuario = usuarioService.authenticate(loginRequest);
        if (usuario.isPresent()) {
            logger.info("Login successful for email: {}", loginRequest.getEmail());
            String token = jwtUtil.generateToken(usuario.get().getEmail(), usuario.get().getRol().name());
            LoginResponse response = new LoginResponse(token, usuario.get().getEmail(), usuario.get().getRol().name(), usuario.get().getId());
            return ResponseEntity.ok(response);
        } else {
            logger.warn("Login failed for email: {}", loginRequest.getEmail());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Credenciales inválidas");
        }
    }
}