package com.diario_intimidad.dto;

public class LoginResponse {

    private String token;
    private String email;
    private String rol;
    private Long userId;

    public LoginResponse() {}

    public LoginResponse(String token, String email, String rol) {
        this.token = token;
        this.email = email;
        this.rol = rol;
    }

    public LoginResponse(String token, String email, String rol, Long userId) {
        this.token = token;
        this.email = email;
        this.rol = rol;
        this.userId = userId;
    }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getRol() { return rol; }
    public void setRol(String rol) { this.rol = rol; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
}