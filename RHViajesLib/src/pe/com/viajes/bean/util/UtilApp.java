/**
 * 
 */
package pe.com.viajes.bean.util;

import java.util.List;

import pe.com.viajes.bean.base.BaseVO;

/**
 * @author Edwin
 *
 */
public abstract class UtilApp {

	public static boolean validarPermisoRoles(List<BaseVO> listaRoles, Integer codigoRol){
		if (listaRoles != null){
			for (BaseVO baseVO : listaRoles) {
				if (baseVO.getCodigoEntero().equals(codigoRol)){
					return true;
				}
			}
		}
		return false;
	}

}
