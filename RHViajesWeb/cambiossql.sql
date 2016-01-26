-- Function: soporte.fn_listarpaises(integer, integer)

-- DROP FUNCTION soporte.fn_listarpaises(integer, integer);

CREATE OR REPLACE FUNCTION soporte.fn_listarpaises(p_idempresa integer, p_idcontinente integer)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin

open micursor for
SELECT id, descripcion, idcontinente
  FROM soporte.pais
 WHERE idcontinente = coalesce(p_idcontinente,idcontinente)
   AND idempresa    = p_idempresa
 ORDER BY descripcion ASC;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION soporte.fn_listarpaises(integer, integer)
  OWNER TO postgres;

  
  
-- Function: seguridad.fn_actualizarcredencialvencida(integer, integer, character varying, integer, character varying)

-- DROP FUNCTION seguridad.fn_actualizarcredencialvencida(integer, integer, character varying, integer, character varying);

CREATE OR REPLACE FUNCTION seguridad.fn_actualizarcredencialvencida(p_idempresa integer, p_idusuario integer, p_credencialnueva character varying, p_usuariomodificacion integer, p_ipmodificacion character varying)
  RETURNS boolean AS
$BODY$

declare salida boolean;
declare idusuario integer;
declare v_fechaexpiracion1 date;
declare v_fechaexpiracion2 date;

begin

select feccaducacredencial
  into v_fechaexpiracion1
  from seguridad.usuario
 where id        = p_idusuario
   and idempresa = p_idempresa;

if v_fechaexpiracion1 is null then
   select current_date into v_fechaexpiracion1;
end if;

v_fechaexpiracion2 = v_fechaexpiracion1 + 45;

update seguridad.usuario
   set feccaducacredencial   = v_fechaexpiracion2,
       credencial            = p_credencialnueva,
       cambiarclave          = false,
       idusuariomodificacion = p_usuariomodificacion,
       fechamodificacion     = current_timestamp,
       ipmodificacion        = p_ipmodificacion
 where id 	             = p_idusuario
   and idempresa             = p_idempresa;

return salida;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION seguridad.fn_actualizarcredencialvencida(integer, integer, character varying, integer, character varying)
  OWNER TO postgres;

  
-- Function: negocio.fn_ingresarpersona(integer, integer, character varying, character varying, character varying, character varying, integer, integer, character varying, integer, character varying, date, character varying, date, integer)

-- DROP FUNCTION negocio.fn_ingresarpersona(integer, integer, character varying, character varying, character varying, character varying, integer, integer, character varying, integer, character varying, date, character varying, date, integer);

CREATE OR REPLACE FUNCTION negocio.fn_ingresarpersona(p_idempresa integer, p_idtipopersona integer, p_nombres character varying, p_apepaterno character varying, p_apematerno character varying, p_idgenero character varying, p_idestadocivil integer, p_idtipodocumento integer, p_numerodocumento character varying, p_usuariocreacion integer, p_ipcreacion character varying, p_fecnacimiento date, p_nropasaporte character varying, p_fecvctopasaporte date, p_idnacionalidad integer)
  RETURNS integer AS
$BODY$

declare maxpersona integer;
declare fechahoy timestamp with time zone;
declare v_cantidad integer;

begin

select count(1)
  into v_cantidad
  from negocio."Persona" 
 where idestadoregistro = 1
   and idempresa        = p_idempresa
   and idtipopersona    = p_idtipopersona
   and idtipodocumento  = p_idtipodocumento 
   and numerodocumento  = p_numerodocumento;

if v_cantidad >=1 then
   raise USING MESSAGE = 'El tipo de documento y numero ya se encuentran registrados para otra persona';
end if;

maxpersona = nextval('negocio.seq_persona');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

insert into negocio."Persona"(id, idtipopersona, nombres, apellidopaterno, apellidomaterno, 
            idgenero, idestadocivil, idtipodocumento, numerodocumento, idusuariocreacion, 
            fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, 
            ipmodificacion,fecnacimiento, nropasaporte, fecvctopasaporte, idnacionalidad, idempresa)
values (maxpersona,p_idtipopersona,p_nombres,p_apepaterno,p_apematerno,p_idgenero,p_idestadocivil,p_idtipodocumento,p_numerodocumento,p_usuariocreacion,fechahoy,
	p_ipcreacion,p_usuariocreacion,fechahoy,p_ipcreacion,p_fecnacimiento, p_nropasaporte, p_fecvctopasaporte,p_idnacionalidad, p_idempresa);

return maxpersona;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

  
-- Function: negocio.fn_consultarservicioventa(integer, integer, character varying, character varying, integer)

-- DROP FUNCTION negocio.fn_consultarservicioventa(integer, integer, character varying, character varying, integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultarservicioventa(p_idempresa integer, p_tipodocumento integer, p_numerodocumento character varying, p_nombres character varying, p_idvendedor integer)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin

open micursor for
select sercab.id, sercab.idcliente1, cli1.nombres as nombres1, cli1.apellidopaterno as apellidopaterno1, cli1.apellidomaterno as apellidomaterno1, 
       sercab.idcliente2, cli2.nombres as nombres2, cli2.apellidopaterno as apellidopaterno2, cli2.apellidomaterno as apellidomaterno2, 
       sercab.fechacompra, sercab.montototal, 
       sercab.idformapago, maemp.nombre as nommediopago, maemp.descripcion as descmediopago,
       sercab.idestadopago, maeep.nombre as nomestpago, maeep.descripcion as descestpago, sercab.idestadoservicio, maest.nombre as nomestservicio,
       sercab.nrocuotas, sercab.tea, sercab.valorcuota, sercab.fechaprimercuota, sercab.fechaultcuota,
       sercab.idusuariocreacion, sercab.fechacreacion, sercab.ipcreacion, 
       sercab.idusuariomodificacion, sercab.fechamodificacion, sercab.ipmodificacion,
       (select count(1) from negocio."ProgramaNovios" where idservicio = sercab.id) as cantidadNovios
  from negocio."ServicioCabecera" sercab 
 inner join negocio.vw_clientesnova cli1 on sercab.idcliente1 = cli1.id
 inner join soporte."Tablamaestra" maemp on maemp.estado = 'A' and maemp.idempresa = p_idempresa and maemp.idmaestro = fn_maestroformapago()      and maemp.id = sercab.idformapago
 inner join soporte."Tablamaestra" maeep on maeep.estado = 'A' and maeep.idempresa = p_idempresa and maeep.idmaestro = fn_maestroestadopago()     and maeep.id = sercab.idestadopago
 inner join soporte."Tablamaestra" maest on maest.estado = 'A' and maest.idempresa = p_idempresa and maest.idmaestro = fn_maestroestadoservicio() and maest.id = sercab.idestadoservicio
  left join negocio.vw_clientesnova cli2 on sercab.idcliente2 = cli2.id and cli2.idempresa = p_idempresa
 where sercab.idestadoregistro = 1
   and (select count(1) from negocio."ServicioDetalle" det where det.idservicio = sercab.id and det.idempresa = p_idempresa) > 0
   and sercab.idempresa        = p_idempresa
   and cli1.idtipodocumento    = COALESCE(p_tipodocumento,cli1.idtipodocumento)
   and cli1.numerodocumento    = COALESCE(p_numerodocumento,cli1.numerodocumento)
   and UPPER(CONCAT(replace(cli1.nombres,' ',''),trim(cli1.apellidopaterno),trim(cli1.apellidomaterno))) like UPPER('%'||COALESCE(p_nombres,CONCAT(trim(replace(cli1.nombres,' ','')),trim(cli1.apellidopaterno),trim(cli1.apellidomaterno)))||'%')
   and sercab.idvendedor       = COALESCE(p_idvendedor,sercab.idvendedor);
	
return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

  
-- Function: negocio.fn_consultarservicioventa(integer, integer, character varying, character varying, integer, integer, date, date)

-- DROP FUNCTION negocio.fn_consultarservicioventa(integer, integer, character varying, character varying, integer, integer, date, date);

CREATE OR REPLACE FUNCTION negocio.fn_consultarservicioventa(p_idempresa integer, p_tipodocumento integer, p_numerodocumento character varying, p_nombres character varying, p_idvendedor integer, p_idservicio integer, p_fechadesde date, p_fechahasta date)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin

if p_idservicio is not null then
open micursor for
select sercab.id, sercab.idcliente1, cli1.nombres as nombres1, cli1.apellidopaterno as apellidopaterno1, cli1.apellidomaterno as apellidomaterno1, 
       sercab.idcliente2, cli2.nombres as nombres2, cli2.apellidopaterno as apellidopaterno2, cli2.apellidomaterno as apellidomaterno2, 
       sercab.fechacompra, sercab.montototal, 
       sercab.idestadopago, maeep.nombre as nomestpago, maeep.descripcion as descestpago, sercab.idestadoservicio, maest.nombre as nomestservicio,
       sercab.nrocuotas, sercab.tea, sercab.valorcuota, sercab.fechaprimercuota, sercab.fechaultcuota,
       sercab.idusuariocreacion, sercab.fechacreacion, sercab.ipcreacion, 
       sercab.idusuariomodificacion, sercab.fechamodificacion, sercab.ipmodificacion,
       (select count(1) from negocio."ProgramaNovios" pn where pn.idservicio = sercab.id and pn.idempresa = p_idempresa) as cantidadNovios, sercab.idvendedor
  from negocio."ServicioCabecera" sercab 
 inner join negocio.vw_clientesnova cli1 on sercab.idcliente1 = cli1.id and sercab.idempresa = p_idempresa
 inner join soporte."Tablamaestra" maeep on maeep.estado      = 'A'     and maeep.idempresa  = p_idempresa and maeep.idmaestro  = fn_maestroestadopago()     and maeep.id = sercab.idestadopago
 inner join soporte."Tablamaestra" maest on maest.estado      = 'A'     and maest.idempresa  = p_idempresa and maest.idmaestro  = fn_maestroestadoservicio() and maest.id = sercab.idestadoservicio
  left join negocio.vw_clientesnova cli2 on sercab.idcliente2 = cli2.id and cli2.idempresa   = p_idempresa
 where sercab.idestadoregistro = 1
   and sercab.idempresa        = p_idempresa
   and (select count(1) from negocio."ServicioDetalle" det where det.idservicio = sercab.id and det.idempresa = p_idempresa) > 0
   and sercab.id               = COALESCE(p_idservicio,sercab.id);
else
open micursor for
select sercab.id, sercab.idcliente1, cli1.nombres as nombres1, cli1.apellidopaterno as apellidopaterno1, cli1.apellidomaterno as apellidomaterno1, 
       sercab.idcliente2, cli2.nombres as nombres2, cli2.apellidopaterno as apellidopaterno2, cli2.apellidomaterno as apellidomaterno2, 
       sercab.fechacompra, sercab.montototal, sercab.idestadopago, maeep.nombre as nomestpago, maeep.descripcion as descestpago, sercab.idestadoservicio, maest.nombre as nomestservicio,
       sercab.nrocuotas, sercab.tea, sercab.valorcuota, sercab.fechaprimercuota, sercab.fechaultcuota,
       sercab.idusuariocreacion, sercab.fechacreacion, sercab.ipcreacion, 
       sercab.idusuariomodificacion, sercab.fechamodificacion, sercab.ipmodificacion,
       (select count(1) from negocio."ProgramaNovios" pn where pn.idservicio = sercab.id and pn.idempresa = p_idempresa) as cantidadNovios, sercab.idvendedor
  from negocio."ServicioCabecera" sercab 
 inner join negocio.vw_clientesnova cli1 on sercab.idcliente1 = cli1.id
 inner join soporte."Tablamaestra" maeep on maeep.estado = 'A' and maeep.idempresa = p_idempresa and maeep.idmaestro = fn_maestroestadopago()     and maeep.id = sercab.idestadopago
 inner join soporte."Tablamaestra" maest on maest.estado = 'A' and maest.idempresa = p_idempresa and maest.idmaestro = fn_maestroestadoservicio() and maest.id = sercab.idestadoservicio
  left join negocio.vw_clientesnova cli2 on sercab.idcliente2 = cli2.id and cli2.idempresa = p_idempresa
 where sercab.idestadoregistro = 1
   and sercab.idempresa        = p_idempresa
   and sercab.fechacompra between p_fechadesde and p_fechahasta
   and (select count(1) from negocio."ServicioDetalle" det where det.idservicio = sercab.id) > 0
   and cli1.idtipodocumento    = COALESCE(p_tipodocumento,cli1.idtipodocumento)
   and cli1.numerodocumento    = COALESCE(p_numerodocumento,cli1.numerodocumento)
   and UPPER(CONCAT(replace(cli1.nombres,' ',''),trim(cli1.apellidopaterno),trim(cli1.apellidomaterno))) like UPPER('%'||COALESCE(p_nombres,CONCAT(trim(replace(cli1.nombres,' ','')),trim(cli1.apellidopaterno),trim(cli1.apellidomaterno)))||'%')
   and sercab.idvendedor       = COALESCE(p_idvendedor,sercab.idvendedor)
   and sercab.id               = COALESCE(p_idservicio,sercab.id);
end if;
	
return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- Function: soporte.fn_listardestinos(integer)

-- DROP FUNCTION soporte.fn_listardestinos(integer);

CREATE OR REPLACE FUNCTION soporte.fn_listardestinos(p_idempresa integer)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin

open micursor for
SELECT des.id, des.idcontinente, cont.nombre as nombrecontinente, des.idpais, pai.descripcion as nombrepais, codigoiata, idtipodestino, tipdes.nombre as nombretipdestino, des.descripcion, 
       des.idusuariocreacion, des.fechacreacion, des.ipcreacion, des.idusuariomodificacion, 
       des.fechamodificacion, des.ipmodificacion, des.idestadoregistro, pai.abreviado
  FROM soporte.destino des,
       soporte."Tablamaestra" cont,
       soporte."Tablamaestra" tipdes,
       soporte.pais pai       
 WHERE des.idestadoregistro = 1
   AND cont.idmaestro       = fn_maestrocontinente()
   AND cont.estado          = 'A'
   AND cont.id              = des.idcontinente
   AND cont.idempresa       = des.idempresa
   AND pai.idestadoregistro = 1
   AND pai.id               = des.idpais
   AND pai.idempresa        = des.idempresa
   AND tipdes.idmaestro     = fn_maestrotipodestino()
   AND tipdes.estado        = 'A'
   AND tipdes.id            = des.idtipodestino
   AND tipdes.idempresa     = des.idempresa
   AND des.idempresa        = p_idempresa
 ORDER BY des.descripcion ASC;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION soporte.fn_listardestinos(integer)
  OWNER TO postgres;
