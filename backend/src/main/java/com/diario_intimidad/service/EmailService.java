package com.diario_intimidad.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender;

    public void enviarEmailValidacion(String to, String token, String tituloDiario) {
        String subject = "Validación de compra - Diario de Intimidad";
        String validationUrl = "http://localhost:3005/validar-pedido?token=" + token;
        String text = String.format(
            "¡Gracias por tu compra!\n\n" +
            "Has comprado el diario: %s\n\n" +
            "Para completar tu compra y crear tu cuenta, por favor valida tu email haciendo clic en el siguiente enlace:\n\n" +
            "%s\n\n" +
            "Si no solicitaste esta compra, ignora este email.\n\n" +
            "Saludos,\nEquipo de Diario de Intimidad",
            tituloDiario, validationUrl
        );

        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(to);
        message.setSubject(subject);
        message.setText(text);

        mailSender.send(message);
    }
}