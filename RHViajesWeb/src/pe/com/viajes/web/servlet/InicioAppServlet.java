package pe.com.viajes.web.servlet;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.sql.SQLException;
import java.util.Properties;

import javax.naming.NamingException;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.web.servicio.SeguridadServicio;
import pe.com.viajes.web.servicio.impl.SeguridadServicioImpl;

/**
 * Servlet implementation class InicioAppServlet
 */
@WebServlet(loadOnStartup = 1, urlPatterns = "/inicioAppServlet", name = "InicioAppServlet")
public class InicioAppServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public InicioAppServlet() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub

		Usuario usuario = new Usuario();
		usuario.setUsuario(request.getParameter("j_username"));
		usuario.setCredencial(request.getParameter("j_password"));

		ServletContext servletContext = request.getServletContext();
		try {
			SeguridadServicio seguridadServicio = new SeguridadServicioImpl(
					servletContext);
			usuario = seguridadServicio.inicioSesion(usuario);

			if (usuario.isEncontrado()) {
				HttpSession session = request.getSession(true);
				session.setAttribute("usuarioSession", usuario);
			} else {
				String msje = "El usuario y la contraseña son incorrectas";
				request.setAttribute("msjeError", msje);
				request.getRequestDispatcher("index.xhtml?msjeError=" + msje)
						.forward(request, response);
			}

		} catch (NamingException e) {
			e.printStackTrace();
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
	}
	
	@Override
	public void init() throws ServletException {
		try {
			String rutaArchivo = "D:\\aplicacion\\";
			String nomArchivoPropiedades = "aplicacionconfiguracion.properties";
			File archivopropiedades = new File(rutaArchivo + nomArchivoPropiedades);
			InputStream streamArchivo = new FileInputStream(archivopropiedades);
			Properties propiedades = new Properties();
			propiedades.load(streamArchivo);
			
			getServletContext().setAttribute("PROPIEDADES_SISTEMA", propiedades);
			
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} 
		
		super.init();
	}

}
