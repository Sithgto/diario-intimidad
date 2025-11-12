package com.diario_intimidad.controller;

import com.diario_intimidad.dto.LoginRequest;
import com.diario_intimidad.dto.LoginResponse;
import com.diario_intimidad.entity.Usuario;
import com.diario_intimidad.service.UsuarioService;
import com.diario_intimidad.config.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "http://localhost:3005")
public class AuthController {

    @Autowired
    private UsuarioService usuarioService;

    @Autowired
    private JwtUtil jwtUtil;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        Optional<Usuario> usuario = usuarioService.authenticate(loginRequest);
        if (usuario.isPresent()) {
            String token = jwtUtil.generateToken(usuario.get().getEmail(), usuario.get().getRol().name());
            LoginResponse response = new LoginResponse(token, usuario.get().getEmail(), usuario.get().getRol().name());
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Credenciales inválidas");
        }
    }
}