package com.diario_intimidad;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class GenerateHash {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String password = "S@1thgto.2@25";
        String hash = encoder.encode(password);
        System.out.println(hash);
    }
}