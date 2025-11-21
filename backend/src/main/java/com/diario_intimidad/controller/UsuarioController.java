package com.diario_intimidad.controller;

import com.diario_intimidad.entity.Usuario;
import com.diario_intimidad.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/usuarios")
@CrossOrigin(origins = "http://localhost:3005")
public class UsuarioController {

    private static final Logger logger = LoggerFactory.getLogger(UsuarioController.class);

    @Autowired
    private UsuarioService usuarioService;

    @GetMapping
    public ResponseEntity<List<Usuario>> getAllUsuarios(Authentication authentication) {
        if (authentication.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"))) {
            return ResponseEntity.ok(usuarioService.findAll());
        } else {
            // For non-admin, return only their own user
            String currentUserEmail;
            if (authentication.getPrincipal() instanceof Usuario) {
                currentUserEmail = ((Usuario) authentication.getPrincipal()).getEmail();
            } else {
                currentUserEmail = authentication.getName();
            }
            Optional<Usuario> usuario = usuarioService.findByEmail(currentUserEmail);
            return usuario.map(u -> ResponseEntity.ok(List.of(u))).orElseGet(() -> ResponseEntity.ok(List.of()));
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<Usuario> getUsuarioById(@PathVariable Long id, Authentication authentication) {
        Optional<Usuario> usuario = usuarioService.findById(id);
        if (usuario.isPresent()) {
            // Allow if own user or admin
            String currentUserEmail;
            if (authentication.getPrincipal() instanceof Usuario) {
                currentUserEmail = ((Usuario) authentication.getPrincipal()).getEmail();
            } else {
                currentUserEmail = authentication.getName();
            }
            Optional<Usuario> currentUser = usuarioService.findByEmail(currentUserEmail);
            if (currentUser.isEmpty() || (!currentUser.get().getId().equals(id) && !authentication.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN")))) {
                return ResponseEntity.status(403).build();
            }
            return ResponseEntity.ok(usuario.get());
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping
    public ResponseEntity<?> createUsuario(@RequestBody Usuario usuario, Authentication authentication) {
        logger.info("Authentication in createUsuario: {}", authentication);
        if (authentication == null) {
            logger.warn("No authentication");
            return ResponseEntity.status(403).body("No autenticado");
        }
        logger.info("Authorities: {}", authentication.getAuthorities());
        logger.info("Attempting to create user with email: {}, by: {}, authorities: {}", usuario.getEmail(), authentication.getName(), authentication.getAuthorities());
        if (!authentication.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"))) {
            logger.warn("User creation failed: user is not admin");
            return ResponseEntity.status(403).body("No autorizado");
        }
        if (usuarioService.findByEmail(usuario.getEmail()).isPresent()) {
            logger.warn("User creation failed: email {} already exists", usuario.getEmail());
            return ResponseEntity.badRequest().body("Email ya existe");
        }
        logger.info("Email is unique, proceeding to save user");
        logger.info("Received user: email={}, password='{}', rol={}", usuario.getEmail(), usuario.getPassword() != null ? usuario.getPassword() : "null", usuario.getRol());
        Usuario saved = usuarioService.save(usuario);
        logger.info("User created successfully with id: {}", saved.getId());
        return ResponseEntity.ok(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Usuario> updateUsuario(@PathVariable Long id, @RequestBody Usuario usuarioDetails, Authentication authentication) {
        logger.info("Update request for user id: {}, by: {}, authorities: {}", id, authentication.getPrincipal(), authentication.getAuthorities());
        Optional<Usuario> usuario = usuarioService.findById(id);
        if (usuario.isPresent()) {
            // Check if user can edit: own user or admin
            String currentUserEmail;
            if (authentication.getPrincipal() instanceof Usuario) {
                currentUserEmail = ((Usuario) authentication.getPrincipal()).getEmail();
            } else {
                currentUserEmail = authentication.getName();
            }
            Optional<Usuario> currentUser = usuarioService.findByEmail(currentUserEmail);
            logger.info("Current user found: {}, id: {}, rol: {}", currentUser.isPresent(), currentUser.map(Usuario::getId).orElse(null), currentUser.map(Usuario::getRol).orElse(null));
            if (currentUser.isEmpty() || (!currentUser.get().getId().equals(id) && !authentication.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN")))) {
                logger.warn("Access denied for user update");
                return ResponseEntity.status(403).build();
            }
            usuarioDetails.setId(id);
            return ResponseEntity.ok(usuarioService.save(usuarioDetails));
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUsuario(@PathVariable Long id, Authentication authentication) {
        if (!authentication.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"))) {
            return ResponseEntity.status(403).build();
        }
        usuarioService.deleteById(id);
        return ResponseEntity.noContent().build();
    }

}