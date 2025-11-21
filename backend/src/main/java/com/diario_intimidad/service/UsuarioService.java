package com.diario_intimidad.service;

import com.diario_intimidad.dto.LoginRequest;
import com.diario_intimidad.entity.Usuario;
import com.diario_intimidad.repository.UsuarioRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class UsuarioService {

    private static final Logger logger = LoggerFactory.getLogger(UsuarioService.class);

    @Autowired
    private UsuarioRepository usuarioRepository;

    private BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public List<Usuario> findAll() {
        return usuarioRepository.findAll();
    }

    public Optional<Usuario> findById(Long id) {
        return usuarioRepository.findById(id);
    }

    public Usuario save(Usuario usuario) {
        logger.info("Saving user with email: {}, rol: {}", usuario.getEmail(), usuario.getRol());
        if (usuario.getPassword() == null || usuario.getPassword().trim().isEmpty()) {
            throw new IllegalArgumentException("Password cannot be null or empty");
        }
        usuario.setPassword(passwordEncoder.encode(usuario.getPassword()));
        logger.info("Password encoded, saving to repository");
        Usuario saved = usuarioRepository.save(usuario);
        logger.info("User saved with id: {}", saved.getId());
        return saved;
    }

    public void deleteById(Long id) {
        usuarioRepository.deleteById(id);
    }

    public Optional<Usuario> findByEmail(String email) {
        return usuarioRepository.findByEmailIgnoreCase(email);
    }

    public Optional<Usuario> authenticate(LoginRequest loginRequest) {
        logger.info("Attempting to authenticate user: {}", loginRequest.getEmail());
        Optional<Usuario> usuario = findByEmail(loginRequest.getEmail());
        if (usuario.isPresent()) {
            logger.info("User found: {}", usuario.get().getEmail());
            String storedPassword = usuario.get().getPassword();
            logger.info("Stored password starts with $2a$: {}", storedPassword.startsWith("$2a$"));
            boolean matches;
            if (storedPassword.startsWith("$2a$")) {
                matches = passwordEncoder.matches(loginRequest.getPassword(), storedPassword);
                logger.info("BCrypt matches: {}", matches);
            } else {
                matches = loginRequest.getPassword().equals(storedPassword);
                logger.info("Plain text matches: {}", matches);
            }
            if (matches) {
                logger.info("Authentication successful for user: {}", loginRequest.getEmail());
                return usuario;
            } else {
                logger.warn("Password does not match for user: {}", loginRequest.getEmail());
            }
        } else {
            logger.warn("User not found: {}", loginRequest.getEmail());
        }
        return Optional.empty();
    }

}