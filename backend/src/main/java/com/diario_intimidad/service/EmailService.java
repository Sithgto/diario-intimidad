package com.diario_intimidad.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    @Value("${MAIL_USERNAME:}")
    private String apiKey;

    @Value("${MAIL_PASSWORD:}")
    private String secretKey;

    private final JavaMailSender mailSender;

    public EmailService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    public void enviarEmailValidacion(String to, String token, String tituloDiario) {
        String subject = "Validación de compra - Diario de Intimidad";
        String validationUrl = "http://localhost:3005/validar-pedido?token=" + token;

        // Crear contenido HTML del email
        String htmlContent = String.format(
            "<!DOCTYPE html>" +
            "<html>" +
            "<head><meta charset='UTF-8'></head>" +
            "<body style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>" +
            "<div style='background-color: #f8f9fa; padding: 20px; text-align: center;'>" +
            "<h1 style='color: #333;'>¡Gracias por tu compra!</h1>" +
            "</div>" +
            "<div style='padding: 20px;'>" +
            "<p>Hola,</p>" +
            "<p>Has comprado el diario: <strong>%s</strong></p>" +
            "<p>Para completar tu compra y crear tu cuenta, por favor valida tu email haciendo clic en el siguiente botón:</p>" +
            "<div style='text-align: center; margin: 30px 0;'>" +
            "<a href='%s' style='background-color: #007bff; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; display: inline-block;'>Validar Email</a>" +
            "</div>" +
            "<p>O copia y pega este enlace en tu navegador:</p>" +
            "<p style='word-break: break-all; background-color: #f8f9fa; padding: 10px; border-radius: 3px;'>%s</p>" +
            "<p>Si no solicitaste esta compra, puedes ignorar este email.</p>" +
            "<hr style='border: none; border-top: 1px solid #eee; margin: 30px 0;'>" +
            "<p style='color: #666; font-size: 12px;'>Saludos,<br>Equipo de Diario de Intimidad</p>" +
            "</div>" +
            "</body>" +
            "</html>",
            tituloDiario, validationUrl, validationUrl
        );

        // Por ahora usamos JavaMail con Mailjet SMTP
        // TODO: Implementar Mailjet API REST cuando las dependencias sean compatibles
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom("noreply@diariointimidad.com");
        message.setTo(to);
        message.setSubject(subject);
        message.setText("Para ver el email completo, por favor usa un cliente de email que soporte HTML.\n\n" + validationUrl);

        mailSender.send(message);
    }
}