package com.diario_intimidad.service;

import com.diario_intimidad.dto.LoginRequest;
import com.diario_intimidad.entity.Usuario;
import com.diario_intimidad.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class UsuarioService {

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
        if (!usuario.getPassword().startsWith("$2a$")) {
            usuario.setPassword(passwordEncoder.encode(usuario.getPassword()));
        }
        return usuarioRepository.save(usuario);
    }

    public void deleteById(Long id) {
        usuarioRepository.deleteById(id);
    }

    public Optional<Usuario> findByEmail(String email) {
        return usuarioRepository.findByEmail(email);
    }

    public Optional<Usuario> authenticate(LoginRequest loginRequest) {
        Optional<Usuario> usuario = findByEmail(loginRequest.getEmail());
        if (usuario.isPresent()) {
            String storedPassword = usuario.get().getPassword();
            boolean matches;
            if (storedPassword.startsWith("$2a$")) {
                matches = passwordEncoder.matches(loginRequest.getPassword(), storedPassword);
            } else {
                matches = loginRequest.getPassword().equals(storedPassword);
            }
            if (matches) {
                return usuario;
            }
        }
        return Optional.empty();
    }

}