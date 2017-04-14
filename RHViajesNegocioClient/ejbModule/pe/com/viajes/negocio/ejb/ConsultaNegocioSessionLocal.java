package pe.com.viajes.negocio.ejb;

import java.sql.SQLException;
import java.util.List;

import javax.ejb.Local;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.DetalleServicioAgencia;
import pe.com.viajes.bean.negocio.MaestroServicio;
import pe.com.viajes.bean.negocio.Proveedor;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;

@Local
public interface ConsultaNegocioSessionLocal {

	public Proveedor consultarProveedor(int codigoProveedor, Integer idEmpresa)
			throws SQLException, Exception;
	
	DetalleServicioAgencia consultaDetalleServicioDetalle(int idServicio,
			int idDetServicio, Integer idEmpresa) throws SQLException;

	List<MaestroServicio> listarMaestroServicioPadre(Integer idEmpresa)
			throws SQLException, Exception;
	
	List<BaseVO> obtenerListaTarjetasPago() throws ErrorConsultaDataException;
}
