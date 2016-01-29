-- Function: negocio.fn_listarmaestroservicios(integer)

-- DROP FUNCTION negocio.fn_listarmaestroservicios(integer);

CREATE OR REPLACE FUNCTION negocio.fn_listarmaestroservicios(p_idempresa integer)
  RETURNS refcursor AS
$BODY$

declare micursor refcursor;

begin

open micursor for
SELECT id, nombre, desccorta, desclarga, requierefee, pagaimpto, cargacomision, esserviciopadre
  FROM negocio."MaestroServicios"
 WHERE visible          = true
   AND idestadoregistro = 1
   AND idempresa        = p_idempresa
 ORDER BY nombre;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
  
-- Function: negocio.fn_listarmaestroserviciosadm(integer)

-- DROP FUNCTION negocio.fn_listarmaestroserviciosadm(integer);

CREATE OR REPLACE FUNCTION negocio.fn_listarmaestroserviciosadm(p_idempresa integer)
  RETURNS refcursor AS
$BODY$

declare micursor refcursor;

begin

open micursor for
SELECT id, nombre, desccorta, desclarga, requierefee, pagaimpto, cargacomision, esserviciopadre
  FROM negocio."MaestroServicios"
 WHERE idestadoregistro = 1
   AND idempresa        = p_idempresa
 ORDER BY nombre;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_listarmaestroserviciosadm(integer)
  OWNER TO postgres;

  
-- Function: negocio.fn_listarmaestroserviciosadm(integer)

-- DROP FUNCTION negocio.fn_listarmaestroserviciosadm(integer);

CREATE OR REPLACE FUNCTION negocio.fn_listarmaestroserviciosadm(p_idempresa integer)
  RETURNS refcursor AS
$BODY$

declare micursor refcursor;

begin

open micursor for
SELECT id, nombre, desccorta, desclarga, requierefee, pagaimpto, cargacomision, esserviciopadre
  FROM negocio."MaestroServicios"
 WHERE idestadoregistro = 1
   AND idempresa        = p_idempresa
 ORDER BY nombre;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_listarmaestroserviciosadm(integer)
  OWNER TO postgres;


-- Function: negocio.fn_consultarcronogramapago(integer, integer)

-- DROP FUNCTION negocio.fn_consultarcronogramapago(integer, integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultarcronogramapago(p_idempresa integer, p_idservicio integer)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin

open micursor for
SELECT nrocuota, idservicio, fechavencimiento, capital, interes, totalcuota, 
       idestadocuota, idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, 
       fechamodificacion, ipmodificacion, idestadoregistro
  FROM negocio."CronogramaPago"
 where idservicio = p_idservicio
   and idempresa  = p_idempresa;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

  
-- Function: negocio.fn_consultarservicioventa(integer, integer)

-- DROP FUNCTION negocio.fn_consultarservicioventa(integer, integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultarservicioventa(p_idempresa integer, p_idservicio integer)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin

open micursor for
select sercab.id, sercab.idcliente1, cli1.nombres as nombres1, cli1.apellidopaterno as apellidopaterno1, cli1.apellidomaterno as apellidomaterno1, 
       sercab.idcliente2, cli2.nombres as nombres2, cli2.apellidopaterno as apellidopaterno2, cli2.apellidomaterno as apellidomaterno2, 
       sercab.fechacompra, sercab.montototal, sercab.montocomisiontotal, sercab.montototaligv, sercab.montototalfee,
       sercab.idestadopago, maeep.nombre as nomestpago, maeep.descripcion as descestpago,
       sercab.nrocuotas, sercab.tea, sercab.valorcuota, sercab.fechaprimercuota, sercab.fechaultcuota, sercab.montocomisiontotal,
       sercab.idestadoservicio, 
       (select count(1) from negocio."PagosServicio" ps where ps.idservicio = sercab.id and ps.idempresa = p_idempresa) tienepagos,
       usu.id as idusuario,
       usu.nombres as nombresvendedor, usu.apepaterno, usu.apematerno,
       sercab.idusuariocreacion, sercab.fechacreacion, sercab.ipcreacion, 
       sercab.idusuariomodificacion, sercab.fechamodificacion, sercab.ipmodificacion, sercab.generocomprobantes, sercab.guardorelacioncomprobantes, sercab.observaciones
  from negocio."ServicioCabecera" sercab 
 inner join negocio.vw_clientesnova cli1 on sercab.idcliente1 = cli1.id and cli1.idempresa  = p_idempresa
 inner join soporte."Tablamaestra" maeep on maeep.estado      = 'A'     and maeep.idempresa = p_idempresa and maeep.idmaestro = fn_maestroestadopago() and maeep.id = sercab.idestadopago
 inner join seguridad.usuario usu        on usu.id            = sercab.idvendedor and usu.idempresa = p_idempresa
  left join negocio.vw_clientesnova cli2 on sercab.idcliente2 = cli2.id and cli2.idempresa = p_idempresa
 where sercab.idestadoregistro = 1
   and (select count(1) from negocio."ServicioDetalle" det where det.idservicio = sercab.id and det.idempresa = p_idempresa) > 0
   and sercab.id               = p_idservicio
   and sercab.idempresa        = p_idempresa;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- Function: negocio.fn_consultarservicioventadetallepadre(integer)

-- DROP FUNCTION negocio.fn_consultarservicioventadetallepadre(integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultarservicioventadetallepadre(p_idempresa integer, p_idservicio integer)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin
open micursor for
SELECT serdet.id as idSerdetalle, serdet.idtiposervicio, 
       tipser.id, tipser.nombre as nomtipservicio, tipser.desccorta as descservicio, tipser.requierefee, 
       tipser.pagaimpto, tipser.cargacomision, tipser.esimpuesto, tipser.esfee,
       serdet.descripcionservicio, serdet.fechaida, serdet.fecharegreso, serdet.cantidad, sercab.idmoneda, tmmo.nombre as nombremoneda, tmmo.abreviatura as simbolomoneda,
       serdet.preciobase, serdet.montototalcomision, serdet.montototal, serdet.idempresaproveedor, pro.nombres, pro.apellidopaterno, 
       pro.apellidomaterno, tipser.visible
  FROM negocio."ServicioDetalle" serdet
 INNER JOIN negocio."ServicioCabecera" sercab ON sercab.idempresa = serdet.idempresa AND sercab.id = p_idservicio
 INNER JOIN soporte."Tablamaestra" tmmo       ON tmmo.idempresa   = serdet.idempresa AND tmmo.idmaestro = fn_maestrotipomoneda() AND tmmo.id = sercab.idmoneda
 INNER JOIN negocio."MaestroServicios" tipser ON tipser.idempresa = serdet.idempresa AND tipser.idestadoregistro = 1 AND tipser.id = serdet.idtiposervicio AND tipser.esserviciopadre = true
  LEFT JOIN negocio.vw_proveedoresnova pro    ON pro.idempresa    = serdet.idempresa AND pro.id = serdet.idempresaproveedor
 WHERE serdet.idestadoregistro = 1
   AND serdet.idempresa        = p_idempresa
   AND serdet.idservicio       = p_idservicio
   AND serdet.idservdetdepende is null;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- Function: negocio.fn_consultarpasajeros(integer, integer)

-- DROP FUNCTION negocio.fn_consultarpasajeros(integer, integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultarpasajeros(p_idempresa integer, p_idserviciodetalle integer)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin

open micursor for
SELECT ps.id, idtipodocumento, tmdi.nombre as nombretipodocumento, 
       numerodocumento, nombres, apellidopaterno, apellidomaterno, correoelectronico, 
       telefono1, telefono2, nropaxfrecuente, idaerolinea,
       negocio.fn_consultarnombrepersona(p_idempresa,idaerolinea) as nombreaerolina, codigoreserva, numeroboleto, fechavctopasaporte, fechanacimiento,
       idrelacion, tmre.nombre as nombrerelacion,
       idserviciodetalle, idservicio
  FROM negocio."PasajeroServicio" ps
 INNER JOIN soporte."Tablamaestra" tmre ON tmre.idmaestro = fn_maestrotiporelacion()  AND tmre.id = ps.idrelacion      AND tmre.idempresa = p_idempresa
 INNER JOIN soporte."Tablamaestra" tmdi ON tmdi.idmaestro = fn_maestrotipodocumento() AND tmdi.id = ps.idtipodocumento AND tmdi.idempresa = p_idempresa
 WHERE idserviciodetalle = p_idserviciodetalle
   AND ps.idempresa      = p_idempresa;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

  
-- Function: negocio.fn_listardocumentosadicionales(integer, integer)

-- DROP FUNCTION negocio.fn_listardocumentosadicionales(integer, integer);

CREATE OR REPLACE FUNCTION negocio.fn_listardocumentosadicionales(p_idempresa integer, p_idservicio integer)
  RETURNS refcursor AS
$BODY$

declare micursor refcursor;

begin

open micursor for
SELECT das.id, idservicio, idtipodocumento, tm.nombre as nombredocumento, descripciondocumento, archivo, nombrearchivo, tipocontenido, 
       extensionarchivo, das.idusuariocreacion, das.fechacreacion, das.ipcreacion, 
       das.idusuariomodificacion, das.fechamodificacion, das.ipmodificacion, das.idestadoregistro
  FROM negocio."DocumentoAdjuntoServicio" das,
       soporte."Tablamaestra" tm
 where das.idservicio      = p_idservicio
   and das.idempresa       = p_idempresa
   and das.idtipodocumento = tm.id
   and das.idempresa       = tm.idempresa
   and tm.idmaestro        = fn_maestrodocumentoadjunto();

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

  
-- Function: negocio.fn_consultarservicioventajr(integer, integer)

-- DROP FUNCTION negocio.fn_consultarservicioventajr(integer, integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultarservicioventajr(p_idempresa integer, p_idservicio integer)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin

open micursor for
select cantidad, descripcionservicio, fechaida, 
       fecharegreso, idmoneda, abreviatura, preciobase, montototal, 
       idservicio 
  from negocio.vw_servicio_detalle 
 where idservicio = p_idservicio
   and idempresa  = p_idempresa;


return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- Function: negocio.fn_consultarservicioventajr(integer, integer)

-- DROP FUNCTION negocio.fn_consultarservicioventajr(integer, integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultarservicioventajr(p_idempresa integer, p_idservicio integer)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin

open micursor for
select cantidad, descripcionservicio, fechaida, 
       fecharegreso, idmoneda, abreviatura, preciobase, montototal, 
       idservicio 
  from negocio.vw_servicio_detalle 
 where idservicio = p_idservicio
   and idempresa  = p_idempresa;


return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- Function: negocio.fn_listarpagos(integer, integer)

-- DROP FUNCTION negocio.fn_listarpagos(integer, integer);

CREATE OR REPLACE FUNCTION negocio.fn_listarpagos(p_idempresa integer, p_idservicio integer)
  RETURNS refcursor AS
$BODY$

declare micursor refcursor;

begin

open micursor for
SELECT idpago, idservicio, ps.idformapago, tmfp.nombre as nombreformapago, fechapago, montopagado, sustentopago, nombrearchivo, extensionarchivo, tipocontenido, espagodetraccion, 
       espagoretencion, ps.idusuariocreacion, ps.fechacreacion, ps.ipcreacion, ps.idusuariomodificacion, ps.fechamodificacion, ps.ipmodificacion
  FROM negocio."PagosServicio" ps
 INNER JOIN soporte."Tablamaestra" tmfp ON tmfp.idempresa = p_idempresa AND ps.idformapago = tmfp.id AND tmfp.idmaestro = fn_maestroformapago()
 WHERE ps.idestadoregistro = 1
   AND ps.idempresa        = p_idempresa
   AND ps.idservicio       = p_idservicio
 ORDER BY idpago DESC;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- Function: negocio.fn_registrarpagoservicio(integer, integer, integer, integer, integer, integer, character varying, character varying, date, character varying, numeric, integer, bytea, character varying, character varying, character varying, character varying, boolean, boolean, integer, character varying)

-- DROP FUNCTION negocio.fn_registrarpagoservicio(integer, integer, integer, integer, integer, integer, character varying, character varying, date, character varying, numeric, integer, bytea, character varying, character varying, character varying, character varying, boolean, boolean, integer, character varying);

CREATE OR REPLACE FUNCTION negocio.fn_registrarpagoservicio(p_idempresa integer, p_idservicio integer, p_idformapago integer, p_idcuentadestino integer, p_idbancotarjeta integer, p_idtipotarjeta integer, p_nombretitular character varying, p_numerotarjeta character varying, p_fechapago date, p_numerooperacion character varying, p_montopago numeric, p_idmoneda integer, p_sustentopago bytea, p_nombrearchivo character varying, p_extensionarchivo character varying, p_tipocontenido character varying, p_comentario character varying, p_espagodetraccion boolean, p_espagoretencion boolean, p_usuariocreacion integer, p_ipcreacion character varying)
  RETURNS integer AS
$BODY$

declare maxid integer;
declare maxidss integer;
declare fechahoy timestamp with time zone;
declare montosaldo decimal(12,3);
declare montosaldofinal decimal(12,3);
declare fechaservicio date;
declare montoservicio decimal(12,3);
declare estadoPago integer;
declare v_tipotransaccion integer;
declare v_desctransaccion character varying;
declare v_registramovimiento boolean;
declare v_monedaservicio integer;
declare v_tipocambio decimal(12,3);
declare v_montoaplicar decimal(12,3);
declare v_registrotranstc integer;

begin

v_monedaservicio = 2;

select idestadopago
  into estadoPago
  from negocio."ServicioCabecera"
 where id        = p_idservicio
   and idempresa = p_idempresa;

if estadoPago = 2 then
    raise USING MESSAGE = 'El servicio se encuentra pagado ya no acepta mas pagos';
end if;

select min(montosaldoservicio)
  into montosaldo
  from negocio."SaldosServicio" ss
 where ss.idservicio = p_idservicio
   and ss.idempresa  = p_idempresa;

if p_idmoneda <> v_monedaservicio then
    select negocio.fn_consultartipocambiomonto(p_idempresa,p_idmoneda,v_monedaservicio) into v_tipocambio;
    v_montoaplicar = p_montopago * v_tipocambio;
else
    v_montoaplicar = p_montopago;
end if;

if v_montoaplicar > montosaldo then
   raise USING MESSAGE = 'El monto a pagar es mayor que el saldo pendiente';
end if;

maxid = nextval('negocio.seq_pago');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

select fechacompra, montototal
  into fechaservicio, montoservicio
  from negocio."ServicioCabecera"
 where id        = p_idservicio
   and idempresa = p_idempresa;

if montosaldo is null then
    montosaldo = montoservicio;
end if;

INSERT INTO negocio."PagosServicio"(
            idpago, idservicio, idformapago, idcuentadestino, idbancotarjeta, idtipotarjeta, 
            nombretitular, numerotarjeta, fechapago, numerooperacion, montopagado, idmoneda, sustentopago, 
            tipocontenido, nombrearchivo, extensionarchivo, comentario, espagodetraccion, 
            espagoretencion, idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, ipmodificacion, idempresa)
    VALUES (maxid, p_idservicio, p_idformapago, p_idcuentadestino, p_idbancotarjeta, p_idtipotarjeta, 
            p_nombretitular, p_numerotarjeta, p_fechapago, p_numerooperacion, p_montopago, p_idmoneda, p_sustentopago, 
            p_tipocontenido, p_nombrearchivo, p_extensionarchivo, p_comentario, p_espagodetraccion, 
            p_espagoretencion, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

if p_idmoneda <> v_monedaservicio then
    select negocio.fn_registrartransacciontipocambio(p_idempresa,p_idmoneda,p_montopago,v_tipocambio,v_monedaservicio,v_montoaplicar,p_usuariocreacion,p_ipcreacion) into v_registrotranstc;
end if;

montosaldofinal = montosaldo - v_montoaplicar;

maxidss = nextval('negocio.seq_salsoservicio');
INSERT INTO negocio."SaldosServicio"(
            idsaldoservicio, idservicio, idpago, fechaservicio, montototalservicio, 
            montosaldoservicio, idtransaccionreferencia, idusuariocreacion, fechacreacion, ipcreacion, 
            idusuariomodificacion, fechamodificacion, ipmodificacion, idempresa)
    VALUES (maxidss, p_idservicio, maxid, fechaservicio, montoservicio, 
            montosaldofinal, v_registrotranstc, p_usuariocreacion, fechahoy, p_ipcreacion, 
            p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

if montosaldofinal = 0 then
   update negocio."ServicioCabecera"
      set idestadopago = 2
    where id           = p_idservicio
      and idempresa    = p_idempresa;
end if;

if p_idformapago = 2 then -- deposito en cuenta
    v_tipotransaccion = 1;
    v_desctransaccion = 'Deposito en cuenta';

    -- 1: ingreso
    -- 2: egreso
    select negocio.fn_registrarmovimientocuenta(p_idempresa, p_idcuentadestino, 1, v_tipotransaccion, v_desctransaccion, p_montopago, null, null, p_usuariocreacion, p_ipcreacion) into v_registramovimiento;
elsif p_idformapago = 3 then -- transferencia
    v_tipotransaccion = 2;
    v_desctransaccion = 'Transferencia de fondos a cuenta';

    -- 1: ingreso
    -- 2: egreso
    select negocio.fn_registrarmovimientocuenta(p_idempresa, p_idcuentadestino, 1, v_tipotransaccion, v_desctransaccion, p_montopago, null, null, p_usuariocreacion, p_ipcreacion) into v_registramovimiento;
end if;

return maxid;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

  
-- Function: negocio.fn_listarpagos(integer, integer)

-- DROP FUNCTION negocio.fn_listarpagos(integer, integer);

CREATE OR REPLACE FUNCTION negocio.fn_listarpagos(p_idempresa integer, p_idservicio integer)
  RETURNS refcursor AS
$BODY$

declare micursor refcursor;

begin

open micursor for
SELECT idpago, idservicio, ps.idformapago, tmfp.nombre as nombreformapago, fechapago, 
       ps.idmoneda, tmmo.nombre as nombremoneda, tmmo.abreviatura, montopagado, sustentopago, nombrearchivo, extensionarchivo, tipocontenido, espagodetraccion, 
       espagoretencion, ps.idusuariocreacion, ps.fechacreacion, ps.ipcreacion, ps.idusuariomodificacion, ps.fechamodificacion, ps.ipmodificacion
  FROM negocio."PagosServicio" ps
 INNER JOIN soporte."Tablamaestra" tmfp ON tmfp.idempresa = p_idempresa AND ps.idformapago = tmfp.id                AND tmfp.idmaestro = fn_maestroformapago()
 INNER JOIN soporte."Tablamaestra" tmmo ON tmmo.idempresa = p_idempresa AND tmmo.idmaestro = fn_maestrotipomoneda() AND tmmo.id        = ps.idmoneda
 WHERE ps.idestadoregistro = 1
   AND ps.idempresa        = p_idempresa
   AND ps.idservicio       = p_idservicio
 ORDER BY idpago DESC;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
