/**
 * 
 */
package pe.com.viajes.bean.negocio;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import pe.com.viajes.bean.base.BaseNegocio;
import pe.com.viajes.bean.base.BaseVO;

/**
 * @author edwreb
 *
 */
public class ServicioAgencia extends BaseNegocio {
	/**
	 * 
	 */
	private static final long serialVersionUID = 52998145587384961L;

	private Cliente cliente;
	private Cliente cliente2;
	private Date fechaServicio;
	private int cantidadServicios;
	private Destino destino;
	private BaseVO formaPago;
	private BaseVO estadoPago;
	private BaseVO estadoServicio;
	private int nroCuotas;
	private BigDecimal tea;
	private BigDecimal valorCuota;
	private Date fechaPrimerCuota;
	private Date fechaUltimaCuota;
	private BaseVO moneda;
	private BigDecimal montoTotalServicios;
	private BigDecimal montoTotalFee;
	private BigDecimal montoTotalComision;
	private BigDecimal montoTotalIGV;
	private BigDecimal montoSaldoServicio;

	private List<DetalleServicioAgencia> listaDetalleServicio;
	private List<DetalleServicioAgencia> listaDetalleServicioAgrupado;
	private List<Pasajero> listaPasajeros;
	private List<CuotaPago> cronogramaPago;

	private BaseVO vendedor;
	private String observaciones;

	private boolean esProgramaNovios;
	private boolean servicioPagado;
	private boolean editable;
	private boolean guardoComprobante;
	private boolean guardoRelacionComprobantes;

	private BaseVO aerolinea;

	private int tienePagos;

	private Integer idReferencia;
	
	private String codigoNovios;

	public static final Integer ESTADO_PENDIENTE_CIERRE = 1;
	public static final Integer ESTADO_CERRADO = 2;
	public static final Integer ESTADO_ANULADO = 3;
	public static final Integer ESTADO_OBSERVADO = 4;

	/**
	 * 
	 */
	public ServicioAgencia() {
		// TODO Auto-generated constructor stub
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
	 * @return the fechaServicio
	 */
	public Date getFechaServicio() {
		return fechaServicio;
	}

	/**
	 * @param fechaServicio
	 *            the fechaServicio to set
	 */
	public void setFechaServicio(Date fechaServicio) {
		this.fechaServicio = fechaServicio;
	}

	/**
	 * @return the cantidadServicios
	 */
	public int getCantidadServicios() {
		return cantidadServicios;
	}

	/**
	 * @param cantidadServicios
	 *            the cantidadServicios to set
	 */
	public void setCantidadServicios(int cantidadServicios) {
		this.cantidadServicios = cantidadServicios;
	}

	/**
	 * @return the destino
	 */
	public Destino getDestino() {
		if (destino == null) {
			destino = new Destino();
		}
		return destino;
	}

	/**
	 * @param destino
	 *            the destino to set
	 */
	public void setDestino(Destino destino) {
		this.destino = destino;
	}

	/**
	 * @return the listaDetalleServicio
	 */
	public List<DetalleServicioAgencia> getListaDetalleServicio() {
		if (listaDetalleServicio == null) {
			listaDetalleServicio = new ArrayList<DetalleServicioAgencia>();
		}
		return listaDetalleServicio;
	}

	/**
	 * @param listaDetalleServicio
	 *            the listaDetalleServicio to set
	 */
	public void setListaDetalleServicio(
			List<DetalleServicioAgencia> listaDetalleServicio) {
		this.listaDetalleServicio = listaDetalleServicio;
	}

	/**
	 * Calcula el monto total de los servicios sumando el total servicio
	 * 
	 * @return
	 */
	public BigDecimal getMontoTotal() {
		BigDecimal monto = BigDecimal.ZERO;

		if (this.listaDetalleServicio != null
				&& !this.listaDetalleServicio.isEmpty()) {
			for (DetalleServicioAgencia detalleServicio : this.listaDetalleServicio) {

				monto = monto.add(detalleServicio.getTotalServicio());
			}
		}

		return monto;
	}

	/**
	 * @return the formaPago
	 */
	public BaseVO getFormaPago() {
		if (formaPago == null) {
			formaPago = new BaseVO();
		}
		return formaPago;
	}

	/**
	 * @param formaPago
	 *            the formaPago to set
	 */
	public void setFormaPago(BaseVO formaPago) {
		this.formaPago = formaPago;
	}

	/**
	 * @return the estadoPago
	 */
	public BaseVO getEstadoPago() {
		if (estadoPago == null) {
			estadoPago = new BaseVO();
		}
		return estadoPago;
	}

	/**
	 * @param estadoPago
	 *            the estadoPago to set
	 */
	public void setEstadoPago(BaseVO estadoPago) {
		this.estadoPago = estadoPago;
	}

	/**
	 * @return the nroCuotas
	 */
	public int getNroCuotas() {
		return nroCuotas;
	}

	/**
	 * @param nroCuotas
	 *            the nroCuotas to set
	 */
	public void setNroCuotas(int nroCuotas) {
		this.nroCuotas = nroCuotas;
	}

	/**
	 * @return the tea
	 */
	public BigDecimal getTea() {
		return tea;
	}

	/**
	 * @param tea
	 *            the tea to set
	 */
	public void setTea(BigDecimal tea) {
		this.tea = tea;
	}

	/**
	 * @return the valorCuota
	 */
	public BigDecimal getValorCuota() {
		return valorCuota;
	}

	/**
	 * @param valorCuota
	 *            the valorCuota to set
	 */
	public void setValorCuota(BigDecimal valorCuota) {
		this.valorCuota = valorCuota;
	}

	/**
	 * @return the fechaPrimerCuota
	 */
	public Date getFechaPrimerCuota() {
		return fechaPrimerCuota;
	}

	/**
	 * @param fechaPrimerCuota
	 *            the fechaPrimerCuota to set
	 */
	public void setFechaPrimerCuota(Date fechaPrimerCuota) {
		this.fechaPrimerCuota = fechaPrimerCuota;
	}

	/**
	 * @return the fechaUltimaCuota
	 */
	public Date getFechaUltimaCuota() {
		return fechaUltimaCuota;
	}

	/**
	 * @param fechaUltimaCuota
	 *            the fechaUltimaCuota to set
	 */
	public void setFechaUltimaCuota(Date fechaUltimaCuota) {
		this.fechaUltimaCuota = fechaUltimaCuota;
	}

	/**
	 * @return the montoTotalServicios
	 */
	public BigDecimal getMontoTotalServicios() {
		if (montoTotalServicios == null) {
			montoTotalServicios = BigDecimal.ZERO;
		}
		return montoTotalServicios;
	}

	/**
	 * @param montoTotalServicios
	 *            the montoTotalServicios to set
	 */
	public void setMontoTotalServicios(BigDecimal montoTotalServicios) {
		this.montoTotalServicios = montoTotalServicios;
	}

	/**
	 * @return the cronogramaPago
	 */
	public List<CuotaPago> getCronogramaPago() {
		if (cronogramaPago == null) {
			cronogramaPago = new ArrayList<CuotaPago>();
		}
		return cronogramaPago;
	}

	/**
	 * @param cronogramaPago
	 *            the cronogramaPago to set
	 */
	public void setCronogramaPago(List<CuotaPago> cronogramaPago) {
		this.cronogramaPago = cronogramaPago;
	}

	/**
	 * @return the cliente2
	 */
	public Cliente getCliente2() {
		if (cliente2 == null) {
			cliente2 = new Cliente();
		}
		return cliente2;
	}

	/**
	 * @param cliente2
	 *            the cliente2 to set
	 */
	public void setCliente2(Cliente cliente2) {
		this.cliente2 = cliente2;
	}

	/**
	 * @return the montoTotalFee
	 */
	public BigDecimal getMontoTotalFee() {
		return montoTotalFee;
	}

	/**
	 * @param montoTotalFee
	 *            the montoTotalFee to set
	 */
	public void setMontoTotalFee(BigDecimal montoTotalFee) {
		this.montoTotalFee = montoTotalFee;
	}

	/**
	 * @return the montoTotalComision
	 */
	public BigDecimal getMontoTotalComision() {
		return montoTotalComision;
	}

	/**
	 * @param montoTotalComision
	 *            the montoTotalComision to set
	 */
	public void setMontoTotalComision(BigDecimal montoTotalComision) {
		this.montoTotalComision = montoTotalComision;
	}

	/**
	 * @return the vendedor
	 */
	public BaseVO getVendedor() {
		if (vendedor == null) {
			vendedor = new BaseVO();
		}
		return vendedor;
	}

	/**
	 * @param vendedor
	 *            the vendedor to set
	 */
	public void setVendedor(BaseVO vendedor) {
		this.vendedor = vendedor;
	}

	/**
	 * @return the observaciones
	 */
	public String getObservaciones() {
		return observaciones;
	}

	/**
	 * @param observaciones
	 *            the observaciones to set
	 */
	public void setObservaciones(String observaciones) {
		this.observaciones = observaciones;
	}

	/**
	 * @return the estadoServicio
	 */
	public BaseVO getEstadoServicio() {
		if (estadoServicio == null) {
			estadoServicio = new BaseVO();
		}
		return estadoServicio;
	}

	/**
	 * @param estadoServicio
	 *            the estadoServicio to set
	 */
	public void setEstadoServicio(BaseVO estadoServicio) {
		this.estadoServicio = estadoServicio;
	}

	/**
	 * @return the esProgramaNovios
	 */
	public boolean isEsProgramaNovios() {
		return esProgramaNovios;
	}

	/**
	 * @param esProgramaNovios
	 *            the esProgramaNovios to set
	 */
	public void setEsProgramaNovios(boolean esProgramaNovios) {
		this.esProgramaNovios = esProgramaNovios;
	}

	/**
	 * @return the montoTotalIGV
	 */
	public BigDecimal getMontoTotalIGV() {
		return montoTotalIGV;
	}

	/**
	 * @param montoTotalIGV
	 *            the montoTotalIGV to set
	 */
	public void setMontoTotalIGV(BigDecimal montoTotalIGV) {
		this.montoTotalIGV = montoTotalIGV;
	}

	/**
	 * @return the aerolinea
	 */
	public BaseVO getAerolinea() {
		return aerolinea;
	}

	/**
	 * @param aerolinea
	 *            the aerolinea to set
	 */
	public void setAerolinea(BaseVO aerolinea) {
		this.aerolinea = aerolinea;
	}

	/**
	 * @return the montoSaldoServicio
	 */
	public BigDecimal getMontoSaldoServicio() {
		return montoSaldoServicio;
	}

	/**
	 * @param montoSaldoServicio
	 *            the montoSaldoServicio to set
	 */
	public void setMontoSaldoServicio(BigDecimal montoSaldoServicio) {
		this.montoSaldoServicio = montoSaldoServicio;
	}

	/**
	 * @return the servicioPagado
	 */
	public boolean isServicioPagado() {
		return servicioPagado;
	}

	/**
	 * @param servicioPagado
	 *            the servicioPagado to set
	 */
	public void setServicioPagado(boolean servicioPagado) {
		this.servicioPagado = servicioPagado;
	}

	/**
	 * @return the editable
	 */
	public boolean isEditable() {
		return editable;
	}

	/**
	 * @param editable
	 *            the editable to set
	 */
	public void setEditable(boolean editable) {
		this.editable = editable;
	}

	/**
	 * @return the tienePagos
	 */
	public int getTienePagos() {
		return tienePagos;
	}

	/**
	 * @param tienePagos
	 *            the tienePagos to set
	 */
	public void setTienePagos(int tienePagos) {
		this.tienePagos = tienePagos;
	}

	/**
	 * @return the guardoComprobante
	 */
	public boolean isGuardoComprobante() {
		return guardoComprobante;
	}

	/**
	 * @param guardoComprobante
	 *            the guardoComprobante to set
	 */
	public void setGuardoComprobante(boolean guardoComprobante) {
		this.guardoComprobante = guardoComprobante;
	}

	/**
	 * @return the guardoRelacionComprobantes
	 */
	public boolean isGuardoRelacionComprobantes() {
		return guardoRelacionComprobantes;
	}

	/**
	 * @param guardoRelacionComprobantes
	 *            the guardoRelacionComprobantes to set
	 */
	public void setGuardoRelacionComprobantes(boolean guardoRelacionComprobantes) {
		this.guardoRelacionComprobantes = guardoRelacionComprobantes;
	}

	/**
	 * @return the listaDetalleServicioAgrupado
	 */
	public List<DetalleServicioAgencia> getListaDetalleServicioAgrupado() {
		if (listaDetalleServicioAgrupado == null) {
			listaDetalleServicioAgrupado = new ArrayList<DetalleServicioAgencia>();
		}
		return listaDetalleServicioAgrupado;
	}

	/**
	 * @param listaDetalleServicioAgrupado
	 *            the listaDetalleServicioAgrupado to set
	 */
	public void setListaDetalleServicioAgrupado(
			List<DetalleServicioAgencia> listaDetalleServicioAgrupado) {
		this.listaDetalleServicioAgrupado = listaDetalleServicioAgrupado;
	}

	/**
	 * @return the moneda
	 */
	public BaseVO getMoneda() {
		if (moneda == null) {
			moneda = new BaseVO();
		}
		return moneda;
	}

	/**
	 * @param moneda
	 *            the moneda to set
	 */
	public void setMoneda(BaseVO moneda) {
		this.moneda = moneda;
	}

	/**
	 * @return the idReferencia
	 */
	public Integer getIdReferencia() {
		return idReferencia;
	}

	/**
	 * @param idReferencia
	 *            the idReferencia to set
	 */
	public void setIdReferencia(Integer idReferencia) {
		this.idReferencia = idReferencia;
	}

	/**
	 * @return the listaPasajeros
	 */
	public List<Pasajero> getListaPasajeros() {
		if (listaPasajeros == null){
			listaPasajeros = new ArrayList<Pasajero>();
		}
		return listaPasajeros;
	}

	/**
	 * @param listaPasajeros the listaPasajeros to set
	 */
	public void setListaPasajeros(List<Pasajero> listaPasajeros) {
		this.listaPasajeros = listaPasajeros;
	}

	/**
	 * @return the codigoNovios
	 */
	public String getCodigoNovios() {
		return codigoNovios;
	}

	/**
	 * @param codigoNovios the codigoNovios to set
	 */
	public void setCodigoNovios(String codigoNovios) {
		this.codigoNovios = codigoNovios;
	}
}
