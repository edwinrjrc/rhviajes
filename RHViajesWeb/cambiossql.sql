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
