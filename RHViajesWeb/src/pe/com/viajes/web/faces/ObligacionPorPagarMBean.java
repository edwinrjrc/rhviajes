/**
 * 
 */
package pe.com.viajes.web.faces;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.StringTokenizer;

import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.naming.NamingException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.event.FileUploadEvent;
import org.richfaces.model.UploadedFile;

import pe.com.viajes.bean.negocio.Comprobante;
import pe.com.viajes.bean.negocio.CuentaBancaria;
import pe.com.viajes.bean.negocio.PagoServicio;
import pe.com.viajes.bean.negocio.Proveedor;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.web.servicio.ConsultaNegocioServicio;
import pe.com.viajes.web.servicio.NegocioServicio;
import pe.com.viajes.web.servicio.impl.ConsultaNegocioServicioImpl;
import pe.com.viajes.web.servicio.impl.NegocioServicioImpl;
import pe.com.viajes.web.util.UtilWeb;

/**
 * @author Edwin
 *
 */
@ManagedBean(name = "obligacionPorPagarMBean")
@SessionScoped()
public class ObligacionPorPagarMBean extends BaseMBean {

	private final static Logger logger = Logger
			.getLogger(ObligacionPorPagarMBean.class);
	/**
	 * 
	 */
	private static final long serialVersionUID = -6007823264843587230L;

	private Comprobante comprobante;
	private Comprobante comprobanteBusqueda;
	private Proveedor proveedorBusqueda;
	private PagoServicio pagoComprobante;

	private List<Comprobante> listaComprobantes;
	private List<Proveedor> listadoProveedores;
	private List<PagoServicio> listaPagos;
	private List<SelectItem> listadoCuentasBancarias;
	private List<SelectItem> listadoCuentasBancariasDestino;

	private boolean nuevaObligacion;
	private boolean editarObligacion;
	private boolean consultoProveedor;
	private boolean buscoObligaciones;
	private boolean busquedaProveedor;
	private boolean mostrarCuenta;
	private boolean mostrarTarjeta;

	private NegocioServicio negocioServicio;
	private ConsultaNegocioServicio consultaNegocioServicio;

	/**
	 * 
	 */
	public ObligacionPorPagarMBean() {
		try {
			ServletContext servletContext = (ServletContext) FacesContext
					.getCurrentInstance().getExternalContext().getContext();
			negocioServicio = new NegocioServicioImpl(servletContext);
			consultaNegocioServicio = new ConsultaNegocioServicioImpl(
					servletContext);
		} catch (NamingException e) {
			logger.error(e.getMessage(), e);
		}
	}

	public void buscar() {
		try {
			this.setListaComprobantes(this.consultaNegocioServicio
					.listarObligacionXPagar(getComprobanteBusqueda()));

			this.setBuscoObligaciones(true);
		} catch (SQLException e) {
			this.setShowModal(true);
			this.setMensajeModal(e.getMessage());
			this.setTipoModal(TIPO_MODAL_ERROR);
			e.printStackTrace();
		} catch (Exception e) {
			this.setShowModal(true);
			this.setMensajeModal(e.getMessage());
			this.setTipoModal(TIPO_MODAL_ERROR);
			e.printStackTrace();
		}
	}

	public void nuevaObligacion() {
		this.setNombreFormulario("Nueva Obligacion por Pagar");
		this.setNuevaObligacion(true);
		this.setEditarObligacion(false);
		this.setConsultoProveedor(true);
		this.setComprobante(null);
		this.setListadoProveedores(null);
		this.setBusquedaProveedor(false);
	}

	public void ejecutarMetodo() {
		if (validarObligacion()) {
			try {
				if (this.isNuevaObligacion()) {
					HttpSession session = obtenerSession(false);

					Usuario usuario = (Usuario) session
							.getAttribute(USUARIO_SESSION);
					getComprobante().setUsuarioCreacion(usuario);
					getComprobante().setIpCreacion(
							obtenerRequest().getRemoteAddr());

					this.setShowModal(this.negocioServicio
							.registrarObligacionXPagar(getComprobante()));
					this.setMensajeModal("Obligación registrados satisfactoriamente");
					this.setTipoModal(TIPO_MODAL_EXITO);
				}

				this.setBuscoObligaciones(false);
			} catch (SQLException e) {
				this.setShowModal(true);
				this.setMensajeModal(e.getMessage());
				this.setTipoModal(TIPO_MODAL_ERROR);
				e.printStackTrace();
			} catch (Exception e) {
				this.setShowModal(true);
				this.setMensajeModal(e.getMessage());
				this.setTipoModal(TIPO_MODAL_ERROR);
				e.printStackTrace();
			}
		}
	}

	private boolean validarObligacion() {
		boolean resultado = true;
		String idFormulario = "idFormObligacion";
		Date fechaHoy = UtilWeb.fechaHoy();

		if (StringUtils.isBlank(this.getComprobante().getProveedor()
				.getNombres())) {
			this.agregarMensaje(idFormulario + ":idTxtProveedor",
					"Seleccione el proveedor", "", FacesMessage.SEVERITY_ERROR);
			resultado = false;
		}
		if (this.getComprobante().getFechaComprobante().after(fechaHoy)
				|| this.getComprobante().getFechaComprobante().equals(fechaHoy)) {
			this.agregarMensaje(
					idFormulario + ":idFecComprobante",
					"La fecha de comprobante no debe ser mayor a la fecha de hoy",
					"", FacesMessage.SEVERITY_ERROR);
			resultado = false;
		}
		if (this.getComprobante().getFechaPago().before(fechaHoy)
				|| this.getComprobante().getFechaPago().equals(fechaHoy)) {
			this.agregarMensaje(idFormulario + ":idFecPago",
					"La fecha de pago debe ser mayor a la fecha de hoy", "",
					FacesMessage.SEVERITY_ERROR);
			resultado = false;
		}

		return resultado;
	}

	public void buscarProveedor() {
		try {
			this.setListadoProveedores(this.consultaNegocioServicio
					.buscarProveedor(getProveedorBusqueda()));

			this.setConsultoProveedor(true);
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void seleccionarProveedor() {
		for (Proveedor proveedor : this.listadoProveedores) {
			if (proveedor.getCodigoEntero().equals(
					proveedor.getCodigoSeleccionado())) {
				if (this.isBusquedaProveedor()) {
					this.getComprobanteBusqueda().setProveedor(proveedor);
					break;
				} else {
					this.getComprobante().setProveedor(proveedor);
					break;
				}
			}
		}
	}

	public void defineSalida() {
		this.setBusquedaProveedor(true);
	}

	public void registrarPagoComprobante() {
		try {
			if (validarRegistroPago()) {
				this.getPagoComprobante().setIdObligacion(
						getComprobante().getCodigoEntero());

				HttpSession session = obtenerSession(false);
				Usuario usuario = (Usuario) session
						.getAttribute("usuarioSession");
				this.getPagoComprobante().setUsuarioCreacion(
						usuario);
				this.getPagoComprobante().setIpCreacion(
						obtenerRequest().getRemoteAddr());
				this.getPagoComprobante().setUsuarioModificacion(
						usuario);
				this.getPagoComprobante().setIpModificacion(
						obtenerRequest().getRemoteAddr());

				this.negocioServicio
						.registrarPagoObligacion(getPagoComprobante());

				this.setShowModal(true);
				this.setMensajeModal("Pago Registrado Satisfactoriamente");
				this.setTipoModal(TIPO_MODAL_EXITO);

				this.setComprobante(this.consultaNegocioServicio
						.consultarComprobanteObligacion(getPagoComprobante()
								.getIdObligacion(), this.obtenerIdEmpresa()));
			}

		} catch (SQLException e) {
			e.printStackTrace();
			this.setShowModal(true);
			this.setMensajeModal(e.getMessage());
			this.setTipoModal(TIPO_MODAL_ERROR);
		} catch (Exception e) {
			e.printStackTrace();
			this.setShowModal(true);
			this.setMensajeModal(e.getMessage());
			this.setTipoModal(TIPO_MODAL_ERROR);
		}
	}

	private boolean validarRegistroPago() {
		boolean resultado = true;
		String idFormulario = "idFrRegiPagoComp";
		if (this.getPagoComprobante().getMontoPago() == null
				|| BigDecimal.ZERO.equals(this.getPagoComprobante()
						.getMontoPago())) {
			this.agregarMensaje(idFormulario + ":idMontoPago",
					"Ingrese el monto a pagar", "", FacesMessage.SEVERITY_ERROR);
			resultado = false;
		}
		if (this.getPagoComprobante().getFechaPago() == null) {
			this.agregarMensaje(idFormulario + ":idSelFecSer",
					"Ingrese la fecha de pago", "", FacesMessage.SEVERITY_ERROR);
			resultado = false;
		}
		if (StringUtils.length(this.getPagoComprobante().getComentario()) > 300) {
			this.agregarMensaje(idFormulario + ":idTxtComentario",
					"El comentario no debe ser mayor a 300 caracteres", "",
					FacesMessage.SEVERITY_ERROR);
			resultado = false;
		}

		return resultado;
	}

	public void verPagos(Comprobante comprobante) {
		this.setComprobante(comprobante);
	}

	public void registrarNuevoPago() {
		this.setPagoComprobante(null);
		this.setMostrarTarjeta(false);
		this.setMostrarCuenta(false);
	}

	public void listener(FileUploadEvent event) throws Exception {
		UploadedFile item = event.getUploadedFile();

		String nombre = item.getName();
		StringTokenizer stk = new StringTokenizer(nombre, ".");
		String archivoNombre = stk.nextToken();
		if (stk.hasMoreTokens()) {
			archivoNombre = stk.nextToken();
		}
		byte[] arregloDatos = IOUtils.toByteArray(item.getInputStream());
		this.getPagoComprobante().setNombreArchivo(nombre);
		this.getPagoComprobante().setExtensionArchivo(archivoNombre);
		this.getPagoComprobante().setSustentoPagoByte(arregloDatos);
		this.getPagoComprobante().setTipoContenido(item.getContentType());
	}

	public void verArchivo(Integer codigoPago) {
		for (PagoServicio pago : this.listaPagos) {
			if (pago.getCodigoEntero().intValue() == codigoPago.intValue()) {
				this.setPagoComprobante(pago);
				break;
			}
		}
	}

	public void exportarArchivo() {
		try {
			HttpServletResponse response = obtenerResponse();
			response.setContentType(pagoComprobante.getTipoContenido());
			response.setHeader("Content-disposition", "attachment;filename="
					+ this.getPagoComprobante().getNombreArchivo());
			response.setHeader("Content-Transfer-Encoding", "binary");

			FacesContext facesContext = obtenerContexto();

			ServletOutputStream respuesta = response.getOutputStream();
			if (this.getPagoComprobante() != null
					&& this.getPagoComprobante().getSustentoPagoByte() != null) {
				respuesta
						.write(this.getPagoComprobante().getSustentoPagoByte());
			}

			respuesta.close();
			respuesta.flush();

			facesContext.responseComplete();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void cambiarFormaPago(ValueChangeEvent e) {
		Object oe = e.getNewValue();
		this.setMostrarCuenta(false);
		this.setMostrarTarjeta(false);

		try {
			this.setListadoCuentasBancarias(null);
			this.setListadoCuentasBancariasDestino(null);
			if (oe != null) {
				String formaPago = oe.toString();

				if ("2".equals(formaPago) || "3".equals(formaPago)) {
					List<CuentaBancaria> lista = this.consultaNegocioServicio
							.listarCuentasBancariasCombo(this.obtenerIdEmpresa());
					SelectItem si = null;
					for (CuentaBancaria cuentaBancaria : lista) {
						si = new SelectItem();

						si.setValue(cuentaBancaria.getCodigoEntero());
						si.setLabel(cuentaBancaria.getNombreCuenta());
						this.getListadoCuentasBancarias().add(si);
					}
					this.setMostrarCuenta(true);
				} else if ("4".equals(formaPago)) {
					this.setMostrarTarjeta(true);
				}

				List<CuentaBancaria> listaCuentasProveedor = this.consultaNegocioServicio
						.listarCuentasBancariasProveedor(this.getComprobante()
								.getProveedor().getCodigoEntero(), this.obtenerIdEmpresa());

				SelectItem si = null;
				if (listaCuentasProveedor != null
						&& !listaCuentasProveedor.isEmpty()) {
					for (CuentaBancaria cuentaBancaria : listaCuentasProveedor) {
						si = new SelectItem();
						si.setValue(cuentaBancaria.getCodigoEntero());
						si.setLabel(cuentaBancaria.getNombreCuenta());
						this.getListadoCuentasBancariasDestino().add(si);
					}
				}

			}
		} catch (SQLException e1) {
			logger.error(e1.getMessage(), e1);
		}
	}

	/**
	 * ========================================================================
	 * ==========================
	 */
	/**
	 * @return the comprobante
	 */
	public Comprobante getComprobante() {
		if (comprobante == null) {
			comprobante = new Comprobante();
		}
		return comprobante;
	}

	/**
	 * @param comprobante
	 *            the comprobante to set
	 */
	public void setComprobante(Comprobante comprobante) {
		this.comprobante = comprobante;
	}

	/**
	 * @return the comprobanteBusqueda
	 */
	public Comprobante getComprobanteBusqueda() {
		if (comprobanteBusqueda == null) {
			comprobanteBusqueda = new Comprobante();
		}
		return comprobanteBusqueda;
	}

	/**
	 * @param comprobanteBusqueda
	 *            the comprobanteBusqueda to set
	 */
	public void setComprobanteBusqueda(Comprobante comprobanteBusqueda) {
		this.comprobanteBusqueda = comprobanteBusqueda;
	}

	/**
	 * @return the listaComprobantes
	 */
	public List<Comprobante> getListaComprobantes() {
		this.setShowModal(false);
		if (listaComprobantes == null || !this.isBuscoObligaciones()) {
			try {
				this.setListaComprobantes(this.consultaNegocioServicio
						.listarObligacionXPagar(getComprobanteBusqueda()));

				this.setBuscoObligaciones(true);

			} catch (SQLException e) {
				this.setShowModal(true);
				this.setMensajeModal(e.getMessage());
				this.setTipoModal(TIPO_MODAL_ERROR);
				e.printStackTrace();
			} catch (Exception e) {
				this.setShowModal(true);
				this.setMensajeModal(e.getMessage());
				this.setTipoModal(TIPO_MODAL_ERROR);
				e.printStackTrace();
			}
		}
		return listaComprobantes;
	}

	/**
	 * @param listaComprobantes
	 *            the listaComprobantes to set
	 */
	public void setListaComprobantes(List<Comprobante> listaComprobantes) {
		this.listaComprobantes = listaComprobantes;
	}

	/**
	 * @return the nuevaObligacion
	 */
	public boolean isNuevaObligacion() {
		return nuevaObligacion;
	}

	/**
	 * @param nuevaObligacion
	 *            the nuevaObligacion to set
	 */
	public void setNuevaObligacion(boolean nuevaObligacion) {
		this.nuevaObligacion = nuevaObligacion;
	}

	/**
	 * @return the editarObligacion
	 */
	public boolean isEditarObligacion() {
		return editarObligacion;
	}

	/**
	 * @param editarObligacion
	 *            the editarObligacion to set
	 */
	public void setEditarObligacion(boolean editarObligacion) {
		this.editarObligacion = editarObligacion;
	}

	/**
	 * @return the proveedorBusqueda
	 */
	public Proveedor getProveedorBusqueda() {
		if (proveedorBusqueda == null) {
			proveedorBusqueda = new Proveedor();
		}
		return proveedorBusqueda;
	}

	/**
	 * @param proveedorBusqueda
	 *            the proveedorBusqueda to set
	 */
	public void setProveedorBusqueda(Proveedor proveedorBusqueda) {
		this.proveedorBusqueda = proveedorBusqueda;
	}

	/**
	 * @return the listadoProveedores
	 */
	public List<Proveedor> getListadoProveedores() {
		try {
			// if (!this.isConsultoProveedor()){
			listadoProveedores = this.consultaNegocioServicio
					.buscarProveedor(getProveedorBusqueda());
			// }

		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return listadoProveedores;
	}

	/**
	 * @param listadoProveedores
	 *            the listadoProveedores to set
	 */
	public void setListadoProveedores(List<Proveedor> listadoProveedores) {
		this.listadoProveedores = listadoProveedores;
	}

	/**
	 * @return the consultoProveedor
	 */
	public boolean isConsultoProveedor() {
		return consultoProveedor;
	}

	/**
	 * @param consultoProveedor
	 *            the consultoProveedor to set
	 */
	public void setConsultoProveedor(boolean consultoProveedor) {
		this.consultoProveedor = consultoProveedor;
	}

	/**
	 * @return the buscoObligaciones
	 */
	public boolean isBuscoObligaciones() {
		return buscoObligaciones;
	}

	/**
	 * @param buscoObligaciones
	 *            the buscoObligaciones to set
	 */
	public void setBuscoObligaciones(boolean buscoObligaciones) {
		this.buscoObligaciones = buscoObligaciones;
	}

	/**
	 * @return the busquedaProveedor
	 */
	public boolean isBusquedaProveedor() {
		return busquedaProveedor;
	}

	/**
	 * @param busquedaProveedor
	 *            the busquedaProveedor to set
	 */
	public void setBusquedaProveedor(boolean busquedaProveedor) {
		this.busquedaProveedor = busquedaProveedor;
	}

	/**
	 * @return the pagoComprobante
	 */
	public PagoServicio getPagoComprobante() {
		if (pagoComprobante == null) {
			pagoComprobante = new PagoServicio();
		}
		return pagoComprobante;
	}

	/**
	 * @param pagoComprobante
	 *            the pagoComprobante to set
	 */
	public void setPagoComprobante(PagoServicio pagoComprobante) {
		this.pagoComprobante = pagoComprobante;
	}

	/**
	 * @return the listaPagos
	 */
	public List<PagoServicio> getListaPagos() {
		try {
			listaPagos = this.consultaNegocioServicio
					.listarPagosObligacion(this.getComprobante()
							.getCodigoEntero(), this.obtenerIdEmpresa());
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return listaPagos;
	}

	/**
	 * @param listaPagos
	 *            the listaPagos to set
	 */
	public void setListaPagos(List<PagoServicio> listaPagos) {
		this.listaPagos = listaPagos;
	}

	/**
	 * @return the mostrarCuenta
	 */
	public boolean isMostrarCuenta() {
		return mostrarCuenta;
	}

	/**
	 * @param mostrarCuenta
	 *            the mostrarCuenta to set
	 */
	public void setMostrarCuenta(boolean mostrarCuenta) {
		this.mostrarCuenta = mostrarCuenta;
	}

	/**
	 * @return the mostrarTarjeta
	 */
	public boolean isMostrarTarjeta() {
		return mostrarTarjeta;
	}

	/**
	 * @param mostrarTarjeta
	 *            the mostrarTarjeta to set
	 */
	public void setMostrarTarjeta(boolean mostrarTarjeta) {
		this.mostrarTarjeta = mostrarTarjeta;
	}

	/**
	 * @return the listadoCuentasBancarias
	 */
	public List<SelectItem> getListadoCuentasBancarias() {
		if (listadoCuentasBancarias == null) {
			listadoCuentasBancarias = new ArrayList<SelectItem>();
		}
		return listadoCuentasBancarias;
	}

	/**
	 * @param listadoCuentasBancarias
	 *            the listadoCuentasBancarias to set
	 */
	public void setListadoCuentasBancarias(
			List<SelectItem> listadoCuentasBancarias) {
		this.listadoCuentasBancarias = listadoCuentasBancarias;
	}

	/**
	 * @return the listadoCuentasBancariasDestino
	 */
	public List<SelectItem> getListadoCuentasBancariasDestino() {
		if (listadoCuentasBancariasDestino == null) {
			listadoCuentasBancariasDestino = new ArrayList<SelectItem>();
		}
		return listadoCuentasBancariasDestino;
	}

	/**
	 * @param listadoCuentasBancariasDestino
	 *            the listadoCuentasBancariasDestino to set
	 */
	public void setListadoCuentasBancariasDestino(
			List<SelectItem> listadoCuentasBancariasDestino) {
		this.listadoCuentasBancariasDestino = listadoCuentasBancariasDestino;
	}

}
