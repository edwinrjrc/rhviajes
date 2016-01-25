/**
 * 
 */
package pe.com.viajes.web.faces;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.naming.NamingException;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpSession;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.base.CorreoElectronico;
import pe.com.viajes.bean.negocio.Cliente;
import pe.com.viajes.bean.negocio.Contacto;
import pe.com.viajes.bean.negocio.Direccion;
import pe.com.viajes.bean.negocio.Telefono;
import pe.com.viajes.bean.negocio.Ubigeo;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.negocio.exception.NoEnvioDatoException;
import pe.com.viajes.negocio.exception.ValidacionException;
import pe.com.viajes.web.servicio.ConsultaNegocioServicio;
import pe.com.viajes.web.servicio.NegocioServicio;
import pe.com.viajes.web.servicio.SoporteServicio;
import pe.com.viajes.web.servicio.UtilNegocioServicio;
import pe.com.viajes.web.servicio.impl.ConsultaNegocioServicioImpl;
import pe.com.viajes.web.servicio.impl.NegocioServicioImpl;
import pe.com.viajes.web.servicio.impl.SoporteServicioImpl;
import pe.com.viajes.web.servicio.impl.UtilNegocioServicioImpl;
import pe.com.viajes.web.util.UtilWeb;

/**
 * @author Edwin
 *
 */

@ManagedBean(name = "clienteMBean")
@SessionScoped()
public class ClienteMBean extends BaseMBean {

	private final static Logger logger = Logger.getLogger(ClienteMBean.class);

	/**
	 * 
	 */
	private static final long serialVersionUID = -3161805888946994195L;

	private List<Cliente> listaClientes;
	private List<Cliente> listaClientesCumples;

	private Cliente cliente;
	private Cliente clienteBusqueda;
	private Direccion direccion;
	private Contacto contacto;

	private boolean nuevoCliente;
	private boolean editarCliente;
	private boolean nuevaDireccion;
	private boolean editarDireccion;
	private boolean nuevoContacto;
	private boolean editarContacto;
	private boolean direccionAgregada;
	private boolean contactoAgregada;
	private boolean busquedaRealizada;
	private boolean personaNatural;

	private String nombreFormulario;
	private String nombreFormularioDireccion;
	private String nombreFormularioContacto;
	private String pestanaActiva = "idFC01";
	private String fechaHoy;

	private List<SelectItem> listaProvincia;
	private List<SelectItem> listaDistrito;

	private SoporteServicio soporteServicio;
	private NegocioServicio negocioServicio;
	private UtilNegocioServicio utilNegocioServicio;
	private ConsultaNegocioServicio consultaNegocioServicio;

	/**
	 * 
	 */
	public ClienteMBean() {
		try {
			ServletContext servletContext = (ServletContext) FacesContext
					.getCurrentInstance().getExternalContext().getContext();
			soporteServicio = new SoporteServicioImpl(servletContext);
			negocioServicio = new NegocioServicioImpl(servletContext);
			utilNegocioServicio = new UtilNegocioServicioImpl(servletContext);
			consultaNegocioServicio = new ConsultaNegocioServicioImpl(
					servletContext);
		} catch (NamingException e) {
			logger.error(e.getMessage(), e);
		}
	}

	public String inicioAdministrador() {
		buscarCliente();
		this.setBusquedaRealizada(false);
		return "irAdministrarCliente";
	}

	public void buscarCliente() {
		try {
			this.setShowModal(false);
			
			getClienteBusqueda().setEmpresa(this.obtenerEmpresa());
			
			this.setListaClientes(this.consultaNegocioServicio
					.consultarCliente2(getClienteBusqueda()));
			this.setBusquedaRealizada(true);
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}
	}

	public void ejecutarMetodo(ActionEvent e) {
		try {
			this.setShowModal(false);
			int tipoDocRUC = UtilWeb.obtenerEnteroPropertieMaestro(
					"tipoDocumentoRUC", "aplicacionDatos");
			this.setListaClientes(null);

			if (validarCliente(e)) {
				if (validarDireccionCliente(e)) {
					if (validarContactoCliente(e)) {
						if (validarTelefonoCliente()) {
							if (this.isNuevoCliente()) {
								HttpSession session = obtenerSession(false);
								Usuario usuario = (Usuario) session
										.getAttribute("usuarioSession");
								getCliente().setUsuarioCreacion(
										usuario);
								getCliente().setIpCreacion(
										obtenerRequest().getRemoteAddr());
								if (tipoDocRUC == getCliente()
										.getDocumentoIdentidad()
										.getTipoDocumento().getCodigoEntero()
										.intValue()) {
									getCliente().setNombres(
											getCliente().getRazonSocial());
								}

								this.setShowModal(negocioServicio
										.registrarCliente(getCliente()));
								this.setTipoModal("1");
								this.setMensajeModal("Cliente registrado Satisfactoriamente");
							} else if (this.isEditarCliente()) {
								HttpSession session = obtenerSession(false);
								Usuario usuario = (Usuario) session
										.getAttribute("usuarioSession");
								getCliente().setUsuarioModificacion(
										usuario);
								getCliente().setIpModificacion(
										obtenerRequest().getRemoteAddr());
								if (tipoDocRUC == getCliente()
										.getDocumentoIdentidad()
										.getTipoDocumento().getCodigoEntero()
										.intValue()) {
									getCliente().setNombres(
											getCliente().getRazonSocial());
								}

								this.mostrarMensajeExito("Cliente actualizado Satisfactoriamente");
							}
						} else {
							this.mostrarMensajeError("Debe ingresar por lo menos un telefono, en la direccion o el contacto");
						}

					} else {
						this.mostrarMensajeError("No se ha agregado ningun contacto para el cliente, para cliente personal natural registre como contacto la mismo persona");
					}
				} else {
					this.mostrarMensajeError("No se ha agregado ninguna dirección al proveedor");
				}
			}
		} catch (NoEnvioDatoException ex) {
			this.mostrarMensajeError(ex.getMessage());
			logger.error(ex.getMessage(), ex);
		} catch (Exception ex) {
			this.mostrarMensajeError(ex.getMessage());
			logger.error(ex.getMessage(), ex);
		}
	}

	private boolean validarTelefonoCliente() {
		boolean resultado = false;

		if (false) {
			List<Direccion> listaDire = this.getCliente().getListaDirecciones();
			for (Direccion direccion : listaDire) {
				List<Telefono> listTelefono = direccion.getTelefonos();
				for (Telefono telefono : listTelefono) {
					if (StringUtils.isNotBlank(telefono.getNumeroTelefono())) {
						resultado = true;
						break;
					}
				}
			}
			if (!resultado) {
				List<Contacto> listaContacto = this.getCliente()
						.getListaContactos();
				for (Contacto contacto : listaContacto) {
					List<Telefono> listTelefono = contacto.getListaTelefonos();
					for (Telefono telefono : listTelefono) {
						if (StringUtils
								.isNotBlank(telefono.getNumeroTelefono())) {
							resultado = true;
							break;
						}
					}
				}
			}
		}

		resultado = true;

		return resultado;
	}

	private boolean validarContactoCliente(ActionEvent e) {
		boolean resultado = true;

		resultado = !(this.getCliente().getListaContactos().isEmpty());

		resultado = true;

		return resultado;
	}

	private boolean validarDireccionCliente(ActionEvent e)
			throws NoEnvioDatoException {
		boolean resultado = true;

		if (false) {
			resultado = !(this.getCliente().getListaDirecciones().isEmpty());

			int principales = 0;
			if (resultado) {
				for (Direccion direccion : this.getCliente()
						.getListaDirecciones()) {
					if (direccion.isPrincipal()) {
						principales++;
					}
				}
			}

			if (principales == 0) {
				throw new NoEnvioDatoException("1010",
						"Debe ingresar una direccion principal");
			}
		}

		return resultado;
	}

	private boolean validarCliente(ActionEvent e) {
		boolean resultado = true;
		String idFormulario = "idFormProveedor";
		int tipoDocDNI = UtilWeb.obtenerEnteroPropertieMaestro(
				"tipoDocumentoDNI", "aplicacionDatos");
		int tipoDocCE = UtilWeb.obtenerEnteroPropertieMaestro(
				"tipoDocumentoCE", "aplicacionDatos");
		int tipoDocRUC = UtilWeb.obtenerEnteroPropertieMaestro(
				"tipoDocumentoRUC", "aplicacionDatos");
		
		if (StringUtils.isBlank(getCliente().getDocumentoIdentidad()
				.getNumeroDocumento())) {
			this.agregarMensaje(idFormulario + ":idFPInNumDoc",
					"Seleccione el tipo de documento", "",
					FacesMessage.SEVERITY_ERROR);
		}
		if (getCliente().getDocumentoIdentidad().getTipoDocumento()
				.getCodigoEntero() == null
				|| getCliente().getDocumentoIdentidad().getTipoDocumento()
						.getCodigoEntero().intValue() == 0) {
			this.agregarMensaje(idFormulario + ":idFPSelTipoDoc",
					"Seleccione el tipo de documento", "",
					FacesMessage.SEVERITY_ERROR);
		} else {
			if (tipoDocDNI == getCliente().getDocumentoIdentidad()
					.getTipoDocumento().getCodigoEntero().intValue()
					|| tipoDocCE == getCliente().getDocumentoIdentidad()
							.getTipoDocumento().getCodigoEntero().intValue()) {
				if (StringUtils.isBlank(getCliente().getApellidoMaterno())) {
					this.agregarMensaje(idFormulario + ":idApeMatPro",
							"Ingrese el apellido materno", "",
							FacesMessage.SEVERITY_ERROR);
					resultado = false;
				}
				if (StringUtils.isBlank(getCliente().getApellidoPaterno())) {
					this.agregarMensaje(idFormulario + ":idApePatPro",
							"Ingrese el apellido paterno", "",
							FacesMessage.SEVERITY_ERROR);
					resultado = false;
				}
				if (StringUtils.isBlank(getCliente().getApellidoPaterno())) {
					this.agregarMensaje(idFormulario + ":idApePatPro",
							"Ingrese el apellido paterno", "",
							FacesMessage.SEVERITY_ERROR);
					resultado = false;
				}
				if (StringUtils.isBlank(getCliente().getNombres())) {
					this.agregarMensaje(idFormulario + ":idNomPro",
							"Ingrese los nombres", "",
							FacesMessage.SEVERITY_ERROR);
					resultado = false;
				}
				if (UtilWeb.validaEnteroEsNuloOCero(getCliente()
						.getEstadoCivil().getCodigoEntero())) {
					this.agregarMensaje(idFormulario + ":idFPSelEstCivil",
							"Seleccione el estado civil", "",
							FacesMessage.SEVERITY_ERROR);
					resultado = false;
				}
				if (StringUtils.isBlank(getCliente().getGenero()
						.getCodigoCadena())) {
					this.agregarMensaje(idFormulario + ":idFPSelGenero",
							"Seleccione el genero", "",
							FacesMessage.SEVERITY_ERROR);
					resultado = false;
				}
				if (getCliente().getFechaNacimiento() == null) {
					this.agregarMensaje(idFormulario + ":idFPFecNacimiento",
							"Seleccione la fecha de nacimiento", "",
							FacesMessage.SEVERITY_ERROR);
					resultado = false;
				}
			}
			if (tipoDocRUC == getCliente().getDocumentoIdentidad()
					.getTipoDocumento().getCodigoEntero().intValue()) {
				if (StringUtils.isBlank(getCliente().getRazonSocial())) {
					this.agregarMensaje(idFormulario + ":idRazSocPro",
							"Ingrese la razon social", "",
							FacesMessage.SEVERITY_ERROR);
					resultado = false;
				}
			}
		}

		return resultado;
	}

	public void consultarCliente(int idcliente) {
		try {
			this.setCliente(consultaNegocioServicio.consultarCliente(idcliente, this.obtenerIdEmpresa()));
			this.setNuevoCliente(false);
			this.setEditarCliente(true);
			this.setNombreFormulario("Editar Cliente");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void nuevoCliente() {
		this.setNuevoCliente(true);
		this.setEditarCliente(false);
		this.setCliente(null);
		this.setNombreFormulario("Nuevo Cliente");
		this.getCliente().setEmpresa(this.obtenerEmpresa());
	}

	public void nuevaDireccion() {
		this.setNombreFormularioDireccion("Nueva Direcci�n");
		this.setNuevaDireccion(true);
		this.setEditarDireccion(false);
		this.setListaDistrito(null);
		this.setListaProvincia(null);
		this.setDireccion(null);
		this.setDireccionAgregada(false);
		this.getDireccion().setEmpresa(this.obtenerEmpresa());
		
		this.getDireccion().setPais(this.getCliente().getNacionalidad());
	}

	public void agregarDireccion(ActionEvent e) {
		try {
			this.setDireccionAgregada(false);
			
			this.getDireccion().setNacional((this.getDireccion().getPais().getCodigoEntero().intValue() == UtilWeb.obtenerEnteroPropertieMaestro("codigoPaisPeru", "aplicacionDatos")));
			
			this.getDireccion().setUsuarioCreacion(this.obtenerUsuarioSession());
			this.getDireccion().setIpCreacion(this.obtenerIpMaquina());
			this.getDireccion().setEmpresa(this.obtenerEmpresa());
			
			if (this.validarDireccion(e)) {
				if (this.isNuevaDireccion()) {
					this.getCliente()
							.getListaDirecciones()
							.add(utilNegocioServicio
									.agregarDireccion(getDireccion()));
					this.setDireccionAgregada(true);
				} else {
					this.getCliente().getListaDirecciones()
							.remove(getDireccion());
					this.getCliente()
							.getListaDirecciones()
							.add(utilNegocioServicio
									.agregarDireccion(getDireccion()));
					this.setDireccionAgregada(true);
				}
			}
		} catch (SQLException ex) {
			this.mostrarMensajeError(ex.getMessage());
			logger.error(ex.getMessage(), ex);
		} catch (Exception ex) {
			this.mostrarMensajeError(ex.getMessage());
			logger.error(ex.getMessage(), ex);
		}
	}

	private boolean validarDireccion(ActionEvent e) {
		boolean resultado = true;
		String idFormulario = "idFDPr";
		if (getDireccion().getVia().getCodigoEntero() == null) {
			this.agregarMensaje(idFormulario + ":idFDSelTipoVia",
					"Seleccione el tipo de via", "",
					FacesMessage.SEVERITY_ERROR);
			resultado = false;
			this.setPestanaActiva("idFC01");
		} else if (getDireccion().getVia().getCodigoEntero().intValue() == 0) {
			this.agregarMensaje(idFormulario + ":idFDSelTipoVia",
					"Seleccione el tipo de via", "",
					FacesMessage.SEVERITY_ERROR);
			resultado = false;
			this.setPestanaActiva("idFD01");
		}
		if (StringUtils.isBlank(getDireccion().getNombreVia())) {
			this.agregarMensaje(idFormulario + ":idFDInNomVia",
					"Ingrese el nombre de via", "", FacesMessage.SEVERITY_ERROR);
			resultado = false;
			this.setPestanaActiva("idFD01");
		}
		if (StringUtils.isBlank(getDireccion().getUbigeo().getDepartamento()
				.getCodigoCadena())) {
			this.agregarMensaje(idFormulario + ":idDepartamentoDireccion",
					"Seleccione el departamento", "",
					FacesMessage.SEVERITY_ERROR);
			resultado = false;
			this.setPestanaActiva("idFD01");
		}
		if (StringUtils.isBlank(getDireccion().getUbigeo().getProvincia()
				.getCodigoCadena())) {
			this.agregarMensaje(idFormulario + ":idProvinciaDireccion",
					"Seleccione la provincia", "", FacesMessage.SEVERITY_ERROR);
			resultado = false;
			this.setPestanaActiva("idFD01");
		}
		if (StringUtils.isBlank(getDireccion().getUbigeo().getDistrito()
				.getCodigoCadena())) {
			this.agregarMensaje(idFormulario + ":idDistritoDireccion",
					"Seleccione el distrito", "", FacesMessage.SEVERITY_ERROR);
			resultado = false;
			this.setPestanaActiva("idFD01");
		}
		if (StringUtils.isNotBlank(getDireccion().getReferencia())
				&& UtilWeb.obtenerLongitud(getDireccion().getReferencia()) > 300) {
			this.agregarMensaje(
					idFormulario + ":idTARefere",
					"El tamaño de referencia supera al permitido, maximo 300 caracteres",
					"", FacesMessage.SEVERITY_ERROR);
			resultado = false;
			this.setPestanaActiva("idFD01");
		}
		if (StringUtils.isNotBlank(getDireccion().getObservaciones())
				&& UtilWeb.obtenerLongitud(getDireccion().getObservaciones()) > 300) {
			this.agregarMensaje(
					idFormulario + ":idTAObser",
					"El tamaño de observaciones supera al permitido, maximo 300 caracteres",
					"", FacesMessage.SEVERITY_ERROR);
			resultado = false;
			this.setPestanaActiva("idFD01");
		}
		if (resultado) {
			List<Telefono> listTelefonos = getDireccion().getTelefonos();
			if (!listTelefonos.isEmpty()) {
				for (Telefono telefono : listTelefonos) {
					if (StringUtils.isBlank(telefono.getNumeroTelefono())) {
						this.agregarMensaje(idFormulario + ":idTablaTelDir",
								"Complete los telefonos vacios", "",
								FacesMessage.SEVERITY_ERROR);
						resultado = false;
						this.setPestanaActiva("idFD02");
						break;
					}
				}
			}
		}

		return resultado;
	}

	public void buscarProvincias() {
		this.setListaProvincia(null);
		this.setListaDistrito(null);
		this.getDireccion().getUbigeo().setProvincia(null);
		this.getDireccion().getUbigeo().setDistrito(null);
	}

	public void buscarDistrito() {
		this.setListaDistrito(null);
		this.getDireccion().getUbigeo().setDistrito(null);
	}

	public void eliminarTelefono(Telefono telefono) {
		this.getDireccion().getTelefonos().remove(telefono);

	}

	public void agregarTelefonoDireccion() {
		Telefono telefono = new Telefono();
		telefono.setId(this.getDireccion().getTelefonos().size() + 1);
		telefono.setUsuarioCreacion(this.obtenerUsuarioSession());
		telefono.setIpCreacion(this.obtenerIpMaquina());
		this.getDireccion().getTelefonos().add(telefono);
	}

	public void editarDireccionCliente(Direccion direccion) {
		this.setNombreFormularioDireccion("Editar Dirección");
		this.setNuevaDireccion(false);
		this.setEditarDireccion(true);
		this.setDireccion(direccion);
	}

	public void eliminarDireccionCliente(Direccion direccion) {
		this.getCliente().getListaDirecciones().remove(direccion);
	}

	public void nuevoContacto() {
		this.setContacto(null);
		this.setNombreFormularioContacto("Nuevo Contacto");
		this.setNuevoContacto(true);
		this.setEditarContacto(false);
		this.setContactoAgregada(false);
		this.getContacto().setEmpresa(this.obtenerEmpresa());

		if (this.getCliente().getListaContactos().isEmpty()
				&& StringUtils.isNotBlank(this.getCliente()
						.getApellidoPaterno())
				&& StringUtils.isNotBlank(this.getCliente().getNombres())) {
			this.getContacto().setDocumentoIdentidad(
					this.getCliente().getDocumentoIdentidad());
			this.getContacto().setNombres(this.getCliente().getNombres());
			this.getContacto().setApellidoPaterno(
					this.getCliente().getApellidoPaterno());
			this.getContacto().setApellidoMaterno(
					this.getCliente().getApellidoMaterno());
		}
	}

	public void agregarContacto(ActionEvent e) {
		try {
			if (this.validarContacto(e)) {
				HttpSession session = obtenerSession(false);
				Usuario usuario = (Usuario) session
						.getAttribute("usuarioSession");
				getContacto().setUsuarioCreacion(usuario);
				getContacto().setIpCreacion(obtenerRequest().getRemoteAddr());
				getContacto().setUsuarioModificacion(usuario);
				getContacto().setIpModificacion(
						obtenerRequest().getRemoteAddr());
				if (this.isEditarContacto()) {
					this.getCliente().getListaContactos().remove(getContacto());
				}

				this.getCliente()
						.getListaContactos()
						.add(utilNegocioServicio.agregarContacto(getContacto()));
				this.setContactoAgregada(true);
			}
		} catch (SQLException ex) {
			this.mostrarMensajeError(ex.getMessage());
			logger.error(ex.getMessage(), ex);
		} catch (Exception ex) {
			this.mostrarMensajeError(ex.getMessage());
			logger.error(ex.getMessage(), ex);
		}
	}

	private boolean validarContacto(ActionEvent e) throws ValidacionException {
		boolean resultado = true;
		String idFormulario = "idFCPr";
		int tipoDocDNI = UtilWeb.obtenerEnteroPropertieMaestro(
				"tipoDocumentoDNI", "aplicacionDatos");
		int tipoDocCE = UtilWeb.obtenerEnteroPropertieMaestro(
				"tipoDocumentoCE", "aplicacionDatos");
		int tipoDocRUC = UtilWeb.obtenerEnteroPropertieMaestro(
				"tipoDocumentoRUC", "aplicacionDatos");
		if (StringUtils.isBlank(getContacto().getApellidoPaterno())) {
			this.agregarMensaje(idFormulario + ":idApePat",
					"Ingrese el apellido paterno", "",
					FacesMessage.SEVERITY_ERROR);
			resultado = false;
			this.setPestanaActiva("idFC01");
		}
		/*if (StringUtils.isBlank(getContacto().getApellidoMaterno())) {
			this.agregarMensaje(idFormulario + ":idApeMat",
					"Ingrese el apellido materno", "",
					FacesMessage.SEVERITY_ERROR);
			resultado = false;
			this.setPestanaActiva("idFC01");
		}*/
		if (StringUtils.isBlank(getContacto().getNombres())) {
			this.agregarMensaje(idFormulario + ":idForProNom",
					"Ingrese los nombres", "", FacesMessage.SEVERITY_ERROR);
			resultado = false;
			this.setPestanaActiva("idFC01");
		}
		if (getContacto().getArea().getCodigoEntero() == null) {
			this.agregarMensaje(idFormulario + ":idSelAreCon",
					"Seleccione el area del contacto", "",
					FacesMessage.SEVERITY_ERROR);
			resultado = false;
			this.setPestanaActiva("idFC01");
		}
		if (StringUtils.isNotBlank(getContacto().getDocumentoIdentidad()
				.getNumeroDocumento())) {
			if (getContacto().getDocumentoIdentidad().getTipoDocumento()
					.getCodigoEntero() != null) {
				if (getContacto().getDocumentoIdentidad().getTipoDocumento()
						.getCodigoEntero().intValue() == tipoDocDNI) {
					if (getContacto().getDocumentoIdentidad()
							.getNumeroDocumento().length() != 8) {
						this.agregarMensaje(
								idFormulario + ":idNumDoc",
								"El número de documento debe ser de 8 caracteres",
								"", FacesMessage.SEVERITY_ERROR);
						resultado = false;
						this.setPestanaActiva("idFC01");
					}
				}
				if (getContacto().getDocumentoIdentidad().getTipoDocumento()
						.getCodigoEntero().intValue() == tipoDocCE) {
					if (getContacto().getDocumentoIdentidad()
							.getNumeroDocumento().length() != 9) {
						this.agregarMensaje(
								idFormulario + ":idNumDoc",
								"El número de documento debe ser de 9 caracteres",
								"", FacesMessage.SEVERITY_ERROR);
						resultado = false;
						this.setPestanaActiva("idFC01");
					}
				}
				if (getContacto().getDocumentoIdentidad().getTipoDocumento()
						.getCodigoEntero().intValue() == tipoDocRUC) {
					if (getContacto().getDocumentoIdentidad()
							.getNumeroDocumento().length() != 11) {
						this.agregarMensaje(
								idFormulario + ":idNumDoc",
								"El número de documento debe ser de 11 caracteres",
								"", FacesMessage.SEVERITY_ERROR);
						resultado = false;
						this.setPestanaActiva("idFC01");
					}
				}
			}
		}
		if (resultado) {
			List<Telefono> listTelefonos = getContacto().getListaTelefonos();
			if (!listTelefonos.isEmpty()) {
				for (Telefono telefono : listTelefonos) {
					if (StringUtils.isBlank(telefono.getNumeroTelefono())) {
						this.agregarMensaje(idFormulario
								+ ":idTablaTelefonosContacto",
								"Complete los telefonos vacios", "",
								FacesMessage.SEVERITY_ERROR);
						resultado = false;
						this.setPestanaActiva("idFC02");
						break;
					}
				}
			}
		}

		if (resultado) {
			List<CorreoElectronico> listCorreos = getContacto()
					.getListaCorreos();
			if (!listCorreos.isEmpty()) {
				for (CorreoElectronico correo : listCorreos) {
					if (StringUtils.isBlank(correo.getDireccion())) {
						this.agregarMensaje(idFormulario
								+ ":idTablaCorreoContacto",
								"Complete los correos electronicos vacios", "",
								FacesMessage.SEVERITY_ERROR);
						resultado = false;
						this.setPestanaActiva("idFC03");
						break;
					}
					else if (!UtilWeb.validarCorreo(correo.getDireccion())) {
						this.agregarMensaje(idFormulario
								+ ":idTablaCorreoContacto",
								"Error en el correo, por favor corrija", "",
								FacesMessage.SEVERITY_ERROR);
						resultado = false;
						this.setPestanaActiva("idFC03");
						break;
					}
				}
			}
		}

		return resultado;
	}

	public void editarContactoCliente(Contacto contactoLista) {
		this.setNombreFormularioContacto("Editar Contacto");
		this.setNuevoContacto(false);
		this.setEditarContacto(true);
		this.setContacto(contactoLista);
	}

	public void eliminarContactoCliente(Contacto contactoLista) {
		this.getCliente().getListaContactos().remove(contactoLista);
	}

	public void agregarTelefonoContacto() {
		Telefono telefono = new Telefono();
		telefono.setId(this.getContacto().getListaTelefonos().size() + 1);
		telefono.setUsuarioCreacion(this.obtenerUsuarioSession());
		telefono.setIpCreacion(this.obtenerIpMaquina());
		this.getContacto().getListaTelefonos().add(telefono);
	}

	public void agregarCorreoContacto() {
		this.getContacto().getListaCorreos().add(new CorreoElectronico());
	}

	public void eliminarTelefonoContacto(Telefono telefono) {
		this.getContacto().getListaTelefonos().remove(telefono);
	}

	public void eliminarCorreoContacto(CorreoElectronico correo) {
		this.getContacto().getListaCorreos().remove(correo);
	}
	
	public void cambiarTipoDocumento(ValueChangeEvent e){
		Object valor = e.getNewValue();
		this.setPersonaNatural(false);
		if (valor instanceof Integer){
			Integer tipoDocumento = (Integer) valor;
			if (tipoDocumento.intValue() == 1 ){
				this.setPersonaNatural(true);
			}
			else if (tipoDocumento.intValue() == 2){
				this.setPersonaNatural(true);
			}
			else if (tipoDocumento.intValue() == 4){
				this.setPersonaNatural(true);
			}
		}
	}

	/**
	 * @return the cliente
	 */
	public Cliente getCliente() {
		if (cliente == null) {
			cliente = new Cliente();
		}
		return cliente;
	}

	/**
	 * @param cliente
	 *            the cliente to set
	 */
	public void setCliente(Cliente cliente) {
		this.cliente = cliente;
	}

	/**
	 * @return the direccion
	 */
	public Direccion getDireccion() {
		if (direccion == null) {
			direccion = new Direccion();
		}
		return direccion;
	}

	/**
	 * @param direccion
	 *            the direccion to set
	 */
	public void setDireccion(Direccion direccion) {
		this.direccion = direccion;
	}

	/**
	 * @return the contacto
	 */
	public Contacto getContacto() {
		if (contacto == null) {
			contacto = new Contacto();
		}
		return contacto;
	}

	/**
	 * @param contacto
	 *            the contacto to set
	 */
	public void setContacto(Contacto contacto) {
		this.contacto = contacto;
	}

	/**
	 * @return the nuevoCliente
	 */
	public boolean isNuevoCliente() {
		return nuevoCliente;
	}

	/**
	 * @param nuevoCliente
	 *            the nuevoCliente to set
	 */
	public void setNuevoCliente(boolean nuevoCliente) {
		this.nuevoCliente = nuevoCliente;
	}

	/**
	 * @return the editarCliente
	 */
	public boolean isEditarCliente() {
		return editarCliente;
	}

	/**
	 * @param editarCliente
	 *            the editarCliente to set
	 */
	public void setEditarCliente(boolean editarCliente) {
		this.editarCliente = editarCliente;
	}

	/**
	 * @return the nuevaDireccion
	 */
	public boolean isNuevaDireccion() {
		return nuevaDireccion;
	}

	/**
	 * @param nuevaDireccion
	 *            the nuevaDireccion to set
	 */
	public void setNuevaDireccion(boolean nuevaDireccion) {
		this.nuevaDireccion = nuevaDireccion;
	}

	/**
	 * @return the editarDireccion
	 */
	public boolean isEditarDireccion() {
		return editarDireccion;
	}

	/**
	 * @param editarDireccion
	 *            the editarDireccion to set
	 */
	public void setEditarDireccion(boolean editarDireccion) {
		this.editarDireccion = editarDireccion;
	}

	/**
	 * @return the nuevoContacto
	 */
	public boolean isNuevoContacto() {
		return nuevoContacto;
	}

	/**
	 * @param nuevoContacto
	 *            the nuevoContacto to set
	 */
	public void setNuevoContacto(boolean nuevoContacto) {
		this.nuevoContacto = nuevoContacto;
	}

	/**
	 * @return the editarContacto
	 */
	public boolean isEditarContacto() {
		return editarContacto;
	}

	/**
	 * @param editarContacto
	 *            the editarContacto to set
	 */
	public void setEditarContacto(boolean editarContacto) {
		this.editarContacto = editarContacto;
	}

	/**
	 * @return the direccionAgregada
	 */
	public boolean isDireccionAgregada() {
		return direccionAgregada;
	}

	/**
	 * @param direccionAgregada
	 *            the direccionAgregada to set
	 */
	public void setDireccionAgregada(boolean direccionAgregada) {
		this.direccionAgregada = direccionAgregada;
	}

	/**
	 * @return the contactoAgregada
	 */
	public boolean isContactoAgregada() {
		return contactoAgregada;
	}

	/**
	 * @param contactoAgregada
	 *            the contactoAgregada to set
	 */
	public void setContactoAgregada(boolean contactoAgregada) {
		this.contactoAgregada = contactoAgregada;
	}

	/**
	 * @return the nombreFormulario
	 */
	public String getNombreFormulario() {
		return nombreFormulario;
	}

	/**
	 * @param nombreFormulario
	 *            the nombreFormulario to set
	 */
	public void setNombreFormulario(String nombreFormulario) {
		this.nombreFormulario = nombreFormulario;
	}

	/**
	 * @return the nombreFormularioDireccion
	 */
	public String getNombreFormularioDireccion() {
		return nombreFormularioDireccion;
	}

	/**
	 * @param nombreFormularioDireccion
	 *            the nombreFormularioDireccion to set
	 */
	public void setNombreFormularioDireccion(String nombreFormularioDireccion) {
		this.nombreFormularioDireccion = nombreFormularioDireccion;
	}

	/**
	 * @return the nombreFormularioContacto
	 */
	public String getNombreFormularioContacto() {
		return nombreFormularioContacto;
	}

	/**
	 * @param nombreFormularioContacto
	 *            the nombreFormularioContacto to set
	 */
	public void setNombreFormularioContacto(String nombreFormularioContacto) {
		this.nombreFormularioContacto = nombreFormularioContacto;
	}

	/**
	 * @return the pestanaActiva
	 */
	public String getPestanaActiva() {
		return pestanaActiva;
	}

	/**
	 * @param pestanaActiva
	 *            the pestanaActiva to set
	 */
	public void setPestanaActiva(String pestanaActiva) {
		this.pestanaActiva = pestanaActiva;
	}

	/**
	 * @return the listaProvincia
	 */
	public List<SelectItem> getListaProvincia() {
		try {
			if (listaProvincia == null || listaProvincia.isEmpty()) {
				List<BaseVO> lista = soporteServicio
						.listarCatalogoProvincia(this.getDireccion()
								.getUbigeo().getDepartamento()
								.getCodigoCadena(), this.obtenerIdEmpresa());
				listaProvincia = UtilWeb.convertirSelectItem(lista);
			}
		} catch (SQLException ex) {
			listaProvincia = new ArrayList<SelectItem>();
			logger.error(ex.getMessage(), ex);
		} catch (Exception ex) {
			listaProvincia = new ArrayList<SelectItem>();
			logger.error(ex.getMessage(), ex);
		}
		return listaProvincia;
	}

	/**
	 * @param listaProvincia
	 *            the listaProvincia to set
	 */
	public void setListaProvincia(List<SelectItem> listaProvincia) {
		this.listaProvincia = listaProvincia;
	}

	/**
	 * @return the listaDistrito
	 */
	public List<SelectItem> getListaDistrito() {
		try {
			if (listaDistrito == null || listaDistrito.isEmpty()) {
				Ubigeo ubigeoLocal = this.getDireccion().getUbigeo();
				List<BaseVO> lista = soporteServicio.listarCatalogoDistrito(
						ubigeoLocal.getDepartamento().getCodigoCadena(),
						ubigeoLocal.getProvincia().getCodigoCadena(), this.obtenerIdEmpresa());
				listaDistrito = UtilWeb.convertirSelectItem(lista);
			}

		} catch (SQLException ex) {
			listaDistrito = new ArrayList<SelectItem>();
			logger.error(ex.getMessage(), ex);
		} catch (Exception ex) {
			listaDistrito = new ArrayList<SelectItem>();
			logger.error(ex.getMessage(), ex);
		}
		return listaDistrito;
	}

	/**
	 * @param listaDistrito
	 *            the listaDistrito to set
	 */
	public void setListaDistrito(List<SelectItem> listaDistrito) {
		this.listaDistrito = listaDistrito;
	}

	/**
	 * @return the listaClientes
	 */
	public List<Cliente> getListaClientes() {
		try {
			this.setShowModal(false);
			if (!this.isBusquedaRealizada()) {
				
				getClienteBusqueda().setEmpresa(this.obtenerEmpresa());
				
				this.setListaClientes(this.consultaNegocioServicio
						.consultarCliente2(getClienteBusqueda()));
			}
		} catch (SQLException ex) {
			logger.error(ex.getMessage(), ex);
		} catch (Exception ex) {
			logger.error(ex.getMessage(), ex);
		}

		return listaClientes;
	}

	/**
	 * @param listaClientes
	 *            the listaClientes to set
	 */
	public void setListaClientes(List<Cliente> listaClientes) {
		this.listaClientes = listaClientes;
	}

	/**
	 * @return the busquedaRealizada
	 */
	public boolean isBusquedaRealizada() {
		return busquedaRealizada;
	}

	/**
	 * @param busquedaRealizada
	 *            the busquedaRealizada to set
	 */
	public void setBusquedaRealizada(boolean busquedaRealizada) {
		this.busquedaRealizada = busquedaRealizada;
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
	 * @return the listaClientesCumples
	 */
	public List<Cliente> getListaClientesCumples() {
		try {

			listaClientesCumples = this.consultaNegocioServicio
					.listarClientesCumples(this.obtenerIdEmpresa());
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}

		return listaClientesCumples;
	}

	/**
	 * @param listaClientesCumples
	 *            the listaClientesCumples to set
	 */
	public void setListaClientesCumples(List<Cliente> listaClientesCumples) {
		this.listaClientesCumples = listaClientesCumples;
	}

	/**
	 * @return the fechaHoy
	 */
	public String getFechaHoy() {

		Calendar cal = Calendar.getInstance();

		fechaHoy = "" + UtilWeb.diaHoy() + ", " + cal.get(Calendar.DATE)
				+ " de " + UtilWeb.mesHoy() + " de " + cal.get(Calendar.YEAR);
		return fechaHoy;
	}

	/**
	 * @param fechaHoy
	 *            the fechaHoy to set
	 */
	public void setFechaHoy(String fechaHoy) {
		this.fechaHoy = fechaHoy;
	}

	/**
	 * @return the personaNatural
	 */
	public boolean isPersonaNatural() {
		return personaNatural;
	}

	/**
	 * @param personaNatural the personaNatural to set
	 */
	public void setPersonaNatural(boolean personaNatural) {
		this.personaNatural = personaNatural;
	}

}
