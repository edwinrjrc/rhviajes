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