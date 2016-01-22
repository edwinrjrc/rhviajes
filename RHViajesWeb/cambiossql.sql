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
