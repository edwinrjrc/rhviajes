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
