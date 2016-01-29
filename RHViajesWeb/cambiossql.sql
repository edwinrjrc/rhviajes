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

