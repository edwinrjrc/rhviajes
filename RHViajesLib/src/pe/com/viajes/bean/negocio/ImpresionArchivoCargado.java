/**
 * 
 */
package pe.com.viajes.bean.negocio;

import pe.com.viajes.bean.base.BaseNegocio;

/**
 * @author EDWREB
 *
 */
public class ImpresionArchivoCargado extends BaseNegocio {
	
	private String nombresCliente;
	private String paternoCliente;
	private String numeroBoleto;

	private static final long serialVersionUID = -1630968614370952271L;

	public ImpresionArchivoCargado() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @return the nombresCliente
	 */
	public String getNombresCliente() {
		return nombresCliente;
	}

	/**
	 * @param nombresCliente the nombresCliente to set
	 */
	public void setNombresCliente(String nombresCliente) {
		this.nombresCliente = nombresCliente;
	}

	/**
	 * @return the paternoCliente
	 */
	public String getPaternoCliente() {
		return paternoCliente;
	}

	/**
	 * @param paternoCliente the paternoCliente to set
	 */
	public void setPaternoCliente(String paternoCliente) {
		this.paternoCliente = paternoCliente;
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

}
