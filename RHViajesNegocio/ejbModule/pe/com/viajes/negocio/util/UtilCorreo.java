/**
 * 
 */
package pe.com.viajes.negocio.util;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.util.Date;
import java.util.Properties;

import javax.activation.DataHandler;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Multipart;
import javax.mail.NoSuchProviderException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;

import org.apache.commons.io.IOUtils;

import pe.com.viajes.bean.negocio.ArchivoAdjunto;
import pe.com.viajes.bean.util.UtilProperties;
import pe.com.viajes.negocio.exception.ErrorEncriptacionException;

/**
 * @author edwreb
 *
 */
public class UtilCorreo {

	private final Properties properties = new Properties();
	private Session session;

	/**
	 * @throws IOException
	 * @throws FileNotFoundException
	 * @throws ErrorEncriptacionException
	 * 
	 */
	public UtilCorreo() throws FileNotFoundException, IOException,
			ErrorEncriptacionException {
		Properties prop = UtilProperties
				.cargaArchivo("correoconfiguracion.properties");

		inicializador(prop);
	}

	private void inicializador(Properties propiedades)
			throws ErrorEncriptacionException {
		properties.put("mail.smtp.host", propiedades.getProperty("smtp.host"));
		properties.put("mail.smtp.starttls.enable",
				propiedades.getProperty("smtp.starttls.enable"));
		properties.put("mail.smtp.port", propiedades.getProperty("smtp.port"));
		properties.put("mail.smtp.mail.sender",
				propiedades.getProperty("smtp.mail.sender"));
		properties.put("mail.smtp.mail.senderName",
				propiedades.getProperty("smtp.mail.senderName"));
		properties.put("mail.smtp.password", UtilEncripta
				.desencriptaCadena(propiedades.getProperty("smtp.password")));
		properties.put("mail.smtp.user", propiedades.getProperty("smtp.user"));
		properties.put("mail.smtp.auth", propiedades.getProperty("smtp.auth"));
		session = Session.getDefaultInstance(properties);
	}

	public void enviarCorreo(String correoDestino, String asunto, String mensaje)
			throws AddressException, NoSuchProviderException,
			MessagingException, UnsupportedEncodingException {

		MimeMessage message = new MimeMessage(session);

		InternetAddress internetAdd = new InternetAddress(
				(String) properties.get("mail.smtp.mail.sender"),
				(String) properties.get("mail.smtp.mail.senderName"));
		message.setFrom(internetAdd);
		message.addRecipient(Message.RecipientType.TO, new InternetAddress(
				correoDestino));
		message.setSubject(asunto);
		message.setContent(mensaje, "text/html");
		Transport t = session.getTransport("smtp");
		t.connect((String) properties.get("mail.smtp.user"),
				(String) properties.get("mail.smtp.password"));
		t.sendMessage(message, message.getAllRecipients());
		t.close();
	}

	public void enviarCorreo(String correoDestino, String asunto,
			String mensaje, InputStream archivoAdjunto)
			throws MessagingException, IOException {
		MimeMessage message = new MimeMessage(session);
		InternetAddress internetAdd = new InternetAddress(
				(String) properties.get("mail.smtp.mail.sender"),
				(String) properties.get("mail.smtp.mail.senderName"));
		message.setFrom(internetAdd);
		message.addRecipient(Message.RecipientType.TO, new InternetAddress(
				correoDestino));
		message.setSubject(asunto);
		message.setSentDate(new Date());

		MimeBodyPart messageBodyPart = new MimeBodyPart();
		messageBodyPart.setContent(mensaje, "text/html");

		// creates multi-part
		Multipart multipart = new MimeMultipart();
		multipart.addBodyPart(messageBodyPart);

		MimeBodyPart attachPart = new MimeBodyPart();

		byte[] data = IOUtils.toByteArray(archivoAdjunto);

		attachPart.setDataHandler(new DataHandler(data,
				"application/octet-stream"));
		multipart.addBodyPart(attachPart);

		message.setContent(multipart);
		Transport t = session.getTransport("smtp");
		t.connect((String) properties.get("mail.smtp.user"),
				(String) properties.get("mail.smtp.password"));
		t.sendMessage(message, message.getAllRecipients());
		t.close();
	}

	public void enviarCorreo(String correoDestino, String asunto,
			String mensaje, byte[] data) throws MessagingException, IOException {
		MimeMessage message = new MimeMessage(session);
		InternetAddress internetAdd = new InternetAddress(
				(String) properties.get("mail.smtp.mail.sender"),
				(String) properties.get("mail.smtp.mail.senderName"));
		message.setFrom(internetAdd);
		message.addRecipient(Message.RecipientType.TO, new InternetAddress(
				correoDestino));
		message.setSubject(asunto);
		message.setSentDate(new Date());

		MimeBodyPart messageBodyPart = new MimeBodyPart();
		messageBodyPart.setContent(mensaje, "text/html");

		// creates multi-part
		Multipart multipart = new MimeMultipart();
		multipart.addBodyPart(messageBodyPart);

		MimeBodyPart attachPart = new MimeBodyPart();

		attachPart.setDataHandler(new DataHandler(data,
				"application/octet-stream"));
		multipart.addBodyPart(attachPart);

		message.setContent(multipart);
		Transport t = session.getTransport("smtp");
		t.connect((String) properties.get("mail.smtp.user"),
				(String) properties.get("mail.smtp.password"));
		t.sendMessage(message, message.getAllRecipients());
		t.close();
	}

	public void enviarCorreo(String correoDestino, String asunto,
			String mensaje, ArchivoAdjunto archivo) throws MessagingException,
			IOException {
		MimeMessage message = new MimeMessage(session);
		InternetAddress internetAdd = new InternetAddress(
				(String) properties.get("mail.smtp.mail.sender"),
				(String) properties.get("mail.smtp.mail.senderName"));
		message.setFrom(internetAdd);
		message.addRecipient(Message.RecipientType.TO, new InternetAddress(
				correoDestino));
		message.setSubject(asunto);
		message.setSentDate(new Date());

		MimeBodyPart messageBodyPart = new MimeBodyPart();
		messageBodyPart.setContent(mensaje, "text/html");

		// creates multi-part
		Multipart multipart = new MimeMultipart();
		multipart.addBodyPart(messageBodyPart);

		MimeBodyPart attachPart = new MimeBodyPart();

		attachPart.setDataHandler(new DataHandler(archivo.getDatos(), archivo
				.getContent()));
		attachPart.setFileName(archivo.getNombreArchivo());
		attachPart.setHeader("Content-ID", "<imagenCorreo>");
		multipart.addBodyPart(attachPart);

		message.setContent(multipart);
		Transport t = session.getTransport("smtp");
		t.connect((String) properties.get("mail.smtp.user"),
				(String) properties.get("mail.smtp.password"));
		t.sendMessage(message, message.getAllRecipients());
		t.close();
	}
}
