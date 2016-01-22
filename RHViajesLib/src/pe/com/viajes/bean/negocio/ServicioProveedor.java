/**
 * 
 */
package pe.com.viajes.bean.negocio;

import java.math.BigDecimal;

import pe.com.viajes.bean.base.BaseNegocio;
import pe.com.viajes.bean.base.BaseVO;

/**
 * @author Edwin
 *
 */
public class ServicioProveedor extends BaseNegocio {

	private BaseVO tipoServicio;
	private boolean editoComision;
	private BigDecimal porcentajeComision;
	private BigDecimal porcenComInternacional;
	private String nombreProveedor;
	private Proveedor proveedor;
	private Proveedor proveedorServicio;
	private ComisionServicio comision;

	
	private static final long serialVersionUID = -7190639530649610005L;

	
	public ServicioProveedor() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @return the tipoServicio
	 */
	public BaseVO getTipoServicio() {
		if (tipoServicio == null) {
			tipoServicio = new BaseVO();
		}
		return tipoServicio;
	}

	/**
	 * @param tipoServicio
	 *            the tipoServicio to set
	 */
	public void setTipoServicio(BaseVO tipoServicio) {
		this.tipoServicio = tipoServicio;
	}

	/**
	 * @return the porcentajeComision
	 */
	public BigDecimal getPorcentajeComision() {
		return porcentajeComision;
	}

	/**
	 * @param porcentajeComision
	 *            the porcentajeComision to set
	 */
	public void setPorcentajeComision(BigDecimal porcentajeComision) {
		this.porcentajeComision = porcentajeComision;
	}

	/**
	 * @return the nombreProveedor
	 */
	public String getNombreProveedor() {
		return nombreProveedor;
	}

	/**
	 * @param nombreProveedor
	 *            the nombreProveedor to set
	 */
	public void setNombreProveedor(String nombreProveedor) {
		this.nombreProveedor = nombreProveedor;
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
	 * @return the proveedorServicio
	 */
	public Proveedor getProveedorServicio() {
		if (proveedorServicio == null) {
			proveedorServicio = new Proveedor();
		}
		return proveedorServicio;
	}

	/**
	 * @param proveedorServicio
	 *            the proveedorServicio to set
	 */
	public void setProveedorServicio(Proveedor proveedorServicio) {
		this.proveedorServicio = proveedorServicio;
	}

	/**
	 * @return the porcenComInternacional
	 */
	public BigDecimal getPorcenComInternacional() {
		return porcenComInternacional;
	}

	/**
	 * @param porcenComInternacional
	 *            the porcenComInternacional to set
	 */
	public void setPorcenComInternacional(BigDecimal porcenComInternacional) {
		this.porcenComInternacional = porcenComInternacional;
	}

	/**
	 * @return the editoComision
	 */
	public boolean isEditoComision() {
		return editoComision;
	}

	/**
	 * @param editoComision
	 *            the editoComision to set
	 */
	public void setEditoComision(boolean editoComision) {
		this.editoComision = editoComision;
	}

	/**
	 * @return the comision
	 */
	public ComisionServicio getComision() {
		if (comision == null){
			comision = new ComisionServicio();
		}
		return comision;
	}

	/**
	 * @param comision the comision to set
	 */
	public void setComision(ComisionServicio comision) {
		this.comision = comision;
	}

}
