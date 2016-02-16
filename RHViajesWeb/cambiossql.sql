-- Function: licencia.fn_listarmaestro(integer)

-- DROP FUNCTION licencia.fn_listarmaestro(integer);

CREATE OR REPLACE FUNCTION licencia.fn_listarempresas()
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin

open micursor for
SELECT emp.id, emp.razonsocial, emp.nombrecomercial, emp.nombredominio, emp.idtipodocumento, tmtd.nombre, tmtd.descripcion, tmtd.abreviatura,
       emp.numerodocumento, emp.nombrecontacto
  FROM licencia."Empresa" emp
 INNER JOIN licencia."Tablamaestra" tmtd ON tmtd.idmaestro = fn_maestrotipodocumentolicencia() AND tmtd.id = idtipodocumento;


return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;



  
CREATE OR REPLACE FUNCTION fn_maestrotipodocumentolicencia()
  RETURNS integer AS
$BODY$

begin

return 1;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
-- Function: licencia.fn_ingresarempresa(character varying, character varying, character varying, integer, character varying, character varying)

-- DROP FUNCTION licencia.fn_ingresarempresa(character varying, character varying, character varying, integer, character varying, character varying);

CREATE OR REPLACE FUNCTION licencia.fn_ingresarempresa(p_razonsocial character varying, p_nombrecomercial character varying, p_nombredominio character varying, p_idtipodocumento integer, 
p_numerodocumento character varying, p_nombrecontacto character varying, p_correocontacto character varying)
  RETURNS integer AS
$BODY$

declare maxid integer;

begin

maxid = nextval('licencia.seq_empresa');

INSERT INTO licencia."Empresa"(
            id, razonsocial, nombrecomercial, nombredominio, idtipodocumento, 
            numerodocumento, nombrecontacto, correocontacto)
    VALUES (maxid, p_razonsocial, p_nombrecomercial, p_nombredominio, p_idtipodocumento, 
            p_numerodocumento, p_nombrecontacto, p_correocontacto);

return maxid;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
  
-- Function: licencia.fn_listarempresas()

-- DROP FUNCTION licencia.fn_listarempresas();

CREATE OR REPLACE FUNCTION licencia.fn_listarempresas()
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin

open micursor for
SELECT emp.id, emp.razonsocial, emp.nombrecomercial, emp.nombredominio, emp.idtipodocumento, tmtd.nombre, tmtd.descripcion, tmtd.abreviatura,
       emp.numerodocumento, emp.nombrecontacto, emp.correocontacto
  FROM licencia."Empresa" emp
 INNER JOIN licencia."Tablamaestra" tmtd ON tmtd.idmaestro = fn_maestrotipodocumentolicencia() AND tmtd.id = idtipodocumento;


return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

  
-- Function: negocio.fn_consultarpersona(integer, integer, integer)

-- DROP FUNCTION negocio.fn_consultarpersona(integer, integer, integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultarpersona(p_idempresa integer, p_id integer, p_idtipopersona integer)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin

open micursor for
SELECT pro.id, pro.nombres, pro.apellidopaterno, pro.apellidomaterno, 
    pro.idgenero, pro.idestadocivil, pro.idtipodocumento, pro.numerodocumento, 
    pro.idusuariocreacion, pro.fechacreacion, pro.ipcreacion, ppro.idrubro, pro.fecnacimiento,
    pro.nropasaporte, pro.fecvctopasaporte, pro.idnacionalidad
   FROM negocio."Persona" pro
   left join negocio."PersonaAdicional" ppro on ppro.idpersona = pro.id AND ppro.idestadoregistro = 1
  WHERE pro.idestadoregistro = 1 
    AND pro.idempresa        = p_idempresa
    AND pro.idtipopersona    = p_idtipopersona
    AND pro.id = p_id;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;