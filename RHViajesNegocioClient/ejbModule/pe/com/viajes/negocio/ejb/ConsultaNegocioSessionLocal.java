package pe.com.viajes.negocio.ejb;

import java.sql.SQLException;

import javax.ejb.Local;

import pe.com.viajes.bean.negocio.Proveedor;

@Local
public interface ConsultaNegocioSessionLocal {

	public Proveedor consultarProveedor(int codigoProveedor, Integer idEmpresa)
			throws SQLException, Exception;
}
