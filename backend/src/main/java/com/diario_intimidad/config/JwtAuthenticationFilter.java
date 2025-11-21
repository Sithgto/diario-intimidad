package com.diario_intimidad.config;

import com.diario_intimidad.entity.Usuario;
import com.diario_intimidad.service.UsuarioService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import java.io.IOException;
import java.util.Collections;
import java.util.Optional;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final Logger logger = LoggerFactory.getLogger(JwtAuthenticationFilter.class);

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private UsuarioService usuarioService;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {

        final String requestURI = request.getRequestURI();
        if (requestURI.startsWith("/uploads/")) {
            chain.doFilter(request, response);
            return;
        }

        final String authorizationHeader = request.getHeader("Authorization");
        logger.info("Processing request: {} {}", request.getMethod(), requestURI);

        String email = null;
        String jwt = null;

        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
            logger.info("Authorization header present");
            jwt = authorizationHeader.substring(7);
            email = jwtUtil.extractEmail(jwt);
            logger.info("Extracted email from token: {}", email);
        } else {
            logger.info("No Authorization header");
        }

        if (email != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            logger.info("Attempting to authenticate user: {}", email);
            Optional<Usuario> usuario = usuarioService.findByEmail(email);
            if (usuario.isPresent() && jwtUtil.validateToken(jwt, email)) {
                String rol = jwtUtil.extractRol(jwt);
                logger.info("Authentication successful for: {} with role: {}", email, rol);
                UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                        usuario.get(), null, Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + rol)));
                authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authToken);
                logger.info("Authentication set in SecurityContext");
            } else {
                logger.info("Authentication failed for: {} - user present: {}, token valid: {}", email, usuario.isPresent(), jwtUtil.validateToken(jwt, email));
            }
        } else if (email == null) {
            logger.info("No email extracted, proceeding without authentication");
        } else {
            logger.info("Authentication already set or email null");
        }
        chain.doFilter(request, response);
    }
}