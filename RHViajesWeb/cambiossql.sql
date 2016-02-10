-- Function: seguridad.fn_puedeagregarusuario(integer)

-- DROP FUNCTION seguridad.fn_puedeagregarusuario(integer);

CREATE OR REPLACE FUNCTION seguridad.fn_puedeagregarusuario(p_idempresa integer)
  RETURNS boolean AS
$BODY$

declare v_cantidadusuarios integer;
declare v_cantidadusuarioslicencia integer;

begin

select count(1)
  into v_cantidadusuarios 
  from seguridad.usuario u
 where u.idempresa = p_idempresa;

select nrousuarios
  into v_cantidadusuarioslicencia
  from licencia."Contrato"
 where idempresa = p_idempresa;
 
return (v_cantidadusuarios < v_cantidadusuarioslicencia);

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION seguridad.fn_puedeagregarusuario(integer)
  OWNER TO postgres;
