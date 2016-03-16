

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
  
  
----------------------------------------------------------------------------------------------------------------
  
  -- Table: negocio."Persona"

drop table negocio."PersonaAdjuntos";
CREATE TABLE negocio."PersonaAdjuntos"
(
  id integer NOT NULL,
  idpersona integer not null,
  idtipopersona integer NOT NULL,
  idtipodocumento integer NOT NULL,
  descripciondocumento character varying(150),
  archivo bytea NOT NULL,
  nombrearchivo character varying(50) NOT NULL,
  tipocontenido character varying(50) NOT NULL,
  extensionarchivo character varying(10) NOT NULL,
  idusuariocreacion integer NOT NULL,
  fechacreacion timestamp with time zone NOT NULL,
  ipcreacion character(15) NOT NULL,
  idusuariomodificacion integer NOT NULL,
  fechamodificacion timestamp with time zone NOT NULL,
  ipmodificacion character(15) NOT NULL,
  idestadoregistro integer NOT NULL DEFAULT 1,
  idempresa integer NOT NULL,
  CONSTRAINT pk_personaadjuntos PRIMARY KEY (id)
);


CREATE SEQUENCE negocio.seq_personaadjuntos
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;



CREATE OR REPLACE FUNCTION negocio.fn_ingresaradjuntopersona(p_idempresa integer, p_idpersona integer, p_idtipopersona integer, p_idtipodocumento integer, 
p_descripciondocumento character varying, p_archivo bytea, p_nombrearchivo character varying, p_extensionarchivo character varying, p_tipocontenido character varying, 
p_usuariocreacion integer, p_ipcreacion character varying)
  RETURNS boolean AS
$BODY$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_personaadjuntos');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."PersonaAdjuntos"(
            id, idpersona, idtipopersona, idtipodocumento, descripciondocumento, 
            archivo, nombrearchivo, tipocontenido, extensionarchivo, idusuariocreacion, 
            fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, 
            ipmodificacion, idestadoregistro, idempresa)
    VALUES (maxid, p_idpersona, p_idtipopersona, p_idtipodocumento, p_descripciondocumento, 
            p_archivo, p_nombrearchivo, p_tipocontenido, p_extensionarchivo, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, 
            p_idempresa);

return true;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;



CREATE OR REPLACE FUNCTION negocio.fn_actualizaradjuntopersona(p_idempresa integer, p_idadjunto integer, 
p_idpersona integer, p_idtipopersona integer, p_idtipodocumento integer, 
p_descripciondocumento character varying, p_archivo bytea, p_nombrearchivo character varying, 
p_extensionarchivo character varying, p_tipocontenido character varying, 
p_usuariocreacion integer, p_ipcreacion character varying)
  RETURNS boolean AS
$BODY$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."PersonaAdjuntos"
   SET idtipodocumento       = p_idtipodocumento, 
       descripciondocumento  = p_descripciondocumento, 
       archivo               = p_archivo, 
       nombrearchivo         = p_nombrearchivo, 
       tipocontenido         = p_tipocontenido, 
       extensionarchivo      = p_extensionarchivo, 
       idusuariomodificacion = p_usuariocreacion, 
       fechamodificacion     = fechahoy, 
       ipmodificacion        = p_ipcreacion,
       idestadoregistro      = 1
 WHERE id                    = p_idadjunto
   AND idempresa             = p_idempresa
   AND idpersona             = p_idpersona
   AND idtipopersona         = p_idtipopersona, ;

return true;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


CREATE OR REPLACE FUNCTION negocio.fn_eliminaradjuntopersona1(p_idempresa integer, p_usuariocreacion integer, p_ipcreacion character varying)
  RETURNS boolean AS
$BODY$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."PersonaAdjuntos"
   SET idestadoregistro      = 0,
       idusuariomodificacion = p_usuariocreacion, 
       fechamodificacion     = fechahoy, 
       ipmodificacion        = p_ipcreacion
 WHERE idempresa             = p_idempresa
   AND idpersona             = p_idpersona
   AND idtipopersona         = p_idtipopersona;

return true;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


CREATE OR REPLACE FUNCTION negocio.fn_eliminaradjuntopersona2(p_idempresa integer, p_idpersona integer, p_idtipopersona integer)
  RETURNS boolean AS
$BODY$

begin

DELETE 
  FROM negocio."PersonaAdjuntos"
 WHERE idestadoregistro = 0
   AND idempresa        =  p_idempresa
   AND id               IN (SELECT id 
                              FROM negocio."PersonaAdjuntos" 
                             WHERE idempresa             = p_idempresa
			       AND idpersona             = p_idpersona
			       AND idtipopersona         = p_idtipopersona);

return true;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
  

CREATE OR REPLACE FUNCTION negocio.fn_listaradjuntospersona(p_idempresa integer, p_idpersona integer, p_idtipopersona integer)
  RETURNS refcursor AS
$BODY$

declare micursor refcursor;

begin

open micursor for
SELECT id, idpersona, idtipopersona, idtipodocumento, descripciondocumento, 
       archivo, nombrearchivo, tipocontenido, extensionarchivo, idusuariocreacion, 
       fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, 
       ipmodificacion, idestadoregistro, idempresa
  FROM negocio."PersonaAdjuntos"
 WHERE idempresa     = p_idempresa
   AND idpersona     = p_idpersona
   AND idtipopersona = p_idtipopersona;


end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
  
CREATE OR REPLACE FUNCTION negocio.fn_eliminaradjuntopersona1(p_idempresa integer, p_idpersona integer, p_idtipopersona integer, p_usuariocreacion integer, p_ipcreacion character varying)
  RETURNS boolean AS
$BODY$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."PersonaAdjuntos"
   SET idestadoregistro      = 0,
       idusuariomodificacion = p_usuariocreacion, 
       fechamodificacion     = fechahoy, 
       ipmodificacion        = p_ipcreacion
 WHERE idempresa             = p_idempresa
   AND idpersona             = p_idpersona
   AND idtipopersona         = p_idtipopersona;

return true;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
  
-- Function: negocio.fn_listaradjuntospersona(integer, integer, integer)

-- DROP FUNCTION negocio.fn_listaradjuntospersona(integer, integer, integer);

CREATE OR REPLACE FUNCTION negocio.fn_listaradjuntospersona(p_idempresa integer, p_idpersona integer, p_idtipopersona integer)
  RETURNS refcursor AS
$BODY$

declare micursor refcursor;

begin

open micursor for
SELECT id, idpersona, idtipopersona, idtipodocumento, descripciondocumento, 
       archivo, nombrearchivo, tipocontenido, extensionarchivo, idusuariocreacion, 
       fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, 
       ipmodificacion, idestadoregistro, idempresa
  FROM negocio."PersonaAdjuntos"
 WHERE idempresa     = p_idempresa
   AND idpersona     = p_idpersona
   AND idtipopersona = p_idtipopersona;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
  
-- Function: negocio.fn_comboproveedorestipo(integer, integer)

-- DROP FUNCTION negocio.fn_comboproveedorestipo(integer, integer);

CREATE OR REPLACE FUNCTION negocio.fn_comboproveedorestipo(p_idempresa integer, p_idtipo integer)
  RETURNS refcursor AS
$BODY$

declare micursor refcursor;

begin

open micursor for
SELECT per.id, per.nombres, pper.nombrecomercial, per.apellidopaterno, per.apellidomaterno
  FROM negocio."Persona" per,
       negocio."ProveedorPersona" pper
 WHERE per.id                = pper.idproveedor
   AND per.idestadoregistro  = 1
   AND pper.idestadoregistro = 1
   AND pper.idtipoproveedor  = p_idtipo
   AND pper.idempresa        = per.idempresa
   AND per.idempresa         = p_idempresa;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
