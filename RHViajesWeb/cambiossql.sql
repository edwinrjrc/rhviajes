-- Function: negocio.fn_listarpagosobligaciones(integer, integer)

-- DROP FUNCTION negocio.fn_listarpagosobligaciones(integer, integer);

CREATE OR REPLACE FUNCTION negocio.fn_listarpagosobligaciones(p_idempresa integer, p_idobligacion integer)
  RETURNS refcursor AS
$BODY$

declare micursor refcursor;

begin

open micursor for
SELECT idpago, idobligacion, fechapago, montopagado, sustentopago, nombrearchivo, extensionarchivo, tipocontenido, espagodetraccion, espagoretencion
  FROM negocio."PagosObligacion"
 WHERE idestadoregistro = 1
   AND idobligacion     = p_idobligacion
   AND idempresa        = p_idempresa
 ORDER BY idpago DESC;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
  
-- Function: negocio.fn_ingresarobligacionxpagar(integer, integer, character varying, integer, date, date, character varying, numeric, numeric, boolean, boolean, integer, character varying)

-- DROP FUNCTION negocio.fn_ingresarobligacionxpagar(integer, integer, character varying, integer, date, date, character varying, numeric, numeric, boolean, boolean, integer, character varying);

CREATE OR REPLACE FUNCTION negocio.fn_ingresarobligacionxpagar(p_idempresa integer, p_idtipocomprobante integer, p_numerocomprobante character varying, p_idproveedor integer, 
p_fechacomprobante date, p_fechapago date, p_detallecomprobante character varying, p_totaligv numeric, p_totalcomprobante numeric, 
p_tienedetraccion boolean, p_tieneretencion boolean, p_usuariocreacion integer, p_ipcreacion character varying, p_idmoneda integer)
  RETURNS boolean AS
$BODY$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_obligacionxpagar');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ObligacionesXPagar"(
            id, idtipocomprobante, numerocomprobante, idproveedor, fechacomprobante, 
            fechapago, detallecomprobante, totaligv, totalcomprobante, saldocomprobante, tienedetraccion, tieneretencion, idusuariocreacion, 
            fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, 
            ipmodificacion, idempresa, idmoneda)
    VALUES (maxid, p_idtipocomprobante, p_numerocomprobante, p_idproveedor, p_fechacomprobante, 
            p_fechapago, p_detallecomprobante, p_totaligv, p_totalcomprobante, p_totalcomprobante, p_tienedetraccion, p_tieneretencion, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa, p_idmoneda);

return true;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;