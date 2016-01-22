/**
 * 
 */
package pe.com.viajes.bean.negocio;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

import pe.com.viajes.bean.base.BaseNegocio;
import pe.com.viajes.bean.base.BaseVO;

/**
 * @author Edwin
 *
 */
public class CotizacionDetalle extends BaseNegocio {

	private static final long serialVersionUID = -5838373285507186460L;
	
	private MaestroServicio tipoServicio;
	private String descripcionServicio;
	private BaseVO aerolinea;
	private BaseVO operadora;
	private Ruta ruta;
	private int dias;
	private int noches;
	private Date fechaServicio;
	private Date fechaIda;
	private Date fechaRegreso;
	private int cantidad;
	private BaseVO moneda;
	private BaseVO monedaFacturacion;
	private BigDecimal tipoCambio;
	private BigDecimal precioUnitarioAnterior;
	private BigDecimal precioUnitario;
	private BigDecimal precioUnitarioConIgv;
	private BigDecimal montoComision;
	private BigDecimal montoIGV;
	private BigDecimal total;
	private ServicioProveedor servicioProveedor;
	private BaseVO servicioPadre;
	private Consolidador consolidador;
	private BaseVO empresaTransporte;
	private BaseVO hotel;

	private List<DetalleServicioAgencia> serviciosHijos;
	private List<Pasajero> listaPasajeros;

	private ConfiguracionTipoServicio configuracionTipoServicio;

	private boolean tarifaNegociada;
	private boolean conIGV;

	private boolean agrupado;
	private int cantidadAgrupados;
	private BigDecimal totalAgrupados;
	private List<Integer> codigoEnteroAgrupados;

	private String codigoReserva;
	private String numeroBoleto;
	
	private boolean aplicaIGV;

	
	/**
	 * @return the tipoServicio
	 */
	public MaestroServicio getTipoServicio() {
		return tipoServicio;
	}

	/**
	 * @param tipoServicio the tipoServicio to set
	 */
	public void setTipoServicio(MaestroServicio tipoServicio) {
		this.tipoServicio = tipoServicio;
	}

	/**
	 * @return the descripcionServicio
	 */
	public String getDescripcionServicio() {
		return descripcionServicio;
	}

	/**
	 * @param descripcionServicio the descripcionServicio to set
	 */
	public void setDescripcionServicio(String descripcionServicio) {
		this.descripcionServicio = descripcionServicio;
	}

	/**
	 * @return the aerolinea
	 */
	public BaseVO getAerolinea() {
		return aerolinea;
	}

	/**
	 * @param aerolinea the aerolinea to set
	 */
	public void setAerolinea(BaseVO aerolinea) {
		this.aerolinea = aerolinea;
	}

	/**
	 * @return the operadora
	 */
	public BaseVO getOperadora() {
		return operadora;
	}

	/**
	 * @param operadora the operadora to set
	 */
	public void setOperadora(BaseVO operadora) {
		this.operadora = operadora;
	}

	/**
	 * @return the ruta
	 */
	public Ruta getRuta() {
		return ruta;
	}

	/**
	 * @param ruta the ruta to set
	 */
	public void setRuta(Ruta ruta) {
		this.ruta = ruta;
	}

	/**
	 * @return the dias
	 */
	public int getDias() {
		return dias;
	}

	/**
	 * @param dias the dias to set
	 */
	public void setDias(int dias) {
		this.dias = dias;
	}

	/**
	 * @return the noches
	 */
	public int getNoches() {
		return noches;
	}

	/**
	 * @param noches the noches to set
	 */
	public void setNoches(int noches) {
		this.noches = noches;
	}

	/**
	 * @return the fechaServicio
	 */
	public Date getFechaServicio() {
		return fechaServicio;
	}

	/**
	 * @param fechaServicio the fechaServicio to set
	 */
	public void setFechaServicio(Date fechaServicio) {
		this.fechaServicio = fechaServicio;
	}

	/**
	 * @return the fechaIda
	 */
	public Date getFechaIda() {
		return fechaIda;
	}

	/**
	 * @param fechaIda the fechaIda to set
	 */
	public void setFechaIda(Date fechaIda) {
		this.fechaIda = fechaIda;
	}

	/**
	 * @return the fechaRegreso
	 */
	public Date getFechaRegreso() {
		return fechaRegreso;
	}

	/**
	 * @param fechaRegreso the fechaRegreso to set
	 */
	public void setFechaRegreso(Date fechaRegreso) {
		this.fechaRegreso = fechaRegreso;
	}

	/**
	 * @return the cantidad
	 */
	public int getCantidad() {
		return cantidad;
	}

	/**
	 * @param cantidad the cantidad to set
	 */
	public void setCantidad(int cantidad) {
		this.cantidad = cantidad;
	}

	/**
	 * @return the moneda
	 */
	public BaseVO getMoneda() {
		return moneda;
	}

	/**
	 * @param moneda the moneda to set
	 */
	public void setMoneda(BaseVO moneda) {
		this.moneda = moneda;
	}

	/**
	 * @return the monedaFacturacion
	 */
	public BaseVO getMonedaFacturacion() {
		return monedaFacturacion;
	}

	/**
	 * @param monedaFacturacion the monedaFacturacion to set
	 */
	public void setMonedaFacturacion(BaseVO monedaFacturacion) {
		this.monedaFacturacion = monedaFacturacion;
	}

	/**
	 * @return the tipoCambio
	 */
	public BigDecimal getTipoCambio() {
		return tipoCambio;
	}

	/**
	 * @param tipoCambio the tipoCambio to set
	 */
	public void setTipoCambio(BigDecimal tipoCambio) {
		this.tipoCambio = tipoCambio;
	}

	/**
	 * @return the precioUnitarioAnterior
	 */
	public BigDecimal getPrecioUnitarioAnterior() {
		return precioUnitarioAnterior;
	}

	/**
	 * @param precioUnitarioAnterior the precioUnitarioAnterior to set
	 */
	public void setPrecioUnitarioAnterior(BigDecimal precioUnitarioAnterior) {
		this.precioUnitarioAnterior = precioUnitarioAnterior;
	}

	/**
	 * @return the precioUnitario
	 */
	public BigDecimal getPrecioUnitario() {
		return precioUnitario;
	}

	/**
	 * @param precioUnitario the precioUnitario to set
	 */
	public void setPrecioUnitario(BigDecimal precioUnitario) {
		this.precioUnitario = precioUnitario;
	}

	/**
	 * @return the precioUnitarioConIgv
	 */
	public BigDecimal getPrecioUnitarioConIgv() {
		return precioUnitarioConIgv;
	}

	/**
	 * @param precioUnitarioConIgv the precioUnitarioConIgv to set
	 */
	public void setPrecioUnitarioConIgv(BigDecimal precioUnitarioConIgv) {
		this.precioUnitarioConIgv = precioUnitarioConIgv;
	}

	/**
	 * @return the montoComision
	 */
	public BigDecimal getMontoComision() {
		return montoComision;
	}

	/**
	 * @param montoComision the montoComision to set
	 */
	public void setMontoComision(BigDecimal montoComision) {
		this.montoComision = montoComision;
	}

	/**
	 * @return the montoIGV
	 */
	public BigDecimal getMontoIGV() {
		return montoIGV;
	}

	/**
	 * @param montoIGV the montoIGV to set
	 */
	public void setMontoIGV(BigDecimal montoIGV) {
		this.montoIGV = montoIGV;
	}

	/**
	 * @return the total
	 */
	public BigDecimal getTotal() {
		return total;
	}

	/**
	 * @param total the total to set
	 */
	public void setTotal(BigDecimal total) {
		this.total = total;
	}

	/**
	 * @return the servicioProveedor
	 */
	public ServicioProveedor getServicioProveedor() {
		return servicioProveedor;
	}

	/**
	 * @param servicioProveedor the servicioProveedor to set
	 */
	public void setServicioProveedor(ServicioProveedor servicioProveedor) {
		this.servicioProveedor = servicioProveedor;
	}

	/**
	 * @return the servicioPadre
	 */
	public BaseVO getServicioPadre() {
		return servicioPadre;
	}

	/**
	 * @param servicioPadre the servicioPadre to set
	 */
	public void setServicioPadre(BaseVO servicioPadre) {
		this.servicioPadre = servicioPadre;
	}

	/**
	 * @return the consolidador
	 */
	public Consolidador getConsolidador() {
		return consolidador;
	}

	/**
	 * @param consolidador the consolidador to set
	 */
	public void setConsolidador(Consolidador consolidador) {
		this.consolidador = consolidador;
	}

	/**
	 * @return the empresaTransporte
	 */
	public BaseVO getEmpresaTransporte() {
		return empresaTransporte;
	}

	/**
	 * @param empresaTransporte the empresaTransporte to set
	 */
	public void setEmpresaTransporte(BaseVO empresaTransporte) {
		this.empresaTransporte = empresaTransporte;
	}

	/**
	 * @return the hotel
	 */
	public BaseVO getHotel() {
		return hotel;
	}

	/**
	 * @param hotel the hotel to set
	 */
	public void setHotel(BaseVO hotel) {
		this.hotel = hotel;
	}

	/**
	 * @return the serviciosHijos
	 */
	public List<DetalleServicioAgencia> getServiciosHijos() {
		return serviciosHijos;
	}

	/**
	 * @param serviciosHijos the serviciosHijos to set
	 */
	public void setServiciosHijos(List<DetalleServicioAgencia> serviciosHijos) {
		this.serviciosHijos = serviciosHijos;
	}

	/**
	 * @return the listaPasajeros
	 */
	public List<Pasajero> getListaPasajeros() {
		return listaPasajeros;
	}

	/**
	 * @param listaPasajeros the listaPasajeros to set
	 */
	public void setListaPasajeros(List<Pasajero> listaPasajeros) {
		this.listaPasajeros = listaPasajeros;
	}

	/**
	 * @return the configuracionTipoServicio
	 */
	public ConfiguracionTipoServicio getConfiguracionTipoServicio() {
		return configuracionTipoServicio;
	}

	/**
	 * @param configuracionTipoServicio the configuracionTipoServicio to set
	 */
	public void setConfiguracionTipoServicio(
			ConfiguracionTipoServicio configuracionTipoServicio) {
		this.configuracionTipoServicio = configuracionTipoServicio;
	}

	/**
	 * @return the tarifaNegociada
	 */
	public boolean isTarifaNegociada() {
		return tarifaNegociada;
	}

	/**
	 * @param tarifaNegociada the tarifaNegociada to set
	 */
	public void setTarifaNegociada(boolean tarifaNegociada) {
		this.tarifaNegociada = tarifaNegociada;
	}

	/**
	 * @return the conIGV
	 */
	public boolean isConIGV() {
		return conIGV;
	}

	/**
	 * @param conIGV the conIGV to set
	 */
	public void setConIGV(boolean conIGV) {
		this.conIGV = conIGV;
	}

	/**
	 * @return the agrupado
	 */
	public boolean isAgrupado() {
		return agrupado;
	}

	/**
	 * @param agrupado the agrupado to set
	 */
	public void setAgrupado(boolean agrupado) {
		this.agrupado = agrupado;
	}

	/**
	 * @return the cantidadAgrupados
	 */
	public int getCantidadAgrupados() {
		return cantidadAgrupados;
	}

	/**
	 * @param cantidadAgrupados the cantidadAgrupados to set
	 */
	public void setCantidadAgrupados(int cantidadAgrupados) {
		this.cantidadAgrupados = cantidadAgrupados;
	}

	/**
	 * @return the totalAgrupados
	 */
	public BigDecimal getTotalAgrupados() {
		return totalAgrupados;
	}

	/**
	 * @param totalAgrupados the totalAgrupados to set
	 */
	public void setTotalAgrupados(BigDecimal totalAgrupados) {
		this.totalAgrupados = totalAgrupados;
	}

	/**
	 * @return the codigoEnteroAgrupados
	 */
	public List<Integer> getCodigoEnteroAgrupados() {
		return codigoEnteroAgrupados;
	}

	/**
	 * @param codigoEnteroAgrupados the codigoEnteroAgrupados to set
	 */
	public void setCodigoEnteroAgrupados(List<Integer> codigoEnteroAgrupados) {
		this.codigoEnteroAgrupados = codigoEnteroAgrupados;
	}

	/**
	 * @return the codigoReserva
	 */
	public String getCodigoReserva() {
		return codigoReserva;
	}

	/**
	 * @param codigoReserva the codigoReserva to set
	 */
	public void setCodigoReserva(String codigoReserva) {
		this.codigoReserva = codigoReserva;
	}

	/**
	 * @return the numeroBoleto
	 */
	public String getNumeroBoleto() {
		return numeroBoleto;
	}

	/**
	 * @param numeroBoleto the numeroBoleto to set
	 */
	public void setNumeroBoleto(String numeroBoleto) {
		this.numeroBoleto = numeroBoleto;
	}

	/**
	 * @return the aplicaIGV
	 */
	public boolean isAplicaIGV() {
		return aplicaIGV;
	}

	/**
	 * @param aplicaIGV the aplicaIGV to set
	 */
	public void setAplicaIGV(boolean aplicaIGV) {
		this.aplicaIGV = aplicaIGV;
	}
	
	
}
