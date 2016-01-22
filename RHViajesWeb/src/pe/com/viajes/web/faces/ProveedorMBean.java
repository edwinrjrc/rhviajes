/**
 * 
 */
package pe.com.viajes.web.faces;

import java.sql.SQLException;
import java.util.ArrayList;
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
import pe.com.viajes.bean.negocio.Contacto;
import pe.com.viajes.bean.negocio.CuentaBancaria;
import pe.com.viajes.bean.negocio.Direccion;
import pe.com.viajes.bean.negocio.Proveedor;
import pe.com.viajes.bean.negocio.ServicioProveedor;
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
@ManagedBean(name = "proveedorMBean")
@SessionScoped()
public class ProveedorMBean extends BaseMBean {

	private final static Logger logger = Logger.getLogger(ProveedorMBean.class);
	/**
	 * 
	 */
	private static final long serialVersionUID = 5592946026376816097L;

	private List<Proveedor> listaProveedores;

	private Proveedor proveedor;
	private Proveedor proveedorBusqueda;
	private Direccion direccion;
	private Contacto contacto;

	private boolean nuevoProveedor;
	private boolean editarProveedor;
	private boolean nuevaDireccion;
	private boolean editarDireccion;
	private boolean nuevoContacto;
	private boolean editarContacto;
	private boolean direccionAgregada;
	private boolean contactoAgregada;

	private String nombreFormulario;
	private String nombreFormularioDireccion;
	private String nombreFormularioContacto;
	private String pestanaActiva = "idFC01";
	private String cuentasBorradas;

	private List<SelectItem> listaProvincia;
	private List<SelectItem> listaDistrito;

	private SoporteServicio soporteServicio;
	private NegocioServicio negocioServicio;
	private ConsultaNegocioServicio consultaNegocioServicio;
	private UtilNegocioServicio utilNegocioServicio;

	/**
	 * 
	 */
	public ProveedorMBean() {
		try {
			ServletContext servletContext = (ServletContext) FacesContext
					.getCurrentInstance().getExternalContext().getContext();
			soporteServicio = new SoporteServicioImpl(servletContext);
			negocioServicio = new NegocioServicioImpl(servletContext);
			consultaNegocioServicio = new ConsultaNegocioServicioImpl(
					servletContext);
			utilNegocioServicio = new UtilNegocioServicioImpl(servletContext);
		} catch (NamingException e) {
			logger.error(e.getMessage(), e);
		}
	}
	
	public String iniciaAdmProveedor(){
		this.setProveedorBusqueda(null);
		this.setListaProveedores(null);
		
		return "irAdministrarProveedor";
	}

	public void nuevoProveedor() {
		this.setNuevoProveedor(true);
		this.setEditarProveedor(false);
		this.setProveedor(null);
		this.setNombreFormulario("Nuevo Proveedor");
		
		this.getProveedor().getNacionalidad().setCodigoEntero(UtilWeb.obtenerEnteroPropertieMaestro("codigoPaisPeru", "aplicacionDatos"));
	}

	public void nuevaDireccion() {
		this.setNombreFormularioDireccion("Nueva Dirección");
		this.setNuevaDireccion(true);
		this.setEditarDireccion(false);
		this.setListaDistrito(null);
		this.setListaProvincia(null);
		this.setDireccion(null);
		this.setDireccionAgregada(false);
		
		this.getDireccion().setPais(this.getProveedor().getNacionalidad());
	}

	public void nuevoContacto() {
		this.setContacto(null);
		this.setNombreFormularioContacto("Nuevo Contacto");
		this.setNuevoContacto(true);
		this.setEditarContacto(false);
		this.setContactoAgregada(false);
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
					this.getProveedor().getListaContactos()
							.remove(getContacto());
				}
				this.getProveedor()
						.getListaContactos()
						.add(utilNegocioServicio.agregarContacto(getContacto()));
				this.setContactoAgregada(true);
			}
		} catch (SQLException ex) {
			logger.error(ex.getMessage(), ex);
		} catch (Exception ex) {
			logger.error(ex.getMessage(), ex);
		}
	}

	public void editarContactoProveedor(Contacto contactoLista) {
		this.setNombreFormularioContacto("Editar Contacto");
		this.setNuevoContacto(false);
		this.setEditarContacto(true);
		this.setContacto(contactoLista);
	}

	public void eliminarContactoProveedor(Contacto contactoLista) {
		this.getProveedor().getListaContactos().remove(contactoLista);
	}

	public void buscarProveedor() {
		try {
			this.setListaProveedores(this.consultaNegocioServicio
					.buscarProveedor(getProveedorBusqueda()));
		} catch (Exception ex) {
			logger.error(ex.getMessage(), ex);
		}
	}

	public void ejecutarMetodo(ActionEvent e) {
		try {
			this.setShowModal(false);
			this.setListaProveedores(null);

			if (validarProveedor(e)) {
				if (validarDireccionProveedor(e)) {
					if (validarContactoProveedor(e)) {
						if (validarTelefonoProveedor()) {
							if (this.isNuevoProveedor()) {
								HttpSession session = obtenerSession(false);
								Usuario usuario = (Usuario) session
										.getAttribute("usuarioSession");
								getProveedor().setUsuarioCreacion(
										usuario);
								getProveedor().setIpCreacion(
										obtenerRequest().getRemoteAddr());
								getProveedor().setNombres(
										getProveedor().getRazonSocial());
								
								this.setShowModal(negocioServicio
										.registrarProveedor(getProveedor()));
								this.setTipoModal("1");
								this.setMensajeModal("Proveedor registrado Satisfactoriamente");
							} else if (this.isEditarProveedor()) {
								HttpSession session = obtenerSession(false);
								Usuario usuario = (Usuario) session
										.getAttribute("usuarioSession");
								getProveedor().setUsuarioModificacion(
										usuario);
								getProveedor().setIpModificacion(
										obtenerRequest().getRemoteAddr());
								getProveedor().setNombres(
										getProveedor().getRazonSocial());

								parseaUsuarioListaServicio(getProveedor());
								parseaUsuarioListaCuentasBancarias(getProveedor());
								this.setShowModal(negocioServicio
										.actualizarProveedor(getProveedor()));
								this.setTipoModal("1");
								this.setMensajeModal("Proveedor actualizado Satisfactoriamente");
							}
						} else {
							this.setShowModal(true);
							this.setTipoModal("2");
							this.setMensajeModal("Debe ingresar por lo menos un telefono, en la direccion o el contacto");
						}

					} else {
						this.setShowModal(true);
						this.setTipoModal("2");
						this.setMensajeModal("No se ha agregado ningun contacto para el proveedor, para proveedor personal natural registre como contacto la mismo persona");
					}
				} else {
					this.setShowModal(true);
					this.setTipoModal("2");
					this.setMensajeModal("No se ha agregado ninguna dirección al proveedor");
				}
			}
		} catch (ValidacionException ex) {
			this.setShowModal(true);
			this.setTipoModal("2");
			this.setMensajeModal(ex.getMessage());
		} catch (NoEnvioDatoException ex) {
			this.setShowModal(true);
			this.setTipoModal("2");
			this.setMensajeModal(ex.getMessage());
		} catch (Exception ex) {
			ex.printStackTrace();
			this.setShowModal(true);
			this.setTipoModal("2");
			this.setMensajeModal(ex.getMessage());
			logger.error(ex.getMessage(), ex);
		}
	}

	private void parseaUsuarioListaCuentasBancarias(Proveedor proveedor2) {
		if (proveedor2.getListaCuentas() != null
				&& !proveedor2.getListaCuentas().isEmpty()) {
			for (CuentaBancaria cuenta : proveedor2.getListaCuentas()) {
				HttpSession session = obtenerSession(false);
				Usuario usuario = (Usuario) session
						.getAttribute("usuarioSession");
				cuenta.setUsuarioCreacion(usuario);
				cuenta.setIpCreacion(obtenerRequest().getRemoteAddr());
				cuenta.setUsuarioModificacion(usuario);
				cuenta.setIpModificacion(obtenerRequest().getRemoteAddr());
			}
		}

	}

	private void parseaUsuarioListaServicio(Proveedor proveedor2)
			throws Exception {
		for (ServicioProveedor servicio : proveedor2
				.getListaServicioProveedor()) {
			HttpSession session = obtenerSession(false);
			Usuario usuario = (Usuario) session.getAttribute("usuarioSession");
			servicio.setUsuarioCreacion(usuario);
			servicio.setIpCreacion(obtenerRequest().getRemoteAddr());
			servicio.setUsuarioModificacion(usuario);
			servicio.setIpModificacion(obtenerRequest().getRemoteAddr());
		}

	}

	private boolean validarContactoProveedor(ActionEvent e) {
		boolean resultado = true;

		resultado = !(this.getProveedor().getListaContactos().isEmpty());

		return resultado;
	}

	private boolean validarDireccionProveedor(ActionEvent e)
			throws NoEnvioDatoException {
		boolean resultado = true;

		resultado = !(this.getProveedor().getListaDirecciones().isEmpty());

		int principales = 0;
		if (resultado) {
			for (Direccion direccion : this.getProveedor()
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

		return resultado;
	}

	private boolean validarProveedor(ActionEvent e) throws ValidacionException {
		boolean resultado = true;
		String idFormulario = "idFormProveedor";
		int tipoDocDNI = UtilWeb.obtenerEnteroPropertieMaestro(
				"tipoDocumentoDNI", "aplicacionDatos");
		int tipoDocCE = UtilWeb.obtenerEnteroPropertieMaestro(
				"tipoDocumentoCE", "aplicacionDatos");
		int tipoDocRUC = UtilWeb.obtenerEnteroPropertieMaestro(
				"tipoDocumentoRUC", "aplicacionDatos");
		boolean proveedorNacional = false;
		
		if (this.getProveedor().getNacionalidad().getCodigoEntero() == null || this.getProveedor().getNacionalidad().getCodigoEntero().intValue() == 0){
			this.agregarMensaje(idFormulario + ":idSelNacionalidad",
					"Seleccione la nacionalidad del proveedor", "",
					FacesMessage.SEVERITY_ERROR);
			resultado = false;
		}
		
		proveedorNacional = (this.getProveedor().getNacionalidad().getCodigoEntero().intValue() == UtilWeb.obtenerEnteroPropertieMaestro("codigoPaisPeru", "aplicacionDatos"));
		
		if (proveedorNacional){
			if (tipoDocDNI == getProveedor().getDocumentoIdentidad()
					.getTipoDocumento().getCodigoEntero().intValue()
					|| tipoDocCE == getProveedor().getDocumentoIdentidad()
							.getTipoDocumento().getCodigoEntero().intValue()) {
				if (StringUtils.isBlank(getProveedor().getApellidoMaterno())) {
					this.agregarMensaje(idFormulario + ":idApeMatPro",
							"Ingrese el apellido materno", "",
							FacesMessage.SEVERITY_ERROR);
					resultado = false;
				}
				if (StringUtils.isBlank(getProveedor().getApellidoPaterno())) {
					this.agregarMensaje(idFormulario + ":idApePatPro",
							"Ingrese el apellido paterno", "",
							FacesMessage.SEVERITY_ERROR);
					resultado = false;
				}
				if (StringUtils.isBlank(getProveedor().getApellidoPaterno())) {
					this.agregarMensaje(idFormulario + ":idApePatPro",
							"Ingrese el apellido paterno", "",
							FacesMessage.SEVERITY_ERROR);
					resultado = false;
				}
				if (StringUtils.isBlank(getProveedor().getNombres())) {
					this.agregarMensaje(idFormulario + ":idNomPro",
							"Ingrese los nombres", "", FacesMessage.SEVERITY_ERROR);
					resultado = false;
				}
			}
			if (tipoDocDNI != getProveedor().getDocumentoIdentidad()
					.getTipoDocumento().getCodigoEntero().intValue()) {
				if (StringUtils.isBlank(getProveedor().getRazonSocial())) {
					this.agregarMensaje(idFormulario + ":idRazSocPro",
							"Ingrese la razon social", "",
							FacesMessage.SEVERITY_ERROR);
					resultado = false;
				}
				if (StringUtils.isBlank(getProveedor().getNombreComercial())) {
					this.agregarMensaje(idFormulario + ":idNomComercialPro",
							"Ingrese la razon social", "",
							FacesMessage.SEVERITY_ERROR);
					resultado = false;
				}
			}
		}
		
		/*
		 * if (this.getProveedor().getListaServicioProveedor()== null ||
		 * this.getProveedor().getListaServicioProveedor().isEmpty()){ throw new
		 * ValidacionException
		 * ("Registre al menos 1 servicio para el proveedor"); }
		 */
		if (this.getProveedor().getTipoProveedor().getCodigoEntero() == null
				|| this.getProveedor().getTipoProveedor().getCodigoEntero()
						.intValue() == 0) {
			this.agregarMensaje(idFormulario + ":idFPSelTipoProveedor",
					"Selecciona el tipo de proveedor", "",
					FacesMessage.SEVERITY_ERROR);
			resultado = false;
		}

		return resultado;
	}

	private boolean validarTelefonoProveedor() {
		boolean resultado = false;

		List<Direccion> listaDire = this.getProveedor().getListaDirecciones();
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
			List<Contacto> listaContacto = this.getProveedor()
					.getListaContactos();
			for (Contacto contacto : listaContacto) {
				List<Telefono> listTelefono = contacto.getListaTelefonos();
				for (Telefono telefono : listTelefono) {
					if (StringUtils.isNotBlank(telefono.getNumeroTelefono())) {
						resultado = true;
						break;
					}
				}
			}
		}

		return resultado;
	}

	public void consultarProveedor(int codigoProveedor) {
		try {
			this.setProveedor(consultaNegocioServicio
					.consultarProveedor(codigoProveedor, this.obtenerIdEmpresa()));
			this.setNuevoProveedor(false);
			this.setEditarProveedor(true);
			this.setNombreFormulario("Editar Proveedor");
		} catch (Exception ex) {
			logger.error(ex.getMessage(), ex);
		}
	}

	public void agregarDireccion(ActionEvent e) {
		try {
			this.setDireccionAgregada(false);
			
			this.getDireccion().setNacional((this.getDireccion().getPais().getCodigoEntero().intValue() == UtilWeb.obtenerEnteroPropertieMaestro("codigoPaisPeru", "aplicacionDatos")));
			
			if (this.validarDireccion(e)) {
				if (this.isNuevaDireccion()) {
					this.getProveedor()
							.getListaDirecciones()
							.add(this.utilNegocioServicio
									.agregarDireccion(getDireccion()));
					this.setDireccionAgregada(true);
				} else {
					this.getProveedor().getListaDirecciones()
							.remove(getDireccion());
					this.getProveedor()
							.getListaDirecciones()
							.add(this.utilNegocioServicio
									.agregarDireccion(getDireccion()));
					this.setDireccionAgregada(true);
				}
			}
		} catch (SQLException ex) {
			logger.error(ex.getMessage(), ex);
		} catch (Exception ex) {
			logger.error(ex.getMessage(), ex);
		}
	}

	public void editarDireccionProveedor(Direccion direccionLista) {
		this.setNombreFormularioDireccion("Editar Dirección");
		this.setNuevaDireccion(false);
		this.setEditarDireccion(true);
		this.setDireccion(direccionLista);
	}

	public void eliminarDireccionProveedor(Direccion direccionLista) {
		this.getProveedor().getListaDirecciones().remove(direccionLista);
	}

	public void agregarTelefonoDireccion() {
		Telefono telefono = new Telefono();
		telefono.setId(this.getDireccion().getTelefonos().size() + 1);
		this.getDireccion().getTelefonos().add(telefono);
	}

	public void agregarTelefonoContacto() {
		Telefono telefono = new Telefono();
		telefono.setId(this.getContacto().getListaTelefonos().size() + 1);
		this.getContacto().getListaTelefonos().add(telefono);
	}

	public void agregarCorreoContacto() {
		this.getContacto().getListaCorreos().add(new CorreoElectronico());
	}

	public void eliminarTelefono(Telefono telefono) {
		this.getDireccion().getTelefonos().remove(telefono);
	}

	public void eliminarTelefonoContacto(Telefono telefono) {
		this.getContacto().getListaTelefonos().remove(telefono);
	}

	public void eliminarCorreoContacto(CorreoElectronico correo) {
		getContacto().getListaCorreos().remove(correo);
	}

	public void buscarProvincias(ValueChangeEvent e) {
		this.setListaProvincia(null);
		this.setListaDistrito(null);
		this.getDireccion().getUbigeo().setProvincia(null);
		this.getDireccion().getUbigeo().setDistrito(null);
	}

	public void buscarDistrito(ValueChangeEvent e) {
		this.setListaDistrito(null);
		this.getDireccion().getUbigeo().setDistrito(null);
	}

	private boolean validarContacto(ActionEvent e) {
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
		if (StringUtils.isBlank(getContacto().getApellidoMaterno())) {
			this.agregarMensaje(idFormulario + ":idApeMat",
					"Ingrese el apellido materno", "",
					FacesMessage.SEVERITY_ERROR);
			resultado = false;
			this.setPestanaActiva("idFC01");
		}
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
				}
			}
		}

		return resultado;
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
		
		if (this.getDireccion().getPais().getCodigoEntero() == null || this.getDireccion().getPais().getCodigoEntero().intValue() == 0){
			this.agregarMensaje(idFormulario + ":idPaisDireccion",
					"Seleccione el pais de la direccion", "",
					FacesMessage.SEVERITY_ERROR);
			resultado = false;
		}
		
		if (getDireccion().isNacional() && StringUtils.isBlank(getDireccion().getUbigeo().getDepartamento()
				.getCodigoCadena())) {
			this.agregarMensaje(idFormulario + ":idDepartamentoDireccion",
					"Seleccione el departamento", "",
					FacesMessage.SEVERITY_ERROR);
			resultado = false;
			this.setPestanaActiva("idFD01");
		}
		if (getDireccion().isNacional() && StringUtils.isBlank(getDireccion().getUbigeo().getProvincia()
				.getCodigoCadena())) {
			this.agregarMensaje(idFormulario + ":idProvinciaDireccion",
					"Seleccione la provincia", "", FacesMessage.SEVERITY_ERROR);
			resultado = false;
			this.setPestanaActiva("idFD01");
		}
		if (getDireccion().isNacional() && StringUtils.isBlank(getDireccion().getUbigeo().getDistrito()
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

	public void agregarServicio() {
		ServicioProveedor servicio = new ServicioProveedor();

		HttpSession session = obtenerSession(false);
		Usuario usuario = (Usuario) session.getAttribute("usuarioSession");
		servicio.setUsuarioCreacion(usuario);
		servicio.setIpCreacion(obtenerRequest().getRemoteAddr());
		servicio.setUsuarioModificacion(usuario);
		servicio.setIpModificacion(obtenerRequest().getRemoteAddr());
		this.getProveedor().getListaServicioProveedor().add(servicio);
	}

	public void eliminarServicio(ServicioProveedor servicio) {
		this.getProveedor().getListaServicioProveedor().remove(servicio);
	}

	public void agregarCuenta() {
		CuentaBancaria cuenta = new CuentaBancaria();
		HttpSession session = obtenerSession(false);
		Usuario usuario = (Usuario) session.getAttribute("usuarioSession");
		cuenta.setUsuarioCreacion(usuario);
		cuenta.setIpCreacion(obtenerRequest().getRemoteAddr());

		this.getProveedor().getListaCuentas().add(cuenta);
	}

	public void removerCuenta(CuentaBancaria cuenta) {
		if (cuenta.getCodigoEntero() != null) {
			this.cuentasBorradas = cuenta.getCodigoEntero().intValue() + ",";
		}
		this.getProveedor().getListaCuentas().remove(cuenta);
	}

	/**
	 * @return the listaProveedores
	 */
	public List<Proveedor> getListaProveedores() {
		this.setShowModal(false);
		try {
			if (listaProveedores == null || listaProveedores.isEmpty()) {
				listaProveedores = this.consultaNegocioServicio
						.listarProveedor(getProveedor());
			}

		} catch (Exception ex) {
			logger.error(ex.getMessage(), ex);
		}
		return listaProveedores;
	}

	/**
	 * @param listaProveedores
	 *            the listaProveedores to set
	 */
	public void setListaProveedores(List<Proveedor> listaProveedores) {
		this.listaProveedores = listaProveedores;
	}

	/**
	 * @return the proveedor
	 */
	public Proveedor getProveedor() {
		if (proveedor == null) {
			proveedor = new Proveedor();
		}
		return proveedor;
	}

	/**
	 * @param proveedor
	 *            the proveedor to set
	 */
	public void setProveedor(Proveedor proveedor) {
		this.proveedor = proveedor;
	}

	/**
	 * @return the nuevoProveedor
	 */
	public boolean isNuevoProveedor() {
		return nuevoProveedor;
	}

	/**
	 * @param nuevoProveedor
	 *            the nuevoProveedor to set
	 */
	public void setNuevoProveedor(boolean nuevoProveedor) {
		this.nuevoProveedor = nuevoProveedor;
	}

	/**
	 * @return the editarProveedor
	 */
	public boolean isEditarProveedor() {
		return editarProveedor;
	}

	/**
	 * @param editarProveedor
	 *            the editarProveedor to set
	 */
	public void setEditarProveedor(boolean editarProveedor) {
		this.editarProveedor = editarProveedor;
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
	 * @return the cuentasBorradas
	 */
	public String getCuentasBorradas() {
		return cuentasBorradas;
	}

	/**
	 * @param cuentasBorradas
	 *            the cuentasBorradas to set
	 */
	public void setCuentasBorradas(String cuentasBorradas) {
		this.cuentasBorradas = cuentasBorradas;
	}

	/**
	 * @return the proveedorBusqueda
	 */
	public Proveedor getProveedorBusqueda() {
		if (proveedorBusqueda == null){
			proveedorBusqueda = new Proveedor();
		}
		return proveedorBusqueda;
	}

	/**
	 * @param proveedorBusqueda the proveedorBusqueda to set
	 */
	public void setProveedorBusqueda(Proveedor proveedorBusqueda) {
		this.proveedorBusqueda = proveedorBusqueda;
	}

}
