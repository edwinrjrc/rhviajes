

CREATE OR REPLACE FUNCTION licencia.fn_listarcontratos()
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin

open micursor for
SELECT c.id, c.fechainicio, c.fechafin, c.precioxusuario, c.nrousuarios, c.serial, 
       c.idempresa, e.nombrecomercial, c.idestado, tmco.nombre as estadocontrato
  FROM licencia."Contrato" c,
       licencia."Empresa" e,
       licencia."Tablamaestra" tmco
 WHERE c.idempresa    = e.id
   AND tmco.idmaestro = licencia.fn_maestroestadocontratolicencia()
   AND c.idestado     = tmco.id;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
  

CREATE OR REPLACE FUNCTION licencia.fn_ingresarcontrato(p_fechainicio date, p_fechafin date, p_precioxusuario decimal, p_nrousuarios integer, p_serial character varying, 
p_idempresa integer, p_idestado integer)
  RETURNS integer AS
$BODY$

declare maxid integer;

begin

maxid = nextval('licencia.seq_contrato');

INSERT INTO licencia."Contrato"(
            id, fechainicio, fechafin, precioxusuario, nrousuarios, serial, 
            idempresa, idestado)
    VALUES (maxid, p_fechainicio, p_fechafin, p_precioxusuario, p_nrousuarios, p_serial, 
            p_idempresa, p_idestado);


return maxid;


end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;