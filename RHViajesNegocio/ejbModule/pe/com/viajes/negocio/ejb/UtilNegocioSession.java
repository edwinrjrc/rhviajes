package pe.com.viajes.negocio.ejb;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import javax.ejb.EJB;
import javax.ejb.Stateless;

import org.apache.commons.lang3.StringUtils;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.jasper.DetalleServicio;
import pe.com.viajes.bean.negocio.Comprobante;
import pe.com.viajes.bean.negocio.ConfiguracionTipoServicio;
import pe.com.viajes.bean.negocio.Contacto;
import pe.com.viajes.bean.negocio.Destino;
import pe.com.viajes.bean.negocio.DetalleComprobante;
import pe.com.viajes.bean.negocio.DetalleServicioAgencia;
import pe.com.viajes.bean.negocio.Direccion;
import pe.com.viajes.bean.negocio.Maestro;
import pe.com.viajes.bean.negocio.MaestroServicio;
import pe.com.viajes.bean.negocio.Parametro;
import pe.com.viajes.bean.negocio.Pasajero;
import pe.com.viajes.bean.negocio.Proveedor;
import pe.com.viajes.bean.negocio.ServicioAgencia;
import pe.com.viajes.bean.negocio.ServicioNovios;
import pe.com.viajes.bean.negocio.ServicioProveedor;
import pe.com.viajes.bean.negocio.TipoCambio;
import pe.com.viajes.bean.negocio.Tramo;
import pe.com.viajes.bean.negocio.Ubigeo;
import pe.com.viajes.bean.util.UtilParse;
import pe.com.viajes.negocio.dao.ComunDao;
import pe.com.viajes.negocio.dao.DestinoDao;
import pe.com.viajes.negocio.dao.MaestroDao;
import pe.com.viajes.negocio.dao.MaestroServicioDao;
import pe.com.viajes.negocio.dao.ParametroDao;
import pe.com.viajes.negocio.dao.ProveedorDao;
import pe.com.viajes.negocio.dao.ServicioNegocioDao;
import pe.com.viajes.negocio.dao.ServicioNovaViajesDao;
import pe.com.viajes.negocio.dao.TipoCambioDao;
import pe.com.viajes.negocio.dao.UbigeoDao;
import pe.com.viajes.negocio.dao.impl.ComunDaoImpl;
import pe.com.viajes.negocio.dao.impl.DestinoDaoImpl;
import pe.com.viajes.negocio.dao.impl.MaestroDaoImpl;
import pe.com.viajes.negocio.dao.impl.MaestroServicioDaoImpl;
import pe.com.viajes.negocio.dao.impl.ParametroDaoImpl;
import pe.com.viajes.negocio.dao.impl.ProveedorDaoImpl;
import pe.com.viajes.negocio.dao.impl.ServicioNegocioDaoImpl;
import pe.com.viajes.negocio.dao.impl.ServicioNovaViajesDaoImpl;
import pe.com.viajes.negocio.dao.impl.TipoCambioDaoImpl;
import pe.com.viajes.negocio.dao.impl.UbigeoDaoImpl;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.negocio.exception.ErrorRegistroDataException;
import pe.com.viajes.negocio.util.UtilConexion;
import pe.com.viajes.negocio.util.UtilEjb;
import pe.com.viajes.negocio.util.UtilJdbc;

/**
 * Session Bean implementation class UtilNegocioSession
 */
@Stateless(name = "UtilNegocioSession")
public class UtilNegocioSession implements UtilNegocioSessionRemote,
		UtilNegocioSessionLocal {

	@EJB
	NegocioSessionLocal negocioSessionLocal;

	@EJB
	ConsultaNegocioSessionLocal consultaNegocioSessionLocal;

	@EJB
	SoporteLocal soporteSessionLocal;

	@Override
	public List<DetalleServicioAgencia> agruparServiciosHijos(
			List<DetalleServicioAgencia> listaServicios, Integer idEmpresa) {
		List<DetalleServicioAgencia> listaServiciosAgrupados = new ArrayList<DetalleServicioAgencia>();

		try {
			for (DetalleServicioAgencia detalleServicioAgencia : listaServicios) {
				detalleServicioAgencia
						.setServiciosHijos(agruparHijos(detalleServicioAgencia
								.getServiciosHijos(),idEmpresa));
				listaServiciosAgrupados.add(detalleServicioAgencia);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return listaServiciosAgrupados;
	}

	private List<DetalleServicioAgencia> agruparHijos(
			List<DetalleServicioAgencia> listaServicios, Integer idEmpresa) {
		List<DetalleServicioAgencia> listaServiciosAgrupados = new ArrayList<DetalleServicioAgencia>();

		try {
			MaestroServicioDao maestroServicioDao = new MaestroServicioDaoImpl();
			List<MaestroServicio> listaTiposServicio = null;
			listaTiposServicio = maestroServicioDao.listarMaestroServiciosAdm(idEmpresa);
			int agrupados = 0;
			BigDecimal montoAgrupado = null;
			int cantidadAgrupado = 0;

			DetalleServicioAgencia detalle = null;
			for (MaestroServicio maestroServicio : listaTiposServicio) {
				detalle = null;
				detalle = new DetalleServicioAgencia();
				agrupados = 0;
				montoAgrupado = BigDecimal.ZERO;
				cantidadAgrupado = 0;
				BaseVO moneda = null;
				for (DetalleServicioAgencia detalleHijo : listaServicios) {
					if (detalleHijo.getTipoServicio().getCodigoEntero()
							.intValue() == maestroServicio.getCodigoEntero()
							.intValue()) {
						montoAgrupado = montoAgrupado.add(detalleHijo
								.getTotalServicio());
						cantidadAgrupado += detalleHijo.getCantidad();
						agrupados++;
						detalle.setCodigoEntero(detalleHijo.getCodigoEntero());
						detalle.setTipoServicio(maestroServicio);
						detalle.setFechaIda(detalleHijo.getFechaIda());
						detalle.setFechaServicio(detalleHijo.getFechaServicio());
						detalle.setFechaRegreso(detalleHijo.getFechaRegreso());
						detalle.setCantidad(detalleHijo.getCantidad());
						detalle.setPrecioUnitario(detalleHijo
								.getPrecioUnitario());
						detalle.setRuta(detalleHijo.getRuta());
						detalle.setDescripcionServicio(detalleHijo
								.getDescripcionServicio());
						detalle.setServicioProveedor(detalleHijo
								.getServicioProveedor());
						detalle.setAerolinea(detalleHijo.getAerolinea());
						detalle.setHotel(detalleHijo.getHotel());
						detalle.setTieneDetraccion(detalleHijo
								.isTieneDetraccion());
						detalle.setTieneRetencion(detalleHijo
								.isTieneRetencion());
						detalle.setTarifaNegociada(detalleHijo
								.isTarifaNegociada());
						detalle.setConfiguracionTipoServicio(detalleHijo
								.getConfiguracionTipoServicio());
						detalle.setMontoComision(detalleHijo.getMontoComision());
						detalle.getCodigoEnteroAgrupados().add(
								detalleHijo.getCodigoEntero());
						detalle.setComprobanteAsociado(detalleHijo
								.getComprobanteAsociado());
						detalle.setTipoComprobante(detalleHijo
								.getTipoComprobante());
						detalle.setNroComprobante(detalleHijo
								.getNroComprobante());
						detalle.setIdComprobanteGenerado(detalleHijo
								.getIdComprobanteGenerado());
						detalle.setMoneda(detalleHijo.getMoneda());
						moneda = detalleHijo.getMoneda();
						detalle.setServicioPadre(detalleHijo.getServicioPadre());
					}
				}
				if (agrupados > 1) {
					detalle.setCantidad(cantidadAgrupado);
					detalle.setDescripcionServicio("Servicios agrupados :: "
							+ agrupados);
					detalle.setAgrupado(true);
					detalle.setCantidadAgrupados(agrupados);

					BigDecimal precio = montoAgrupado.divide(
							BigDecimal.valueOf(cantidadAgrupado),
							BigDecimal.ROUND_CEILING);
					detalle.setPrecioUnitario(precio);
					detalle.setMoneda(moneda);
					detalle.setTotal(montoAgrupado);
					listaServiciosAgrupados.add(detalle);
				} else if (agrupados > 0) {
					listaServiciosAgrupados.add(detalle);
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return listaServiciosAgrupados;
	}

	@Override
	public List<DetalleServicioAgencia> agregarServicioVenta(
			Integer idMonedaServicio,
			List<DetalleServicioAgencia> listaServiciosVenta,
			DetalleServicioAgencia detalleServicio)
			throws ErrorRegistroDataException, SQLException, Exception {

		Connection conn = null;

		try {
			conn = UtilConexion.obtenerConexion();

			MaestroServicioDao maestroServicioDao = new MaestroServicioDaoImpl();
			DestinoDao destinoDao = new DestinoDaoImpl();
			ProveedorDao proveedorDao = new ProveedorDaoImpl();
			ComunDao comunDao = new ComunDaoImpl();
			TipoCambioDao tipoCambioDao = new TipoCambioDaoImpl(detalleServicio.getEmpresa().getCodigoEntero());
			MaestroDao maestroDao = new MaestroDaoImpl();

			TipoCambio tipoCambio = tipoCambioDao.consultarTipoCambio(
					detalleServicio.getMoneda().getCodigoEntero(),
					idMonedaServicio, conn);
			detalleServicio.setTipoCambio(tipoCambio.getMontoCambio());
			
			Maestro hijoMaestro = new Maestro();
			hijoMaestro.setCodigoMaestro(UtilEjb.obtenerEnteroPropertieMaestro("maestroMonedas", "aplicacionDatosEjb"));
			hijoMaestro.setCodigoEntero(idMonedaServicio);
			hijoMaestro.setEmpresa(detalleServicio.getEmpresa());
			Maestro hijoMoneda = maestroDao.consultarHijoMaestro(hijoMaestro);
			detalleServicio.setMonedaFacturacion(hijoMoneda);

			MaestroServicio tipoServicio = maestroServicioDao
					.consultarMaestroServicio(detalleServicio.getTipoServicio()
							.getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero(), conn);
			detalleServicio.setTipoServicio(tipoServicio);
			DetalleServicioAgencia detalle = null;
			if (!detalleServicio.getTipoServicio().isServicioPadre()) {
				for (int i = 0; i < listaServiciosVenta.size(); i++) {
					detalle = listaServiciosVenta.get(i);
					if (detalle.getCodigoEntero().intValue() == detalleServicio
							.getServicioPadre().getCodigoEntero().intValue()) {
						break;
					}
				}

				if (detalleServicio.getFechaIda() == null) {
					detalleServicio.setFechaIda(detalle.getFechaIda());
				}
			}
			
			if (detalleServicio.getFechaIda() == null){
				detalleServicio.setFechaIda(new Date());
			}

			// obtener nombre empresa proveedor
			if (detalleServicio.getServicioProveedor().getProveedor()
					.getCodigoEntero() != null
					&& detalleServicio.getServicioProveedor().getProveedor()
							.getCodigoEntero().intValue() != 0) {
				detalleServicio.getServicioProveedor().setProveedor(
						proveedorDao.consultarProveedor(detalleServicio
								.getServicioProveedor().getProveedor()
								.getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero(), conn));
			}

			// obtener nombre aerolinea
			if (detalleServicio.getAerolinea().getCodigoEntero() != null
					&& detalleServicio.getAerolinea().getCodigoEntero()
							.intValue() != 0) {
				detalleServicio.getAerolinea().setNombre(
						proveedorDao.consultarProveedor(
								detalleServicio.getAerolinea()
										.getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero(), conn)
								.getNombreCompleto());
			}

			// obtener nombre empresa transporte
			if (detalleServicio.getEmpresaTransporte().getCodigoEntero() != null
					&& detalleServicio.getEmpresaTransporte().getCodigoEntero()
							.intValue() != 0) {
				detalleServicio.getEmpresaTransporte().setNombre(
						proveedorDao.consultarProveedor(
								detalleServicio.getEmpresaTransporte()
										.getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero(), conn)
								.getNombreCompleto());
			}

			// obtener nombre operador
			if (detalleServicio.getOperadora().getCodigoEntero() != null
					&& detalleServicio.getOperadora().getCodigoEntero()
							.intValue() != 0) {
				detalleServicio.getOperadora().setNombre(
						proveedorDao.consultarProveedor(
								detalleServicio.getOperadora()
										.getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero(), conn)
								.getNombreCompleto());
			}

			// obtener nombre hotel
			if (detalleServicio.getHotel().getCodigoEntero() != null
					&& detalleServicio.getHotel().getCodigoEntero().intValue() != 0) {
				detalleServicio.getHotel().setNombre(
						proveedorDao.consultarProveedor(
								detalleServicio.getHotel().getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero(),
								conn).getNombreCompleto());
			}

			// Obtener la descripcion del servicio
			detalleServicio.setDescripcionServicio(this.generarDescripcionServicio(detalleServicio));
			
			BigDecimal comision = BigDecimal.ZERO;
			BigDecimal totalVenta = BigDecimal.ZERO;

			if (StringUtils.isBlank(detalleServicio.getDescripcionServicio())) {
				detalleServicio.setDescripcionServicio(StringUtils
						.upperCase(detalleServicio.getTipoServicio()
								.getNombre()));
			}

			detalleServicio.setDescripcionServicio(StringUtils
					.upperCase(detalleServicio.getDescripcionServicio()));

			if (detalleServicio.getCantidad() == 0) {
				detalleServicio.setCantidad(1);

				if (!detalleServicio.getTipoServicio().isServicioPadre()) {
					detalleServicio.setCantidad(detalle.getCantidad());
				}
			}

			if (detalleServicio.getRuta() != null) {
				for (Tramo tramo : detalleServicio.getRuta().getTramos()) {
					tramo.setOrigen(destinoDao.consultarDestino(tramo
							.getOrigen().getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero(), conn));
					tramo.setDestino(destinoDao.consultarDestino(tramo
							.getDestino().getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero(), conn));
				}
			}

			boolean calcularIGV = detalleServicio.isAplicaIGV();

			if (detalleServicio.getPrecioUnitarioAnterior() != null) {
				detalleServicio.setPrecioUnitario(detalleServicio
						.getPrecioUnitarioAnterior().multiply(
								tipoCambio.getMontoCambio()));
				BigDecimal total = detalleServicio.getPrecioUnitario()
						.multiply(
								UtilParse.parseIntABigDecimal(detalleServicio
										.getCantidad()));
				if (calcularIGV) {
					if (detalleServicio.isConIGV()) {
						detalleServicio.setPrecioUnitarioConIgv(detalleServicio
								.getPrecioUnitario());
						ParametroDao parametroDao = new ParametroDaoImpl();
						BigDecimal valorParametro = BigDecimal.ZERO;
						Parametro param = parametroDao
								.consultarParametro(UtilEjb
										.obtenerEnteroPropertieMaestro(
												"codigoParametroIGV",
												"aplicacionDatosEjb"), detalleServicio.getEmpresa().getCodigoEntero());
						List<MaestroServicio> lista = maestroServicioDao
								.consultarServiciosInvisibles(detalleServicio
										.getTipoServicio().getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero());
						for (MaestroServicio maestroServicio : lista) {
							if (maestroServicio.getCodigoEntero().intValue() == UtilEjb
									.convertirCadenaEntero(param.getValor())) {
								valorParametro = UtilEjb
										.convertirCadenaDecimal(maestroServicio
												.getValorParametro());
								break;
							}
						}
						valorParametro = valorParametro.add(BigDecimal.ONE);
						BigDecimal precioBase = detalleServicio
								.getPrecioUnitario().divide(valorParametro, 4,
										RoundingMode.HALF_DOWN);
						total = precioBase.multiply(UtilParse
								.parseIntABigDecimal(detalleServicio
										.getCantidad()));
						detalleServicio.setPrecioUnitario(precioBase);
					}
				}

				totalVenta = totalVenta.add(total);
			}

			if (detalleServicio.getServicioProveedor().getComision().getValorComision() != null){
				int tipoComision = detalleServicio.getServicioProveedor().getComision().getTipoComision().getCodigoEntero().intValue();
				boolean servicioConIGV = false;
				boolean servicioSinIGV = false;
				String serviciosCadena = UtilEjb.obtenerCadenaPropertieMaestro("serviciosConIGV", "aplicacionDatosEjb");
				if (StringUtils.isBlank(serviciosCadena)){
					throw new ErrorRegistroDataException("No se configuro los servicios con IGV en archivo properties aplicacionDatosEjb.properties");
				}
				String[] servicios = serviciosCadena.split(",");
				
				for(String idServicio : servicios){
					if (UtilEjb.convertirCadenaEntero(idServicio) == detalleServicio.getTipoServicio().getCodigoEntero().intValue() ){
						servicioConIGV = true;
						break;
					}
				}
				
				serviciosCadena = UtilEjb.obtenerCadenaPropertieMaestro("serviciosSinIGV", "aplicacionDatosEjb");
				if (StringUtils.isBlank(serviciosCadena)){
					throw new ErrorRegistroDataException("No se configuro los servicios sin IGV en archivo properties aplicacionDatosEjb.properties");
				}
				servicios = serviciosCadena.split(",");
				
				for(String idServicio : servicios){
					if (UtilEjb.convertirCadenaEntero(idServicio) == detalleServicio.getTipoServicio().getCodigoEntero().intValue() ){
						servicioSinIGV = true;
						break;
					}
				}
				
				if (servicioConIGV){
					if (tipoComision == UtilEjb.obtenerEnteroPropertieMaestro("comisionPorcentaje", "aplicacionDatosEjb")){
						
						comision = detalleServicio.getServicioProveedor().getComision().getValorComision().multiply(totalVenta);
						detalleServicio.getServicioProveedor().getComision().setValorComisionSinIGV(desglozarMontoSinIGV(comision, detalleServicio.getEmpresa().getCodigoEntero()));
						detalleServicio.getServicioProveedor().getComision().setValorIGVComision(comision.subtract(detalleServicio.getServicioProveedor().getComision().getValorComisionSinIGV()));
						comision = comision.divide(BigDecimal.valueOf(100.0));
						
						detalleServicio.getServicioProveedor().getComision().setMontoTotal(comision);
					}
					else if (tipoComision == UtilEjb.obtenerEnteroPropertieMaestro("comisionMontoFijo", "aplicacionDatosEjb")){
						comision = comision.add(detalleServicio.getServicioProveedor().getComision().getValorComision());
						
						detalleServicio.getServicioProveedor().getComision().setValorComisionSinIGV(desglozarMontoSinIGV(comision, detalleServicio.getEmpresa().getCodigoEntero()));
						detalleServicio.getServicioProveedor().getComision().setValorIGVComision(comision.subtract(detalleServicio.getServicioProveedor().getComision().getValorComisionSinIGV()));
						
						detalleServicio.getServicioProveedor().getComision().setMontoTotal(comision);
					}
				}
				else if (servicioSinIGV){
					if (tipoComision == UtilEjb.obtenerEnteroPropertieMaestro("comisionPorcentaje", "aplicacionDatosEjb")){
						
						comision = detalleServicio.getServicioProveedor().getComision().getValorComision().multiply(totalVenta);
						comision = comision.divide(BigDecimal.valueOf(100.0));
						detalleServicio.getServicioProveedor().getComision().setValorComisionSinIGV(comision);
						detalleServicio.getServicioProveedor().getComision().setValorIGVComision(calcularIGVMonto(comision, detalleServicio.getEmpresa().getCodigoEntero()));
						
						if (detalleServicio.getServicioProveedor().getComision().isAplicaIGV()){
							comision = aplicarIGVMonto(comision, detalleServicio.getEmpresa().getCodigoEntero());
						}
						detalleServicio.getServicioProveedor().getComision().setMontoTotal(comision);
					}
					else if (tipoComision == UtilEjb.obtenerEnteroPropertieMaestro("comisionMontoFijo", "aplicacionDatosEjb")){
						comision = comision.add(detalleServicio.getServicioProveedor().getComision().getValorComision());
						
						detalleServicio.getServicioProveedor().getComision().setValorComisionSinIGV(comision);
						detalleServicio.getServicioProveedor().getComision().setValorIGVComision(calcularIGVMonto(comision, detalleServicio.getEmpresa().getCodigoEntero()));
						if (detalleServicio.getServicioProveedor().getComision().isAplicaIGV()){
							comision = aplicarIGVMonto(comision, detalleServicio.getEmpresa().getCodigoEntero());
						}
						detalleServicio.getServicioProveedor().getComision().setMontoTotal(comision);
					}
				}
			}

			detalleServicio.setMontoComision(comision);

			int idDetServicio = comunDao.obtenerSiguienteSecuencia(conn);
			detalleServicio.setCodigoEntero(idDetServicio);
			listaServiciosVenta.add(detalleServicio);

			List<DetalleServicioAgencia> listaInvisibles = null;
			if (detalleServicio.getTipoServicio().isServicioPadre()) {
				listaInvisibles = agregarServicioVentaInvisible(idDetServicio,
						detalleServicio, calcularIGV);
			} else {
				listaInvisibles = agregarServicioVentaInvisible(detalleServicio
						.getServicioPadre().getCodigoEntero(), detalleServicio,
						calcularIGV);
			}

			if (listaInvisibles != null) {
				listaServiciosVenta.addAll(listaInvisibles);
			}

			listaServiciosVenta = UtilEjb
					.ordenarServiciosVenta(listaServiciosVenta);

			return listaServiciosVenta;
		} catch (SQLException e) {
			throw new ErrorRegistroDataException(e.getMessage(), e);

		} catch (Exception e) {
			throw new ErrorRegistroDataException(
					"No se pudo agregar el servicio al listado", e);

		} finally {
			if (conn != null) {
				conn.close();
			}
		}
	}
	
	private BigDecimal obtenerPorcentajeIGV(Integer idEmpresa) throws SQLException{
		ParametroDao parametroDao = new ParametroDaoImpl();
		Parametro paramIGV = parametroDao.consultarParametro(UtilEjb
				.obtenerEnteroPropertieMaestro("codigoParametroImptoIGV",
						"aplicacionDatosEjb"), idEmpresa);
		
		return UtilEjb.convertirCadenaDecimal(paramIGV.getValor());
	}
	
	private BigDecimal calcularIGVMonto(BigDecimal montoValor, Integer idEmpresa) throws SQLException{
		return montoValor.multiply(obtenerPorcentajeIGV(idEmpresa));
	}

	private BigDecimal aplicarIGVMonto(BigDecimal monto, Integer idEmpresa) throws SQLException {
		BigDecimal valorParametroIGV = obtenerPorcentajeIGV(idEmpresa);
		valorParametroIGV = valorParametroIGV.add(BigDecimal.ONE);
		monto = monto.multiply(valorParametroIGV);

		return monto;
	}
	
	@Override
	public BigDecimal desglozarMontoSinIGV(BigDecimal monto, Integer idEmpresa) throws SQLException{
		BigDecimal valorDesglozar = obtenerPorcentajeIGV(idEmpresa).add(BigDecimal.ONE);
		monto = monto.divide(valorDesglozar, RoundingMode.HALF_UP);
		
		return monto;
	}
	
	@Override
	public BigDecimal obtenerMontoIGV(BigDecimal monto, Integer idEmpresa) throws SQLException{
		BigDecimal valor = desglozarMontoSinIGV(monto, idEmpresa);
		BigDecimal valorIGVFinal = monto.subtract(valor); 
		return valorIGVFinal;
	}

	private String generarDescripcionServicio(DetalleServicioAgencia detalle) {
		try {
			String descripcion = "";
			if (StringUtils.isBlank(detalle.getDescripcionServicio())) {
				ConfiguracionTipoServicio configuracion = this.soporteSessionLocal
						.consultarConfiguracionServicio(detalle
								.getTipoServicio().getCodigoEntero(), detalle.getEmpresa().getCodigoEntero());

				descripcion = detalle.getTipoServicio().getNombre() + " ";
				if (configuracion.isMuestraRuta()) {
					descripcion = descripcion + detalle.getRuta().getTramos().get(0).getOrigen().getDescripcion() + " / ";
					for (int i=0; i<detalle.getRuta().getTramos().size(); i++){
						Tramo tramo = detalle.getRuta().getTramos().get(i);
						descripcion = descripcion + tramo.getDestino().getDescripcion() + " / ";
					}
				}
				if (configuracion.isMuestraAerolinea()) {
					descripcion = descripcion + " con "
							+ detalle.getAerolinea().getNombre() + " ";
				}
				if (configuracion.isMuestraFechaServicio()) {
					SimpleDateFormat sdf = new SimpleDateFormat(
							"dd/MM/yyyy HH:mm");
					descripcion = descripcion + " desde "
							+ sdf.format(detalle.getFechaIda());
				}
				if (configuracion.isMuestraFechaRegreso()) {
					SimpleDateFormat sdf = new SimpleDateFormat(
							"dd/MM/yyyy HH:mm");
					descripcion = descripcion + " hasta "
							+ sdf.format(detalle.getFechaRegreso());
				}
				if (configuracion.isMuestraHotel()) {
					descripcion = descripcion + " en hotel "
							+ detalle.getHotel().getNombre();
				}
				if (configuracion.isMuestraCodigoReserva()) {
					descripcion = descripcion + " con codigo de reserva: "
							+ detalle.getCodigoReserva();
				}
				if (configuracion.isMuestraNumeroBoleto()) {
					descripcion = descripcion + " numero de boleto: "
							+ detalle.getNumeroBoleto();
				}
				return StringUtils.normalizeSpace(descripcion);
			} else {
				descripcion = detalle.getTipoServicio().getNombre() + " - "
						+ detalle.getDescripcionServicio();

				return StringUtils.normalizeSpace(descripcion);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return "";
	}

	@Override
	public List<DetalleServicioAgencia> actualizarServicioVenta(
			Integer idMonedaServicio,
			List<DetalleServicioAgencia> listaServiciosVenta,
			DetalleServicioAgencia detalleServicio)
			throws ErrorRegistroDataException, SQLException, Exception {

		Connection conn = null;

		try {
			DetalleServicioAgencia detalleServicioAgencia = null;
			int codigo = 0;
			for (int i = 0; i < listaServiciosVenta.size(); i++) {
				detalleServicioAgencia = listaServiciosVenta.get(i);
				if (detalleServicioAgencia.getCodigoEntero().intValue() == detalleServicio
						.getCodigoEntero().intValue()) {
					codigo = detalleServicioAgencia.getCodigoEntero()
							.intValue();
					break;
				}
			}

			conn = UtilConexion.obtenerConexion();

			MaestroServicioDao maestroServicioDao = new MaestroServicioDaoImpl();
			DestinoDao destinoDao = new DestinoDaoImpl();
			ProveedorDao proveedorDao = new ProveedorDaoImpl();
			TipoCambioDao tipoCambioDao = new TipoCambioDaoImpl(detalleServicio.getEmpresa().getCodigoEntero());
			MaestroDao maestroDao = new MaestroDaoImpl();

			TipoCambio tipoCambio;
			try {
				tipoCambio = tipoCambioDao.consultarTipoCambio(detalleServicio
						.getMoneda().getCodigoEntero(), idMonedaServicio, conn);
			} catch (Exception e) {
				e.printStackTrace();
				tipoCambio = new TipoCambio();
				tipoCambio.setMontoCambio(BigDecimal.ONE);
			}
			detalleServicio.setTipoCambio(tipoCambio.getMontoCambio());
			
			Maestro hijoMaestro = new Maestro();
			hijoMaestro.setCodigoMaestro(UtilEjb.obtenerEnteroPropertieMaestro("maestroMonedas", "aplicacionDatosEjb"));
			hijoMaestro.setCodigoEntero(idMonedaServicio);
			hijoMaestro.setEmpresa(detalleServicio.getEmpresa());
			Maestro hijoMoneda = maestroDao.consultarHijoMaestro(hijoMaestro);
			detalleServicio.setMonedaFacturacion(hijoMoneda);

			detalleServicioAgencia.setTipoServicio(maestroServicioDao
					.consultarMaestroServicio(detalleServicio.getTipoServicio()
							.getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero() ,conn));

			// obtener nombre empresa proveedor
			if (detalleServicio.getServicioProveedor().getProveedor()
					.getCodigoEntero() != null
					&& detalleServicio.getServicioProveedor().getProveedor()
							.getCodigoEntero().intValue() != 0) {
				detalleServicioAgencia.getServicioProveedor().setProveedor(
						proveedorDao.consultarProveedor(detalleServicio
								.getServicioProveedor().getProveedor()
								.getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero(), conn));
			}

			// obtener nombre aerolinea
			if (detalleServicio.getAerolinea().getCodigoEntero() != null
					&& detalleServicio.getAerolinea().getCodigoEntero()
							.intValue() != 0) {
				detalleServicioAgencia.getAerolinea().setNombre(
						proveedorDao.consultarProveedor(
								detalleServicio.getAerolinea()
										.getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero(), conn)
								.getNombreCompleto());
			}

			// obtener nombre empresa transporte
			if (detalleServicio.getEmpresaTransporte().getCodigoEntero() != null
					&& detalleServicio.getEmpresaTransporte().getCodigoEntero()
							.intValue() != 0) {
				detalleServicioAgencia.getEmpresaTransporte().setNombre(
						proveedorDao.consultarProveedor(
								detalleServicio.getEmpresaTransporte()
										.getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero(), conn)
								.getNombreCompleto());
			}

			// obtener nombre operador
			if (detalleServicio.getOperadora().getCodigoEntero() != null
					&& detalleServicio.getOperadora().getCodigoEntero()
							.intValue() != 0) {
				detalleServicioAgencia.getOperadora().setNombre(
						proveedorDao.consultarProveedor(
								detalleServicio.getOperadora()
										.getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero(), conn)
								.getNombreCompleto());
			}

			// obtener nombre hotel
			if (detalleServicio.getHotel().getCodigoEntero() != null
					&& detalleServicio.getHotel().getCodigoEntero().intValue() != 0) {
				detalleServicioAgencia.getHotel().setNombre(
						proveedorDao.consultarProveedor(
								detalleServicio.getHotel().getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero(), 
								conn).getNombreCompleto());
			}

			BigDecimal comision = BigDecimal.ZERO;
			BigDecimal totalVenta = BigDecimal.ZERO;

			detalleServicioAgencia.setDescripcionServicio(StringUtils
						.upperCase(this.generarDescripcionServicio(detalleServicio)));

			detalleServicioAgencia.setDescripcionServicio(StringUtils
					.upperCase(detalleServicio.getDescripcionServicio()));

			detalleServicioAgencia.setCantidad(detalleServicio.getCantidad());
			if (detalleServicio.getCantidad() == 0) {
				detalleServicioAgencia.setCantidad(1);
			}

			if (detalleServicio.getRuta() != null) {
				for (Tramo tramo : detalleServicio.getRuta().getTramos()) {
					tramo.setOrigen(destinoDao.consultarDestino(tramo
							.getOrigen().getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero(), conn));
					tramo.setDestino(destinoDao.consultarDestino(tramo
							.getDestino().getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero(), conn));
				}
			}

			boolean calcularIGV = detalleServicio.isAplicaIGV();

			if (detalleServicio.getPrecioUnitarioAnterior() != null) {
				detalleServicio.setPrecioUnitario(detalleServicio
						.getPrecioUnitarioAnterior().multiply(
								tipoCambio.getMontoCambio()));
				BigDecimal total = detalleServicio.getPrecioUnitario()
						.multiply(
								UtilParse.parseIntABigDecimal(detalleServicio
										.getCantidad()));

				if (calcularIGV) {
					if (detalleServicio.isConIGV()) {
						ParametroDao parametroDao = new ParametroDaoImpl();
						BigDecimal valorParametro = BigDecimal.ZERO;
						Parametro param = parametroDao
								.consultarParametro(UtilEjb
										.obtenerEnteroPropertieMaestro(
												"codigoParametroIGV",
												"aplicacionDatosEjb"), detalleServicio.getEmpresa().getCodigoEntero());
						List<MaestroServicio> lista = maestroServicioDao
								.consultarServiciosInvisibles(detalleServicio
										.getTipoServicio().getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero());
						for (MaestroServicio maestroServicio : lista) {
							if (maestroServicio.getCodigoEntero().intValue() == UtilEjb
									.convertirCadenaEntero(param.getValor())) {
								valorParametro = UtilEjb
										.convertirCadenaDecimal(maestroServicio
												.getValorParametro());
								break;
							}
						}
						valorParametro = valorParametro.add(BigDecimal.ONE);
						BigDecimal precioBase = detalleServicio
								.getPrecioUnitario().divide(valorParametro, 4,
										RoundingMode.HALF_DOWN);
						total = precioBase.multiply(UtilParse
								.parseIntABigDecimal(detalleServicio
										.getCantidad()));
						detalleServicioAgencia.setPrecioUnitario(precioBase);
					}
				}

				totalVenta = totalVenta.add(total);
			}

			if (detalleServicio.getServicioProveedor().getComision().getValorComision() != null){
				int tipoComision = detalleServicio.getServicioProveedor().getComision().getTipoComision().getCodigoEntero().intValue();
				boolean servicioConIGV = false;
				boolean servicioSinIGV = false;
				String serviciosCadena = UtilEjb.obtenerCadenaPropertieMaestro("serviciosConIGV", "aplicacionDatosEjb");
				if (StringUtils.isBlank(serviciosCadena)){
					throw new ErrorRegistroDataException("No se configuro los servicios con IGV en archivo properties aplicacionDatosEjb.properties");
				}
				String[] servicios = serviciosCadena.split(",");
				
				for(String idServicio : servicios){
					if (UtilEjb.convertirCadenaEntero(idServicio) == detalleServicio.getTipoServicio().getCodigoEntero().intValue() ){
						servicioConIGV = true;
						break;
					}
				}
				
				serviciosCadena = UtilEjb.obtenerCadenaPropertieMaestro("serviciosSinIGV", "aplicacionDatosEjb");
				if (StringUtils.isBlank(serviciosCadena)){
					throw new ErrorRegistroDataException("No se configuro los servicios sin IGV en archivo properties aplicacionDatosEjb.properties");
				}
				servicios = serviciosCadena.split(",");
				
				for(String idServicio : servicios){
					if (UtilEjb.convertirCadenaEntero(idServicio) == detalleServicio.getTipoServicio().getCodigoEntero().intValue() ){
						servicioSinIGV = true;
						break;
					}
				}
				
				if (servicioConIGV){
					if (tipoComision == UtilEjb.obtenerEnteroPropertieMaestro("comisionPorcentaje", "aplicacionDatosEjb")){
						
						comision = detalleServicio.getServicioProveedor().getComision().getValorComision().multiply(totalVenta);
						detalleServicio.getServicioProveedor().getComision().setValorComisionSinIGV(desglozarMontoSinIGV(comision, detalleServicio.getEmpresa().getCodigoEntero()));
						detalleServicio.getServicioProveedor().getComision().setValorIGVComision(comision.subtract(detalleServicio.getServicioProveedor().getComision().getValorComisionSinIGV()));
						comision = comision.divide(BigDecimal.valueOf(100.0));
						
						detalleServicio.getServicioProveedor().getComision().setMontoTotal(comision);
					}
					else if (tipoComision == UtilEjb.obtenerEnteroPropertieMaestro("comisionMontoFijo", "aplicacionDatosEjb")){
						comision = comision.add(detalleServicio.getServicioProveedor().getComision().getValorComision());
						
						detalleServicio.getServicioProveedor().getComision().setValorComisionSinIGV(desglozarMontoSinIGV(comision, detalleServicio.getEmpresa().getCodigoEntero()));
						detalleServicio.getServicioProveedor().getComision().setValorIGVComision(comision.subtract(detalleServicio.getServicioProveedor().getComision().getValorComisionSinIGV()));
						
						detalleServicio.getServicioProveedor().getComision().setMontoTotal(comision);
					}
				}
				else if (servicioSinIGV){
					if (tipoComision == UtilEjb.obtenerEnteroPropertieMaestro("comisionPorcentaje", "aplicacionDatosEjb")){
						
						comision = detalleServicio.getServicioProveedor().getComision().getValorComision().multiply(totalVenta);
						comision = comision.divide(BigDecimal.valueOf(100.0));
						detalleServicio.getServicioProveedor().getComision().setValorComisionSinIGV(comision);
						detalleServicio.getServicioProveedor().getComision().setValorIGVComision(calcularIGVMonto(comision, detalleServicio.getEmpresa().getCodigoEntero()));
						
						if (detalleServicio.getServicioProveedor().getComision().isAplicaIGV()){
							comision = aplicarIGVMonto(comision, detalleServicio.getEmpresa().getCodigoEntero());
						}
						detalleServicio.getServicioProveedor().getComision().setMontoTotal(comision);
					}
					else if (tipoComision == UtilEjb.obtenerEnteroPropertieMaestro("comisionMontoFijo", "aplicacionDatosEjb")){
						comision = comision.add(detalleServicio.getServicioProveedor().getComision().getValorComision());
						
						detalleServicio.getServicioProveedor().getComision().setValorComisionSinIGV(comision);
						detalleServicio.getServicioProveedor().getComision().setValorIGVComision(calcularIGVMonto(comision, detalleServicio.getEmpresa().getCodigoEntero()));
						if (detalleServicio.getServicioProveedor().getComision().isAplicaIGV()){
							comision = aplicarIGVMonto(comision, detalleServicio.getEmpresa().getCodigoEntero());
						}
						detalleServicio.getServicioProveedor().getComision().setMontoTotal(comision);
					}
				}
			}
			detalleServicioAgencia.setMontoComision(comision);

			List<DetalleServicioAgencia> listaInvisibles = null;
			if (detalleServicio.getTipoServicio().isServicioPadre()) {
				listaInvisibles = agregarServicioVentaInvisible(
						detalleServicioAgencia.getCodigoEntero(),
						detalleServicio, calcularIGV);
			} else {
				listaInvisibles = agregarServicioVentaInvisible(
						detalleServicioAgencia.getServicioPadre()
								.getCodigoEntero(), detalleServicio,
						calcularIGV);
			}

			/*int indice = 0;
			
			for (int i=0; i<listaServiciosVenta.size(); i++){
				DetalleServicioAgencia detalleServicioAgencia2 = listaServiciosVenta.get(i);
				if (detalleServicioAgencia2.getServicioPadre()
						.getCodigoEntero() != null
						&& detalleServicioAgencia2.getServicioPadre()
								.getCodigoEntero().intValue() == detalleServicio
								.getCodigoEntero().intValue()) {
					indice = i;
				}
			}
			listaServiciosVenta.remove(indice);*/

			for (int i = 0; i < listaServiciosVenta.size(); i++) {
				DetalleServicioAgencia detalleServicioAgencia2 = listaServiciosVenta
						.get(i);
				if (detalleServicioAgencia2.getCodigoEntero().intValue() == codigo) {
					listaServiciosVenta.remove(detalleServicioAgencia2);
				}
			}

			listaServiciosVenta.add(detalleServicioAgencia);
			if (listaInvisibles != null) {
				for (int j=0; j<listaServiciosVenta.size(); j++){
					DetalleServicioAgencia servicioHijo = listaServiciosVenta.get(j);
					if (servicioHijo.getServicioPadre()!= null && servicioHijo.getServicioPadre().getCodigoEntero() != null && servicioHijo.getServicioPadre().getCodigoEntero().intValue() == detalleServicioAgencia.getCodigoEntero().intValue() && servicioHijo.isInvisible()){
						listaServiciosVenta.remove(j);
					}
				}
				listaServiciosVenta.addAll(listaInvisibles);
			}

			listaServiciosVenta = UtilEjb
					.ordenarServiciosVenta(listaServiciosVenta);

			return listaServiciosVenta;

		} catch (Exception e) {
			throw new ErrorRegistroDataException(
					"No se pudo agregar el servicio al listado", e);
		} finally {
			if (conn != null) {
				conn.close();
			}
		}
	}

	private List<DetalleServicioAgencia> agregarServicioVentaInvisible(
			Integer idServicioPadre, DetalleServicioAgencia detalleServicio2,
			boolean calcularIGV) throws ErrorConsultaDataException, Exception {

		List<DetalleServicioAgencia> listaServicios = new ArrayList<DetalleServicioAgencia>();
		try {
			if (calcularIGV) {
				ComunDao comunDao = new ComunDaoImpl();
				MaestroServicioDao maestroServicioDao = new MaestroServicioDaoImpl();
				List<MaestroServicio> lista = maestroServicioDao
						.consultarServiciosInvisibles(detalleServicio2
								.getTipoServicio().getCodigoEntero(), detalleServicio2.getEmpresa().getCodigoEntero());

				DetalleServicioAgencia detalle = null;
				for (MaestroServicio maestroServicio : lista) {
					detalle = new DetalleServicioAgencia();
					detalle.setCodigoEntero(comunDao
							.obtenerSiguienteSecuencia());
					detalle.setDescripcionServicio(maestroServicio.getNombre());
					detalle.setCantidad(1);
					detalle.getTipoServicio().setCodigoEntero(
							maestroServicio.getCodigoEntero());
					detalle.getTipoServicio().setNombre(
							maestroServicio.getNombre());
					detalle.getTipoServicio().setOperacionMatematica(maestroServicio.getOperacionMatematica());
					detalle.setFechaIda(new Date());
					detalle.getServicioPadre().setCodigoEntero(idServicioPadre);
					detalle.setMoneda(detalleServicio2.getMoneda());
					detalle.setTipoCambio(detalleServicio2.getTipoCambio());
					detalle.setPrecioUnitarioAnterior(detalleServicio2
							.getPrecioUnitarioAnterior());
					detalle.setInvisible(true);
					try {
						BigDecimal cantidad = BigDecimal.valueOf(Double
								.valueOf(String.valueOf(detalleServicio2
										.getCantidad())));
						BigDecimal precioBase = detalleServicio2
								.getPrecioUnitarioAnterior();
						precioBase = precioBase.multiply(detalleServicio2
								.getTipoCambio());
						BigDecimal porcenIGV = BigDecimal.valueOf(Double
								.valueOf(maestroServicio.getValorParametro()));
						BigDecimal totalServicioPrecede = precioBase
								.multiply(cantidad);

						BigDecimal igvServicio = totalServicioPrecede
								.multiply(porcenIGV);

						detalle.setMontoIGV(igvServicio);
						detalle.setPrecioUnitario(igvServicio);
						listaServicios.add(detalle);
					} catch (Exception e) {
						detalle.setMontoIGV(BigDecimal.ZERO);
						detalle.setPrecioUnitario(BigDecimal.ZERO);
						listaServicios.add(detalle);
						e.printStackTrace();
					}
				}
			}

			return listaServicios;
		} catch (SQLException e) {
			throw new ErrorConsultaDataException(
					"Error en Consulta de Servicios Ocultos", e);
		} catch (Exception e) {
			throw new ErrorConsultaDataException(
					"Error en Consulta de Servicios Ocultos", e);
		}

	}

	@Override
	public BigDecimal calculaPorcentajeComision(
			DetalleServicioAgencia detalleServicio) throws SQLException,
			Exception {
		DestinoDao destinoDao = new DestinoDaoImpl();
		ProveedorDao proveedorDao = new ProveedorDaoImpl();
		int idTipoServicio = detalleServicio.getTipoServicio()
				.getCodigoEntero().intValue();
		if (idTipoServicio == UtilEjb.obtenerEnteroPropertieMaestro(
				"servicioBoletoAereo", "aplicacionDatosEjb")) {
			int nacionales = 0;
			int internacionales = 0;
			Locale localidad = Locale.getDefault();
			if (!detalleServicio.getRuta().getTramos().isEmpty()) {
				for (Tramo tramo : detalleServicio.getRuta().getTramos()) {
					Destino destinoConsultado = destinoDao
							.consultarDestino(tramo.getDestino()
									.getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero());
					if (localidad.getCountry().equals(
							destinoConsultado.getPais().getAbreviado())) {
						nacionales++;
					}
					Destino origenConsultado = destinoDao
							.consultarDestino(tramo.getOrigen()
									.getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero());
					if (!localidad.getCountry().equals(
							origenConsultado.getPais().getAbreviado())) {
						internacionales++;
					}
					if (nacionales > 0 && internacionales > 0) {
						break;
					}
				}
			}

			List<ServicioProveedor> lista = proveedorDao
					.consultarServicioProveedor(detalleServicio
							.getServicioProveedor().getProveedor()
							.getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero());

			for (ServicioProveedor servicioProveedor : lista) {
				if ((servicioProveedor.getProveedorServicio().getCodigoEntero() != null && detalleServicio
						.getAerolinea().getCodigoEntero() != null)
						&& servicioProveedor.getProveedorServicio()
								.getCodigoEntero().intValue() == detalleServicio
								.getAerolinea().getCodigoEntero().intValue()) {

					if (nacionales > 0 && internacionales > 0) {
						return servicioProveedor.getPorcenComInternacional();
					} else {
						return servicioProveedor.getPorcentajeComision();
					}
				}
			}
		} else if (idTipoServicio == UtilEjb.obtenerEnteroPropertieMaestro(
				"servicioPaquete", "aplicacionDatosEjb")) {
			if (detalleServicio
					.getServicioProveedor().getProveedor()
					.getCodigoEntero() != null && detalleServicio.getEmpresa().getCodigoEntero() != null){
				List<ServicioProveedor> lista = proveedorDao
						.consultarServicioProveedor(detalleServicio
								.getServicioProveedor().getProveedor()
								.getCodigoEntero().intValue(), detalleServicio.getEmpresa().getCodigoEntero().intValue());
				
				for (ServicioProveedor servicioProveedor : lista) {
					if ((servicioProveedor.getProveedorServicio().getCodigoEntero() != null && detalleServicio
							.getOperadora().getCodigoEntero() != null)
							&& servicioProveedor.getProveedorServicio()
									.getCodigoEntero().intValue() == detalleServicio
									.getOperadora().getCodigoEntero().intValue()) {
						return servicioProveedor.getPorcenComInternacional();
					}
				}
			}

		} else if (idTipoServicio == UtilEjb.obtenerEnteroPropertieMaestro(
				"servicioPrograma", "aplicacionDatosEjb")) {
			List<ServicioProveedor> lista = proveedorDao
					.consultarServicioProveedor(detalleServicio
							.getServicioProveedor().getProveedor()
							.getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero());

			for (ServicioProveedor servicioProveedor : lista) {
				if ((servicioProveedor.getProveedorServicio().getCodigoEntero() != null && detalleServicio
						.getOperadora().getCodigoEntero() != null)
						&& servicioProveedor.getProveedorServicio()
								.getCodigoEntero().intValue() == detalleServicio
								.getOperadora().getCodigoEntero().intValue()) {
					return servicioProveedor.getPorcenComInternacional();
				}
			}
		} else if (idTipoServicio == UtilEjb.obtenerEnteroPropertieMaestro(
				"servicioHotel", "aplicacionDatosEjb")) {
			List<ServicioProveedor> lista = proveedorDao
					.consultarServicioProveedor(detalleServicio
							.getServicioProveedor().getProveedor()
							.getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero());

			for (ServicioProveedor servicioProveedor : lista) {
				if ((servicioProveedor.getProveedorServicio().getCodigoEntero() != null && detalleServicio
						.getHotel().getCodigoEntero() != null)
						&& servicioProveedor.getProveedorServicio()
								.getCodigoEntero().intValue() == detalleServicio
								.getHotel().getCodigoEntero().intValue()) {
					return servicioProveedor.getPorcenComInternacional();
				}
			}
		} else if (idTipoServicio == UtilEjb.obtenerEnteroPropertieMaestro(
				"servicioTraslado", "aplicacionDatosEjb")) {
			List<ServicioProveedor> lista = proveedorDao
					.consultarServicioProveedor(detalleServicio
							.getServicioProveedor().getProveedor()
							.getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero());

			for (ServicioProveedor servicioProveedor : lista) {
				if ((servicioProveedor.getProveedorServicio().getCodigoEntero() != null && detalleServicio
						.getOperadora().getCodigoEntero() != null)
						&& servicioProveedor.getProveedorServicio()
								.getCodigoEntero().intValue() == detalleServicio
								.getOperadora().getCodigoEntero().intValue()) {
					return servicioProveedor.getPorcenComInternacional();
				}
			}
		} else if (idTipoServicio == UtilEjb.obtenerEnteroPropertieMaestro(
				"servicioBoletoTerrestre", "aplicacionDatosEjb")) {
			List<ServicioProveedor> lista = proveedorDao
					.consultarServicioProveedor(detalleServicio
							.getServicioProveedor().getProveedor()
							.getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero());

			for (ServicioProveedor servicioProveedor : lista) {
				if ((servicioProveedor.getProveedorServicio().getCodigoEntero() != null && detalleServicio
						.getEmpresaTransporte().getCodigoEntero() != null)
						&& servicioProveedor.getProveedorServicio()
								.getCodigoEntero().intValue() == detalleServicio
								.getEmpresaTransporte().getCodigoEntero()
								.intValue()) {
					return servicioProveedor.getPorcenComInternacional();
				}
			}
		}

		return BigDecimal.ZERO;
	}

	@Override
	public List<DetalleServicio> consultarServiciosVentaJR(Integer idServicio, Integer idEmpresa)
			throws SQLException {
		ServicioNegocioDao servicioNegocioDao = new ServicioNegocioDaoImpl();

		return servicioNegocioDao.consultarServicioVentaJR(idServicio, idEmpresa);
	}

	@Override
	public Direccion agregarDireccion(Direccion direccion) throws SQLException,
			Exception {
		if (direccion.isNacional()){
			String iddepartamento = direccion.getUbigeo().getDepartamento()
					.getCodigoCadena();
			String idprovincia = direccion.getUbigeo().getProvincia()
					.getCodigoCadena();
			String iddistrito = direccion.getUbigeo().getDistrito()
					.getCodigoCadena();
			UbigeoDao ubigeoDao = new UbigeoDaoImpl(direccion.getEmpresa().getCodigoEntero());
			Ubigeo resultado = ubigeoDao.consultarUbigeo(iddepartamento + "0000");
			direccion.getUbigeo().setDepartamento(resultado.getDepartamento());
			direccion.getUbigeo().getDepartamento()
					.setNombre(resultado.getNombre());

			resultado = ubigeoDao.consultarUbigeo(iddepartamento + idprovincia
					+ "00");
			direccion.getUbigeo().setProvincia(resultado.getProvincia());
			direccion.getUbigeo().getProvincia().setNombre(resultado.getNombre());

			resultado = ubigeoDao.consultarUbigeo(iddepartamento + idprovincia
					+ iddistrito);
			direccion.getUbigeo().setDistrito(resultado.getDistrito());
			direccion.getUbigeo().getDistrito().setNombre(resultado.getNombre());

			direccion.getUbigeo().setCodigoCadena(
					iddepartamento + idprovincia + iddistrito);
		}

		direccion.setDireccion(obtenerDireccionCompleta(direccion));

		return direccion;
	}

	@Override
	public Contacto agregarContacto(Contacto contacto) throws SQLException,
			Exception {
		MaestroDao maestroDao = new MaestroDaoImpl();

		try {
			Maestro hijoMaestro = new Maestro();
			hijoMaestro.setCodigoEntero(contacto.getArea().getCodigoEntero());
			int valorMaestro = UtilEjb.obtenerEnteroPropertieMaestro(
					"maestroAreas", "aplicacionDatosEjb");
			hijoMaestro.setCodigoMaestro(valorMaestro);
			hijoMaestro.setEmpresa(contacto.getEmpresa());
			hijoMaestro = maestroDao.consultarHijoMaestro(hijoMaestro);
			contacto.getArea().setNombre(hijoMaestro.getNombre());
		} catch (Exception e) {
			throw new ErrorRegistroDataException(
					"No se pudo agregar el contacto", e);
		}

		return contacto;
	}

	@Override
	public String obtenerDireccionCompleta(Direccion direccion)
			throws SQLException, Exception {
		MaestroDao maestroDao = new MaestroDaoImpl();
		Maestro hijoMaestro = new Maestro();
		int valorMaestro = UtilEjb.obtenerEnteroPropertieMaestro("maestroVias",
				"aplicacionDatosEjb");
		hijoMaestro.setCodigoMaestro(valorMaestro);
		hijoMaestro.setCodigoEntero(direccion.getVia().getCodigoEntero());
		hijoMaestro.setEmpresa(direccion.getEmpresa());
		hijoMaestro = maestroDao.consultarHijoMaestro(hijoMaestro);
		String direccionCompleta = "" + hijoMaestro.getAbreviatura() + " "
				+ direccion.getNombreVia();
		if (StringUtils.isNotBlank(direccion.getNumero())) {
			direccionCompleta = direccionCompleta + " Nro "
					+ direccion.getNumero();
		} else {
			direccionCompleta = direccionCompleta + " Mz. "
					+ direccion.getManzana();
			direccionCompleta = direccionCompleta + " Lt. "
					+ direccion.getLote();
		}
		if (StringUtils.isNotBlank(direccion.getInterior())) {
			direccionCompleta = direccionCompleta + " Int "
					+ direccion.getInterior();
		}

		return UtilJdbc.convertirMayuscula(direccionCompleta);
	}

	@Override
	public ServicioNovios agregarServicio(ServicioNovios detalleServicio)
			throws SQLException, Exception {

		Connection conn = null;

		try {
			conn = UtilConexion.obtenerConexion();

			MaestroServicioDao maestroServicioDao = new MaestroServicioDaoImpl();

			ProveedorDao proveedorDao = new ProveedorDaoImpl();

			detalleServicio.setTipoServicio(maestroServicioDao
					.consultarMaestroServicio(detalleServicio.getTipoServicio()
							.getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero(), conn));

			// obtener nombre empresa proveedor
			if (detalleServicio.getServicioProveedor().getProveedor()
					.getCodigoEntero() != null
					&& detalleServicio.getServicioProveedor().getProveedor()
							.getCodigoEntero().intValue() != 0) {
				detalleServicio.getServicioProveedor().setProveedor(
						proveedorDao.consultarProveedor(detalleServicio
								.getServicioProveedor().getProveedor()
								.getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero(), conn));
			}

			// obtener nombre aerolinea
			if (detalleServicio.getAerolinea().getCodigoEntero() != null
					&& detalleServicio.getAerolinea().getCodigoEntero()
							.intValue() != 0) {
				detalleServicio.getAerolinea().setNombre(
						proveedorDao.consultarProveedor(
								detalleServicio.getAerolinea()
										.getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero(), conn)
								.getNombreCompleto());
			}

			// obtener nombre empresa transporte
			if (detalleServicio.getEmpresaTransporte().getCodigoEntero() != null
					&& detalleServicio.getEmpresaTransporte().getCodigoEntero()
							.intValue() != 0) {
				detalleServicio.getEmpresaTransporte().setNombre(
						proveedorDao.consultarProveedor(
								detalleServicio.getEmpresaTransporte()
										.getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero(), conn)
								.getNombreCompleto());
			}

			// obtener nombre operador
			if (detalleServicio.getOperadora().getCodigoEntero() != null
					&& detalleServicio.getOperadora().getCodigoEntero()
							.intValue() != 0) {
				detalleServicio.getOperadora().setNombre(
						proveedorDao.consultarProveedor(
								detalleServicio.getOperadora()
										.getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero(), conn)
								.getNombreCompleto());
			}

			// obtener nombre hotel
			if (detalleServicio.getHotel().getCodigoEntero() != null
					&& detalleServicio.getHotel().getCodigoEntero().intValue() != 0) {
				detalleServicio.getHotel().setNombre(
						proveedorDao.consultarProveedor(
								detalleServicio.getHotel().getCodigoEntero(), detalleServicio.getEmpresa().getCodigoEntero(), 
								conn).getNombreCompleto());
			}

			BigDecimal comision = BigDecimal.ZERO;
			BigDecimal totalVenta = BigDecimal.ZERO;

			if (StringUtils.isBlank(detalleServicio.getDescripcionServicio())) {
				detalleServicio.setDescripcionServicio(StringUtils
						.upperCase(detalleServicio.getTipoServicio()
								.getNombre()));
			}

			detalleServicio.setDescripcionServicio(StringUtils
					.upperCase(detalleServicio.getDescripcionServicio()));

			if (detalleServicio.getCantidad() == 0) {
				detalleServicio.setCantidad(1);
			}

			if (detalleServicio.getPrecioUnitario() != null) {
				BigDecimal total = detalleServicio.getPrecioUnitario()
						.multiply(
								UtilParse.parseIntABigDecimal(detalleServicio
										.getCantidad()));
				totalVenta = totalVenta.add(total);
			}

			if (detalleServicio.getServicioProveedor().getPorcentajeComision() != null) {
				comision = detalleServicio.getServicioProveedor()
						.getPorcentajeComision().multiply(totalVenta);
				comision = comision.divide(BigDecimal.valueOf(100.0));
			}

			if (detalleServicio.getServicioProveedor().getProveedor()
					.getCodigoEntero() != null) {
				Proveedor proveedor = consultaNegocioSessionLocal
						.consultarProveedor(detalleServicio
								.getServicioProveedor().getProveedor()
								.getCodigoEntero().intValue(), detalleServicio.getEmpresa().getCodigoEntero());
				detalleServicio.getServicioProveedor().setProveedor(proveedor);
			}

			detalleServicio.setMontoComision(comision);

			detalleServicio.setCodigoCadena(String.valueOf(System
					.currentTimeMillis()));

			return detalleServicio;
		} catch (Exception e) {
			throw new ErrorRegistroDataException(
					"No se pudo agregar el servicio al listado", e);
		} finally {
			if (conn != null) {
				conn.close();
			}
		}
	}

	@Override
	public BigDecimal calcularValorCuota(ServicioAgencia servicioAgencia)
			throws SQLException, Exception {
		BigDecimal valorCuota = BigDecimal.ZERO;

		ServicioNegocioDao servicioNegocioDao = new ServicioNegocioDaoImpl();
		valorCuota = servicioNegocioDao.calcularCuota(servicioAgencia);

		return valorCuota;
}

	@Override
	public Pasajero agregarPasajero(Pasajero pasajero)
			throws ErrorRegistroDataException {
		try {
			MaestroDao maestroDao = new MaestroDaoImpl();
			Maestro hijoMaestro = new Maestro();
			int valorMaestro = UtilEjb.obtenerEnteroPropertieMaestro(
					"maestroRelacion", "aplicacionDatosEjb");
			hijoMaestro.setCodigoMaestro(valorMaestro);
			hijoMaestro.setCodigoEntero(pasajero.getRelacion()
					.getCodigoEntero());
			hijoMaestro.setEmpresa(pasajero.getEmpresa());
			hijoMaestro = maestroDao.consultarHijoMaestro(hijoMaestro);

			pasajero.getRelacion().setNombre(StringUtils.upperCase(hijoMaestro.getNombre().toUpperCase()));
			pasajero.setApellidoMaterno(StringUtils.upperCase(pasajero.getApellidoMaterno()));
			pasajero.setApellidoPaterno(StringUtils.upperCase(pasajero.getApellidoPaterno()));
			pasajero.setNombres(StringUtils.upperCase(pasajero.getNombres().toUpperCase()));
			pasajero.setCorreoElectronico(StringUtils.upperCase(pasajero.getCorreoElectronico()));
			pasajero.setCodigoReserva(StringUtils.upperCase(pasajero.getCodigoReserva()));

			return pasajero;
		} catch (SQLException e) {
			throw new ErrorRegistroDataException("No se agrego el pasajero");
		}
	}
	
	@Override
	public List<String> generarDetalleComprobanteImpresionDocumentoCobranza(List<DetalleComprobante> listaDetalle, int idServicio, int idEmpresa) throws ErrorConsultaDataException{
		if (listaDetalle != null){
			try {
				Comprobante comprobante = new Comprobante();
				comprobante.getEmpresa().setCodigoEntero(idEmpresa);
				comprobante.setIdServicio(idServicio);
				ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(idEmpresa);
				List<DetalleComprobante> listaResumen = servicioNovaViajesDao.consultaResumenDocumentoCobranza(comprobante);
				DetalleServicioAgencia detalleServicioAgencia = null;
				List<String> detalle = new ArrayList<String>();
				for (DetalleComprobante detalleComprobante : listaResumen) {
					if (detalleComprobante.getCantidad() > 0){
						for (DetalleComprobante detalle2 : listaDetalle){
							detalleServicioAgencia = new DetalleServicioAgencia();
							detalleServicioAgencia.setCodigoEntero(detalle2.getIdServicioDetalle());
							detalleServicioAgencia.getTipoServicio().setCodigoEntero(detalleComprobante.getCodigoEntero());
							detalleServicioAgencia.getEmpresa().setCodigoEntero(idEmpresa);
							List<DetalleServicioAgencia> lista2 = servicioNovaViajesDao.consultarDescripcionServicio(detalleServicioAgencia, idServicio);
							for (DetalleServicioAgencia detalleServicioAgencia2 : lista2) {
								List<Pasajero> listaPasajeros = servicioNovaViajesDao.consultarPasajerosServicio(detalleServicioAgencia2, idServicio);
								detalle.add("Por la compra de "+listaPasajeros.size()+" "+detalleServicioAgencia2.getDescripcionServicio()+" para los pasajeros:");
								for (Pasajero pasajero : listaPasajeros) {
									detalle.add("-"+pasajero.getNombreCompleto());
								}
							}
						}
					}
				}
				return detalle;
			} catch (SQLException e1) {
				throw new ErrorConsultaDataException(
						"Error en la generacion de detalle de comprobante", e1);
			} catch (Exception e1) {
				throw new ErrorConsultaDataException(
						"Error en la generacion de detalle de comprobante", e1);
			}
			
		}
		return null;
	}
	
	@Override
	public List<String> generarDetalleComprobanteImpresionBoleta(List<DetalleComprobante> listaDetalle, int idServicio, int idEmpresa) throws ErrorConsultaDataException{
		if (listaDetalle != null){
			try {
				ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(idEmpresa);
				List<String> detalle = new ArrayList<String>();
				List<Pasajero> listaPasajeros = servicioNovaViajesDao.consultarPasajerosServicio(idEmpresa, idServicio);
				detalle.add("Por el FEE de emision para los pasajeros:");
				for (Pasajero pasajero : listaPasajeros) {
					detalle.add("-"+pasajero.getNombreCompleto());
				}
				return detalle;
			} catch (SQLException e1) {
				throw new ErrorConsultaDataException(
						"Error en la generacion de detalle de comprobante", e1);
			} catch (Exception e1) {
				throw new ErrorConsultaDataException(
						"Error en la generacion de detalle de comprobante", e1);
			}
			
		}
		return null;
	}
	
	@Override
	public List<Pasajero> consultarPasajerosServicio(int idServicio, int idEmpresa) throws ErrorConsultaDataException{
		try {
			ServicioNovaViajesDao servicioNovaViajesDao = new ServicioNovaViajesDaoImpl(idEmpresa);
			List<Pasajero> listaPasajeros = servicioNovaViajesDao.consultarPasajerosServicio(idEmpresa, idServicio);
			
			return listaPasajeros;
		} catch (SQLException e1) {
			throw new ErrorConsultaDataException(
					"Error en la consulta de pasajeros", e1);
		} catch (Exception e1) {
			throw new ErrorConsultaDataException(
					"Error en la consulta de pasajeros", e1);
		}
			
	}
	
	@Override
	public Connection obtenerConexion(){
		return UtilConexion.obtenerConexion();
	}
}
