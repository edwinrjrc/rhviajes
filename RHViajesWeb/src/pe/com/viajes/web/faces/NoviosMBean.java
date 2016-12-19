/**
 * 
 */
package pe.com.viajes.web.faces;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.naming.NamingException;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import net.sf.jasperreports.engine.JREmptyDataSource;
import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JasperFillManager;
import net.sf.jasperreports.engine.JasperPrint;
import net.sf.jasperreports.engine.export.JRPdfExporter;
import net.sf.jasperreports.export.SimpleExporterInput;
import net.sf.jasperreports.export.SimpleOutputStreamExporterOutput;
import net.sf.jasperreports.export.SimplePdfExporterConfiguration;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.Cliente;
import pe.com.viajes.bean.negocio.Destino;
import pe.com.viajes.bean.negocio.DetalleServicioAgencia;
import pe.com.viajes.bean.negocio.MaestroServicio;
import pe.com.viajes.bean.negocio.ProgramaNovios;
import pe.com.viajes.bean.negocio.ServicioAgencia;
import pe.com.viajes.bean.negocio.ServicioNovios;
import pe.com.viajes.bean.negocio.ServicioProveedor;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.negocio.exception.ErrorRegistroDataException;
import pe.com.viajes.negocio.exception.ValidacionException;
import pe.com.viajes.web.servicio.ConsultaNegocioServicio;
import pe.com.viajes.web.servicio.NegocioServicio;
import pe.com.viajes.web.servicio.SoporteServicio;
import pe.com.viajes.web.servicio.impl.ConsultaNegocioServicioImpl;
import pe.com.viajes.web.servicio.impl.NegocioServicioImpl;
import pe.com.viajes.web.servicio.impl.SoporteServicioImpl;
import pe.com.viajes.web.util.UtilWeb;

/**
 * @author edwreb
 * 
 */
@ManagedBean(name = "noviosMBean")
@SessionScoped()
public class NoviosMBean extends BaseMBean {

	private final static Logger logger = Logger.getLogger(NoviosMBean.class);

	/**
	 * 
	 */
	private static final long serialVersionUID = -2578137810881699743L;

	private ProgramaNovios programaNovios;
	private ProgramaNovios programaNoviosBusqueda;
	private Cliente clienteBusqueda;
	private ServicioNovios servicioNovios;
	private Destino destinoBusqueda;
	private Destino origenBusqueda;

	private int tipoBusqueda;

	private boolean nuevoNovios;
	private boolean editarNovios;
	private boolean registroExito;
	private boolean servicioFee;
	private boolean editarComision;

	private List<ProgramaNovios> listadoNovios;
	private List<DetalleServicioAgencia> listadoDetalleServicio;
	private List<DetalleServicioAgencia> listadoDetalleServicioTotal;
	private List<Cliente> listadoClientes;
	private List<Cliente> listadoInvitados;
	private List<SelectItem> listadoEmpresas;
	private List<ServicioProveedor> listaProveedores;
	private List<Destino> listaDestinosBusqueda;
	private List<Destino> listaOrigenesBusqueda;

	private String generoCliente;

	private NegocioServicio negocioServicio;
	private SoporteServicio soporteServicio;
	private ConsultaNegocioServicio consultaNegocioServicio;

	/**
	 * 
	 */
	public NoviosMBean() {
		try {
			ServletContext servletContext = (ServletContext) FacesContext
					.getCurrentInstance().getExternalContext().getContext();
			soporteServicio = new SoporteServicioImpl(servletContext);
			negocioServicio = new NegocioServicioImpl(servletContext);
			consultaNegocioServicio = new ConsultaNegocioServicioImpl(
					servletContext);
		} catch (NamingException e) {
			logger.error(e.getMessage(), e);
		}
	}

	public void inicio() {
		this.setProgramaNoviosBusqueda(null);
		this.setListadoNovios(null);
	}

	public void buscarProgramaNovios() {
		try {
			System.out.println("busca novios");
			listadoNovios = this.consultaNegocioServicio
					.consultarNovios(getProgramaNoviosBusqueda());
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}
	}

	public void registrarNovios() {
		this.setProgramaNovios(null);
		this.setListadoDetalleServicio(null);
		this.setListadoDetalleServicioTotal(null);
		this.setListadoInvitados(null);
		this.setNuevoNovios(true);
		this.setEditarNovios(false);
		this.setShowModal(false);
		this.setRegistroExito(false);
		this.setNombreFormulario("Registro de Novios");
		HttpSession session = obtenerSession(false);
		Usuario usuario = (Usuario) session.getAttribute(USUARIO_SESSION);
		if (!UtilWeb.validarPermisoRoles(usuario.getListaRoles(), 1)) {
			this.getProgramaNovios().getVendedor()
					.setCodigoEntero(usuario.getCodigoEntero());
			this.getProgramaNovios().getVendedor()
					.setNombre(usuario.getNombreCompleto());
		}
	}

	public void consultaClientes(String genero, long busqueda) {
		try {
			this.setClienteBusqueda(null);
			this.setGeneroCliente(genero);
			this.setTipoBusqueda((int) busqueda);

			this.setListadoClientes(this.consultaNegocioServicio
					.listarClientesNovios(genero, this.obtenerIdEmpresa()));
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}
	}

	public void buscarClientes() {
		try {
			getClienteBusqueda().getGenero().setCodigoCadena(
					this.getGeneroCliente());
			this.listadoClientes = this.consultaNegocioServicio
					.buscarClientesNovios(getClienteBusqueda(), this.obtenerIdEmpresa());

		} catch (SQLException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void ejecutarMetodo(ActionEvent e) {

		try {
			if (validarNuevoNovios()) {
				if (this.isNuevoNovios()) {

					getProgramaNovios()
							.setListaInvitados(getListadoInvitados());
					getProgramaNovios().setListaServicios(
							getListadoDetalleServicio());
					HttpSession session = obtenerSession(false);
					Usuario usuario = (Usuario) session
							.getAttribute(USUARIO_SESSION);
					getProgramaNovios()
							.setUsuarioCreacion(usuario);
					getProgramaNovios().setIpCreacion(
							obtenerRequest().getRemoteAddr());

					for (Cliente cliente : this.getProgramaNovios()
							.getListaInvitados()) {

						cliente.setUsuarioCreacion(usuario);
						cliente.setIpCreacion(obtenerRequest().getRemoteAddr());
					}

					Integer idnovios = negocioServicio
							.registrarNovios(getProgramaNovios());
					this.setRegistroExito(idnovios != null
							&& idnovios.intValue() != 0);

					getProgramaNovios().setCodigoEntero(idnovios);
					List<ProgramaNovios> resultadoConsulta = this.consultaNegocioServicio
							.consultarNovios(programaNovios);
					if (resultadoConsulta != null
							&& !resultadoConsulta.isEmpty()) {
						this.setProgramaNovios(resultadoConsulta.get(0));
					}

					this.setShowModal(true);
					this.setMensajeModal("Novios registrados satisfactoriamente");
					this.setTipoModal(TIPO_MODAL_EXITO);
				} else if (this.isEditarNovios()) {
					getProgramaNovios()
							.setListaInvitados(getListadoInvitados());
					getProgramaNovios().setListaServicios(
							getListadoDetalleServicio());
					HttpSession session = obtenerSession(false);
					Usuario usuario = (Usuario) session
							.getAttribute(USUARIO_SESSION);
					getProgramaNovios().setUsuarioModificacion(
							usuario);
					getProgramaNovios().setIpModificacion(
							obtenerRequest().getRemoteAddr());

					for (Cliente cliente : this.getProgramaNovios()
							.getListaInvitados()) {

						cliente.setUsuarioCreacion(usuario);
						cliente.setIpCreacion(obtenerRequest().getRemoteAddr());
						cliente.setUsuarioModificacion(usuario);
						cliente.setIpModificacion(obtenerRequest()
								.getRemoteAddr());
					}

					for (DetalleServicioAgencia detalle : getProgramaNovios()
							.getListaServicios()) {
						detalle.setUsuarioCreacion(usuario);
						detalle.setIpCreacion(obtenerRequest().getRemoteAddr());
						detalle.setUsuarioModificacion(usuario);
						detalle.setIpModificacion(obtenerRequest()
								.getRemoteAddr());
					}

					Integer idnovios = negocioServicio
							.actualizarNovios(getProgramaNovios());
					this.setRegistroExito(idnovios != null
							&& idnovios.intValue() != 0);

					getProgramaNovios().setCodigoEntero(idnovios);
					List<ProgramaNovios> resultadoConsulta = this.consultaNegocioServicio
							.consultarNovios(programaNovios);
					if (resultadoConsulta != null
							&& !resultadoConsulta.isEmpty()) {
						this.setProgramaNovios(resultadoConsulta.get(0));
					}

					this.setShowModal(true);
					this.setMensajeModal("Novios actualizados satisfactoriamente");
					this.setTipoModal(TIPO_MODAL_EXITO);
				}
			}
		} catch (ValidacionException ex) {
			this.setShowModal(true);
			this.setMensajeModal(ex.getMessage());
			this.setTipoModal(TIPO_MODAL_ERROR);
			logger.error(ex.getMessage(), ex);
		} catch (Exception ex) {
			this.setShowModal(true);
			this.setMensajeModal(ex.getMessage());
			this.setTipoModal(TIPO_MODAL_ERROR);
			logger.error(ex.getMessage(), ex);
		}

	}

	public void cargarProveedores(ValueChangeEvent e) {
		Object oe = e.getNewValue();
		try {
			setListadoEmpresas(null);
			this.getServicioNovios().getServicioProveedor().setProveedor(null);

			if (oe != null) {
				String valor = oe.toString();

				/*
				 * Parametro param =
				 * this.parametroServicio.consultarParametro(UtilWeb
				 * .obtenerEnteroPropertieMaestro( "codigoParametroFee",
				 * "aplicacionDatos"));
				 */
				MaestroServicio maestroServicio = this.consultaNegocioServicio
						.consultarMaestroServicio(UtilWeb
								.convertirCadenaEntero(valor), this.obtenerIdEmpresa());

				this.setServicioFee(maestroServicio.isEsFee()
						|| maestroServicio.isEsImpuesto());
				if (!this.isServicioFee()) {
					listaProveedores = this.consultaNegocioServicio
							.proveedoresXServicio(UtilWeb
									.convertirCadenaEntero(valor), this.obtenerIdEmpresa());
					setListadoEmpresas(null);

					SelectItem si = null;
					for (ServicioProveedor servicioProveedor : listaProveedores) {
						si = new SelectItem();
						si.setValue(servicioProveedor.getCodigoEntero());
						si.setLabel(servicioProveedor.getNombreProveedor());
						getListadoEmpresas().add(si);
					}
				}
			}
		} catch (SQLException ex) {
			logger.error(ex.getMessage(), ex);
		} catch (Exception ex) {
			logger.error(ex.getMessage(), ex);
		}
	}

	public void seleccionarEmpresa(ValueChangeEvent e) {
		Object oe = e.getNewValue();
		try {
			if (oe != null) {
				String valor = oe.toString();

				for (ServicioProveedor servicioProveedor : this.listaProveedores) {
					if (servicioProveedor.getCodigoEntero().intValue() == UtilWeb
							.convertirCadenaEntero(valor)) {
						this.getServicioNovios()
								.getServicioProveedor()
								.setPorcentajeComision(
										servicioProveedor
												.getPorcentajeComision());
						break;
					}
				}
			}
		} catch (Exception ex) {
			this.getServicioNovios().getServicioProveedor()
					.setPorcentajeComision(BigDecimal.ZERO);
			logger.error(ex.getMessage(), ex);
		}
	}

	private boolean validarNuevoNovios() throws ValidacionException,
			ErrorRegistroDataException, SQLException, Exception {
		boolean resultado = true;
		String idFormulario = "idFormNovios";
		if (this.getProgramaNovios().getNovia() == null
				|| this.getProgramaNovios().getNovia().getCodigoEntero() == null
				|| this.getProgramaNovios().getNovia().getCodigoEntero()
						.intValue() == 0
				|| StringUtils.isBlank(this.getProgramaNovios().getNovia()
						.getNombreCompleto())) {
			this.agregarMensaje(idFormulario + ":idFrNovia",
					"Seleccione a la novia", "", FacesMessage.SEVERITY_ERROR);
			resultado = false;
		}
		if (this.getProgramaNovios().getNovio() == null
				|| this.getProgramaNovios().getNovio().getCodigoEntero() == null
				|| this.getProgramaNovios().getNovio().getCodigoEntero()
						.intValue() == 0
				|| StringUtils.isBlank(this.getProgramaNovios().getNovio()
						.getNombreCompleto())) {
			this.agregarMensaje(idFormulario + ":idFrNovio",
					"Seleccione a la novio", "", FacesMessage.SEVERITY_ERROR);
			resultado = false;
		}
		if (this.getProgramaNovios().getDestino() == null
				|| this.getProgramaNovios().getDestino().getCodigoEntero() == null
				|| this.getProgramaNovios().getDestino().getCodigoEntero()
						.intValue() == 0) {
			this.agregarMensaje(idFormulario + ":idSelDestino",
					"Seleccione el destino", "", FacesMessage.SEVERITY_ERROR);
			resultado = false;
		}
		if (this.getProgramaNovios().getFechaBoda() == null) {
			this.agregarMensaje(idFormulario + ":idFecBoda",
					"Seleccione la fecha de la Boda", "",
					FacesMessage.SEVERITY_ERROR);
			resultado = false;
		}
		if (this.getProgramaNovios().getFechaViaje() == null) {
			this.agregarMensaje(idFormulario + ":idFecViaje",
					"Seleccione la fecha de Viaje", "",
					FacesMessage.SEVERITY_ERROR);
			resultado = false;
		}
		if (this.getProgramaNovios().getFechaShower() == null) {
			this.agregarMensaje(idFormulario + ":idFecShower",
					"Seleccione la fecha del Shower", "",
					FacesMessage.SEVERITY_ERROR);
			resultado = false;
		}
		if (this.getProgramaNovios().getMoneda() == null
				|| this.getProgramaNovios().getMoneda().getCodigoEntero()
						.intValue() == 0) {
			this.agregarMensaje(idFormulario + ":idSelMoneda",
					"Seleccione la moneda de la cuota inicial", "",
					FacesMessage.SEVERITY_ERROR);
			resultado = false;
		}
		if (this.getProgramaNovios().getCuotaInicial() == null
				|| this.getProgramaNovios().getCuotaInicial()
						.equals(BigDecimal.ZERO)) {
			this.agregarMensaje(idFormulario + ":idCuotaInicial",
					"Ingrese el monto de la cuota inicial", "",
					FacesMessage.SEVERITY_ERROR);
			resultado = false;
		}
		if (resultado) {
			if (this.getProgramaNovios().getFechaBoda()
					.after(this.getProgramaNovios().getFechaViaje())) {
				throw new ValidacionException(
						"La fecha de la boda no puede ser mayor a la fecha del viaje");
			}
			if (this.getProgramaNovios().getFechaViaje()
					.before(this.getProgramaNovios().getFechaShower())) {
				throw new ValidacionException(
						"La fecha del Shower no puede ser mayor a la fecha del viaje");
			}
			if (this.getProgramaNovios().getFechaShower()
					.after(this.getProgramaNovios().getFechaBoda())) {
				throw new ValidacionException(
						"La fecha del Shower no puede ser mayor a la fecha de la boda");
			}
		}

		if (resultado) {
			if (this.getListadoDetalleServicio().isEmpty()) {
				throw new ErrorRegistroDataException(
						"No se agregaron servicios a la venta");
			} else {

				validarServicios();

				validarFee();
			}
		}

		return resultado;
	}

	private void validarServicios() throws ErrorRegistroDataException,
			SQLException, Exception {

		for (DetalleServicioAgencia detalle : this.getListadoDetalleServicio()) {

			List<BaseVO> listaDependientes = this.consultaNegocioServicio
					.consultaServiciosDependientes(detalle.getTipoServicio()
							.getCodigoEntero(), this.obtenerIdEmpresa());

			for (BaseVO baseVO : listaDependientes) {
				if (!estaEnListaServicios(baseVO)) {
					throw new ErrorRegistroDataException("No se agrego "
							+ baseVO.getNombre());
				}
			}

		}

	}

	private boolean estaEnListaServicios(BaseVO baseVO) {
		boolean resultado = false;

		for (DetalleServicioAgencia detalle : this.getListadoDetalleServicio()) {
			if (detalle.getTipoServicio().getCodigoEntero().intValue() == baseVO
					.getCodigoEntero().intValue()) {
				resultado = true;
			}
		}

		return resultado;
	}

	private void validarImpto() throws ErrorRegistroDataException {
		boolean tieneImpto = false;

		for (DetalleServicioAgencia detalle : this.getListadoDetalleServicio()) {
			if (detalle.getTipoServicio().isEsImpuesto()) {
				tieneImpto = true;
				break;
			}
		}

		if (!tieneImpto) {
			throw new ErrorRegistroDataException("No se agrego el Impuesto");
		}

	}

	private void validarFee() throws ErrorRegistroDataException {
		boolean tieneFee = false;

		for (DetalleServicioAgencia detalle : this.getListadoDetalleServicio()) {
			if (detalle.getTipoServicio().isEsFee()) {
				tieneFee = true;
				break;
			}
		}

		if (!tieneFee) {
			throw new ErrorRegistroDataException("No se agrego el Fee de Venta");
		}
	}

	public void seleccionarNovio() {
		if (this.getTipoBusqueda() == 1) {
			if ("F".equals(this.getGeneroCliente())) {
				this.getProgramaNoviosBusqueda().setNovia(
						obtenerClienteListado());
			} else {
				this.getProgramaNoviosBusqueda().setNovio(
						obtenerClienteListado());
			}
		} else {
			if ("F".equals(this.getGeneroCliente())) {
				this.getProgramaNovios().setNovia(obtenerClienteListado());
			} else {
				this.getProgramaNovios().setNovio(obtenerClienteListado());
			}
		}
	}

	public void imprimirFormatoNovios() {
		String rutaCarpeta = "/../resources/jasper/";
		String[] rutaJasper = { "report2.jasper", "contrato1.jasper",
				"contrato2.jasper", "contrato3.jasper" };

		try {
			HttpServletResponse response = obtenerResponse();
			response.setHeader("Content-Type", "application/pdf");
			response.setHeader("Content-disposition",
					"attachment;filename=registroNovios.pdf");
			response.setHeader("Content-Transfer-Encoding", "binary");

			FacesContext facesContext = obtenerContexto();
			InputStream[] jasperStream = new InputStream[4];
			OutputStream stream = response.getOutputStream();
			for (int i = 0; i < rutaJasper.length; i++) {
				rutaJasper[i] = obtenerRequest().getContextPath() + rutaCarpeta
						+ rutaJasper[i];
				jasperStream[i] = facesContext.getExternalContext()
						.getResourceAsStream(rutaJasper[i]);
			}
			imprimirPDF(enviarParametros(), stream, jasperStream);

			facesContext.responseComplete();

		} catch (IOException e) {
			e.printStackTrace();
			logger.error(e.getMessage(), e);
		} catch (Exception e) {
			e.printStackTrace();
			logger.error(e.getMessage(), e);
		}
	}

	private Map<String, Object> enviarParametros() {
		Map<String, Object> parametros = new HashMap<String, Object>();

		SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");

		try {
			parametros.put("P_CODIGONOVIOS", getProgramaNovios()
					.getCodigoNovios());
			parametros.put("P_NOVIA", getProgramaNovios().getNovia()
					.getNombreCompleto());
			parametros.put("P_NOVIO", getProgramaNovios().getNovio()
					.getNombreCompleto());
			parametros.put("P_FECHABODA",
					sdf.format(getProgramaNovios().getFechaBoda()));
			parametros.put("P_DESTINO", getProgramaNovios().getDestino()
					.getDescripcion());
			parametros.put("P_PAIS", getProgramaNovios().getDestino().getPais()
					.getDescripcion());
			parametros.put("P_FECHAIDA",
					sdf.format(getProgramaNovios().getFechaViaje()));
			parametros.put("P_FECHAINSCRIPCION",
					sdf.format(getProgramaNovios().getFechaCreacion()));
			parametros.put("P_CUOTAINICIAL", getProgramaNovios()
					.getCuotaInicial().toString());
			parametros.put("P_NROINVITADOS",
					String.valueOf(getProgramaNovios().getCantidadInvitados()));

			parametros.put("nomNovia", String.valueOf(getProgramaNovios()
					.getNovia().getNombreCompleto()));
			parametros.put("nomNovio", String.valueOf(getProgramaNovios()
					.getNovio().getNombreCompleto()));
			parametros.put(
					"dniNovia",
					String.valueOf(getProgramaNovios().getNovia()
							.getDocumentoIdentidad().getNumeroDocumento()));
			parametros.put(
					"dniNovio",
					String.valueOf(getProgramaNovios().getNovio()
							.getDocumentoIdentidad().getNumeroDocumento()));
			parametros.put("nomAsesora", String.valueOf(getProgramaNovios()
					.getVendedor().getNombre()));
			parametros.put("dniAsesora", "41222245");
		} catch (Exception e) {
			parametros.put("P_CODIGONOVIOS", "");
			parametros.put("P_NOVIA", "");
			parametros.put("P_NOVIO", "");
			parametros.put("P_FECHABODA", "");
			parametros.put("P_DESTINO", "");
			parametros.put("P_PAIS", "");
			parametros.put("P_FECHAIDA", "");
			parametros.put("P_FECHAINSCRIPCION", "");
			parametros.put("P_CUOTAINICIAL", "");
			parametros.put("P_NROINVITADOS", "");
			parametros.put("nomNovia", "");
			parametros.put("nomNovio", "");
			parametros.put("dniNovia", "");
			parametros.put("dniNovio", "");
			parametros.put("nomAsesora", "");
			parametros.put("dniAsesora", "");
			logger.error(e.getMessage(), e);
		}

		return parametros;
	}

	public void consultarProgramaNovios(int idProgramaNovios) {
		try {

			this.setNombreFormulario("Edicion de Novios");
			this.setNuevoNovios(false);
			this.setEditarNovios(true);
			this.setProgramaNovios(null);
			this.setListadoDetalleServicio(null);
			this.setListadoDetalleServicioTotal(null);
			this.setProgramaNovios(this.consultaNegocioServicio
					.consultarProgramaNovios(idProgramaNovios, this.obtenerIdEmpresa()));
			this.setListadoInvitados(this.getProgramaNovios()
					.getListaInvitados());

			ServicioAgencia consultaServicioNovios = this.consultaNegocioServicio
					.consultarVentaServicio(this.getProgramaNovios()
							.getIdServicio(), this.obtenerIdEmpresa());

			this.setListadoDetalleServicioTotal(consultaServicioNovios
					.getListaDetalleServicio());
			for (DetalleServicioAgencia detServicio : consultaServicioNovios
					.getListaDetalleServicio()) {
				if (detServicio.getTipoServicio().isVisible()) {
					this.getListadoDetalleServicio().add(detServicio);
				}
			}

			this.calcularTotales();
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void agregarInvitado() {
		this.getListadoInvitados().add(new Cliente());
	}

	public void eliminarInvitado(Cliente invitado) {
		this.getListadoInvitados().remove(invitado);
	}

	private Cliente obtenerClienteListado() {
		try {
			for (Cliente clienteLocal : this.getListadoClientes()) {
				if (clienteLocal.getCodigoEntero().equals(
						clienteLocal.getCodigoSeleccionado())) {
					return clienteLocal;
				}
			}
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}

		return null;
	}

	private void imprimirPDF(Map<String, Object> map,
			OutputStream outputStream, InputStream[] jasperStream)
			throws JRException {

		List<JasperPrint> printList = new ArrayList<JasperPrint>();

		for (int i = 0; i < jasperStream.length; i++) {
			printList.add(JasperFillManager.fillReport(jasperStream[i], map,
					new JREmptyDataSource()));
		}

		JRPdfExporter exporter = new JRPdfExporter();
		exporter.setExporterInput(SimpleExporterInput.getInstance(printList));
		exporter.setExporterOutput(new SimpleOutputStreamExporterOutput(
				outputStream));
		SimplePdfExporterConfiguration configuration = new SimplePdfExporterConfiguration();
		configuration.setCreatingBatchModeBookmarks(true);
		// exporter.setConfiguration(configuration);
		exporter.exportReport();
	}

	public void agregarServicio() {
		try {
			if (validarServicioVenta()) {
				HttpSession session = obtenerSession(false);
				Usuario usuario = (Usuario) session
						.getAttribute("usuarioSession");
				getServicioNovios().setUsuarioCreacion(usuario);
				getServicioNovios().setIpCreacion(
						obtenerRequest().getRemoteAddr());

				getServicioNovios().getServicioProveedor().setEditoComision(
						this.isEditarComision());

				/*
				 * this.setListadoDetalleServicio(negocioServicio
				 * .agregarServicioVenta
				 * (this.getListadoDetalleServicio(),getServicioNovios()));
				 */

				this.setServicioNovios(null);

				calcularTotales();

				this.setServicioFee(false);
				this.setListadoEmpresas(null);
			}
			/*
			 * } catch (ErrorRegistroDataException e) {
			 * logger.error(e.getMessage(), e); this.setShowModal(true);
			 * this.setMensajeModal(e.getMessage());
			 * this.setTipoModal(TIPO_MODAL_ERROR); } catch (SQLException e) {
			 * logger.error(e.getMessage(), e); this.setShowModal(true);
			 * this.setMensajeModal(e.getMessage());
			 * this.setTipoModal(TIPO_MODAL_ERROR);
			 */
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			this.setShowModal(true);
			this.setMensajeModal(e.getMessage());
			this.setTipoModal(TIPO_MODAL_ERROR);
		}
	}

	private boolean validarServicioVenta() {
		boolean resultado = true;
		String idFormulario = "idFormNovios";
		if (this.getServicioNovios().getTipoServicio().getCodigoEntero() == null
				|| this.getServicioNovios().getTipoServicio().getCodigoEntero()
						.intValue() == 0) {
			this.agregarMensaje(idFormulario + ":idSelTipoServicio",
					"Seleccione el tipo de servicio", "",
					FacesMessage.SEVERITY_ERROR);
			resultado = false;
		} else {
			if (!this.isServicioFee()) {
				if (this.getServicioNovios().getTipoServicio()
						.getCodigoEntero() == null
						|| this.getServicioNovios().getTipoServicio()
								.getCodigoEntero().intValue() == 0) {
					this.agregarMensaje(idFormulario + ":idSelTipoServicio",
							"Seleccione el tipo de servicio", "",
							FacesMessage.SEVERITY_ERROR);
					resultado = false;
				}
				if (StringUtils.isBlank(this.getServicioNovios()
						.getDescripcionServicio())) {
					this.agregarMensaje(idFormulario + ":idDescServicio",
							"Ingrese la descripcion del servicio", "",
							FacesMessage.SEVERITY_ERROR);
					resultado = false;
				}
				if (this.getServicioNovios().getCantidad() == 0) {
					this.agregarMensaje(idFormulario + ":idCantidad",
							"Ingrese la cantidad", "",
							FacesMessage.SEVERITY_ERROR);
					resultado = false;
				}
				if (this.getServicioNovios().getPrecioUnitario() == null
						|| this.getServicioNovios().getPrecioUnitario()
								.doubleValue() == 0.0) {
					this.agregarMensaje(idFormulario + ":idPrecUnitario",
							"Ingrese el precio base del servicio", "",
							FacesMessage.SEVERITY_ERROR);
					resultado = false;
				}
				if (this.getServicioNovios().getFechaIda() == null) {
					this.agregarMensaje(idFormulario + ":idFecServicio",
							"Ingrese la fecha del servicio", "",
							FacesMessage.SEVERITY_ERROR);
					resultado = false;
				} else if (UtilWeb.fecha1EsMayorIgualFecha2(this
						.getServicioNovios().getFechaIda(), new Date())) {
					this.agregarMensaje(
							idFormulario + ":idFecServicio",
							"La fecha del servicio no puede ser menor que la fecha de actual",
							"", FacesMessage.SEVERITY_ERROR);
					resultado = false;
				} else if (this.getServicioNovios().getFechaRegreso() != null
						&& this.getServicioNovios()
								.getFechaIda()
								.after(this.getServicioNovios()
										.getFechaRegreso())) {
					this.agregarMensaje(
							idFormulario + ":idFecServicio",
							"La fecha del servicio no puede ser mayor que la fecha de regreso",
							"", FacesMessage.SEVERITY_ERROR);
					resultado = false;
				}
				if (this.getServicioNovios().getServicioProveedor()
						.getProveedor().getCodigoEntero() == null
						|| this.getServicioNovios().getServicioProveedor()
								.getProveedor().getCodigoEntero().intValue() == 0) {
					this.agregarMensaje(idFormulario + ":idSelEmpServicio",
							"Seleccione el proveedor del servicio", "",
							FacesMessage.SEVERITY_ERROR);
					resultado = false;
				}
			} else {
				if (this.getServicioNovios().getPrecioUnitario() == null) {
					this.agregarMensaje(idFormulario + ":idMonFee",
							"Ingrese el Monto Fee", "",
							FacesMessage.SEVERITY_ERROR);
					resultado = false;
				}
				if (this.getServicioNovios().getFechaIda() == null) {
					this.agregarMensaje(idFormulario + ":idFecServicioFee",
							"Ingrese la fecha del servicio", "",
							FacesMessage.SEVERITY_ERROR);
					resultado = false;
				}
			}
		}

		return resultado;
	}

	public void eliminarServicio(ServicioNovios servicioNovios) {
		try {
			this.getListadoDetalleServicio().remove(servicioNovios);

			calcularTotales();

			for (int i = 0; i < listadoDetalleServicioTotal.size(); i++) {
				DetalleServicioAgencia detalle = listadoDetalleServicioTotal
						.get(i);
				if (servicioNovios.getCodigoCadena().equals(
						detalle.getCodigoCadena())) {
					this.listadoDetalleServicioTotal.remove(i);
				}
			}

			calcularTotales();
		} catch (Exception e) {
			this.setShowModal(true);
			this.setMensajeModal(e.getMessage());
			this.setTipoModal(TIPO_MODAL_ERROR);
			logger.error(e.getMessage(), e);
		}
	}

	private void calcularTotales() {
		BigDecimal montoTotal = BigDecimal.ZERO;
		BigDecimal montoComision = BigDecimal.ZERO;
		BigDecimal montoFee = BigDecimal.ZERO;
		BigDecimal montoIgv = BigDecimal.ZERO;
		try {

			/*
			 * Parametro param =
			 * this.parametroServicio.consultarParametro(UtilWeb
			 * .obtenerEnteroPropertieMaestro( "codigoParametroFee",
			 * "aplicacionDatos"));
			 */

			for (DetalleServicioAgencia detalleServicio : this
					.getListadoDetalleServicioTotal()) {
				montoTotal = montoTotal.add(detalleServicio.getTotalServicio());
				montoComision = montoComision.add(detalleServicio
						.getMontoComision());
				for (DetalleServicioAgencia detalleServicio2 : detalleServicio
						.getServiciosHijos()) {
					if (detalleServicio2.getTipoServicio().isEsImpuesto()) {
						montoIgv = montoIgv.add(detalleServicio2
								.getPrecioUnitario());
					}
				}

				if (detalleServicio.getTipoServicio().getCodigoEntero() != null
						&& detalleServicio.getTipoServicio().isEsFee()) {
					montoFee = montoFee.add(detalleServicio.getTotalServicio());
				}

			}

			montoTotal = montoTotal.add(montoIgv);

		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			montoTotal = BigDecimal.ZERO;
		}

		this.getProgramaNovios().setMontoTotalServicios(montoTotal);
		this.getProgramaNovios().setMontoTotalServiciosPrograma(montoTotal);
		this.getProgramaNovios().setMontoTotalComision(montoComision);
		this.getProgramaNovios().setMontoTotalFee(montoFee);
		this.getProgramaNovios().setMontoTotalIGV(montoIgv);
	}

	private boolean validarServicioAgregar() {
		boolean resultado = true;
		String idFormulario = "idFormNovios";
		if (!this.isServicioFee()) {
			if (this.getServicioNovios().getTipoServicio().getCodigoEntero() == null
					|| this.getServicioNovios().getTipoServicio()
							.getCodigoEntero().intValue() == 0) {
				this.agregarMensaje(idFormulario + ":idSelTipoServicio",
						"Seleccione el tipo de servicio", "",
						FacesMessage.SEVERITY_ERROR);
				resultado = false;
			}
			if (StringUtils.isBlank(this.getServicioNovios()
					.getDescripcionServicio())) {
				this.agregarMensaje(idFormulario + ":idDescServicio",
						"Ingrese la descripcion del servicio", "",
						FacesMessage.SEVERITY_ERROR);
				resultado = false;
			}
			if (this.getServicioNovios().getCantidad() == 0) {
				this.agregarMensaje(idFormulario + ":idCantidad",
						"Ingrese la cantidad", "", FacesMessage.SEVERITY_ERROR);
				resultado = false;
			}
			if (this.getServicioNovios().getPrecioUnitario() == null
					|| this.getServicioNovios().getPrecioUnitario()
							.doubleValue() == 0.0) {
				this.agregarMensaje(idFormulario + ":idPrecUnitario",
						"Ingrese el precio base del servicio", "",
						FacesMessage.SEVERITY_ERROR);
				resultado = false;
			}
			if (this.getServicioNovios().getFechaIda() == null) {
				this.agregarMensaje(idFormulario + ":idFecServicio",
						"Ingrese la fecha del servicio", "",
						FacesMessage.SEVERITY_ERROR);
				resultado = false;
			}
		} else {
			if (this.getServicioNovios().getPrecioUnitario() == null
					|| this.getServicioNovios().getPrecioUnitario()
							.doubleValue() == 0.0) {
				this.agregarMensaje(idFormulario + ":idMonFee",
						"Ingrese el Monto Fee", "", FacesMessage.SEVERITY_ERROR);
				resultado = false;
			}
			if (this.getServicioNovios().getFechaIda() == null) {
				this.agregarMensaje(idFormulario + ":idFecServicioFee",
						"Ingrese la fecha del servicio", "",
						FacesMessage.SEVERITY_ERROR);
				resultado = false;
			}
		}
		return resultado;
	}

	public void consultarDestinos() {
		try {
			this.setListaDestinosBusqueda(null);
			this.setDestinoBusqueda(null);

			List<Destino> listaDestinos = this.soporteServicio.listarDestinos(this.obtenerIdEmpresa());

			this.setListaDestinosBusqueda(listaDestinos);
			this.setListaOrigenesBusqueda(listaDestinos);
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void seleccionarAerolinea(ValueChangeEvent e) {
		Object oe = e.getNewValue();
		try {
			if (oe != null) {
				String valor = oe.toString();

				this.getServicioNovios().getAerolinea()
						.setCodigoEntero(UtilWeb.convertirCadenaEntero(valor));

				this.getServicioNovios().getServicioProveedor()
						.setPorcentajeComision(null);

			}
		} catch (Exception ex) {
			this.getServicioNovios().getServicioProveedor()
					.setPorcentajeComision(BigDecimal.ZERO);
			logger.error(ex.getMessage(), ex);
		}
	}

	public void seleccionarOperadora() {

	}

	public void cargarDatosValores(ValueChangeEvent e) {
		Object oe = e.getNewValue();
		try {
			setListadoEmpresas(null);
			this.getServicioNovios().getServicioProveedor().setProveedor(null);

			if (oe != null) {
				String valor = oe.toString();

				/*
				 * Parametro param =
				 * this.parametroServicio.consultarParametro(UtilWeb
				 * .obtenerEnteroPropertieMaestro( "codigoParametroFee",
				 * "aplicacionDatos"));
				 * this.setServicioFee(valor.equals(param.getValor()));
				 */

				MaestroServicio maestroServicio = this.consultaNegocioServicio
						.consultarMaestroServicio(UtilWeb
								.convertirCadenaEntero(valor), this.obtenerIdEmpresa());

				this.getServicioNovios().setConfiguracionTipoServicio(
						this.soporteServicio
								.consultarConfiguracionServicio(UtilWeb
										.convertirCadenaEntero(valor), this.obtenerIdEmpresa()));

				this.setServicioFee(maestroServicio.isEsFee()
						|| maestroServicio.isEsImpuesto());

				if (!this.isServicioFee()) {
					listaProveedores = this.consultaNegocioServicio
							.proveedoresXServicio(UtilWeb
									.convertirCadenaEntero(valor), this.obtenerIdEmpresa());
					setListadoEmpresas(null);

					SelectItem si = null;
					for (ServicioProveedor servicioProveedor : listaProveedores) {
						si = new SelectItem();
						si.setValue(servicioProveedor.getCodigoEntero());
						si.setLabel(servicioProveedor.getNombreProveedor());
						getListadoEmpresas().add(si);
					}
				}
			} else {
				this.getServicioNovios().setConfiguracionTipoServicio(null);
			}
		} catch (SQLException ex) {
			logger.error(ex.getMessage(), ex);
		} catch (Exception ex) {
			logger.error(ex.getMessage(), ex);
		}
	}

	private Destino obtenerDestinoListado() {
		try {
			for (Destino destino : this.listaDestinosBusqueda) {
				if (destino.getCodigoEntero().intValue() == destino
						.getCodigoSeleccionado().intValue()) {
					return destino;
				}
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	public void buscarDestino() {

	}

	public void buscarOrigen() {

	}

	private Destino obtenerOrigenListado() {
		try {
			for (Destino destino : this.getListaOrigenesBusqueda()) {
				if (destino.getCodigoEntero().intValue() == destino
						.getCodigoSeleccionado().intValue()) {
					return destino;
				}
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	/**
	 * ========================================================================
	 * ==
	 */

	/**
	 * @return the programaNovios
	 */
	public ProgramaNovios getProgramaNovios() {
		if (programaNovios == null) {
			programaNovios = new ProgramaNovios();
		}
		return programaNovios;
	}

	/**
	 * @param programaNovios
	 *            the programaNovios to set
	 */
	public void setProgramaNovios(ProgramaNovios programaNovios) {
		this.programaNovios = programaNovios;
	}

	/**
	 * @return the listadoNovios
	 */
	public List<ProgramaNovios> getListadoNovios() {
		try {
			listadoNovios = this.consultaNegocioServicio
					.consultarNovios(getProgramaNoviosBusqueda());
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}
		return listadoNovios;
	}

	/**
	 * @param listadoNovios
	 *            the listadoNovios to set
	 */
	public void setListadoNovios(List<ProgramaNovios> listadoNovios) {
		this.listadoNovios = listadoNovios;
	}

	/**
	 * @return the clienteBusqueda
	 */
	public Cliente getClienteBusqueda() {
		if (clienteBusqueda == null) {
			clienteBusqueda = new Cliente();
		}
		return clienteBusqueda;
	}

	/**
	 * @param clienteBusqueda
	 *            the clienteBusqueda to set
	 */
	public void setClienteBusqueda(Cliente clienteBusqueda) {
		this.clienteBusqueda = clienteBusqueda;
	}

	/**
	 * @return the listadoClientes
	 */
	public List<Cliente> getListadoClientes() {
		if (listadoClientes == null) {
			listadoClientes = new ArrayList<Cliente>();
		}
		return listadoClientes;
	}

	/**
	 * @param listadoClientes
	 *            the listadoClientes to set
	 */
	public void setListadoClientes(List<Cliente> listadoClientes) {
		this.listadoClientes = listadoClientes;
	}

	/**
	 * @return the programaNoviosBusqueda
	 */
	public ProgramaNovios getProgramaNoviosBusqueda() {
		if (programaNoviosBusqueda == null) {
			programaNoviosBusqueda = new ProgramaNovios();
		}
		return programaNoviosBusqueda;
	}

	/**
	 * @param programaNoviosBusqueda
	 *            the programaNoviosBusqueda to set
	 */
	public void setProgramaNoviosBusqueda(ProgramaNovios programaNoviosBusqueda) {
		this.programaNoviosBusqueda = programaNoviosBusqueda;
	}

	/**
	 * @return the generoCliente
	 */
	public String getGeneroCliente() {
		return generoCliente;
	}

	/**
	 * @param generoCliente
	 *            the generoCliente to set
	 */
	public void setGeneroCliente(String generoCliente) {
		this.generoCliente = generoCliente;
	}

	/**
	 * @return the tipoBusqueda
	 */
	public int getTipoBusqueda() {
		return tipoBusqueda;
	}

	/**
	 * @param tipoBusqueda
	 *            the tipoBusqueda to set
	 */
	public void setTipoBusqueda(int tipoBusqueda) {
		this.tipoBusqueda = tipoBusqueda;
	}

	/**
	 * @return the listadoInvitados
	 */
	public List<Cliente> getListadoInvitados() {
		if (listadoInvitados == null) {
			listadoInvitados = new ArrayList<Cliente>();
		}
		return listadoInvitados;
	}

	/**
	 * @param listadoInvitados
	 *            the listadoInvitados to set
	 */
	public void setListadoInvitados(List<Cliente> listadoInvitados) {
		this.listadoInvitados = listadoInvitados;
	}

	/**
	 * @return the nuevoNovios
	 */
	public boolean isNuevoNovios() {
		return nuevoNovios;
	}

	/**
	 * @param nuevoNovios
	 *            the nuevoNovios to set
	 */
	public void setNuevoNovios(boolean nuevoNovios) {
		this.nuevoNovios = nuevoNovios;
	}

	/**
	 * @return the registroExito
	 */
	public boolean isRegistroExito() {
		return registroExito;
	}

	/**
	 * @param registroExito
	 *            the registroExito to set
	 */
	public void setRegistroExito(boolean registroExito) {
		this.registroExito = registroExito;
	}

	/**
	 * @return the servicioNovios
	 */
	public ServicioNovios getServicioNovios() {
		if (servicioNovios == null) {
			servicioNovios = new ServicioNovios();
		}
		return servicioNovios;
	}

	/**
	 * @param servicioNovios
	 *            the servicioNovios to set
	 */
	public void setServicioNovios(ServicioNovios servicioNovios) {
		this.servicioNovios = servicioNovios;
	}

	/**
	 * @return the servicioFee
	 */
	public boolean isServicioFee() {
		return servicioFee;
	}

	/**
	 * @param servicioFee
	 *            the servicioFee to set
	 */
	public void setServicioFee(boolean servicioFee) {
		this.servicioFee = servicioFee;
	}

	/**
	 * @return the listadoEmpresas
	 */
	public List<SelectItem> getListadoEmpresas() {
		if (listadoEmpresas == null) {
			listadoEmpresas = new ArrayList<SelectItem>();
		}
		return listadoEmpresas;
	}

	/**
	 * @param listadoEmpresas
	 *            the listadoEmpresas to set
	 */
	public void setListadoEmpresas(List<SelectItem> listadoEmpresas) {
		this.listadoEmpresas = listadoEmpresas;
	}

	/**
	 * @return the listaProveedores
	 */
	public List<ServicioProveedor> getListaProveedores() {
		if (listaProveedores == null) {
			listaProveedores = new ArrayList<ServicioProveedor>();
		}
		return listaProveedores;
	}

	/**
	 * @param listaProveedores
	 *            the listaProveedores to set
	 */
	public void setListaProveedores(List<ServicioProveedor> listaProveedores) {
		this.listaProveedores = listaProveedores;
	}

	/**
	 * @return the editarNovios
	 */
	public boolean isEditarNovios() {
		return editarNovios;
	}

	/**
	 * @param editarNovios
	 *            the editarNovios to set
	 */
	public void setEditarNovios(boolean editarNovios) {
		this.editarNovios = editarNovios;
	}

	/**
	 * @return the listaDestinosBusqueda
	 */
	public List<Destino> getListaDestinosBusqueda() {
		if (listaDestinosBusqueda == null) {
			listaDestinosBusqueda = new ArrayList<Destino>();
		}
		return listaDestinosBusqueda;
	}

	/**
	 * @param listaDestinosBusqueda
	 *            the listaDestinosBusqueda to set
	 */
	public void setListaDestinosBusqueda(List<Destino> listaDestinosBusqueda) {
		this.listaDestinosBusqueda = listaDestinosBusqueda;
	}

	/**
	 * @return the listaOrigenesBusqueda
	 */
	public List<Destino> getListaOrigenesBusqueda() {
		if (listaOrigenesBusqueda == null) {
			listaOrigenesBusqueda = new ArrayList<Destino>();
		}
		return listaOrigenesBusqueda;
	}

	/**
	 * @param listaOrigenesBusqueda
	 *            the listaOrigenesBusqueda to set
	 */
	public void setListaOrigenesBusqueda(List<Destino> listaOrigenesBusqueda) {
		this.listaOrigenesBusqueda = listaOrigenesBusqueda;
	}

	/**
	 * @return the destinoBusqueda
	 */
	public Destino getDestinoBusqueda() {
		if (destinoBusqueda == null) {
			destinoBusqueda = new Destino();
		}
		return destinoBusqueda;
	}

	/**
	 * @param destinoBusqueda
	 *            the destinoBusqueda to set
	 */
	public void setDestinoBusqueda(Destino destinoBusqueda) {
		this.destinoBusqueda = destinoBusqueda;
	}

	/**
	 * @return the origenBusqueda
	 */
	public Destino getOrigenBusqueda() {
		if (origenBusqueda == null) {
			origenBusqueda = new Destino();
		}
		return origenBusqueda;
	}

	/**
	 * @param origenBusqueda
	 *            the origenBusqueda to set
	 */
	public void setOrigenBusqueda(Destino origenBusqueda) {
		this.origenBusqueda = origenBusqueda;
	}

	/**
	 * @return the listadoDetalleServicio
	 */
	public List<DetalleServicioAgencia> getListadoDetalleServicio() {
		if (listadoDetalleServicio == null) {
			listadoDetalleServicio = new ArrayList<DetalleServicioAgencia>();
		}
		return listadoDetalleServicio;
	}

	/**
	 * @param listadoDetalleServicio
	 *            the listadoDetalleServicio to set
	 */
	public void setListadoDetalleServicio(
			List<DetalleServicioAgencia> listadoDetalleServicio) {
		this.listadoDetalleServicio = listadoDetalleServicio;
	}

	/**
	 * @return the listadoDetalleServicioTotal
	 */
	public List<DetalleServicioAgencia> getListadoDetalleServicioTotal() {
		if (listadoDetalleServicioTotal == null) {
			listadoDetalleServicioTotal = new ArrayList<DetalleServicioAgencia>();
		}
		return listadoDetalleServicioTotal;
	}

	/**
	 * @param listadoDetalleServicioTotal
	 *            the listadoDetalleServicioTotal to set
	 */
	public void setListadoDetalleServicioTotal(
			List<DetalleServicioAgencia> listadoDetalleServicioTotal) {
		this.listadoDetalleServicioTotal = listadoDetalleServicioTotal;
	}

	/**
	 * @return the editarComision
	 */
	public boolean isEditarComision() {
		return editarComision;
	}

	/**
	 * @param editarComision
	 *            the editarComision to set
	 */
	public void setEditarComision(boolean editarComision) {
		this.editarComision = editarComision;
	}

}
