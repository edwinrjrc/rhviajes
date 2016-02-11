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

  


CREATE OR REPLACE FUNCTION licencia.fn_ingresarcontrato(p_fechainicio date, p_fechafin date, p_precioxusuario decimal, p_nrousuarios integer, p_idempresa integer, p_idestado integer)
  RETURNS integer AS
$BODY$

declare maxid integer;

begin

maxid = nextval('licencia.seq_contrato');

INSERT INTO licencia."Contrato"(
            id, fechainicio, fechafin, precioxusuario, nrousuarios, idempresa, idestado)
    VALUES (maxid, p_fechainicio, p_fechafin, p_precioxusuario, p_nrousuarios, p_idempresa, p_idestado);

return maxid;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
