--
-- PostgreSQL database dump
--

-- Dumped from database version 9.2.8
-- Dumped by pg_dump version 9.2.8
-- Started on 2016-02-11 19:16:22

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 6 (class 2615 OID 75890)
-- Name: auditoria; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA auditoria;


ALTER SCHEMA auditoria OWNER TO postgres;

--
-- TOC entry 7 (class 2615 OID 75891)
-- Name: licencia; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA licencia;


ALTER SCHEMA licencia OWNER TO postgres;

--
-- TOC entry 8 (class 2615 OID 75892)
-- Name: negocio; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA negocio;


ALTER SCHEMA negocio OWNER TO postgres;

--
-- TOC entry 9 (class 2615 OID 75893)
-- Name: reportes; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA reportes;


ALTER SCHEMA reportes OWNER TO postgres;

--
-- TOC entry 10 (class 2615 OID 75894)
-- Name: seguridad; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA seguridad;


ALTER SCHEMA seguridad OWNER TO postgres;

--
-- TOC entry 11 (class 2615 OID 75895)
-- Name: soporte; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA soporte;


ALTER SCHEMA soporte OWNER TO postgres;

--
-- TOC entry 281 (class 3079 OID 11727)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2849 (class 0 OID 0)
-- Dependencies: 281
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 282 (class 3079 OID 75896)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 2850 (class 0 OID 0)
-- Dependencies: 282
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET search_path = auditoria, pg_catalog;

--
-- TOC entry 328 (class 1255 OID 75930)
-- Name: fn_consultaasistencia(integer, date); Type: FUNCTION; Schema: auditoria; Owner: postgres
--

CREATE FUNCTION fn_consultaasistencia(p_idempresa integer, p_fecha date) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
select u.usuario, u.nombres, u.apepaterno, u.apematerno, 
       (select max(e.fecharegistro) 
          from auditoria.eventosesionsistema e
         where e.idusuario = u.id
           and date(e.fecharegistro) = p_fecha) as horaInicio
  from seguridad.usuario u
 where u.id_rol <> 1
   and u.idempresa = p_idempresa;

return micursor;

end;$$;


ALTER FUNCTION auditoria.fn_consultaasistencia(p_idempresa integer, p_fecha date) OWNER TO postgres;

--
-- TOC entry 329 (class 1255 OID 75931)
-- Name: fn_registrareventosesionsistema(integer, integer, character varying, integer, integer, character varying); Type: FUNCTION; Schema: auditoria; Owner: postgres
--

CREATE FUNCTION fn_registrareventosesionsistema(p_idempresa integer, p_idusuario integer, p_usuario character varying, p_idtipoevento integer, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare 
fechahoy timestamp with time zone;
maxid integer;

BEGIN

maxid = nextval('auditoria.seq_eventosesionsistema');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;
	
INSERT INTO auditoria.eventosesionsistema(
            id, idusuario, usuario, fecharegistro, idtipoevento, idempresa, idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, ipmodificacion)
    VALUES (maxid, p_idusuario, p_usuario, fechahoy,p_idtipoevento, p_idempresa, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return true;

END;
$$;


ALTER FUNCTION auditoria.fn_registrareventosesionsistema(p_idempresa integer, p_idusuario integer, p_usuario character varying, p_idtipoevento integer, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

SET search_path = licencia, pg_catalog;

--
-- TOC entry 533 (class 1255 OID 76811)
-- Name: fn_actualizarcontrato(integer, date, date, numeric, integer); Type: FUNCTION; Schema: licencia; Owner: postgres
--

CREATE FUNCTION fn_actualizarcontrato(p_id integer, p_fechainicio date, p_fechafin date, p_precioxusuario numeric, p_nrousuarios integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$

begin

UPDATE licencia."Contrato"
   SET fechainicio    = p_fechainicio, 
       fechafin       = p_fechafin, 
       precioxusuario = p_precioxusuario, 
       nrousuarios    = p_nrousuarios
 WHERE id             = p_id;

return maxid;

end;
$$;


ALTER FUNCTION licencia.fn_actualizarcontrato(p_id integer, p_fechainicio date, p_fechafin date, p_precioxusuario numeric, p_nrousuarios integer) OWNER TO postgres;

--
-- TOC entry 330 (class 1255 OID 75932)
-- Name: fn_consultaempresa(character varying); Type: FUNCTION; Schema: licencia; Owner: postgres
--

CREATE FUNCTION fn_consultaempresa(p_nombredominio character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT id, razonsocial, nombrecomercial, nombredominio
  FROM licencia."Empresa"
 WHERE nombredominio = p_nombredominio;


return micursor;

end;
$$;


ALTER FUNCTION licencia.fn_consultaempresa(p_nombredominio character varying) OWNER TO postgres;

--
-- TOC entry 524 (class 1255 OID 76810)
-- Name: fn_ingresarcontrato(date, date, numeric, integer, integer, integer); Type: FUNCTION; Schema: licencia; Owner: postgres
--

CREATE FUNCTION fn_ingresarcontrato(p_fechainicio date, p_fechafin date, p_precioxusuario numeric, p_nrousuarios integer, p_idempresa integer, p_idestado integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;

begin

maxid = nextval('licencia.seq_contrato');

INSERT INTO licencia."Contrato"(
            id, fechainicio, fechafin, precioxusuario, nrousuarios, idempresa, idestado)
    VALUES (maxid, p_fechainicio, p_fechafin, p_precioxusuario, p_nrousuarios, p_idempresa, p_idestado);

return maxid;

end;
$$;


ALTER FUNCTION licencia.fn_ingresarcontrato(p_fechainicio date, p_fechafin date, p_precioxusuario numeric, p_nrousuarios integer, p_idempresa integer, p_idestado integer) OWNER TO postgres;

--
-- TOC entry 535 (class 1255 OID 83198)
-- Name: fn_ingresarempresa(character varying, character varying, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: licencia; Owner: postgres
--

CREATE FUNCTION fn_ingresarempresa(p_razonsocial character varying, p_nombrecomercial character varying, p_nombredominio character varying, p_idtipodocumento integer, p_numerodocumento character varying, p_nombrecontacto character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;

begin

maxid = nextval('licencia.seq_empresa');

INSERT INTO licencia."Empresa"(
            id, razonsocial, nombrecomercial, nombredominio, idtipodocumento, 
            numerodocumento, nombrecontacto)
    VALUES (maxid, p_razonsocial, p_nombrecomercial, p_nombredominio, p_idtipodocumento, 
            p_numerodocumento, p_nombrecontacto);

return maxid;

end;
$$;


ALTER FUNCTION licencia.fn_ingresarempresa(p_razonsocial character varying, p_nombrecomercial character varying, p_nombredominio character varying, p_idtipodocumento integer, p_numerodocumento character varying, p_nombrecontacto character varying) OWNER TO postgres;

--
-- TOC entry 534 (class 1255 OID 76813)
-- Name: fn_listarmaestro(integer); Type: FUNCTION; Schema: licencia; Owner: postgres
--

CREATE FUNCTION fn_listarmaestro(p_idmaestro integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT id, idmaestro, nombre, descripcion, orden, estado, abreviatura, 
       idestadoregistro
  FROM licencia."Tablamaestra"
 WHERE idmaestro = p_idmaestro;

return micursor;

end;
$$;


ALTER FUNCTION licencia.fn_listarmaestro(p_idmaestro integer) OWNER TO postgres;

SET search_path = negocio, pg_catalog;

--
-- TOC entry 331 (class 1255 OID 75933)
-- Name: fn_actualizarcomprobanteservicio(integer, integer, boolean, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarcomprobanteservicio(p_idempresa integer, p_idservicio integer, p_generocomprobantes boolean, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;
Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."ServicioCabecera"
   SET generocomprobantes    = p_generocomprobantes, 
       idusuariomodificacion = p_usuariomodificacion, 
       fechamodificacion     = fechahoy, 
       ipmodificacion        = p_ipmodificacion
 WHERE id                    = p_idservicio
   and idempresa             = p_idempresa;

 return true;

end;
$$;


ALTER FUNCTION negocio.fn_actualizarcomprobanteservicio(p_idempresa integer, p_idservicio integer, p_generocomprobantes boolean, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 332 (class 1255 OID 75934)
-- Name: fn_actualizarcontactoproveedor(integer, integer, integer, integer, character varying, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarcontactoproveedor(p_idempresa integer, p_idproveedor integer, p_idcontacto integer, p_idarea integer, p_anexo character varying, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

BEGIN

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE 
  negocio."PersonaContactoProveedor" 
SET 
  idarea                = p_idarea,
  anexo                 = p_anexo,
  idusuariomodificacion = p_usuariomodificacion,
  fechamodificacion     = fechahoy,
  ipmodificacion        = p_ipmodificacion
WHERE idestadoregistro  = 1
  AND idempresa         = p_idempresa
  AND idproveedor       = p_idproveedor
  AND idcontacto        = p_idcontacto;

return true;
END;
$$;


ALTER FUNCTION negocio.fn_actualizarcontactoproveedor(p_idempresa integer, p_idproveedor integer, p_idcontacto integer, p_idarea integer, p_anexo character varying, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 333 (class 1255 OID 75935)
-- Name: fn_actualizarcorreoelectronico(integer, integer, character varying, boolean, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarcorreoelectronico(p_idempresa integer, p_id integer, p_correo character varying, p_recibirpromociones boolean, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."CorreoElectronico"
   SET correo                = p_correo, 
       recibirpromociones    = p_recibirpromociones,
       idusuariomodificacion = p_usuariomodificacion, 
       fechamodificacion     = fechahoy, 
       ipmodificacion        = p_ipmodificacion
 WHERE idestadoregistro      = 1
   AND idempresa             = p_idempresa
   AND id                    = p_id;


end;
$$;


ALTER FUNCTION negocio.fn_actualizarcorreoelectronico(p_idempresa integer, p_id integer, p_correo character varying, p_recibirpromociones boolean, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 334 (class 1255 OID 75936)
-- Name: fn_actualizarcuentabancaria(integer, integer, character varying, character varying, integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarcuentabancaria(p_idempresa integer, p_idcuenta integer, p_nombrecuenta character varying, p_numerocuenta character varying, p_idtipocuenta integer, p_idbanco integer, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_cuentabancaria');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;


UPDATE negocio."CuentaBancaria"
   SET nombrecuenta          = p_nombrecuenta, 
       numerocuenta          = p_numerocuenta,
       idtipocuenta          = p_idtipocuenta,
       idbanco               = p_idbanco, 
       idusuariomodificacion = p_usuariomodificacion, 
       fechamodificacion     = fechahoy, 
       ipmodificacion        = p_ipmodificacion
 WHERE id                    = p_idcuenta
   AND idempresa             = p_idempresa;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_actualizarcuentabancaria(p_idempresa integer, p_idcuenta integer, p_nombrecuenta character varying, p_numerocuenta character varying, p_idtipocuenta integer, p_idbanco integer, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 335 (class 1255 OID 75937)
-- Name: fn_actualizarcuentabancariasaldo(integer, integer, numeric, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarcuentabancariasaldo(p_idempresa integer, p_idcuenta integer, p_saldocuenta numeric, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_cuentabancaria');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;


UPDATE negocio."CuentaBancaria"
   SET saldocuenta           = p_saldocuenta, 
       idusuariomodificacion = p_usuariomodificacion, 
       fechamodificacion     = fechahoy, 
       ipmodificacion        = p_ipmodificacion
 WHERE id                    = p_idcuenta
   AND idempresa             = p_idempresa;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_actualizarcuentabancariasaldo(p_idempresa integer, p_idcuenta integer, p_saldocuenta numeric, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 338 (class 1255 OID 75938)
-- Name: fn_actualizardireccion(integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character, integer, character varying, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizardireccion(p_idempresa integer, p_id integer, p_idvia integer, p_nombrevia character varying, p_numero character varying, p_interior character varying, p_manzana character varying, p_lote character varying, p_principal character varying, p_idubigeo character, p_usuariomodificacion integer, p_ipmodificacion character varying, p_observacion character varying, p_referencia character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare 

fechahoy    timestamp with time zone;
iddireccion integer = 0;
cantidad    integer    = 0;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

select count(1)
  into cantidad
  from negocio."Direccion"
 where id               = p_id
   and idestadoregistro = 1
   And idempresa        = p_idempresa;

if cantidad = 1 then
iddireccion           = p_id;
UPDATE 
  negocio."Direccion" 
SET 
  idvia                 = p_idvia,
  nombrevia             = p_nombrevia,
  numero                = p_numero,
  interior              = p_interior,
  manzana               = p_manzana,
  lote                  = p_lote,
  principal             = p_principal,
  idubigeo              = p_idubigeo,
  observacion           = p_observacion,
  referencia            = p_referencia,
  idusuariomodificacion = p_usuariomodificacion,
  fechamodificacion     = fechahoy,
  ipmodificacion        = p_ipmodificacion
WHERE idestadoregistro  = 1
  AND id                = iddireccion
  AND idempresa         = p_idempresa;

elsif cantidad = 0 then
select 
negocio.fn_ingresardireccion(p_idvia, p_nombrevia, p_numero, p_interior, p_manzana, p_lote, p_principal, p_idubigeo, p_usuariomodificacion, p_ipmodificacion, 
p_observacion, p_referencia)
into iddireccion;

end if;

return iddireccion;

end;
$$;


ALTER FUNCTION negocio.fn_actualizardireccion(p_idempresa integer, p_id integer, p_idvia integer, p_nombrevia character varying, p_numero character varying, p_interior character varying, p_manzana character varying, p_lote character varying, p_principal character varying, p_idubigeo character, p_usuariomodificacion integer, p_ipmodificacion character varying, p_observacion character varying, p_referencia character varying) OWNER TO postgres;

--
-- TOC entry 339 (class 1255 OID 75939)
-- Name: fn_actualizardireccion(integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character, integer, character varying, character varying, character varying, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizardireccion(p_idempresa integer, p_id integer, p_idvia integer, p_nombrevia character varying, p_numero character varying, p_interior character varying, p_manzana character varying, p_lote character varying, p_principal character varying, p_idubigeo character, p_usuariomodificacion integer, p_ipmodificacion character varying, p_observacion character varying, p_referencia character varying, p_idpais integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare 

fechahoy    timestamp with time zone;
iddireccion integer = 0;
cantidad    integer    = 0;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

select count(1)
  into cantidad
  from negocio."Direccion"
 where id               = p_id
   and idestadoregistro = 1
   And idempresa        = p_idempresa;

if cantidad = 1 then
iddireccion           = p_id;
UPDATE 
  negocio."Direccion" 
SET 
  idvia                 = p_idvia,
  nombrevia             = p_nombrevia,
  numero                = p_numero,
  interior              = p_interior,
  manzana               = p_manzana,
  lote                  = p_lote,
  principal             = p_principal,
  idubigeo              = p_idubigeo,
  observacion           = p_observacion,
  referencia            = p_referencia,
  idusuariomodificacion = p_usuariomodificacion,
  fechamodificacion     = fechahoy,
  ipmodificacion        = p_ipmodificacion,
  idpais                = p_idpais
WHERE idestadoregistro  = 1
  AND id                = iddireccion
  AND idempresa         = p_idempresa;

elsif cantidad = 0 then
select 
negocio.fn_ingresardireccion(p_idempresa, p_idvia, p_nombrevia, p_numero, p_interior, p_manzana, p_lote, p_principal, p_idubigeo, p_usuariomodificacion, p_ipmodificacion, 
p_observacion, p_referencia, p_idpais)
into iddireccion;

end if;

return iddireccion;

end;
$$;


ALTER FUNCTION negocio.fn_actualizardireccion(p_idempresa integer, p_id integer, p_idvia integer, p_nombrevia character varying, p_numero character varying, p_interior character varying, p_manzana character varying, p_lote character varying, p_principal character varying, p_idubigeo character, p_usuariomodificacion integer, p_ipmodificacion character varying, p_observacion character varying, p_referencia character varying, p_idpais integer) OWNER TO postgres;

--
-- TOC entry 340 (class 1255 OID 75940)
-- Name: fn_actualizarestadoservicio(integer, integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarestadoservicio(p_idempresa integer, p_idservicio integer, p_idestadoservicio integer, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;
Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."ServicioCabecera"
   SET idestadoservicio      = p_idestadoservicio, 
       idusuariomodificacion = p_usuariomodificacion, 
       fechamodificacion     = fechahoy, 
       ipmodificacion        = p_ipmodificacion
 WHERE id                    = p_idservicio
   AND idempresa             = p_idempresa;

 return true;

end;
$$;


ALTER FUNCTION negocio.fn_actualizarestadoservicio(p_idempresa integer, p_idservicio integer, p_idestadoservicio integer, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 341 (class 1255 OID 75941)
-- Name: fn_actualizarpersona(integer, integer, integer, character varying, character varying, character varying, character varying, integer, integer, character varying, integer, character varying, date, character varying, date, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarpersona(p_idempresa integer, p_id integer, p_idtipopersona integer, p_nombres character varying, p_apepaterno character varying, p_apematerno character varying, p_idgenero character varying, p_idestadocivil integer, p_idtipodocumento integer, p_numerodocumento character varying, p_usuariomodificacion integer, p_ipmodificacion character varying, p_fecnacimiento date, p_nropasaporte character varying, p_fecvctopasaporte date, p_idnacionalidad integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare 

fechahoy timestamp with time zone;
cantidad integer;
idpersona integer;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

select count(1)
  into cantidad
  from negocio."Persona"
 where id               = p_id
   AND idtipopersona    = p_idtipopersona
   AND idempresa        = p_idempresa;

if cantidad = 1 then
idpersona                    = p_id;
UPDATE negocio."Persona"
   SET nombres               = p_nombres, 
       apellidopaterno       = p_apepaterno, 
       apellidomaterno       = p_apematerno, 
       idgenero              = p_idgenero, 
       idestadocivil         = p_idestadocivil, 
       idtipodocumento       = p_idtipodocumento, 
       numerodocumento       = p_numerodocumento, 
       idusuariomodificacion = p_usuariomodificacion, 
       fechamodificacion     = fechahoy, 
       ipmodificacion        = p_ipmodificacion,
       fecnacimiento         = p_fecnacimiento,
       idestadoregistro      = 1,
       nropasaporte          = p_nropasaporte,
       fecvctopasaporte      = p_fecvctopasaporte,
       idnacionalidad        = p_idnacionalidad
 WHERE id                    = idpersona
   AND idtipopersona         = p_idtipopersona
   AND idempresa             = p_idempresa;

elsif cantidad = 0 then

select negocio.fn_ingresarpersona(p_idtipopersona, p_nombres, p_apepaterno, p_apematerno, p_idgenero, p_idestadocivil, p_idtipodocumento, 
p_numerodocumento, p_usuariomodificacion, p_ipmodificacion, p_nropasaporte, p_fecvctopasaporte) into idpersona;

end if;

return idpersona;

 end;
$$;


ALTER FUNCTION negocio.fn_actualizarpersona(p_idempresa integer, p_id integer, p_idtipopersona integer, p_nombres character varying, p_apepaterno character varying, p_apematerno character varying, p_idgenero character varying, p_idestadocivil integer, p_idtipodocumento integer, p_numerodocumento character varying, p_usuariomodificacion integer, p_ipmodificacion character varying, p_fecnacimiento date, p_nropasaporte character varying, p_fecvctopasaporte date, p_idnacionalidad integer) OWNER TO postgres;

--
-- TOC entry 342 (class 1255 OID 75942)
-- Name: fn_actualizarpersonaproveedor(integer, integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarpersonaproveedor(p_idempresa integer, p_idpersona integer, p_idrubro integer, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

BEGIN

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE 
  negocio."PersonaAdicional" 
SET 
  idrubro               = p_idrubro,
  idusuariomodificacion = p_usuariomodificacion,
  fechamodificacion     = fechahoy,
  ipmodificacion        = p_ipmodificacion
WHERE idestadoregistro  = 1
  AND idpersona         = p_idpersona
  AND idempresa         = p_idempresa;
  
  return true;

  
END;
$$;


ALTER FUNCTION negocio.fn_actualizarpersonaproveedor(p_idempresa integer, p_idpersona integer, p_idrubro integer, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 343 (class 1255 OID 75943)
-- Name: fn_actualizarprogramanovios(integer, integer, date, date, integer, numeric, integer, integer, date, text, numeric, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarprogramanovios(p_idnovios integer, p_iddestino integer, p_fechaboda date, p_fechaviaje date, p_idmoneda integer, p_cuotainicial numeric, p_dias integer, p_noches integer, p_fechashower date, p_observaciones text, p_montototal numeric, p_idservicio integer, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

Begin

maxid = nextval('negocio.seq_novios');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."ProgramaNovios"
   SET idusuariomodificacion = p_usuariomodificacion, 
       fechamodificacion     = fechahoy, 
       ipmodificacion        = p_ipmodificacion, 
       idestadoregistro      = 0
 WHERE id                    = p_idnovios;

INSERT INTO negocio."ProgramaNovios"(
            id, codigonovios, idnovia, idnovio, iddestino, fechaboda, fechaviaje, 
            idmoneda, cuotainicial, dias, noches, fechashower, observaciones, 
            montototal, idservicio, idusuariocreacion, 
            fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, 
            ipmodificacion)
    (SELECT maxid, codigonovios, idnovia, idnovio, p_iddestino, p_fechaboda, p_fechaviaje, 
                   p_idmoneda, p_cuotainicial, p_dias, p_noches, p_fechashower, p_observaciones, 
                   p_montototal, p_idservicio, p_usuariomodificacion, fechahoy, p_ipmodificacion, 
                   p_usuariomodificacion, fechahoy, p_ipmodificacion
              FROM negocio."ProgramaNovios"
             WHERE id = p_idnovios);

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_actualizarprogramanovios(p_idnovios integer, p_iddestino integer, p_fechaboda date, p_fechaviaje date, p_idmoneda integer, p_cuotainicial numeric, p_dias integer, p_noches integer, p_fechashower date, p_observaciones text, p_montototal numeric, p_idservicio integer, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 344 (class 1255 OID 75944)
-- Name: fn_actualizarproveedorcuentabancaria(integer, integer, integer, character varying, character varying, integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarproveedorcuentabancaria(p_idempresa integer, p_idcuenta integer, p_idproveedor integer, p_nombrecuenta character varying, p_numerocuenta character varying, p_idtipocuenta integer, p_idbanco integer, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare v_pagosACuenta integer;
declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

SELECT count(1)
  INTO v_pagosACuenta
  FROM negocio."PagosObligacion" po
 INNER JOIN negocio."ObligacionesXPagar" oxp ON oxp.id = po.idobligacion AND oxp.idempresa = p_idempresa
 WHERE oxp.idproveedor    = p_idproveedor
   AND po.idcuentadestino = p_idcuenta
   AND po.idempresa       = p_idempresa;

IF v_pagosACuenta = 0 THEN
	UPDATE negocio."CuentaBancaria"
	   SET nombrecuenta          = p_nombrecuenta, 
	       numerocuenta          = p_numerocuenta,
	       idtipocuenta          = p_idtipocuenta,
	       idbanco               = p_idbanco, 
	       idusuariomodificacion = p_usuariomodificacion, 
	       fechamodificacion     = fechahoy, 
	       ipmodificacion        = p_ipmodificacion
	 WHERE id                    = p_idcuenta
	   AND idempresa             = p_idempresa;

ELSE
	UPDATE negocio."CuentaBancaria"
	   SET nombrecuenta          = p_nombrecuenta,
	       idusuariomodificacion = p_usuariomodificacion, 
	       fechamodificacion     = fechahoy, 
	       ipmodificacion        = p_ipmodificacion
	 WHERE id                    = p_idcuenta
	   AND idempresa             = p_idempresa;

END IF;


return true;

end;
$$;


ALTER FUNCTION negocio.fn_actualizarproveedorcuentabancaria(p_idempresa integer, p_idcuenta integer, p_idproveedor integer, p_nombrecuenta character varying, p_numerocuenta character varying, p_idtipocuenta integer, p_idbanco integer, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 345 (class 1255 OID 75945)
-- Name: fn_actualizarproveedorservicio(integer, integer, integer, integer, numeric, numeric, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarproveedorservicio(p_idempresa integer, p_idproveedor integer, p_idtiposervicio integer, p_idproveedorservicio integer, p_porcencomision numeric, p_porcencominternacional numeric, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare 

fechahoy timestamp with time zone;
cantidad integer;
resultado boolean;


begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

select count(1)
  into cantidad
  from negocio."ProveedorTipoServicio"
 where idproveedor         = p_idproveedor
   and idtiposervicio      = p_idtiposervicio
   and idproveedorservicio = p_idproveedorservicio
   and idempresa           = p_idempresa;

if cantidad = 1 then
UPDATE negocio."ProveedorTipoServicio"
   SET porcencomnacional      = p_porcencomision, 
       porcencominternacional = p_porcencominternacional,
       idusuariomodificacion  = p_usuariomodificacion, 
       fechamodificacion      = fechahoy, 
       ipmodificacion         = p_ipmodificacion,
       idestadoregistro       = 1
 WHERE idproveedor            = p_idproveedor
   AND idtiposervicio         = p_idtiposervicio
   AND idproveedorservicio    = p_idproveedorservicio
   AND idempresa              = p_idempresa;
else
select negocio.fn_ingresarservicioproveedor(p_idempresa,p_idproveedor,p_idtiposervicio,p_idproveedorservicio,p_porcencomision,p_porcencominternacional,p_usuariomodificacion,
    p_ipmodificacion) into resultado;
end if;

return true;

 end;
$$;


ALTER FUNCTION negocio.fn_actualizarproveedorservicio(p_idempresa integer, p_idproveedor integer, p_idtiposervicio integer, p_idproveedorservicio integer, p_porcencomision numeric, p_porcencominternacional numeric, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 346 (class 1255 OID 75946)
-- Name: fn_actualizarproveedortipo(integer, integer, integer, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarproveedortipo(p_idempresa integer, p_idpersona integer, p_idtipoproveedor integer, p_usuariomodificacion integer, p_ipmodificacion character varying, p_nombrecomercial character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."ProveedorPersona"
   SET idtipoproveedor       = p_idtipoproveedor, 
       idusuariomodificacion = p_usuariomodificacion, 
       fechamodificacion     = fechahoy, 
       ipmodificacion        = p_ipmodificacion,
       nombrecomercial       = p_nombrecomercial
 WHERE idproveedor           = p_idpersona
   AND idempresa             = p_idempresa;


return true;

end;
$$;


ALTER FUNCTION negocio.fn_actualizarproveedortipo(p_idempresa integer, p_idpersona integer, p_idtipoproveedor integer, p_usuariomodificacion integer, p_ipmodificacion character varying, p_nombrecomercial character varying) OWNER TO postgres;

--
-- TOC entry 347 (class 1255 OID 75947)
-- Name: fn_actualizarrelacioncomprobantes(integer, integer, boolean, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarrelacioncomprobantes(p_idempresa integer, p_idservicio integer, p_guardorelacion boolean, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;
Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."ServicioCabecera"
   SET guardorelacioncomprobantes = p_guardorelacion, 
       idusuariomodificacion      = p_usuariomodificacion, 
       fechamodificacion          = fechahoy, 
       ipmodificacion             = p_ipmodificacion
 WHERE id                         = p_idservicio
   AND idempresa                  = p_idempresa;

 return true;

end;
$$;


ALTER FUNCTION negocio.fn_actualizarrelacioncomprobantes(p_idempresa integer, p_idservicio integer, p_guardorelacion boolean, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 348 (class 1255 OID 75948)
-- Name: fn_actualizarservicio(integer, integer, character varying, character varying, character varying, boolean, integer, boolean, integer, boolean, boolean, boolean, integer, character varying, integer, boolean, boolean); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarservicio(p_idempresa integer, p_id integer, p_nombreservicio character varying, p_desccorta character varying, p_desclarga character varying, p_requierefee boolean, p_idmaeserfee integer, p_pagaimpto boolean, p_idmaeserimpto integer, p_cargacomision boolean, p_esimpuesto boolean, p_esfee boolean, p_usuariomodificacion integer, p_ipmodificacion character varying, p_idparametro integer, p_visible boolean, p_serviciopadre boolean) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."MaestroServicios"
   SET nombre                = p_nombreservicio, 
       desccorta             = p_desccorta, 
       desclarga             = p_desclarga, 
       requierefee           = p_requierefee, 
       idmaeserfee           = p_idmaeserfee,
       pagaimpto             = p_pagaimpto, 
       idmaeserimpto         = p_idmaeserimpto,
       cargacomision         = p_cargacomision,
       esimpuesto            = p_esimpuesto,
       esfee	             = p_esfee,
       idusuariomodificacion = p_usuariomodificacion, 
       fechamodificacion     = fechahoy, 
       ipmodificacion        = p_ipmodificacion,
       idparametroasociado   = p_idparametro,
       visible               = p_visible,
       esserviciopadre       = p_serviciopadre
 WHERE id                    = p_id
   AND idempresa             = p_idempresa;

return true;
end;
$$;


ALTER FUNCTION negocio.fn_actualizarservicio(p_idempresa integer, p_id integer, p_nombreservicio character varying, p_desccorta character varying, p_desclarga character varying, p_requierefee boolean, p_idmaeserfee integer, p_pagaimpto boolean, p_idmaeserimpto integer, p_cargacomision boolean, p_esimpuesto boolean, p_esfee boolean, p_usuariomodificacion integer, p_ipmodificacion character varying, p_idparametro integer, p_visible boolean, p_serviciopadre boolean) OWNER TO postgres;

--
-- TOC entry 351 (class 1255 OID 75949)
-- Name: fn_actualizarserviciocabecera1(integer, integer, integer, integer, date, integer, numeric, numeric, numeric, numeric, integer, character varying, integer, integer, integer, integer, numeric, numeric, date, date, integer, text, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarserviciocabecera1(p_idempresa integer, p_idservicio integer, p_idcliente1 integer, p_idcliente2 integer, p_fechacompra date, p_cantidadservicios integer, p_montototal numeric, p_montototalfee numeric, p_montototalcomision numeric, p_montototaligv numeric, p_iddestino integer, p_descdestino character varying, p_idmediopago integer, p_idestadopago integer, p_idestadoservicio integer, p_nrocuotas integer, p_tea numeric, p_valorcuota numeric, p_fechaprimercuota date, p_fechaultcuota date, p_idvendedor integer, p_observacion text, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;
Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."ServicioCabecera"
   SET idcliente1            = p_idcliente1, 
       idcliente2            = p_idcliente2, 
       fechacompra           = p_fechacompra, 
       idformapago           = p_idmediopago, 
       idestadopago          = p_idestadopago, 
       idestadoservicio      = p_idestadoservicio, 
       nrocuotas             = p_nrocuotas, 
       tea                   = p_tea, 
       valorcuota            = p_valorcuota, 
       fechaprimercuota      = p_fechaprimercuota, 
       fechaultcuota         = p_fechaultcuota, 
       montocomisiontotal    = p_montototalcomision, 
       montototaligv         = p_montototaligv, 
       montototal            = p_montototal, 
       montototalfee         = p_montototalfee, 
       idvendedor            = p_idvendedor, 
       observaciones         = p_observacion,
       idusuariomodificacion = p_usuariomodificacion, 
       fechamodificacion     = fechahoy, 
       ipmodificacion        = p_ipmodificacion
 WHERE id                    = p_idservicio
   AND idempresa             = p_idempresa;

 return p_idservicio;

end;
$$;


ALTER FUNCTION negocio.fn_actualizarserviciocabecera1(p_idempresa integer, p_idservicio integer, p_idcliente1 integer, p_idcliente2 integer, p_fechacompra date, p_cantidadservicios integer, p_montototal numeric, p_montototalfee numeric, p_montototalcomision numeric, p_montototaligv numeric, p_iddestino integer, p_descdestino character varying, p_idmediopago integer, p_idestadopago integer, p_idestadoservicio integer, p_nrocuotas integer, p_tea numeric, p_valorcuota numeric, p_fechaprimercuota date, p_fechaultcuota date, p_idvendedor integer, p_observacion text, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 352 (class 1255 OID 75950)
-- Name: fn_actualizarservicioproveedor(integer, integer, integer, integer, numeric, numeric, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarservicioproveedor(p_idempresa integer, p_idproveedor integer, p_idtiposervicio integer, p_idproveedorservicio integer, p_porcencomnacional numeric, p_porcencominternacional numeric, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."ProveedorTipoServicio"
   SET porcencomnacional      = p_porcencomnacional, 
       porcencominternacional = p_porcencominternacional, 
       idusuariomodificacion  = p_usuariomodificacion, 
       fechamodificacion      = fechahoy, 
       ipmodificacion         = p_ipmodificacion, 
       idestadoregistro       = 1
 WHERE idproveedor            = p_idproveedor
   AND idtiposervicio         = p_idtiposervicio
   AND idproveedorservicio    = p_idproveedorservicio
   AND idempresa              = p_idempresa;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_actualizarservicioproveedor(p_idempresa integer, p_idproveedor integer, p_idtiposervicio integer, p_idproveedorservicio integer, p_porcencomnacional numeric, p_porcencominternacional numeric, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 353 (class 1255 OID 75951)
-- Name: fn_calcularcuota(numeric, numeric, numeric); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_calcularcuota(p_montototal numeric, p_nrocuotas numeric, p_tea numeric) RETURNS numeric
    LANGUAGE plpgsql
    AS $$

declare valorcuota decimal = 0;
declare numerador decimal = 0;
declare denominador decimal = 0;
declare tasamensual decimal = 0;

Begin

tasamensual = negocio.fn_calculartem(p_tea);

numerador = ((1+tasamensual)^p_nrocuotas) * tasamensual;
denominador = ((1+tasamensual)^p_nrocuotas) - 1;

valorcuota = p_montototal * (numerador / denominador);


return valorcuota;


End;
$$;


ALTER FUNCTION negocio.fn_calcularcuota(p_montototal numeric, p_nrocuotas numeric, p_tea numeric) OWNER TO postgres;

--
-- TOC entry 354 (class 1255 OID 75952)
-- Name: fn_calculartem(numeric); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_calculartem(p_tea numeric) RETURNS double precision
    LANGUAGE plpgsql
    AS $$

declare tasamensual decimal = 0;


begin

tasamensual = ( (1+p_tea)^(1.0/12.0) )-1;

return tasamensual;

end;
$$;


ALTER FUNCTION negocio.fn_calculartem(p_tea numeric) OWNER TO postgres;

--
-- TOC entry 355 (class 1255 OID 75953)
-- Name: fn_comboproveedorestipo(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_comboproveedorestipo(p_idempresa integer, p_idtipo integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT per.id, per.nombres, per.apellidopaterno, per.apellidomaterno
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
$$;


ALTER FUNCTION negocio.fn_comboproveedorestipo(p_idempresa integer, p_idtipo integer) OWNER TO postgres;

--
-- TOC entry 356 (class 1255 OID 75954)
-- Name: fn_consultacuentabancaria(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultacuentabancaria(p_idempresa integer, p_idcuenta integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT id, nombrecuenta, numerocuenta, idtipocuenta, idbanco, idmoneda, saldocuenta, usuariocreacion, 
       fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
       ipmodificacion
  FROM negocio."CuentaBancaria"
 WHERE idestadoregistro = 1
   AND id               = p_idcuenta
   AND idempresa        = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultacuentabancaria(p_idempresa integer, p_idcuenta integer) OWNER TO postgres;

--
-- TOC entry 357 (class 1255 OID 75955)
-- Name: fn_consultararchivoscargados(integer, integer, date, date, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultararchivoscargados(p_idempresa integer, p_idarchivo integer, p_fechadesde date, p_fechahasta date, p_idproveedor integer, p_nombrereporte character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT ac.id, nombrearchivo, nombrereporte, ac.idproveedor, vp.nombres, vp.apellidopaterno, vp.apellidomaterno, numerofilas, numerocolumnas, 
       (SELECT COUNT(1) 
          FROM negocio."DetalleArchivoCargado" dac
         WHERE seleccionado = TRUE
           AND idarchivo    = ac.id
           AND idempresa    = ac.idempresa) AS seleccionados,
       ac.idmoneda, tmmo.nombre, tmmo.abreviatura, ac.montosubtotal, ac.montoigv, ac.montototal
  FROM negocio."ArchivoCargado" ac,
       negocio.vw_proveedor vp,
       soporte."Tablamaestra" tmmo
 WHERE vp.idproveedor                   = ac.idproveedor
   AND tmmo.idmaestro                   = fn_maestromoneda()
   AND ac.idmoneda                      = tmmo.id
   AND tmmo.idempresa                   = ac.idempresa
   AND ac.idempresa                     = p_idempresa
   AND ac.id                            = COALESCE(p_idarchivo, ac.id)
   AND date(ac.fechacreacion)           BETWEEN p_fechadesde AND p_fechahasta
   AND ac.idproveedor                   = COALESCE(p_idproveedor, ac.idproveedor)
   AND REPLACE(ac.nombrereporte,' ','') LIKE '%'||COALESCE(p_nombrereporte,REPLACE(ac.nombrereporte,' ',''))||'%';

 return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultararchivoscargados(p_idempresa integer, p_idarchivo integer, p_fechadesde date, p_fechahasta date, p_idproveedor integer, p_nombrereporte character varying) OWNER TO postgres;

--
-- TOC entry 358 (class 1255 OID 75956)
-- Name: fn_consultarcheckinpendientes(integer, timestamp without time zone, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarcheckinpendientes(p_idempresa integer, p_fechahasta timestamp without time zone, p_idvendedor integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
select sc.id, negocio.fn_consultarnombrepersona(p_idempresa,sc.idcliente1) as nombrecliente, 
       negocio.fn_consultarnombrepersona(p_idempresa,sc.idcliente2) as nombrecliente2,
       t.descripcionorigen, t.descripciondestino, t.fechasalida, t.fechallegada, 
       negocio.fn_consultarnombrepersona(p_idempresa,t.idaerolinea) nombreaerolinea,
       sd.id as iddetalle, t.id as idtramo, rs.id as idruta
  from negocio."Tramo" t
 inner join negocio."RutaServicio" rs on rs.idtramo = t.id and rs.idempresa = p_idempresa
 inner join negocio."ServicioDetalle" sd on sd.idruta = rs.id and sd.idempresa = p_idempresa
 inner join negocio."ServicioCabecera" sc on sc.id = sd.idservicio and sc.idempresa = p_idempresa
 where t.idempresa = p_idempresa
   and fechasalida between current_timestamp and p_fechahasta
   and sc.idvendedor = coalesce(p_idvendedor,sc.idvendedor);

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarcheckinpendientes(p_idempresa integer, p_fechahasta timestamp without time zone, p_idvendedor integer) OWNER TO postgres;

--
-- TOC entry 336 (class 1255 OID 75957)
-- Name: fn_consultarclientescumple(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarclientescumple(p_idempresa integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
select id, idtipopersona, nombres, apellidopaterno, apellidomaterno, 
       idgenero, idestadocivil, idtipodocumento, numerodocumento, usuariocreacion, 
       fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
       ipmodificacion, idestadoregistro, fecnacimiento, nropasaporte, 
       fecvctopasaporte
  from negocio."Persona" p
 where p.idestadoregistro              = 1
   and p.idempresa                     = p_idempresa
   and p.idtipopersona                 = fn_tipopersonacliente()
   and to_char(p.fecnacimiento,'ddMM') = to_char(current_date,'ddMM');

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarclientescumple(p_idempresa integer) OWNER TO postgres;

--
-- TOC entry 349 (class 1255 OID 75958)
-- Name: fn_consultarclientesnovios(integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarclientesnovios(p_idempresa integer, p_genero character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT pro.id AS idpersona, tdoc.id AS idtipodocumento, 
       tdoc.nombre AS nombretipodocumento, pro.numerodocumento, pro.nombres, 
       pro.apellidopaterno, pro.apellidomaterno
   FROM negocio."Persona" pro, 
        soporte."Tablamaestra" tdoc
  WHERE pro.idestadoregistro  = 1
    AND pro.idempresa         = p_idempresa
    AND pro.idtipopersona     = fn_tipopersonacliente()
    AND tdoc.idmaestro        = fn_maestrotipodocumento()
    AND pro.idtipodocumento   = tdoc.id
    AND pro.idgenero          = p_genero;


return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarclientesnovios(p_idempresa integer, p_genero character varying) OWNER TO postgres;

--
-- TOC entry 359 (class 1255 OID 75959)
-- Name: fn_consultarclientesnovios(integer, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarclientesnovios(p_idempresa integer, p_genero character varying, p_idtipodocumento integer, p_numerodocumento character varying, p_nombres character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT pro.id AS idpersona, tdoc.id AS idtipodocumento, 
       tdoc.nombre AS nombretipodocumento, pro.numerodocumento, pro.nombres, 
       pro.apellidopaterno, pro.apellidomaterno
   FROM negocio."Persona" pro, 
        soporte."Tablamaestra" tdoc
  WHERE pro.idestadoregistro  = 1
    AND pro.idempresa         = p_idempresa
    AND pro.idtipopersona     = fn_tipopersonacliente()
    AND tdoc.idmaestro        = fn_maestrotipodocumento()
    AND pro.idtipodocumento   = tdoc.id
    AND pro.idgenero          = p_genero
    AND tdoc.id               = COALESCE(p_idtipodocumento,tdoc.id)
    AND pro.numerodocumento   = COALESCE(p_numerodocumento,pro.numerodocumento)
    AND CONCAT(replace(pro.nombres,' ',''),trim(pro.apellidopaterno),trim(pro.apellidomaterno)) like '%'||COALESCE(p_nombres,CONCAT(replace(pro.nombres,' ',''),trim(pro.apellidopaterno),trim(pro.apellidomaterno)))||'%';


return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarclientesnovios(p_idempresa integer, p_genero character varying, p_idtipodocumento integer, p_numerodocumento character varying, p_nombres character varying) OWNER TO postgres;

--
-- TOC entry 360 (class 1255 OID 75960)
-- Name: fn_consultarcompbtobligcnservdethijo(integer, integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarcompbtobligcnservdethijo(p_idempresa integer, p_idservicio integer, p_iddetservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT serdet.id as idSerdetalle, serdet.idtiposervicio, 
       tipser.id, tipser.nombre as nomtipservicio, tipser.desccorta as descservicio, tipser.requierefee, 
       tipser.pagaimpto, tipser.cargacomision, tipser.esimpuesto, tipser.esfee,
       serdet.descripcionservicio, serdet.fechaida, serdet.fecharegreso, serdet.cantidad, 
       serdet.preciobase, serdet.montototalcomision, serdet.montototal, serdet.idempresaproveedor, pro.nombres, pro.apellidopaterno, 
       pro.apellidomaterno, tipser.visible,
       (select cg.tienedetraccion
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and dc.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa) as tieneDetraccion,
       (select cg.tieneretencion
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and dc.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa) as tieneRetencion,
       (select cg.id
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and dc.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa) as idComprobante,
       (select cg.idtipocomprobante
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and dc.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa) as tipoComprobante,
       (select tm.nombre
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg,
               soporte."Tablamaestra" tm
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and dc.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa
           and tm.idempresa         = dc.idempresa
           and tm.id                = cg.idtipocomprobante
           and tm.idmaestro         = fn_maestrotipocomprobante()) as tipoComprobanteNombre,
       (select tm.abreviatura
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg,
               soporte."Tablamaestra" tm
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and dc.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa
           and tm.idempresa         = dc.idempresa
           and tm.id                = cg.idtipocomprobante
           and tm.idmaestro         = fn_maestrotipocomprobante()) as tipoComprobanteAbrev,
       (select cg.numerocomprobante
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and dc.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa) as numeroComprobante,
       (select tm.nombre
	  from negocio."ComprobanteObligacion" comobl,
	       negocio."ObligacionesXPagar" obli,
	       soporte."Tablamaestra" tm
	 where comobl.iddetalleservicio = serdet.id
	   and comobl.idobligacion      = obli.id
	   and comobl.idempresa         = obli.idempresa
	   and obli.idtipocomprobante   = tm.id
	   and obli.idempresa           = tm.idempresa
	   and comobli.idempresa        = p_idempresa
	   and tm.estado                = 'A'
	   and tm.idmaestro             = fn_maestrotipocomprobante()) as tipoObligacion,
       (select tm.abreviatura
	  from negocio."ComprobanteObligacion" comobl,
	       negocio."ObligacionesXPagar" obli,
	       soporte."Tablamaestra" tm
	 where comobl.iddetalleservicio = serdet.id
	   and comobl.idobligacion      = obli.id
	   and comobl.idempresa         = obli.idempresa
	   and obli.idtipocomprobante   = tm.id
	   and obli.idempresa           = tm.idempresa
	   and comobl                   = p_idempresa
	   and tm.estado                = 'A'
	   and tm.idmaestro             = fn_maestrotipocomprobante()) as tipoObligacionAbrev,
       (select obli.numerocomprobante
	  from negocio."ComprobanteObligacion" comobl,
	       negocio."ObligacionesXPagar" obli
	 where comobl.iddetalleservicio = serdet.id
	   and comobl.idobligacion      = obli.id
	   and comobl.idempresa         = obli.idempresa
	   and comobl.idempresa         = p_idempresa) as numeroObligacion
  FROM negocio."ServicioDetalle" serdet
 INNER JOIN negocio."MaestroServicios" tipser ON tipser.id = serdet.idtiposervicio    AND tipser.idempresa = p_idempresa
  LEFT JOIN negocio.vw_proveedoresnova pro    ON pro.id   = serdet.idempresaproveedor AND pro.idempresa    = p_idempresa AND tipser.idestadoregistro = 1 
 WHERE serdet.idestadoregistro = 1
   AND serdet.idempresa        = p_idempresa
   AND serdet.idservicio       = p_idservicio
   AND serdet.idservdetdepende = p_iddetservicio;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarcompbtobligcnservdethijo(p_idempresa integer, p_idservicio integer, p_iddetservicio integer) OWNER TO postgres;

--
-- TOC entry 361 (class 1255 OID 75961)
-- Name: fn_consultarcomprobantesgenerados(integer, integer, integer, integer, integer, character varying, date, date); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarcomprobantesgenerados(p_idempresa integer, p_idcomprobante integer, p_idservicio integer, p_idadquiriente integer, p_idtipocomprobante integer, p_numerocomprobante character varying, p_fechadesde date, p_fechahasta date) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT cg.id, cg.idservicio, cg.idtipocomprobante, tm.nombre, cg.numerocomprobante, cg.idtitular, p.nombres, p.apellidopaterno, p.apellidomaterno,
       cg.fechacomprobante, cg.idmoneda, tmmo.nombre as nombremoneda, tmmo.abreviatura, (cg.totalcomprobante-cg.totaligv) as subtotalcomprobante, 
       cg.totaligv, cg.totalcomprobante, cg.tienedetraccion, 
       cg.tieneretencion, cg.usuariocreacion, cg.fechacreacion, cg.ipcreacion, cg.usuariomodificacion, 
       cg.fechamodificacion, cg.ipmodificacion
  FROM negocio."ComprobanteGenerado" cg
 INNER JOIN soporte."Tablamaestra" tmmo ON tmmo.idmaestro       = fn_maestrotipomoneda() AND tmmo.id      = cg.idmoneda                 AND tmmo.idempresa = p_idempresa
 INNER JOIN soporte."Tablamaestra" tm   ON cg.idtipocomprobante = tm.id                  AND tm.idmaestro = fn_maestrotipocomprobante() AND tm.idempresa   = p_idempresa
 INNER JOIN negocio."Persona" p         ON cg.idtitular         = p.id                   AND p.idempresa  = p_idempresa
 WHERE cg.idestadoregistro  = 1
   AND cg.idempresa         = p_idempresa
   AND cg.fechacomprobante  BETWEEN COALESCE(p_fechadesde,'1900-01-01') AND COALESCE(p_fechahasta,current_date)
   AND cg.id                = COALESCE(p_idcomprobante, cg.id)
   AND cg.idservicio        = COALESCE(p_idservicio, cg.idservicio)
   AND cg.idtitular         = COALESCE(p_idadquiriente, cg.idtitular)
   AND cg.idtipocomprobante = COALESCE(p_idtipocomprobante, cg.idtipocomprobante)
   AND cg.numerocomprobante = COALESCE(p_numerocomprobante, cg.numerocomprobante);
   
return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarcomprobantesgenerados(p_idempresa integer, p_idcomprobante integer, p_idservicio integer, p_idadquiriente integer, p_idtipocomprobante integer, p_numerocomprobante character varying, p_fechadesde date, p_fechahasta date) OWNER TO postgres;

--
-- TOC entry 362 (class 1255 OID 75962)
-- Name: fn_consultarcomprobantesobligacionservdet(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarcomprobantesobligacionservdet(p_idempresa integer, p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT serdet.id as idSerdetalle, serdet.idtiposervicio, 
       tipser.id, tipser.nombre as nomtipservicio, tipser.desccorta as descservicio, tipser.requierefee, 
       tipser.pagaimpto, tipser.cargacomision, tipser.esimpuesto, tipser.esfee,
       serdet.descripcionservicio, serdet.fechaida, serdet.fecharegreso, serdet.cantidad, 
       serdet.preciobase, serdet.montototalcomision, serdet.montototal, serdet.idempresaproveedor, pro.nombres, pro.apellidopaterno, 
       pro.apellidomaterno, tipser.visible,
       (select cg.tienedetraccion
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and cd.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa) as tieneDetraccion,
       (select cg.tieneretencion
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and cd.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa) as tieneRetencion,
       (select cg.id
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and cd.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa) as idComprobante,
       (select cg.idtipocomprobante
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and cd.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa) as tipoComprobante,
       (select tm.nombre
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg,
               soporte."Tablamaestra" tm
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and cd.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa
           and tm.idempresa         = dc.idempresa
           and tm.id                = cg.idtipocomprobante
           and tm.idmaestro         = fn_maestrotipocomprobante()) as tipoComprobanteNombre,
       (select tm.abreviatura
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg,
               soporte."Tablamaestra" tm
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and cd.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa
           and tm.idempresa         = dc.idempresa
           and tm.id                = cg.idtipocomprobante
           and tm.idmaestro         = fn_maestrotipocomprobante()) as tipoComprobanteAbrev,
       (select cg.numerocomprobante
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and cd.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa) as numeroComprobante,
       (select tm.nombre
	  from negocio."ComprobanteObligacion" comobl,
	       negocio."ObligacionesXPagar" obli,
	       soporte."Tablamaestra" tm
	 where comobl.iddetalleservicio = serdet.id
	   and comobl.idobligacion      = obli.id
	   and comobl.idempresa         = obli.idempresa
	   and comobl.idempresa         = tm.idempresa
	   and comobl.idempresa         = p_idempresa
	   and obli.idtipocomprobante   = tm.id
	   and tm.estado                = 'A'
	   and tm.idmaestro             = fn_maestrotipocomprobante()) as tipoObligacion,
	(select tm.abreviatura
	  from negocio."ComprobanteObligacion" comobl,
	       negocio."ObligacionesXPagar" obli,
	       soporte."Tablamaestra" tm
	 where comobl.iddetalleservicio = serdet.id
	   and comobl.idobligacion      = obli.id
	   and comobl.idempresa         = obli.idempresa
	   and comobl.idempresa         = tm.idempresa
	   and comobl.idempresa         = p_idempresa
	   and obli.idtipocomprobante   = tm.id
	   and tm.estado                = 'A'
	   and tm.idmaestro             = fn_maestrotipocomprobante()) as tipoObligacionAbrev,
       (select obli.numerocomprobante
	  from negocio."ComprobanteObligacion" comobl,
	       negocio."ObligacionesXPagar" obli
	 where comobl.iddetalleservicio = serdet.id
	   and comobl.idobligacion      = obli.id
	   and comobl.idempresa         = obli.idempresa
	   and comobl.idempresa         = p_idempresa) as numeroObligacion
  FROM negocio."ServicioDetalle" serdet
 INNER JOIN negocio."MaestroServicios" tipser ON tipser.id = serdet.idtiposervicio     AND tipser.idempresa = p_idempresa AND tipser.idestadoregistro = 1
  LEFT JOIN negocio.vw_proveedoresnova pro    ON pro.id    = serdet.idempresaproveedor AND pro.idempresa    = p_idempresa
 WHERE serdet.idestadoregistro = 1
   AND serdet.idempresa        = p_idempresa
   AND serdet.idservicio       = p_idservicio
   AND serdet.idservdetdepende is null;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarcomprobantesobligacionservdet(p_idempresa integer, p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 363 (class 1255 OID 75963)
-- Name: fn_consultarcomprobantesserviciodetalle(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarcomprobantesserviciodetalle(p_idempresa integer, p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT serdet.id as idSerdetalle, serdet.idtiposervicio, 
       tipser.id, tipser.nombre as nomtipservicio, tipser.desccorta as descservicio, tipser.requierefee, 
       tipser.pagaimpto, tipser.cargacomision, tipser.esimpuesto, tipser.esfee,
       serdet.descripcionservicio, serdet.fechaida, serdet.fecharegreso, serdet.cantidad, 
       serdet.preciobase, serdet.montototalcomision, serdet.montototal, serdet.idempresaproveedor, pro.nombres, pro.apellidopaterno, 
       pro.apellidomaterno, tipser.visible,
       (select cg.tienedetraccion
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and dc.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa) as tieneDetraccion,
       (select cg.tieneretencion
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and dc.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa) as tieneRetencion,
       (select cg.id
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and dc.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa) as idComprobante,
       (select cg.idtipocomprobante
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and dc.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa) as tipoComprobante,
       (select tm.nombre
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg,
               soporte."Tablamaestra" tm
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and dc.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa
           and tm.idempresa         = cg.idempresa
           and tm.id                = cg.idtipocomprobante
           and tm.idmaestro         = fn_maestrotipocomprobante()) as tipoComprobanteNombre,
       (select tm.abreviatura
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg,
               soporte."Tablamaestra" tm
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and dc.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa
           and tm.idempresa         = cg.idempresa
           and tm.id                = cg.idtipocomprobante
           and tm.idmaestro         = fn_maestrotipocomprobante()) as tipoComprobanteAbrev,
       (select cg.numerocomprobante
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and dc.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa) as numeroComprobante
       
  FROM negocio."ServicioDetalle" serdet
 INNER JOIN negocio."MaestroServicios" tipser ON tipser.id = serdet.idtiposervicio     AND tipser.idempresa = p_idempresa AND tipser.idestadoregistro = 1
  LEFT JOIN negocio.vw_proveedoresnova pro    ON pro.id    = serdet.idempresaproveedor AND pro.idempresa    = p_idempresa
 WHERE serdet.idestadoregistro = 1
   AND serdet.idempresa        = p_idempresa
   AND serdet.idservicio       = p_idservicio
   AND serdet.idservdetdepende is null;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarcomprobantesserviciodetalle(p_idempresa integer, p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 366 (class 1255 OID 75964)
-- Name: fn_consultarcompserviciodethijo(integer, integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarcompserviciodethijo(p_idempresa integer, p_idservicio integer, p_iddetserv integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT serdet.id as idSerdetalle, serdet.idtiposervicio, 
       tipser.id, tipser.nombre as nomtipservicio, tipser.desccorta as descservicio, tipser.requierefee, 
       tipser.pagaimpto, tipser.cargacomision, tipser.esimpuesto, tipser.esfee,
       serdet.descripcionservicio, serdet.fechaida, serdet.fecharegreso, serdet.cantidad, 
       serdet.preciobase, serdet.montototalcomision, serdet.montototal, serdet.idempresaproveedor, pro.nombres, pro.apellidopaterno, 
       pro.apellidomaterno, tipser.visible,
       (select cg.tienedetraccion
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and dc.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa) as tieneDetraccion,
       (select cg.tieneretencion
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and dc.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa) as tieneRetencion,
       (select cg.id
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and dc.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa) as idComprobante,
       (select cg.idtipocomprobante
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and dc.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa) as tipoComprobante,
       (select tm.nombre
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg,
               soporte."Tablamaestra" tm
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and dc.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa
           and tm.idempresa         = cg.idempresa
           and tm.id                = cg.idtipocomprobante
           and tm.idmaestro         = fn_maestrotipocomprobante()) as tipoComprobanteNombre,
       (select tm.abreviatura
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg,
               soporte."Tablamaestra" tm
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and dc.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa
           and tm.idempresa         = cg.idempresa
           and tm.id                = cg.idtipocomprobante
           and tm.idmaestro         = fn_maestrotipocomprobante()) as tipoComprobanteAbrev,
       (select cg.numerocomprobante
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and dc.idempresa         = cg.idempresa
           and dc.idempresa         = p_idempresa) as numeroComprobante
       
  FROM negocio."ServicioDetalle" serdet
 INNER JOIN negocio."MaestroServicios" tipser ON tipser.id = serdet.idtiposervicio     AND tipser.idempresa = p_idempresa AND tipser.idestadoregistro = 1
  LEFT JOIN negocio.vw_proveedoresnova pro    ON pro.id    = serdet.idempresaproveedor AND pro.idempresa    = p_idempresa
 WHERE serdet.idestadoregistro = 1
   AND serdet.idempresa        = p_idempresa
   AND serdet.idservicio       = p_idservicio
   AND serdet.idservdetdepende = p_iddetserv;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarcompserviciodethijo(p_idempresa integer, p_idservicio integer, p_iddetserv integer) OWNER TO postgres;

--
-- TOC entry 367 (class 1255 OID 75965)
-- Name: fn_consultarconsolidador(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarconsolidador(p_idconsolidador integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT id, nombre, usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
       fechamodificacion, ipmodificacion
  FROM negocio."Consolidador"
 WHERE idestadoregistro = 1
   AND id               = p_idconsolidador;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarconsolidador(p_idconsolidador integer) OWNER TO postgres;

--
-- TOC entry 368 (class 1255 OID 75966)
-- Name: fn_consultarcontactoxpersona(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarcontactoxpersona(p_idempresa integer, p_idpersona integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
select per.id, per.idtipopersona, per.nombres, per.apellidopaterno, per.apellidomaterno, 
       per.idgenero, per.idestadocivil, per.idtipodocumento, per.numerodocumento
  from negocio."PersonaContactoProveedor" pcon,
       negocio."Persona" per
 where pcon.idestadoregistro = 1
   and per.idestadoregistro  = 1
   and pcon.idempresa        = per.idempresa
   and pcon.idempresa        = p_idempresa
   and per.idtipopersona     = fn_tipopersonacontacto()
   and pcon.idcontacto       = per.id
   and pcon.idproveedor      = p_idpersona;


return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarcontactoxpersona(p_idempresa integer, p_idpersona integer) OWNER TO postgres;

--
-- TOC entry 369 (class 1255 OID 75967)
-- Name: fn_consultarcronogramapago(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarcronogramapago(p_idempresa integer, p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT nrocuota, idservicio, fechavencimiento, capital, interes, totalcuota, 
       idestadocuota, idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, 
       fechamodificacion, ipmodificacion, idestadoregistro
  FROM negocio."CronogramaPago"
 where idservicio = p_idservicio
   and idempresa  = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarcronogramapago(p_idempresa integer, p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 370 (class 1255 OID 75968)
-- Name: fn_consultarcronogramaservicio(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarcronogramaservicio(p_idempresa integer, p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT nrocuota, idservicio, fechavencimiento, capital, interes, totalcuota, 
       idestadocuota, usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
       fechamodificacion, ipmodificacion, idestadoregistro
  FROM negocio."CronogramaPago"
 WHERE idservicio = p_idservicio
   AND idempresa  = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarcronogramaservicio(p_idempresa integer, p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 371 (class 1255 OID 75969)
-- Name: fn_consultardetallecomprobantegenerado(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultardetallecomprobantegenerado(p_idempresa integer, p_idcomprobante integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT id, idserviciodetalle, idcomprobante, cantidad, detalleconcepto, 
       preciounitario, totaldetalle
  FROM negocio."DetalleComprobanteGenerado"
 WHERE idcomprobante = p_idcomprobante
   AND idempresa     = p_idempresa;
   

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultardetallecomprobantegenerado(p_idempresa integer, p_idcomprobante integer) OWNER TO postgres;

--
-- TOC entry 372 (class 1255 OID 75970)
-- Name: fn_consultardetalleservicioventadetalle(integer, integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultardetalleservicioventadetalle(p_idempresa integer, p_idservicio integer, p_iddetalle integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT serdet.id as idSerdetalle, 
       tipser.id as idtiposervicio, tipser.nombre as nomtipservicio, tipser.desccorta as descservicio, tipser.requierefee, 
       tipser.pagaimpto, tipser.cargacomision, tipser.esimpuesto, tipser.esfee, tipser.visible,
       
       serdet.descripcionservicio, 
       serdet.idservicio, 
       serdet.fechaida, 
       serdet.fecharegreso, 
       serdet.cantidad, 
       serdet.idempresaproveedor, 
       serdet.descripcionproveedor,
       pro.nombres, pro.apellidopaterno, pro.apellidomaterno,
       serdet.idempresaoperadora, 
       serdet.descripcionoperador, 
       serdet.idempresatransporte, 
       serdet.descripcionemptransporte, 
       serdet.idhotel, 
       serdet.decripcionhotel, 
       serdet.idruta, 
       serdet.preciobase, 
       serdet.editocomision, 
       serdet.tarifanegociada,
       serdet.montototalcomision, 
       serdet.montototal
  FROM negocio."ServicioDetalle" serdet
 INNER JOIN negocio."MaestroServicios" tipser ON tipser.id = serdet.idtiposervicio     AND tipser.idempresa = p_idempresa AND tipser.idestadoregistro = 1
  LEFT JOIN negocio.vw_proveedoresnova pro    ON pro.id    = serdet.idempresaproveedor AND pro.idempresa    = p_idempresa
 WHERE serdet.idestadoregistro = 1
   AND serdet.idservicio       = p_idservicio
   AND serdet.idempresa        = p_idempresa
   AND serdet.id               = p_iddetalle;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultardetalleservicioventadetalle(p_idempresa integer, p_idservicio integer, p_iddetalle integer) OWNER TO postgres;

--
-- TOC entry 373 (class 1255 OID 75971)
-- Name: fn_consultarinvitadosnovios(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarinvitadosnovios(p_idempresa integer, p_idnovios integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT id, nombres, apellidopaterno, apellidomaterno, telefono, correoelectronico, 
       fecnacimiento
  FROM negocio."Personapotencial"
 WHERE idnovios  = p_idnovios
   AND idempresa = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarinvitadosnovios(p_idempresa integer, p_idnovios integer) OWNER TO postgres;

--
-- TOC entry 374 (class 1255 OID 75972)
-- Name: fn_consultarnombrepersona(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarnombrepersona(p_idempresa integer, p_id integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare nombre character varying(100);

begin

SELECT COALESCE(pro.nombres,'')||' '||COALESCE(pro.apellidopaterno,'')||' '||COALESCE(pro.apellidomaterno,'')
  INTO nombre
  FROM negocio."Persona" pro
 WHERE pro.id        = p_id
   AND pro.idempresa = p_idempresa;

return nombre;

end;
$$;


ALTER FUNCTION negocio.fn_consultarnombrepersona(p_idempresa integer, p_id integer) OWNER TO postgres;

--
-- TOC entry 377 (class 1255 OID 75973)
-- Name: fn_consultarnovios(integer, integer, character varying, integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarnovios(p_idempresa integer, p_id integer, p_codnovios character varying, p_idnovia integer, p_idnovio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT snov.id, snov.codigonovios, novia.idtipodocumento as tipodocnovia, novia.numerodocumento as numdocnovia, 
       snov.idnovia, novia.nombres as nomnovia, novia.apellidopaterno as apepatnovia, novia.apellidomaterno as apematnovia,
       novio.idtipodocumento as tipodocnovio, novio.numerodocumento as numdocnovio, 
       snov.idnovio, novio.nombres as nomnovio, novio.apellidopaterno as apepatnovio, novio.apellidomaterno as apematnovio,
       snov.iddestino, dest.descripcion as descdestino, dest.codigoiata, pai.descripcion as descpais,
       snov.fechaboda, snov.fechaviaje, 
       snov.idmoneda, snov.cuotainicial, snov.dias, snov.noches, snov.fechashower, snov.observaciones, 
       snov.usuariocreacion, snov.fechacreacion, snov.ipcreacion, snov.usuariomodificacion, 
       snov.fechamodificacion, snov.ipmodificacion,
       (select count(1) from negocio."Personapotencial" where idnovios = snov.id) as cantidadInvitados, snov.idservicio,
       sercab.idvendedor, usu.nombres as nomvendedor, usu.apepaterno as apepatvendedor, usu.apematerno as apematvendedor,
       sercab.montocomisiontotal, sercab.montototal, sercab.montototalfee
  FROM negocio."ProgramaNovios" snov,
       negocio."Persona" novia,
       negocio."Persona" novio,
       soporte.destino dest,
       soporte.pais pai,
       negocio."ServicioCabecera" sercab,
       seguridad.usuario usu
 WHERE snov.idestadoregistro  = 1
   AND snov.idempresa         = p_idempresa
   AND snov.idempresa         = novia.idempresa
   AND snov.idempresa         = novio.idempresa
   AND snov.idempresa         = dest.idempresa
   AND snov.idempresa         = pai.idempresa
   AND snov.idempresa         = sercab.idempresa
   AND snov.idempresa         = usu.idempresa
   AND snov.id                = COALESCE(p_id,snov.id)
   AND novia.idestadoregistro = 1
   AND novia.idtipopersona    = fn_tipopersonacliente()
   AND novia.id               = snov.idnovia
   AND snov.idnovia           = COALESCE(p_idnovia,snov.idnovia)
   AND novio.idestadoregistro = 1
   AND novio.idtipopersona    = fn_tipopersonacliente()
   AND novio.id               = snov.idnovio
   AND snov.idnovio           = COALESCE(p_idnovio,snov.idnovio)
   AND dest.idestadoregistro  = 1
   AND dest.id                = snov.iddestino
   AND pai.idestadoregistro   = 1
   AND dest.idpais            = pai.id
   AND snov.idservicio        = sercab.id
   AND sercab.idvendedor      = usu.id
   AND snov.codigonovios      = COALESCE(p_codnovios,snov.codigonovios);

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarnovios(p_idempresa integer, p_id integer, p_codnovios character varying, p_idnovia integer, p_idnovio integer) OWNER TO postgres;

--
-- TOC entry 378 (class 1255 OID 75974)
-- Name: fn_consultarobligacion(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarobligacion(p_idempresa integer, p_idobligacion integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT oxp.id, idtipocomprobante, tmtd.nombre, numerocomprobante, idproveedor as idtitular, tit.nombres, tit.apellidopaterno, tit.apellidomaterno, fechacomprobante, 
       fechapago, detallecomprobante, totaligv, totalcomprobante, saldocomprobante, tienedetraccion, 
       tieneretencion
  FROM negocio."ObligacionesXPagar" oxp
 INNER JOIN soporte."Tablamaestra" tmtd ON tmtd.idmaestro = fn_maestrotipocomprobante() AND tmtd.idempresa = p_idempresa AND tmtd.id       = oxp.idtipocomprobante
 INNER JOIN negocio."Persona" tit       ON tit.id         = oxp.idproveedor             AND tit.idempresa  = p_idempresa AND tit.idestadoregistro = 1
 WHERE oxp.id        = p_idobligacion
   AND oxp.idempresa = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarobligacion(p_idempresa integer, p_idobligacion integer) OWNER TO postgres;

--
-- TOC entry 379 (class 1255 OID 75975)
-- Name: fn_consultarobligacionespendientespago(integer, date); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarobligacionespendientespago(p_idempresa integer, p_fechahasta date) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
select id, idtipocomprobante, numerocomprobante, idproveedor, 
       negocio.fn_consultarnombrepersona(p_idempresa,idproveedor) as nombreproveedor,
       fechacomprobante, fechapago, detallecomprobante, totaligv, totalcomprobante, saldocomprobante, 
       tienedetraccion, tieneretencion, idmoneda
  from negocio."ObligacionesXPagar" op
 where op.fechapago between current_date and p_fechahasta
   and op.idempresa = p_idempresa;
 
return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarobligacionespendientespago(p_idempresa integer, p_fechahasta date) OWNER TO postgres;

--
-- TOC entry 380 (class 1255 OID 75976)
-- Name: fn_consultarobligacionxpagar(integer, integer, character varying, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarobligacionxpagar(p_idempresa integer, p_idtipocomprobante integer, p_numerocomprobante character varying, p_idproveedor integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
select oxp.id, oxp.idtipocomprobante, tm.nombre as nombrecomprobante, oxp.numerocomprobante, 
       oxp.idproveedor, pro.nombres, oxp.fechacomprobante, 
       oxp.fechapago, oxp.detallecomprobante, oxp.totaligv, oxp.totalcomprobante, oxp.saldocomprobante
  from negocio."ObligacionesXPagar" oxp,
       soporte."Tablamaestra" tm,
       negocio."Persona" pro
 where oxp.idtipocomprobante = tm.id
   and tm.idmaestro          = fn_maestrotipocomprobante()
   and oxp.idempresa         = tm.idempresa
   and pro.idestadoregistro  = 1
   and pro.idtipopersona     = fn_tipopersonaproveedor()
   and pro.id                = oxp.idproveedor
   and pro.idempresa         = oxp.idempresa
   and oxp.idempresa         = p_idempresa
   and oxp.idtipocomprobante = COALESCE(p_idtipocomprobante,oxp.idtipocomprobante)
   and oxp.numerocomprobante = COALESCE(p_numerocomprobante,oxp.numerocomprobante)
   and oxp.idproveedor       = COALESCE(p_idproveedor,oxp.idproveedor);

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarobligacionxpagar(p_idempresa integer, p_idtipocomprobante integer, p_numerocomprobante character varying, p_idproveedor integer) OWNER TO postgres;

--
-- TOC entry 381 (class 1255 OID 75977)
-- Name: fn_consultarpasajeros(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarpasajeros(p_idempresa integer, p_idserviciodetalle integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT ps.id, idtipodocumento, tmdi.nombre as nombretipodocumento, 
       numerodocumento, nombres, apellidopaterno, apellidomaterno, correoelectronico, 
       telefono1, telefono2, nropaxfrecuente, idaerolinea,
       negocio.fn_consultarnombrepersona(p_idempresa,idaerolinea) as nombreaerolina, codigoreserva, numeroboleto, fechavctopasaporte, fechanacimiento,
       idrelacion, tmre.nombre as nombrerelacion,
       idserviciodetalle, idservicio
  FROM negocio."PasajeroServicio" ps
 INNER JOIN soporte."Tablamaestra" tmre ON tmre.idmaestro = fn_maestrotiporelacion()  AND tmre.id = ps.idrelacion      AND tmre.idempresa = p_idempresa
 INNER JOIN soporte."Tablamaestra" tmdi ON tmdi.idmaestro = fn_maestrotipodocumento() AND tmdi.id = ps.idtipodocumento AND tmdi.idempresa = p_idempresa
 WHERE idserviciodetalle = p_idserviciodetalle
   AND ps.idempresa      = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarpasajeros(p_idempresa integer, p_idserviciodetalle integer) OWNER TO postgres;

--
-- TOC entry 382 (class 1255 OID 75978)
-- Name: fn_consultarpasajeroshistorico(integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarpasajeroshistorico(p_idempresa integer, p_idtipodocumento integer, p_numerodocumento character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT ps.id, idtipodocumento, numerodocumento, nombres, apellidopaterno, apellidomaterno, correoelectronico, 
       telefono1, telefono2, nropaxfrecuente, idaerolinea, codigoreserva, numeroboleto, fechavctopasaporte, fechanacimiento,
       idrelacion, idserviciodetalle, idservicio
  FROM negocio."PasajeroServicio" ps
 WHERE idtipodocumento = p_idtipodocumento
   AND numerodocumento = p_numerodocumento
   AND idempresa       = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarpasajeroshistorico(p_idempresa integer, p_idtipodocumento integer, p_numerodocumento character varying) OWNER TO postgres;

--
-- TOC entry 383 (class 1255 OID 75979)
-- Name: fn_consultarpersona(integer, integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarpersona(p_idempresa integer, p_id integer, p_idtipopersona integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT pro.id, pro.nombres, pro.apellidopaterno, pro.apellidomaterno, 
    pro.idgenero, pro.idestadocivil, pro.idtipodocumento, pro.numerodocumento, 
    pro.idusuariocreacion, pro.fechacreacion, pro.ipcreacion, ppro.idrubro, pro.fecnacimiento,
    pro.nropasaporte, pro.fecvctopasaporte
   FROM negocio."Persona" pro
   left join negocio."PersonaAdicional" ppro on ppro.idpersona = pro.id AND ppro.idestadoregistro = 1
  WHERE pro.idestadoregistro = 1 
    AND pro.idempresa        = p_idempresa
    AND pro.idtipopersona    = p_idtipopersona
    AND pro.id = p_id;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarpersona(p_idempresa integer, p_id integer, p_idtipopersona integer) OWNER TO postgres;

--
-- TOC entry 385 (class 1255 OID 75980)
-- Name: fn_consultarpersonas(integer, integer, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarpersonas(p_idempresa integer, p_idtipopersona integer, p_idtipodocumento integer, p_numerodocumento character varying, p_nombres character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT pro.id AS idproveedor, tdoc.id AS idtipodocumento, 
       tdoc.nombre AS nombretipodocumento, pro.numerodocumento, pro.nombres, 
       pro.apellidopaterno, pro.apellidomaterno, 
       dir.idvia, tvia.nombre AS nombretipovia, 
       dir.nombrevia, dir.numero, dir.interior, dir.manzana, dir.lote, 
	    ( SELECT tel.numero
		FROM negocio."TelefonoDireccion" tedir, 
		     negocio."Telefono" tel
	       WHERE tedir.idestadoregistro = 1 
		 AND tel.idestadoregistro   = 1 
		 AND tedir.iddireccion      = dir.id
		 AND tedir.idempresa        = tel.idempresa
		 AND tedir.idempresa        = p_idempresa
		 AND tedir.idtelefono       = tel.id LIMIT 1) AS teledireccion
   FROM negocio."Persona" pro
  INNER JOIN soporte."Tablamaestra" tdoc     ON tdoc.idmaestro        = fn_maestrotipodocumento() AND pro.idtipodocumento = tdoc.id        AND tdoc.idempresa = p_idempresa
   LEFT JOIN negocio."PersonaDireccion" pdir ON pdir.idestadoregistro = 1                         AND pro.id              = pdir.idpersona AND pdir.idempresa = p_idempresa
   LEFT JOIN negocio."Direccion" dir         ON dir.idestadoregistro  = 1                         AND pdir.iddireccion    = dir.id         AND dir.principal = 'S' AND dir.idempresa = p_idempresa
   LEFT JOIN soporte."Tablamaestra" tvia     ON tvia.idmaestro        = fn_maestrotipovia()       AND dir.idvia           = tvia.id        AND tvia.idempresa = p_idempresa
  WHERE pro.idestadoregistro  = 1
    AND pro.idempresa         = p_idempresa
    AND pro.idtipopersona     = COALESCE(p_idtipopersona,pro.idtipopersona)
    AND tdoc.id               = COALESCE(p_idtipodocumento,tdoc.id)
    AND pro.numerodocumento   = COALESCE(p_numerodocumento,pro.numerodocumento)
    AND CONCAT(replace(pro.nombres,' ',''),trim(pro.apellidopaterno),trim(pro.apellidomaterno)) like '%'||COALESCE(p_nombres,CONCAT(replace(pro.nombres,' ',''),trim(pro.apellidopaterno),trim(pro.apellidomaterno)))||'%';

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarpersonas(p_idempresa integer, p_idtipopersona integer, p_idtipodocumento integer, p_numerodocumento character varying, p_nombres character varying) OWNER TO postgres;

--
-- TOC entry 386 (class 1255 OID 75981)
-- Name: fn_consultarpersonas2(integer, integer, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarpersonas2(p_idempresa integer, p_idtipopersona integer, p_idtipodocumento integer, p_numerodocumento character varying, p_nombres character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT per.id, tdoc.id AS idtipodocumento, 
       tdoc.nombre AS nombretipodocumento, per.numerodocumento, per.nombres, 
       per.apellidopaterno, per.apellidomaterno, per.idgenero, 
       (case when per.idgenero='M' then 'MASCULINO'
        else 'FEMENINO' end) as genero, per.idestadocivil, estciv.nombre
   FROM soporte."Tablamaestra" tdoc
  INNER JOIN negocio."Persona" per         ON per.idtipopersona = fn_tipopersonacliente() AND per.idestadoregistro = 1 AND per.idtipodocumento = tdoc.id AND per.idempresa = p_idempresa
   LEFT JOIN soporte."Tablamaestra" estciv ON estciv.idmaestro  = fn_maestroestadocivil() AND estciv.id      = per.idestadocivil
  WHERE per.idestadoregistro  = 1 
    AND tdoc.idmaestro        = fn_maestrotipodocumento() 
    AND tdoc.id               = COALESCE(p_idtipodocumento,tdoc.id)
    AND per.numerodocumento   = COALESCE(p_numerodocumento,per.numerodocumento)
    AND CONCAT(replace(per.nombres,' ',''),trim(per.apellidopaterno),trim(per.apellidomaterno)) like '%'||COALESCE(p_nombres,CONCAT(replace(per.nombres,' ',''),trim(per.apellidopaterno),trim(per.apellidomaterno)))||'%'
  ORDER BY per.nombres, per.apellidopaterno, per.apellidomaterno ASC;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarpersonas2(p_idempresa integer, p_idtipopersona integer, p_idtipodocumento integer, p_numerodocumento character varying, p_nombres character varying) OWNER TO postgres;

--
-- TOC entry 387 (class 1255 OID 75982)
-- Name: fn_consultarproveedorservicio(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarproveedorservicio(p_idempresa integer, p_idproveedor integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT idproveedor, idtiposervicio, idproveedorservicio, porcencomnacional, porcencominternacional
  FROM negocio."ProveedorTipoServicio"
 WHERE idestadoregistro = 1
   AND idempresa        = p_idempresa
   AND idproveedor      = p_idproveedor;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarproveedorservicio(p_idempresa integer, p_idproveedor integer) OWNER TO postgres;

--
-- TOC entry 388 (class 1255 OID 75983)
-- Name: fn_consultarsaldosservicio(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarsaldosservicio(p_idempresa integer, p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT idsaldoservicio, idservicio, idpago, fechaservicio, montototalservicio, 
       montosaldoservicio
  FROM negocio."SaldosServicio"
 WHERE idempresa = p_idempresa
   AND idsaldoservicio = (SELECT max(idsaldoservicio)
                            FROM negocio."SaldosServicio" 
                           WHERE idservicio = p_idservicio
                             AND idempresa  = p_idempresa);


return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarsaldosservicio(p_idempresa integer, p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 389 (class 1255 OID 75984)
-- Name: fn_consultarservicio(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarservicio(p_idempresa integer, p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT id, nombre, desccorta, desclarga, requierefee, idmaeserfee, pagaimpto, idmaeserimpto, cargacomision, esimpuesto, esfee, idparametroasociado, visible, esserviciopadre
  FROM negocio."MaestroServicios"
 WHERE id        = p_idservicio
   AND idempresa = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarservicio(p_idempresa integer, p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 390 (class 1255 OID 75985)
-- Name: fn_consultarserviciodependientes(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarserviciodependientes(p_idempresa integer, p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT idservicio, idserviciodepende, ms.nombre, ms.visible
  FROM negocio."ServicioMaestroServicio" sms,
       negocio."MaestroServicios" ms
 WHERE sms.idestadoregistro  = 1
   AND sms.idservicio        = p_idservicio
   AND sms.idserviciodepende = ms.id
   AND sms.idempresa         = ms.idempresa
   AND sms.idempresa         = p_idempresa;
  -- AND ms.visible            = true;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarserviciodependientes(p_idempresa integer, p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 391 (class 1255 OID 75986)
-- Name: fn_consultarserviciodetallehijos(integer, integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarserviciodetallehijos(p_idempresa integer, p_idservicio integer, p_idserviciopadre integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT serdet.id as idSerdetalle, serdet.idtiposervicio, 
       tipser.id, tipser.nombre as nomtipservicio, tipser.desccorta as descservicio, tipser.requierefee, 
       tipser.pagaimpto, tipser.cargacomision, tipser.esimpuesto, tipser.esfee,
       serdet.descripcionservicio, serdet.fechaida, serdet.fecharegreso, serdet.cantidad, 
       serdet.preciobase, serdet.montototalcomision, serdet.montototal, serdet.idempresaproveedor, pro.nombres, pro.apellidopaterno, 
       pro.apellidomaterno
  FROM negocio."ServicioDetalle" serdet
 INNER JOIN negocio."MaestroServicios" tipser ON tipser.id = serdet.idtiposervicio     AND tipser.idempresa = p_idempresa AND tipser.idestadoregistro = 1
  LEFT JOIN negocio.vw_proveedoresnova pro    ON pro.id    = serdet.idempresaproveedor AND pro.idempresa    = p_idempresa
 WHERE serdet.idestadoregistro = 1
   AND serdet.idservicio       = p_idservicio
   AND serdet.idservdetdepende = p_idserviciopadre
   AND serdet.idempresa        = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarserviciodetallehijos(p_idempresa integer, p_idservicio integer, p_idserviciopadre integer) OWNER TO postgres;

--
-- TOC entry 392 (class 1255 OID 75987)
-- Name: fn_consultarserviciosinvisibles(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarserviciosinvisibles(p_idempresa integer, p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for

select sms.idserviciodepende, ms.nombre, COALESCE((select max(valor) from soporte."Parametro" par where par.id = ms.idparametroasociado),'0') as valor
  from negocio."ServicioMaestroServicio" sms
 inner join negocio."MaestroServicios" ms on sms.idserviciodepende = ms.id and ms.visible = false and ms.idempresa = p_idempresa
 where sms.idservicio = p_idservicio
   and sms.idempresa  = p_idempresa;

 return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarserviciosinvisibles(p_idempresa integer, p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 394 (class 1255 OID 75988)
-- Name: fn_consultarservicioventa(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarservicioventa(p_idempresa integer, p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
select sercab.id, sercab.idcliente1, cli1.nombres as nombres1, cli1.apellidopaterno as apellidopaterno1, cli1.apellidomaterno as apellidomaterno1, 
       sercab.idcliente2, cli2.nombres as nombres2, cli2.apellidopaterno as apellidopaterno2, cli2.apellidomaterno as apellidomaterno2, 
       sercab.fechacompra, sercab.montototal, sercab.montocomisiontotal, sercab.montototaligv, sercab.montototalfee,
       sercab.idestadopago, maeep.nombre as nomestpago, maeep.descripcion as descestpago,
       sercab.nrocuotas, sercab.tea, sercab.valorcuota, sercab.fechaprimercuota, sercab.fechaultcuota, sercab.montocomisiontotal,
       sercab.idestadoservicio, 
       (select count(1) from negocio."PagosServicio" ps where ps.idservicio = sercab.id and ps.idempresa = p_idempresa) tienepagos,
       usu.id as idusuario,
       usu.nombres as nombresvendedor, usu.apepaterno, usu.apematerno,
       sercab.idusuariocreacion, sercab.fechacreacion, sercab.ipcreacion, 
       sercab.idusuariomodificacion, sercab.fechamodificacion, sercab.ipmodificacion, sercab.generocomprobantes, sercab.guardorelacioncomprobantes, sercab.observaciones
  from negocio."ServicioCabecera" sercab 
 inner join negocio.vw_clientesnova cli1 on sercab.idcliente1 = cli1.id and cli1.idempresa  = p_idempresa
 inner join soporte."Tablamaestra" maeep on maeep.estado      = 'A'     and maeep.idempresa = p_idempresa and maeep.idmaestro = fn_maestroestadopago() and maeep.id = sercab.idestadopago
 inner join seguridad.usuario usu        on usu.id            = sercab.idvendedor and usu.idempresa = p_idempresa
  left join negocio.vw_clientesnova cli2 on sercab.idcliente2 = cli2.id and cli2.idempresa = p_idempresa
 where sercab.idestadoregistro = 1
   and (select count(1) from negocio."ServicioDetalle" det where det.idservicio = sercab.id and det.idempresa = p_idempresa) > 0
   and sercab.id               = p_idservicio
   and sercab.idempresa        = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarservicioventa(p_idempresa integer, p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 395 (class 1255 OID 75989)
-- Name: fn_consultarservicioventa(integer, integer, character varying, character varying, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarservicioventa(p_idempresa integer, p_tipodocumento integer, p_numerodocumento character varying, p_nombres character varying, p_idvendedor integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
select sercab.id, sercab.idcliente1, cli1.nombres as nombres1, cli1.apellidopaterno as apellidopaterno1, cli1.apellidomaterno as apellidomaterno1, 
       sercab.idcliente2, cli2.nombres as nombres2, cli2.apellidopaterno as apellidopaterno2, cli2.apellidomaterno as apellidomaterno2, 
       sercab.fechacompra, sercab.montototal, 
       sercab.idformapago, maemp.nombre as nommediopago, maemp.descripcion as descmediopago,
       sercab.idestadopago, maeep.nombre as nomestpago, maeep.descripcion as descestpago, sercab.idestadoservicio, maest.nombre as nomestservicio,
       sercab.nrocuotas, sercab.tea, sercab.valorcuota, sercab.fechaprimercuota, sercab.fechaultcuota,
       sercab.idusuariocreacion, sercab.fechacreacion, sercab.ipcreacion, 
       sercab.idusuariomodificacion, sercab.fechamodificacion, sercab.ipmodificacion,
       (select count(1) from negocio."ProgramaNovios" where idservicio = sercab.id) as cantidadNovios
  from negocio."ServicioCabecera" sercab 
 inner join negocio.vw_clientesnova cli1 on sercab.idcliente1 = cli1.id
 inner join soporte."Tablamaestra" maemp on maemp.estado = 'A' and maemp.idempresa = p_idempresa and maemp.idmaestro = fn_maestroformapago()      and maemp.id = sercab.idformapago
 inner join soporte."Tablamaestra" maeep on maeep.estado = 'A' and maeep.idempresa = p_idempresa and maeep.idmaestro = fn_maestroestadopago()     and maeep.id = sercab.idestadopago
 inner join soporte."Tablamaestra" maest on maest.estado = 'A' and maest.idempresa = p_idempresa and maest.idmaestro = fn_maestroestadoservicio() and maest.id = sercab.idestadoservicio
  left join negocio.vw_clientesnova cli2 on sercab.idcliente2 = cli2.id and cli2.idempresa = p_idempresa
 where sercab.idestadoregistro = 1
   and (select count(1) from negocio."ServicioDetalle" det where det.idservicio = sercab.id and det.idempresa = p_idempresa) > 0
   and sercab.idempresa        = p_idempresa
   and cli1.idtipodocumento    = COALESCE(p_tipodocumento,cli1.idtipodocumento)
   and cli1.numerodocumento    = COALESCE(p_numerodocumento,cli1.numerodocumento)
   and UPPER(CONCAT(replace(cli1.nombres,' ',''),trim(cli1.apellidopaterno),trim(cli1.apellidomaterno))) like UPPER('%'||COALESCE(p_nombres,CONCAT(trim(replace(cli1.nombres,' ','')),trim(cli1.apellidopaterno),trim(cli1.apellidomaterno)))||'%')
   and sercab.idvendedor       = COALESCE(p_idvendedor,sercab.idvendedor);
	
return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarservicioventa(p_idempresa integer, p_tipodocumento integer, p_numerodocumento character varying, p_nombres character varying, p_idvendedor integer) OWNER TO postgres;

--
-- TOC entry 396 (class 1255 OID 75990)
-- Name: fn_consultarservicioventa(integer, integer, character varying, character varying, integer, integer, date, date); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarservicioventa(p_idempresa integer, p_tipodocumento integer, p_numerodocumento character varying, p_nombres character varying, p_idvendedor integer, p_idservicio integer, p_fechadesde date, p_fechahasta date) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

if p_idservicio is not null then
open micursor for
select sercab.id, sercab.idcliente1, cli1.nombres as nombres1, cli1.apellidopaterno as apellidopaterno1, cli1.apellidomaterno as apellidomaterno1, 
       sercab.idcliente2, cli2.nombres as nombres2, cli2.apellidopaterno as apellidopaterno2, cli2.apellidomaterno as apellidomaterno2, 
       sercab.fechacompra, sercab.montototal, 
       sercab.idestadopago, maeep.nombre as nomestpago, maeep.descripcion as descestpago, sercab.idestadoservicio, maest.nombre as nomestservicio,
       sercab.nrocuotas, sercab.tea, sercab.valorcuota, sercab.fechaprimercuota, sercab.fechaultcuota,
       sercab.idusuariocreacion, sercab.fechacreacion, sercab.ipcreacion, 
       sercab.idusuariomodificacion, sercab.fechamodificacion, sercab.ipmodificacion,
       (select count(1) from negocio."ProgramaNovios" pn where pn.idservicio = sercab.id and pn.idempresa = p_idempresa) as cantidadNovios, sercab.idvendedor
  from negocio."ServicioCabecera" sercab 
 inner join negocio.vw_clientesnova cli1 on sercab.idcliente1 = cli1.id and sercab.idempresa = p_idempresa
 inner join soporte."Tablamaestra" maeep on maeep.estado      = 'A'     and maeep.idempresa  = p_idempresa and maeep.idmaestro  = fn_maestroestadopago()     and maeep.id = sercab.idestadopago
 inner join soporte."Tablamaestra" maest on maest.estado      = 'A'     and maest.idempresa  = p_idempresa and maest.idmaestro  = fn_maestroestadoservicio() and maest.id = sercab.idestadoservicio
  left join negocio.vw_clientesnova cli2 on sercab.idcliente2 = cli2.id and cli2.idempresa   = p_idempresa
 where sercab.idestadoregistro = 1
   and sercab.idempresa        = p_idempresa
   and (select count(1) from negocio."ServicioDetalle" det where det.idservicio = sercab.id and det.idempresa = p_idempresa) > 0
   and sercab.id               = COALESCE(p_idservicio,sercab.id);
else
open micursor for
select sercab.id, sercab.idcliente1, cli1.nombres as nombres1, cli1.apellidopaterno as apellidopaterno1, cli1.apellidomaterno as apellidomaterno1, 
       sercab.idcliente2, cli2.nombres as nombres2, cli2.apellidopaterno as apellidopaterno2, cli2.apellidomaterno as apellidomaterno2, 
       sercab.fechacompra, sercab.montototal, sercab.idestadopago, maeep.nombre as nomestpago, maeep.descripcion as descestpago, sercab.idestadoservicio, maest.nombre as nomestservicio,
       sercab.nrocuotas, sercab.tea, sercab.valorcuota, sercab.fechaprimercuota, sercab.fechaultcuota,
       sercab.idusuariocreacion, sercab.fechacreacion, sercab.ipcreacion, 
       sercab.idusuariomodificacion, sercab.fechamodificacion, sercab.ipmodificacion,
       (select count(1) from negocio."ProgramaNovios" pn where pn.idservicio = sercab.id and pn.idempresa = p_idempresa) as cantidadNovios, sercab.idvendedor
  from negocio."ServicioCabecera" sercab 
 inner join negocio.vw_clientesnova cli1 on sercab.idcliente1 = cli1.id
 inner join soporte."Tablamaestra" maeep on maeep.estado = 'A' and maeep.idempresa = p_idempresa and maeep.idmaestro = fn_maestroestadopago()     and maeep.id = sercab.idestadopago
 inner join soporte."Tablamaestra" maest on maest.estado = 'A' and maest.idempresa = p_idempresa and maest.idmaestro = fn_maestroestadoservicio() and maest.id = sercab.idestadoservicio
  left join negocio.vw_clientesnova cli2 on sercab.idcliente2 = cli2.id and cli2.idempresa = p_idempresa
 where sercab.idestadoregistro = 1
   and sercab.idempresa        = p_idempresa
   and sercab.fechacompra between p_fechadesde and p_fechahasta
   and (select count(1) from negocio."ServicioDetalle" det where det.idservicio = sercab.id) > 0
   and cli1.idtipodocumento    = COALESCE(p_tipodocumento,cli1.idtipodocumento)
   and cli1.numerodocumento    = COALESCE(p_numerodocumento,cli1.numerodocumento)
   and UPPER(CONCAT(replace(cli1.nombres,' ',''),trim(cli1.apellidopaterno),trim(cli1.apellidomaterno))) like UPPER('%'||COALESCE(p_nombres,CONCAT(trim(replace(cli1.nombres,' ','')),trim(cli1.apellidopaterno),trim(cli1.apellidomaterno)))||'%')
   and sercab.idvendedor       = COALESCE(p_idvendedor,sercab.idvendedor)
   and sercab.id               = COALESCE(p_idservicio,sercab.id);
end if;
	
return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarservicioventa(p_idempresa integer, p_tipodocumento integer, p_numerodocumento character varying, p_nombres character varying, p_idvendedor integer, p_idservicio integer, p_fechadesde date, p_fechahasta date) OWNER TO postgres;

--
-- TOC entry 397 (class 1255 OID 75991)
-- Name: fn_consultarservicioventadetalle(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarservicioventadetalle(p_idempresa integer, p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT serdet.id as idSerdetalle, serdet.idtiposervicio, 
       tipser.id, tipser.nombre as nomtipservicio, tipser.desccorta as descservicio, tipser.requierefee, 
       tipser.pagaimpto, tipser.cargacomision, tipser.esimpuesto, tipser.esfee,
       serdet.descripcionservicio, serdet.fechaida, serdet.fecharegreso, serdet.cantidad, 
       serdet.preciobase, serdet.montototalcomision, serdet.montototal, serdet.idempresaproveedor, pro.nombres, pro.apellidopaterno, 
       pro.apellidomaterno, tipser.visible
  FROM negocio."ServicioDetalle" serdet
 INNER JOIN negocio."MaestroServicios" tipser ON tipser.idestadoregistro = 1        AND tipser.idempresa = p_idempresa AND tipser.id = serdet.idtiposervicio
  LEFT JOIN negocio.vw_proveedoresnova pro    ON pro.id = serdet.idempresaproveedor AND pro.idempresa    = p_idempresa
 WHERE serdet.idestadoregistro = 1
   AND serdet.idempresa        = p_idempresa
   AND serdet.idservicio       = p_idservicio
   AND serdet.idservdetdepende is null;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarservicioventadetalle(p_idempresa integer, p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 398 (class 1255 OID 75992)
-- Name: fn_consultarservicioventadetallehijo(integer, integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarservicioventadetallehijo(p_idempresa integer, p_idservicio integer, p_idserdeta integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT serdet.id as idSerdetalle, serdet.idtiposervicio, 
       tipser.id, tipser.nombre as nomtipservicio, tipser.desccorta as descservicio, tipser.requierefee, 
       tipser.pagaimpto, tipser.cargacomision, tipser.esimpuesto, tipser.esfee,
       serdet.descripcionservicio, serdet.fechaida, serdet.fecharegreso, serdet.cantidad, sercab.idmoneda, tmmo.nombre as nombremoneda, tmmo.abreviatura as simbolomoneda,
       serdet.preciobase, serdet.montototalcomision, serdet.montototal, serdet.idempresaproveedor, pro.nombres, pro.apellidopaterno, 
       pro.apellidomaterno, tipser.visible
  FROM negocio."ServicioDetalle" serdet
 INNER JOIN negocio."ServicioCabecera" sercab ON sercab.id               = serdet.idservicio         AND sercab.id     = p_idservicio          AND sercab.idempresa       = p_idempresa
 INNER JOIN soporte."Tablamaestra"     tmmo   ON tmmo.idmaestro          = fn_maestrotipomoneda()    AND tmmo.id       = sercab.idmoneda       AND tmmo.idempresa         = p_idempresa
 INNER JOIN negocio."MaestroServicios" tipser ON tipser.idestadoregistro = 1                         AND tipser.id     = serdet.idtiposervicio AND tipser.esserviciopadre = false
  LEFT JOIN negocio.vw_proveedoresnova pro    ON pro.id                  = serdet.idempresaproveedor AND pro.idempresa = p_idempresa
 WHERE serdet.idestadoregistro = 1
   AND serdet.idempresa        = p_idempresa
   AND serdet.idservicio       = p_idservicio
   AND serdet.idservdetdepende = p_idserdeta;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarservicioventadetallehijo(p_idempresa integer, p_idservicio integer, p_idserdeta integer) OWNER TO postgres;

--
-- TOC entry 400 (class 1255 OID 75993)
-- Name: fn_consultarservicioventadetallepadre(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarservicioventadetallepadre(p_idempresa integer, p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT serdet.id as idSerdetalle, serdet.idtiposervicio, 
       tipser.id, tipser.nombre as nomtipservicio, tipser.desccorta as descservicio, tipser.requierefee, 
       tipser.pagaimpto, tipser.cargacomision, tipser.esimpuesto, tipser.esfee,
       serdet.descripcionservicio, serdet.fechaida, serdet.fecharegreso, serdet.cantidad, sercab.idmoneda, tmmo.nombre as nombremoneda, tmmo.abreviatura as simbolomoneda,
       serdet.preciobase, serdet.montototalcomision, serdet.montototal, serdet.idempresaproveedor, pro.nombres, pro.apellidopaterno, 
       pro.apellidomaterno, tipser.visible
  FROM negocio."ServicioDetalle" serdet
 INNER JOIN negocio."ServicioCabecera" sercab ON sercab.idempresa = serdet.idempresa AND sercab.id = p_idservicio
 INNER JOIN soporte."Tablamaestra" tmmo       ON tmmo.idempresa   = serdet.idempresa AND tmmo.idmaestro = fn_maestrotipomoneda() AND tmmo.id = sercab.idmoneda
 INNER JOIN negocio."MaestroServicios" tipser ON tipser.idempresa = serdet.idempresa AND tipser.idestadoregistro = 1 AND tipser.id = serdet.idtiposervicio AND tipser.esserviciopadre = true
  LEFT JOIN negocio.vw_proveedoresnova pro    ON pro.idempresa    = serdet.idempresa AND pro.id = serdet.idempresaproveedor
 WHERE serdet.idestadoregistro = 1
   AND serdet.idempresa        = p_idempresa
   AND serdet.idservicio       = p_idservicio
   AND serdet.idservdetdepende is null;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarservicioventadetallepadre(p_idempresa integer, p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 401 (class 1255 OID 75994)
-- Name: fn_consultarservicioventajr(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarservicioventajr(p_idempresa integer, p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
select cantidad, descripcionservicio, fechaida, 
       fecharegreso, idmoneda, abreviatura, preciobase, montototal, 
       idservicio 
  from negocio.vw_servicio_detalle 
 where idservicio = p_idservicio
   and idempresa  = p_idempresa;


return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarservicioventajr(p_idempresa integer, p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 402 (class 1255 OID 75995)
-- Name: fn_consultartipocambio(integer, integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultartipocambio(p_idempresa integer, p_idmonedaorigen integer, p_idmonedadestino integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare fechahoy date;
declare v_cantidad integer;
declare v_idultimo integer;
declare v_idtipocambio integer;
declare v_mensaje character varying(100);
declare micursor refcursor;

begin

select current_date into fechahoy;

select count(1)
  into v_cantidad
  from negocio."TipoCambio"
 where fechatipocambio = fechahoy
   and idempresa       = p_idempresa
   and idmonedaorigen  = p_idmonedaorigen
   and idmonedadestino = p_idmonedadestino;

if v_cantidad = 1 then
    select id
      into v_idtipocambio
      from negocio."TipoCambio"
     where fechatipocambio = fechahoy
       and idempresa       = p_idempresa
       and idmonedaorigen  = p_idmonedaorigen
       and idmonedadestino = p_idmonedadestino;
elsif v_cantidad > 1 then
    select max(id)
      into v_idtipocambio
      from negocio."TipoCambio"
     where fechatipocambio = fechahoy
       and idempresa       = p_idempresa
       and idmonedaorigen  = p_idmonedaorigen
       and idmonedadestino = p_idmonedadestino;
else
    select count(1)
      into v_cantidad
      from negocio."TipoCambio"
     where idempresa       = p_idempresa
       and idmonedaorigen  = p_idmonedaorigen
       and idmonedadestino = p_idmonedadestino;

    if v_cantidad >= 1 then
        select max(id)
          into v_idtipocambio
	  from negocio."TipoCambio"
	 where idempresa       = p_idempresa
	   and idmonedaorigen  = p_idmonedaorigen
	   and idmonedadestino = p_idmonedadestino;
    else
        v_mensaje = 'Tipo de cambio de '||(select nombre
                                            from soporte."Tablamaestra" 
                                           where idempresa = p_idempresa
                                             and idmaestro = fn_maestrotipomoneda()
                                             and id        = p_idmonedaorigen);
        v_mensaje = v_mensaje || ' a ' || (select nombre
                                           from soporte."Tablamaestra" 
                                          where idempresa = p_idempresa
                                            and idmaestro = fn_maestrotipomoneda()
                                            and id        = p_idmonedadestino);

        v_mensaje = v_mensaje || ' no fue registrado';
        
        RAISE USING MESSAGE = v_mensaje;
    end if;
end if;

open micursor for
SELECT tc.id, fechatipocambio, 
       idmonedaorigen, tmmo.nombre as nombreMonOrigen, 
       idmonedadestino, tmmd.nombre as nombreMonDestino, 
       montocambio
  FROM negocio."TipoCambio" tc
 INNER JOIN soporte."Tablamaestra" tmmo ON tmmo.idmaestro = fn_maestrotipomoneda() AND tmmo.id = idmonedaorigen  AND tmmo.idempresa = p_idempresa
 INNER JOIN soporte."Tablamaestra" tmmd ON tmmd.idmaestro = fn_maestrotipomoneda() AND tmmd.id = idmonedadestino AND tmmo.idempresa = p_idempresa
 WHERE tc.id        = v_idtipocambio
   AND tc.idempresa = p_idempresa;

 return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultartipocambio(p_idempresa integer, p_idmonedaorigen integer, p_idmonedadestino integer) OWNER TO postgres;

--
-- TOC entry 403 (class 1255 OID 75996)
-- Name: fn_consultartipocambiomonto(integer, integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultartipocambiomonto(p_idempresa integer, p_idmonedaorigen integer, p_idmonedadestino integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$

declare fechahoy date;
declare v_cantidad integer;
declare v_idtipocambio integer;
declare v_mensaje character varying(15);
declare v_tipocambio decimal(9,6);

begin

select current_date into fechahoy;

select count(1)
  into v_cantidad
  from negocio."TipoCambio"
 where fechatipocambio = fechahoy
   and idempresa       = p_idempresa
   and idmonedaorigen  = p_idmonedaorigen
   and idmonedadestino = p_idmonedadestino;

if v_cantidad = 1 then
    select id
      into v_idtipocambio
      from negocio."TipoCambio"
     where fechatipocambio = fechahoy
       and idempresa       = p_idempresa
       and idmonedaorigen  = p_idmonedaorigen
       and idmonedadestino = p_idmonedadestino;
elsif v_cantidad > 1 then
    select max(id)
      into v_idtipocambio
      from negocio."TipoCambio"
     where fechatipocambio = fechahoy
       and idempresa       = p_idempresa
       and idmonedaorigen  = p_idmonedaorigen
       and idmonedadestino = p_idmonedadestino;
else
    select count(1)
      into v_cantidad
      from negocio."TipoCambio"
     where idempresa       = p_idempresa
       and idmonedaorigen  = p_idmonedaorigen
       and idmonedadestino = p_idmonedadestino;

    if v_cantidad >= 1 then
        select max(id)
          into v_idtipocambio
	  from negocio."TipoCambio"
	 where idempresa       = p_idempresa
	   and idmonedaorigen  = p_idmonedaorigen
	   and idmonedadestino = p_idmonedadestino;
    else
        v_mensaje = 'Tipo de cambio de '+(select nombre
                                            from soporte."Tablamaestra" 
                                           where idempresa = p_idempresa
                                             and idmaestro = fn_maestrotipomoneda()
                                             and id        = p_idmonedaorigen);
        v_mensaje = v_mensaje + ' a ' + (select nombre
                                           from soporte."Tablamaestra" 
                                          where idempresa = p_idempresa
                                            and idmaestro = fn_maestrotipomoneda()
                                            and id        = p_idmonedadestino);

        v_mensaje = v_mensaje + ' no fue registrado';
        
        RAISE USING MESSAGE = v_mensaje;
    end if;
end if;

SELECT montocambio
  INTO v_tipocambio
  FROM negocio."TipoCambio"
 WHERE id        = v_idtipocambio
   and idempresa = p_idempresa;

return v_tipocambio;

end;
$$;


ALTER FUNCTION negocio.fn_consultartipocambiomonto(p_idempresa integer, p_idmonedaorigen integer, p_idmonedadestino integer) OWNER TO postgres;

--
-- TOC entry 404 (class 1255 OID 75997)
-- Name: fn_consultartramosruta(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultartramosruta(p_idempresa integer, p_idruta integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT tramo.id as idtramo, tramo.descripcionorigen, tramo.fechasalida, tramo.descripciondestino, tramo.fechallegada, tramo.preciobase, per.nombres
  FROM negocio."RutaServicio" ruta
 INNER JOIN negocio."Tramo" tramo ON ruta.idtramo          = tramo.id AND tramo.idempresa   = p_idempresa
 INNER JOIN negocio."Persona" per ON per.idestadoregistro  = 1        AND tramo.idaerolinea = per.id      AND per.idempresa = p_idempresa
 WHERE ruta.idestadoregistro = 1
   AND ruta.id               = p_idruta
   AND ruta.idempresa        = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultartramosruta(p_idempresa integer, p_idruta integer) OWNER TO postgres;

--
-- TOC entry 405 (class 1255 OID 75998)
-- Name: fn_correosxpersona(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_correosxpersona(p_idempresa integer, p_idpersona integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT id, correo, idpersona, usuariocreacion, fechacreacion, ipcreacion, 
       usuariomodificacion, fechamodificacion, ipmodificacion, idestadoregistro
  FROM negocio."CorreoElectronico"
 WHERE idestadoregistro = 1
   AND idpersona        = p_idpersona
   AND idempresa        = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_correosxpersona(p_idempresa integer, p_idpersona integer) OWNER TO postgres;

--
-- TOC entry 406 (class 1255 OID 75999)
-- Name: fn_direccionesxpersona(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_direccionesxpersona(p_idempresa integer, p_idpersona integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT dir.id, dir.idvia, dir.nombrevia, dir.numero, dir.interior, dir.manzana, 
       dir.lote, dir.principal, dir.idubigeo, dep.iddepartamento, 
       dep.descripcion AS departamento, pro.idprovincia, 
       pro.descripcion AS provincia, dis.iddistrito, dis.descripcion AS distrito, 
       pdir.idpersona, dir.observacion, dir.referencia
  FROM negocio."Direccion" dir, 
       negocio."PersonaDireccion" pdir, 
       soporte.ubigeo dep, 
       soporte.ubigeo pro, 
       soporte.ubigeo dis
 WHERE dir.idestadoregistro                  =  1 
   AND pdir.idestadoregistro                 =  1 
   AND dir.id                                =  pdir.iddireccion
   AND dir.idempresa                         =  pdir.idempresa
   AND substring(dir.idubigeo, 1, 2)||'0000' =  dep.id
   AND dep.iddepartamento                    <> '00'
   AND dep.idprovincia                       =  '00'
   AND dep.iddistrito                        =  '00'
   AND dep.idempresa                         =  dir.idempresa
   AND substring(dir.idubigeo, 1, 4)||'00'   =  pro.id
   AND pro.iddepartamento                    <> '00'
   AND pro.idprovincia                       <> '00'
   AND pro.iddistrito                        =  '00'
   AND pro.idempresa                         = dir.idempresa
   AND dis.id::bpchar                        = dir.idubigeo
   AND pdir.idempresa                        = p_idempresa
   AND dir.idempresa                         = p_idempresa
   AND pdir.idpersona                        = p_idpersona;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_direccionesxpersona(p_idempresa integer, p_idpersona integer) OWNER TO postgres;

--
-- TOC entry 399 (class 1255 OID 76000)
-- Name: fn_eliminarcontactoproveedor(integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminarcontactoproveedor(p_idempresa integer, p_idpersona integer, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."Persona"
   SET idestadoregistro      = 0,
       idusuariomodificacion = p_usuariomodificacion, 
       fechamodificacion     = fechahoy, 
       ipmodificacion        = p_ipmodificacion
 WHERE idestadoregistro      = 1
   AND idempresa             = p_idempresa
   AND id                    in (select idcontacto
                                   from negocio."PersonaContactoProveedor"
                                  where idestadoregistro = 1
                                    and idproveedor      = p_idpersona
                                    and idempresa        = p_idempresa);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminarcontactoproveedor(p_idempresa integer, p_idpersona integer, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 350 (class 1255 OID 76001)
-- Name: fn_eliminarcorreoscontacto(integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminarcorreoscontacto(p_idempresa integer, p_idpersona integer, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."CorreoElectronico"
   SET idestadoregistro      = 0, 
       idusuariomodificacion = p_usuariomodificacion, 
       fechamodificacion     = fechahoy, 
       ipmodificacion        = p_ipmodificacion
 WHERE idestadoregistro      = 1
   AND idempresa             = p_idempresa
   AND idpersona             = p_idpersona;

return p_idpersona;

end;
$$;


ALTER FUNCTION negocio.fn_eliminarcorreoscontacto(p_idempresa integer, p_idpersona integer, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 364 (class 1255 OID 76002)
-- Name: fn_eliminarcronogramaservicio(integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminarcronogramaservicio(p_idservicio integer, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."CronogramaPago"
   SET idestadoregistro      = 0,
       idusuariomodificacion = p_usuariomodificacion, 
       fechamodificacion     = fechahoy, 
       ipmodificacion        = p_ipmodificacion
 WHERE idservicio            = p_idservicio;
 
return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminarcronogramaservicio(p_idservicio integer, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 375 (class 1255 OID 76003)
-- Name: fn_eliminarcronogramaservicio(integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminarcronogramaservicio(p_idempresa integer, p_idservicio integer, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."CronogramaPago"
   SET idestadoregistro      = 0,
       idusuariomodificacion = p_usuariomodificacion, 
       fechamodificacion     = fechahoy, 
       ipmodificacion        = p_ipmodificacion
 WHERE idservicio            = p_idservicio
   AND idempresa             = p_idempresa;
 
return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminarcronogramaservicio(p_idempresa integer, p_idservicio integer, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 384 (class 1255 OID 76004)
-- Name: fn_eliminarcuentasproveedor(integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminarcuentasproveedor(p_idempresa integer, p_idproveedor integer, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."ProveedorCuentaBancaria"
   SET idestadoregistro      = 0,
       idusuariomodificacion = p_usuariomodificacion, 
       fechamodificacion     = fechahoy, 
       ipmodificacion        = p_ipmodificacion
 WHERE idestadoregistro      = 1
   AND idempresa             = p_idempresa
   AND idproveedor           = p_idproveedor;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminarcuentasproveedor(p_idempresa integer, p_idproveedor integer, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 393 (class 1255 OID 76005)
-- Name: fn_eliminardetalleservicio(integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminardetalleservicio(p_idempresa integer, p_idservicio integer, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."ServicioDetalle"
   SET idestadoregistro      = 0,
       idusuariomodificacion = p_usuariomodificacion, 
       fechamodificacion     = fechahoy, 
       ipmodificacion        = p_ipmodificacion
 WHERE idservicio            = p_idservicio
   AND idempresa             = p_idempresa;
 
return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminardetalleservicio(p_idempresa integer, p_idservicio integer, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 409 (class 1255 OID 76006)
-- Name: fn_eliminardirecciones(integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminardirecciones(p_idempresa integer, p_idpersona integer, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE 
  negocio."Direccion" 
SET 
  idestadoregistro      = 0,
  idusuariomodificacion = p_usuariomodificacion,
  fechamodificacion     = fechahoy,
  ipmodificacion        = p_ipmodificacion
WHERE idestadoregistro  = 1
  AND idempresa         = p_idempresa
  AND id                IN (SELECT iddireccion 
                              FROM negocio."PersonaDireccion"
                             WHERE idpersona        = p_idpersona
                               AND idestadoregistro = 1
                               AND idempresa        = p_idempresa);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminardirecciones(p_idempresa integer, p_idpersona integer, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 410 (class 1255 OID 76007)
-- Name: fn_eliminardocumentosustentoservicio(integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminardocumentosustentoservicio(p_idempresa integer, p_idservicio integer, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."DocumentoAdjuntoServicio"
   SET idestadoregistro      = 0,
       idusuariomodificacion = p_usuariomodificacion,
       fechamodificacion     = fechahoy,
       ipmodificacion        = p_ipmodificacion
 WHERE idservicio            = p_idservicio
   AND idempresa             = p_idempresa;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminardocumentosustentoservicio(p_idempresa integer, p_idservicio integer, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 411 (class 1255 OID 76008)
-- Name: fn_eliminarinvitadosnovios(integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminarinvitadosnovios(p_idempresa integer, p_idnovios integer, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."Personapotencial"
   SET idusuariomodificacion = p_usuariomodificacion, 
       fechamodificacion     = fechahoy, 
       ipmodificacion        = p_ipmodificacion, 
       idestadoregistro      = 0
 WHERE idnovios              = p_idnovios
   AND idempresa             = p_idempresa;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminarinvitadosnovios(p_idempresa integer, p_idnovios integer, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 412 (class 1255 OID 76009)
-- Name: fn_eliminarpersona(integer, integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminarpersona(p_idempresa integer, p_idpersona integer, p_idtipopersona integer, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."Persona"
   SET idestadoregistro      = 0,
       idusuariomodificacion = p_usuariomodificacion, 
       fechamodificacion     = fechahoy, 
       ipmodificacion        = p_ipmodificacion
 WHERE idestadoregistro      = 1
   AND id                    = p_idpersona
   AND idempresa             = p_idempresa
   AND idtipopersona         = p_idtipopersona;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminarpersona(p_idempresa integer, p_idpersona integer, p_idtipopersona integer, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 413 (class 1255 OID 76010)
-- Name: fn_eliminarpersonadirecciones(integer, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminarpersonadirecciones(p_idempresa integer, p_idpersona integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE 
  negocio."PersonaDireccion"
SET 
  idestadoregistro     = 0
WHERE idestadoregistro = 1
  AND idempresa        = p_idempresa
  AND idpersona        = p_idpersona;

return false;

end;
$$;


ALTER FUNCTION negocio.fn_eliminarpersonadirecciones(p_idempresa integer, p_idpersona integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 414 (class 1255 OID 76011)
-- Name: fn_eliminarpersonadirecciones(integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminarpersonadirecciones(p_idempresa integer, p_idpersona integer, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE 
  negocio."PersonaDireccion"
SET 
  idestadoregistro      = 0,
  idusuariomodificacion = p_usuariomodificacion,
  fechamodificacion     = fechahoy,
  ipmodificacion        = p_ipmodificacion
WHERE idestadoregistro  = 1
  AND idempresa         = p_idempresa
  AND idpersona         = p_idpersona;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminarpersonadirecciones(p_idempresa integer, p_idpersona integer, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 415 (class 1255 OID 76012)
-- Name: fn_eliminarproveedorservicio(integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminarproveedorservicio(p_idempresa integer, p_idpersona integer, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."ProveedorTipoServicio"
   SET idestadoregistro      = 0,
       idusuariomodificacion = p_usuariomodificacion,
       fechamodificacion     = fechahoy,
       ipmodificacion        = p_ipmodificacion
 WHERE idproveedor           = p_idpersona
   AND idempresa             = p_idempresa;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminarproveedorservicio(p_idempresa integer, p_idpersona integer, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 416 (class 1255 OID 76013)
-- Name: fn_eliminartelefonoscontacto(integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminartelefonoscontacto(p_idempresa integer, p_idcontacto integer, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE 
  negocio."Telefono" 
SET
  idestadoregistro      = 0,
  idusuariomodificacion = p_usuariomodificacion,
  fechamodificacion     = fechahoy,
  ipmodificacion        = p_ipmodificacion
WHERE idestadoregistro  = 1
  AND idempresa         = p_idempresa
  AND id                IN (SELECT idtelefono
                              FROM negocio."TelefonoPersona"
                             WHERE idpersona        = p_idcontacto
                               AND idestadoregistro = 1
                               AND idempresa        = p_idempresa);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminartelefonoscontacto(p_idempresa integer, p_idcontacto integer, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 417 (class 1255 OID 76014)
-- Name: fn_eliminartelefonosdireccion(integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminartelefonosdireccion(p_idempresa integer, p_iddireccion integer, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE 
  negocio."Telefono" 
SET 
  idestadoregistro      = 0,
  idusuariomodificacion = p_usuariomodificacion,
  fechamodificacion     = fechahoy,
  ipmodificacion        = p_ipmodificacion
WHERE idestadoregistro  = 1
  AND idempresa         = p_idempresa
  AND id                IN (SELECT idtelefono
                              FROM negocio."TelefonoDireccion"
                             WHERE iddireccion      = p_iddireccion
                               AND idestadoregistro = 1
                               AND idempresa        = p_idempresa);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminartelefonosdireccion(p_idempresa integer, p_iddireccion integer, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 418 (class 1255 OID 76015)
-- Name: fn_generaimparchivocargado(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_generaimparchivocargado(p_idempresa integer, p_id integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT p.nombres, p.apellidopaterno, p.apellidomaterno, sd.numeroboleto
  FROM negocio."DetalleArchivoCargado" dac
 INNER JOIN negocio."ServicioDetalle" sd  ON sd.codigoreserva = dac.campo1    AND sd.idempresa     = p_idempresa
 INNER JOIN negocio."ServicioCabecera" sc ON sc.id            = sd.idservicio AND sc.idempresa     = p_idempresa
 INNER JOIN negocio."Persona" p           ON sc.idcliente1    = p.id          AND p.idempresa      = p_idempresa AND p.idtipopersona  = 1
 WHERE idarchivo = p_id
   AND idempresa = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_generaimparchivocargado(p_idempresa integer, p_id integer) OWNER TO postgres;

--
-- TOC entry 419 (class 1255 OID 76016)
-- Name: fn_generarcodigonovio(integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_generarcodigonovio(p_idempresa integer, p_codigosnovios integer, p_usuario character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$

declare cod_novio character varying(20);
declare fechaserie character varying(4);

Begin


select to_char(fecnacimiento,'ddMM')
  into fechaserie
  from seguridad.usuario
 where usuario   = p_usuario
   and idempresa = p_idempresa;

cod_novio = fechaserie || p_codigosnovios;

return cod_novio;

end;
$$;


ALTER FUNCTION negocio.fn_generarcodigonovio(p_idempresa integer, p_codigosnovios integer, p_usuario character varying) OWNER TO postgres;

--
-- TOC entry 420 (class 1255 OID 76017)
-- Name: fn_generarcronogramapago(integer, date, numeric, numeric, numeric, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_generarcronogramapago(p_idservicio integer, p_fechaprimervencimiento date, p_montototal numeric, p_tea numeric, p_nrocuotas numeric, p_usuariocrecion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare nrocuota integer = 1;
declare valorcuota decimal = 0;
declare capital decimal = 0;
declare interes decimal = 0;
declare fecvencimiento date = p_fechaprimervencimiento;
declare tasamensual decimal = 0;
declare saldo decimal = p_montototal;


Begin

select negocio.fn_calcularcuota(p_montototal,p_nrocuotas,p_tea) into valorcuota;
select negocio.fn_calculartem(p_tea) into tasamensual;

LOOP

    interes = saldo * tasamensual;
    capital = valorcuota - interes;

    PERFORM negocio.fn_ingresarcuotacronograma(
    nrocuota,
    p_idservicio,
    fecvencimiento,
    capital,
    interes,
    valorcuota,
    1,
    p_usuariocrecion,
    p_ipcreacion);

    nrocuota = nrocuota + 1;
    fecvencimiento = (fecvencimiento + (1 || ' month')::INTERVAL);
    saldo = saldo - capital;
    
    EXIT WHEN cast(nrocuota as decimal) > p_nrocuotas;  
END LOOP;

update negocio."ServicioCabecera" set fechaultcuota = fecvencimiento where id = p_idservicio;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_generarcronogramapago(p_idservicio integer, p_fechaprimervencimiento date, p_montototal numeric, p_tea numeric, p_nrocuotas numeric, p_usuariocrecion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 421 (class 1255 OID 76018)
-- Name: fn_ingresainvitado(integer, character varying, character varying, character varying, date, character varying, character varying, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresainvitado(p_idempresa integer, p_nombres character varying, p_apellidopaterno character varying, p_apellidomaterno character varying, p_fecnacimiento date, p_telefono character varying, p_correoelectronico character varying, p_idnovios integer, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_personapotencial');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."Personapotencial"(
            id, nombres, apellidopaterno, apellidomaterno, 
            fecnacimiento, telefono, correoelectronico, idnovios, idusuariocreacion, 
            fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, 
            ipmodificacion, idempresa)
    VALUES (maxid, p_nombres, p_apellidopaterno, p_apellidomaterno, 
            p_fecnacimiento, p_telefono, p_correoelectronico, p_idnovios, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, 
            p_ipcreacion, p_idempresa);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresainvitado(p_idempresa integer, p_nombres character varying, p_apellidopaterno character varying, p_apellidomaterno character varying, p_fecnacimiento date, p_telefono character varying, p_correoelectronico character varying, p_idnovios integer, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 422 (class 1255 OID 76019)
-- Name: fn_ingresararchivocargado(character varying, character varying, integer, integer, integer, integer, numeric, numeric, numeric, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresararchivocargado(p_nombrearchivo character varying, p_nombrereporte character varying, p_idproveedor integer, p_numerofilas integer, p_numerocolumnas integer, p_idmoneda integer, p_montosubtotal numeric, p_montoigv numeric, p_montototal numeric, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_archivocargado');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ArchivoCargado"(
            id, nombrearchivo, nombrereporte, idproveedor, numerofilas, numerocolumnas, idmoneda, montosubtotal, montoigv, montototal, idusuariocreacion, fechacreacion, 
            ipcreacion, idusuariomodificacion, fechamodificacion, ipmodificacion)
    VALUES (maxid, p_nombrearchivo, p_nombrereporte, p_idproveedor, p_numerofilas, p_numerocolumnas, p_idmoneda, p_montosubtotal, p_montoIGV, p_montototal, p_usuariocreacion, 
	    fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_ingresararchivocargado(p_nombrearchivo character varying, p_nombrereporte character varying, p_idproveedor integer, p_numerofilas integer, p_numerocolumnas integer, p_idmoneda integer, p_montosubtotal numeric, p_montoigv numeric, p_montototal numeric, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 423 (class 1255 OID 76020)
-- Name: fn_ingresararchivocargado(integer, character varying, character varying, integer, integer, integer, integer, numeric, numeric, numeric, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresararchivocargado(p_idempresa integer, p_nombrearchivo character varying, p_nombrereporte character varying, p_idproveedor integer, p_numerofilas integer, p_numerocolumnas integer, p_idmoneda integer, p_montosubtotal numeric, p_montoigv numeric, p_montototal numeric, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_archivocargado');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ArchivoCargado"(
            id, nombrearchivo, nombrereporte, idproveedor, numerofilas, numerocolumnas, idmoneda, montosubtotal, montoigv, montototal, idusuariocreacion, fechacreacion, 
            ipcreacion, idusuariomodificacion, fechamodificacion, ipmodificacion, idempresa)
    VALUES (maxid, p_nombrearchivo, p_nombrereporte, p_idproveedor, p_numerofilas, p_numerocolumnas, p_idmoneda, p_montosubtotal, p_montoIGV, p_montototal, p_usuariocreacion, 
	    fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_ingresararchivocargado(p_idempresa integer, p_nombrearchivo character varying, p_nombrereporte character varying, p_idproveedor integer, p_numerofilas integer, p_numerocolumnas integer, p_idmoneda integer, p_montosubtotal numeric, p_montoigv numeric, p_montototal numeric, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 424 (class 1255 OID 76021)
-- Name: fn_ingresarcomprobanteadicional(integer, integer, integer, character varying, integer, character varying, date, numeric, numeric, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarcomprobanteadicional(p_idempresa integer, p_idservicio integer, p_idtipocomprobante integer, p_numerocomprobante character varying, p_idtitular integer, p_detallecomprobante character varying, p_fechacomprobante date, p_totaligv numeric, p_totalcomprobante numeric, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;
declare cantidad integer;


Begin

select count(1)
  into cantidad
  from negocio."ComprobanteAdicional"
 where numerocomprobante = p_numerocomprobante
   and idempresa         = p_idempresa;

if cantidad > 0 then
   raise USING MESSAGE = 'El número de comprobante ya se encuentra registrado';
end if;

maxid = nextval('negocio.seq_comprobanteadicional');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ComprobanteAdicional"(
            id, idservicio, idtipocomprobante, numerocomprobante, idtitular, 
            detallecomprobante, fechacomprobante, totaligv, totalcomprobante, 
            idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, 
            fechamodificacion, ipmodificacion, idempresa)
    VALUES (maxid, p_idservicio, p_idtipocomprobante, p_numerocomprobante, p_idtitular, p_detallecomprobante, 
            p_fechacomprobante, p_totaligv, p_totalcomprobante, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, 
            p_ipcreacion, p_idempresa);

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarcomprobanteadicional(p_idempresa integer, p_idservicio integer, p_idtipocomprobante integer, p_numerocomprobante character varying, p_idtitular integer, p_detallecomprobante character varying, p_fechacomprobante date, p_totaligv numeric, p_totalcomprobante numeric, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 427 (class 1255 OID 76022)
-- Name: fn_ingresarcomprobantegenerado(integer, integer, integer, character varying, integer, date, numeric, numeric, boolean, boolean, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarcomprobantegenerado(p_idempresa integer, p_idservicio integer, p_idtipocomprobante integer, p_numerocomprobante character varying, p_idtitular integer, p_fechacomprobante date, p_totaligv numeric, p_totalcomprobante numeric, p_tienedetraccion boolean, p_tieneretencion boolean, p_idmoneda integer, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;
declare cantidad integer;


Begin

select count(1)
  into cantidad
  from negocio."ComprobanteGenerado"
 where numerocomprobante = p_numerocomprobante
   and idempresa         = p_idempresa;

if cantidad > 0 then
   raise USING MESSAGE = 'El número de comprobante ya se encuentra registrado';
end if;

maxid = nextval('negocio.seq_comprobantegenerado');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ComprobanteGenerado"(
            id, idservicio, idtipocomprobante, numerocomprobante, idtitular, fechacomprobante, idmoneda,
            totaligv, totalcomprobante, tienedetraccion, tieneretencion, idusuariocreacion, fechacreacion, ipcreacion, 
            idusuariomodificacion, fechamodificacion, ipmodificacion, idempresa)
    VALUES (maxid, p_idservicio, p_idtipocomprobante, p_numerocomprobante, p_idtitular, p_fechacomprobante, p_idmoneda,
            p_totaligv, p_totalcomprobante, p_tienedetraccion, p_tieneretencion, p_usuariocreacion, fechahoy, p_ipcreacion, 
            p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarcomprobantegenerado(p_idempresa integer, p_idservicio integer, p_idtipocomprobante integer, p_numerocomprobante character varying, p_idtitular integer, p_fechacomprobante date, p_totaligv numeric, p_totalcomprobante numeric, p_tienedetraccion boolean, p_tieneretencion boolean, p_idmoneda integer, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 428 (class 1255 OID 76023)
-- Name: fn_ingresarconsolidador(character varying, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarconsolidador(p_nombre character varying, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

Begin

maxid = nextval('negocio.seq_consolidador');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."Consolidador"(
            id, nombre, usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
            fechamodificacion, ipmodificacion)
    VALUES (maxid, p_nombre, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);


return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarconsolidador(p_nombre character varying, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 429 (class 1255 OID 76024)
-- Name: fn_ingresarcontactoproveedor(integer, integer, integer, integer, character varying, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarcontactoproveedor(p_idempresa integer, p_idproveedor integer, p_idcontacto integer, p_idarea integer, p_anexo character varying, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."PersonaContactoProveedor"(
            idproveedor, idcontacto, idarea, anexo, idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, ipmodificacion, idempresa)
    VALUES (p_idproveedor, p_idcontacto, p_idarea, p_anexo, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarcontactoproveedor(p_idempresa integer, p_idproveedor integer, p_idcontacto integer, p_idarea integer, p_anexo character varying, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 430 (class 1255 OID 76025)
-- Name: fn_ingresarcorreoelectronico(integer, character varying, integer, boolean, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarcorreoelectronico(p_idempresa integer, p_correo character varying, p_idpersona integer, p_recibirpromociones boolean, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxcorreo integer = 0;
declare fechahoy timestamp with time zone;

begin

maxcorreo = nextval('negocio.seq_correoelectronico');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."CorreoElectronico"(
            id, correo, idpersona, recibirpromociones, idusuariocreacion, fechacreacion, ipcreacion, 
            idusuariomodificacion, fechamodificacion, ipmodificacion, idempresa)
    VALUES (maxcorreo, p_correo, p_idpersona, p_recibirpromociones, p_usuariocreacion, fechahoy, p_ipcreacion, 
            p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

return maxcorreo;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarcorreoelectronico(p_idempresa integer, p_correo character varying, p_idpersona integer, p_recibirpromociones boolean, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 431 (class 1255 OID 76026)
-- Name: fn_ingresarcuentabancariaproveedor(integer, character varying, character varying, integer, integer, integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarcuentabancariaproveedor(p_idempresa integer, p_nombrecuenta character varying, p_numerocuenta character varying, p_idtipocuenta integer, p_idbanco integer, p_idmoneda integer, p_idproveedor integer, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;
declare maxid integer;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;
maxid = nextval('negocio.seq_cuentabancariaproveedor');

INSERT INTO negocio."ProveedorCuentaBancaria"(
            id, nombrecuenta, numerocuenta, idtipocuenta, idbanco, idmoneda, 
            idproveedor, idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, 
            fechamodificacion, ipmodificacion, idempresa)
    VALUES (maxid, p_nombrecuenta, p_numerocuenta, p_idtipocuenta, p_idbanco, p_idmoneda, 
            p_idproveedor, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarcuentabancariaproveedor(p_idempresa integer, p_nombrecuenta character varying, p_numerocuenta character varying, p_idtipocuenta integer, p_idbanco integer, p_idmoneda integer, p_idproveedor integer, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 432 (class 1255 OID 76027)
-- Name: fn_ingresarcuotacronograma(integer, integer, integer, date, double precision, double precision, double precision, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarcuotacronograma(p_idempresa integer, p_nrocuota integer, p_idservicio integer, p_fechavencimiento date, p_capital double precision, p_interes double precision, p_totalcuota double precision, p_idestadocuota integer, p_usuariocrecion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."CronogramaPago"(
            nrocuota, idservicio, fechavencimiento, capital, interes, totalcuota, 
            idestadocuota, idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, 
            fechamodificacion, ipmodificacion, idempresa)
    VALUES (p_nrocuota, p_idservicio, p_fechavencimiento, p_capital, p_interes, p_totalcuota, 
            p_idestadocuota, p_usuariocrecion, fechahoy, p_ipcreacion, p_usuariocrecion, 
            fechahoy, p_ipcreacion, p_idempresa);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarcuotacronograma(p_idempresa integer, p_nrocuota integer, p_idservicio integer, p_fechavencimiento date, p_capital double precision, p_interes double precision, p_totalcuota double precision, p_idestadocuota integer, p_usuariocrecion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 435 (class 1255 OID 76028)
-- Name: fn_ingresardetallearchivocargado(integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, boolean, integer, character varying, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresardetallearchivocargado(p_idempresa integer, p_idarchivo integer, p_campo1 character varying, p_campo2 character varying, p_campo3 character varying, p_campo4 character varying, p_campo5 character varying, p_campo6 character varying, p_campo7 character varying, p_campo8 character varying, p_campo9 character varying, p_campo10 character varying, p_campo11 character varying, p_campo12 character varying, p_campo13 character varying, p_campo14 character varying, p_campo15 character varying, p_campo16 character varying, p_campo17 character varying, p_campo18 character varying, p_campo19 character varying, p_campo20 character varying, p_seleccionado boolean, p_idtipocomprobante integer, p_numerocomprobante character varying, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_detallearchivocargado');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."DetalleArchivoCargado"(
            id, idarchivo, campo1, campo2, campo3, campo4, campo5, campo6, 
            campo7, campo8, campo9, campo10, campo11, campo12, campo13, campo14, 
            campo15, campo16, campo17, campo18, campo19, campo20, seleccionado, idtipocomprobante, numerocomprobante,
            idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, 
            fechamodificacion, ipmodificacion, idempresa)
    VALUES (maxid, p_idarchivo, p_campo1, p_campo2, p_campo3, p_campo4, p_campo5, p_campo6, 
            p_campo7, p_campo8, p_campo9, p_campo10, p_campo11, p_campo12, p_campo13, p_campo14, 
            p_campo15, p_campo16, p_campo17, p_campo18, p_campo19, p_campo20, p_seleccionado, p_idtipocomprobante, p_numerocomprobante, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, 
            p_ipcreacion, p_idempresa);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresardetallearchivocargado(p_idempresa integer, p_idarchivo integer, p_campo1 character varying, p_campo2 character varying, p_campo3 character varying, p_campo4 character varying, p_campo5 character varying, p_campo6 character varying, p_campo7 character varying, p_campo8 character varying, p_campo9 character varying, p_campo10 character varying, p_campo11 character varying, p_campo12 character varying, p_campo13 character varying, p_campo14 character varying, p_campo15 character varying, p_campo16 character varying, p_campo17 character varying, p_campo18 character varying, p_campo19 character varying, p_campo20 character varying, p_seleccionado boolean, p_idtipocomprobante integer, p_numerocomprobante character varying, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 436 (class 1255 OID 76029)
-- Name: fn_ingresardetallecomprobantegenerado(integer, integer, integer, integer, character varying, numeric, numeric, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresardetallecomprobantegenerado(p_idempresa integer, idserviciodetalle integer, p_idcomprobante integer, p_cantidad integer, p_detalleconcepto character varying, p_preciounitario numeric, p_totaldetalle numeric, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

Begin

maxid = nextval('negocio.seq_detallecomprobantegenerado');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."DetalleComprobanteGenerado"(
            id, idserviciodetalle, idcomprobante, cantidad, detalleconcepto, preciounitario, 
            totaldetalle, idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, 
            fechamodificacion, ipmodificacion, idempresa)
    VALUES (maxid, idserviciodetalle, p_idcomprobante, p_cantidad, p_detalleconcepto, p_preciounitario, 
            p_totaldetalle, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresardetallecomprobantegenerado(p_idempresa integer, idserviciodetalle integer, p_idcomprobante integer, p_cantidad integer, p_detalleconcepto character varying, p_preciounitario numeric, p_totaldetalle numeric, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 437 (class 1255 OID 76030)
-- Name: fn_ingresardireccion(integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character, integer, character varying, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresardireccion(p_idempresa integer, p_idvia integer, p_nombrevia character varying, p_numero character varying, p_interior character varying, p_manzana character varying, p_lote character varying, p_principal character varying, p_idubigeo character, p_usuariocreacion integer, p_ipcreacion character varying, p_observacion character varying, p_referencia character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxdireccion integer;
declare fechahoy timestamp with time zone;

begin

select coalesce(max(id),0)
  into maxdireccion
  from negocio."Direccion"
 where idempresa = p_idempresa;

maxdireccion = nextval('negocio.seq_direccion');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

insert into negocio."Direccion"(id, idvia, nombrevia, numero, interior, manzana, lote, principal, idubigeo, 
            idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, 
            fechamodificacion, ipmodificacion, observacion, referencia, idempresa)
values (maxdireccion,p_idvia,p_nombrevia,p_numero,p_interior,p_manzana,p_lote,p_principal,p_idubigeo,p_usuariocreacion,fechahoy,
	p_ipcreacion,p_usuariocreacion,fechahoy,p_ipcreacion, p_observacion, p_referencia, p_idempresa);

return maxdireccion;

end;
$$;


ALTER FUNCTION negocio.fn_ingresardireccion(p_idempresa integer, p_idvia integer, p_nombrevia character varying, p_numero character varying, p_interior character varying, p_manzana character varying, p_lote character varying, p_principal character varying, p_idubigeo character, p_usuariocreacion integer, p_ipcreacion character varying, p_observacion character varying, p_referencia character varying) OWNER TO postgres;

--
-- TOC entry 438 (class 1255 OID 76031)
-- Name: fn_ingresardireccion(integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character, integer, character varying, character varying, character varying, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresardireccion(p_idempresa integer, p_idvia integer, p_nombrevia character varying, p_numero character varying, p_interior character varying, p_manzana character varying, p_lote character varying, p_principal character varying, p_idubigeo character, p_usuariocreacion integer, p_ipcreacion character varying, p_observacion character varying, p_referencia character varying, p_idpais integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxdireccion integer;
declare fechahoy timestamp with time zone;

begin

select coalesce(max(id),0)
  into maxdireccion
  from negocio."Direccion";

maxdireccion = nextval('negocio.seq_direccion');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

insert into negocio."Direccion"(id, idvia, nombrevia, numero, interior, manzana, lote, principal, idubigeo, 
            idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, 
            fechamodificacion, ipmodificacion, observacion, referencia, idpais, idempresa)
values (maxdireccion,p_idvia,p_nombrevia,p_numero,p_interior,p_manzana,p_lote,p_principal,p_idubigeo,p_usuariocreacion,fechahoy,
	p_ipcreacion,p_usuariocreacion,fechahoy,p_ipcreacion, p_observacion, p_referencia,p_idpais,p_idempresa);

return maxdireccion;

end;
$$;


ALTER FUNCTION negocio.fn_ingresardireccion(p_idempresa integer, p_idvia integer, p_nombrevia character varying, p_numero character varying, p_interior character varying, p_manzana character varying, p_lote character varying, p_principal character varying, p_idubigeo character, p_usuariocreacion integer, p_ipcreacion character varying, p_observacion character varying, p_referencia character varying, p_idpais integer) OWNER TO postgres;

--
-- TOC entry 439 (class 1255 OID 76032)
-- Name: fn_ingresarobligacionxpagar(integer, integer, character varying, integer, date, date, character varying, numeric, numeric, boolean, boolean, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarobligacionxpagar(p_idempresa integer, p_idtipocomprobante integer, p_numerocomprobante character varying, p_idproveedor integer, p_fechacomprobante date, p_fechapago date, p_detallecomprobante character varying, p_totaligv numeric, p_totalcomprobante numeric, p_tienedetraccion boolean, p_tieneretencion boolean, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_obligacionxpagar');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ObligacionesXPagar"(
            id, idtipocomprobante, numerocomprobante, idproveedor, fechacomprobante, 
            fechapago, detallecomprobante, totaligv, totalcomprobante, saldocomprobante, tienedetraccion, tieneretencion, idusuariocreacion, 
            fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, 
            ipmodificacion, idempresa)
    VALUES (maxid, p_idtipocomprobante, p_numerocomprobante, p_idproveedor, p_fechacomprobante, 
            p_fechapago, p_detallecomprobante, p_totaligv, p_totalcomprobante, p_totalcomprobante, p_tienedetraccion, p_tieneretencion, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

return true;
end;
$$;


ALTER FUNCTION negocio.fn_ingresarobligacionxpagar(p_idempresa integer, p_idtipocomprobante integer, p_numerocomprobante character varying, p_idproveedor integer, p_fechacomprobante date, p_fechapago date, p_detallecomprobante character varying, p_totaligv numeric, p_totalcomprobante numeric, p_tienedetraccion boolean, p_tieneretencion boolean, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 433 (class 1255 OID 76033)
-- Name: fn_ingresarobligacionxpagar(integer, character varying, integer, date, date, character varying, numeric, numeric, boolean, boolean, character varying, character varying, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarobligacionxpagar(p_idtipocomprobante integer, p_numerocomprobante character varying, p_idproveedor integer, p_fechacomprobante date, p_fechapago date, p_detallecomprobante character varying, p_totaligv numeric, p_totalcomprobante numeric, p_tienedetraccion boolean, p_tieneretencion boolean, p_usuariocreacion character varying, p_ipcreacion character varying, p_idmoneda integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_obligacionxpagar');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ObligacionesXPagar"(
            id, idtipocomprobante, numerocomprobante, idproveedor, fechacomprobante, 
            fechapago, detallecomprobante, totaligv, totalcomprobante, saldocomprobante, tienedetraccion, tieneretencion, usuariocreacion, 
            fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
            ipmodificacion, idmoneda)
    VALUES (maxid, p_idtipocomprobante, p_numerocomprobante, p_idproveedor, p_fechacomprobante, 
            p_fechapago, p_detallecomprobante, p_totaligv, p_totalcomprobante, p_totalcomprobante, p_tienedetraccion, p_tieneretencion, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idmoneda);

return true;
end;
$$;


ALTER FUNCTION negocio.fn_ingresarobligacionxpagar(p_idtipocomprobante integer, p_numerocomprobante character varying, p_idproveedor integer, p_fechacomprobante date, p_fechapago date, p_detallecomprobante character varying, p_totaligv numeric, p_totalcomprobante numeric, p_tienedetraccion boolean, p_tieneretencion boolean, p_usuariocreacion character varying, p_ipcreacion character varying, p_idmoneda integer) OWNER TO postgres;

--
-- TOC entry 440 (class 1255 OID 76034)
-- Name: fn_ingresarpais(integer, character varying, integer, integer, character varying, date); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarpais(p_idempresa integer, p_descripcion character varying, p_idcontinente integer, p_usuariocreacion integer, p_ipcreacion character varying, p_fecnacimiento date) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxpais integer;
declare fechahoy timestamp with time zone;

begin

maxpais = nextval('negocio.seq_pais');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO soporte.pais(
            id, descripcion, idcontinente, idusuariocreacion, fechacreacion, 
            ipcreacion, idusuariomodificacion, fechamodificacion, ipmodificacion, idempresa)
    VALUES (maxpais, p_descripcion, p_idcontinente, p_usuariocreacion, fechahoy, 
            p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

return maxpais;
end;
$$;


ALTER FUNCTION negocio.fn_ingresarpais(p_idempresa integer, p_descripcion character varying, p_idcontinente integer, p_usuariocreacion integer, p_ipcreacion character varying, p_fecnacimiento date) OWNER TO postgres;

--
-- TOC entry 441 (class 1255 OID 76035)
-- Name: fn_ingresarpasajero(integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, character varying, character varying, date, date, integer, integer, integer, character varying, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarpasajero(p_idempresa integer, p_idtipodocumento integer, p_numerodocumento character varying, p_nombres character varying, p_apellidopaterno character varying, p_apellidomaterno character varying, p_correoelectronico character varying, p_telefono1 character varying, p_telefono2 character varying, p_nropaxfrecuente character varying, p_idrelacion integer, p_idaerolinea integer, p_codigoreserva character varying, p_numeroboleto character varying, p_fechavctopasaporte date, p_fechanacimiento date, p_idserviciodetalle integer, p_idservicio integer, p_usuariocreacion integer, p_ipcreacion character varying, p_idpais integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_pax');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."PasajeroServicio"(
            id, idtipodocumento, numerodocumento, nombres, apellidopaterno, 
            apellidomaterno, correoelectronico, telefono1, telefono2, nropaxfrecuente, 
            idaerolinea, idrelacion, codigoreserva, numeroboleto, fechavctopasaporte, 
            fechanacimiento, idserviciodetalle, idservicio, idusuariocreacion, 
            fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, 
            ipmodificacion,idpais, idempresa)
    VALUES (maxid, p_idtipodocumento, p_numerodocumento, p_nombres, p_apellidopaterno, p_apellidomaterno, p_correoelectronico, 
            p_telefono1, p_telefono2, p_nropaxfrecuente, p_idaerolinea, p_idrelacion, p_codigoreserva, p_numeroboleto, p_fechavctopasaporte, p_fechanacimiento,
            p_idserviciodetalle, p_idservicio, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion,p_idpais, p_idempresa);

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarpasajero(p_idempresa integer, p_idtipodocumento integer, p_numerodocumento character varying, p_nombres character varying, p_apellidopaterno character varying, p_apellidomaterno character varying, p_correoelectronico character varying, p_telefono1 character varying, p_telefono2 character varying, p_nropaxfrecuente character varying, p_idrelacion integer, p_idaerolinea integer, p_codigoreserva character varying, p_numeroboleto character varying, p_fechavctopasaporte date, p_fechanacimiento date, p_idserviciodetalle integer, p_idservicio integer, p_usuariocreacion integer, p_ipcreacion character varying, p_idpais integer) OWNER TO postgres;

--
-- TOC entry 442 (class 1255 OID 76036)
-- Name: fn_ingresarpersona(integer, integer, character varying, character varying, character varying, character varying, integer, integer, character varying, integer, character varying, date, character varying, date, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarpersona(p_idempresa integer, p_idtipopersona integer, p_nombres character varying, p_apepaterno character varying, p_apematerno character varying, p_idgenero character varying, p_idestadocivil integer, p_idtipodocumento integer, p_numerodocumento character varying, p_usuariocreacion integer, p_ipcreacion character varying, p_fecnacimiento date, p_nropasaporte character varying, p_fecvctopasaporte date, p_idnacionalidad integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$

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
$$;


ALTER FUNCTION negocio.fn_ingresarpersona(p_idempresa integer, p_idtipopersona integer, p_nombres character varying, p_apepaterno character varying, p_apematerno character varying, p_idgenero character varying, p_idestadocivil integer, p_idtipodocumento integer, p_numerodocumento character varying, p_usuariocreacion integer, p_ipcreacion character varying, p_fecnacimiento date, p_nropasaporte character varying, p_fecvctopasaporte date, p_idnacionalidad integer) OWNER TO postgres;

--
-- TOC entry 443 (class 1255 OID 76037)
-- Name: fn_ingresarpersonadireccion(integer, integer, integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarpersonadireccion(p_idempresa integer, p_idpersona integer, p_idtipopersona integer, p_iddireccion integer, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."PersonaDireccion"(
            idpersona, iddireccion, idtipopersona, idempresa, idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, ipmodificacion)
    VALUES (p_idpersona, p_iddireccion, p_idtipopersona, p_idempresa, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarpersonadireccion(p_idempresa integer, p_idpersona integer, p_idtipopersona integer, p_iddireccion integer, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 444 (class 1255 OID 76038)
-- Name: fn_ingresarpersonaproveedor(integer, integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarpersonaproveedor(p_idempresa integer, p_idpersona integer, p_idrubro integer, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."PersonaAdicional"(idpersona, idrubro, idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, ipmodificacion, idempresa)
    VALUES (p_idpersona, p_idrubro, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarpersonaproveedor(p_idempresa integer, p_idpersona integer, p_idrubro integer, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 445 (class 1255 OID 76039)
-- Name: fn_ingresarprogramanovios(integer, integer, integer, integer, date, date, integer, numeric, integer, integer, date, text, numeric, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarprogramanovios(p_idempresa integer, p_idnovia integer, p_idnovio integer, p_iddestino integer, p_fechaboda date, p_fechaviaje date, p_idmoneda integer, p_cuotainicial numeric, p_dias integer, p_noches integer, p_fechashower date, p_observaciones text, p_montototal numeric, p_idservicio integer, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;
declare cod_novio character varying(20);

Begin

maxid = nextval('negocio.seq_novios');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;
cod_novio = negocio.fn_generarcodigonovio(p_idempresa,maxid,p_usuariocreacion);

INSERT INTO negocio."ProgramaNovios"(
            id, codigonovios, idnovia, idnovio, iddestino, fechaboda, fechaviaje, 
            idmoneda, cuotainicial, dias, noches, fechashower, observaciones, 
            montototal, idservicio, idusuariocreacion, 
            fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, 
            ipmodificacion, idempresa)
    VALUES (maxid, cod_novio, p_idnovia, p_idnovio, p_iddestino, p_fechaboda, p_fechaviaje, p_idmoneda, p_cuotainicial, p_dias, p_noches, p_fechashower, 
	    p_observaciones, p_montototal, p_idservicio, p_usuariocreacion, 
	    fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarprogramanovios(p_idempresa integer, p_idnovia integer, p_idnovio integer, p_iddestino integer, p_fechaboda date, p_fechaviaje date, p_idmoneda integer, p_cuotainicial numeric, p_dias integer, p_noches integer, p_fechashower date, p_observaciones text, p_montototal numeric, p_idservicio integer, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 446 (class 1255 OID 76040)
-- Name: fn_ingresarproveedortipo(integer, integer, integer, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarproveedortipo(p_idempresa integer, p_idpersona integer, p_idtipoproveedor integer, p_usuariocreacion integer, p_ipcreacion character varying, p_nombrecomercial character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

Begin

maxid = nextval('negocio.seq_consolidador');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ProveedorPersona"(
            idproveedor, idtipoproveedor, idusuariocreacion, fechacreacion, 
            ipcreacion, idusuariomodificacion, fechamodificacion, ipmodificacion, nombrecomercial, idempresa)
    VALUES (p_idpersona, p_idtipoproveedor, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_nombrecomercial, p_idempresa);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarproveedortipo(p_idempresa integer, p_idpersona integer, p_idtipoproveedor integer, p_usuariocreacion integer, p_ipcreacion character varying, p_nombrecomercial character varying) OWNER TO postgres;

--
-- TOC entry 425 (class 1255 OID 76041)
-- Name: fn_ingresarruta(integer, integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarruta(p_idempresa integer, p_idruta integer, p_idtramo integer, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."RutaServicio"(
            id, idtramo, idusuariocreacion, fechacreacion, 
            ipcreacion, idusuariomodificacion, fechamodificacion, ipmodificacion, idempresa)
    VALUES (p_idruta, p_idtramo, p_usuariocreacion, fechahoy, 
            p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarruta(p_idempresa integer, p_idruta integer, p_idtramo integer, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 449 (class 1255 OID 76042)
-- Name: fn_ingresarservicio(integer, character varying, character varying, character varying, boolean, integer, boolean, integer, boolean, boolean, numeric, integer, character varying, integer, boolean, boolean); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarservicio(p_idempresa integer, p_nombreservicio character varying, p_desccorta character varying, p_desclarga character varying, p_requierefee boolean, p_idmaeserfee integer, p_pagaimpto boolean, p_idmaeserimpto integer, p_cargacomision boolean, p_cargaigv boolean, p_valorcomision numeric, p_usuariocreacion integer, p_ipcreacion character varying, p_idparametro integer, p_visible boolean, p_serviciopadre boolean) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_maestroservicio');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."MaestroServicios"(
            id, nombre, desccorta, desclarga, requierefee, idmaeserfee, pagaimpto, 
            idmaeserimpto, cargacomision, cargaigv, valorporcomision, 
            idusuariocreacion, fechacreacion, ipcreacion, 
            idusuariomodificacion, fechamodificacion, ipmodificacion, idparametroasociado, visible, esserviciopadre, idempresa)
    VALUES (maxid, p_nombreservicio, p_desccorta, p_desclarga, p_requierefee, p_idmaeserfee, p_pagaimpto, 
            p_idmaeserimpto, p_cargacomision, p_cargaigv, p_valorcomision, p_usuariocreacion, fechahoy, 
            p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idparametro, p_visible, p_serviciopadre, p_idempresa);

return maxid;
end;
$$;


ALTER FUNCTION negocio.fn_ingresarservicio(p_idempresa integer, p_nombreservicio character varying, p_desccorta character varying, p_desclarga character varying, p_requierefee boolean, p_idmaeserfee integer, p_pagaimpto boolean, p_idmaeserimpto integer, p_cargacomision boolean, p_cargaigv boolean, p_valorcomision numeric, p_usuariocreacion integer, p_ipcreacion character varying, p_idparametro integer, p_visible boolean, p_serviciopadre boolean) OWNER TO postgres;

--
-- TOC entry 450 (class 1255 OID 76043)
-- Name: fn_ingresarserviciocabecera(integer, integer, integer, date, numeric, numeric, numeric, numeric, integer, integer, integer, numeric, numeric, date, date, integer, integer, text, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarserviciocabecera(p_idempresa integer, p_idcliente1 integer, p_idcliente2 integer, p_fechaservicio date, p_montototaligv numeric, p_montototal numeric, p_montototalfee numeric, p_montototalcomision numeric, p_idestadopago integer, p_idestadoservicio integer, p_nrocuotas integer, p_tea numeric, p_valorcuota numeric, p_fechaprimercuota date, p_fechaultcuota date, p_idmoneda integer, p_idvendedor integer, p_observacion text, p_usuariocreacion integer, p_ipcreacion character varying, p_codigonovios character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

Begin

maxid = nextval('negocio.seq_serviciocabecera');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ServicioCabecera"(
            id, idcliente1, idcliente2, fechacompra,
            idestadopago, idestadoservicio, nrocuotas, tea, valorcuota, 
            fechaprimercuota, fechaultcuota, idmoneda, montocomisiontotal, 
            montototaligv, montototal, montototalfee, idvendedor, observaciones, 
            idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, 
            fechamodificacion, ipmodificacion, codigonovios, idempresa)
    VALUES (maxid, p_idcliente1, p_idcliente2, p_fechaservicio,
            p_idestadopago, p_idestadoservicio, p_nrocuotas, p_tea, p_valorcuota, 
            p_fechaprimercuota, p_fechaultcuota, p_idmoneda, p_montototalcomision, 
            p_montototaligv, p_montototal, p_montototalfee, p_idvendedor, p_observacion, 
            p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_codigonovios, p_idempresa);

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarserviciocabecera(p_idempresa integer, p_idcliente1 integer, p_idcliente2 integer, p_fechaservicio date, p_montototaligv numeric, p_montototal numeric, p_montototalfee numeric, p_montototalcomision numeric, p_idestadopago integer, p_idestadoservicio integer, p_nrocuotas integer, p_tea numeric, p_valorcuota numeric, p_fechaprimercuota date, p_fechaultcuota date, p_idmoneda integer, p_idvendedor integer, p_observacion text, p_usuariocreacion integer, p_ipcreacion character varying, p_codigonovios character varying) OWNER TO postgres;

--
-- TOC entry 451 (class 1255 OID 76044)
-- Name: fn_ingresarserviciodetalle(integer, integer, character varying, integer, timestamp with time zone, timestamp with time zone, integer, integer, character varying, integer, character varying, integer, character varying, integer, character varying, integer, integer, numeric, numeric, numeric, boolean, boolean, numeric, integer, boolean, numeric, numeric, numeric, numeric, integer, boolean, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarserviciodetalle(p_idempresa integer, p_idtiposervicio integer, p_descripcionservicio character varying, p_idservicio integer, p_fechaida timestamp with time zone, p_fecharegreso timestamp with time zone, p_cantidad integer, p_idproveedor integer, p_descripcionproveedor character varying, p_idoperador integer, p_descripcionoperador character varying, p_idempresatransporte integer, p_descripcionemptransporte character varying, p_idhotel integer, p_decripcionhotel character varying, p_idruta integer, p_idmoneda integer, p_preciounitarioanterior numeric, p_tipocambio numeric, p_preciounitario numeric, p_editocomision boolean, p_tarifanegociada boolean, p_valorcomision numeric, p_tipovalorcomision integer, p_aplicarigvcomision boolean, p_subtotalcomision numeric, p_montoigvcomision numeric, p_montocomision numeric, p_montototal numeric, p_idservdetdepende integer, p_aplicaigv boolean, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

Begin

maxid = nextval('negocio.seq_serviciodetalle');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ServicioDetalle"(
            id, idtiposervicio, descripcionservicio, idservicio, fechaida, 
            fecharegreso, cantidad, idempresaproveedor, descripcionproveedor, 
            idempresaoperadora, descripcionoperador, idempresatransporte, 
            descripcionemptransporte, idhotel, decripcionhotel, idruta, idmoneda, 
            preciobaseanterior, tipocambio, preciobase, editocomision, tarifanegociada, 
            valorcomision, tipovalorcomision, aplicarigvcomision, subtotalcomision, 
            montoigvcomision, montototalcomision, montototal, idservdetdepende, aplicaigv, idusuariocreacion, fechacreacion, 
            ipcreacion, idusuariomodificacion, fechamodificacion, ipmodificacion, idempresa)
    VALUES (maxid, p_idtiposervicio, p_descripcionservicio, p_idservicio, p_fechaida, 
            p_fecharegreso, p_cantidad, p_idproveedor, p_descripcionproveedor, 
            p_idoperador, p_descripcionoperador, p_idempresatransporte, p_descripcionemptransporte, p_idhotel, p_decripcionhotel,
            p_idruta, p_idmoneda, p_preciounitarioanterior, p_tipocambio, p_preciounitario, p_editocomision, p_tarifanegociada,
            p_valorcomision, p_tipovalorcomision, p_aplicarigvcomision, p_subtotalcomision, p_montoigvcomision, p_montocomision, p_montototal, 
            p_idservdetdepende, p_aplicaigv,
            p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarserviciodetalle(p_idempresa integer, p_idtiposervicio integer, p_descripcionservicio character varying, p_idservicio integer, p_fechaida timestamp with time zone, p_fecharegreso timestamp with time zone, p_cantidad integer, p_idproveedor integer, p_descripcionproveedor character varying, p_idoperador integer, p_descripcionoperador character varying, p_idempresatransporte integer, p_descripcionemptransporte character varying, p_idhotel integer, p_decripcionhotel character varying, p_idruta integer, p_idmoneda integer, p_preciounitarioanterior numeric, p_tipocambio numeric, p_preciounitario numeric, p_editocomision boolean, p_tarifanegociada boolean, p_valorcomision numeric, p_tipovalorcomision integer, p_aplicarigvcomision boolean, p_subtotalcomision numeric, p_montoigvcomision numeric, p_montocomision numeric, p_montototal numeric, p_idservdetdepende integer, p_aplicaigv boolean, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 452 (class 1255 OID 76045)
-- Name: fn_ingresarserviciomaestroservicio(integer, integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarserviciomaestroservicio(p_idempresa integer, p_idservicio integer, p_idserviciodepente integer, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare cantidad integer;
declare fechahoy timestamp with time zone;

Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

select count(1)
  into cantidad
  from negocio."ServicioMaestroServicio"
 where idservicio        = p_idservicio
   and idempresa         = p_idempresa
   and idserviciodepende = p_idserviciodepente;

if cantidad = 0 then
INSERT INTO negocio."ServicioMaestroServicio"(
            idservicio, idserviciodepende, idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, ipmodificacion, idempresa)
    VALUES (p_idservicio, p_idserviciodepente, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

end if;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarserviciomaestroservicio(p_idempresa integer, p_idservicio integer, p_idserviciodepente integer, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 453 (class 1255 OID 76046)
-- Name: fn_ingresarservicioproveedor(integer, integer, integer, integer, numeric, numeric, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarservicioproveedor(p_idempresa integer, p_idproveedor integer, p_idtiposervicio integer, p_idproveedorservicio integer, p_porcencomision numeric, p_porcencominternacional numeric, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;
declare v_cantidad integer;

begin

select count(1)
  into v_cantidad
  from negocio."ProveedorTipoServicio" 
 where idproveedor         = p_idproveedor
   and idtiposervicio      = p_idtiposervicio
   and idproveedorservicio = p_idproveedorservicio
   and idempresa           = p_idempresa;

if v_cantidad = 1 then
   select negocio.fn_actualizarservicioproveedor(p_idempresa, p_idproveedor,p_idtiposervicio,p_idproveedorservicio,
   p_porcencomision,p_porcencominternacional,p_usuariocreacion,p_ipcreacion);
else
   select current_timestamp AT TIME ZONE 'PET' into fechahoy;

   INSERT INTO negocio."ProveedorTipoServicio"(
            idproveedor, idtiposervicio, idproveedorservicio, porcencomnacional, porcencominternacional, idusuariocreacion, 
            fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, 
            ipmodificacion, idempresa)
   VALUES (p_idproveedor, p_idtiposervicio, p_idproveedorservicio, p_porcencomision, p_porcencominternacional, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);
end if;
return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarservicioproveedor(p_idempresa integer, p_idproveedor integer, p_idtiposervicio integer, p_idproveedorservicio integer, p_porcencomision numeric, p_porcencominternacional numeric, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 456 (class 1255 OID 76047)
-- Name: fn_ingresartelefono(integer, character varying, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresartelefono(p_idempresa integer, p_numero character varying, p_idempresaproveedor integer, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxtelefono integer;
declare fechahoy timestamp with time zone;

Begin

select coalesce(max(id),0)
  into maxtelefono
  from negocio."Telefono"
 where idempresa = p_idempresa;

maxtelefono = nextval('negocio.seq_telefono');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."Telefono"(
            id, numero, idempresaproveedor, idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, 
            fechamodificacion, ipmodificacion, idempresa)
    VALUES (maxtelefono, p_numero, p_idempresaproveedor, p_usuariocreacion,fechahoy,
	p_ipcreacion,p_usuariocreacion,fechahoy,p_ipcreacion, p_idempresa);

return maxtelefono;

end;
$$;


ALTER FUNCTION negocio.fn_ingresartelefono(p_idempresa integer, p_numero character varying, p_idempresaproveedor integer, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 457 (class 1255 OID 76048)
-- Name: fn_ingresartelefonodireccion(integer, integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresartelefonodireccion(p_idempresa integer, p_idtelefono integer, p_iddireccion integer, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."TelefonoDireccion"(
            idtelefono, iddireccion, idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, 
            fechamodificacion, ipmodificacion, idempresa)
    VALUES (p_idtelefono, p_iddireccion, p_usuariocreacion,fechahoy,
	p_ipcreacion,p_usuariocreacion,fechahoy,p_ipcreacion, p_idempresa);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresartelefonodireccion(p_idempresa integer, p_idtelefono integer, p_iddireccion integer, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 458 (class 1255 OID 76049)
-- Name: fn_ingresartelefonopersona(integer, integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresartelefonopersona(p_idempresa integer, p_idtelefono integer, p_idpersona integer, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

Begin

INSERT INTO negocio."TelefonoPersona"(
            idtelefono, idpersona, idempresa, idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, ipmodificacion)
    VALUES (p_idtelefono, p_idpersona, p_idempresa, p_usuariocreacion, current_timestamp, p_ipcreacion, p_usuariocreacion, current_timestamp, p_ipcreacion);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresartelefonopersona(p_idempresa integer, p_idtelefono integer, p_idpersona integer, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 459 (class 1255 OID 76050)
-- Name: fn_ingresartipocambio(integer, date, integer, integer, numeric, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresartipocambio(p_idempresa integer, p_fecha date, p_idmonedaorigen integer, p_idmonedadestino integer, p_montocambio numeric, p_usuariocreacion integer, p_ipcrecion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_tipocambio');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."TipoCambio"(
            id, fechatipocambio, idmonedaorigen, idmonedadestino, montocambio, 
            idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, 
            fechamodificacion, ipmodificacion, idempresa)
    VALUES (maxid, p_fecha, p_idmonedaorigen, p_idmonedadestino, p_montocambio, 
            p_usuariocreacion, fechahoy, p_ipcrecion, p_usuariocreacion, fechahoy, p_ipcrecion, p_idempresa);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresartipocambio(p_idempresa integer, p_fecha date, p_idmonedaorigen integer, p_idmonedadestino integer, p_montocambio numeric, p_usuariocreacion integer, p_ipcrecion character varying) OWNER TO postgres;

--
-- TOC entry 460 (class 1255 OID 76051)
-- Name: fn_ingresartramo(integer, integer, character varying, timestamp with time zone, integer, character varying, timestamp with time zone, numeric, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresartramo(p_idempresa integer, p_idorigen integer, p_descripcionorigen character varying, p_fechasalida timestamp with time zone, p_iddestino integer, p_descripciondestino character varying, p_fechallegada timestamp with time zone, p_preciobase numeric, p_idaerolinea integer, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

Begin

maxid = nextval('negocio.seq_tramo');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."Tramo"(
            id, idorigen, descripcionorigen, fechasalida, iddestino, descripciondestino, 
            fechallegada, preciobase, idaerolinea, idusuariocreacion, fechacreacion, ipcreacion, 
            idusuariomodificacion, fechamodificacion, ipmodificacion, idempresa)
    VALUES (maxid, p_idorigen, p_descripcionorigen, p_fechasalida, p_iddestino, p_descripciondestino, 
            p_fechallegada, p_preciobase, p_idaerolinea, p_usuariocreacion, fechahoy, p_ipcreacion, 
            p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_ingresartramo(p_idempresa integer, p_idorigen integer, p_descripcionorigen character varying, p_fechasalida timestamp with time zone, p_iddestino integer, p_descripciondestino character varying, p_fechallegada timestamp with time zone, p_preciobase numeric, p_idaerolinea integer, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 461 (class 1255 OID 76052)
-- Name: fn_listarclientescorreo(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarclientescorreo(p_idempresa integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
select cli.id as idcliente, cli.nombres as nomcliente, cli.apellidopaterno as apepatcliente, cli.apellidomaterno as apematcliente, 
       con.id as idcontacto, con.nombres as nomcontacto, con.apellidopaterno as apepatcontacto, con.apellidomaterno as apematcontacto,
       cor.correo, cor.recibirpromociones
  from negocio.vw_clientesnova cli,
       negocio."PersonaContactoProveedor" pccli,
       negocio.vw_consultacontacto con,
       negocio."CorreoElectronico" cor
 where cli.id                 = pccli.idproveedor
   and cli.idempresa          = pccli.idempresa
   and pccli.idestadoregistro = 1
   and pccli.idcontacto       = con.id
   and pccli.idempresa        = con.idempresa
   and cor.idpersona          = con.id
   and cor.idempresa          = con.idempresa
   and cor.correo             is not null
   and cor.correo             <> ''
   and cli.idempresa          = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarclientescorreo(p_idempresa integer) OWNER TO postgres;

--
-- TOC entry 462 (class 1255 OID 76053)
-- Name: fn_listarclientescumples(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarclientescumples(p_idempresa integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
select * 
  from negocio.vw_clientesnova
 where to_char(fecnacimiento,'ddMM') = to_char(current_date,'ddMM')
   and idempresa                     = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarclientescumples(p_idempresa integer) OWNER TO postgres;

--
-- TOC entry 463 (class 1255 OID 76054)
-- Name: fn_listarconsolidadores(); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarconsolidadores() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT id, nombre, usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
       fechamodificacion, ipmodificacion
  FROM negocio."Consolidador"
 WHERE idestadoregistro = 1;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarconsolidadores() OWNER TO postgres;

--
-- TOC entry 466 (class 1255 OID 76055)
-- Name: fn_listarcuentasbancarias(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarcuentasbancarias(p_idempresa integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT cb.id, cb.nombrecuenta, cb.numerocuenta, cb.idtipocuenta, tmtc.nombre as nombretipocuenta, cb.idbanco, tmba.nombre as nombrebanco, 
       cb.idmoneda, tmmo.nombre as nombremoneda, tmmo.abreviatura, cb.saldocuenta, 
       (SELECT COUNT(1)
          FROM negocio."MovimientoCuenta" mc
         WHERE mc.idcuenta  = cb.id
           AND mc.idempresa = cb.idempresa) numeroMovimientos,
       cb.usuariocreacion, cb.fechacreacion, cb.ipcreacion, cb.usuariomodificacion, cb.fechamodificacion, cb.ipmodificacion
  FROM negocio."CuentaBancaria" cb,
       soporte."Tablamaestra" tmtc,
       soporte."Tablamaestra" tmba,
       soporte."Tablamaestra" tmmo
 WHERE idestadoregistro = 1
   AND tmtc.idmaestro   = fn_maestrotipocuenta()
   AND cb.idtipocuenta  = tmtc.id
   AND cb.idempresa     = tmtc.idempresa
   AND tmba.idmaestro   = fn_maestrobanco()
   AND cb.idbanco       = tmba.id
   AND cb.idempresa     = tmba.idempresa
   AND tmmo.idmaestro   = fn_maestrotipomoneda()
   AND cb.idmoneda      = tmmo.id
   AND cb.idempresa     = tmmo.idempresa
   AND cb.idempresa     = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarcuentasbancarias(p_idempresa integer) OWNER TO postgres;

--
-- TOC entry 467 (class 1255 OID 76056)
-- Name: fn_listarcuentasbancariascombo(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarcuentasbancariascombo(p_idempresa integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT cb.id, cb.nombrecuenta
  FROM negocio."CuentaBancaria" cb
 WHERE idestadoregistro = 1
   AND idempresa        = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarcuentasbancariascombo(p_idempresa integer) OWNER TO postgres;

--
-- TOC entry 468 (class 1255 OID 76057)
-- Name: fn_listarcuentasbancariasproveedor(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarcuentasbancariasproveedor(p_idempresa integer, p_idproveedor integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT id, nombrecuenta, numerocuenta, idtipocuenta, idbanco, idmoneda, 
       idproveedor
  FROM negocio."ProveedorCuentaBancaria" pcb
 WHERE idestadoregistro = 1
   AND idproveedor      = p_idproveedor
   AND idempresa        = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarcuentasbancariasproveedor(p_idempresa integer, p_idproveedor integer) OWNER TO postgres;

--
-- TOC entry 469 (class 1255 OID 76058)
-- Name: fn_listardocumentosadicionales(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listardocumentosadicionales(p_idempresa integer, p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT das.id, idservicio, idtipodocumento, tm.nombre as nombredocumento, descripciondocumento, archivo, nombrearchivo, tipocontenido, 
       extensionarchivo, das.idusuariocreacion, das.fechacreacion, das.ipcreacion, 
       das.idusuariomodificacion, das.fechamodificacion, das.ipmodificacion, das.idestadoregistro
  FROM negocio."DocumentoAdjuntoServicio" das,
       soporte."Tablamaestra" tm
 where das.idservicio      = p_idservicio
   and das.idempresa       = p_idempresa
   and das.idtipodocumento = tm.id
   and das.idempresa       = tm.idempresa
   and tm.idmaestro        = fn_maestrodocumentoadjunto();

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listardocumentosadicionales(p_idempresa integer, p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 470 (class 1255 OID 76059)
-- Name: fn_listarmaestroservicios(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarmaestroservicios(p_idempresa integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

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
$$;


ALTER FUNCTION negocio.fn_listarmaestroservicios(p_idempresa integer) OWNER TO postgres;

--
-- TOC entry 471 (class 1255 OID 76060)
-- Name: fn_listarmaestroserviciosadm(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarmaestroserviciosadm(p_idempresa integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

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
$$;


ALTER FUNCTION negocio.fn_listarmaestroserviciosadm(p_idempresa integer) OWNER TO postgres;

--
-- TOC entry 472 (class 1255 OID 76061)
-- Name: fn_listarmaestroserviciosfee(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarmaestroserviciosfee(p_idempresa integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT id, nombre, desccorta, desclarga, requierefee, pagaimpto, cargacomision, esserviciopadre
  FROM negocio."MaestroServicios"
 WHERE idestadoregistro = 1
   AND esfee            = TRUE
   AND idempresa        = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarmaestroserviciosfee(p_idempresa integer) OWNER TO postgres;

--
-- TOC entry 473 (class 1255 OID 76062)
-- Name: fn_listarmaestroserviciosigv(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarmaestroserviciosigv(p_idempresa integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT id, nombre, desccorta, desclarga, requierefee, pagaimpto, cargacomision, esserviciopadre
  FROM negocio."MaestroServicios"
 WHERE idestadoregistro = 1
   AND esimpuesto       = TRUE
   AND idempresa        = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarmaestroserviciosigv(p_idempresa integer) OWNER TO postgres;

--
-- TOC entry 474 (class 1255 OID 76063)
-- Name: fn_listarmaestroserviciosimpto(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarmaestroserviciosimpto(p_idempresa integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT id, nombre, desccorta, desclarga, requierefee, pagaimpto, cargacomision, esserviciopadre
  FROM negocio."MaestroServicios"
 WHERE idestadoregistro = 1
   AND esimpuesto       = TRUE
   AND idempresa        = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarmaestroserviciosimpto(p_idempresa integer) OWNER TO postgres;

--
-- TOC entry 475 (class 1255 OID 76064)
-- Name: fn_listarmovimientosxcuenta(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarmovimientosxcuenta(p_idempresa integer, p_idcuenta integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT id, 
       idcuenta, 
       idtipomovimiento, 
       (CASE idtipomovimiento WHEN 1 THEN 'Ingreso' ELSE 'Egreso' END) as desTipoMovimiento,
       idtransaccion, 
       tmtt.nombre as nombreTransaccion,
       descripcionnovimiento, 
       importemovimiento, 
       idautorizador, 
       idmovimientopadre, 
       usuariocreacion, 
       fechacreacion, 
       ipcreacion, 
       usuariomodificacion, 
       fechamodificacion, 
       ipmodificacion
  FROM negocio."MovimientoCuenta" mc
 INNER JOIN negocio."CuentaBancaria" cb ON cb.idempresa   = p_idempresa AND cb.idestadoregistro = 1                           AND mc.idcuenta = cb.id
 INNER JOIN soporte."Tablamaestra" tmtt ON tmtt.idempresa = p_idempresa AND tmtt.idmaestro      = fn_maestrotipotransaccion() AND tmtt.id = idtransaccion
 WHERE mc.idcuenta  = p_idcuenta
   AND mc.idempresa = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarmovimientosxcuenta(p_idempresa integer, p_idcuenta integer) OWNER TO postgres;

--
-- TOC entry 464 (class 1255 OID 76065)
-- Name: fn_listarpagos(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarpagos(p_idempresa integer, p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT idpago, idservicio, ps.idformapago, tmfp.nombre as nombreformapago, fechapago, 
       ps.idmoneda, tmmo.nombre as nombremoneda, tmmo.abreviatura, montopagado, sustentopago, nombrearchivo, extensionarchivo, tipocontenido, espagodetraccion, 
       espagoretencion, ps.idusuariocreacion, ps.fechacreacion, ps.ipcreacion, ps.idusuariomodificacion, ps.fechamodificacion, ps.ipmodificacion
  FROM negocio."PagosServicio" ps
 INNER JOIN soporte."Tablamaestra" tmfp ON tmfp.idempresa = p_idempresa AND ps.idformapago = tmfp.id                AND tmfp.idmaestro = fn_maestroformapago()
 INNER JOIN soporte."Tablamaestra" tmmo ON tmmo.idempresa = p_idempresa AND tmmo.idmaestro = fn_maestrotipomoneda() AND tmmo.id        = ps.idmoneda
 WHERE ps.idestadoregistro = 1
   AND ps.idempresa        = p_idempresa
   AND ps.idservicio       = p_idservicio
 ORDER BY idpago DESC;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarpagos(p_idempresa integer, p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 476 (class 1255 OID 76066)
-- Name: fn_listarpagosobligaciones(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarpagosobligaciones(p_idempresa integer, p_idobligacion integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT idpago, idobligacion, fechapago, montopagado, sustentopago, nombrearchivo, extensionarchivo, tipocontenido, espagodetraccion, espagoretencion, usuariocreacion, 
       fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
       ipmodificacion
  FROM negocio."PagosObligacion"
 WHERE idestadoregistro = 1
   AND idobligacion     = p_idobligacion
   AND idempresa        = p_idempresa
 ORDER BY idpago DESC;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarpagosobligaciones(p_idempresa integer, p_idobligacion integer) OWNER TO postgres;

--
-- TOC entry 478 (class 1255 OID 76067)
-- Name: fn_listartipocambio(integer, date); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listartipocambio(p_idempresa integer, p_fecha date) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT tc.id, fechatipocambio, 
       idmonedaorigen, tmmo.nombre as nombreMonOrigen, 
       idmonedadestino, tmmd.nombre as nombreMonDestino, 
       montocambio
  FROM negocio."TipoCambio" tc
 INNER JOIN soporte."Tablamaestra" tmmo ON tmmo.idmaestro = fn_maestrotipomoneda() AND tmmo.id = idmonedaorigen  AND tmmo.idempresa = p_idempresa
 INNER JOIN soporte."Tablamaestra" tmmd ON tmmd.idmaestro = fn_maestrotipomoneda() AND tmmd.id = idmonedadestino AND tmmd.idempresa = p_idempresa
 WHERE fechatipocambio = COALESCE(p_fecha,fechatipocambio)
   AND tc.idempresa    = p_idempresa
 ORDER BY tc.id DESC;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listartipocambio(p_idempresa integer, p_fecha date) OWNER TO postgres;

--
-- TOC entry 479 (class 1255 OID 76068)
-- Name: fn_proveedorxservicio(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_proveedorxservicio(p_idempresa integer, p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT per.id, per.nombres, pp.nombrecomercial
  FROM negocio."Persona" per
 INNER JOIN negocio."PersonaAdicional" padd ON padd.idempresa = p_idempresa AND padd.idpersona = per.id AND padd.idestadoregistro = 1 --AND padd.idrubro = fn_rubroagenciaviajes()
 INNER JOIN negocio."ProveedorPersona" pp   ON pp.idempresa   = p_idempresa AND pp.idproveedor = per.id AND pp.idestadoregistro = 1
 WHERE per.idestadoregistro =  1
   AND per.idempresa        =  p_idempresa
   AND per.idtipopersona    =  fn_tipopersonaproveedor()
   AND per.id               IN (SELECT idproveedor FROM negocio."ProveedorTipoServicio" WHERE idestadoregistro = 1 AND idtiposervicio = p_idservicio AND idempresa = p_idempresa);

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_proveedorxservicio(p_idempresa integer, p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 480 (class 1255 OID 76069)
-- Name: fn_registrarcomprobanteobligacion(integer, integer, integer, integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_registrarcomprobanteobligacion(p_idempresa integer, p_idcomprobante integer, p_idobligacion integer, p_iddetalleservicio integer, p_idservicio integer, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ComprobanteObligacion"(
            idcomprobante, idobligacion, iddetalleservicio, idservicio, idusuariocreacion, fechacreacion, 
            ipcreacion, idusuariomodificacion, fechamodificacion, ipmodificacion, idempresa)
    VALUES (p_idcomprobante, p_idobligacion, p_iddetalleservicio, p_idservicio, p_usuariocreacion, fechahoy, 
            p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_registrarcomprobanteobligacion(p_idempresa integer, p_idcomprobante integer, p_idobligacion integer, p_iddetalleservicio integer, p_idservicio integer, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 481 (class 1255 OID 76070)
-- Name: fn_registrarcuentabancaria(integer, character varying, character varying, integer, integer, integer, numeric, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_registrarcuentabancaria(p_idempresa integer, p_nombrecuenta character varying, p_numerocuenta character varying, p_idtipocuenta integer, p_idbanco integer, p_idmoneda integer, p_saldocuenta numeric, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_cuentabancaria');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."CuentaBancaria"(
            id, nombrecuenta, numerocuenta, idtipocuenta, idbanco, idmoneda, saldocuenta, idusuariocreacion, 
            fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, 
            ipmodificacion, idempresa)
    VALUES (maxid, p_nombrecuenta, p_numerocuenta, p_idtipocuenta, p_idbanco, p_idmoneda, p_saldocuenta, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_registrarcuentabancaria(p_idempresa integer, p_nombrecuenta character varying, p_numerocuenta character varying, p_idtipocuenta integer, p_idbanco integer, p_idmoneda integer, p_saldocuenta numeric, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 482 (class 1255 OID 76071)
-- Name: fn_registrardocumentosustentoservicio(integer, integer, integer, character varying, bytea, character varying, character varying, character varying, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_registrardocumentosustentoservicio(p_idempresa integer, p_idservicio integer, p_idtipodocumento integer, p_descripciondocumento character varying, p_archivo bytea, p_nombrearchivo character varying, p_extensionarchivo character varying, p_tipocontenido character varying, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_documentoservicio');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."DocumentoAdjuntoServicio"(
            id, idservicio, idtipodocumento, descripciondocumento, archivo, nombrearchivo, tipocontenido, 
            extensionarchivo, idusuariocreacion, fechacreacion, ipcreacion, 
            idusuariomodificacion, fechamodificacion, ipmodificacion, idempresa)
    VALUES (maxid, p_idservicio, p_idtipodocumento, p_descripciondocumento, p_archivo, p_nombrearchivo, p_tipocontenido, 
            p_extensionarchivo, p_usuariocreacion, fechahoy, p_ipcreacion, 
            p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_registrardocumentosustentoservicio(p_idempresa integer, p_idservicio integer, p_idtipodocumento integer, p_descripciondocumento character varying, p_archivo bytea, p_nombrearchivo character varying, p_extensionarchivo character varying, p_tipocontenido character varying, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 483 (class 1255 OID 76072)
-- Name: fn_registrarmovimientocuenta(integer, integer, integer, integer, character varying, numeric, integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_registrarmovimientocuenta(p_idempresa integer, p_idcuenta integer, p_idtipomovimiento integer, p_idtransaccion integer, p_descripcionnovimiento character varying, p_importemovimiento numeric, p_idautorizador integer, p_idmovimientopadre integer, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;
declare v_saldocuenta decimal(20,6);
declare v_saldocuenta_actualiza decimal(20,6);
declare v_resultado boolean;

begin

maxid = nextval('negocio.seq_movimientocuenta');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."MovimientoCuenta"(
            id, idcuenta, idtipomovimiento, idtransaccion, descripcionnovimiento, 
            importemovimiento, idautorizador, idmovimientopadre, idusuariocreacion, 
            fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, 
            ipmodificacion, idempresa)
    VALUES (maxid, p_idcuenta, p_idtipomovimiento, p_idtransaccion, p_descripcionnovimiento, 
            p_importemovimiento, p_idautorizador, p_idmovimientopadre, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

SELECT saldocuenta
  INTO v_saldocuenta
  FROM negocio."CuentaBancaria"
 WHERE id        = p_idcuenta
   AND idempresa = p_idempresa;

if p_idtipomovimiento = 1 then -- ingreso
    v_saldocuenta_actualiza = v_saldocuenta + p_importemovimiento;
else -- egreso
    v_saldocuenta_actualiza = v_saldocuenta - p_importemovimiento;
end if;

select negocio.fn_actualizarcuentabancariasaldo(p_idempresa, p_idcuenta, v_saldocuenta_actualiza, p_usuariocreacion, p_ipcreacion) into v_resultado;

return v_resultado;

end;
$$;


ALTER FUNCTION negocio.fn_registrarmovimientocuenta(p_idempresa integer, p_idcuenta integer, p_idtipomovimiento integer, p_idtransaccion integer, p_descripcionnovimiento character varying, p_importemovimiento numeric, p_idautorizador integer, p_idmovimientopadre integer, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 486 (class 1255 OID 76073)
-- Name: fn_registrarpagoobligacion(integer, integer, integer, integer, integer, integer, integer, character varying, character varying, date, character varying, numeric, integer, bytea, character varying, character varying, character varying, character varying, boolean, boolean, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_registrarpagoobligacion(p_idempresa integer, p_idobligacion integer, p_idformapago integer, p_idcuentaorigen integer, p_idcuentadestino integer, p_idbancotarjeta integer, p_idtipotarjeta integer, p_nombretitular character varying, p_numerotarjeta character varying, p_fechapago date, p_numerooperacion character varying, p_montopago numeric, p_idmoneda integer, p_sustentopago bytea, p_nombrearchivo character varying, p_extensionarchivo character varying, p_tipocontenido character varying, p_comentario character varying, p_espagodetraccion boolean, p_espagoretencion boolean, p_usuarioautoriza integer, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;
declare v_montocomprobante decimal(12,3);
declare v_montosaldo decimal(12,3);
declare v_montopagado decimal(12,3);
declare v_tipomovimiento integer;
declare v_tipotransaccion integer;
declare v_desctransaccion character varying;
declare v_registramovimiento boolean;

begin

maxid = nextval('negocio.seq_pago');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

SELECT totalcomprobante
  INTO v_montocomprobante
  FROM negocio."ObligacionesXPagar"
 WHERE id        = p_idobligacion
   AND idempresa = p_idempresa;

SELECT SUM(montopagado)
  into v_montopagado
  FROM negocio."PagosObligacion"
 WHERE idobligacion = p_idobligacion
   AND idempresa    = p_idempresa;

if v_montopagado is not null then
	v_montosaldo = v_montocomprobante - v_montopagado;
	IF v_montosaldo < p_montopago THEN
		raise USING MESSAGE = 'El monto a pagar es mayor que el saldo pendiente';
	END IF;
else
    v_montosaldo = v_montocomprobante - p_montopago;
end if;

INSERT INTO negocio."PagosObligacion"(
            idpago, idobligacion, idformapago, idcuentaorigen, idcuentadestino, idbancotarjeta, 
            idtipotarjeta, nombretitular, numerotarjeta, fechapago, numerooperacion, montopagado, idmoneda,
            sustentopago, tipocontenido, nombrearchivo, extensionarchivo, 
            comentario, espagodetraccion, espagoretencion, idusuariocreacion, 
            fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, 
            ipmodificacion, idempresa)
    VALUES (maxid, p_idobligacion, p_idformapago, p_idcuentaorigen, p_idcuentadestino, p_idbancotarjeta, 
            p_idtipotarjeta, p_nombretitular, p_numerotarjeta, p_fechapago, p_numerooperacion, p_montopago, p_idmoneda,
            p_sustentopago, p_tipocontenido, p_nombrearchivo, p_extensionarchivo, 
            p_comentario, p_espagodetraccion, p_espagoretencion, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);


UPDATE negocio."ObligacionesXPagar"
   SET saldocomprobante = v_montosaldo
 WHERE id               = p_idobligacion
   AND idempresa        = p_idempresa;


-- 1: ingreso
-- 2: egreso
v_tipomovimiento = 2;
if p_idformapago = 2 then
    v_tipotransaccion = 1;-- deposito en cuenta
    v_desctransaccion = 'Deposito en cuenta';
elsif p_idformapago = 3 then
    v_tipotransaccion = 2;-- transferencia
    v_desctransaccion = 'Transferencia de fondos a cuenta';
end if;

select negocio.fn_registrarmovimientocuenta(p_idempresa, p_idcuentaorigen, v_tipomovimiento, v_tipotransaccion, v_desctransaccion, p_montopago, 
p_usuarioautoriza, null, p_usuariocreacion, p_ipcreacion) into v_registramovimiento;

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_registrarpagoobligacion(p_idempresa integer, p_idobligacion integer, p_idformapago integer, p_idcuentaorigen integer, p_idcuentadestino integer, p_idbancotarjeta integer, p_idtipotarjeta integer, p_nombretitular character varying, p_numerotarjeta character varying, p_fechapago date, p_numerooperacion character varying, p_montopago numeric, p_idmoneda integer, p_sustentopago bytea, p_nombrearchivo character varying, p_extensionarchivo character varying, p_tipocontenido character varying, p_comentario character varying, p_espagodetraccion boolean, p_espagoretencion boolean, p_usuarioautoriza integer, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 487 (class 1255 OID 76074)
-- Name: fn_registrarpagoservicio(integer, integer, integer, integer, integer, integer, character varying, character varying, date, character varying, numeric, integer, bytea, character varying, character varying, character varying, character varying, boolean, boolean, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_registrarpagoservicio(p_idempresa integer, p_idservicio integer, p_idformapago integer, p_idcuentadestino integer, p_idbancotarjeta integer, p_idtipotarjeta integer, p_nombretitular character varying, p_numerotarjeta character varying, p_fechapago date, p_numerooperacion character varying, p_montopago numeric, p_idmoneda integer, p_sustentopago bytea, p_nombrearchivo character varying, p_extensionarchivo character varying, p_tipocontenido character varying, p_comentario character varying, p_espagodetraccion boolean, p_espagoretencion boolean, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare maxidss integer;
declare fechahoy timestamp with time zone;
declare montosaldo decimal(12,3);
declare montosaldofinal decimal(12,3);
declare fechaservicio date;
declare montoservicio decimal(12,3);
declare estadoPago integer;
declare v_tipotransaccion integer;
declare v_desctransaccion character varying;
declare v_registramovimiento boolean;
declare v_monedaservicio integer;
declare v_tipocambio decimal(12,3);
declare v_montoaplicar decimal(12,3);
declare v_registrotranstc integer;

begin

v_monedaservicio = 2;

select idestadopago
  into estadoPago
  from negocio."ServicioCabecera"
 where id        = p_idservicio
   and idempresa = p_idempresa;

if estadoPago = 2 then
    raise USING MESSAGE = 'El servicio se encuentra pagado ya no acepta mas pagos';
end if;

select min(montosaldoservicio)
  into montosaldo
  from negocio."SaldosServicio" ss
 where ss.idservicio = p_idservicio
   and ss.idempresa  = p_idempresa;

if p_idmoneda <> v_monedaservicio then
    select negocio.fn_consultartipocambiomonto(p_idempresa,p_idmoneda,v_monedaservicio) into v_tipocambio;
    v_montoaplicar = p_montopago * v_tipocambio;
else
    v_montoaplicar = p_montopago;
end if;

if v_montoaplicar > montosaldo then
   raise USING MESSAGE = 'El monto a pagar es mayor que el saldo pendiente';
end if;

maxid = nextval('negocio.seq_pago');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

select fechacompra, montototal
  into fechaservicio, montoservicio
  from negocio."ServicioCabecera"
 where id        = p_idservicio
   and idempresa = p_idempresa;

if montosaldo is null then
    montosaldo = montoservicio;
end if;

INSERT INTO negocio."PagosServicio"(
            idpago, idservicio, idformapago, idcuentadestino, idbancotarjeta, idtipotarjeta, 
            nombretitular, numerotarjeta, fechapago, numerooperacion, montopagado, idmoneda, sustentopago, 
            tipocontenido, nombrearchivo, extensionarchivo, comentario, espagodetraccion, 
            espagoretencion, idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, ipmodificacion, idempresa)
    VALUES (maxid, p_idservicio, p_idformapago, p_idcuentadestino, p_idbancotarjeta, p_idtipotarjeta, 
            p_nombretitular, p_numerotarjeta, p_fechapago, p_numerooperacion, p_montopago, p_idmoneda, p_sustentopago, 
            p_tipocontenido, p_nombrearchivo, p_extensionarchivo, p_comentario, p_espagodetraccion, 
            p_espagoretencion, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

if p_idmoneda <> v_monedaservicio then
    select negocio.fn_registrartransacciontipocambio(p_idempresa,p_idmoneda,p_montopago,v_tipocambio,v_monedaservicio,v_montoaplicar,p_usuariocreacion,p_ipcreacion) into v_registrotranstc;
end if;

montosaldofinal = montosaldo - v_montoaplicar;

maxidss = nextval('negocio.seq_salsoservicio');
INSERT INTO negocio."SaldosServicio"(
            idsaldoservicio, idservicio, idpago, fechaservicio, montototalservicio, 
            montosaldoservicio, idtransaccionreferencia, idusuariocreacion, fechacreacion, ipcreacion, 
            idusuariomodificacion, fechamodificacion, ipmodificacion, idempresa)
    VALUES (maxidss, p_idservicio, maxid, fechaservicio, montoservicio, 
            montosaldofinal, v_registrotranstc, p_usuariocreacion, fechahoy, p_ipcreacion, 
            p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

if montosaldofinal = 0 then
   update negocio."ServicioCabecera"
      set idestadopago = 2
    where id           = p_idservicio
      and idempresa    = p_idempresa;
end if;

if p_idformapago = 2 then -- deposito en cuenta
    v_tipotransaccion = 1;
    v_desctransaccion = 'Deposito en cuenta';

    -- 1: ingreso
    -- 2: egreso
    select negocio.fn_registrarmovimientocuenta(p_idempresa, p_idcuentadestino, 1, v_tipotransaccion, v_desctransaccion, p_montopago, null, null, p_usuariocreacion, p_ipcreacion) into v_registramovimiento;
elsif p_idformapago = 3 then -- transferencia
    v_tipotransaccion = 2;
    v_desctransaccion = 'Transferencia de fondos a cuenta';

    -- 1: ingreso
    -- 2: egreso
    select negocio.fn_registrarmovimientocuenta(p_idempresa, p_idcuentadestino, 1, v_tipotransaccion, v_desctransaccion, p_montopago, null, null, p_usuariocreacion, p_ipcreacion) into v_registramovimiento;
end if;

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_registrarpagoservicio(p_idempresa integer, p_idservicio integer, p_idformapago integer, p_idcuentadestino integer, p_idbancotarjeta integer, p_idtipotarjeta integer, p_nombretitular character varying, p_numerotarjeta character varying, p_fechapago date, p_numerooperacion character varying, p_montopago numeric, p_idmoneda integer, p_sustentopago bytea, p_nombrearchivo character varying, p_extensionarchivo character varying, p_tipocontenido character varying, p_comentario character varying, p_espagodetraccion boolean, p_espagoretencion boolean, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 488 (class 1255 OID 76075)
-- Name: fn_registrarsaldoservicio(integer, integer, integer, date, numeric, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_registrarsaldoservicio(p_idempresa integer, p_idservicio integer, p_idpago integer, p_fechaservicio date, p_montototalservicio numeric, idreferencia integer, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_salsoservicio');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;


INSERT INTO negocio."SaldosServicio"(
            idsaldoservicio, idservicio, idpago, fechaservicio, montototalservicio, 
            montosaldoservicio, idtransaccionreferencia, idusuariocreacion, fechacreacion, ipcreacion, 
            idusuariomodificacion, fechamodificacion, ipmodificacion, idempresa)
    VALUES (maxid, p_idservicio, p_idpago, p_fechaservicio, p_montototalservicio, 
            p_montototalservicio, idreferencia, p_usuariocreacion, fechahoy, p_ipcreacion, 
            p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

return maxid;
end;
$$;


ALTER FUNCTION negocio.fn_registrarsaldoservicio(p_idempresa integer, p_idservicio integer, p_idpago integer, p_fechaservicio date, p_montototalservicio numeric, idreferencia integer, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 489 (class 1255 OID 76076)
-- Name: fn_registrartransacciontipocambio(integer, integer, numeric, numeric, integer, numeric, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_registrartransacciontipocambio(p_idempresa integer, p_idmonedainicio integer, p_montoinicio numeric, p_tipocambio numeric, p_idmonedafin integer, p_montofin numeric, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_transacciontipocambio');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."TransaccionTipoCambio"(
            id, idmonedainicio, montoinicio, tipocambio, idmonedafin, montofin, 
            idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, 
            fechamodificacion, ipmodificacion, idempresa)
    VALUES (maxid, p_idmonedainicio, p_montoinicio, p_tipocambio, p_idmonedafin, p_montofin, 
            p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

return maxid;
end;
$$;


ALTER FUNCTION negocio.fn_registrartransacciontipocambio(p_idempresa integer, p_idmonedainicio integer, p_montoinicio numeric, p_tipocambio numeric, p_idmonedafin integer, p_montofin numeric, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 490 (class 1255 OID 76077)
-- Name: fn_siguienteruta(); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_siguienteruta() RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;

Begin

maxid = nextval('negocio.seq_ruta');

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_siguienteruta() OWNER TO postgres;

--
-- TOC entry 491 (class 1255 OID 76078)
-- Name: fn_telefonosxdireccion(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_telefonosxdireccion(p_idempresa integer, p_iddireccion integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT tel.id, tel.numero, tel.idempresaproveedor
  FROM negocio."TelefonoDireccion" tdir,
       negocio."Telefono" tel
 WHERE tdir.idestadoregistro = 1
   AND tel.idestadoregistro  = 1
   AND tdir.idtelefono       = tel.id
   AND tdir.idempresa        = tel.idempresa
   AND tdir.iddireccion      = p_iddireccion
   AND tdir.idempresa        = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_telefonosxdireccion(p_idempresa integer, p_iddireccion integer) OWNER TO postgres;

--
-- TOC entry 492 (class 1255 OID 76079)
-- Name: fn_telefonosxpersona(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_telefonosxpersona(p_idempresa integer, p_idpersona integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT tel.id, tel.numero, tel.idempresaproveedor
  FROM negocio."TelefonoPersona" tper,
       negocio."Telefono" tel
 WHERE tper.idestadoregistro = 1
   AND tel.idestadoregistro  = 1
   AND tper.idtelefono       = tel.id
   AND tper.idempresa        = tel.idempresa
   AND tper.idpersona        = p_idpersona
   AND tper.idempresa        = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_telefonosxpersona(p_idempresa integer, p_idpersona integer) OWNER TO postgres;

--
-- TOC entry 484 (class 1255 OID 76080)
-- Name: fn_validareliminarcuentasproveedor(integer, integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_validareliminarcuentasproveedor(p_idempresa integer, p_idcuenta integer, p_idproveedor integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;
declare v_pagosACuenta integer;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

SELECT count(1)
  INTO v_pagosACuenta
  FROM negocio."PagosObligacion" po
 INNER JOIN negocio."ObligacionesXPagar" ON oxp.id = po.idobligacion AND oxp.idempresa = po.idempresa
 WHERE oxp.idproveedor    = p_idproveedor
   AND po.idcuentadestino = p_idcuenta
   AND po.idempresa       = p_idempresa;

IF v_pagosACuenta > 0 THEN
	RAISE USING MESSAGE = 'No se puede eliminar la cuenta porque esta asociada a pagos';
END IF;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_validareliminarcuentasproveedor(p_idempresa integer, p_idcuenta integer, p_idproveedor integer) OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- TOC entry 485 (class 1255 OID 76081)
-- Name: fn_maestrobanco(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_maestrobanco() RETURNS integer
    LANGUAGE plpgsql
    AS $$

begin

return 8;
end;
$$;


ALTER FUNCTION public.fn_maestrobanco() OWNER TO postgres;

--
-- TOC entry 493 (class 1255 OID 76082)
-- Name: fn_maestrocontinente(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_maestrocontinente() RETURNS integer
    LANGUAGE plpgsql
    AS $$

begin

return 10;
end;
$$;


ALTER FUNCTION public.fn_maestrocontinente() OWNER TO postgres;

--
-- TOC entry 337 (class 1255 OID 76083)
-- Name: fn_maestrodocumentoadjunto(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_maestrodocumentoadjunto() RETURNS integer
    LANGUAGE plpgsql
    AS $$

begin

return 17;
end;
$$;


ALTER FUNCTION public.fn_maestrodocumentoadjunto() OWNER TO postgres;

--
-- TOC entry 365 (class 1255 OID 76084)
-- Name: fn_maestroestadocivil(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_maestroestadocivil() RETURNS integer
    LANGUAGE plpgsql
    AS $$

begin

return 9;
end;
$$;


ALTER FUNCTION public.fn_maestroestadocivil() OWNER TO postgres;

--
-- TOC entry 376 (class 1255 OID 76085)
-- Name: fn_maestroestadopago(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_maestroestadopago() RETURNS integer
    LANGUAGE plpgsql
    AS $$

begin

return 13;
end;
$$;


ALTER FUNCTION public.fn_maestroestadopago() OWNER TO postgres;

--
-- TOC entry 407 (class 1255 OID 76086)
-- Name: fn_maestroestadoservicio(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_maestroestadoservicio() RETURNS integer
    LANGUAGE plpgsql
    AS $$

begin

return 14;
end;
$$;


ALTER FUNCTION public.fn_maestroestadoservicio() OWNER TO postgres;

--
-- TOC entry 408 (class 1255 OID 76087)
-- Name: fn_maestroformapago(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_maestroformapago() RETURNS integer
    LANGUAGE plpgsql
    AS $$

begin

return 12;
end;
$$;


ALTER FUNCTION public.fn_maestroformapago() OWNER TO postgres;

--
-- TOC entry 426 (class 1255 OID 76088)
-- Name: fn_maestromoneda(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_maestromoneda() RETURNS integer
    LANGUAGE plpgsql
    AS $$

begin

return 18;
end;
$$;


ALTER FUNCTION public.fn_maestromoneda() OWNER TO postgres;

--
-- TOC entry 434 (class 1255 OID 76089)
-- Name: fn_maestrotipocomprobante(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_maestrotipocomprobante() RETURNS integer
    LANGUAGE plpgsql
    AS $$

begin

return 16;
end;
$$;


ALTER FUNCTION public.fn_maestrotipocomprobante() OWNER TO postgres;

--
-- TOC entry 447 (class 1255 OID 76090)
-- Name: fn_maestrotipocuenta(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_maestrotipocuenta() RETURNS integer
    LANGUAGE plpgsql
    AS $$

begin

return 19;
end;
$$;


ALTER FUNCTION public.fn_maestrotipocuenta() OWNER TO postgres;

--
-- TOC entry 448 (class 1255 OID 76091)
-- Name: fn_maestrotipodestino(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_maestrotipodestino() RETURNS integer
    LANGUAGE plpgsql
    AS $$

begin

return 11;
end;
$$;


ALTER FUNCTION public.fn_maestrotipodestino() OWNER TO postgres;

--
-- TOC entry 454 (class 1255 OID 76092)
-- Name: fn_maestrotipodocumento(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_maestrotipodocumento() RETURNS integer
    LANGUAGE plpgsql
    AS $$

begin

return 1;
end;
$$;


ALTER FUNCTION public.fn_maestrotipodocumento() OWNER TO postgres;

--
-- TOC entry 455 (class 1255 OID 76093)
-- Name: fn_maestrotipomoneda(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_maestrotipomoneda() RETURNS integer
    LANGUAGE plpgsql
    AS $$

begin

return 18;
end;
$$;


ALTER FUNCTION public.fn_maestrotipomoneda() OWNER TO postgres;

--
-- TOC entry 465 (class 1255 OID 76094)
-- Name: fn_maestrotiporelacion(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_maestrotiporelacion() RETURNS integer
    LANGUAGE plpgsql
    AS $$

begin

return 21;
end;
$$;


ALTER FUNCTION public.fn_maestrotiporelacion() OWNER TO postgres;

--
-- TOC entry 477 (class 1255 OID 76095)
-- Name: fn_maestrotipotransaccion(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_maestrotipotransaccion() RETURNS integer
    LANGUAGE plpgsql
    AS $$

begin

return 12;
end;
$$;


ALTER FUNCTION public.fn_maestrotipotransaccion() OWNER TO postgres;

--
-- TOC entry 494 (class 1255 OID 76096)
-- Name: fn_maestrotipovia(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_maestrotipovia() RETURNS integer
    LANGUAGE plpgsql
    AS $$

begin

return 2;
end;
$$;


ALTER FUNCTION public.fn_maestrotipovia() OWNER TO postgres;

--
-- TOC entry 495 (class 1255 OID 76097)
-- Name: fn_rubroagenciaviajes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_rubroagenciaviajes() RETURNS integer
    LANGUAGE plpgsql
    AS $$

begin

return 1;
end;
$$;


ALTER FUNCTION public.fn_rubroagenciaviajes() OWNER TO postgres;

--
-- TOC entry 496 (class 1255 OID 76098)
-- Name: fn_tipopersonacliente(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_tipopersonacliente() RETURNS integer
    LANGUAGE plpgsql
    AS $$

begin

return 1;
end;
$$;


ALTER FUNCTION public.fn_tipopersonacliente() OWNER TO postgres;

--
-- TOC entry 497 (class 1255 OID 76099)
-- Name: fn_tipopersonacontacto(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_tipopersonacontacto() RETURNS integer
    LANGUAGE plpgsql
    AS $$

begin

return 3;
end;
$$;


ALTER FUNCTION public.fn_tipopersonacontacto() OWNER TO postgres;

--
-- TOC entry 498 (class 1255 OID 76100)
-- Name: fn_tipopersonaproveedor(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_tipopersonaproveedor() RETURNS integer
    LANGUAGE plpgsql
    AS $$

begin

return 2;
end;
$$;


ALTER FUNCTION public.fn_tipopersonaproveedor() OWNER TO postgres;

SET search_path = reportes, pg_catalog;

--
-- TOC entry 499 (class 1255 OID 76101)
-- Name: fn_re_generalventas(date, date); Type: FUNCTION; Schema: reportes; Owner: postgres
--

CREATE FUNCTION fn_re_generalventas(p_desde date, p_hasta date) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT sd.idtiposervicio, ms.nombre, COUNT(sd.id) AS cantidad, SUM(sd.montototal) as montototal, SUM(montocomision) as montocomision
  FROM negocio."ServicioCabecera" sc
 INNER JOIN negocio."ServicioDetalle" sd  ON sd.idservicio     = sc.id AND sd.idestadoregistro = 1
 INNER JOIN negocio."MaestroServicios" ms ON sd.idtiposervicio = ms.id AND sd.idestadoregistro = 1 AND ms.visible = TRUE
 WHERE sc.idestadoservicio = 2
   AND sc.idestadoregistro = 1
   AND sc.fechacompra BETWEEN p_desde AND p_hasta
 GROUP BY sd.idtiposervicio, ms.nombre;

return micursor;

end;
$$;


ALTER FUNCTION reportes.fn_re_generalventas(p_desde date, p_hasta date) OWNER TO postgres;

--
-- TOC entry 500 (class 1255 OID 76102)
-- Name: fn_re_generalventas(date, date, integer); Type: FUNCTION; Schema: reportes; Owner: postgres
--

CREATE FUNCTION fn_re_generalventas(p_desde date, p_hasta date, p_idvendedor integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT sd.idtiposervicio, ms.nombre, COUNT(sd.id) AS cantidad, SUM(sd.montototal) as montototal, SUM(montocomision) as montocomision
  FROM negocio."ServicioCabecera" sc
 INNER JOIN negocio."ServicioDetalle" sd  ON sd.idservicio     = sc.id AND sd.idestadoregistro = 1
 INNER JOIN negocio."MaestroServicios" ms ON sd.idtiposervicio = ms.id AND sd.idestadoregistro = 1 AND ms.visible = TRUE
 WHERE sc.idestadoservicio = 2
   AND sc.idestadoregistro = 1
   AND sc.fechacompra BETWEEN p_desde AND p_hasta
   AND sc.idvendedor       = COALESCE(p_idvendedor,sc.idvendedor)
 GROUP BY sd.idtiposervicio, ms.nombre;

return micursor;

end;
$$;


ALTER FUNCTION reportes.fn_re_generalventas(p_desde date, p_hasta date, p_idvendedor integer) OWNER TO postgres;

SET search_path = seguridad, pg_catalog;

--
-- TOC entry 501 (class 1255 OID 76103)
-- Name: fn_actualizarclaveusuario(integer, integer, character varying, integer, character varying); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION fn_actualizarclaveusuario(p_idempresa integer, p_idusuario integer, p_credencialnueva character varying, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

update seguridad.usuario
   set credencial            = p_credencialnueva,
       cambiarclave          = true,
       idusuariomodificacion = p_usuariomodificacion,
       fechamodificacion     = fechahoy,
       ipmodificacion        = p_ipmodificacion
 where id 	             = p_idusuario
   and idempresa             = p_idempresa;


return true;

end;
$$;


ALTER FUNCTION seguridad.fn_actualizarclaveusuario(p_idempresa integer, p_idusuario integer, p_credencialnueva character varying, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 502 (class 1255 OID 76104)
-- Name: fn_actualizarcredencialvencida(integer, integer, character varying, integer, character varying); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION fn_actualizarcredencialvencida(p_idempresa integer, p_idusuario integer, p_credencialnueva character varying, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

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
$$;


ALTER FUNCTION seguridad.fn_actualizarcredencialvencida(p_idempresa integer, p_idusuario integer, p_credencialnueva character varying, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 503 (class 1255 OID 76105)
-- Name: fn_actualizarusuario(integer, integer, integer, character varying, character varying, character varying, integer, character varying); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION fn_actualizarusuario(p_idempresa integer, p_id integer, p_rol integer, p_nombres character varying, p_apepaterno character varying, p_apematerno character varying, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

update seguridad.usuario
   set id_rol	  = p_rol,
       nombres               = p_nombres,
       apepaterno            = p_apepaterno,
       apematerno            = p_apematerno,
       idusuariomodificacion = p_usuariomodificacion,
       fechamodificacion     = fechahoy,
       ipmodificacion        = p_ipmodificacion
 where id 	             = p_id
   and idempresa             = p_idempresa;

return true;

end;
$$;


ALTER FUNCTION seguridad.fn_actualizarusuario(p_idempresa integer, p_id integer, p_rol integer, p_nombres character varying, p_apepaterno character varying, p_apematerno character varying, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 504 (class 1255 OID 76106)
-- Name: fn_cambiarclaveusuario(integer, character varying, character varying, character varying, integer, character varying); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION fn_cambiarclaveusuario(p_idempresa integer, p_usuario character varying, p_credencialactual character varying, p_credencialnueva character varying, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare idusuario integer;
declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

select COALESCE(max(id),0) 
  into idusuario
  from seguridad.usuario
 where usuario    = p_usuario
   and credencial = p_credencialactual
   and idempresa  = p_idempresa;

if idusuario = 0 then
 RAISE EXCEPTION 'Informacion de usuario incorrecta';
else
update seguridad.usuario
   set credencial            = p_credencialnueva,
       idusuariomodificacion = p_usuariomodificacion,
       fechamodificacion     = fechahoy,
       ipmodificacion        = p_ipmodificacion
 where id 	             = idusuario
   and idempresa             = p_idempresa;
end if;

return true;

end;
$$;


ALTER FUNCTION seguridad.fn_cambiarclaveusuario(p_idempresa integer, p_usuario character varying, p_credencialactual character varying, p_credencialnueva character varying, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 505 (class 1255 OID 76107)
-- Name: fn_consultarusuarios(character varying); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION fn_consultarusuarios(p_usuario character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
select id, usuario, credencial, id_rol, nombre, nombres, apepaterno, apematerno, cambiarclave, feccaducacredencial, vendedor
  from seguridad.vw_listarusuarios 
 where upper(usuario) = p_usuario;

return micursor;

end;$$;


ALTER FUNCTION seguridad.fn_consultarusuarios(p_usuario character varying) OWNER TO postgres;

--
-- TOC entry 507 (class 1255 OID 76108)
-- Name: fn_ingresarusuario(integer, character varying, character varying, integer, character varying, character varying, character varying, date, boolean, integer, character varying); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION fn_ingresarusuario(p_idempresa integer, p_usuario character varying, p_credencial character varying, p_rol integer, p_nombres character varying, p_apepaterno character varying, p_apematerno character varying, p_fecnacimiento date, p_vendedor boolean, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxusuario integer;
declare fechahoy timestamp with time zone;

begin

select max(id)
  into maxusuario
  from seguridad.usuario
 where idempresa = p_idempresa;

 select current_timestamp AT TIME ZONE 'PET' into fechahoy;

maxusuario = maxusuario + 1;

insert into seguridad.usuario(id,usuario,credencial,id_rol,nombres,apepaterno,apematerno,fecnacimiento,vendedor, idempresa, 
idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, ipmodificacion)
values (maxusuario,p_usuario,p_credencial,p_rol,p_nombres,p_apepaterno,p_apematerno,p_fecnacimiento,p_vendedor, p_idempresa, 
p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return true;

exception
when others then
  return false;

end;
$$;


ALTER FUNCTION seguridad.fn_ingresarusuario(p_idempresa integer, p_usuario character varying, p_credencial character varying, p_rol integer, p_nombres character varying, p_apepaterno character varying, p_apematerno character varying, p_fecnacimiento date, p_vendedor boolean, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 508 (class 1255 OID 76109)
-- Name: fn_iniciosesion(integer, character varying, character varying); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION fn_iniciosesion(p_idempresa integer, p_usuario character varying, p_credencial character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare cantidad integer;

begin

cantidad = 0;

select count(1)
  into cantidad
  from seguridad.usuario usr
 where upper(usr.usuario) = p_usuario
   and usr.credencial     = p_credencial
   and usr.idempresa      = p_idempresa;

if cantidad = 1 then
   return true;
else
   return false;
end if;

exception
when others then
  return false;

end;
$$;


ALTER FUNCTION seguridad.fn_iniciosesion(p_idempresa integer, p_usuario character varying, p_credencial character varying) OWNER TO postgres;

--
-- TOC entry 509 (class 1255 OID 76110)
-- Name: fn_listarusuarios(integer); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION fn_listarusuarios(p_idempresa integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
select * 
  from seguridad.usuario
 where idempresa = p_idempresa;

return micursor;

end;$$;


ALTER FUNCTION seguridad.fn_listarusuarios(p_idempresa integer) OWNER TO postgres;

--
-- TOC entry 510 (class 1255 OID 76111)
-- Name: fn_listarvendedores(integer); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION fn_listarvendedores(p_idempresa integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
select * 
  from seguridad.usuario u
 where u.vendedor  = true
   and u.idempresa = p_idempresa;

return micursor;

end;$$;


ALTER FUNCTION seguridad.fn_listarvendedores(p_idempresa integer) OWNER TO postgres;

--
-- TOC entry 532 (class 1255 OID 76774)
-- Name: fn_puedeagregarusuario(integer); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION fn_puedeagregarusuario(p_idempresa integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

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
$$;


ALTER FUNCTION seguridad.fn_puedeagregarusuario(p_idempresa integer) OWNER TO postgres;

SET search_path = soporte, pg_catalog;

--
-- TOC entry 511 (class 1255 OID 76112)
-- Name: fn_actualizardestino(integer, integer, integer, integer, integer, character varying, character varying, integer, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_actualizardestino(p_idempresa integer, p_id integer, p_idcontinente integer, p_idpais integer, p_idtipodestino integer, p_codigoiata character varying, p_descripcion character varying, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE soporte.destino
   SET idcontinente          = p_idcontinente, 
       idpais                = p_idpais, 
       codigoiata            = p_codigoiata, 
       idtipodestino         = p_idtipodestino, 
       descripcion           = p_descripcion, 
       idusuariomodificacion = p_usuariomodificacion, 
       fechamodificacion     = fechahoy, 
       ipmodificacion        = p_ipmodificacion
 WHERE id                    = p_id
   AND idempresa             = p_idempresa;
 
return true;

end;
$$;


ALTER FUNCTION soporte.fn_actualizardestino(p_idempresa integer, p_id integer, p_idcontinente integer, p_idpais integer, p_idtipodestino integer, p_codigoiata character varying, p_descripcion character varying, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 512 (class 1255 OID 76113)
-- Name: fn_actualizarmaestro(integer, integer, integer, character varying, character varying, character varying, integer, character varying, integer, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_actualizarmaestro(p_idempresa integer, p_id integer, p_idtipo integer, p_nombre character varying, p_descripcion character varying, p_estado character varying, p_orden integer, p_abreviatura character varying, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE soporte."Tablamaestra"
   SET nombre                = p_nombre,
       descripcion           = p_descripcion,
       estado                = p_estado,
       orden                 = p_orden,
       abreviatura           = p_abreviatura,
       idusuariomodificacion = p_usuariomodificacion,
       fechamodificacion     = fechahoy,
       ipmodificacion        = p_ipmodificacion
 WHERE id                    = p_id
   AND idmaestro             = p_idtipo
   AND idempresa             = p_idempresa;

return true;

end;
$$;


ALTER FUNCTION soporte.fn_actualizarmaestro(p_idempresa integer, p_id integer, p_idtipo integer, p_nombre character varying, p_descripcion character varying, p_estado character varying, p_orden integer, p_abreviatura character varying, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 513 (class 1255 OID 76114)
-- Name: fn_actualizarparametro(integer, integer, character varying, character varying, character varying, character varying, boolean, integer, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_actualizarparametro(p_idempresa integer, p_id integer, p_nombre character varying, p_descripcion character varying, p_valor character varying, p_estado character varying, p_editable boolean, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

update soporte."Parametro"
   set nombre                = p_nombre,
       descripcion           = p_descripcion,
       valor                 = p_valor,
       estado                = p_estado,
       editable              = p_editable,
       idusuariomodificacion = p_usuariomodificacion,
       fechamodificacion     = fechahoy,
       ipmodificacion        = p_ipmodificacion
 where id                    = p_id
   and idempresa             = p_idempresa;

return true;

exception
when others then
  return false;

end;
$$;


ALTER FUNCTION soporte.fn_actualizarparametro(p_idempresa integer, p_id integer, p_nombre character varying, p_descripcion character varying, p_valor character varying, p_estado character varying, p_editable boolean, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 514 (class 1255 OID 76115)
-- Name: fn_buscardestinos1(integer, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_buscardestinos1(p_idempresa integer, p_nombre character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT des.id, des.idcontinente, cont.nombre as nombrecontinente, idpais, pai.descripcion as nombrepais, codigoiata, idtipodestino, tipdes.nombre as nombretipdestino, des.descripcion, 
       des.usuariocreacion, des.fechacreacion, des.ipcreacion, des.usuariomodificacion, 
       des.fechamodificacion, des.ipmodificacion, des.idestadoregistro, pai.abreviado
  FROM soporte.destino des,
       soporte."Tablamaestra" cont,
       soporte."Tablamaestra" tipdes,
       soporte.pais pai       
 WHERE des.idestadoregistro = 1
   AND cont.idmaestro       = fn_maestrocontinente
   AND cont.estado          = 'A'
   AND cont.id              = des.idcontinente
   AND cont.idempresa       = des.idempresa
   AND pai.idestadoregistro = 1
   AND pai.id               = des.idpais
   AND pai.idempresa        = des.idempresa
   AND tipdes.idmaestro     = fn_maestrotipodestino()
   AND tipdes.estado        = 'A'
   AND tipdes.id            = des.idtipodestino
   AND tipdes.idempresa     = des.idempresa
   AND des.idempresa        = p_idempresa
   AND des.descripcion      like '%'||p_nombre||'%';

return micursor;

end;
$$;


ALTER FUNCTION soporte.fn_buscardestinos1(p_idempresa integer, p_nombre character varying) OWNER TO postgres;

--
-- TOC entry 515 (class 1255 OID 76116)
-- Name: fn_consultaempresa(character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_consultaempresa(p_nombredominio character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT id, razonsocial, nombrecomercial, nombredominio
  FROM licencia."Empresa"
 WHERE nombredominio = p_nombredominio;


return micursor;

end;
$$;


ALTER FUNCTION soporte.fn_consultaempresa(p_nombredominio character varying) OWNER TO postgres;

--
-- TOC entry 506 (class 1255 OID 76117)
-- Name: fn_consultarconfiguracionservicio(integer, integer); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_consultarconfiguracionservicio(p_idempresa integer, p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT idtiposervicio, muestraaerolinea, muestraempresatransporte, muestrahotel, 
       muestraproveedor, muestradescservicio, muestrafechaservicio, 
       muestrafecharegreso, muestracantidad, muestraprecio, muestraruta, 
       muestracomision, muestraoperador, muestratarifanegociada, muestracodigoreserva, muestranumeroboleto, idempresa
  FROM soporte."ConfiguracionTipoServicio"
 WHERE idestadoregistro = 1
   AND idtiposervicio   = p_idservicio
   AND idempresa        = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION soporte.fn_consultarconfiguracionservicio(p_idempresa integer, p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 516 (class 1255 OID 76118)
-- Name: fn_consultardestino(integer, integer); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_consultardestino(p_idempresa integer, p_iddestino integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT d.id, d.idcontinente, d.idpais, p.descripcion as descpais, d.codigoiata, d.idtipodestino, d.descripcion as descdestino, 
       d.idusuariocreacion, d.fechacreacion, d.ipcreacion, d.idusuariomodificacion, 
       d.fechamodificacion, d.ipmodificacion, p.abreviado
  FROM soporte.destino d,
       soporte.pais p
 WHERE d.idestadoregistro = 1
   AND d.id               = p_iddestino
   AND d.idpais           = p.id
   AND d.idempresa        = p.idempresa
   AND d.idempresa        = p_idempresa
   AND p.idestadoregistro = 1;


return micursor;

end;
$$;


ALTER FUNCTION soporte.fn_consultardestino(p_idempresa integer, p_iddestino integer) OWNER TO postgres;

--
-- TOC entry 517 (class 1255 OID 76119)
-- Name: fn_consultardestinoiata(integer, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_consultardestinoiata(p_idempresa integer, p_codigoiata character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT d.id, d.idcontinente, d.idpais, p.descripcion as descpais, d.codigoiata, d.idtipodestino, d.descripcion as descdestino, 
       p.abreviado
  FROM soporte.destino d,
       soporte.pais p
 WHERE d.idestadoregistro = 1
   AND d.codigoiata       = p_codigoIATA
   AND d.idpais           = p.id
   AND d.idempresa        = p.idempresa
   AND p.idestadoregistro = 1;

return micursor;

end;
$$;


ALTER FUNCTION soporte.fn_consultardestinoiata(p_idempresa integer, p_codigoiata character varying) OWNER TO postgres;

--
-- TOC entry 518 (class 1255 OID 76120)
-- Name: fn_eliminarconfiguracion(integer, integer, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_eliminarconfiguracion(p_idempresa integer, p_usuariomodificacion integer, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

update soporte."ConfiguracionTipoServicio"
   set idestadoregistro      = 0,
       idusuariomodificacion = p_usuariomodificacion,
       fechamodificacion     = fechahoy,
       ipmodificacion        = p_ipmodificacion
 where idempresa             = p_idempresa;

return true;

end;
$$;


ALTER FUNCTION soporte.fn_eliminarconfiguracion(p_idempresa integer, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 519 (class 1255 OID 76121)
-- Name: fn_ingresardestino(integer, integer, integer, integer, character varying, character varying, integer, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_ingresardestino(p_idempresa integer, p_idcontinente integer, p_idpais integer, p_idtipodestino integer, p_codigoiata character varying, p_descripcion character varying, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('soporte.seq_destino');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO soporte.destino(
            id, idcontinente, idpais, codigoiata, idtipodestino, descripcion, 
            idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, 
            fechamodificacion, ipmodificacion, idempresa)
    VALUES (maxid, p_idcontinente, p_idpais, p_codigoiata, p_idtipodestino, p_descripcion, 
            p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_idempresa);

return true;

end;
$$;


ALTER FUNCTION soporte.fn_ingresardestino(p_idempresa integer, p_idcontinente integer, p_idpais integer, p_idtipodestino integer, p_codigoiata character varying, p_descripcion character varying, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 520 (class 1255 OID 76122)
-- Name: fn_ingresardestino(integer, integer, integer, integer, character varying, character varying, boolean, integer, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_ingresardestino(p_idempresa integer, p_idcontinente integer, p_idpais integer, p_idtipodestino integer, p_codigoiata character varying, p_descripcion character varying, p_aplicaigv boolean, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('soporte.seq_destino');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO soporte.destino(
            id, idcontinente, idpais, codigoiata, idtipodestino, descripcion, aplicaigv,
            idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, 
            fechamodificacion, ipmodificacion, idempresa)
    VALUES (maxid, p_idcontinente, p_idpais, p_codigoiata, p_idtipodestino, p_descripcion, p_aplicaigv, 
            p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_idempresa);

return true;

end;
$$;


ALTER FUNCTION soporte.fn_ingresardestino(p_idempresa integer, p_idcontinente integer, p_idpais integer, p_idtipodestino integer, p_codigoiata character varying, p_descripcion character varying, p_aplicaigv boolean, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 521 (class 1255 OID 76123)
-- Name: fn_ingresarhijomaestro(integer, integer, character varying, character varying, character varying, integer, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_ingresarhijomaestro(p_idempresa integer, p_idmaestro integer, p_nombre character varying, p_descripcion character varying, p_abreviatura character varying, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

select max(id)
  into maxid
  from soporte."Tablamaestra"
 where idmaestro = p_idmaestro
   and idempresa = p_idempresa;

if (maxid is null) then
maxid = 0;
end if;

maxid = maxid + 1;

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO soporte."Tablamaestra"(id, idmaestro, nombre, descripcion, abreviatura, orden, estado, idempresa, idusuariocreacion, fechacreacion, ipcreacion, 
idusuariomodificacion, fechamodificacion, ipmodificacion)
values (maxid,p_idmaestro,p_nombre,p_descripcion,p_abreviatura,maxid,'A', p_idempresa, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return true;

end;
$$;


ALTER FUNCTION soporte.fn_ingresarhijomaestro(p_idempresa integer, p_idmaestro integer, p_nombre character varying, p_descripcion character varying, p_abreviatura character varying, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 522 (class 1255 OID 76124)
-- Name: fn_ingresarmaestro(integer, character varying, character varying, integer, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_ingresarmaestro(p_idempresa integer, p_nombre character varying, p_descripcion character varying, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin


select max(id)
  into maxid
  from soporte."Tablamaestra"
 where idmaestro = 0
   and idempresa = p_idempresa;

if (maxid is null) then
maxid = 0;
end if;

maxid = maxid + 1;

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO soporte."Tablamaestra"(id, nombre, descripcion, orden, estado, idempresa, idusuariocreacion, fechacreacion, ipcreacion, 
idusuariomodificacion, fechamodificacion, ipmodificacion)
values (maxid,p_nombre,p_descripcion,maxid,'A', p_idempresa, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return true;

end;
$$;


ALTER FUNCTION soporte.fn_ingresarmaestro(p_idempresa integer, p_nombre character varying, p_descripcion character varying, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 523 (class 1255 OID 76125)
-- Name: fn_ingresarpais(integer, character varying, integer, integer, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_ingresarpais(p_idempresa integer, p_descripcion character varying, p_idcontinente integer, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxpais integer;
declare fechahoy timestamp with time zone;

begin

maxpais = nextval('soporte.seq_pais');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO soporte.pais(
            id, descripcion, idcontinente, idusuariocreacion, fechacreacion, 
            ipcreacion, idusuariomodificacion, fechamodificacion, ipmodificacion, 
            idempresa)
    VALUES (maxpais, p_descripcion, p_idcontinente, p_usuariocreacion, fechahoy, 
            p_ipcreacion, p_usuariocreacion, fechahoy, 
            p_ipcreacion, p_idempresa);

return true;

end;
$$;


ALTER FUNCTION soporte.fn_ingresarpais(p_idempresa integer, p_descripcion character varying, p_idcontinente integer, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 525 (class 1255 OID 76126)
-- Name: fn_ingresarparametro(integer, character varying, character varying, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_ingresarparametro(p_idempresa integer, p_nombre character varying, p_descripcion character varying, p_valor character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxparametro integer;
declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

select max(id)
  into maxparametro
  from soporte."Parametro";

if (maxparametro is null) then
maxparametro = 0;
end if;

maxparametro = maxparametro + 1;

INSERT INTO soporte."Parametro"(id, nombre, descripcion, valor, estado, editable, idempresa, idusuariocreacion, fechacreacion, ipcreacion, idusuariomodificacion, 
fechamodificacion, ipmodificacion)
values (maxparametro,p_nombre,p_descripcion,p_valor,'A',true, p_idempresa, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return true;

end;
$$;


ALTER FUNCTION soporte.fn_ingresarparametro(p_idempresa integer, p_nombre character varying, p_descripcion character varying, p_valor character varying) OWNER TO postgres;

--
-- TOC entry 526 (class 1255 OID 76127)
-- Name: fn_listarconfiguracionservicio(integer); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_listarconfiguracionservicio(p_idempresa integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT idtiposervicio, muestraaerolinea, muestraempresatransporte, muestrahotel, 
       muestraproveedor, muestradescservicio, muestrafechaservicio, 
       muestrafecharegreso, muestracantidad, muestraprecio, muestraruta, 
       muestracomision, muestraoperador, muestratarifanegociada
  FROM soporte."ConfiguracionTipoServicio"
 WHERE idestadoregistro = 1
   AND idempresa        = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION soporte.fn_listarconfiguracionservicio(p_idempresa integer) OWNER TO postgres;

--
-- TOC entry 527 (class 1255 OID 76128)
-- Name: fn_listardestinos(integer); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_listardestinos(p_idempresa integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT des.id, des.idcontinente, cont.nombre as nombrecontinente, des.idpais, pai.descripcion as nombrepais, codigoiata, idtipodestino, tipdes.nombre as nombretipdestino, des.descripcion, 
       des.idusuariocreacion, des.fechacreacion, des.ipcreacion, des.idusuariomodificacion, 
       des.fechamodificacion, des.ipmodificacion, des.idestadoregistro, pai.abreviado
  FROM soporte.destino des,
       soporte."Tablamaestra" cont,
       soporte."Tablamaestra" tipdes,
       soporte.pais pai       
 WHERE des.idestadoregistro = 1
   AND cont.idmaestro       = fn_maestrocontinente()
   AND cont.estado          = 'A'
   AND cont.id              = des.idcontinente
   AND cont.idempresa       = des.idempresa
   AND pai.idestadoregistro = 1
   AND pai.id               = des.idpais
   AND pai.idempresa        = des.idempresa
   AND tipdes.idmaestro     = fn_maestrotipodestino()
   AND tipdes.estado        = 'A'
   AND tipdes.id            = des.idtipodestino
   AND tipdes.idempresa     = des.idempresa
   AND des.idempresa        = p_idempresa
 ORDER BY des.descripcion ASC;

return micursor;

end;
$$;


ALTER FUNCTION soporte.fn_listardestinos(p_idempresa integer) OWNER TO postgres;

--
-- TOC entry 528 (class 1255 OID 76129)
-- Name: fn_listarpaises(integer, integer); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_listarpaises(p_idempresa integer, p_idcontinente integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION soporte.fn_listarpaises(p_idempresa integer, p_idcontinente integer) OWNER TO postgres;

--
-- TOC entry 529 (class 1255 OID 76130)
-- Name: fn_listartiposservicio(integer); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_listartiposservicio(p_idempresa integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT id, nombre
  FROM negocio."MaestroServicios"
 WHERE idestadoregistro = 1
   AND idempresa        = p_idempresa
   --AND id               not in (select idtiposervicio from soporte."ConfiguracionTipoServicio" where idestadoregistro =1)
 ORDER BY id;

return micursor;

end;
$$;


ALTER FUNCTION soporte.fn_listartiposservicio(p_idempresa integer) OWNER TO postgres;

--
-- TOC entry 530 (class 1255 OID 76131)
-- Name: fn_registrarconfiguracionservicio(integer, integer, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, integer, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_registrarconfiguracionservicio(p_idempresa integer, p_idtiposervicio integer, p_muestraaerolinea boolean, p_muestraempresatransporte boolean, p_muestrahotel boolean, p_muestraproveedor boolean, p_muestradescservicio boolean, p_muestrafechaservicio boolean, p_muestrafecharegreso boolean, p_muestracantidad boolean, p_muestraprecio boolean, p_muestraruta boolean, p_muestracomision boolean, p_muestraoperador boolean, p_muestratarifanegociada boolean, p_muestracodigoreserva boolean, p_muestranumeroboleto boolean, p_usuariocreacion integer, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO soporte."ConfiguracionTipoServicio"(
            idtiposervicio, muestraaerolinea, muestraempresatransporte, muestrahotel, 
            muestraproveedor, muestradescservicio, muestrafechaservicio, 
            muestrafecharegreso, muestracantidad, muestraprecio, muestraruta, 
            muestracomision, muestraoperador, muestratarifanegociada, muestracodigoreserva, muestranumeroboleto, idusuariocreacion, 
            fechacreacion, ipcreacion, idusuariomodificacion, fechamodificacion, 
            ipmodificacion, idempresa)
    VALUES (p_idtiposervicio, p_muestraaerolinea, p_muestraempresatransporte, p_muestrahotel, 
            p_muestraproveedor, p_muestradescservicio, p_muestrafechaservicio, 
            p_muestrafecharegreso, p_muestracantidad, p_muestraprecio, p_muestraruta, 
            p_muestracomision, p_muestraoperador, p_muestratarifanegociada, p_muestracodigoreserva, p_muestranumeroboleto, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idempresa);

return true;

end;
$$;


ALTER FUNCTION soporte.fn_registrarconfiguracionservicio(p_idempresa integer, p_idtiposervicio integer, p_muestraaerolinea boolean, p_muestraempresatransporte boolean, p_muestrahotel boolean, p_muestraproveedor boolean, p_muestradescservicio boolean, p_muestrafechaservicio boolean, p_muestrafecharegreso boolean, p_muestracantidad boolean, p_muestraprecio boolean, p_muestraruta boolean, p_muestracomision boolean, p_muestraoperador boolean, p_muestratarifanegociada boolean, p_muestracodigoreserva boolean, p_muestranumeroboleto boolean, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 531 (class 1255 OID 76132)
-- Name: fn_siguientesequencia(); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_siguientesequencia() RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;

begin

maxid = nextval('soporte.seq_comun');

return maxid;

end;
$$;


ALTER FUNCTION soporte.fn_siguientesequencia() OWNER TO postgres;

SET search_path = auditoria, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 174 (class 1259 OID 76133)
-- Name: eventosesionsistema; Type: TABLE; Schema: auditoria; Owner: postgres; Tablespace: 
--

CREATE TABLE eventosesionsistema (
    id integer NOT NULL,
    idusuario integer NOT NULL,
    usuario character varying(100) NOT NULL,
    fecharegistro timestamp with time zone NOT NULL,
    idtipoevento integer NOT NULL,
    idempresa integer NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone,
    ipcreacion character varying(15),
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone,
    ipmodificacion character varying(15),
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE auditoria.eventosesionsistema OWNER TO postgres;

--
-- TOC entry 175 (class 1259 OID 76137)
-- Name: seq_eventosesionsistema; Type: SEQUENCE; Schema: auditoria; Owner: postgres
--

CREATE SEQUENCE seq_eventosesionsistema
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auditoria.seq_eventosesionsistema OWNER TO postgres;

SET search_path = licencia, pg_catalog;

--
-- TOC entry 176 (class 1259 OID 76139)
-- Name: Contrato; Type: TABLE; Schema: licencia; Owner: postgres; Tablespace: 
--

CREATE TABLE "Contrato" (
    id integer NOT NULL,
    fechainicio date NOT NULL,
    fechafin date NOT NULL,
    precioxusuario numeric(12,2) NOT NULL,
    nrousuarios integer NOT NULL,
    serial text,
    idempresa integer NOT NULL,
    idestado integer DEFAULT 1 NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE licencia."Contrato" OWNER TO postgres;

--
-- TOC entry 177 (class 1259 OID 76145)
-- Name: Empresa; Type: TABLE; Schema: licencia; Owner: postgres; Tablespace: 
--

CREATE TABLE "Empresa" (
    id integer NOT NULL,
    razonsocial character varying(100) NOT NULL,
    nombrecomercial character varying(100),
    nombredominio character varying(100) NOT NULL,
    idtipodocumento integer NOT NULL,
    numerodocumento character varying(15) NOT NULL,
    nombrecontacto character varying(200) NOT NULL
);


ALTER TABLE licencia."Empresa" OWNER TO postgres;

--
-- TOC entry 278 (class 1259 OID 76775)
-- Name: Tablamaestra; Type: TABLE; Schema: licencia; Owner: postgres; Tablespace: 
--

CREATE TABLE "Tablamaestra" (
    id integer NOT NULL,
    idmaestro integer DEFAULT 0 NOT NULL,
    nombre character varying(50),
    descripcion character varying(100),
    orden integer,
    estado character(1),
    abreviatura character varying(5),
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE licencia."Tablamaestra" OWNER TO postgres;

--
-- TOC entry 279 (class 1259 OID 76808)
-- Name: seq_contrato; Type: SEQUENCE; Schema: licencia; Owner: postgres
--

CREATE SEQUENCE seq_contrato
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE licencia.seq_contrato OWNER TO postgres;

--
-- TOC entry 280 (class 1259 OID 83195)
-- Name: seq_empresa; Type: SEQUENCE; Schema: licencia; Owner: postgres
--

CREATE SEQUENCE seq_empresa
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE licencia.seq_empresa OWNER TO postgres;

SET search_path = negocio, pg_catalog;

--
-- TOC entry 178 (class 1259 OID 76151)
-- Name: ArchivoCargado; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ArchivoCargado" (
    id integer NOT NULL,
    nombrearchivo character varying(100) NOT NULL,
    nombrereporte character varying(100) NOT NULL,
    idproveedor integer NOT NULL,
    numerofilas integer NOT NULL,
    numerocolumnas integer NOT NULL,
    idmoneda integer NOT NULL,
    montosubtotal numeric(12,4) NOT NULL,
    montoigv numeric(12,4) NOT NULL,
    montototal numeric(12,4) NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer
);


ALTER TABLE negocio."ArchivoCargado" OWNER TO postgres;

--
-- TOC entry 179 (class 1259 OID 76155)
-- Name: ComprobanteAdicional; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ComprobanteAdicional" (
    id integer NOT NULL,
    idservicio integer NOT NULL,
    idtipocomprobante integer NOT NULL,
    numerocomprobante character varying(20) NOT NULL,
    idtitular integer,
    detallecomprobante text,
    fechacomprobante date,
    totaligv numeric(12,3),
    totalcomprobante numeric(12,3),
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."ComprobanteAdicional" OWNER TO postgres;

--
-- TOC entry 180 (class 1259 OID 76162)
-- Name: ComprobanteGenerado; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ComprobanteGenerado" (
    id integer NOT NULL,
    idservicio integer NOT NULL,
    idtipocomprobante integer NOT NULL,
    numerocomprobante character varying(20) NOT NULL,
    idtitular integer NOT NULL,
    fechacomprobante date,
    idmoneda integer,
    totaligv numeric(12,3),
    totalcomprobante numeric(12,3),
    tienedetraccion boolean,
    tieneretencion boolean,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer
);


ALTER TABLE negocio."ComprobanteGenerado" OWNER TO postgres;

--
-- TOC entry 181 (class 1259 OID 76166)
-- Name: ComprobanteObligacion; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ComprobanteObligacion" (
    idcomprobante integer NOT NULL,
    idobligacion integer NOT NULL,
    iddetalleservicio integer NOT NULL,
    idservicio integer NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."ComprobanteObligacion" OWNER TO postgres;

--
-- TOC entry 182 (class 1259 OID 76170)
-- Name: CorreoElectronico; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "CorreoElectronico" (
    id integer NOT NULL,
    correo character varying(100) NOT NULL,
    idpersona integer NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone,
    ipcreacion character varying(15),
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone,
    ipmodificacion character varying(15),
    idestadoregistro integer DEFAULT 1 NOT NULL,
    recibirpromociones boolean DEFAULT false,
    idempresa integer
);


ALTER TABLE negocio."CorreoElectronico" OWNER TO postgres;

--
-- TOC entry 183 (class 1259 OID 76175)
-- Name: CronogramaPago; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "CronogramaPago" (
    nrocuota integer NOT NULL,
    idservicio integer NOT NULL,
    fechavencimiento date NOT NULL,
    capital numeric NOT NULL,
    interes numeric NOT NULL,
    totalcuota numeric NOT NULL,
    idestadocuota integer NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer
);


ALTER TABLE negocio."CronogramaPago" OWNER TO postgres;

--
-- TOC entry 184 (class 1259 OID 76182)
-- Name: CuentaBancaria; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "CuentaBancaria" (
    id integer NOT NULL,
    nombrecuenta character varying(40) NOT NULL,
    numerocuenta character varying(20) NOT NULL,
    idtipocuenta integer NOT NULL,
    idbanco integer,
    idmoneda integer NOT NULL,
    saldocuenta numeric(20,6) DEFAULT 0.000000 NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."CuentaBancaria" OWNER TO postgres;

--
-- TOC entry 185 (class 1259 OID 76187)
-- Name: DetalleArchivoCargado; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "DetalleArchivoCargado" (
    id integer NOT NULL,
    idarchivo integer NOT NULL,
    campo1 character varying(100),
    campo2 character varying(100),
    campo3 character varying(100),
    campo4 character varying(100),
    campo5 character varying(100),
    campo6 character varying(100),
    campo7 character varying(100),
    campo8 character varying(100),
    campo9 character varying(100),
    campo10 character varying(100),
    campo11 character varying(100),
    campo12 character varying(100),
    campo13 character varying(100),
    campo14 character varying(100),
    campo15 character varying(100),
    campo16 character varying(100),
    campo17 character varying(100),
    campo18 character varying(100),
    campo19 character varying(100),
    campo20 character varying(100),
    seleccionado boolean DEFAULT false NOT NULL,
    idtipocomprobante integer,
    numerocomprobante character varying(20),
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer
);


ALTER TABLE negocio."DetalleArchivoCargado" OWNER TO postgres;

--
-- TOC entry 186 (class 1259 OID 76195)
-- Name: DetalleComprobanteGenerado; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "DetalleComprobanteGenerado" (
    id integer NOT NULL,
    idserviciodetalle integer NOT NULL,
    idcomprobante integer NOT NULL,
    cantidad integer NOT NULL,
    detalleconcepto character varying(300),
    preciounitario numeric(12,3),
    totaldetalle numeric(12,3),
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer
);


ALTER TABLE negocio."DetalleComprobanteGenerado" OWNER TO postgres;

--
-- TOC entry 187 (class 1259 OID 76199)
-- Name: Direccion; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "Direccion" (
    id integer NOT NULL,
    idvia integer NOT NULL,
    nombrevia character varying(50),
    numero character varying(10),
    interior character varying(10),
    manzana character varying(10),
    lote character varying(10),
    principal character varying(1),
    idubigeo character(6),
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character varying(50) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character varying(50) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    observacion character varying(300),
    referencia character varying(300),
    idpais integer NOT NULL,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."Direccion" OWNER TO postgres;

--
-- TOC entry 188 (class 1259 OID 76206)
-- Name: DocumentoAdjuntoServicio; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "DocumentoAdjuntoServicio" (
    id integer NOT NULL,
    idservicio integer NOT NULL,
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
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."DocumentoAdjuntoServicio" OWNER TO postgres;

--
-- TOC entry 189 (class 1259 OID 76213)
-- Name: EventoObsAnuServicio; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "EventoObsAnuServicio" (
    id integer NOT NULL,
    idtipoevento integer NOT NULL,
    comentario character varying(300) NOT NULL,
    idservicio integer NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."EventoObsAnuServicio" OWNER TO postgres;

--
-- TOC entry 190 (class 1259 OID 76217)
-- Name: MaestroServicios; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "MaestroServicios" (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    desccorta character varying(100),
    desclarga character varying(300),
    requierefee boolean DEFAULT false NOT NULL,
    idmaeserfee integer,
    pagaimpto boolean DEFAULT false NOT NULL,
    idmaeserimpto integer,
    cargacomision boolean DEFAULT false NOT NULL,
    cargaigv boolean DEFAULT false NOT NULL,
    comisionporcen boolean DEFAULT false NOT NULL,
    valorporcomision numeric,
    esimpuesto boolean DEFAULT false NOT NULL,
    esfee boolean DEFAULT false NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idparametroasociado integer,
    visible boolean DEFAULT true NOT NULL,
    esserviciopadre boolean DEFAULT false NOT NULL,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."MaestroServicios" OWNER TO postgres;

--
-- TOC entry 191 (class 1259 OID 76233)
-- Name: MovimientoCuenta; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "MovimientoCuenta" (
    id integer NOT NULL,
    idcuenta integer NOT NULL,
    idtipomovimiento integer NOT NULL,
    idtransaccion integer NOT NULL,
    descripcionnovimiento character varying(100),
    importemovimiento numeric(20,6) DEFAULT 0.000000 NOT NULL,
    idautorizador integer,
    idmovimientopadre integer,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."MovimientoCuenta" OWNER TO postgres;

--
-- TOC entry 192 (class 1259 OID 76238)
-- Name: ObligacionesXPagar; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ObligacionesXPagar" (
    id integer NOT NULL,
    idtipocomprobante integer NOT NULL,
    numerocomprobante character varying(20) NOT NULL,
    idproveedor integer NOT NULL,
    fechacomprobante date NOT NULL,
    fechapago date,
    detallecomprobante character varying(300),
    totaligv numeric(12,3) NOT NULL,
    totalcomprobante numeric(12,3) NOT NULL,
    saldocomprobante numeric(12,3) NOT NULL,
    tienedetraccion boolean,
    tieneretencion boolean,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer NOT NULL,
    idmoneda integer NOT NULL
);


ALTER TABLE negocio."ObligacionesXPagar" OWNER TO postgres;

--
-- TOC entry 193 (class 1259 OID 76242)
-- Name: PagosObligacion; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "PagosObligacion" (
    idpago integer NOT NULL,
    idobligacion integer NOT NULL,
    idformapago integer NOT NULL,
    idcuentaorigen integer,
    idcuentadestino integer,
    idbancotarjeta integer,
    idtipotarjeta integer,
    nombretitular character varying(50),
    numerotarjeta character varying(16),
    fechapago date NOT NULL,
    numerooperacion character varying(20),
    montopagado numeric(12,3) NOT NULL,
    idmoneda integer NOT NULL,
    sustentopago bytea,
    tipocontenido character varying(50),
    nombrearchivo character varying(20),
    extensionarchivo character varying(10),
    comentario character varying(300),
    espagodetraccion boolean,
    espagoretencion boolean,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer
);


ALTER TABLE negocio."PagosObligacion" OWNER TO postgres;

--
-- TOC entry 194 (class 1259 OID 76249)
-- Name: PagosServicio; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "PagosServicio" (
    idpago integer NOT NULL,
    idservicio integer NOT NULL,
    idformapago integer NOT NULL,
    idcuentadestino integer,
    idbancotarjeta integer,
    idtipotarjeta integer,
    nombretitular character varying(50),
    numerotarjeta character varying(16),
    numerooperacion character varying(20),
    fechapago date NOT NULL,
    montopagado numeric(12,3) NOT NULL,
    idmoneda integer NOT NULL,
    sustentopago bytea,
    tipocontenido character varying(50),
    nombrearchivo character varying(20),
    extensionarchivo character varying(10),
    comentario character varying(300),
    espagodetraccion boolean,
    espagoretencion boolean,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."PagosServicio" OWNER TO postgres;

--
-- TOC entry 195 (class 1259 OID 76256)
-- Name: PasajeroServicio; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "PasajeroServicio" (
    id bigint NOT NULL,
    idtipodocumento integer,
    numerodocumento character varying(11),
    nombres character varying(100) NOT NULL,
    apellidopaterno character varying(50) NOT NULL,
    apellidomaterno character varying(50),
    correoelectronico character varying(100),
    telefono1 character varying(10),
    telefono2 character varying(10),
    nropaxfrecuente character varying(20),
    idaerolinea integer,
    idrelacion integer NOT NULL,
    codigoreserva character varying(10),
    numeroboleto character varying(20),
    fechavctopasaporte date,
    fechanacimiento date,
    idserviciodetalle integer NOT NULL,
    idservicio integer NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idpais integer,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."PasajeroServicio" OWNER TO postgres;

--
-- TOC entry 196 (class 1259 OID 76260)
-- Name: Persona; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "Persona" (
    id bigint NOT NULL,
    idtipopersona integer NOT NULL,
    nombres character varying(100),
    apellidopaterno character varying(50),
    apellidomaterno character varying(50),
    idgenero character varying(1),
    idestadocivil integer,
    idtipodocumento integer,
    numerodocumento character varying(15),
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    fecnacimiento date,
    nropasaporte character varying(12),
    fecvctopasaporte date,
    idnacionalidad integer,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."Persona" OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 76264)
-- Name: PersonaAdicional; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "PersonaAdicional" (
    idpersona integer NOT NULL,
    idrubro integer,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."PersonaAdicional" OWNER TO postgres;

--
-- TOC entry 198 (class 1259 OID 76268)
-- Name: PersonaContactoProveedor; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "PersonaContactoProveedor" (
    idproveedor integer NOT NULL,
    idcontacto integer NOT NULL,
    idarea integer,
    anexo character varying(5),
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."PersonaContactoProveedor" OWNER TO postgres;

--
-- TOC entry 199 (class 1259 OID 76272)
-- Name: PersonaDireccion; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "PersonaDireccion" (
    idpersona bigint NOT NULL,
    iddireccion integer NOT NULL,
    idtipopersona integer NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character varying(50) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character varying(50) NOT NULL
);


ALTER TABLE negocio."PersonaDireccion" OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 76276)
-- Name: Personapotencial; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "Personapotencial" (
    id integer NOT NULL,
    nombres character varying(50) NOT NULL,
    apellidopaterno character varying(20) NOT NULL,
    apellidomaterno character varying(20),
    telefono character varying(12),
    correoelectronico character varying(100),
    idnovios integer NOT NULL,
    fecnacimiento date,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."Personapotencial" OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 76280)
-- Name: ProgramaNovios; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ProgramaNovios" (
    id integer NOT NULL,
    codigonovios character varying(20) NOT NULL,
    idnovia integer NOT NULL,
    idnovio integer NOT NULL,
    iddestino integer NOT NULL,
    fechaboda date NOT NULL,
    fechaviaje date NOT NULL,
    fechashower date,
    idmoneda integer NOT NULL,
    cuotainicial numeric NOT NULL,
    dias integer NOT NULL,
    noches integer NOT NULL,
    observaciones text,
    montototal numeric NOT NULL,
    idservicio integer NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character varying(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character varying(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."ProgramaNovios" OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 76287)
-- Name: ProveedorCuentaBancaria; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ProveedorCuentaBancaria" (
    id integer NOT NULL,
    nombrecuenta character varying(40) NOT NULL,
    numerocuenta character varying(20) NOT NULL,
    idtipocuenta integer NOT NULL,
    idbanco integer NOT NULL,
    idmoneda integer NOT NULL,
    idproveedor integer NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character varying(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character varying(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."ProveedorCuentaBancaria" OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 76291)
-- Name: ProveedorPersona; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ProveedorPersona" (
    idproveedor integer NOT NULL,
    idtipoproveedor integer NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character varying(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character varying(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    nombrecomercial character varying(100),
    idempresa integer NOT NULL
);


ALTER TABLE negocio."ProveedorPersona" OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 76295)
-- Name: ProveedorTipoServicio; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ProveedorTipoServicio" (
    idproveedor integer NOT NULL,
    idtiposervicio integer NOT NULL,
    idproveedorservicio integer NOT NULL,
    porcencomnacional numeric NOT NULL,
    porcencominternacional numeric,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character varying(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character varying(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer
);


ALTER TABLE negocio."ProveedorTipoServicio" OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 76302)
-- Name: RutaServicio; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "RutaServicio" (
    id integer NOT NULL,
    idtramo integer NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer
);


ALTER TABLE negocio."RutaServicio" OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 76306)
-- Name: SaldosServicio; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "SaldosServicio" (
    idsaldoservicio integer NOT NULL,
    idservicio integer NOT NULL,
    idpago integer,
    fechaservicio date NOT NULL,
    montototalservicio numeric(12,3) NOT NULL,
    montosaldoservicio numeric(12,3) NOT NULL,
    idtransaccionreferencia integer,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."SaldosServicio" OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 76310)
-- Name: ServicioCabecera; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ServicioCabecera" (
    id bigint NOT NULL,
    idcliente1 integer NOT NULL,
    idcliente2 integer,
    fechacompra date NOT NULL,
    idestadopago integer,
    idestadoservicio integer,
    nrocuotas integer,
    tea numeric,
    valorcuota numeric,
    fechaprimercuota date,
    fechaultcuota date,
    idmoneda integer NOT NULL,
    montocomisiontotal numeric NOT NULL,
    montototaligv numeric NOT NULL,
    montototal numeric NOT NULL,
    montototalfee numeric NOT NULL,
    idvendedor integer NOT NULL,
    observaciones text,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    generocomprobantes boolean DEFAULT false NOT NULL,
    guardorelacioncomprobantes boolean DEFAULT false NOT NULL,
    codigonovios character varying(20),
    idempresa integer NOT NULL
);


ALTER TABLE negocio."ServicioCabecera" OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 76319)
-- Name: ServicioDetalle; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ServicioDetalle" (
    id bigint NOT NULL,
    idtiposervicio integer NOT NULL,
    descripcionservicio character varying(300) NOT NULL,
    idservicio integer NOT NULL,
    fechaida timestamp with time zone NOT NULL,
    fecharegreso timestamp with time zone,
    cantidad integer NOT NULL,
    idempresaproveedor integer,
    descripcionproveedor character varying(100),
    idempresaoperadora integer,
    descripcionoperador character varying(100),
    idempresatransporte integer,
    descripcionemptransporte character varying(100),
    idhotel integer,
    decripcionhotel character varying(100),
    idruta integer,
    idmoneda integer NOT NULL,
    preciobaseanterior numeric NOT NULL,
    tipocambio numeric(9,6) NOT NULL,
    preciobase numeric NOT NULL,
    editocomision boolean DEFAULT false,
    tarifanegociada boolean DEFAULT false,
    valorcomision numeric,
    tipovalorcomision integer,
    aplicarigvcomision boolean DEFAULT true,
    subtotalcomision numeric(12,6),
    montoigvcomision numeric(12,6),
    montototalcomision numeric(12,6),
    montototal numeric NOT NULL,
    idservdetdepende integer,
    aplicaigv boolean DEFAULT true NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."ServicioDetalle" OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 76330)
-- Name: ServicioMaestroServicio; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ServicioMaestroServicio" (
    idservicio integer NOT NULL,
    idserviciodepende integer NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character varying(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."ServicioMaestroServicio" OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 76334)
-- Name: Telefono; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "Telefono" (
    id integer NOT NULL,
    numero character varying(9) NOT NULL,
    idempresaproveedor integer NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone,
    ipcreacion character varying(15),
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone,
    ipmodificacion character varying(15),
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer
);


ALTER TABLE negocio."Telefono" OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 76338)
-- Name: TelefonoDireccion; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "TelefonoDireccion" (
    idtelefono integer NOT NULL,
    iddireccion integer NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone,
    ipcreacion character varying(15),
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone,
    ipmodificacion character varying(15),
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer
);


ALTER TABLE negocio."TelefonoDireccion" OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 76342)
-- Name: TelefonoPersona; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "TelefonoPersona" (
    idtelefono integer NOT NULL,
    idpersona integer NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone,
    ipcreacion character varying(15),
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone,
    ipmodificacion character varying(15),
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."TelefonoPersona" OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 76346)
-- Name: TipoCambio; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "TipoCambio" (
    id integer NOT NULL,
    fechatipocambio date NOT NULL,
    idmonedaorigen integer NOT NULL,
    idmonedadestino integer NOT NULL,
    montocambio numeric(9,6) NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."TipoCambio" OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 76350)
-- Name: Tramo; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "Tramo" (
    id integer NOT NULL,
    idorigen integer NOT NULL,
    descripcionorigen character varying(100) NOT NULL,
    fechasalida timestamp with time zone NOT NULL,
    iddestino integer NOT NULL,
    descripciondestino character varying(100) NOT NULL,
    fechallegada timestamp with time zone NOT NULL,
    preciobase numeric,
    idaerolinea integer NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."Tramo" OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 76357)
-- Name: TransaccionTipoCambio; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "TransaccionTipoCambio" (
    id integer NOT NULL,
    idmonedainicio integer,
    montoinicio numeric(15,2) NOT NULL,
    tipocambio numeric(9,6) NOT NULL,
    idmonedafin integer,
    montofin numeric(15,2) NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer NOT NULL
);


ALTER TABLE negocio."TransaccionTipoCambio" OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 76361)
-- Name: seq_archivocargado; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_archivocargado
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_archivocargado OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 76363)
-- Name: seq_comprobanteadicional; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_comprobanteadicional
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_comprobanteadicional OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 76365)
-- Name: seq_comprobantegenerado; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_comprobantegenerado
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_comprobantegenerado OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 76367)
-- Name: seq_consolidador; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_consolidador
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_consolidador OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 76369)
-- Name: seq_correoelectronico; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_correoelectronico
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_correoelectronico OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 76371)
-- Name: seq_cuentabancaria; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_cuentabancaria
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_cuentabancaria OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 76373)
-- Name: seq_cuentabancariaproveedor; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_cuentabancariaproveedor
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_cuentabancariaproveedor OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 76375)
-- Name: seq_detallearchivocargado; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_detallearchivocargado
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_detallearchivocargado OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 76377)
-- Name: seq_detallecomprobantegenerado; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_detallecomprobantegenerado
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_detallecomprobantegenerado OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 76379)
-- Name: seq_direccion; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_direccion
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_direccion OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 76381)
-- Name: seq_documentoservicio; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_documentoservicio
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_documentoservicio OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 76383)
-- Name: seq_eventoservicio; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_eventoservicio
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_eventoservicio OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 76385)
-- Name: seq_maestroservicio; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_maestroservicio
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_maestroservicio OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 76387)
-- Name: seq_movimientocuenta; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_movimientocuenta
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_movimientocuenta OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 76389)
-- Name: seq_novios; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_novios
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_novios OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 76391)
-- Name: seq_obligacionxpagar; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_obligacionxpagar
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_obligacionxpagar OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 76393)
-- Name: seq_pago; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_pago
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_pago OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 76395)
-- Name: seq_pax; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_pax
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_pax OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 76397)
-- Name: seq_persona; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_persona
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_persona OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 76399)
-- Name: seq_personapotencial; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_personapotencial
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_personapotencial OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 76401)
-- Name: seq_ruta; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_ruta
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_ruta OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 76403)
-- Name: seq_salsoservicio; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_salsoservicio
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_salsoservicio OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 76405)
-- Name: seq_serviciocabecera; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_serviciocabecera
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_serviciocabecera OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 76407)
-- Name: seq_serviciodetalle; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_serviciodetalle
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_serviciodetalle OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 76409)
-- Name: seq_serviciosnovios; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_serviciosnovios
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_serviciosnovios OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 76411)
-- Name: seq_telefono; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_telefono
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_telefono OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 76413)
-- Name: seq_tipocambio; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_tipocambio
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_tipocambio OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 76415)
-- Name: seq_tramo; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_tramo
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_tramo OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 76417)
-- Name: seq_transacciontipocambio; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_transacciontipocambio
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_transacciontipocambio OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 76419)
-- Name: vw_clientesnova; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_clientesnova AS
    SELECT per.id, per.idtipopersona, per.nombres, per.apellidopaterno, per.apellidomaterno, per.idgenero, per.idestadocivil, per.idtipodocumento, per.numerodocumento, per.idusuariocreacion, per.fechacreacion, per.ipcreacion, per.idusuariomodificacion, per.fechamodificacion, per.ipmodificacion, per.idestadoregistro, per.fecnacimiento, per.idempresa FROM "Persona" per WHERE ((per.idestadoregistro = 1) AND (per.idtipopersona = 1));


ALTER TABLE negocio.vw_clientesnova OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 76423)
-- Name: vw_consultacontacto; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_consultacontacto AS
    SELECT pro.id, pro.nombres, pro.apellidopaterno, pro.apellidomaterno, pro.idgenero, pro.idestadocivil, pro.idtipodocumento, pro.numerodocumento, pro.idusuariocreacion, pro.fechacreacion, pro.ipcreacion, pro.idempresa FROM "Persona" pro WHERE ((pro.idtipopersona = 3) AND (pro.idestadoregistro = 1));


ALTER TABLE negocio.vw_consultacontacto OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 76427)
-- Name: vw_consultacorreocontacto; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_consultacorreocontacto AS
    SELECT cor.id, cor.correo, cor.idpersona, cor.recibirpromociones, cor.idusuariocreacion, cor.fechacreacion, cor.ipcreacion, cor.idusuariomodificacion, cor.fechamodificacion, cor.ipmodificacion, cor.idempresa FROM "CorreoElectronico" cor WHERE (cor.idestadoregistro = 1);


ALTER TABLE negocio.vw_consultacorreocontacto OWNER TO postgres;

SET search_path = soporte, pg_catalog;

--
-- TOC entry 248 (class 1259 OID 76431)
-- Name: ubigeo; Type: TABLE; Schema: soporte; Owner: postgres; Tablespace: 
--

CREATE TABLE ubigeo (
    id character varying(6) NOT NULL,
    iddepartamento character varying(2),
    idprovincia character varying(2),
    iddistrito character varying(2),
    descripcion character varying(50),
    idempresa integer NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone,
    ipcreacion character varying(15),
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone,
    ipmodificacion character varying(15),
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE soporte.ubigeo OWNER TO postgres;

SET search_path = negocio, pg_catalog;

--
-- TOC entry 249 (class 1259 OID 76435)
-- Name: vw_consultadireccionproveedor; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_consultadireccionproveedor AS
    SELECT dir.id, dir.idvia, dir.nombrevia, dir.numero, dir.interior, dir.manzana, dir.lote, dir.principal, dir.idubigeo, dir.idusuariocreacion, dir.fechacreacion, dir.ipcreacion, dir.idpais, dep.iddepartamento, dep.descripcion AS departamento, pro.idprovincia, pro.descripcion AS provincia, dis.iddistrito, dis.descripcion AS distrito, pdir.idpersona, dir.observacion, dir.referencia, dir.idempresa FROM (((("Direccion" dir JOIN "PersonaDireccion" pdir ON (((pdir.idestadoregistro = 1) AND (dir.id = pdir.iddireccion)))) LEFT JOIN soporte.ubigeo dep ON (((((("substring"((dir.idubigeo)::text, 1, 2) || '0000'::text) = (dep.id)::text) AND ((dep.iddepartamento)::text <> '00'::text)) AND ((dep.idprovincia)::text = '00'::text)) AND ((dep.iddistrito)::text = '00'::text)))) LEFT JOIN soporte.ubigeo pro ON (((((("substring"((dir.idubigeo)::text, 1, 4) || '00'::text) = (pro.id)::text) AND ((pro.iddepartamento)::text <> '00'::text)) AND ((pro.idprovincia)::text <> '00'::text)) AND ((pro.iddistrito)::text = '00'::text)))) LEFT JOIN soporte.ubigeo dis ON (((dis.id)::bpchar = dir.idubigeo))) WHERE (dir.idestadoregistro = 1);


ALTER TABLE negocio.vw_consultadireccionproveedor OWNER TO postgres;

SET search_path = soporte, pg_catalog;

--
-- TOC entry 250 (class 1259 OID 76440)
-- Name: pais; Type: TABLE; Schema: soporte; Owner: postgres; Tablespace: 
--

CREATE TABLE pais (
    id integer NOT NULL,
    descripcion character varying(100),
    idcontinente integer NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character varying(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character varying(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    abreviado character varying(2),
    idpais integer,
    idempresa integer
);


ALTER TABLE soporte.pais OWNER TO postgres;

SET search_path = negocio, pg_catalog;

--
-- TOC entry 251 (class 1259 OID 76444)
-- Name: vw_consultaproveedor; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_consultaproveedor AS
    SELECT pro.id, pro.nombres, pro.apellidopaterno, pro.apellidomaterno, pper.nombrecomercial, pro.idgenero, pro.idestadocivil, pro.idtipodocumento, pro.numerodocumento, pro.idusuariocreacion, pro.fechacreacion, pro.ipcreacion, ppro.idrubro, pper.idtipoproveedor, pro.idnacionalidad, pai.descripcion AS descnacionalidad, pro.idempresa FROM ((("Persona" pro JOIN "PersonaAdicional" ppro ON (((ppro.idestadoregistro = 1) AND (pro.idtipopersona = public.fn_tipopersonaproveedor())))) JOIN "ProveedorPersona" pper ON (((pro.id = ppro.idpersona) AND (pper.idproveedor = pro.id)))) LEFT JOIN soporte.pais pai ON ((pro.idnacionalidad = pai.id))) WHERE (pro.idestadoregistro = 1);


ALTER TABLE negocio.vw_consultaproveedor OWNER TO postgres;

SET search_path = soporte, pg_catalog;

--
-- TOC entry 252 (class 1259 OID 76449)
-- Name: Tablamaestra; Type: TABLE; Schema: soporte; Owner: postgres; Tablespace: 
--

CREATE TABLE "Tablamaestra" (
    id integer NOT NULL,
    idmaestro integer DEFAULT 0 NOT NULL,
    nombre character varying(50),
    descripcion character varying(100),
    orden integer,
    estado character(1),
    abreviatura character varying(5),
    idempresa integer,
    idusuariocreacion integer,
    fechacreacion timestamp with time zone,
    ipcreacion character varying(15),
    idusuariomodificacion integer,
    fechamodificacion timestamp with time zone,
    ipmodificacion character varying(15),
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE soporte."Tablamaestra" OWNER TO postgres;

SET search_path = negocio, pg_catalog;

--
-- TOC entry 253 (class 1259 OID 76454)
-- Name: vw_contactoproveedor; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_contactoproveedor AS
    SELECT con.id, con.nombres, con.apellidopaterno, con.apellidomaterno, con.idgenero, con.idestadocivil, con.idtipodocumento, con.numerodocumento, con.idusuariocreacion, con.fechacreacion, con.ipcreacion, pcpro.idproveedor, pcpro.idarea, area.nombre, pcpro.anexo, con.idempresa FROM "Persona" con, ("PersonaContactoProveedor" pcpro LEFT JOIN soporte."Tablamaestra" area ON ((((pcpro.idarea = area.id) AND (area.estado = 'A'::bpchar)) AND (area.idmaestro = 4)))) WHERE ((((con.idestadoregistro = 1) AND (pcpro.idestadoregistro = 1)) AND (con.idtipopersona = 3)) AND (con.id = pcpro.idcontacto));


ALTER TABLE negocio.vw_contactoproveedor OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 76459)
-- Name: vw_direccioncliente; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_direccioncliente AS
    SELECT dir.id, dir.idvia, tvia.nombre AS nombretipovia, dir.nombrevia, dir.numero, dir.interior, dir.manzana, dir.lote, pdir.idpersona, pdir.idempresa FROM "PersonaDireccion" pdir, "Direccion" dir, soporte."Tablamaestra" tvia WHERE (((((pdir.idestadoregistro = 1) AND (dir.idestadoregistro = 1)) AND (pdir.iddireccion = dir.id)) AND (tvia.idmaestro = 2)) AND (dir.idvia = tvia.id));


ALTER TABLE negocio.vw_direccioncliente OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 76463)
-- Name: vw_proveedor; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_proveedor AS
    SELECT pro.id AS idproveedor, tdoc.id AS idtipodocumento, tdoc.nombre AS nombretipodocumento, pro.numerodocumento, pro.nombres, pro.apellidopaterno, pro.apellidomaterno, ppro.idrubro, trub.nombre AS nombrerubro, dir.idvia, tvia.nombre AS nombretipovia, dir.nombrevia, dir.numero, dir.interior, dir.manzana, dir.lote, (SELECT tel.numero FROM "TelefonoDireccion" tedir, "Telefono" tel WHERE ((((tedir.idestadoregistro = 1) AND (tel.idestadoregistro = 1)) AND (tedir.iddireccion = dir.id)) AND (tedir.idtelefono = tel.id)) LIMIT 1) AS teledireccion, pro.idempresa FROM "Persona" pro, soporte."Tablamaestra" tdoc, "PersonaAdicional" ppro, soporte."Tablamaestra" trub, (("PersonaDireccion" pdir LEFT JOIN "Direccion" dir ON (((pdir.iddireccion = dir.id) AND ((dir.principal)::text = 'S'::text)))) LEFT JOIN soporte."Tablamaestra" tvia ON (((tvia.idmaestro = 2) AND (dir.idvia = tvia.id)))) WHERE (((((((((((pro.idestadoregistro = 1) AND (pro.idtipopersona = 2)) AND (tdoc.idmaestro = 1)) AND (pro.idtipodocumento = tdoc.id)) AND (pro.id = ppro.idpersona)) AND (trub.idmaestro = 3)) AND (ppro.idestadoregistro = 1)) AND (ppro.idrubro = trub.id)) AND (dir.idestadoregistro = 1)) AND (pdir.idestadoregistro = 1)) AND (pro.id = pdir.idpersona)) ORDER BY pro.nombres, pro.apellidopaterno, pro.apellidomaterno;


ALTER TABLE negocio.vw_proveedor OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 76468)
-- Name: vw_proveedoresnova; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_proveedoresnova AS
    SELECT per.id, per.idtipopersona, per.nombres, per.apellidopaterno, per.apellidomaterno, per.idgenero, per.idestadocivil, per.idtipodocumento, per.numerodocumento, per.idusuariocreacion, per.fechacreacion, per.ipcreacion, per.idusuariomodificacion, per.fechamodificacion, per.ipmodificacion, per.idestadoregistro, per.fecnacimiento, per.idempresa FROM "Persona" per WHERE ((per.idestadoregistro = 1) AND (per.idtipopersona = 2));


ALTER TABLE negocio.vw_proveedoresnova OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 76472)
-- Name: vw_servicio_detalle; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_servicio_detalle AS
    SELECT serdet.cantidad, serdet.descripcionservicio, serdet.fechaida, serdet.fecharegreso, serdet.idmoneda, tmmo.abreviatura, serdet.preciobase, serdet.montototal, serdet.idservicio, serdet.idempresa FROM ("ServicioDetalle" serdet JOIN soporte."Tablamaestra" tmmo ON (((tmmo.idmaestro = 20) AND (serdet.idmoneda = tmmo.id))));


ALTER TABLE negocio.vw_servicio_detalle OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 76477)
-- Name: vw_telefonocontacto; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_telefonocontacto AS
    SELECT tel.id, tel.numero, tel.idempresaproveedor, tper.idpersona, tper.idempresa FROM "Telefono" tel, "TelefonoPersona" tper, "Persona" per WHERE ((((((tel.idestadoregistro = 1) AND (tper.idestadoregistro = 1)) AND (tel.id = tper.idtelefono)) AND (per.idestadoregistro = 1)) AND (tper.idpersona = per.id)) AND (per.idtipopersona = 3));


ALTER TABLE negocio.vw_telefonocontacto OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 76481)
-- Name: vw_telefonodireccion; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_telefonodireccion AS
    SELECT tel.id, tel.numero, tel.idempresaproveedor, teldir.iddireccion, teldir.idempresa FROM "Telefono" tel, "TelefonoDireccion" teldir WHERE (((tel.idestadoregistro = 1) AND (teldir.idestadoregistro = 1)) AND (tel.id = teldir.idtelefono));


ALTER TABLE negocio.vw_telefonodireccion OWNER TO postgres;

SET search_path = seguridad, pg_catalog;

--
-- TOC entry 260 (class 1259 OID 76485)
-- Name: rol; Type: TABLE; Schema: seguridad; Owner: postgres; Tablespace: 
--

CREATE TABLE rol (
    id integer NOT NULL,
    nombre character varying(30),
    idempresa integer,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone,
    ipcreacion character varying(15),
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone,
    ipmodificacion character varying(15),
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE seguridad.rol OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 76489)
-- Name: usuario; Type: TABLE; Schema: seguridad; Owner: postgres; Tablespace: 
--

CREATE TABLE usuario (
    id integer DEFAULT 0 NOT NULL,
    usuario character varying(100) NOT NULL,
    credencial character varying(50) NOT NULL,
    id_rol integer,
    nombres character varying(50),
    apepaterno character varying(20),
    apematerno character varying(20),
    fecnacimiento date,
    vendedor boolean DEFAULT false,
    cambiarclave boolean DEFAULT false NOT NULL,
    feccaducacredencial date,
    idempresa integer NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone,
    ipcreacion character varying(15),
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone,
    ipmodificacion character varying(15),
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE seguridad.usuario OWNER TO postgres;

--
-- TOC entry 2851 (class 0 OID 0)
-- Dependencies: 261
-- Name: COLUMN usuario.id; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN usuario.id IS 'identificador de usuario';


--
-- TOC entry 2852 (class 0 OID 0)
-- Dependencies: 261
-- Name: COLUMN usuario.usuario; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN usuario.usuario IS 'usuario de inicio de sesion';


--
-- TOC entry 262 (class 1259 OID 76496)
-- Name: vw_listarusuarios; Type: VIEW; Schema: seguridad; Owner: postgres
--

CREATE VIEW vw_listarusuarios AS
    SELECT u.id, u.usuario, u.credencial, u.id_rol, r.nombre, u.nombres, u.apepaterno, u.apematerno, u.vendedor, u.fecnacimiento, u.cambiarclave, u.feccaducacredencial, u.idempresa FROM usuario u, rol r WHERE (u.id_rol = r.id);


ALTER TABLE seguridad.vw_listarusuarios OWNER TO postgres;

SET search_path = soporte, pg_catalog;

--
-- TOC entry 263 (class 1259 OID 76500)
-- Name: ConfiguracionTipoServicio; Type: TABLE; Schema: soporte; Owner: postgres; Tablespace: 
--

CREATE TABLE "ConfiguracionTipoServicio" (
    idtiposervicio integer NOT NULL,
    muestraaerolinea boolean,
    muestraempresatransporte boolean,
    muestrahotel boolean,
    muestraproveedor boolean,
    muestradescservicio boolean,
    muestrafechaservicio boolean,
    muestrafecharegreso boolean,
    muestracantidad boolean,
    muestraprecio boolean,
    muestraruta boolean,
    muestracomision boolean,
    muestraoperador boolean,
    muestratarifanegociada boolean,
    muestracodigoreserva boolean,
    muestranumeroboleto boolean,
    idusuariocreacion integer,
    fechacreacion timestamp with time zone,
    ipcreacion character varying(15),
    idusuariomodificacion integer,
    fechamodificacion timestamp with time zone,
    ipmodificacion character varying(15),
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer
);


ALTER TABLE soporte."ConfiguracionTipoServicio" OWNER TO postgres;

--
-- TOC entry 264 (class 1259 OID 76504)
-- Name: Parametro; Type: TABLE; Schema: soporte; Owner: postgres; Tablespace: 
--

CREATE TABLE "Parametro" (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    descripcion character varying(200),
    valor character varying(50) NOT NULL,
    estado character(1) NOT NULL,
    editable boolean NOT NULL,
    idempresa integer,
    idusuariocreacion integer,
    fechacreacion timestamp with time zone,
    ipcreacion character varying(15),
    idusuariomodificacion integer,
    fechamodificacion timestamp with time zone,
    ipmodificacion character varying(15),
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE soporte."Parametro" OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 76508)
-- Name: TipoCambio; Type: TABLE; Schema: soporte; Owner: postgres; Tablespace: 
--

CREATE TABLE "TipoCambio" (
    id integer NOT NULL,
    monedaorigen character varying(3),
    monedadestino character varying(3),
    tipocambiocompra numeric(9,6) NOT NULL,
    tipocambioventa numeric(9,6) NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer
);


ALTER TABLE soporte."TipoCambio" OWNER TO postgres;

--
-- TOC entry 266 (class 1259 OID 76512)
-- Name: destino; Type: TABLE; Schema: soporte; Owner: postgres; Tablespace: 
--

CREATE TABLE destino (
    id integer NOT NULL,
    idcontinente integer NOT NULL,
    idpais integer NOT NULL,
    codigoiata character varying(3) NOT NULL,
    idtipodestino integer NOT NULL,
    descripcion character varying(100) NOT NULL,
    idusuariocreacion integer NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character varying(15) NOT NULL,
    idusuariomodificacion integer NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character varying(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idempresa integer
);


ALTER TABLE soporte.destino OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 76516)
-- Name: seq_comun; Type: SEQUENCE; Schema: soporte; Owner: postgres
--

CREATE SEQUENCE seq_comun
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE soporte.seq_comun OWNER TO postgres;

--
-- TOC entry 268 (class 1259 OID 76518)
-- Name: seq_destino; Type: SEQUENCE; Schema: soporte; Owner: postgres
--

CREATE SEQUENCE seq_destino
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE soporte.seq_destino OWNER TO postgres;

--
-- TOC entry 269 (class 1259 OID 76520)
-- Name: seq_pais; Type: SEQUENCE; Schema: soporte; Owner: postgres
--

CREATE SEQUENCE seq_pais
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE soporte.seq_pais OWNER TO postgres;

--
-- TOC entry 270 (class 1259 OID 76522)
-- Name: vw_catalogodepartamento; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_catalogodepartamento AS
    SELECT ubigeo.id, ubigeo.iddepartamento, ubigeo.descripcion, ubigeo.idempresa FROM ubigeo WHERE ((((ubigeo.idprovincia)::text = '00'::text) AND ((ubigeo.iddistrito)::text = '00'::text)) AND ((ubigeo.iddepartamento)::text <> '00'::text));


ALTER TABLE soporte.vw_catalogodepartamento OWNER TO postgres;

--
-- TOC entry 271 (class 1259 OID 76526)
-- Name: vw_catalogodistrito; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_catalogodistrito AS
    SELECT ubigeo.id, ubigeo.iddepartamento, ubigeo.idprovincia, ubigeo.iddistrito, ubigeo.descripcion, ubigeo.idempresa FROM ubigeo WHERE (((ubigeo.iddepartamento)::text <> '00'::text) AND ((ubigeo.idprovincia)::text <> '00'::text));


ALTER TABLE soporte.vw_catalogodistrito OWNER TO postgres;

--
-- TOC entry 272 (class 1259 OID 76530)
-- Name: vw_catalogomaestro; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_catalogomaestro AS
    SELECT "Tablamaestra".id, "Tablamaestra".idmaestro, "Tablamaestra".nombre, "Tablamaestra".descripcion, "Tablamaestra".idempresa FROM "Tablamaestra" WHERE (("Tablamaestra".idmaestro <> 0) AND ("Tablamaestra".estado = 'A'::bpchar));


ALTER TABLE soporte.vw_catalogomaestro OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 76534)
-- Name: vw_catalogoprovincia; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_catalogoprovincia AS
    SELECT ubigeo.id, ubigeo.iddepartamento, ubigeo.idprovincia, ubigeo.descripcion, ubigeo.idempresa FROM ubigeo WHERE ((((ubigeo.iddistrito)::text = '00'::text) AND ((ubigeo.idprovincia)::text <> '00'::text)) AND ((ubigeo.iddepartamento)::text <> '00'::text));


ALTER TABLE soporte.vw_catalogoprovincia OWNER TO postgres;

--
-- TOC entry 274 (class 1259 OID 76538)
-- Name: vw_listahijosmaestro; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_listahijosmaestro AS
    SELECT "Tablamaestra".id, "Tablamaestra".idmaestro, "Tablamaestra".nombre, "Tablamaestra".descripcion, "Tablamaestra".orden, "Tablamaestra".estado, CASE WHEN ("Tablamaestra".estado = 'A'::bpchar) THEN 'Activo'::text ELSE 'Inactivo'::text END AS descestado, "Tablamaestra".abreviatura, "Tablamaestra".idempresa FROM "Tablamaestra" WHERE ("Tablamaestra".idmaestro <> 0);


ALTER TABLE soporte.vw_listahijosmaestro OWNER TO postgres;

--
-- TOC entry 275 (class 1259 OID 76542)
-- Name: vw_listamaestros; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_listamaestros AS
    SELECT "Tablamaestra".id, "Tablamaestra".idmaestro, "Tablamaestra".nombre, "Tablamaestra".descripcion, "Tablamaestra".orden, "Tablamaestra".estado, CASE WHEN ("Tablamaestra".estado = 'A'::bpchar) THEN 'ACTIVO'::text ELSE 'INACTIVO'::text END AS descestado, "Tablamaestra".idempresa FROM "Tablamaestra" WHERE ("Tablamaestra".idmaestro = 0);


ALTER TABLE soporte.vw_listamaestros OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 76546)
-- Name: vw_listaparametros; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_listaparametros AS
    SELECT "Parametro".id, "Parametro".nombre, "Parametro".descripcion, "Parametro".valor, "Parametro".estado, "Parametro".editable, "Parametro".idempresa FROM "Parametro";


ALTER TABLE soporte.vw_listaparametros OWNER TO postgres;

--
-- TOC entry 277 (class 1259 OID 76550)
-- Name: vw_ubigeo; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_ubigeo AS
    SELECT ubigeo.id, ubigeo.iddepartamento, ubigeo.idprovincia, ubigeo.iddistrito, ubigeo.descripcion, ubigeo.idempresa FROM ubigeo;


ALTER TABLE soporte.vw_ubigeo OWNER TO postgres;

SET search_path = auditoria, pg_catalog;

--
-- TOC entry 2756 (class 0 OID 76133)
-- Dependencies: 174
-- Data for Name: eventosesionsistema; Type: TABLE DATA; Schema: auditoria; Owner: postgres
--

INSERT INTO eventosesionsistema VALUES (165, 2, 'admin@innovaviajes.pe', '2016-01-20 11:29:43.213-05', 1, 1, 2, '2016-01-20 11:29:43.213-05', '127.0.0.1', 2, '2016-01-20 11:29:43.213-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (166, 2, 'admin@innovaviajes.pe', '2016-01-21 09:30:31.283-05', 1, 1, 2, '2016-01-21 09:30:31.283-05', '127.0.0.1', 2, '2016-01-21 09:30:31.283-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (167, 2, 'admin@innovaviajes.pe', '2016-01-22 12:15:41.45-05', 1, 1, 2, '2016-01-22 12:15:41.45-05', '127.0.0.1', 2, '2016-01-22 12:15:41.45-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (168, 2, 'admin@innovaviajes.pe', '2016-01-22 12:17:35.042-05', 1, 1, 2, '2016-01-22 12:17:35.042-05', '127.0.0.1', 2, '2016-01-22 12:17:35.042-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (169, 2, 'admin@innovaviajes.pe', '2016-01-22 12:19:16.508-05', 1, 1, 2, '2016-01-22 12:19:16.508-05', '127.0.0.1', 2, '2016-01-22 12:19:16.508-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (170, 2, 'admin@innovaviajes.pe', '2016-01-22 12:21:07.642-05', 1, 1, 2, '2016-01-22 12:21:07.642-05', '127.0.0.1', 2, '2016-01-22 12:21:07.642-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (171, 2, 'admin@innovaviajes.pe', '2016-01-22 12:25:03.997-05', 1, 1, 2, '2016-01-22 12:25:03.997-05', '127.0.0.1', 2, '2016-01-22 12:25:03.997-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (172, 2, 'admin@innovaviajes.pe', '2016-01-22 12:31:07.328-05', 1, 1, 2, '2016-01-22 12:31:07.328-05', '127.0.0.1', 2, '2016-01-22 12:31:07.328-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (173, 2, 'admin@innovaviajes.pe', '2016-01-22 12:35:10.6-05', 1, 1, 2, '2016-01-22 12:35:10.6-05', '127.0.0.1', 2, '2016-01-22 12:35:10.6-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (174, 2, 'admin@innovaviajes.pe', '2016-01-22 12:36:40.566-05', 1, 1, 2, '2016-01-22 12:36:40.566-05', '127.0.0.1', 2, '2016-01-22 12:36:40.566-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (175, 2, 'admin@innovaviajes.pe', '2016-01-22 15:46:33.672-05', 1, 1, 2, '2016-01-22 15:46:33.672-05', '127.0.0.1', 2, '2016-01-22 15:46:33.672-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (176, 2, 'admin@innovaviajes.pe', '2016-01-22 16:24:25.151-05', 1, 1, 2, '2016-01-22 16:24:25.151-05', '127.0.0.1', 2, '2016-01-22 16:24:25.151-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (1, 2, 'admin@innovaviajes.pe', '2016-01-22 17:22:11.504-05', 1, 1, 2, '2016-01-22 17:22:11.504-05', '127.0.0.1', 2, '2016-01-22 17:22:11.504-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (2, 2, 'admin@innovaviajes.pe', '2016-01-22 17:23:34.454-05', 1, 1, 2, '2016-01-22 17:23:34.454-05', '127.0.0.1', 2, '2016-01-22 17:23:34.454-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (3, 2, 'admin@innovaviajes.pe', '2016-01-22 17:31:12.537-05', 1, 1, 2, '2016-01-22 17:31:12.537-05', '127.0.0.1', 2, '2016-01-22 17:31:12.537-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (4, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-22 17:32:46.242-05', 1, 1, 3, '2016-01-22 17:32:46.242-05', '127.0.0.1', 3, '2016-01-22 17:32:46.242-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (5, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-22 17:35:54.648-05', 1, 1, 3, '2016-01-22 17:35:54.648-05', '127.0.0.1', 3, '2016-01-22 17:35:54.648-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (6, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-22 17:37:17.845-05', 1, 1, 3, '2016-01-22 17:37:17.845-05', '127.0.0.1', 3, '2016-01-22 17:37:17.845-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (7, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-22 17:40:43.157-05', 1, 1, 3, '2016-01-22 17:40:43.157-05', '127.0.0.1', 3, '2016-01-22 17:40:43.157-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (8, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-22 17:51:27.16-05', 1, 1, 3, '2016-01-22 17:51:27.16-05', '127.0.0.1', 3, '2016-01-22 17:51:27.16-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (9, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-22 17:56:13.17-05', 1, 1, 3, '2016-01-22 17:56:13.17-05', '127.0.0.1', 3, '2016-01-22 17:56:13.17-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (10, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 10:51:21.093-05', 1, 1, 3, '2016-01-25 10:51:21.093-05', '127.0.0.1', 3, '2016-01-25 10:51:21.093-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (11, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 11:13:54.482-05', 1, 1, 3, '2016-01-25 11:13:54.482-05', '127.0.0.1', 3, '2016-01-25 11:13:54.482-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (12, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 11:50:31.865-05', 1, 1, 3, '2016-01-25 11:50:31.865-05', '127.0.0.1', 3, '2016-01-25 11:50:31.865-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (13, 2, 'admin@innovaviajes.pe', '2016-01-25 12:02:29.136-05', 1, 1, 2, '2016-01-25 12:02:29.136-05', '127.0.0.1', 2, '2016-01-25 12:02:29.136-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (14, 2, 'admin@innovaviajes.pe', '2016-01-25 12:05:21.392-05', 1, 1, 2, '2016-01-25 12:05:21.392-05', '127.0.0.1', 2, '2016-01-25 12:05:21.392-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (15, 2, 'admin@innovaviajes.pe', '2016-01-25 16:32:22.846-05', 1, 1, 2, '2016-01-25 16:32:22.846-05', '127.0.0.1', 2, '2016-01-25 16:32:22.846-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (16, 2, 'admin@innovaviajes.pe', '2016-01-25 16:44:14.94-05', 1, 1, 2, '2016-01-25 16:44:14.94-05', '127.0.0.1', 2, '2016-01-25 16:44:14.94-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (17, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 16:46:58.831-05', 1, 1, 3, '2016-01-25 16:46:58.831-05', '127.0.0.1', 3, '2016-01-25 16:46:58.831-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (18, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 16:56:39.153-05', 1, 1, 3, '2016-01-25 16:56:39.153-05', '127.0.0.1', 3, '2016-01-25 16:56:39.153-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (19, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 17:07:41.786-05', 1, 1, 3, '2016-01-25 17:07:41.786-05', '127.0.0.1', 3, '2016-01-25 17:07:41.786-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (20, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 17:50:41.052-05', 1, 1, 3, '2016-01-25 17:50:41.052-05', '127.0.0.1', 3, '2016-01-25 17:50:41.052-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (21, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 17:57:56.527-05', 1, 1, 3, '2016-01-25 17:57:56.527-05', '127.0.0.1', 3, '2016-01-25 17:57:56.527-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (22, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 18:05:05.501-05', 1, 1, 3, '2016-01-25 18:05:05.501-05', '127.0.0.1', 3, '2016-01-25 18:05:05.501-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (23, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 18:10:31.042-05', 1, 1, 3, '2016-01-25 18:10:31.042-05', '127.0.0.1', 3, '2016-01-25 18:10:31.042-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (24, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 18:14:12.43-05', 1, 1, 3, '2016-01-25 18:14:12.43-05', '127.0.0.1', 3, '2016-01-25 18:14:12.43-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (25, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 18:18:25.747-05', 1, 1, 3, '2016-01-25 18:18:25.747-05', '127.0.0.1', 3, '2016-01-25 18:18:25.747-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (26, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 18:23:34.597-05', 1, 1, 3, '2016-01-25 18:23:34.597-05', '127.0.0.1', 3, '2016-01-25 18:23:34.597-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (27, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 18:24:41.181-05', 1, 1, 3, '2016-01-25 18:24:41.181-05', '127.0.0.1', 3, '2016-01-25 18:24:41.181-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (28, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 18:34:25.395-05', 1, 1, 3, '2016-01-25 18:34:25.395-05', '127.0.0.1', 3, '2016-01-25 18:34:25.395-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (29, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 21:02:45.244-05', 1, 1, 3, '2016-01-25 21:02:45.244-05', '127.0.0.1', 3, '2016-01-25 21:02:45.244-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (30, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 21:10:56.839-05', 1, 1, 3, '2016-01-25 21:10:56.839-05', '127.0.0.1', 3, '2016-01-25 21:10:56.839-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (31, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 21:12:59.708-05', 1, 1, 3, '2016-01-25 21:12:59.708-05', '127.0.0.1', 3, '2016-01-25 21:12:59.708-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (32, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 21:14:17.838-05', 1, 1, 3, '2016-01-25 21:14:17.838-05', '127.0.0.1', 3, '2016-01-25 21:14:17.838-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (33, 2, 'admin@innovaviajes.pe', '2016-01-25 21:15:00.729-05', 1, 1, 2, '2016-01-25 21:15:00.729-05', '127.0.0.1', 2, '2016-01-25 21:15:00.729-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (34, 2, 'admin@innovaviajes.pe', '2016-01-25 21:19:59.145-05', 1, 1, 2, '2016-01-25 21:19:59.145-05', '127.0.0.1', 2, '2016-01-25 21:19:59.145-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (35, 2, 'admin@innovaviajes.pe', '2016-01-25 21:28:43.981-05', 1, 1, 2, '2016-01-25 21:28:43.981-05', '127.0.0.1', 2, '2016-01-25 21:28:43.981-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (36, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 21:50:41.811-05', 1, 1, 3, '2016-01-25 21:50:41.811-05', '127.0.0.1', 3, '2016-01-25 21:50:41.811-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (37, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 22:08:56.206-05', 1, 1, 3, '2016-01-25 22:08:56.206-05', '127.0.0.1', 3, '2016-01-25 22:08:56.206-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (38, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 22:27:11.478-05', 1, 1, 3, '2016-01-25 22:27:11.478-05', '127.0.0.1', 3, '2016-01-25 22:27:11.478-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (39, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 22:53:09.566-05', 1, 1, 3, '2016-01-25 22:53:09.566-05', '127.0.0.1', 3, '2016-01-25 22:53:09.566-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (40, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 23:09:49.595-05', 1, 1, 3, '2016-01-25 23:09:49.595-05', '127.0.0.1', 3, '2016-01-25 23:09:49.595-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (41, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 23:25:03.102-05', 1, 1, 3, '2016-01-25 23:25:03.102-05', '127.0.0.1', 3, '2016-01-25 23:25:03.102-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (42, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-25 23:41:51.639-05', 1, 1, 3, '2016-01-25 23:41:51.639-05', '127.0.0.1', 3, '2016-01-25 23:41:51.639-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (43, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-28 21:46:11.855-05', 1, 1, 3, '2016-01-28 21:46:11.855-05', '127.0.0.1', 3, '2016-01-28 21:46:11.855-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (44, 2, 'admin@innovaviajes.pe', '2016-01-28 21:47:46.135-05', 1, 1, 2, '2016-01-28 21:47:46.135-05', '127.0.0.1', 2, '2016-01-28 21:47:46.135-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (45, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-28 21:53:29.558-05', 1, 1, 3, '2016-01-28 21:53:29.558-05', '127.0.0.1', 3, '2016-01-28 21:53:29.558-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (46, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-28 22:45:22.852-05', 1, 1, 3, '2016-01-28 22:45:22.852-05', '127.0.0.1', 3, '2016-01-28 22:45:22.852-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (47, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-28 23:22:36.466-05', 1, 1, 3, '2016-01-28 23:22:36.466-05', '127.0.0.1', 3, '2016-01-28 23:22:36.466-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (48, 2, 'admin@innovaviajes.pe', '2016-01-28 23:57:44.454-05', 1, 1, 2, '2016-01-28 23:57:44.454-05', '127.0.0.1', 2, '2016-01-28 23:57:44.454-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (49, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-29 00:03:50.179-05', 1, 1, 3, '2016-01-29 00:03:50.179-05', '127.0.0.1', 3, '2016-01-29 00:03:50.179-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (50, 2, 'admin@innovaviajes.pe', '2016-01-29 00:18:02.57-05', 1, 1, 2, '2016-01-29 00:18:02.57-05', '127.0.0.1', 2, '2016-01-29 00:18:02.57-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (51, 4, 'edwin.rebaza@innovaviajes.pe', '2016-01-29 00:20:12.105-05', 1, 1, 4, '2016-01-29 00:20:12.105-05', '127.0.0.1', 4, '2016-01-29 00:20:12.105-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (52, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-29 00:25:46.85-05', 1, 1, 3, '2016-01-29 00:25:46.85-05', '127.0.0.1', 3, '2016-01-29 00:25:46.85-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (53, 4, 'edwin.rebaza@innovaviajes.pe', '2016-01-29 00:29:49.051-05', 1, 1, 4, '2016-01-29 00:29:49.051-05', '127.0.0.1', 4, '2016-01-29 00:29:49.051-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (54, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-29 00:32:37.628-05', 1, 1, 3, '2016-01-29 00:32:37.628-05', '127.0.0.1', 3, '2016-01-29 00:32:37.628-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (55, 2, 'admin@innovaviajes.pe', '2016-01-30 14:30:50.64-05', 1, 1, 2, '2016-01-30 14:30:50.64-05', '127.0.0.1', 2, '2016-01-30 14:30:50.64-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (56, 3, 'paola.huarachi@innovaviajes.pe', '2016-01-30 14:32:36.545-05', 1, 1, 3, '2016-01-30 14:32:36.545-05', '127.0.0.1', 3, '2016-01-30 14:32:36.545-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (57, 2, 'admin@innovaviajes.pe', '2016-01-30 22:00:13.152-05', 1, 1, 2, '2016-01-30 22:00:13.152-05', '127.0.0.1', 2, '2016-01-30 22:00:13.152-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (58, 2, 'admin@innovaviajes.pe', '2016-01-30 22:05:36.386-05', 1, 1, 2, '2016-01-30 22:05:36.386-05', '127.0.0.1', 2, '2016-01-30 22:05:36.386-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (59, 2, 'admin@innovaviajes.pe', '2016-01-30 22:09:20.15-05', 1, 1, 2, '2016-01-30 22:09:20.15-05', '127.0.0.1', 2, '2016-01-30 22:09:20.15-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (60, 2, 'admin@innovaviajes.pe', '2016-01-30 22:16:32.745-05', 1, 1, 2, '2016-01-30 22:16:32.745-05', '127.0.0.1', 2, '2016-01-30 22:16:32.745-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (61, 2, 'admin@innovaviajes.pe', '2016-01-30 22:17:07.216-05', 1, 1, 2, '2016-01-30 22:17:07.216-05', '127.0.0.1', 2, '2016-01-30 22:17:07.216-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (62, 2, 'admin@innovaviajes.pe', '2016-01-30 22:37:47.116-05', 1, 1, 2, '2016-01-30 22:37:47.116-05', '127.0.0.1', 2, '2016-01-30 22:37:47.116-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (63, 2, 'admin@innovaviajes.pe', '2016-01-30 23:22:18.441-05', 1, 1, 2, '2016-01-30 23:22:18.441-05', '127.0.0.1', 2, '2016-01-30 23:22:18.441-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (64, 1, 'administrador@rhsistemas.pe', '2016-02-04 20:55:08.585-05', 1, 100, 1, '2016-02-04 20:55:08.585-05', '127.0.0.1', 1, '2016-02-04 20:55:08.585-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (65, 1, 'administrador@rhsistemas.pe', '2016-02-04 21:37:23.831-05', 1, 100, 1, '2016-02-04 21:37:23.831-05', '127.0.0.1', 1, '2016-02-04 21:37:23.831-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (66, 1, 'administrador@rhsistemas.pe', '2016-02-04 21:58:14.436-05', 1, 100, 1, '2016-02-04 21:58:14.436-05', '127.0.0.1', 1, '2016-02-04 21:58:14.436-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (67, 1, 'administrador@rhsistemas.pe', '2016-02-04 22:03:21.736-05', 1, 100, 1, '2016-02-04 22:03:21.736-05', '127.0.0.1', 1, '2016-02-04 22:03:21.736-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (68, 1, 'administrador@rhsistemas.pe', '2016-02-05 07:34:01.75-05', 1, 100, 1, '2016-02-05 07:34:01.75-05', '127.0.0.1', 1, '2016-02-05 07:34:01.75-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (69, 1, 'administrador@rhsistemas.pe', '2016-02-05 07:35:57.125-05', 1, 100, 1, '2016-02-05 07:35:57.125-05', '127.0.0.1', 1, '2016-02-05 07:35:57.125-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (70, 1, 'administrador@rhsistemas.pe', '2016-02-10 09:40:27.596-05', 1, 100, 1, '2016-02-10 09:40:27.596-05', '127.0.0.1', 1, '2016-02-10 09:40:27.596-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (71, 1, 'administrador@rhsistemas.pe', '2016-02-10 09:51:00.755-05', 1, 100, 1, '2016-02-10 09:51:00.755-05', '127.0.0.1', 1, '2016-02-10 09:51:00.755-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (72, 1, 'administrador@rhsistemas.pe', '2016-02-10 09:54:05.763-05', 1, 100, 1, '2016-02-10 09:54:05.763-05', '127.0.0.1', 1, '2016-02-10 09:54:05.763-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (73, 1, 'administrador@rhsistemas.pe', '2016-02-10 10:07:48.601-05', 1, 100, 1, '2016-02-10 10:07:48.601-05', '127.0.0.1', 1, '2016-02-10 10:07:48.601-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (74, 1, 'administrador@rhsistemas.pe', '2016-02-10 10:13:45.537-05', 1, 100, 1, '2016-02-10 10:13:45.537-05', '127.0.0.1', 1, '2016-02-10 10:13:45.537-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (75, 1, 'administrador@rhsistemas.pe', '2016-02-10 10:15:04.57-05', 1, 100, 1, '2016-02-10 10:15:04.57-05', '127.0.0.1', 1, '2016-02-10 10:15:04.57-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (76, 1, 'administrador@rhsistemas.pe', '2016-02-10 10:21:10.636-05', 1, 100, 1, '2016-02-10 10:21:10.636-05', '127.0.0.1', 1, '2016-02-10 10:21:10.636-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (77, 1, 'administrador@rhsistemas.pe', '2016-02-10 10:22:35.008-05', 1, 100, 1, '2016-02-10 10:22:35.008-05', '127.0.0.1', 1, '2016-02-10 10:22:35.008-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (78, 1, 'administrador@rhsistemas.pe', '2016-02-10 10:24:12.021-05', 1, 100, 1, '2016-02-10 10:24:12.021-05', '127.0.0.1', 1, '2016-02-10 10:24:12.021-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (79, 1, 'administrador@rhsistemas.pe', '2016-02-10 10:45:30.538-05', 1, 100, 1, '2016-02-10 10:45:30.538-05', '127.0.0.1', 1, '2016-02-10 10:45:30.538-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (80, 1, 'administrador@rhsistemas.pe', '2016-02-10 10:52:01.351-05', 1, 100, 1, '2016-02-10 10:52:01.351-05', '127.0.0.1', 1, '2016-02-10 10:52:01.351-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (81, 1, 'administrador@rhsistemas.pe', '2016-02-10 12:18:26.635-05', 1, 100, 1, '2016-02-10 12:18:26.635-05', '127.0.0.1', 1, '2016-02-10 12:18:26.635-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (82, 1, 'administrador@rhsistemas.pe', '2016-02-10 12:30:33.966-05', 1, 100, 1, '2016-02-10 12:30:33.966-05', '127.0.0.1', 1, '2016-02-10 12:30:33.966-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (83, 1, 'administrador@rhsistemas.pe', '2016-02-10 12:32:21.13-05', 1, 100, 1, '2016-02-10 12:32:21.13-05', '127.0.0.1', 1, '2016-02-10 12:32:21.13-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (84, 1, 'administrador@rhsistemas.pe', '2016-02-10 12:33:47.674-05', 1, 100, 1, '2016-02-10 12:33:47.674-05', '127.0.0.1', 1, '2016-02-10 12:33:47.674-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (85, 1, 'administrador@rhsistemas.pe', '2016-02-10 12:36:00.068-05', 1, 100, 1, '2016-02-10 12:36:00.068-05', '127.0.0.1', 1, '2016-02-10 12:36:00.068-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (86, 1, 'administrador@rhsistemas.pe', '2016-02-10 12:37:52.768-05', 1, 100, 1, '2016-02-10 12:37:52.768-05', '127.0.0.1', 1, '2016-02-10 12:37:52.768-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (87, 1, 'administrador@rhsistemas.pe', '2016-02-10 13:06:34.448-05', 1, 100, 1, '2016-02-10 13:06:34.448-05', '127.0.0.1', 1, '2016-02-10 13:06:34.448-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (88, 3, 'paola.huarachi@innovaviajes.pe', '2016-02-10 13:26:55.446-05', 1, 1, 3, '2016-02-10 13:26:55.446-05', '127.0.0.1', 3, '2016-02-10 13:26:55.446-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (89, 1, 'administrador@rhsistemas.pe', '2016-02-11 08:57:47.069-05', 1, 100, 1, '2016-02-11 08:57:47.069-05', '127.0.0.1', 1, '2016-02-11 08:57:47.069-05', '127.0.0.1', 1);
INSERT INTO eventosesionsistema VALUES (90, 1, 'administrador@rhsistemas.pe', '2016-02-11 09:42:29.351-05', 1, 100, 1, '2016-02-11 09:42:29.351-05', '127.0.0.1', 1, '2016-02-11 09:42:29.351-05', '127.0.0.1', 1);


--
-- TOC entry 2853 (class 0 OID 0)
-- Dependencies: 175
-- Name: seq_eventosesionsistema; Type: SEQUENCE SET; Schema: auditoria; Owner: postgres
--

SELECT pg_catalog.setval('seq_eventosesionsistema', 90, true);


SET search_path = licencia, pg_catalog;

--
-- TOC entry 2758 (class 0 OID 76139)
-- Dependencies: 176
-- Data for Name: Contrato; Type: TABLE DATA; Schema: licencia; Owner: postgres
--

INSERT INTO "Contrato" VALUES (1, '2016-01-01', '2016-12-31', 5.00, 10, 'HXQHO5DBbMLFWnTsVc1kHXyNllDa9/HFKjPwlRlQCvZGNEshXDGCPif54HmvNGlTRpbMXk92suaWlKYB8bhAww==', 1, 1, 1);


--
-- TOC entry 2759 (class 0 OID 76145)
-- Dependencies: 177
-- Data for Name: Empresa; Type: TABLE DATA; Schema: licencia; Owner: postgres
--

INSERT INTO "Empresa" VALUES (1, 'Innova Viajes RH', 'Innova Viajes', 'innovaviajes.pe', 1, '20600866151', 'Paola Huarachi');
INSERT INTO "Empresa" VALUES (2, 'Grupo Maral', 'Viajes Terra Nova', 'viajesterranova.com.pe', 1, '20123456789', 'Liliam Quispe');
INSERT INTO "Empresa" VALUES (100, 'RH Sistemas SAC', 'RH Sistemas', 'rhsistemas.pe', 1, '20123456789', 'Edwin Rebaza Cerpa');


--
-- TOC entry 2839 (class 0 OID 76775)
-- Dependencies: 278
-- Data for Name: Tablamaestra; Type: TABLE DATA; Schema: licencia; Owner: postgres
--

INSERT INTO "Tablamaestra" VALUES (1, 0, 'MAESTRO TIPO DE DOCUMENTO', 'MAESTRO DE TIPO DE DOCUMENTO', 1, 'A', NULL, 1);
INSERT INTO "Tablamaestra" VALUES (1, 1, 'RUC', 'REGISTRO UNICO DE CONTRIBUYENTE', 1, 'A', 'RUC', 1);
INSERT INTO "Tablamaestra" VALUES (2, 0, 'MAESTRO DE ESTADO DE CONTRATO', 'MAESTRO DE ESTADO DE CONTRATO', 2, 'A', NULL, 1);
INSERT INTO "Tablamaestra" VALUES (1, 2, 'ACTIVO', 'ACTIVO', 1, 'A', 'A', 1);
INSERT INTO "Tablamaestra" VALUES (2, 2, 'SUSPENDIDO', 'SUSPENDIDO', 2, 'A', 'S', 1);
INSERT INTO "Tablamaestra" VALUES (3, 2, 'TERMINADO', 'TERMINADO', 3, 'A', 'T', 1);


--
-- TOC entry 2854 (class 0 OID 0)
-- Dependencies: 279
-- Name: seq_contrato; Type: SEQUENCE SET; Schema: licencia; Owner: postgres
--

SELECT pg_catalog.setval('seq_contrato', 1, false);


--
-- TOC entry 2855 (class 0 OID 0)
-- Dependencies: 280
-- Name: seq_empresa; Type: SEQUENCE SET; Schema: licencia; Owner: postgres
--

SELECT pg_catalog.setval('seq_empresa', 1, false);


SET search_path = negocio, pg_catalog;

--
-- TOC entry 2760 (class 0 OID 76151)
-- Dependencies: 178
-- Data for Name: ArchivoCargado; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2761 (class 0 OID 76155)
-- Dependencies: 179
-- Data for Name: ComprobanteAdicional; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2762 (class 0 OID 76162)
-- Dependencies: 180
-- Data for Name: ComprobanteGenerado; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2763 (class 0 OID 76166)
-- Dependencies: 181
-- Data for Name: ComprobanteObligacion; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2764 (class 0 OID 76170)
-- Dependencies: 182
-- Data for Name: CorreoElectronico; Type: TABLE DATA; Schema: negocio; Owner: postgres
--

INSERT INTO "CorreoElectronico" VALUES (2, 'EDWINRJRC@GMAIL.COM', 26, 3, '2016-01-25 18:20:20.5-05', '127.0.0.1', 3, '2016-01-25 18:20:20.5-05', '127.0.0.1', 1, true, 1);
INSERT INTO "CorreoElectronico" VALUES (4, 'PAOLA.HUARACHI@INNOVAVIAJES.PE', 31, 3, '2016-01-25 22:30:52.541-05', '127.0.0.1', 3, '2016-01-25 22:30:52.541-05', '127.0.0.1', 1, false, 1);


--
-- TOC entry 2765 (class 0 OID 76175)
-- Dependencies: 183
-- Data for Name: CronogramaPago; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2766 (class 0 OID 76182)
-- Dependencies: 184
-- Data for Name: CuentaBancaria; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2767 (class 0 OID 76187)
-- Dependencies: 185
-- Data for Name: DetalleArchivoCargado; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2768 (class 0 OID 76195)
-- Dependencies: 186
-- Data for Name: DetalleComprobanteGenerado; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2769 (class 0 OID 76199)
-- Dependencies: 187
-- Data for Name: Direccion; Type: TABLE DATA; Schema: negocio; Owner: postgres
--

INSERT INTO "Direccion" VALUES (17, 1, 'VENEZUELA', '842', '1102', NULL, NULL, 'S', '150105', 3, '2016-01-25 18:20:20.5-05', '127.0.0.1', 3, '2016-01-25 18:20:20.5-05', '127.0.0.1', 1, 'TORRE 4', 'A 2 CUADRAS DE LA AV. ALFONSO UGARTE', 1, 1);
INSERT INTO "Direccion" VALUES (20, 1, 'VENEZUELA', '842', '1102', NULL, NULL, 'S', '150105', 3, '2016-01-25 22:30:52.541-05', '127.0.0.1', 3, '2016-01-25 22:30:52.541-05', '127.0.0.1', 1, 'TORRE 4', 'A 2 CUADRAS DE LA AV. ALFONSO UGARTE', 1, 1);
INSERT INTO "Direccion" VALUES (22, 2, 'JOSE PARDO', '513', NULL, NULL, NULL, 'S', '150122', 3, '2016-01-28 23:00:59.644-05', '127.0.0.1', 3, '2016-01-28 23:00:59.644-05', '127.0.0.1', 1, 'URB. CERCADO DE MIRAFLORES', NULL, 1, 1);
INSERT INTO "Direccion" VALUES (21, 2, 'BERLIN', '364', NULL, NULL, NULL, 'S', '150122', 3, '2016-01-28 22:54:15.746-05', '127.0.0.1', 3, '2016-01-28 23:07:46.295-05', '127.0.0.1', 0, NULL, NULL, 1, 1);
INSERT INTO "Direccion" VALUES (23, 2, 'BERLIN', '364', NULL, NULL, NULL, 'S', '150122', 3, '2016-01-28 23:07:46.295-05', '127.0.0.1', 3, '2016-01-28 23:07:46.295-05', '127.0.0.1', 1, NULL, NULL, 1, 1);


--
-- TOC entry 2770 (class 0 OID 76206)
-- Dependencies: 188
-- Data for Name: DocumentoAdjuntoServicio; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2771 (class 0 OID 76213)
-- Dependencies: 189
-- Data for Name: EventoObsAnuServicio; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2772 (class 0 OID 76217)
-- Dependencies: 190
-- Data for Name: MaestroServicios; Type: TABLE DATA; Schema: negocio; Owner: postgres
--

INSERT INTO "MaestroServicios" VALUES (1, 'FEE', 'FEE DE EMISION', 'FEE DE EMISION', false, NULL, false, NULL, false, false, false, NULL, false, true, 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 1, NULL, true, true, 1);
INSERT INTO "MaestroServicios" VALUES (2, 'IMPUESTO AEREO', 'IMPUESTO AEREO', 'IMPUESTO AEREO POR USO DEL AEROPUERTO', false, NULL, false, NULL, false, false, false, NULL, true, false, 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 1, NULL, true, false, 1);
INSERT INTO "MaestroServicios" VALUES (5, 'PROGRAMA', 'PROGRAMA', 'PROGRAMA', true, NULL, false, NULL, false, false, false, NULL, false, false, 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 1, NULL, true, true, 1);
INSERT INTO "MaestroServicios" VALUES (6, 'IGV', 'IGV', 'IMPUESTO GENERAL A LAS VENTAS', false, NULL, false, NULL, false, false, false, NULL, true, false, 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 1, 1, false, false, 1);
INSERT INTO "MaestroServicios" VALUES (7, 'GASTO EMISION', 'GASTO DE EMISION', 'GASTO POR CONFIRMACION Y/O EMISION', false, NULL, false, NULL, false, false, false, NULL, false, false, 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 1, NULL, true, true, 1);
INSERT INTO "MaestroServicios" VALUES (12, 'PENALIDAD', 'CAMBIOS', 'CAMBIO DE FECHA, RUTA, NOMBRE,ETC', false, NULL, false, NULL, false, false, false, NULL, false, false, 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 1, NULL, true, false, 1);
INSERT INTO "MaestroServicios" VALUES (8, 'SEGURO DE ASISTENCIA', 'SEGURO DE ASISTENCIA', 'SEGURO DE VIAJE EN CASO DE ENFERMEDAD O ACCIDENTE', false, NULL, false, NULL, true, false, false, NULL, false, false, 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 1, NULL, true, true, 1);
INSERT INTO "MaestroServicios" VALUES (10, 'ALQUILER DE AUTO', 'ALQUILER DE AUTO', 'ALQUILER DE TODO TIPO DE AUTO, MINIVAN O VAN', false, NULL, false, NULL, true, false, false, NULL, false, false, 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 1, NULL, true, true, 1);
INSERT INTO "MaestroServicios" VALUES (9, 'BOLETO TERRESTRE', 'BOLETO DE BUS', 'BOLETO TERRESTRE NACIONAL O INTERNACIONAL', false, NULL, false, NULL, true, false, false, NULL, false, false, 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 1, NULL, true, true, 1);
INSERT INTO "MaestroServicios" VALUES (11, 'TRASLADO', 'TRASLADOS', 'TRASLADOS AEROPUERTO, HOTEL U OTRO DESTINO', false, NULL, false, NULL, false, false, false, NULL, false, false, 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 1, NULL, true, true, 1);
INSERT INTO "MaestroServicios" VALUES (4, 'PAQUETE', 'PAQUETE DE VIAJE', 'PAQUETE DE VIAJE', false, 1, true, NULL, false, false, false, NULL, false, false, 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 1, NULL, true, true, 1);
INSERT INTO "MaestroServicios" VALUES (13, 'HOTEL', 'HOTEL', 'HOTEL', true, 1, false, NULL, false, false, false, NULL, false, false, 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 1, NULL, true, true, 1);
INSERT INTO "MaestroServicios" VALUES (3, 'BOLETO AEREO', 'BOLETO AEREO', 'BOLETO AEREO', true, 1, true, NULL, false, false, false, NULL, false, false, 2, '2016-01-22 11:58:37.313-05', '0.0.0.0        ', 2, '2016-01-28 21:48:55.351-05', '127.0.0.1      ', 1, NULL, true, true, 1);


--
-- TOC entry 2773 (class 0 OID 76233)
-- Dependencies: 191
-- Data for Name: MovimientoCuenta; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2774 (class 0 OID 76238)
-- Dependencies: 192
-- Data for Name: ObligacionesXPagar; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2775 (class 0 OID 76242)
-- Dependencies: 193
-- Data for Name: PagosObligacion; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2776 (class 0 OID 76249)
-- Dependencies: 194
-- Data for Name: PagosServicio; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2777 (class 0 OID 76256)
-- Dependencies: 195
-- Data for Name: PasajeroServicio; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2778 (class 0 OID 76260)
-- Dependencies: 196
-- Data for Name: Persona; Type: TABLE DATA; Schema: negocio; Owner: postgres
--

INSERT INTO "Persona" VALUES (25, 1, 'EDWIN', 'REBAZA', 'CERPA', 'M', 1, 1, '41229544', 3, '2016-01-25 18:20:20.5-05', '127.0.0.1      ', 3, '2016-01-25 18:20:20.5-05', '127.0.0.1      ', 1, '1982-05-30', NULL, NULL, 1, 1);
INSERT INTO "Persona" VALUES (30, 2, 'INNOVA VIAJES RH SAC', NULL, NULL, NULL, NULL, 3, '20600866151', 3, '2016-01-25 22:30:52.541-05', '127.0.0.1      ', 3, '2016-01-25 22:30:52.541-05', '127.0.0.1      ', 1, NULL, NULL, NULL, 1, 1);
INSERT INTO "Persona" VALUES (34, 2, 'LAN PERU S.A.', NULL, NULL, NULL, NULL, 3, '20341841357', 3, '2016-01-28 23:00:59.644-05', '127.0.0.1      ', 3, '2016-01-28 23:00:59.644-05', '127.0.0.1      ', 1, NULL, NULL, NULL, 1, 1);
INSERT INTO "Persona" VALUES (35, 3, 'FDGFGDFG DFGDFGFD', 'DSFDDFD', 'FFGDFGFG', NULL, NULL, 1, '45435344', 3, '2016-01-28 23:00:59.644-05', '127.0.0.1      ', 3, '2016-01-28 23:00:59.644-05', '127.0.0.1      ', 1, NULL, NULL, NULL, NULL, 1);
INSERT INTO "Persona" VALUES (32, 2, 'COSTAMAR TRAVEL CRUISE & TOURS S.A.C.', NULL, NULL, NULL, NULL, 3, '20126339632', 3, '2016-01-28 22:54:15.746-05', '127.0.0.1      ', 3, '2016-01-28 23:07:46.295-05', '127.0.0.1      ', 1, NULL, NULL, NULL, 1, 1);
INSERT INTO "Persona" VALUES (33, 3, 'FDGFDGFD DFGFDG', 'DSFDSFDSF', 'DFGFDGDFG', NULL, NULL, 1, '35563434', 3, '2016-01-28 22:54:15.746-05', '127.0.0.1      ', 3, '2016-01-28 23:07:46.295-05', '127.0.0.1      ', 0, NULL, NULL, NULL, NULL, 1);
INSERT INTO "Persona" VALUES (36, 3, 'FDGFDGFD DFGFDG', 'DSFDSFDSF', 'DFGFDGDFG', NULL, NULL, 1, '35563434', 3, '2016-01-28 23:07:46.295-05', '127.0.0.1      ', 3, '2016-01-28 23:07:46.295-05', '127.0.0.1      ', 1, NULL, NULL, NULL, NULL, 1);
INSERT INTO "Persona" VALUES (26, 3, 'EDWIN', 'REBAZA', 'CERPA', 'M', NULL, 1, '41229544', 3, '2016-01-25 18:20:20.5-05', '127.0.0.1      ', 3, '2016-01-25 18:20:20.5-05', '127.0.0.1      ', 1, NULL, NULL, NULL, NULL, 1);
INSERT INTO "Persona" VALUES (31, 3, 'PAOLA', 'HUARACHI', 'PFLÜCKER', 'F', NULL, 1, '42096852', 3, '2016-01-25 22:30:52.541-05', '127.0.0.1      ', 3, '2016-01-25 22:30:52.541-05', '127.0.0.1      ', 1, NULL, NULL, NULL, NULL, 1);


--
-- TOC entry 2779 (class 0 OID 76264)
-- Dependencies: 197
-- Data for Name: PersonaAdicional; Type: TABLE DATA; Schema: negocio; Owner: postgres
--

INSERT INTO "PersonaAdicional" VALUES (25, 1, 3, '2016-01-25 18:20:20.5-05', '127.0.0.1      ', 3, '2016-01-25 18:20:20.5-05', '127.0.0.1      ', 1, 1);
INSERT INTO "PersonaAdicional" VALUES (30, 1, 3, '2016-01-25 22:30:52.541-05', '127.0.0.1      ', 3, '2016-01-25 22:30:52.541-05', '127.0.0.1      ', 1, 1);
INSERT INTO "PersonaAdicional" VALUES (34, 3, 3, '2016-01-28 23:00:59.644-05', '127.0.0.1      ', 3, '2016-01-28 23:00:59.644-05', '127.0.0.1      ', 1, 1);
INSERT INTO "PersonaAdicional" VALUES (32, 1, 3, '2016-01-28 22:54:15.746-05', '127.0.0.1      ', 3, '2016-01-28 23:07:46.295-05', '127.0.0.1      ', 1, 1);


--
-- TOC entry 2780 (class 0 OID 76268)
-- Dependencies: 198
-- Data for Name: PersonaContactoProveedor; Type: TABLE DATA; Schema: negocio; Owner: postgres
--

INSERT INTO "PersonaContactoProveedor" VALUES (25, 26, 2, '3333', 3, '2016-01-25 18:20:20.5-05', '127.0.0.1      ', 3, '2016-01-25 18:20:20.5-05', '127.0.0.1      ', 1, 1);
INSERT INTO "PersonaContactoProveedor" VALUES (30, 31, 1, '3422', 3, '2016-01-25 22:30:52.541-05', '127.0.0.1      ', 3, '2016-01-25 22:30:52.541-05', '127.0.0.1      ', 1, 1);
INSERT INTO "PersonaContactoProveedor" VALUES (32, 33, 1, '3222', 3, '2016-01-28 22:54:15.746-05', '127.0.0.1      ', 3, '2016-01-28 22:54:15.746-05', '127.0.0.1      ', 1, 1);
INSERT INTO "PersonaContactoProveedor" VALUES (34, 35, 1, '4544', 3, '2016-01-28 23:00:59.644-05', '127.0.0.1      ', 3, '2016-01-28 23:00:59.644-05', '127.0.0.1      ', 1, 1);
INSERT INTO "PersonaContactoProveedor" VALUES (32, 36, 1, '3222', 3, '2016-01-28 23:07:46.295-05', '127.0.0.1      ', 3, '2016-01-28 23:07:46.295-05', '127.0.0.1      ', 1, 1);


--
-- TOC entry 2781 (class 0 OID 76272)
-- Dependencies: 199
-- Data for Name: PersonaDireccion; Type: TABLE DATA; Schema: negocio; Owner: postgres
--

INSERT INTO "PersonaDireccion" VALUES (25, 17, 1, 1, 1, 3, '2016-01-25 18:20:20.5-05', '127.0.0.1', 3, '2016-01-25 18:20:20.5-05', '127.0.0.1');
INSERT INTO "PersonaDireccion" VALUES (30, 20, 2, 1, 1, 3, '2016-01-25 22:30:52.541-05', '127.0.0.1', 3, '2016-01-25 22:30:52.541-05', '127.0.0.1');
INSERT INTO "PersonaDireccion" VALUES (32, 21, 2, 1, 1, 3, '2016-01-28 22:54:15.746-05', '127.0.0.1', 3, '2016-01-28 22:54:15.746-05', '127.0.0.1');
INSERT INTO "PersonaDireccion" VALUES (34, 22, 2, 1, 1, 3, '2016-01-28 23:00:59.644-05', '127.0.0.1', 3, '2016-01-28 23:00:59.644-05', '127.0.0.1');
INSERT INTO "PersonaDireccion" VALUES (32, 23, 2, 1, 1, 3, '2016-01-28 23:07:46.295-05', '127.0.0.1      ', 3, '2016-01-28 23:07:46.295-05', '127.0.0.1      ');


--
-- TOC entry 2782 (class 0 OID 76276)
-- Dependencies: 200
-- Data for Name: Personapotencial; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2783 (class 0 OID 76280)
-- Dependencies: 201
-- Data for Name: ProgramaNovios; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2784 (class 0 OID 76287)
-- Dependencies: 202
-- Data for Name: ProveedorCuentaBancaria; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2785 (class 0 OID 76291)
-- Dependencies: 203
-- Data for Name: ProveedorPersona; Type: TABLE DATA; Schema: negocio; Owner: postgres
--

INSERT INTO "ProveedorPersona" VALUES (30, 2, 3, '2016-01-25 22:30:52.541-05', '127.0.0.1', 3, '2016-01-25 22:30:52.541-05', '127.0.0.1', 1, 'INNOVA VIAJES ', 1);
INSERT INTO "ProveedorPersona" VALUES (34, 1, 3, '2016-01-28 23:00:59.644-05', '127.0.0.1', 3, '2016-01-28 23:00:59.644-05', '127.0.0.1', 1, 'LAN PERU S.A.', 1);
INSERT INTO "ProveedorPersona" VALUES (32, 2, 3, '2016-01-28 22:54:15.746-05', '127.0.0.1', 3, '2016-01-28 23:07:46.295-05', '127.0.0.1', 1, 'COSTAMAR', 1);


--
-- TOC entry 2786 (class 0 OID 76295)
-- Dependencies: 204
-- Data for Name: ProveedorTipoServicio; Type: TABLE DATA; Schema: negocio; Owner: postgres
--

INSERT INTO "ProveedorTipoServicio" VALUES (32, 3, 34, 2, 3, 3, '2016-01-28 23:07:46.295-05', '127.0.0.1', 3, '2016-01-28 23:07:46.295-05', '127.0.0.1', 1, 1);


--
-- TOC entry 2787 (class 0 OID 76302)
-- Dependencies: 205
-- Data for Name: RutaServicio; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2788 (class 0 OID 76306)
-- Dependencies: 206
-- Data for Name: SaldosServicio; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2789 (class 0 OID 76310)
-- Dependencies: 207
-- Data for Name: ServicioCabecera; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2790 (class 0 OID 76319)
-- Dependencies: 208
-- Data for Name: ServicioDetalle; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2791 (class 0 OID 76330)
-- Dependencies: 209
-- Data for Name: ServicioMaestroServicio; Type: TABLE DATA; Schema: negocio; Owner: postgres
--

INSERT INTO "ServicioMaestroServicio" VALUES (3, 2, 2, '2016-01-28 21:48:55.351-05', '127.0.0.1      ', 2, '2016-01-28 21:48:55.351-05', '127.0.0.1', 1, 1);
INSERT INTO "ServicioMaestroServicio" VALUES (3, 6, 2, '2016-01-28 21:48:55.351-05', '127.0.0.1      ', 2, '2016-01-28 21:48:55.351-05', '127.0.0.1', 1, 1);


--
-- TOC entry 2792 (class 0 OID 76334)
-- Dependencies: 210
-- Data for Name: Telefono; Type: TABLE DATA; Schema: negocio; Owner: postgres
--

INSERT INTO "Telefono" VALUES (13, '3323289', 0, 3, '2016-01-25 18:20:20.5-05', '127.0.0.1', 3, '2016-01-25 18:20:20.5-05', '127.0.0.1', 1, 1);
INSERT INTO "Telefono" VALUES (14, '997895622', 1, 3, '2016-01-25 18:20:20.5-05', '127.0.0.1', 3, '2016-01-25 18:20:20.5-05', '127.0.0.1', 1, 1);
INSERT INTO "Telefono" VALUES (18, '3323289', 0, 3, '2016-01-25 22:30:52.541-05', '127.0.0.1', 3, '2016-01-25 22:30:52.541-05', '127.0.0.1', 1, 1);
INSERT INTO "Telefono" VALUES (19, '962320680', 1, 3, '2016-01-25 22:30:52.541-05', '127.0.0.1', 3, '2016-01-25 22:30:52.541-05', '127.0.0.1', 1, 1);
INSERT INTO "Telefono" VALUES (20, '975445455', 1, 3, '2016-01-28 22:54:15.746-05', '127.0.0.1', 3, '2016-01-28 22:54:15.746-05', '127.0.0.1', 1, 1);
INSERT INTO "Telefono" VALUES (21, '986436555', 1, 3, '2016-01-28 23:00:59.644-05', '127.0.0.1', 3, '2016-01-28 23:00:59.644-05', '127.0.0.1', 1, 1);
INSERT INTO "Telefono" VALUES (22, '975445455', 1, 3, '2016-01-28 23:07:46.295-05', NULL, 3, '2016-01-28 23:07:46.295-05', NULL, 1, 1);


--
-- TOC entry 2793 (class 0 OID 76338)
-- Dependencies: 211
-- Data for Name: TelefonoDireccion; Type: TABLE DATA; Schema: negocio; Owner: postgres
--

INSERT INTO "TelefonoDireccion" VALUES (13, 17, 3, '2016-01-25 18:20:20.5-05', '127.0.0.1', 3, '2016-01-25 18:20:20.5-05', '127.0.0.1', 1, 1);
INSERT INTO "TelefonoDireccion" VALUES (18, 20, 3, '2016-01-25 22:30:52.541-05', '127.0.0.1', 3, '2016-01-25 22:30:52.541-05', '127.0.0.1', 1, 1);


--
-- TOC entry 2794 (class 0 OID 76342)
-- Dependencies: 212
-- Data for Name: TelefonoPersona; Type: TABLE DATA; Schema: negocio; Owner: postgres
--

INSERT INTO "TelefonoPersona" VALUES (14, 26, 3, '2016-01-25 18:20:20.5-05', '127.0.0.1', 3, '2016-01-25 18:20:20.5-05', '127.0.0.1', 1, 1);
INSERT INTO "TelefonoPersona" VALUES (19, 31, 3, '2016-01-25 22:30:52.541-05', '127.0.0.1', 3, '2016-01-25 22:30:52.541-05', '127.0.0.1', 1, 1);
INSERT INTO "TelefonoPersona" VALUES (20, 33, 3, '2016-01-28 22:54:15.746-05', '127.0.0.1', 3, '2016-01-28 22:54:15.746-05', '127.0.0.1', 1, 1);
INSERT INTO "TelefonoPersona" VALUES (21, 35, 3, '2016-01-28 23:00:59.644-05', '127.0.0.1', 3, '2016-01-28 23:00:59.644-05', '127.0.0.1', 1, 1);
INSERT INTO "TelefonoPersona" VALUES (22, 36, 3, '2016-01-28 23:07:46.295-05', '127.0.0.1      ', 3, '2016-01-28 23:07:46.295-05', '127.0.0.1      ', 1, 1);


--
-- TOC entry 2795 (class 0 OID 76346)
-- Dependencies: 213
-- Data for Name: TipoCambio; Type: TABLE DATA; Schema: negocio; Owner: postgres
--

INSERT INTO "TipoCambio" VALUES (1, '2016-01-29', 2, 2, 1.000000, 4, '2016-01-29 00:30:54.442-05', '127.0.0.1      ', 4, '2016-01-29 00:30:54.442-05', '127.0.0.1      ', 1, 1);
INSERT INTO "TipoCambio" VALUES (2, '2016-01-29', 1, 1, 1.000000, 4, '2016-01-29 00:31:12.026-05', '127.0.0.1      ', 4, '2016-01-29 00:31:12.026-05', '127.0.0.1      ', 1, 1);
INSERT INTO "TipoCambio" VALUES (3, '2016-01-29', 2, 1, 3.250000, 4, '2016-01-29 00:31:28.529-05', '127.0.0.1      ', 4, '2016-01-29 00:31:28.529-05', '127.0.0.1      ', 1, 1);
INSERT INTO "TipoCambio" VALUES (4, '2016-01-29', 1, 2, 0.250000, 4, '2016-01-29 00:32:02.688-05', '127.0.0.1      ', 4, '2016-01-29 00:32:02.688-05', '127.0.0.1      ', 1, 1);


--
-- TOC entry 2796 (class 0 OID 76350)
-- Dependencies: 214
-- Data for Name: Tramo; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2797 (class 0 OID 76357)
-- Dependencies: 215
-- Data for Name: TransaccionTipoCambio; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2856 (class 0 OID 0)
-- Dependencies: 216
-- Name: seq_archivocargado; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_archivocargado', 1, false);


--
-- TOC entry 2857 (class 0 OID 0)
-- Dependencies: 217
-- Name: seq_comprobanteadicional; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_comprobanteadicional', 1, false);


--
-- TOC entry 2858 (class 0 OID 0)
-- Dependencies: 218
-- Name: seq_comprobantegenerado; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_comprobantegenerado', 1, false);


--
-- TOC entry 2859 (class 0 OID 0)
-- Dependencies: 219
-- Name: seq_consolidador; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_consolidador', 3, true);


--
-- TOC entry 2860 (class 0 OID 0)
-- Dependencies: 220
-- Name: seq_correoelectronico; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_correoelectronico', 4, true);


--
-- TOC entry 2861 (class 0 OID 0)
-- Dependencies: 221
-- Name: seq_cuentabancaria; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_cuentabancaria', 1, false);


--
-- TOC entry 2862 (class 0 OID 0)
-- Dependencies: 222
-- Name: seq_cuentabancariaproveedor; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_cuentabancariaproveedor', 1, false);


--
-- TOC entry 2863 (class 0 OID 0)
-- Dependencies: 223
-- Name: seq_detallearchivocargado; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_detallearchivocargado', 1, false);


--
-- TOC entry 2864 (class 0 OID 0)
-- Dependencies: 224
-- Name: seq_detallecomprobantegenerado; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_detallecomprobantegenerado', 1, false);


--
-- TOC entry 2865 (class 0 OID 0)
-- Dependencies: 225
-- Name: seq_direccion; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_direccion', 23, true);


--
-- TOC entry 2866 (class 0 OID 0)
-- Dependencies: 226
-- Name: seq_documentoservicio; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_documentoservicio', 1, false);


--
-- TOC entry 2867 (class 0 OID 0)
-- Dependencies: 227
-- Name: seq_eventoservicio; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_eventoservicio', 1, false);


--
-- TOC entry 2868 (class 0 OID 0)
-- Dependencies: 228
-- Name: seq_maestroservicio; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_maestroservicio', 1, false);


--
-- TOC entry 2869 (class 0 OID 0)
-- Dependencies: 229
-- Name: seq_movimientocuenta; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_movimientocuenta', 1, false);


--
-- TOC entry 2870 (class 0 OID 0)
-- Dependencies: 230
-- Name: seq_novios; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_novios', 1, false);


--
-- TOC entry 2871 (class 0 OID 0)
-- Dependencies: 231
-- Name: seq_obligacionxpagar; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_obligacionxpagar', 1, false);


--
-- TOC entry 2872 (class 0 OID 0)
-- Dependencies: 232
-- Name: seq_pago; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_pago', 1, false);


--
-- TOC entry 2873 (class 0 OID 0)
-- Dependencies: 233
-- Name: seq_pax; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_pax', 1, false);


--
-- TOC entry 2874 (class 0 OID 0)
-- Dependencies: 234
-- Name: seq_persona; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_persona', 36, true);


--
-- TOC entry 2875 (class 0 OID 0)
-- Dependencies: 235
-- Name: seq_personapotencial; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_personapotencial', 1, false);


--
-- TOC entry 2876 (class 0 OID 0)
-- Dependencies: 236
-- Name: seq_ruta; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_ruta', 1, false);


--
-- TOC entry 2877 (class 0 OID 0)
-- Dependencies: 237
-- Name: seq_salsoservicio; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_salsoservicio', 1, false);


--
-- TOC entry 2878 (class 0 OID 0)
-- Dependencies: 238
-- Name: seq_serviciocabecera; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_serviciocabecera', 1, false);


--
-- TOC entry 2879 (class 0 OID 0)
-- Dependencies: 239
-- Name: seq_serviciodetalle; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_serviciodetalle', 1, false);


--
-- TOC entry 2880 (class 0 OID 0)
-- Dependencies: 240
-- Name: seq_serviciosnovios; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_serviciosnovios', 1, false);


--
-- TOC entry 2881 (class 0 OID 0)
-- Dependencies: 241
-- Name: seq_telefono; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_telefono', 22, true);


--
-- TOC entry 2882 (class 0 OID 0)
-- Dependencies: 242
-- Name: seq_tipocambio; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_tipocambio', 4, true);


--
-- TOC entry 2883 (class 0 OID 0)
-- Dependencies: 243
-- Name: seq_tramo; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_tramo', 1, false);


--
-- TOC entry 2884 (class 0 OID 0)
-- Dependencies: 244
-- Name: seq_transacciontipocambio; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_transacciontipocambio', 1, false);


SET search_path = seguridad, pg_catalog;

--
-- TOC entry 2830 (class 0 OID 76485)
-- Dependencies: 260
-- Data for Name: rol; Type: TABLE DATA; Schema: seguridad; Owner: postgres
--

INSERT INTO rol VALUES (1, 'Administrador', 1, 2, '2016-01-01 00:00:00-05', '0.0.0.0', 2, '2016-01-01 00:00:00-05', '0.0.0.0', 1);
INSERT INTO rol VALUES (2, 'vendedor', 1, 2, '2016-01-22 17:26:24.023-05', '0.0.0.0', 2, '2016-01-22 17:26:24.023-05', '0.0.0.0', 1);
INSERT INTO rol VALUES (3, 'Supervisor Administrativo', 1, 2, '2016-01-22 17:26:24.023-05', '0.0.0.0', 2, '2016-01-22 17:26:24.023-05', '0.0.0.0', 1);
INSERT INTO rol VALUES (4, 'Supervisor Ventas', 1, 2, '2016-01-22 17:26:24.023-05', '0.0.0.0', 2, '2016-01-22 17:26:24.023-05', '0.0.0.0', 1);
INSERT INTO rol VALUES (5, 'Administrador Sistema', 100, 1, '2016-01-01 00:00:00-05', '0.0.0.0', 1, '2016-01-01 00:00:00-05', '0.0.0.0.', 1);


--
-- TOC entry 2831 (class 0 OID 76489)
-- Dependencies: 261
-- Data for Name: usuario; Type: TABLE DATA; Schema: seguridad; Owner: postgres
--

INSERT INTO usuario VALUES (2, 'admin@innovaviajes.pe', 'F9jP2jxpZxi1Pi9dPuNQeA==', 1, 'Administrador', 'Innova Viajes', NULL, '2016-01-20', false, false, '2017-01-01', 1, 2, '2016-01-01 00:00:00-05', '0.0.0.0', 2, '2016-01-01 00:00:00-05', '0.0.0.0', 1);
INSERT INTO usuario VALUES (4, 'edwin.rebaza@innovaviajes.pe', 'lTWx84S1UEGdaLnnFIlkeQ==', 3, 'EDWIN', 'REBAZA', 'CERPA', '1982-05-30', false, false, '2016-03-14', 1, 2, '2016-01-29 00:19:10.455-05', '127.0.0.1', 4, '2016-01-29 00:24:21.917-05', '127.0.0.1', 1);
INSERT INTO usuario VALUES (3, 'paola.huarachi@innovaviajes.pe', '0m/hFwdSaDdN3Hw6Z2Vbow==', 4, 'PAOLA', 'HUARACHI', 'PFLÜCKER', '1983-09-02', true, false, '2016-04-21', 1, 2, '2016-01-22 17:32:07.173-05', '127.0.0.1', 3, '2016-01-30 14:33:10.318-05', '127.0.0.1', 1);
INSERT INTO usuario VALUES (1, 'administrador@rhsistemas.pe', 'F9jP2jxpZxi1Pi9dPuNQeA==', 5, 'Administrador', 'RH Viajes', NULL, '1980-01-20', false, false, '2017-01-01', 100, 1, '2016-01-01 00:00:00-05', '0.0.0.0', 1, '2016-01-01 00:00:00-05', '0.0.0.0', 1);


SET search_path = soporte, pg_catalog;

--
-- TOC entry 2832 (class 0 OID 76500)
-- Dependencies: 263
-- Data for Name: ConfiguracionTipoServicio; Type: TABLE DATA; Schema: soporte; Owner: postgres
--

INSERT INTO "ConfiguracionTipoServicio" VALUES (3, false, false, false, true, true, false, false, true, true, true, false, false, false, false, false, 2, '2016-01-28 21:52:39.154-05', '127.0.0.1', 2, '2016-01-28 23:58:03.57-05', '127.0.0.1', 0, 1);
INSERT INTO "ConfiguracionTipoServicio" VALUES (3, false, false, false, true, true, false, false, true, true, true, true, false, false, false, false, 2, '2016-01-28 23:58:03.57-05', '127.0.0.1', 2, '2016-01-28 23:58:03.57-05', '127.0.0.1', 1, 1);


--
-- TOC entry 2833 (class 0 OID 76504)
-- Dependencies: 264
-- Data for Name: Parametro; Type: TABLE DATA; Schema: soporte; Owner: postgres
--

INSERT INTO "Parametro" VALUES (1, 'IGV', 'IMPUSTO GENERAL A LAS VENTAS', '0.18', 'A', true, 1, 2, '2016-01-22 10:31:30.399-05', '0.0.0.0', 2, '2016-01-22 10:31:30.399-05', '0.0.0.0', 1);
INSERT INTO "Parametro" VALUES (2, 'TIPO DE CAMBIO', 'TIPO DE CAMBIO', '2.8', 'A', true, 1, 2, '2016-01-22 10:31:30.399-05', '0.0.0.0', 2, '2016-01-22 10:31:30.399-05', '0.0.0.0', 1);
INSERT INTO "Parametro" VALUES (3, 'TASA PRE CREDITO', 'TASA PREDETERMINADA DE CREDITO', '0.015', 'A', true, 1, 2, '2016-01-22 10:31:30.399-05', '0.0.0.0', 2, '2016-01-22 10:31:30.399-05', '0.0.0.0', 1);
INSERT INTO "Parametro" VALUES (4, 'CODIGO FEE', 'CODIGO DE SERVICIO FEE', '6', 'A', true, 1, 2, '2016-01-22 10:31:30.399-05', '0.0.0.0', 2, '2016-01-22 10:31:30.399-05', '0.0.0.0', 1);
INSERT INTO "Parametro" VALUES (6, 'HORAS PARA CHECKIN', '"NUMERO DE HORAS PARA CHECKIN"', '100', 'A', true, 1, 2, '2016-01-22 10:31:30.399-05', '0.0.0.0', 2, '2016-01-22 10:31:30.399-05', '0.0.0.0', 1);
INSERT INTO "Parametro" VALUES (5, 'CODIGO IGV', 'CODIGO DEL SERVIDIO DE IMPUESTO IGV', '6', 'A', true, 1, 2, '2016-01-22 10:31:30.399-05', '0.0.0.0', 2, '2016-01-22 10:31:30.399-05', '0.0.0.0', 1);


--
-- TOC entry 2829 (class 0 OID 76449)
-- Dependencies: 252
-- Data for Name: Tablamaestra; Type: TABLE DATA; Schema: soporte; Owner: postgres
--

INSERT INTO "Tablamaestra" VALUES (10, 3, 'IMPORTADOR/EXPORTADOR', 'IMPORTA Y EXPORTA', 10, 'A', 'IMPEX', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (10, 21, 'AMIGO', 'AMIGO DEL CLIENTE', 10, 'A', 'AMI', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (8, 15, 'ASEGURADORA', 'SEGUROS DE ASISTENCIA', 8, 'A', 'SEGUR', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (5, 1, 'OTROS', 'OTRO TIPO DE DOCUMENTO', 5, 'A', 'OTRO', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (1, 0, 'MAESTRO DE TIPO DE DOCUMENTO', 'MAESTRO DE TIPO DE DOCUMENTO', 1, 'A', NULL, 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (2, 0, 'MAESTRO DE VIAS', 'MAESTRO DE VIAS', 2, 'A', NULL, 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (3, 0, 'MAESTRO DE RUBRO', 'MAESTRO DE RUBRO', 3, 'A', NULL, 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (4, 0, 'MAESTRO DE AREAS', 'MAESTRO DE AREAS LO', 0, 'A', NULL, 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (5, 0, 'MAESTRO DE EMPRESAS OPERADORAS', 'MAESTRO DE EMPRESAS OPERADORAS', 5, 'A', NULL, 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (6, 0, 'MAESTRO DE PERSONAS', 'MAESTRO DE PERSONAS', 6, 'A', NULL, 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (7, 0, 'MAESTRO DE MENSAJES', 'MAESTRO DE MENSAJES', 7, 'A', NULL, 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (8, 0, 'MAESTRO DE BANCOS', 'MAESTRO DE BANCOS', 8, 'A', NULL, 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (9, 0, 'MAESTRO DE ESTADO CIVIL', 'MAESTRO DE ESTADO CIVIL', 9, 'A', NULL, 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (10, 0, 'MAESTRO DE CONTINENTES', 'MAESTRO DE CONTINENTES', 10, 'A', NULL, 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (11, 0, 'MAESTRO TIPO DE DESTINO', 'MAESTRO TIPO DE DESTINO', 11, 'A', NULL, 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (12, 0, 'MAESTRO DE FORMA DE PAGO', 'MAESTRO DE FORMA DE PAGO', 13, 'A', NULL, 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (13, 0, 'MAESTRO DE ESTADOS DE PAGO', 'MAESTRO DE ESTADOS DE PAGO', 14, 'A', NULL, 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (14, 0, 'MAESTRO DE ESTADO SERVICIO', 'MAESTRO DE ESTADOS DE SERVICIO', 15, 'A', NULL, 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (15, 0, 'MAESTRO TIPO DE PROVEEDOR', 'MAESTRO TIPO DE PROVEEDOR', 0, 'A', NULL, 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (16, 0, 'MAESTRO DE TIPO DE COMPROBANTE', 'MAESTRO DE TIPO DE COMPROBANTE', 17, 'A', NULL, 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (17, 0, 'MAESTRO DE DOCUMENTOS', 'MAESTRO DE DOCUMENTOS', 18, 'A', NULL, 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (18, 0, 'MAESTRO MONEDAS', 'MAESTRO MONEDAS', 0, 'A', NULL, 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (19, 0, 'MAESTRO TIPO CUENTA', 'MAESTRO TIPO CUENTA', 21, 'A', NULL, 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (20, 0, 'MAESTRO PROVEEDOR DE TARJETA', 'MAESTRO PROVEEDOR DE TARJETA', 22, 'A', NULL, 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (21, 0, 'MAESTRO DE RELACION', 'MAESTRO DE RELACION', 23, 'A', NULL, 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (1, 1, 'DNI', 'DOCUMENO NACIONAL DE IDENTIDAD', 1, 'A', 'DNI', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (2, 1, 'CARNÉ DE EXTRANJERIA', 'CARNÉ DE EXTRANJERIA', 2, 'A', 'CE', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (3, 1, 'RUC', 'REGISTRO UNICO DEL CONTRIBUYENTE', 3, 'A', 'RUC', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (4, 1, 'PASAPORTE', 'PASAPORTE', 4, 'A', 'PASPA', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (1, 2, 'AVENIDA', 'AVENIDA', 1, 'A', 'AV', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (2, 2, 'CALLE', 'CALLE', 0, 'A', 'CA', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (3, 2, 'JIRON', 'JIRON', 3, 'A', 'JR', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (4, 2, 'PASAJE', 'PASAJE', 4, 'A', 'PSJ', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (1, 3, 'AGENCIA DE VIAJES', 'AGENCIA DE VIAJES', 1, 'A', 'AGE', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (2, 3, 'HOTEL', 'HOTEL HOSPEDAJE', 2, 'A', 'HOTE', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (3, 3, 'AEROLINEA', 'AEROLINEAS', 3, 'A', 'AERO', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (4, 3, 'TELEFONIA', 'TELEFONIA', 4, 'A', 'TELEF', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (5, 3, 'ASEGURADORAS', 'ASEGURADORAS', 5, 'A', 'ASEG', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (6, 3, 'LIBRERIA', 'LIBRERIA', 6, 'A', 'LIB', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (7, 3, 'FERRETERIA', 'FERRETERIA', 7, 'A', 'FER', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (8, 3, 'BELLEZA', 'PELUQUERIA Y SPA', 8, 'A', 'BEL', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (9, 3, 'EDUCACION', 'EDUCACION', 9, 'A', 'EDU', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (1, 4, 'VENTAS', 'VENTAS', 2, 'A', 'VEN', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (2, 4, 'FINANZAS', 'FINANZAS', 3, 'A', 'FINA', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (3, 4, 'COMPRAS', 'COMPRAS', 4, 'A', 'COM', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (4, 4, 'CONTABILIDAD', 'CONTABILIDAD', 6, 'A', 'CON', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (1, 5, 'CLARO', 'CLARO', 1, 'A', 'CLA', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (2, 5, 'MOVISTAR', 'MOVISTAR', 2, 'A', 'MOV', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (3, 5, 'ENTEL', 'ENTEL', 3, 'A', 'ENT', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (1, 6, 'CLIENTE', 'CLIENTE', 1, 'A', 'CLI', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (2, 6, 'PROVEEDOR', 'PROVEEDOR', 2, 'A', 'PRO', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (3, 6, 'CONTACTO', 'CONTACTO DE PROVEEDOR', 3, 'A', 'CPRO', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (1, 8, 'BANCO DE CREDITO', 'BANCO DE CREDITO DEL PERU', 1, 'A', 'BCP', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (2, 8, 'BANCO BBVA CONTINENTAL', 'BANCO BBVA CONTINENTAL', 2, 'A', 'BBVA', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (3, 8, 'BANCO FINANCIERO', 'BANCO FINANCIERO DEL PERU', 3, 'A', 'BFP', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (4, 8, 'BANCO INTERBANK', 'BANCO INTERNACIONAL DEL PERU', 4, 'A', 'IBK', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (5, 8, 'BANCO SCOTIABANK', 'BANCO SCOTIABANK', 5, 'A', 'SCO', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (6, 8, 'BANCO CITYBANK', 'BANCO CITYBANK', 6, 'A', 'CITI', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (1, 9, 'SOLTERO', 'SOLTERO', 1, 'A', 'SOL', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (2, 9, 'CASADO', 'CASADO', 2, 'A', 'CAS', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (3, 9, 'DIVORCIADO', 'DIVORCIADO', 3, 'A', 'DIV', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (4, 9, 'VIUDO', 'VIUDO', 4, 'A', 'VIU', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (1, 10, 'AMERICA DEL SUR', 'AMERCIA DEL SUR', 1, 'A', 'AMSUR', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (2, 10, 'AMERICA DEL CENTRO', 'AMERICA DEL CENTRO', 2, 'A', 'AMCEN', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (3, 10, 'AMERICA DEL NORTE', 'AMERICA DEL NORTE', 3, 'A', 'AMNOR', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (4, 10, 'EUROPA', 'EUROPA', 4, 'A', 'EUR', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (5, 10, 'ASIA', 'ASIA', 5, 'A', 'ASI', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (6, 10, 'AFRICA', 'AFRICA', 6, 'A', 'AFR', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (7, 10, 'OCEANIA', 'OCEANIA', 7, 'A', 'OCE', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (1, 11, 'PLAYA', 'PLAYA', 1, 'A', 'PLA', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (2, 11, 'CIUDAD', 'CIUDAD', 2, 'A', 'CIU', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (3, 11, 'NIEVE', 'NIEVE', 3, 'A', 'NIEVE', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (4, 11, 'SELVA', 'SELVA', 4, 'A', 'SEL', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (1, 12, 'EFECTIVO', 'EFECTIVO', 1, 'A', 'EFE', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (2, 12, 'DEPOSITO EN CUENTA', 'DEPOSITO EN CUENTA', 2, 'A', 'DEPC', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (3, 12, 'TRANSFERENCIA', 'TRANSFERENCIA', 3, 'A', 'TRAN', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (4, 12, 'TARJETA DE CREDITO', 'TARJETA DE CREDITO', 4, 'A', 'TCRE', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (1, 13, 'PENDIENTE', 'PENDIENTE', 1, 'A', 'PEN', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (2, 13, 'PAGADO', 'PAGADO', 2, 'A', 'PAG', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (3, 13, 'PENDIENTE CON MORA', 'PENDIENTE CON MORA', 3, 'A', 'PEMOR', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (1, 14, 'PENDIENTE', 'PENDIENTE DE CIERRE', 1, 'A', 'PEN', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (2, 14, 'CERRADO', 'CERRADO', 2, 'A', 'CERR', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (3, 14, 'ANULADO', 'ANULADO', 3, 'A', 'ANU', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (4, 14, 'OBSERVADO', 'OBSERVADO', 4, 'A', 'OBS', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (1, 15, 'AEROLINEA', 'AEROLINEA', 1, 'A', 'AERO', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (2, 15, 'CONSOLIDADOR', 'CONSOLIDADOR', 2, 'A', 'CONS', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (3, 15, 'OPERADOR', 'OPERADOR', 3, 'A', 'OPER', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (4, 15, 'TRANSPORTISTA', 'EMPRESA DE TRANSPORTES', 4, 'A', 'ETRA', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (5, 15, 'TRASLADISTA', 'TRASLADISTA', 5, 'A', 'TRAS', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (6, 15, 'HOTEL', 'HOTEL', 6, 'A', 'HOTE', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (7, 15, 'MAYORISTA', 'MAYORISTA', 7, 'A', 'MAYO', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (1, 16, 'FACTURA', 'FACTURA', 1, 'A', 'F', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (2, 16, 'BOLETA', 'BOLETA', 2, 'A', 'B', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (3, 16, 'DOCUMENTO DE COBRANZA', 'DOCUMENTO DE COBRANZA', 3, 'A', 'DC', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (4, 16, 'NOTA DE CREDITO', 'NOTA DE CREDITO', 4, 'A', 'NC', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (1, 17, 'TICKET ELECTRONICO', 'TICKET ELECTRONICO', 1, 'A', 'TIEL', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (2, 17, 'DOCUMENTO DE IDENTIDAD', 'DOCUMENTO DE IDENTIDAD', 2, 'A', 'DOCID', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (3, 17, 'VOUCHER DE DEPOSITO', 'VOUCHER DE DEPOSITO', 3, 'A', 'VODE', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (1, 18, 'NUEVOS SOLES', 'NUEVOS SOLES', 1, 'A', 'S/.', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (2, 18, 'DOLARES AMERICANOS', 'DOLARES AMERICANOS', 2, 'A', '$', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (1, 19, 'AHORROS', 'CUENTA DE AHORROS', 1, 'A', 'AH', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (2, 19, 'CUENTA CORRIENTE', 'CUENTA CORRIENTE', 2, 'A', 'CC', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (1, 20, 'VISA', 'VISA', 1, 'A', 'VISA', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (2, 20, 'MASTERCARD', 'MASTER CARD', 2, 'A', 'MC', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (3, 20, 'AMERICAN EXPRESS', 'AMERICAN EXPRESS', 3, 'A', 'AMEX', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (4, 20, 'DINERS', 'DINERS CLUB', 4, 'A', 'DINE', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (1, 21, 'EL MISMO', 'EL MISMO', 1, 'A', 'MISM', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (2, 21, 'ESPOSA', 'ESPOSA', 2, 'A', 'ESPO', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (3, 21, 'HIJO', 'HIJO', 3, 'A', 'HIJO', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (4, 21, 'HIJA', 'HIJA', 4, 'A', 'HIJA', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (5, 21, 'PADRE', 'PADRE', 5, 'A', 'PAD', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (6, 21, 'MADRE', 'MADRE', 6, 'A', 'MAD', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (7, 21, 'ABUELO', 'ABUELO', 7, 'A', 'ABUO', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (8, 21, 'ABUELA', 'ABUELA', 8, 'A', 'ABUA', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (9, 21, 'COLABORADOR', 'EMPLEADO DE LA EMPRESA', 9, 'A', 'COLAB', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (11, 21, 'SOBRINO', 'SOBRINO O SOBRINA', 11, 'A', 'SOBRI', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);
INSERT INTO "Tablamaestra" VALUES (11, 3, 'TRASLADOS', 'TRASLADOS ', 11, 'A', 'TRASL', 1, 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 2, '2016-01-22 10:28:32.231-05', '0.0.0.0', 1);


--
-- TOC entry 2834 (class 0 OID 76508)
-- Dependencies: 265
-- Data for Name: TipoCambio; Type: TABLE DATA; Schema: soporte; Owner: postgres
--



--
-- TOC entry 2835 (class 0 OID 76512)
-- Dependencies: 266
-- Data for Name: destino; Type: TABLE DATA; Schema: soporte; Owner: postgres
--

INSERT INTO destino VALUES (2, 1, 1, 'LIM', 2, 'LIMA', 3, '2016-01-29 00:14:18.131-05', '127.0.0.1', 3, '2016-01-29 00:14:18.131-05', '127.0.0.1', 1, 1);
INSERT INTO destino VALUES (3, 1, 1, 'AQP', 2, 'AREQUIPA', 3, '2016-01-29 00:14:52.423-05', '127.0.0.1', 3, '2016-01-29 00:14:52.423-05', '127.0.0.1', 1, 1);
INSERT INTO destino VALUES (4, 1, 1, 'PIU', 2, 'PIURA', 3, '2016-01-29 00:15:09.154-05', '127.0.0.1', 3, '2016-01-29 00:15:09.154-05', '127.0.0.1', 1, 1);


--
-- TOC entry 2828 (class 0 OID 76440)
-- Dependencies: 250
-- Data for Name: pais; Type: TABLE DATA; Schema: soporte; Owner: postgres
--

INSERT INTO pais VALUES (1, 'PERÚ', 1, 2, '2016-01-22 16:27:21.48-05', '127.0.0.1', 2, '2016-01-22 16:27:21.48-05', '127.0.0.1', 1, NULL, NULL, 1);


--
-- TOC entry 2885 (class 0 OID 0)
-- Dependencies: 267
-- Name: seq_comun; Type: SEQUENCE SET; Schema: soporte; Owner: postgres
--

SELECT pg_catalog.setval('seq_comun', 2, true);


--
-- TOC entry 2886 (class 0 OID 0)
-- Dependencies: 268
-- Name: seq_destino; Type: SEQUENCE SET; Schema: soporte; Owner: postgres
--

SELECT pg_catalog.setval('seq_destino', 4, true);


--
-- TOC entry 2887 (class 0 OID 0)
-- Dependencies: 269
-- Name: seq_pais; Type: SEQUENCE SET; Schema: soporte; Owner: postgres
--

SELECT pg_catalog.setval('seq_pais', 1, false);


--
-- TOC entry 2827 (class 0 OID 76431)
-- Dependencies: 248
-- Data for Name: ubigeo; Type: TABLE DATA; Schema: soporte; Owner: postgres
--

INSERT INTO ubigeo VALUES ('010000', '01', '00', '00', 'AMAZONAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010100', '01', '01', '00', 'CHACHAPOYAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010101', '01', '01', '01', 'CHACHAPOYAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010102', '01', '01', '02', 'ASUNCION', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010103', '01', '01', '03', 'BALSAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010104', '01', '01', '04', 'CHETO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010105', '01', '01', '05', 'CHILIQUIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010106', '01', '01', '06', 'CHUQUIBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010107', '01', '01', '07', 'GRANADA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010108', '01', '01', '08', 'HUANCAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010109', '01', '01', '09', 'LA JALCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010110', '01', '01', '10', 'LEIMEBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010111', '01', '01', '11', 'LEVANTO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010112', '01', '01', '12', 'MAGDALENA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010113', '01', '01', '13', 'MARISCAL CASTILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010114', '01', '01', '14', 'MOLINOPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010115', '01', '01', '15', 'MONTEVIDEO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010116', '01', '01', '16', 'OLLEROS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010117', '01', '01', '17', 'QUINJALCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010118', '01', '01', '18', 'SAN FRANCISCO DE DAGUAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010119', '01', '01', '19', 'SAN ISIDRO DE MAINO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010120', '01', '01', '20', 'SOLOCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010121', '01', '01', '21', 'SONCHE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010200', '01', '02', '00', 'BAGUA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010201', '01', '02', '01', 'BAGUA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010202', '01', '02', '02', 'ARAMANGO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010203', '01', '02', '03', 'COPALLIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010204', '01', '02', '04', 'EL PARCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010205', '01', '02', '05', 'IMAZA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010206', '01', '02', '06', 'LA PECA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010300', '01', '03', '00', 'BONGARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010301', '01', '03', '01', 'JUMBILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010302', '01', '03', '02', 'CHISQUILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010303', '01', '03', '03', 'CHURUJA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010304', '01', '03', '04', 'COROSHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010305', '01', '03', '05', 'CUISPES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010306', '01', '03', '06', 'FLORIDA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010307', '01', '03', '07', 'JAZAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010308', '01', '03', '08', 'RECTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010309', '01', '03', '09', 'SAN CARLOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010310', '01', '03', '10', 'SHIPASBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010311', '01', '03', '11', 'VALERA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010312', '01', '03', '12', 'YAMBRASBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010400', '01', '04', '00', 'CONDORCANQUI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010401', '01', '04', '01', 'NIEVA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010402', '01', '04', '02', 'EL CENEPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010403', '01', '04', '03', 'RIO SANTIAGO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010500', '01', '05', '00', 'LUYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010501', '01', '05', '01', 'LAMUD', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010502', '01', '05', '02', 'CAMPORREDONDO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010503', '01', '05', '03', 'COCABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010504', '01', '05', '04', 'COLCAMAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010505', '01', '05', '05', 'CONILA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010506', '01', '05', '06', 'INGUILPATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010507', '01', '05', '07', 'LONGUITA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010508', '01', '05', '08', 'LONYA CHICO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010509', '01', '05', '09', 'LUYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010510', '01', '05', '10', 'LUYA VIEJO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010511', '01', '05', '11', 'MARIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010512', '01', '05', '12', 'OCALLI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010513', '01', '05', '13', 'OCUMAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010514', '01', '05', '14', 'PISUQUIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010515', '01', '05', '15', 'PROVIDENCIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010516', '01', '05', '16', 'SAN CRISTOBAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010517', '01', '05', '17', 'SAN FRANCISCO DEL YESO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010518', '01', '05', '18', 'SAN JERONIMO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010519', '01', '05', '19', 'SAN JUAN DE LOPECANCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010520', '01', '05', '20', 'SANTA CATALINA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010521', '01', '05', '21', 'SANTO TOMAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010522', '01', '05', '22', 'TINGO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010523', '01', '05', '23', 'TRITA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010600', '01', '06', '00', 'RODRIGUEZ DE MENDOZA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010601', '01', '06', '01', 'SAN NICOLAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010602', '01', '06', '02', 'CHIRIMOTO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010603', '01', '06', '03', 'COCHAMAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010604', '01', '06', '04', 'HUAMBO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010605', '01', '06', '05', 'LIMABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010606', '01', '06', '06', 'LONGAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010607', '01', '06', '07', 'MARISCAL BENAVIDES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010608', '01', '06', '08', 'MILPUC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010609', '01', '06', '09', 'OMIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010610', '01', '06', '10', 'SANTA ROSA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010611', '01', '06', '11', 'TOTORA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010612', '01', '06', '12', 'VISTA ALEGRE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010700', '01', '07', '00', 'UTCUBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010701', '01', '07', '01', 'BAGUA GRANDE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010702', '01', '07', '02', 'CAJARURO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010703', '01', '07', '03', 'CUMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010704', '01', '07', '04', 'EL MILAGRO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010705', '01', '07', '05', 'JAMALCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010706', '01', '07', '06', 'LONYA GRANDE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('010707', '01', '07', '07', 'YAMON', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020000', '02', '00', '00', 'ANCASH', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020100', '02', '01', '00', 'HUARAZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020101', '02', '01', '01', 'HUARAZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020102', '02', '01', '02', 'COCHABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020103', '02', '01', '03', 'COLCABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020104', '02', '01', '04', 'HUANCHAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020105', '02', '01', '05', 'INDEPENDENCIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020106', '02', '01', '06', 'JANGAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020107', '02', '01', '07', 'LA LIBERTAD', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020108', '02', '01', '08', 'OLLEROS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020109', '02', '01', '09', 'PAMPAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020110', '02', '01', '10', 'PARIACOTO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020111', '02', '01', '11', 'PIRA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020112', '02', '01', '12', 'TARICA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020200', '02', '02', '00', 'AIJA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020201', '02', '02', '01', 'AIJA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020202', '02', '02', '02', 'CORIS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020203', '02', '02', '03', 'HUACLLAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020204', '02', '02', '04', 'LA MERCED', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020205', '02', '02', '05', 'SUCCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020300', '02', '03', '00', 'ANTONIO RAYMONDI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020301', '02', '03', '01', 'LLAMELLIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020302', '02', '03', '02', 'ACZO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020303', '02', '03', '03', 'CHACCHO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020304', '02', '03', '04', 'CHINGAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020305', '02', '03', '05', 'MIRGAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020306', '02', '03', '06', 'SAN JUAN DE RONTOY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020400', '02', '04', '00', 'ASUNCION', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020401', '02', '04', '01', 'CHACAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020402', '02', '04', '02', 'ACOCHACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020500', '02', '05', '00', 'BOLOGNESI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020501', '02', '05', '01', 'CHIQUIAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020502', '02', '05', '02', 'ABELARDO PARDO LEZAMETA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020503', '02', '05', '03', 'ANTONIO RAYMONDI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020504', '02', '05', '04', 'AQUIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020505', '02', '05', '05', 'CAJACAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020506', '02', '05', '06', 'CANIS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020507', '02', '05', '07', 'COLQUIOC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020508', '02', '05', '08', 'HUALLANCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020509', '02', '05', '09', 'HUASTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020510', '02', '05', '10', 'HUAYLLACAYAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020511', '02', '05', '11', 'LA PRIMAVERA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020512', '02', '05', '12', 'MANGAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020513', '02', '05', '13', 'PACLLON', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020514', '02', '05', '14', 'SAN MIGUEL DE CORPANQUI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020515', '02', '05', '15', 'TICLLOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020600', '02', '06', '00', 'CARHUAZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020601', '02', '06', '01', 'CARHUAZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020602', '02', '06', '02', 'ACOPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020603', '02', '06', '03', 'AMASHCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020604', '02', '06', '04', 'ANTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020605', '02', '06', '05', 'ATAQUERO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020606', '02', '06', '06', 'MARCARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020607', '02', '06', '07', 'PARIAHUANCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020608', '02', '06', '08', 'SAN MIGUEL DE ACO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020609', '02', '06', '09', 'SHILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020610', '02', '06', '10', 'TINCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020611', '02', '06', '11', 'YUNGAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020700', '02', '07', '00', 'CARLOS FERMIN FITZCARRALD', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020701', '02', '07', '01', 'SAN LUIS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020702', '02', '07', '02', 'SAN NICOLAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020703', '02', '07', '03', 'YAUYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020800', '02', '08', '00', 'CASMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020801', '02', '08', '01', 'CASMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020802', '02', '08', '02', 'BUENA VISTA ALTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020803', '02', '08', '03', 'COMANDANTE NOEL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020804', '02', '08', '04', 'YAUTAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020900', '02', '09', '00', 'CORONGO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020901', '02', '09', '01', 'CORONGO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020902', '02', '09', '02', 'ACO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020903', '02', '09', '03', 'BAMBAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020904', '02', '09', '04', 'CUSCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020905', '02', '09', '05', 'LA PAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020906', '02', '09', '06', 'YANAC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('020907', '02', '09', '07', 'YUPAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021000', '02', '10', '00', 'HUARI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021001', '02', '10', '01', 'HUARI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021002', '02', '10', '02', 'ANRA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021003', '02', '10', '03', 'CAJAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021004', '02', '10', '04', 'CHAVIN DE HUANTAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021005', '02', '10', '05', 'HUACACHI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021006', '02', '10', '06', 'HUACCHIS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021007', '02', '10', '07', 'HUACHIS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021008', '02', '10', '08', 'HUANTAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021009', '02', '10', '09', 'MASIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021010', '02', '10', '10', 'PAUCAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021011', '02', '10', '11', 'PONTO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021012', '02', '10', '12', 'RAHUAPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021013', '02', '10', '13', 'RAPAYAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021014', '02', '10', '14', 'SAN MARCOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021015', '02', '10', '15', 'SAN PEDRO DE CHANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021016', '02', '10', '16', 'UCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021100', '02', '11', '00', 'HUARMEY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021101', '02', '11', '01', 'HUARMEY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021102', '02', '11', '02', 'COCHAPETI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021103', '02', '11', '03', 'CULEBRAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021104', '02', '11', '04', 'HUAYAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021105', '02', '11', '05', 'MALVAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021200', '02', '12', '00', 'HUAYLAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021201', '02', '12', '01', 'CARAZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021202', '02', '12', '02', 'HUALLANCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021203', '02', '12', '03', 'HUATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021204', '02', '12', '04', 'HUAYLAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021205', '02', '12', '05', 'MATO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021206', '02', '12', '06', 'PAMPAROMAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021207', '02', '12', '07', 'PUEBLO LIBRE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021208', '02', '12', '08', 'SANTA CRUZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021209', '02', '12', '09', 'SANTO TORIBIO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021210', '02', '12', '10', 'YURACMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021300', '02', '13', '00', 'MARISCAL LUZURIAGA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021301', '02', '13', '01', 'PISCOBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021302', '02', '13', '02', 'CASCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021303', '02', '13', '03', 'ELEAZAR GUZMAN BARRON', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021304', '02', '13', '04', 'FIDEL OLIVAS ESCUDERO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021305', '02', '13', '05', 'LLAMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021306', '02', '13', '06', 'LLUMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021307', '02', '13', '07', 'LUCMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021308', '02', '13', '08', 'MUSGA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021400', '02', '14', '00', 'OCROS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021401', '02', '14', '01', 'OCROS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021402', '02', '14', '02', 'ACAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021403', '02', '14', '03', 'CAJAMARQUILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021404', '02', '14', '04', 'CARHUAPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021405', '02', '14', '05', 'COCHAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021406', '02', '14', '06', 'CONGAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021407', '02', '14', '07', 'LLIPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021408', '02', '14', '08', 'SAN CRISTOBAL DE RAJAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021409', '02', '14', '09', 'SAN PEDRO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021410', '02', '14', '10', 'SANTIAGO DE CHILCAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021500', '02', '15', '00', 'PALLASCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021501', '02', '15', '01', 'CABANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021502', '02', '15', '02', 'BOLOGNESI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021503', '02', '15', '03', 'CONCHUCOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021504', '02', '15', '04', 'HUACASCHUQUE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021505', '02', '15', '05', 'HUANDOVAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021506', '02', '15', '06', 'LACABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021507', '02', '15', '07', 'LLAPO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021508', '02', '15', '08', 'PALLASCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021509', '02', '15', '09', 'PAMPAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021510', '02', '15', '10', 'SANTA ROSA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021511', '02', '15', '11', 'TAUCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021600', '02', '16', '00', 'POMABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021601', '02', '16', '01', 'POMABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021602', '02', '16', '02', 'HUAYLLAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021603', '02', '16', '03', 'PAROBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021604', '02', '16', '04', 'QUINUABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021700', '02', '17', '00', 'RECUAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021701', '02', '17', '01', 'RECUAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021702', '02', '17', '02', 'CATAC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021703', '02', '17', '03', 'COTAPARACO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021704', '02', '17', '04', 'HUAYLLAPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021705', '02', '17', '05', 'LLACLLIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021706', '02', '17', '06', 'MARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021707', '02', '17', '07', 'PAMPAS CHICO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021708', '02', '17', '08', 'PARARIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021709', '02', '17', '09', 'TAPACOCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021710', '02', '17', '10', 'TICAPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021800', '02', '18', '00', 'SANTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021801', '02', '18', '01', 'CHIMBOTE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021802', '02', '18', '02', 'CACERES DEL PERU', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021803', '02', '18', '03', 'COISHCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021804', '02', '18', '04', 'MACATE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021805', '02', '18', '05', 'MORO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021806', '02', '18', '06', 'NEPEÑA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021807', '02', '18', '07', 'SAMANCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021808', '02', '18', '08', 'SANTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021809', '02', '18', '09', 'NUEVO CHIMBOTE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021900', '02', '19', '00', 'SIHUAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021901', '02', '19', '01', 'SIHUAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021902', '02', '19', '02', 'ACOBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021903', '02', '19', '03', 'ALFONSO UGARTE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021904', '02', '19', '04', 'CASHAPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021905', '02', '19', '05', 'CHINGALPO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021906', '02', '19', '06', 'HUAYLLABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021907', '02', '19', '07', 'QUICHES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021908', '02', '19', '08', 'RAGASH', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021909', '02', '19', '09', 'SAN JUAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('021910', '02', '19', '10', 'SICSIBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('022000', '02', '20', '00', 'YUNGAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('022001', '02', '20', '01', 'YUNGAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('022002', '02', '20', '02', 'CASCAPARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('022003', '02', '20', '03', 'MANCOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('022004', '02', '20', '04', 'MATACOTO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('022005', '02', '20', '05', 'QUILLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('022006', '02', '20', '06', 'RANRAHIRCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('022007', '02', '20', '07', 'SHUPLUY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('022008', '02', '20', '08', 'YANAMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030000', '03', '00', '00', 'APURIMAC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030100', '03', '01', '00', 'ABANCAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030101', '03', '01', '01', 'ABANCAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030102', '03', '01', '02', 'CHACOCHE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030103', '03', '01', '03', 'CIRCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030104', '03', '01', '04', 'CURAHUASI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030105', '03', '01', '05', 'HUANIPACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030106', '03', '01', '06', 'LAMBRAMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030107', '03', '01', '07', 'PICHIRHUA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030108', '03', '01', '08', 'SAN PEDRO DE CACHORA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030109', '03', '01', '09', 'TAMBURCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030200', '03', '02', '00', 'ANDAHUAYLAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030201', '03', '02', '01', 'ANDAHUAYLAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030202', '03', '02', '02', 'ANDARAPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030203', '03', '02', '03', 'CHIARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030204', '03', '02', '04', 'HUANCARAMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030205', '03', '02', '05', 'HUANCARAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030206', '03', '02', '06', 'HUAYANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030207', '03', '02', '07', 'KISHUARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030208', '03', '02', '08', 'PACOBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030209', '03', '02', '09', 'PACUCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030210', '03', '02', '10', 'PAMPACHIRI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030211', '03', '02', '11', 'POMACOCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030212', '03', '02', '12', 'SAN ANTONIO DE CACHI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030213', '03', '02', '13', 'SAN JERONIMO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030214', '03', '02', '14', 'SAN MIGUEL DE CHACCRAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030215', '03', '02', '15', 'SANTA MARIA DE CHICMO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030216', '03', '02', '16', 'TALAVERA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030217', '03', '02', '17', 'TUMAY HUARACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030218', '03', '02', '18', 'TURPO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030219', '03', '02', '19', 'KAQUIABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030300', '03', '03', '00', 'ANTABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030301', '03', '03', '01', 'ANTABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030302', '03', '03', '02', 'EL ORO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030303', '03', '03', '03', 'HUAQUIRCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030304', '03', '03', '04', 'JUAN ESPINOZA MEDRANO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030305', '03', '03', '05', 'OROPESA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030306', '03', '03', '06', 'PACHACONAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030307', '03', '03', '07', 'SABAINO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030400', '03', '04', '00', 'AYMARAES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030401', '03', '04', '01', 'CHALHUANCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030402', '03', '04', '02', 'CAPAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030403', '03', '04', '03', 'CARAYBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030404', '03', '04', '04', 'CHAPIMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030405', '03', '04', '05', 'COLCABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030406', '03', '04', '06', 'COTARUSE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030407', '03', '04', '07', 'HUAYLLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030408', '03', '04', '08', 'JUSTO APU SAHUARAURA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030409', '03', '04', '09', 'LUCRE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030410', '03', '04', '10', 'POCOHUANCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030411', '03', '04', '11', 'SAN JUAN DE CHACÑA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030412', '03', '04', '12', 'SAÑAYCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030413', '03', '04', '13', 'SORAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030414', '03', '04', '14', 'TAPAIRIHUA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030415', '03', '04', '15', 'TINTAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030416', '03', '04', '16', 'TORAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030417', '03', '04', '17', 'YANACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030500', '03', '05', '00', 'COTABAMBAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030501', '03', '05', '01', 'TAMBOBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030502', '03', '05', '02', 'COTABAMBAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030503', '03', '05', '03', 'COYLLURQUI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030504', '03', '05', '04', 'HAQUIRA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030505', '03', '05', '05', 'MARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030506', '03', '05', '06', 'CHALLHUAHUACHO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030600', '03', '06', '00', 'CHINCHEROS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030601', '03', '06', '01', 'CHINCHEROS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030602', '03', '06', '02', 'ANCO_HUALLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030603', '03', '06', '03', 'COCHARCAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030604', '03', '06', '04', 'HUACCANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030605', '03', '06', '05', 'OCOBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030606', '03', '06', '06', 'ONGOY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030607', '03', '06', '07', 'URANMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030608', '03', '06', '08', 'RANRACANCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030700', '03', '07', '00', 'GRAU', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030701', '03', '07', '01', 'CHUQUIBAMBILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030702', '03', '07', '02', 'CURPAHUASI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030703', '03', '07', '03', 'GAMARRA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030704', '03', '07', '04', 'HUAYLLATI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030705', '03', '07', '05', 'MAMARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030706', '03', '07', '06', 'MICAELA BASTIDAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030707', '03', '07', '07', 'PATAYPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030708', '03', '07', '08', 'PROGRESO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030709', '03', '07', '09', 'SAN ANTONIO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030710', '03', '07', '10', 'SANTA ROSA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030711', '03', '07', '11', 'TURPAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030712', '03', '07', '12', 'VILCABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030713', '03', '07', '13', 'VIRUNDO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('030714', '03', '07', '14', 'CURASCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040000', '04', '00', '00', 'AREQUIPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040100', '04', '01', '00', 'AREQUIPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040101', '04', '01', '01', 'AREQUIPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040102', '04', '01', '02', 'ALTO SELVA ALEGRE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040103', '04', '01', '03', 'CAYMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040104', '04', '01', '04', 'CERRO COLORADO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040105', '04', '01', '05', 'CHARACATO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040106', '04', '01', '06', 'CHIGUATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040107', '04', '01', '07', 'JACOBO HUNTER', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040108', '04', '01', '08', 'LA JOYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040109', '04', '01', '09', 'MARIANO MELGAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040110', '04', '01', '10', 'MIRAFLORES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040111', '04', '01', '11', 'MOLLEBAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040112', '04', '01', '12', 'PAUCARPATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040113', '04', '01', '13', 'POCSI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040114', '04', '01', '14', 'POLOBAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040115', '04', '01', '15', 'QUEQUEÑA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040116', '04', '01', '16', 'SABANDIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040117', '04', '01', '17', 'SACHACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040118', '04', '01', '18', 'SAN JUAN DE SIGUAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040119', '04', '01', '19', 'SAN JUAN DE TARUCANI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040120', '04', '01', '20', 'SANTA ISABEL DE SIGUAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040121', '04', '01', '21', 'SANTA RITA DE SIGUAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040122', '04', '01', '22', 'SOCABAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040123', '04', '01', '23', 'TIABAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040124', '04', '01', '24', 'UCHUMAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040125', '04', '01', '25', 'VITOR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040126', '04', '01', '26', 'YANAHUARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040127', '04', '01', '27', 'YARABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040128', '04', '01', '28', 'YURA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040129', '04', '01', '29', 'JOSE LUIS BUSTAMANTE Y RIVERO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040200', '04', '02', '00', 'CAMANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040201', '04', '02', '01', 'CAMANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040202', '04', '02', '02', 'JOSE MARIA QUIMPER', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040203', '04', '02', '03', 'MARIANO NICOLAS VALCARCEL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040204', '04', '02', '04', 'MARISCAL CACERES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040205', '04', '02', '05', 'NICOLAS DE PIEROLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040206', '04', '02', '06', 'OCOÑA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040207', '04', '02', '07', 'QUILCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040208', '04', '02', '08', 'SAMUEL PASTOR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040300', '04', '03', '00', 'CARAVELI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040301', '04', '03', '01', 'CARAVELI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040302', '04', '03', '02', 'ACARI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040303', '04', '03', '03', 'ATICO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040304', '04', '03', '04', 'ATIQUIPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040305', '04', '03', '05', 'BELLA UNION', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040306', '04', '03', '06', 'CAHUACHO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040307', '04', '03', '07', 'CHALA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040308', '04', '03', '08', 'CHAPARRA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040309', '04', '03', '09', 'HUANUHUANU', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040310', '04', '03', '10', 'JAQUI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040311', '04', '03', '11', 'LOMAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040312', '04', '03', '12', 'QUICACHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040313', '04', '03', '13', 'YAUCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040400', '04', '04', '00', 'CASTILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040401', '04', '04', '01', 'APLAO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040402', '04', '04', '02', 'ANDAGUA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040403', '04', '04', '03', 'AYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040404', '04', '04', '04', 'CHACHAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040405', '04', '04', '05', 'CHILCAYMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040406', '04', '04', '06', 'CHOCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040407', '04', '04', '07', 'HUANCARQUI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040408', '04', '04', '08', 'MACHAGUAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040409', '04', '04', '09', 'ORCOPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040410', '04', '04', '10', 'PAMPACOLCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040411', '04', '04', '11', 'TIPAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040412', '04', '04', '12', 'UÑON', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040413', '04', '04', '13', 'URACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040414', '04', '04', '14', 'VIRACO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040500', '04', '05', '00', 'CAYLLOMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040501', '04', '05', '01', 'CHIVAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040502', '04', '05', '02', 'ACHOMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040503', '04', '05', '03', 'CABANACONDE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040504', '04', '05', '04', 'CALLALLI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040505', '04', '05', '05', 'CAYLLOMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040506', '04', '05', '06', 'COPORAQUE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040507', '04', '05', '07', 'HUAMBO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040508', '04', '05', '08', 'HUANCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040509', '04', '05', '09', 'ICHUPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040510', '04', '05', '10', 'LARI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040511', '04', '05', '11', 'LLUTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040512', '04', '05', '12', 'MACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040513', '04', '05', '13', 'MADRIGAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040514', '04', '05', '14', 'SAN ANTONIO DE CHUCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040515', '04', '05', '15', 'SIBAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040516', '04', '05', '16', 'TAPAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040517', '04', '05', '17', 'TISCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040518', '04', '05', '18', 'TUTI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040519', '04', '05', '19', 'YANQUE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040520', '04', '05', '20', 'MAJES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040600', '04', '06', '00', 'CONDESUYOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040601', '04', '06', '01', 'CHUQUIBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040602', '04', '06', '02', 'ANDARAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040603', '04', '06', '03', 'CAYARANI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040604', '04', '06', '04', 'CHICHAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040605', '04', '06', '05', 'IRAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040606', '04', '06', '06', 'RIO GRANDE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040607', '04', '06', '07', 'SALAMANCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040608', '04', '06', '08', 'YANAQUIHUA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040700', '04', '07', '00', 'ISLAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040701', '04', '07', '01', 'MOLLENDO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040702', '04', '07', '02', 'COCACHACRA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040703', '04', '07', '03', 'DEAN VALDIVIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040704', '04', '07', '04', 'ISLAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040705', '04', '07', '05', 'MEJIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040706', '04', '07', '06', 'PUNTA DE BOMBON', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040800', '04', '08', '00', 'LA UNION', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040801', '04', '08', '01', 'COTAHUASI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040802', '04', '08', '02', 'ALCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040803', '04', '08', '03', 'CHARCANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040804', '04', '08', '04', 'HUAYNACOTAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040805', '04', '08', '05', 'PAMPAMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040806', '04', '08', '06', 'PUYCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040807', '04', '08', '07', 'QUECHUALLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040808', '04', '08', '08', 'SAYLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040809', '04', '08', '09', 'TAURIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040810', '04', '08', '10', 'TOMEPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('040811', '04', '08', '11', 'TORO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050000', '05', '00', '00', 'AYACUCHO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050100', '05', '01', '00', 'HUAMANGA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050101', '05', '01', '01', 'AYACUCHO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050102', '05', '01', '02', 'ACOCRO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050103', '05', '01', '03', 'ACOS VINCHOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050104', '05', '01', '04', 'CARMEN ALTO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050105', '05', '01', '05', 'CHIARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050106', '05', '01', '06', 'OCROS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050107', '05', '01', '07', 'PACAYCASA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050108', '05', '01', '08', 'QUINUA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050109', '05', '01', '09', 'SAN JOSE DE TICLLAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050110', '05', '01', '10', 'SAN JUAN BAUTISTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050111', '05', '01', '11', 'SANTIAGO DE PISCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050112', '05', '01', '12', 'SOCOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050113', '05', '01', '13', 'TAMBILLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050114', '05', '01', '14', 'VINCHOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050115', '05', '01', '15', 'JESUS NAZARENO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050200', '05', '02', '00', 'CANGALLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050201', '05', '02', '01', 'CANGALLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050202', '05', '02', '02', 'CHUSCHI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050203', '05', '02', '03', 'LOS MOROCHUCOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050204', '05', '02', '04', 'MARIA PARADO DE BELLIDO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050205', '05', '02', '05', 'PARAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050206', '05', '02', '06', 'TOTOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050300', '05', '03', '00', 'HUANCA SANCOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050301', '05', '03', '01', 'SANCOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050302', '05', '03', '02', 'CARAPO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050303', '05', '03', '03', 'SACSAMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050304', '05', '03', '04', 'SANTIAGO DE LUCANAMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050400', '05', '04', '00', 'HUANTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050401', '05', '04', '01', 'HUANTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050402', '05', '04', '02', 'AYAHUANCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050403', '05', '04', '03', 'HUAMANGUILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050404', '05', '04', '04', 'IGUAIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050405', '05', '04', '05', 'LURICOCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050406', '05', '04', '06', 'SANTILLANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050407', '05', '04', '07', 'SIVIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050408', '05', '04', '08', 'LLOCHEGUA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050500', '05', '05', '00', 'LA MAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050501', '05', '05', '01', 'SAN MIGUEL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050502', '05', '05', '02', 'ANCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050503', '05', '05', '03', 'AYNA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050504', '05', '05', '04', 'CHILCAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050505', '05', '05', '05', 'CHUNGUI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050506', '05', '05', '06', 'LUIS CARRANZA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050507', '05', '05', '07', 'SANTA ROSA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050508', '05', '05', '08', 'TAMBO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050509', '05', '05', '09', 'SAMUGARI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050600', '05', '06', '00', 'LUCANAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050601', '05', '06', '01', 'PUQUIO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050602', '05', '06', '02', 'AUCARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050603', '05', '06', '03', 'CABANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050604', '05', '06', '04', 'CARMEN SALCEDO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050605', '05', '06', '05', 'CHAVIÑA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050606', '05', '06', '06', 'CHIPAO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050607', '05', '06', '07', 'HUAC-HUAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050608', '05', '06', '08', 'LARAMATE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050609', '05', '06', '09', 'LEONCIO PRADO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050610', '05', '06', '10', 'LLAUTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050611', '05', '06', '11', 'LUCANAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050612', '05', '06', '12', 'OCAÑA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050613', '05', '06', '13', 'OTOCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050614', '05', '06', '14', 'SAISA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050615', '05', '06', '15', 'SAN CRISTOBAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050616', '05', '06', '16', 'SAN JUAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050617', '05', '06', '17', 'SAN PEDRO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050618', '05', '06', '18', 'SAN PEDRO DE PALCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050619', '05', '06', '19', 'SANCOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050620', '05', '06', '20', 'SANTA ANA DE HUAYCAHUACHO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050621', '05', '06', '21', 'SANTA LUCIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050700', '05', '07', '00', 'PARINACOCHAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050701', '05', '07', '01', 'CORACORA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050702', '05', '07', '02', 'CHUMPI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050703', '05', '07', '03', 'CORONEL CASTAÑEDA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050704', '05', '07', '04', 'PACAPAUSA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050705', '05', '07', '05', 'PULLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050706', '05', '07', '06', 'PUYUSCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050707', '05', '07', '07', 'SAN FRANCISCO DE RAVACAYCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050708', '05', '07', '08', 'UPAHUACHO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050800', '05', '08', '00', 'PAUCAR DEL SARA SARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050801', '05', '08', '01', 'PAUSA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050802', '05', '08', '02', 'COLTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050803', '05', '08', '03', 'CORCULLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050804', '05', '08', '04', 'LAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050805', '05', '08', '05', 'MARCABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050806', '05', '08', '06', 'OYOLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050807', '05', '08', '07', 'PARARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050808', '05', '08', '08', 'SAN JAVIER DE ALPABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050809', '05', '08', '09', 'SAN JOSE DE USHUA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050810', '05', '08', '10', 'SARA SARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050900', '05', '09', '00', 'SUCRE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050901', '05', '09', '01', 'QUEROBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050902', '05', '09', '02', 'BELEN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050903', '05', '09', '03', 'CHALCOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050904', '05', '09', '04', 'CHILCAYOC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050905', '05', '09', '05', 'HUACAÑA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050906', '05', '09', '06', 'MORCOLLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050907', '05', '09', '07', 'PAICO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050908', '05', '09', '08', 'SAN PEDRO DE LARCAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050909', '05', '09', '09', 'SAN SALVADOR DE QUIJE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050910', '05', '09', '10', 'SANTIAGO DE PAUCARAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('050911', '05', '09', '11', 'SORAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('051000', '05', '10', '00', 'VICTOR FAJARDO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('051001', '05', '10', '01', 'HUANCAPI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('051002', '05', '10', '02', 'ALCAMENCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('051003', '05', '10', '03', 'APONGO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('051004', '05', '10', '04', 'ASQUIPATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('051005', '05', '10', '05', 'CANARIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('051006', '05', '10', '06', 'CAYARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('051007', '05', '10', '07', 'COLCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('051008', '05', '10', '08', 'HUAMANQUIQUIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('051009', '05', '10', '09', 'HUANCARAYLLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('051010', '05', '10', '10', 'HUAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('051011', '05', '10', '11', 'SARHUA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('051012', '05', '10', '12', 'VILCANCHOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('051100', '05', '11', '00', 'VILCAS HUAMAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('051101', '05', '11', '01', 'VILCAS HUAMAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('051102', '05', '11', '02', 'ACCOMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('051103', '05', '11', '03', 'CARHUANCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('051104', '05', '11', '04', 'CONCEPCION', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('051105', '05', '11', '05', 'HUAMBALPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('051106', '05', '11', '06', 'INDEPENDENCIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('051107', '05', '11', '07', 'SAURAMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('051108', '05', '11', '08', 'VISCHONGO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060000', '06', '00', '00', 'CAJAMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060100', '06', '01', '00', 'CAJAMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060101', '06', '01', '01', 'CAJAMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060102', '06', '01', '02', 'ASUNCION', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060103', '06', '01', '03', 'CHETILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060104', '06', '01', '04', 'COSPAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060105', '06', '01', '05', 'ENCAÑADA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060106', '06', '01', '06', 'JESUS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060107', '06', '01', '07', 'LLACANORA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060108', '06', '01', '08', 'LOS BAÑOS DEL INCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060109', '06', '01', '09', 'MAGDALENA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060110', '06', '01', '10', 'MATARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060111', '06', '01', '11', 'NAMORA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060112', '06', '01', '12', 'SAN JUAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060200', '06', '02', '00', 'CAJABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060201', '06', '02', '01', 'CAJABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060202', '06', '02', '02', 'CACHACHI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060203', '06', '02', '03', 'CONDEBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060204', '06', '02', '04', 'SITACOCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060300', '06', '03', '00', 'CELENDIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060301', '06', '03', '01', 'CELENDIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060302', '06', '03', '02', 'CHUMUCH', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060303', '06', '03', '03', 'CORTEGANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060304', '06', '03', '04', 'HUASMIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060305', '06', '03', '05', 'JORGE CHAVEZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060306', '06', '03', '06', 'JOSE GALVEZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060307', '06', '03', '07', 'MIGUEL IGLESIAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060308', '06', '03', '08', 'OXAMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060309', '06', '03', '09', 'SOROCHUCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060310', '06', '03', '10', 'SUCRE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060311', '06', '03', '11', 'UTCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060312', '06', '03', '12', 'LA LIBERTAD DE PALLAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060400', '06', '04', '00', 'CHOTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060401', '06', '04', '01', 'CHOTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060402', '06', '04', '02', 'ANGUIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060403', '06', '04', '03', 'CHADIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060404', '06', '04', '04', 'CHIGUIRIP', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060405', '06', '04', '05', 'CHIMBAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060406', '06', '04', '06', 'CHOROPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060407', '06', '04', '07', 'COCHABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060408', '06', '04', '08', 'CONCHAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060409', '06', '04', '09', 'HUAMBOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060410', '06', '04', '10', 'LAJAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060411', '06', '04', '11', 'LLAMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060412', '06', '04', '12', 'MIRACOSTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060413', '06', '04', '13', 'PACCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060414', '06', '04', '14', 'PION', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060415', '06', '04', '15', 'QUEROCOTO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060416', '06', '04', '16', 'SAN JUAN DE LICUPIS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060417', '06', '04', '17', 'TACABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060418', '06', '04', '18', 'TOCMOCHE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060419', '06', '04', '19', 'CHALAMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060500', '06', '05', '00', 'CONTUMAZA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060501', '06', '05', '01', 'CONTUMAZA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060502', '06', '05', '02', 'CHILETE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060503', '06', '05', '03', 'CUPISNIQUE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060504', '06', '05', '04', 'GUZMANGO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060505', '06', '05', '05', 'SAN BENITO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060506', '06', '05', '06', 'SANTA CRUZ DE TOLED', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060507', '06', '05', '07', 'TANTARICA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060508', '06', '05', '08', 'YONAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060600', '06', '06', '00', 'CUTERVO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060601', '06', '06', '01', 'CUTERVO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060602', '06', '06', '02', 'CALLAYUC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060603', '06', '06', '03', 'CHOROS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060604', '06', '06', '04', 'CUJILLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060605', '06', '06', '05', 'LA RAMADA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060606', '06', '06', '06', 'PIMPINGOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060607', '06', '06', '07', 'QUEROCOTILLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060608', '06', '06', '08', 'SAN ANDRES DE CUTERVO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060609', '06', '06', '09', 'SAN JUAN DE CUTERVO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060610', '06', '06', '10', 'SAN LUIS DE LUCMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060611', '06', '06', '11', 'SANTA CRUZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060612', '06', '06', '12', 'SANTO DOMINGO DE LA CAPILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060613', '06', '06', '13', 'SANTO TOMAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060614', '06', '06', '14', 'SOCOTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060615', '06', '06', '15', 'TORIBIO CASANOVA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060700', '06', '07', '00', 'HUALGAYOC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060701', '06', '07', '01', 'BAMBAMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060702', '06', '07', '02', 'CHUGUR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060703', '06', '07', '03', 'HUALGAYOC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060800', '06', '08', '00', 'JAEN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060801', '06', '08', '01', 'JAEN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060802', '06', '08', '02', 'BELLAVISTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060803', '06', '08', '03', 'CHONTALI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060804', '06', '08', '04', 'COLASAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060805', '06', '08', '05', 'HUABAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060806', '06', '08', '06', 'LAS PIRIAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060807', '06', '08', '07', 'POMAHUACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060808', '06', '08', '08', 'PUCARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060809', '06', '08', '09', 'SALLIQUE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060810', '06', '08', '10', 'SAN FELIPE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060811', '06', '08', '11', 'SAN JOSE DEL ALTO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060812', '06', '08', '12', 'SANTA ROSA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060900', '06', '09', '00', 'SAN IGNACIO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060901', '06', '09', '01', 'SAN IGNACIO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060902', '06', '09', '02', 'CHIRINOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060903', '06', '09', '03', 'HUARANGO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060904', '06', '09', '04', 'LA COIPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060905', '06', '09', '05', 'NAMBALLE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060906', '06', '09', '06', 'SAN JOSE DE LOURDES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('060907', '06', '09', '07', 'TABACONAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061000', '06', '10', '00', 'SAN MARCOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061001', '06', '10', '01', 'PEDRO GALVEZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061002', '06', '10', '02', 'CHANCAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061003', '06', '10', '03', 'EDUARDO VILLANUEVA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061004', '06', '10', '04', 'GREGORIO PITA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061005', '06', '10', '05', 'ICHOCAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061006', '06', '10', '06', 'JOSE MANUEL QUIROZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061007', '06', '10', '07', 'JOSE SABOGAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061100', '06', '11', '00', 'SAN MIGUEL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061101', '06', '11', '01', 'SAN MIGUEL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061102', '06', '11', '02', 'BOLIVAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061103', '06', '11', '03', 'CALQUIS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061104', '06', '11', '04', 'CATILLUC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061105', '06', '11', '05', 'EL PRADO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061106', '06', '11', '06', 'LA FLORIDA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061107', '06', '11', '07', 'LLAPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061108', '06', '11', '08', 'NANCHOC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061109', '06', '11', '09', 'NIEPOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061110', '06', '11', '10', 'SAN GREGORIO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061111', '06', '11', '11', 'SAN SILVESTRE DE COCHAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061112', '06', '11', '12', 'TONGOD', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061113', '06', '11', '13', 'UNION AGUA BLANCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061200', '06', '12', '00', 'SAN PABLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061201', '06', '12', '01', 'SAN PABLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061202', '06', '12', '02', 'SAN BERNARDINO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061203', '06', '12', '03', 'SAN LUIS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061204', '06', '12', '04', 'TUMBADEN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061300', '06', '13', '00', 'SANTA CRUZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061301', '06', '13', '01', 'SANTA CRUZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061302', '06', '13', '02', 'ANDABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061303', '06', '13', '03', 'CATACHE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061304', '06', '13', '04', 'CHANCAYBAÑOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061305', '06', '13', '05', 'LA ESPERANZA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061306', '06', '13', '06', 'NINABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061307', '06', '13', '07', 'PULAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061308', '06', '13', '08', 'SAUCEPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061309', '06', '13', '09', 'SEXI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061310', '06', '13', '10', 'UTICYACU', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('061311', '06', '13', '11', 'YAUYUCAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('070000', '07', '00', '00', 'CALLAO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('070100', '07', '01', '00', 'CALLAO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('070101', '07', '01', '01', 'CALLAO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('070102', '07', '01', '02', 'BELLAVISTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('070103', '07', '01', '03', 'CARMEN DE LA LEGUA REYNOSO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('070104', '07', '01', '04', 'LA PERLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('070105', '07', '01', '05', 'LA PUNTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('070106', '07', '01', '06', 'VENTANILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080000', '08', '00', '00', 'CUSCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080100', '08', '01', '00', 'CUSCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080101', '08', '01', '01', 'CUSCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080102', '08', '01', '02', 'CCORCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080103', '08', '01', '03', 'POROY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080104', '08', '01', '04', 'SAN JERONIMO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080105', '08', '01', '05', 'SAN SEBASTIAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080106', '08', '01', '06', 'SANTIAGO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080107', '08', '01', '07', 'SAYLLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080108', '08', '01', '08', 'WANCHAQ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080200', '08', '02', '00', 'ACOMAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080201', '08', '02', '01', 'ACOMAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080202', '08', '02', '02', 'ACOPIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080203', '08', '02', '03', 'ACOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080204', '08', '02', '04', 'MOSOC LLACTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080205', '08', '02', '05', 'POMACANCHI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080206', '08', '02', '06', 'RONDOCAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080207', '08', '02', '07', 'SANGARARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080300', '08', '03', '00', 'ANTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080301', '08', '03', '01', 'ANTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080302', '08', '03', '02', 'ANCAHUASI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080303', '08', '03', '03', 'CACHIMAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080304', '08', '03', '04', 'CHINCHAYPUJIO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080305', '08', '03', '05', 'HUAROCONDO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080306', '08', '03', '06', 'LIMATAMBO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080307', '08', '03', '07', 'MOLLEPATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080308', '08', '03', '08', 'PUCYURA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080309', '08', '03', '09', 'ZURITE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080400', '08', '04', '00', 'CALCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080401', '08', '04', '01', 'CALCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080402', '08', '04', '02', 'COYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080403', '08', '04', '03', 'LAMAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080404', '08', '04', '04', 'LARES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080405', '08', '04', '05', 'PISAC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080406', '08', '04', '06', 'SAN SALVADOR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080407', '08', '04', '07', 'TARAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080408', '08', '04', '08', 'YANATILE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080500', '08', '05', '00', 'CANAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080501', '08', '05', '01', 'YANAOCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080502', '08', '05', '02', 'CHECCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080503', '08', '05', '03', 'KUNTURKANKI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080504', '08', '05', '04', 'LANGUI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080505', '08', '05', '05', 'LAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080506', '08', '05', '06', 'PAMPAMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080507', '08', '05', '07', 'QUEHUE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080508', '08', '05', '08', 'TUPAC AMARU', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080600', '08', '06', '00', 'CANCHIS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080601', '08', '06', '01', 'SICUANI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080602', '08', '06', '02', 'CHECACUPE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080603', '08', '06', '03', 'COMBAPATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080604', '08', '06', '04', 'MARANGANI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080605', '08', '06', '05', 'PITUMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080606', '08', '06', '06', 'SAN PABLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080607', '08', '06', '07', 'SAN PEDRO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080608', '08', '06', '08', 'TINTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080700', '08', '07', '00', 'CHUMBIVILCAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080701', '08', '07', '01', 'SANTO TOMAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080702', '08', '07', '02', 'CAPACMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080703', '08', '07', '03', 'CHAMACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080704', '08', '07', '04', 'COLQUEMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080705', '08', '07', '05', 'LIVITACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080706', '08', '07', '06', 'LLUSCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080707', '08', '07', '07', 'QUIÑOTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080708', '08', '07', '08', 'VELILLE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080800', '08', '08', '00', 'ESPINAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080801', '08', '08', '01', 'ESPINAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080802', '08', '08', '02', 'CONDOROMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080803', '08', '08', '03', 'COPORAQUE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080804', '08', '08', '04', 'OCORURO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080805', '08', '08', '05', 'PALLPATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080806', '08', '08', '06', 'PICHIGUA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080807', '08', '08', '07', 'SUYCKUTAMBO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080808', '08', '08', '08', 'ALTO PICHIGUA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080900', '08', '09', '00', 'LA CONVENCION', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080901', '08', '09', '01', 'SANTA ANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080902', '08', '09', '02', 'ECHARATE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080903', '08', '09', '03', 'HUAYOPATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080904', '08', '09', '04', 'MARANURA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080905', '08', '09', '05', 'OCOBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080906', '08', '09', '06', 'QUELLOUNO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080907', '08', '09', '07', 'KIMBIRI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080908', '08', '09', '08', 'SANTA TERESA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080909', '08', '09', '09', 'VILCABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('080910', '08', '09', '10', 'PICHARI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081000', '08', '10', '00', 'PARURO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081001', '08', '10', '01', 'PARURO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081002', '08', '10', '02', 'ACCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081003', '08', '10', '03', 'CCAPI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081004', '08', '10', '04', 'COLCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081005', '08', '10', '05', 'HUANOQUITE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081006', '08', '10', '06', 'OMACHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081007', '08', '10', '07', 'PACCARITAMBO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081008', '08', '10', '08', 'PILLPINTO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081009', '08', '10', '09', 'YAURISQUE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081100', '08', '11', '00', 'PAUCARTAMBO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081101', '08', '11', '01', 'PAUCARTAMBO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081102', '08', '11', '02', 'CAICAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081103', '08', '11', '03', 'CHALLABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081104', '08', '11', '04', 'COLQUEPATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081105', '08', '11', '05', 'HUANCARANI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081106', '08', '11', '06', 'KOSÑIPATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081200', '08', '12', '00', 'QUISPICANCHI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081201', '08', '12', '01', 'URCOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081202', '08', '12', '02', 'ANDAHUAYLILLAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081203', '08', '12', '03', 'CAMANTI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081204', '08', '12', '04', 'CCARHUAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081205', '08', '12', '05', 'CCATCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081206', '08', '12', '06', 'CUSIPATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081207', '08', '12', '07', 'HUARO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081208', '08', '12', '08', 'LUCRE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081209', '08', '12', '09', 'MARCAPATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081210', '08', '12', '10', 'OCONGATE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081211', '08', '12', '11', 'OROPESA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081212', '08', '12', '12', 'QUIQUIJANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081300', '08', '13', '00', 'URUBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081301', '08', '13', '01', 'URUBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081302', '08', '13', '02', 'CHINCHERO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081303', '08', '13', '03', 'HUAYLLABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081304', '08', '13', '04', 'MACHUPICCHU', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081305', '08', '13', '05', 'MARAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081306', '08', '13', '06', 'OLLANTAYTAMBO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('081307', '08', '13', '07', 'YUCAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090000', '09', '00', '00', 'HUANCAVELICA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090100', '09', '01', '00', 'HUANCAVELICA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090101', '09', '01', '01', 'HUANCAVELICA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090102', '09', '01', '02', 'ACOBAMBILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090103', '09', '01', '03', 'ACORIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090104', '09', '01', '04', 'CONAYCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090105', '09', '01', '05', 'CUENCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090106', '09', '01', '06', 'HUACHOCOLPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090107', '09', '01', '07', 'HUAYLLAHUARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090108', '09', '01', '08', 'IZCUCHACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090109', '09', '01', '09', 'LARIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090110', '09', '01', '10', 'MANTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090111', '09', '01', '11', 'MARISCAL CACERES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090112', '09', '01', '12', 'MOYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090113', '09', '01', '13', 'NUEVO OCCORO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090114', '09', '01', '14', 'PALCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090115', '09', '01', '15', 'PILCHACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090116', '09', '01', '16', 'VILCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090117', '09', '01', '17', 'YAULI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090118', '09', '01', '18', 'ASCENSION', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090119', '09', '01', '19', 'HUANDO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090200', '09', '02', '00', 'ACOBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090201', '09', '02', '01', 'ACOBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090202', '09', '02', '02', 'ANDABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090203', '09', '02', '03', 'ANTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090204', '09', '02', '04', 'CAJA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090205', '09', '02', '05', 'MARCAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090206', '09', '02', '06', 'PAUCARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090207', '09', '02', '07', 'POMACOCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090208', '09', '02', '08', 'ROSARIO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090300', '09', '03', '00', 'ANGARAES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090301', '09', '03', '01', 'LIRCAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090302', '09', '03', '02', 'ANCHONGA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090303', '09', '03', '03', 'CALLANMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090304', '09', '03', '04', 'CCOCHACCASA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090305', '09', '03', '05', 'CHINCHO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090306', '09', '03', '06', 'CONGALLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090307', '09', '03', '07', 'HUANCA-HUANCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090308', '09', '03', '08', 'HUAYLLAY GRANDE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090309', '09', '03', '09', 'JULCAMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090310', '09', '03', '10', 'SAN ANTONIO DE ANTAPARCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090311', '09', '03', '11', 'SANTO TOMAS DE PATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090312', '09', '03', '12', 'SECCLLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090400', '09', '04', '00', 'CASTROVIRREYNA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090401', '09', '04', '01', 'CASTROVIRREYNA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090402', '09', '04', '02', 'ARMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090403', '09', '04', '03', 'AURAHUA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090404', '09', '04', '04', 'CAPILLAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090405', '09', '04', '05', 'CHUPAMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090406', '09', '04', '06', 'COCAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090407', '09', '04', '07', 'HUACHOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090408', '09', '04', '08', 'HUAMATAMBO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090409', '09', '04', '09', 'MOLLEPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090410', '09', '04', '10', 'SAN JUAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090411', '09', '04', '11', 'SANTA ANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090412', '09', '04', '12', 'TANTARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090413', '09', '04', '13', 'TICRAPO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090500', '09', '05', '00', 'CHURCAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090501', '09', '05', '01', 'CHURCAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090502', '09', '05', '02', 'ANCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090503', '09', '05', '03', 'CHINCHIHUASI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090504', '09', '05', '04', 'EL CARMEN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090505', '09', '05', '05', 'LA MERCED', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090506', '09', '05', '06', 'LOCROJA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090507', '09', '05', '07', 'PAUCARBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090508', '09', '05', '08', 'SAN MIGUEL DE MAYOCC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090509', '09', '05', '09', 'SAN PEDRO DE CORIS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090510', '09', '05', '10', 'PACHAMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090511', '09', '05', '11', 'COSME', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090600', '09', '06', '00', 'HUAYTARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090601', '09', '06', '01', 'HUAYTARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090602', '09', '06', '02', 'AYAVI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090603', '09', '06', '03', 'CORDOVA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090604', '09', '06', '04', 'HUAYACUNDO ARMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090605', '09', '06', '05', 'LARAMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090606', '09', '06', '06', 'OCOYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090607', '09', '06', '07', 'PILPICHACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090608', '09', '06', '08', 'QUERCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090609', '09', '06', '09', 'QUITO-ARMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090610', '09', '06', '10', 'SAN ANTONIO DE CUSICANCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090611', '09', '06', '11', 'SAN FRANCISCO DE SANGAYAICO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090612', '09', '06', '12', 'SAN ISIDRO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090613', '09', '06', '13', 'SANTIAGO DE CHOCORVOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090614', '09', '06', '14', 'SANTIAGO DE QUIRAHUARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090615', '09', '06', '15', 'SANTO DOMINGO DE CAPILLAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090616', '09', '06', '16', 'TAMBO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090700', '09', '07', '00', 'TAYACAJA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090701', '09', '07', '01', 'PAMPAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090702', '09', '07', '02', 'ACOSTAMBO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090703', '09', '07', '03', 'ACRAQUIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090704', '09', '07', '04', 'AHUAYCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090705', '09', '07', '05', 'COLCABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090706', '09', '07', '06', 'DANIEL HERNANDEZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090707', '09', '07', '07', 'HUACHOCOLPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090709', '09', '07', '09', 'HUARIBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090710', '09', '07', '10', 'ÑAHUIMPUQUIO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090711', '09', '07', '11', 'PAZOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090713', '09', '07', '13', 'QUISHUAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090714', '09', '07', '14', 'SALCABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090715', '09', '07', '15', 'SALCAHUASI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090716', '09', '07', '16', 'SAN MARCOS DE ROCCHAC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090717', '09', '07', '17', 'SURCUBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('090718', '09', '07', '18', 'TINTAY PUNCU', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100000', '10', '00', '00', 'HUANUCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100100', '10', '01', '00', 'HUANUCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100101', '10', '01', '01', 'HUANUCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100102', '10', '01', '02', 'AMARILIS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100103', '10', '01', '03', 'CHINCHAO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100104', '10', '01', '04', 'CHURUBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100105', '10', '01', '05', 'MARGOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100106', '10', '01', '06', 'QUISQUI (KICHKI)', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100107', '10', '01', '07', 'SAN FRANCISCO DE CAYRAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100108', '10', '01', '08', 'SAN PEDRO DE CHAULAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100109', '10', '01', '09', 'SANTA MARIA DEL VALLE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100110', '10', '01', '10', 'YARUMAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100111', '10', '01', '11', 'PILLCO MARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100112', '10', '01', '12', 'YACUS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100200', '10', '02', '00', 'AMBO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100201', '10', '02', '01', 'AMBO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100202', '10', '02', '02', 'CAYNA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100203', '10', '02', '03', 'COLPAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100204', '10', '02', '04', 'CONCHAMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100205', '10', '02', '05', 'HUACAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100206', '10', '02', '06', 'SAN FRANCISCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100207', '10', '02', '07', 'SAN RAFAEL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100208', '10', '02', '08', 'TOMAY KICHWA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100300', '10', '03', '00', 'DOS DE MAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100301', '10', '03', '01', 'LA UNION', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100307', '10', '03', '07', 'CHUQUIS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100311', '10', '03', '11', 'MARIAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100313', '10', '03', '13', 'PACHAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100316', '10', '03', '16', 'QUIVILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100317', '10', '03', '17', 'RIPAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100321', '10', '03', '21', 'SHUNQUI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100322', '10', '03', '22', 'SILLAPATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100323', '10', '03', '23', 'YANAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100400', '10', '04', '00', 'HUACAYBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100401', '10', '04', '01', 'HUACAYBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100402', '10', '04', '02', 'CANCHABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100403', '10', '04', '03', 'COCHABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100404', '10', '04', '04', 'PINRA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100500', '10', '05', '00', 'HUAMALIES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100501', '10', '05', '01', 'LLATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100502', '10', '05', '02', 'ARANCAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100503', '10', '05', '03', 'CHAVIN DE PARIARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100504', '10', '05', '04', 'JACAS GRANDE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100505', '10', '05', '05', 'JIRCAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100506', '10', '05', '06', 'MIRAFLORES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100507', '10', '05', '07', 'MONZON', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100508', '10', '05', '08', 'PUNCHAO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100509', '10', '05', '09', 'PUÑOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100510', '10', '05', '10', 'SINGA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100511', '10', '05', '11', 'TANTAMAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100600', '10', '06', '00', 'LEONCIO PRADO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100601', '10', '06', '01', 'RUPA-RUPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100602', '10', '06', '02', 'DANIEL ALOMIA ROBLES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100603', '10', '06', '03', 'HERMILIO VALDIZAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100604', '10', '06', '04', 'JOSE CRESPO Y CASTILLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100605', '10', '06', '05', 'LUYANDO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100606', '10', '06', '06', 'MARIANO DAMASO BERAUN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100700', '10', '07', '00', 'MARAÑON', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100701', '10', '07', '01', 'HUACRACHUCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100702', '10', '07', '02', 'CHOLON', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100703', '10', '07', '03', 'SAN BUENAVENTURA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100800', '10', '08', '00', 'PACHITEA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100801', '10', '08', '01', 'PANAO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100802', '10', '08', '02', 'CHAGLLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100803', '10', '08', '03', 'MOLINO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100804', '10', '08', '04', 'UMARI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100900', '10', '09', '00', 'PUERTO INCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100901', '10', '09', '01', 'PUERTO INCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100902', '10', '09', '02', 'CODO DEL POZUZO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100903', '10', '09', '03', 'HONORIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100904', '10', '09', '04', 'TOURNAVISTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('100905', '10', '09', '05', 'YUYAPICHIS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('101000', '10', '10', '00', 'LAURICOCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('101001', '10', '10', '01', 'JESUS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('101002', '10', '10', '02', 'BAÑOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('101003', '10', '10', '03', 'JIVIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('101004', '10', '10', '04', 'QUEROPALCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('101005', '10', '10', '05', 'RONDOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('101006', '10', '10', '06', 'SAN FRANCISCO DE ASIS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('101007', '10', '10', '07', 'SAN MIGUEL DE CAURI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('101100', '10', '11', '00', 'YAROWILCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('101101', '10', '11', '01', 'CHAVINILLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('101102', '10', '11', '02', 'CAHUAC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('101103', '10', '11', '03', 'CHACABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('101104', '10', '11', '04', 'APARICIO POMARES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('101105', '10', '11', '05', 'JACAS CHICO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('101106', '10', '11', '06', 'OBAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('101107', '10', '11', '07', 'PAMPAMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('101108', '10', '11', '08', 'CHORAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110000', '11', '00', '00', 'ICA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110100', '11', '01', '00', 'ICA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110101', '11', '01', '01', 'ICA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110102', '11', '01', '02', 'LA TINGUIÑA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110103', '11', '01', '03', 'LOS AQUIJES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110104', '11', '01', '04', 'OCUCAJE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110105', '11', '01', '05', 'PACHACUTEC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110106', '11', '01', '06', 'PARCONA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110107', '11', '01', '07', 'PUEBLO NUEVO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110108', '11', '01', '08', 'SALAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110109', '11', '01', '09', 'SAN JOSE DE LOS MOLINOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110110', '11', '01', '10', 'SAN JUAN BAUTISTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110111', '11', '01', '11', 'SANTIAGO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110112', '11', '01', '12', 'SUBTANJALLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110113', '11', '01', '13', 'TATE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110114', '11', '01', '14', 'YAUCA DEL ROSARIO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110200', '11', '02', '00', 'CHINCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110201', '11', '02', '01', 'CHINCHA ALTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110202', '11', '02', '02', 'ALTO LARAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110203', '11', '02', '03', 'CHAVIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110204', '11', '02', '04', 'CHINCHA BAJA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110205', '11', '02', '05', 'EL CARMEN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110206', '11', '02', '06', 'GROCIO PRADO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110207', '11', '02', '07', 'PUEBLO NUEVO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110208', '11', '02', '08', 'SAN JUAN DE YANAC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110209', '11', '02', '09', 'SAN PEDRO DE HUACARPANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110210', '11', '02', '10', 'SUNAMPE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110211', '11', '02', '11', 'TAMBO DE MORA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110300', '11', '03', '00', 'NAZCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110301', '11', '03', '01', 'NAZCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110302', '11', '03', '02', 'CHANGUILLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110303', '11', '03', '03', 'EL INGENIO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110304', '11', '03', '04', 'MARCONA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110305', '11', '03', '05', 'VISTA ALEGRE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110400', '11', '04', '00', 'PALPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110401', '11', '04', '01', 'PALPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110402', '11', '04', '02', 'LLIPATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110403', '11', '04', '03', 'RIO GRANDE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110404', '11', '04', '04', 'SANTA CRUZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110405', '11', '04', '05', 'TIBILLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110500', '11', '05', '00', 'PISCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110501', '11', '05', '01', 'PISCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110502', '11', '05', '02', 'HUANCANO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110503', '11', '05', '03', 'HUMAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110504', '11', '05', '04', 'INDEPENDENCIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110505', '11', '05', '05', 'PARACAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110506', '11', '05', '06', 'SAN ANDRES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110507', '11', '05', '07', 'SAN CLEMENTE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('110508', '11', '05', '08', 'TUPAC AMARU INCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120000', '12', '00', '00', 'JUNIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120100', '12', '01', '00', 'HUANCAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120101', '12', '01', '01', 'HUANCAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120104', '12', '01', '04', 'CARHUACALLANGA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120105', '12', '01', '05', 'CHACAPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120106', '12', '01', '06', 'CHICCHE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120107', '12', '01', '07', 'CHILCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120108', '12', '01', '08', 'CHONGOS ALTO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120111', '12', '01', '11', 'CHUPURO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120112', '12', '01', '12', 'COLCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120113', '12', '01', '13', 'CULLHUAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120114', '12', '01', '14', 'EL TAMBO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120116', '12', '01', '16', 'HUACRAPUQUIO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120117', '12', '01', '17', 'HUALHUAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120119', '12', '01', '19', 'HUANCAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120120', '12', '01', '20', 'HUASICANCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120121', '12', '01', '21', 'HUAYUCACHI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120122', '12', '01', '22', 'INGENIO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120124', '12', '01', '24', 'PARIAHUANCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120125', '12', '01', '25', 'PILCOMAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120126', '12', '01', '26', 'PUCARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120127', '12', '01', '27', 'QUICHUAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120128', '12', '01', '28', 'QUILCAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120129', '12', '01', '29', 'SAN AGUSTIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120130', '12', '01', '30', 'SAN JERONIMO DE TUNAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120132', '12', '01', '32', 'SAÑO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120133', '12', '01', '33', 'SAPALLANGA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120134', '12', '01', '34', 'SICAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120135', '12', '01', '35', 'SANTO DOMINGO DE ACOBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120136', '12', '01', '36', 'VIQUES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120200', '12', '02', '00', 'CONCEPCION', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120201', '12', '02', '01', 'CONCEPCION', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120202', '12', '02', '02', 'ACO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120203', '12', '02', '03', 'ANDAMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120204', '12', '02', '04', 'CHAMBARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120205', '12', '02', '05', 'COCHAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120206', '12', '02', '06', 'COMAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120207', '12', '02', '07', 'HEROINAS TOLEDO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120208', '12', '02', '08', 'MANZANARES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120209', '12', '02', '09', 'MARISCAL CASTILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120210', '12', '02', '10', 'MATAHUASI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120211', '12', '02', '11', 'MITO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120212', '12', '02', '12', 'NUEVE DE JULIO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120213', '12', '02', '13', 'ORCOTUNA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120214', '12', '02', '14', 'SAN JOSE DE QUERO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120215', '12', '02', '15', 'SANTA ROSA DE OCOPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120300', '12', '03', '00', 'CHANCHAMAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120301', '12', '03', '01', 'CHANCHAMAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120302', '12', '03', '02', 'PERENE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120303', '12', '03', '03', 'PICHANAQUI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120304', '12', '03', '04', 'SAN LUIS DE SHUARO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120305', '12', '03', '05', 'SAN RAMON', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120306', '12', '03', '06', 'VITOC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120400', '12', '04', '00', 'JAUJA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120401', '12', '04', '01', 'JAUJA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120402', '12', '04', '02', 'ACOLLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120403', '12', '04', '03', 'APATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120404', '12', '04', '04', 'ATAURA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120405', '12', '04', '05', 'CANCHAYLLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120406', '12', '04', '06', 'CURICACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120407', '12', '04', '07', 'EL MANTARO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120408', '12', '04', '08', 'HUAMALI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120409', '12', '04', '09', 'HUARIPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120410', '12', '04', '10', 'HUERTAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120411', '12', '04', '11', 'JANJAILLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120412', '12', '04', '12', 'JULCAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120413', '12', '04', '13', 'LEONOR ORDOÑEZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120414', '12', '04', '14', 'LLOCLLAPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120415', '12', '04', '15', 'MARCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120416', '12', '04', '16', 'MASMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120417', '12', '04', '17', 'MASMA CHICCHE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120418', '12', '04', '18', 'MOLINOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120419', '12', '04', '19', 'MONOBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120420', '12', '04', '20', 'MUQUI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120421', '12', '04', '21', 'MUQUIYAUYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120422', '12', '04', '22', 'PACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120423', '12', '04', '23', 'PACCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120424', '12', '04', '24', 'PANCAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120425', '12', '04', '25', 'PARCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120426', '12', '04', '26', 'POMACANCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120427', '12', '04', '27', 'RICRAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120428', '12', '04', '28', 'SAN LORENZO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120429', '12', '04', '29', 'SAN PEDRO DE CHUNAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120430', '12', '04', '30', 'SAUSA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120431', '12', '04', '31', 'SINCOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120432', '12', '04', '32', 'TUNAN MARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120433', '12', '04', '33', 'YAULI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120434', '12', '04', '34', 'YAUYOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120500', '12', '05', '00', 'JUNIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120501', '12', '05', '01', 'JUNIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120502', '12', '05', '02', 'CARHUAMAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120503', '12', '05', '03', 'ONDORES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120504', '12', '05', '04', 'ULCUMAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120600', '12', '06', '00', 'SATIPO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120601', '12', '06', '01', 'SATIPO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120602', '12', '06', '02', 'COVIRIALI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120603', '12', '06', '03', 'LLAYLLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120605', '12', '06', '05', 'PAMPA HERMOSA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120607', '12', '06', '07', 'RIO NEGRO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120608', '12', '06', '08', 'RIO TAMBO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120699', '12', '06', '99', 'MAZAMARI - PANGOA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120700', '12', '07', '00', 'TARMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120701', '12', '07', '01', 'TARMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120702', '12', '07', '02', 'ACOBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120703', '12', '07', '03', 'HUARICOLCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120704', '12', '07', '04', 'HUASAHUASI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120705', '12', '07', '05', 'LA UNION', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120706', '12', '07', '06', 'PALCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120707', '12', '07', '07', 'PALCAMAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120708', '12', '07', '08', 'SAN PEDRO DE CAJAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120709', '12', '07', '09', 'TAPO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120800', '12', '08', '00', 'YAULI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120801', '12', '08', '01', 'LA OROYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120802', '12', '08', '02', 'CHACAPALPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120803', '12', '08', '03', 'HUAY-HUAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120804', '12', '08', '04', 'MARCAPOMACOCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120805', '12', '08', '05', 'MOROCOCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120806', '12', '08', '06', 'PACCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120807', '12', '08', '07', 'SANTA BARBARA DE CARHUACAYAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120808', '12', '08', '08', 'SANTA ROSA DE SACCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120809', '12', '08', '09', 'SUITUCANCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120810', '12', '08', '10', 'YAULI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120900', '12', '09', '00', 'CHUPACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120901', '12', '09', '01', 'CHUPACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120902', '12', '09', '02', 'AHUAC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120903', '12', '09', '03', 'CHONGOS BAJO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120904', '12', '09', '04', 'HUACHAC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120905', '12', '09', '05', 'HUAMANCACA CHICO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120906', '12', '09', '06', 'SAN JUAN DE ISCOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120907', '12', '09', '07', 'SAN JUAN DE JARPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120908', '12', '09', '08', 'TRES DE DICIEMBRE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('120909', '12', '09', '09', 'YANACANCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130000', '13', '00', '00', 'LA LIBERTAD', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130100', '13', '01', '00', 'TRUJILLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130101', '13', '01', '01', 'TRUJILLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130102', '13', '01', '02', 'EL PORVENIR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130103', '13', '01', '03', 'FLORENCIA DE MORA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130104', '13', '01', '04', 'HUANCHACO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130105', '13', '01', '05', 'LA ESPERANZA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130106', '13', '01', '06', 'LAREDO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130107', '13', '01', '07', 'MOCHE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130108', '13', '01', '08', 'POROTO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130109', '13', '01', '09', 'SALAVERRY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130110', '13', '01', '10', 'SIMBAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130111', '13', '01', '11', 'VICTOR LARCO HERRERA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130200', '13', '02', '00', 'ASCOPE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130201', '13', '02', '01', 'ASCOPE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130202', '13', '02', '02', 'CHICAMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130203', '13', '02', '03', 'CHOCOPE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130204', '13', '02', '04', 'MAGDALENA DE CAO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130205', '13', '02', '05', 'PAIJAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130206', '13', '02', '06', 'RAZURI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130207', '13', '02', '07', 'SANTIAGO DE CAO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130208', '13', '02', '08', 'CASA GRANDE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130300', '13', '03', '00', 'BOLIVAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130301', '13', '03', '01', 'BOLIVAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130302', '13', '03', '02', 'BAMBAMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130303', '13', '03', '03', 'CONDORMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130304', '13', '03', '04', 'LONGOTEA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130305', '13', '03', '05', 'UCHUMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130306', '13', '03', '06', 'UCUNCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130400', '13', '04', '00', 'CHEPEN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130401', '13', '04', '01', 'CHEPEN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130402', '13', '04', '02', 'PACANGA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130403', '13', '04', '03', 'PUEBLO NUEVO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130500', '13', '05', '00', 'JULCAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130501', '13', '05', '01', 'JULCAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130502', '13', '05', '02', 'CALAMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130503', '13', '05', '03', 'CARABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130504', '13', '05', '04', 'HUASO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130600', '13', '06', '00', 'OTUZCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130601', '13', '06', '01', 'OTUZCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130602', '13', '06', '02', 'AGALLPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130604', '13', '06', '04', 'CHARAT', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130605', '13', '06', '05', 'HUARANCHAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130606', '13', '06', '06', 'LA CUESTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130608', '13', '06', '08', 'MACHE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130610', '13', '06', '10', 'PARANDAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130611', '13', '06', '11', 'SALPO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130613', '13', '06', '13', 'SINSICAP', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130614', '13', '06', '14', 'USQUIL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130700', '13', '07', '00', 'PACASMAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130701', '13', '07', '01', 'SAN PEDRO DE LLOC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130702', '13', '07', '02', 'GUADALUPE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130703', '13', '07', '03', 'JEQUETEPEQUE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130704', '13', '07', '04', 'PACASMAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130705', '13', '07', '05', 'SAN JOSE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130800', '13', '08', '00', 'PATAZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130801', '13', '08', '01', 'TAYABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130802', '13', '08', '02', 'BULDIBUYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130803', '13', '08', '03', 'CHILLIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130804', '13', '08', '04', 'HUANCASPATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130805', '13', '08', '05', 'HUAYLILLAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130806', '13', '08', '06', 'HUAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130807', '13', '08', '07', 'ONGON', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130808', '13', '08', '08', 'PARCOY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130809', '13', '08', '09', 'PATAZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130810', '13', '08', '10', 'PIAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130811', '13', '08', '11', 'SANTIAGO DE CHALLAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130812', '13', '08', '12', 'TAURIJA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130813', '13', '08', '13', 'URPAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130900', '13', '09', '00', 'SANCHEZ CARRION', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130901', '13', '09', '01', 'HUAMACHUCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130902', '13', '09', '02', 'CHUGAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130903', '13', '09', '03', 'COCHORCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130904', '13', '09', '04', 'CURGOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130905', '13', '09', '05', 'MARCABAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130906', '13', '09', '06', 'SANAGORAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130907', '13', '09', '07', 'SARIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('130908', '13', '09', '08', 'SARTIMBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('131000', '13', '10', '00', 'SANTIAGO DE CHUCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('131001', '13', '10', '01', 'SANTIAGO DE CHUCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('131002', '13', '10', '02', 'ANGASMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('131003', '13', '10', '03', 'CACHICADAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('131004', '13', '10', '04', 'MOLLEBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('131005', '13', '10', '05', 'MOLLEPATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('131006', '13', '10', '06', 'QUIRUVILCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('131007', '13', '10', '07', 'SANTA CRUZ DE CHUCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('131008', '13', '10', '08', 'SITABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('131100', '13', '11', '00', 'GRAN CHIMU', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('131101', '13', '11', '01', 'CASCAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('131102', '13', '11', '02', 'LUCMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('131103', '13', '11', '03', 'MARMOT', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('131104', '13', '11', '04', 'SAYAPULLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('131200', '13', '12', '00', 'VIRU', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('131201', '13', '12', '01', 'VIRU', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('131202', '13', '12', '02', 'CHAO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('131203', '13', '12', '03', 'GUADALUPITO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140000', '14', '00', '00', 'LAMBAYEQUE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140100', '14', '01', '00', 'CHICLAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140101', '14', '01', '01', 'CHICLAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140102', '14', '01', '02', 'CHONGOYAPE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140103', '14', '01', '03', 'ETEN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140104', '14', '01', '04', 'ETEN PUERTO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140105', '14', '01', '05', 'JOSE LEONARDO ORTIZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140106', '14', '01', '06', 'LA VICTORIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140107', '14', '01', '07', 'LAGUNAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140108', '14', '01', '08', 'MONSEFU', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140109', '14', '01', '09', 'NUEVA ARICA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140110', '14', '01', '10', 'OYOTUN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140111', '14', '01', '11', 'PICSI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140112', '14', '01', '12', 'PIMENTEL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140113', '14', '01', '13', 'REQUE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140114', '14', '01', '14', 'SANTA ROSA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140115', '14', '01', '15', 'SAÑA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140116', '14', '01', '16', 'CAYALTI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140117', '14', '01', '17', 'PATAPO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140118', '14', '01', '18', 'POMALCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140119', '14', '01', '19', 'PUCALA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140120', '14', '01', '20', 'TUMAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140200', '14', '02', '00', 'FERREÑAFE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140201', '14', '02', '01', 'FERREÑAFE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140202', '14', '02', '02', 'CAÑARIS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140203', '14', '02', '03', 'INCAHUASI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140204', '14', '02', '04', 'MANUEL ANTONIO MESONES MURO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140205', '14', '02', '05', 'PITIPO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140206', '14', '02', '06', 'PUEBLO NUEVO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140300', '14', '03', '00', 'LAMBAYEQUE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140301', '14', '03', '01', 'LAMBAYEQUE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140302', '14', '03', '02', 'CHOCHOPE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140303', '14', '03', '03', 'ILLIMO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140304', '14', '03', '04', 'JAYANCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140305', '14', '03', '05', 'MOCHUMI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140306', '14', '03', '06', 'MORROPE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140307', '14', '03', '07', 'MOTUPE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140308', '14', '03', '08', 'OLMOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140309', '14', '03', '09', 'PACORA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140310', '14', '03', '10', 'SALAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140311', '14', '03', '11', 'SAN JOSE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('140312', '14', '03', '12', 'TUCUME', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150000', '15', '00', '00', 'LIMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150100', '15', '01', '00', 'LIMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150101', '15', '01', '01', 'LIMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150102', '15', '01', '02', 'ANCON', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150103', '15', '01', '03', 'ATE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150104', '15', '01', '04', 'BARRANCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150105', '15', '01', '05', 'BREÑA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150106', '15', '01', '06', 'CARABAYLLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150107', '15', '01', '07', 'CHACLACAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150108', '15', '01', '08', 'CHORRILLOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150109', '15', '01', '09', 'CIENEGUILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150110', '15', '01', '10', 'COMAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150111', '15', '01', '11', 'EL AGUSTINO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150112', '15', '01', '12', 'INDEPENDENCIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150113', '15', '01', '13', 'JESUS MARIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150114', '15', '01', '14', 'LA MOLINA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150115', '15', '01', '15', 'LA VICTORIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150116', '15', '01', '16', 'LINCE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150117', '15', '01', '17', 'LOS OLIVOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150118', '15', '01', '18', 'LURIGANCHO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150119', '15', '01', '19', 'LURIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150120', '15', '01', '20', 'MAGDALENA DEL MAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150121', '15', '01', '21', 'PUEBLO LIBRE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150122', '15', '01', '22', 'MIRAFLORES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150123', '15', '01', '23', 'PACHACAMAC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150124', '15', '01', '24', 'PUCUSANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150125', '15', '01', '25', 'PUENTE PIEDRA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150126', '15', '01', '26', 'PUNTA HERMOSA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150127', '15', '01', '27', 'PUNTA NEGRA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150128', '15', '01', '28', 'RIMAC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150129', '15', '01', '29', 'SAN BARTOLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150130', '15', '01', '30', 'SAN BORJA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150131', '15', '01', '31', 'SAN ISIDRO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150132', '15', '01', '32', 'SAN JUAN DE LURIGANCHO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150133', '15', '01', '33', 'SAN JUAN DE MIRAFLORES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150134', '15', '01', '34', 'SAN LUIS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150135', '15', '01', '35', 'SAN MARTIN DE PORRES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150136', '15', '01', '36', 'SAN MIGUEL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150137', '15', '01', '37', 'SANTA ANITA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150138', '15', '01', '38', 'SANTA MARIA DEL MAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150139', '15', '01', '39', 'SANTA ROSA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150140', '15', '01', '40', 'SANTIAGO DE SURCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150141', '15', '01', '41', 'SURQUILLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150142', '15', '01', '42', 'VILLA EL SALVADOR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150143', '15', '01', '43', 'VILLA MARIA DEL TRIUNFO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150200', '15', '02', '00', 'BARRANCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150201', '15', '02', '01', 'BARRANCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150202', '15', '02', '02', 'PARAMONGA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150203', '15', '02', '03', 'PATIVILCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150204', '15', '02', '04', 'SUPE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150205', '15', '02', '05', 'SUPE PUERTO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150300', '15', '03', '00', 'CAJATAMBO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150301', '15', '03', '01', 'CAJATAMBO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150302', '15', '03', '02', 'COPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150303', '15', '03', '03', 'GORGOR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150304', '15', '03', '04', 'HUANCAPON', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150305', '15', '03', '05', 'MANAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150400', '15', '04', '00', 'CANTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150401', '15', '04', '01', 'CANTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150402', '15', '04', '02', 'ARAHUAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150403', '15', '04', '03', 'HUAMANTANGA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150404', '15', '04', '04', 'HUAROS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150405', '15', '04', '05', 'LACHAQUI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150406', '15', '04', '06', 'SAN BUENAVENTURA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150407', '15', '04', '07', 'SANTA ROSA DE QUIVES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150500', '15', '05', '00', 'CAÑETE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150501', '15', '05', '01', 'SAN VICENTE DE CAÑETE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150502', '15', '05', '02', 'ASIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150503', '15', '05', '03', 'CALANGO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150504', '15', '05', '04', 'CERRO AZUL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150505', '15', '05', '05', 'CHILCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150506', '15', '05', '06', 'COAYLLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150507', '15', '05', '07', 'IMPERIAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150508', '15', '05', '08', 'LUNAHUANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150509', '15', '05', '09', 'MALA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150510', '15', '05', '10', 'NUEVO IMPERIAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150511', '15', '05', '11', 'PACARAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150512', '15', '05', '12', 'QUILMANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150513', '15', '05', '13', 'SAN ANTONIO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150514', '15', '05', '14', 'SAN LUIS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150515', '15', '05', '15', 'SANTA CRUZ DE FLORES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150516', '15', '05', '16', 'ZUÑIGA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150600', '15', '06', '00', 'HUARAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150601', '15', '06', '01', 'HUARAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150602', '15', '06', '02', 'ATAVILLOS ALTO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150603', '15', '06', '03', 'ATAVILLOS BAJO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150604', '15', '06', '04', 'AUCALLAMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150605', '15', '06', '05', 'CHANCAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150606', '15', '06', '06', 'IHUARI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150607', '15', '06', '07', 'LAMPIAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150608', '15', '06', '08', 'PACARAOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150609', '15', '06', '09', 'SAN MIGUEL DE ACOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150610', '15', '06', '10', 'SANTA CRUZ DE ANDAMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150611', '15', '06', '11', 'SUMBILCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150612', '15', '06', '12', 'VEINTISIETE DE NOVIEMBRE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150700', '15', '07', '00', 'HUAROCHIRI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150701', '15', '07', '01', 'MATUCANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150702', '15', '07', '02', 'ANTIOQUIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150703', '15', '07', '03', 'CALLAHUANCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150704', '15', '07', '04', 'CARAMPOMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150705', '15', '07', '05', 'CHICLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150706', '15', '07', '06', 'CUENCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150707', '15', '07', '07', 'HUACHUPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150708', '15', '07', '08', 'HUANZA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150709', '15', '07', '09', 'HUAROCHIRI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150710', '15', '07', '10', 'LAHUAYTAMBO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150711', '15', '07', '11', 'LANGA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150712', '15', '07', '12', 'LARAOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150713', '15', '07', '13', 'MARIATANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150714', '15', '07', '14', 'RICARDO PALMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150715', '15', '07', '15', 'SAN ANDRES DE TUPICOCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150716', '15', '07', '16', 'SAN ANTONIO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150717', '15', '07', '17', 'SAN BARTOLOME', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150718', '15', '07', '18', 'SAN DAMIAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150719', '15', '07', '19', 'SAN JUAN DE IRIS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150720', '15', '07', '20', 'SAN JUAN DE TANTARANCHE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150721', '15', '07', '21', 'SAN LORENZO DE QUINTI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150722', '15', '07', '22', 'SAN MATEO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150723', '15', '07', '23', 'SAN MATEO DE OTAO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150724', '15', '07', '24', 'SAN PEDRO DE CASTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150725', '15', '07', '25', 'SAN PEDRO DE HUANCAYRE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150726', '15', '07', '26', 'SANGALLAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150727', '15', '07', '27', 'SANTA CRUZ DE COCACHACRA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150728', '15', '07', '28', 'SANTA EULALIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150729', '15', '07', '29', 'SANTIAGO DE ANCHUCAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150730', '15', '07', '30', 'SANTIAGO DE TUNA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150731', '15', '07', '31', 'SANTO DOMINGO DE LOS OLLEROS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150732', '15', '07', '32', 'SURCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150800', '15', '08', '00', 'HUAURA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150801', '15', '08', '01', 'HUACHO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150802', '15', '08', '02', 'AMBAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150803', '15', '08', '03', 'CALETA DE CARQUIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150804', '15', '08', '04', 'CHECRAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150805', '15', '08', '05', 'HUALMAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150806', '15', '08', '06', 'HUAURA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150807', '15', '08', '07', 'LEONCIO PRADO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150808', '15', '08', '08', 'PACCHO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150809', '15', '08', '09', 'SANTA LEONOR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150810', '15', '08', '10', 'SANTA MARIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150811', '15', '08', '11', 'SAYAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150812', '15', '08', '12', 'VEGUETA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150900', '15', '09', '00', 'OYON', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150901', '15', '09', '01', 'OYON', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150902', '15', '09', '02', 'ANDAJES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150903', '15', '09', '03', 'CAUJUL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150904', '15', '09', '04', 'COCHAMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150905', '15', '09', '05', 'NAVAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('150906', '15', '09', '06', 'PACHANGARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151000', '15', '10', '00', 'YAUYOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151001', '15', '10', '01', 'YAUYOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151002', '15', '10', '02', 'ALIS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151003', '15', '10', '03', 'ALLAUCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151004', '15', '10', '04', 'AYAVIRI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151005', '15', '10', '05', 'AZANGARO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151006', '15', '10', '06', 'CACRA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151007', '15', '10', '07', 'CARANIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151008', '15', '10', '08', 'CATAHUASI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151009', '15', '10', '09', 'CHOCOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151010', '15', '10', '10', 'COCHAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151011', '15', '10', '11', 'COLONIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151012', '15', '10', '12', 'HONGOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151013', '15', '10', '13', 'HUAMPARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151014', '15', '10', '14', 'HUANCAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151015', '15', '10', '15', 'HUANGASCAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151016', '15', '10', '16', 'HUANTAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151017', '15', '10', '17', 'HUAÑEC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151018', '15', '10', '18', 'LARAOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151019', '15', '10', '19', 'LINCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151020', '15', '10', '20', 'MADEAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151021', '15', '10', '21', 'MIRAFLORES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151022', '15', '10', '22', 'OMAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151023', '15', '10', '23', 'PUTINZA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151024', '15', '10', '24', 'QUINCHES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151025', '15', '10', '25', 'QUINOCAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151026', '15', '10', '26', 'SAN JOAQUIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151027', '15', '10', '27', 'SAN PEDRO DE PILAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151028', '15', '10', '28', 'TANTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151029', '15', '10', '29', 'TAURIPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151030', '15', '10', '30', 'TOMAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151031', '15', '10', '31', 'TUPE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151032', '15', '10', '32', 'VIÑAC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('151033', '15', '10', '33', 'VITIS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160000', '16', '00', '00', 'LORETO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160100', '16', '01', '00', 'MAYNAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160101', '16', '01', '01', 'IQUITOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160102', '16', '01', '02', 'ALTO NANAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160103', '16', '01', '03', 'FERNANDO LORES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160104', '16', '01', '04', 'INDIANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160105', '16', '01', '05', 'LAS AMAZONAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160106', '16', '01', '06', 'MAZAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160107', '16', '01', '07', 'NAPO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160108', '16', '01', '08', 'PUNCHANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160109', '16', '01', '09', 'PUTUMAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160110', '16', '01', '10', 'TORRES CAUSANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160112', '16', '01', '12', 'BELEN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160113', '16', '01', '13', 'SAN JUAN BAUTISTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160114', '16', '01', '14', 'TENIENTE MANUEL CLAVERO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160200', '16', '02', '00', 'ALTO AMAZONAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160201', '16', '02', '01', 'YURIMAGUAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160202', '16', '02', '02', 'BALSAPUERTO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160205', '16', '02', '05', 'JEBEROS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160206', '16', '02', '06', 'LAGUNAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160210', '16', '02', '10', 'SANTA CRUZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160211', '16', '02', '11', 'TENIENTE CESAR LOPEZ ROJAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160300', '16', '03', '00', 'LORETO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160301', '16', '03', '01', 'NAUTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160302', '16', '03', '02', 'PARINARI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160303', '16', '03', '03', 'TIGRE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160304', '16', '03', '04', 'TROMPETEROS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160305', '16', '03', '05', 'URARINAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160400', '16', '04', '00', 'MARISCAL RAMON CASTILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160401', '16', '04', '01', 'RAMON CASTILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160402', '16', '04', '02', 'PEBAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160403', '16', '04', '03', 'YAVARI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160404', '16', '04', '04', 'SAN PABLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160500', '16', '05', '00', 'REQUENA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160501', '16', '05', '01', 'REQUENA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160502', '16', '05', '02', 'ALTO TAPICHE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160503', '16', '05', '03', 'CAPELO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160504', '16', '05', '04', 'EMILIO SAN MARTIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160505', '16', '05', '05', 'MAQUIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160506', '16', '05', '06', 'PUINAHUA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160507', '16', '05', '07', 'SAQUENA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160508', '16', '05', '08', 'SOPLIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160509', '16', '05', '09', 'TAPICHE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160510', '16', '05', '10', 'JENARO HERRERA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160511', '16', '05', '11', 'YAQUERANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160600', '16', '06', '00', 'UCAYALI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160601', '16', '06', '01', 'CONTAMANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160602', '16', '06', '02', 'INAHUAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160603', '16', '06', '03', 'PADRE MARQUEZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160604', '16', '06', '04', 'PAMPA HERMOSA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160605', '16', '06', '05', 'SARAYACU', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160606', '16', '06', '06', 'VARGAS GUERRA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160700', '16', '07', '00', 'DATEM DEL MARAÑON', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160701', '16', '07', '01', 'BARRANCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160702', '16', '07', '02', 'CAHUAPANAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160703', '16', '07', '03', 'MANSERICHE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160704', '16', '07', '04', 'MORONA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160705', '16', '07', '05', 'PASTAZA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('160706', '16', '07', '06', 'ANDOAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('170000', '17', '00', '00', 'MADRE DE DIOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('170100', '17', '01', '00', 'TAMBOPATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('170101', '17', '01', '01', 'TAMBOPATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('170102', '17', '01', '02', 'INAMBARI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('170103', '17', '01', '03', 'LAS PIEDRAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('170104', '17', '01', '04', 'LABERINTO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('170200', '17', '02', '00', 'MANU', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('170201', '17', '02', '01', 'MANU', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('170202', '17', '02', '02', 'FITZCARRALD', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('170203', '17', '02', '03', 'MADRE DE DIOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('170204', '17', '02', '04', 'HUEPETUHE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('170300', '17', '03', '00', 'TAHUAMANU', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('170301', '17', '03', '01', 'IÑAPARI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('170302', '17', '03', '02', 'IBERIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('170303', '17', '03', '03', 'TAHUAMANU', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180000', '18', '00', '00', 'MOQUEGUA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180100', '18', '01', '00', 'MARISCAL NIETO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180101', '18', '01', '01', 'MOQUEGUA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180102', '18', '01', '02', 'CARUMAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180103', '18', '01', '03', 'CUCHUMBAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180104', '18', '01', '04', 'SAMEGUA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180105', '18', '01', '05', 'SAN CRISTOBAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180106', '18', '01', '06', 'TORATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180200', '18', '02', '00', 'GENERAL SANCHEZ CERRO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180201', '18', '02', '01', 'OMATE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180202', '18', '02', '02', 'CHOJATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180203', '18', '02', '03', 'COALAQUE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180204', '18', '02', '04', 'ICHUÑA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180205', '18', '02', '05', 'LA CAPILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180206', '18', '02', '06', 'LLOQUE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180207', '18', '02', '07', 'MATALAQUE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180208', '18', '02', '08', 'PUQUINA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180209', '18', '02', '09', 'QUINISTAQUILLAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180210', '18', '02', '10', 'UBINAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180211', '18', '02', '11', 'YUNGA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180300', '18', '03', '00', 'ILO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180301', '18', '03', '01', 'ILO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180302', '18', '03', '02', 'EL ALGARROBAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('180303', '18', '03', '03', 'PACOCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190000', '19', '00', '00', 'PASCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190100', '19', '01', '00', 'PASCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190101', '19', '01', '01', 'CHAUPIMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190102', '19', '01', '02', 'HUACHON', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190103', '19', '01', '03', 'HUARIACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190104', '19', '01', '04', 'HUAYLLAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190105', '19', '01', '05', 'NINACACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190106', '19', '01', '06', 'PALLANCHACRA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190107', '19', '01', '07', 'PAUCARTAMBO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190108', '19', '01', '08', 'SAN FRANCISCO DE ASIS DE YARUSYACAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190109', '19', '01', '09', 'SIMON BOLIVAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190110', '19', '01', '10', 'TICLACAYAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190111', '19', '01', '11', 'TINYAHUARCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190112', '19', '01', '12', 'VICCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190113', '19', '01', '13', 'YANACANCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190200', '19', '02', '00', 'DANIEL ALCIDES CARRION', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190201', '19', '02', '01', 'YANAHUANCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190202', '19', '02', '02', 'CHACAYAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190203', '19', '02', '03', 'GOYLLARISQUIZGA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190204', '19', '02', '04', 'PAUCAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190205', '19', '02', '05', 'SAN PEDRO DE PILLAO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190206', '19', '02', '06', 'SANTA ANA DE TUSI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190207', '19', '02', '07', 'TAPUC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190208', '19', '02', '08', 'VILCABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190300', '19', '03', '00', 'OXAPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190301', '19', '03', '01', 'OXAPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190302', '19', '03', '02', 'CHONTABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190303', '19', '03', '03', 'HUANCABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190304', '19', '03', '04', 'PALCAZU', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190305', '19', '03', '05', 'POZUZO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190306', '19', '03', '06', 'PUERTO BERMUDEZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190307', '19', '03', '07', 'VILLA RICA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('190308', '19', '03', '08', 'CONSTITUCION', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200000', '20', '00', '00', 'PIURA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200100', '20', '01', '00', 'PIURA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200101', '20', '01', '01', 'PIURA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200104', '20', '01', '04', 'CASTILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200105', '20', '01', '05', 'CATACAOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200107', '20', '01', '07', 'CURA MORI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200108', '20', '01', '08', 'EL TALLAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200109', '20', '01', '09', 'LA ARENA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200110', '20', '01', '10', 'LA UNION', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200111', '20', '01', '11', 'LAS LOMAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200114', '20', '01', '14', 'TAMBO GRANDE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200200', '20', '02', '00', 'AYABACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200201', '20', '02', '01', 'AYABACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200202', '20', '02', '02', 'FRIAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200203', '20', '02', '03', 'JILILI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200204', '20', '02', '04', 'LAGUNAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200205', '20', '02', '05', 'MONTERO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200206', '20', '02', '06', 'PACAIPAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200207', '20', '02', '07', 'PAIMAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200208', '20', '02', '08', 'SAPILLICA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200209', '20', '02', '09', 'SICCHEZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200210', '20', '02', '10', 'SUYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200300', '20', '03', '00', 'HUANCABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200301', '20', '03', '01', 'HUANCABAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200302', '20', '03', '02', 'CANCHAQUE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200303', '20', '03', '03', 'EL CARMEN DE LA FRONTERA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200304', '20', '03', '04', 'HUARMACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200305', '20', '03', '05', 'LALAQUIZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200306', '20', '03', '06', 'SAN MIGUEL DE EL FAIQUE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200307', '20', '03', '07', 'SONDOR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200308', '20', '03', '08', 'SONDORILLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200400', '20', '04', '00', 'MORROPON', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200401', '20', '04', '01', 'CHULUCANAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200402', '20', '04', '02', 'BUENOS AIRES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200403', '20', '04', '03', 'CHALACO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200404', '20', '04', '04', 'LA MATANZA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200405', '20', '04', '05', 'MORROPON', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200406', '20', '04', '06', 'SALITRAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200407', '20', '04', '07', 'SAN JUAN DE BIGOTE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200408', '20', '04', '08', 'SANTA CATALINA DE MOSSA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200409', '20', '04', '09', 'SANTO DOMINGO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200410', '20', '04', '10', 'YAMANGO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200500', '20', '05', '00', 'PAITA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200501', '20', '05', '01', 'PAITA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200502', '20', '05', '02', 'AMOTAPE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200503', '20', '05', '03', 'ARENAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200504', '20', '05', '04', 'COLAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200505', '20', '05', '05', 'LA HUACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200506', '20', '05', '06', 'TAMARINDO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200507', '20', '05', '07', 'VICHAYAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200600', '20', '06', '00', 'SULLANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200601', '20', '06', '01', 'SULLANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200602', '20', '06', '02', 'BELLAVISTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200603', '20', '06', '03', 'IGNACIO ESCUDERO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200604', '20', '06', '04', 'LANCONES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200605', '20', '06', '05', 'MARCAVELICA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200606', '20', '06', '06', 'MIGUEL CHECA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200607', '20', '06', '07', 'QUERECOTILLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200608', '20', '06', '08', 'SALITRAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200700', '20', '07', '00', 'TALARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200701', '20', '07', '01', 'PARIÑAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200702', '20', '07', '02', 'EL ALTO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200703', '20', '07', '03', 'LA BREA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200704', '20', '07', '04', 'LOBITOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200705', '20', '07', '05', 'LOS ORGANOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200706', '20', '07', '06', 'MANCORA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200800', '20', '08', '00', 'SECHURA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200801', '20', '08', '01', 'SECHURA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200802', '20', '08', '02', 'BELLAVISTA DE LA UNION', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200803', '20', '08', '03', 'BERNAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200804', '20', '08', '04', 'CRISTO NOS VALGA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200805', '20', '08', '05', 'VICE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('200806', '20', '08', '06', 'RINCONADA LLICUAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210000', '21', '00', '00', 'PUNO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210100', '21', '01', '00', 'PUNO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210101', '21', '01', '01', 'PUNO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210102', '21', '01', '02', 'ACORA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210103', '21', '01', '03', 'AMANTANI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210104', '21', '01', '04', 'ATUNCOLLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210105', '21', '01', '05', 'CAPACHICA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210106', '21', '01', '06', 'CHUCUITO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210107', '21', '01', '07', 'COATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210108', '21', '01', '08', 'HUATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210109', '21', '01', '09', 'MAÑAZO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210110', '21', '01', '10', 'PAUCARCOLLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210111', '21', '01', '11', 'PICHACANI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210112', '21', '01', '12', 'PLATERIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210113', '21', '01', '13', 'SAN ANTONIO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210114', '21', '01', '14', 'TIQUILLACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210115', '21', '01', '15', 'VILQUE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210200', '21', '02', '00', 'AZANGARO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210201', '21', '02', '01', 'AZANGARO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210202', '21', '02', '02', 'ACHAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210203', '21', '02', '03', 'ARAPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210204', '21', '02', '04', 'ASILLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210205', '21', '02', '05', 'CAMINACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210206', '21', '02', '06', 'CHUPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210207', '21', '02', '07', 'JOSE DOMINGO CHOQUEHUANCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210208', '21', '02', '08', 'MUÑANI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210209', '21', '02', '09', 'POTONI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210210', '21', '02', '10', 'SAMAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210211', '21', '02', '11', 'SAN ANTON', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210212', '21', '02', '12', 'SAN JOSE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210213', '21', '02', '13', 'SAN JUAN DE SALINAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210214', '21', '02', '14', 'SANTIAGO DE PUPUJA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210215', '21', '02', '15', 'TIRAPATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210300', '21', '03', '00', 'CARABAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210301', '21', '03', '01', 'MACUSANI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210302', '21', '03', '02', 'AJOYANI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210303', '21', '03', '03', 'AYAPATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210304', '21', '03', '04', 'COASA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210305', '21', '03', '05', 'CORANI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210306', '21', '03', '06', 'CRUCERO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210307', '21', '03', '07', 'ITUATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210308', '21', '03', '08', 'OLLACHEA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210309', '21', '03', '09', 'SAN GABAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210310', '21', '03', '10', 'USICAYOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210400', '21', '04', '00', 'CHUCUITO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210401', '21', '04', '01', 'JULI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210402', '21', '04', '02', 'DESAGUADERO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210403', '21', '04', '03', 'HUACULLANI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210404', '21', '04', '04', 'KELLUYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210405', '21', '04', '05', 'PISACOMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210406', '21', '04', '06', 'POMATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210407', '21', '04', '07', 'ZEPITA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210500', '21', '05', '00', 'EL COLLAO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210501', '21', '05', '01', 'ILAVE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210502', '21', '05', '02', 'CAPAZO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210503', '21', '05', '03', 'PILCUYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210504', '21', '05', '04', 'SANTA ROSA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210505', '21', '05', '05', 'CONDURIRI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210600', '21', '06', '00', 'HUANCANE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210601', '21', '06', '01', 'HUANCANE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210602', '21', '06', '02', 'COJATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210603', '21', '06', '03', 'HUATASANI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210604', '21', '06', '04', 'INCHUPALLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210605', '21', '06', '05', 'PUSI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210606', '21', '06', '06', 'ROSASPATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210607', '21', '06', '07', 'TARACO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210608', '21', '06', '08', 'VILQUE CHICO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210700', '21', '07', '00', 'LAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210701', '21', '07', '01', 'LAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210702', '21', '07', '02', 'CABANILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210703', '21', '07', '03', 'CALAPUJA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210704', '21', '07', '04', 'NICASIO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210705', '21', '07', '05', 'OCUVIRI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210706', '21', '07', '06', 'PALCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210707', '21', '07', '07', 'PARATIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210708', '21', '07', '08', 'PUCARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210709', '21', '07', '09', 'SANTA LUCIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210710', '21', '07', '10', 'VILAVILA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210800', '21', '08', '00', 'MELGAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210801', '21', '08', '01', 'AYAVIRI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210802', '21', '08', '02', 'ANTAUTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210803', '21', '08', '03', 'CUPI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210804', '21', '08', '04', 'LLALLI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210805', '21', '08', '05', 'MACARI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210806', '21', '08', '06', 'NUÑOA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210807', '21', '08', '07', 'ORURILLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210808', '21', '08', '08', 'SANTA ROSA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210809', '21', '08', '09', 'UMACHIRI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210900', '21', '09', '00', 'MOHO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210901', '21', '09', '01', 'MOHO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210902', '21', '09', '02', 'CONIMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210903', '21', '09', '03', 'HUAYRAPATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('210904', '21', '09', '04', 'TILALI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211000', '21', '10', '00', 'SAN ANTONIO DE PUTINA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211001', '21', '10', '01', 'PUTINA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211002', '21', '10', '02', 'ANANEA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211003', '21', '10', '03', 'PEDRO VILCA APAZA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211004', '21', '10', '04', 'QUILCAPUNCU', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211005', '21', '10', '05', 'SINA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211100', '21', '11', '00', 'SAN ROMAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211101', '21', '11', '01', 'JULIACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211102', '21', '11', '02', 'CABANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211103', '21', '11', '03', 'CABANILLAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211104', '21', '11', '04', 'CARACOTO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211200', '21', '12', '00', 'SANDIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211201', '21', '12', '01', 'SANDIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211202', '21', '12', '02', 'CUYOCUYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211203', '21', '12', '03', 'LIMBANI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211204', '21', '12', '04', 'PATAMBUCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211205', '21', '12', '05', 'PHARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211206', '21', '12', '06', 'QUIACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211207', '21', '12', '07', 'SAN JUAN DEL ORO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211208', '21', '12', '08', 'YANAHUAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211209', '21', '12', '09', 'ALTO INAMBARI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211210', '21', '12', '10', 'SAN PEDRO DE PUTINA PUNCO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211300', '21', '13', '00', 'YUNGUYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211301', '21', '13', '01', 'YUNGUYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211302', '21', '13', '02', 'ANAPIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211303', '21', '13', '03', 'COPANI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211304', '21', '13', '04', 'CUTURAPI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211305', '21', '13', '05', 'OLLARAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211306', '21', '13', '06', 'TINICACHI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('211307', '21', '13', '07', 'UNICACHI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220000', '22', '00', '00', 'SAN MARTIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220100', '22', '01', '00', 'MOYOBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220101', '22', '01', '01', 'MOYOBAMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220102', '22', '01', '02', 'CALZADA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220103', '22', '01', '03', 'HABANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220104', '22', '01', '04', 'JEPELACIO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220105', '22', '01', '05', 'SORITOR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220106', '22', '01', '06', 'YANTALO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220200', '22', '02', '00', 'BELLAVISTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220201', '22', '02', '01', 'BELLAVISTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220202', '22', '02', '02', 'ALTO BIAVO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220203', '22', '02', '03', 'BAJO BIAVO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220204', '22', '02', '04', 'HUALLAGA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220205', '22', '02', '05', 'SAN PABLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220206', '22', '02', '06', 'SAN RAFAEL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220300', '22', '03', '00', 'EL DORADO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220301', '22', '03', '01', 'SAN JOSE DE SISA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220302', '22', '03', '02', 'AGUA BLANCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220303', '22', '03', '03', 'SAN MARTIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220304', '22', '03', '04', 'SANTA ROSA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220305', '22', '03', '05', 'SHATOJA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220400', '22', '04', '00', 'HUALLAGA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220401', '22', '04', '01', 'SAPOSOA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220402', '22', '04', '02', 'ALTO SAPOSOA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220403', '22', '04', '03', 'EL ESLABON', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220404', '22', '04', '04', 'PISCOYACU', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220405', '22', '04', '05', 'SACANCHE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220406', '22', '04', '06', 'TINGO DE SAPOSOA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220500', '22', '05', '00', 'LAMAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220501', '22', '05', '01', 'LAMAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220502', '22', '05', '02', 'ALONSO DE ALVARADO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220503', '22', '05', '03', 'BARRANQUITA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220504', '22', '05', '04', 'CAYNARACHI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220505', '22', '05', '05', 'CUÑUMBUQUI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220506', '22', '05', '06', 'PINTO RECODO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220507', '22', '05', '07', 'RUMISAPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220508', '22', '05', '08', 'SAN ROQUE DE CUMBAZA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220509', '22', '05', '09', 'SHANAO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220510', '22', '05', '10', 'TABALOSOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220511', '22', '05', '11', 'ZAPATERO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220600', '22', '06', '00', 'MARISCAL CACERES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220601', '22', '06', '01', 'JUANJUI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220602', '22', '06', '02', 'CAMPANILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220603', '22', '06', '03', 'HUICUNGO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220604', '22', '06', '04', 'PACHIZA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220605', '22', '06', '05', 'PAJARILLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220700', '22', '07', '00', 'PICOTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220701', '22', '07', '01', 'PICOTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220702', '22', '07', '02', 'BUENOS AIRES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220703', '22', '07', '03', 'CASPISAPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220704', '22', '07', '04', 'PILLUANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220705', '22', '07', '05', 'PUCACACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220706', '22', '07', '06', 'SAN CRISTOBAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220707', '22', '07', '07', 'SAN HILARION', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220708', '22', '07', '08', 'SHAMBOYACU', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220709', '22', '07', '09', 'TINGO DE PONASA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220710', '22', '07', '10', 'TRES UNIDOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220800', '22', '08', '00', 'RIOJA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220801', '22', '08', '01', 'RIOJA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220802', '22', '08', '02', 'AWAJUN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220803', '22', '08', '03', 'ELIAS SOPLIN VARGAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220804', '22', '08', '04', 'NUEVA CAJAMARCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220805', '22', '08', '05', 'PARDO MIGUEL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220806', '22', '08', '06', 'POSIC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220807', '22', '08', '07', 'SAN FERNANDO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220808', '22', '08', '08', 'YORONGOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220809', '22', '08', '09', 'YURACYACU', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220900', '22', '09', '00', 'SAN MARTIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220901', '22', '09', '01', 'TARAPOTO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220902', '22', '09', '02', 'ALBERTO LEVEAU', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220903', '22', '09', '03', 'CACATACHI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220904', '22', '09', '04', 'CHAZUTA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220905', '22', '09', '05', 'CHIPURANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220906', '22', '09', '06', 'EL PORVENIR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220907', '22', '09', '07', 'HUIMBAYOC', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220908', '22', '09', '08', 'JUAN GUERRA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220909', '22', '09', '09', 'LA BANDA DE SHILCAYO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220910', '22', '09', '10', 'MORALES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220911', '22', '09', '11', 'PAPAPLAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220912', '22', '09', '12', 'SAN ANTONIO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220913', '22', '09', '13', 'SAUCE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('220914', '22', '09', '14', 'SHAPAJA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('221000', '22', '10', '00', 'TOCACHE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('221001', '22', '10', '01', 'TOCACHE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('221002', '22', '10', '02', 'NUEVO PROGRESO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('221003', '22', '10', '03', 'POLVORA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('221004', '22', '10', '04', 'SHUNTE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('221005', '22', '10', '05', 'UCHIZA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230000', '23', '00', '00', 'TACNA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230100', '23', '01', '00', 'TACNA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230101', '23', '01', '01', 'TACNA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230102', '23', '01', '02', 'ALTO DE LA ALIANZA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230103', '23', '01', '03', 'CALANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230104', '23', '01', '04', 'CIUDAD NUEVA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230105', '23', '01', '05', 'INCLAN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230106', '23', '01', '06', 'PACHIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230107', '23', '01', '07', 'PALCA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230108', '23', '01', '08', 'POCOLLAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230109', '23', '01', '09', 'SAMA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230110', '23', '01', '10', 'CORONEL GREGORIO ALBARRACIN LANCHIPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230200', '23', '02', '00', 'CANDARAVE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230201', '23', '02', '01', 'CANDARAVE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230202', '23', '02', '02', 'CAIRANI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230203', '23', '02', '03', 'CAMILACA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230204', '23', '02', '04', 'CURIBAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230205', '23', '02', '05', 'HUANUARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230206', '23', '02', '06', 'QUILAHUANI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230300', '23', '03', '00', 'JORGE BASADRE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230301', '23', '03', '01', 'LOCUMBA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230302', '23', '03', '02', 'ILABAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230303', '23', '03', '03', 'ITE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230400', '23', '04', '00', 'TARATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230401', '23', '04', '01', 'TARATA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230402', '23', '04', '02', 'HEROES ALBARRACIN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230403', '23', '04', '03', 'ESTIQUE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230404', '23', '04', '04', 'ESTIQUE-PAMPA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230405', '23', '04', '05', 'SITAJARA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230406', '23', '04', '06', 'SUSAPAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230407', '23', '04', '07', 'TARUCACHI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('230408', '23', '04', '08', 'TICACO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('240000', '24', '00', '00', 'TUMBES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('240100', '24', '01', '00', 'TUMBES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('240101', '24', '01', '01', 'TUMBES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('240102', '24', '01', '02', 'CORRALES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('240103', '24', '01', '03', 'LA CRUZ', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('240104', '24', '01', '04', 'PAMPAS DE HOSPITAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('240105', '24', '01', '05', 'SAN JACINTO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('240106', '24', '01', '06', 'SAN JUAN DE LA VIRGEN', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('240200', '24', '02', '00', 'CONTRALMIRANTE VILLAR', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('240201', '24', '02', '01', 'ZORRITOS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('240202', '24', '02', '02', 'CASITAS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('240203', '24', '02', '03', 'CANOAS DE PUNTA SAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('240300', '24', '03', '00', 'ZARUMILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('240301', '24', '03', '01', 'ZARUMILLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('240302', '24', '03', '02', 'AGUAS VERDES', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('240303', '24', '03', '03', 'MATAPALO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('240304', '24', '03', '04', 'PAPAYAL', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('250000', '25', '00', '00', 'UCAYALI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('250100', '25', '01', '00', 'CORONEL PORTILLO', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('250101', '25', '01', '01', 'CALLERIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('250102', '25', '01', '02', 'CAMPOVERDE', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('250103', '25', '01', '03', 'IPARIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('250104', '25', '01', '04', 'MASISEA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('250105', '25', '01', '05', 'YARINACOCHA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('250106', '25', '01', '06', 'NUEVA REQUENA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('250107', '25', '01', '07', 'MANANTAY', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('250200', '25', '02', '00', 'ATALAYA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('250201', '25', '02', '01', 'RAYMONDI', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('250202', '25', '02', '02', 'SEPAHUA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('250203', '25', '02', '03', 'TAHUANIA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('250204', '25', '02', '04', 'YURUA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('250300', '25', '03', '00', 'PADRE ABAD', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('250301', '25', '03', '01', 'PADRE ABAD', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('250302', '25', '03', '02', 'IRAZOLA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('250303', '25', '03', '03', 'CURIMANA', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('250400', '25', '04', '00', 'PURUS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);
INSERT INTO ubigeo VALUES ('250401', '25', '04', '01', 'PURUS', 1, 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 2, '2016-01-22 17:02:36.718-05', '0.0.0.0', 1);


SET search_path = auditoria, pg_catalog;

--
-- TOC entry 2501 (class 2606 OID 76555)
-- Name: pk_iniciosesion; Type: CONSTRAINT; Schema: auditoria; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY eventosesionsistema
    ADD CONSTRAINT pk_iniciosesion PRIMARY KEY (id);


SET search_path = licencia, pg_catalog;

--
-- TOC entry 2503 (class 2606 OID 76557)
-- Name: pk_contrato; Type: CONSTRAINT; Schema: licencia; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Contrato"
    ADD CONSTRAINT pk_contrato PRIMARY KEY (id);


--
-- TOC entry 2505 (class 2606 OID 76559)
-- Name: pk_empresa; Type: CONSTRAINT; Schema: licencia; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Empresa"
    ADD CONSTRAINT pk_empresa PRIMARY KEY (id);


--
-- TOC entry 2605 (class 2606 OID 76781)
-- Name: pk_tablamaestra; Type: CONSTRAINT; Schema: licencia; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Tablamaestra"
    ADD CONSTRAINT pk_tablamaestra PRIMARY KEY (id, idmaestro);


SET search_path = negocio, pg_catalog;

--
-- TOC entry 2543 (class 2606 OID 76561)
-- Name: cons_uniq_idpersona; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Persona"
    ADD CONSTRAINT cons_uniq_idpersona UNIQUE (id);


--
-- TOC entry 2507 (class 2606 OID 76563)
-- Name: pk_archivocargado; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ArchivoCargado"
    ADD CONSTRAINT pk_archivocargado PRIMARY KEY (id);


--
-- TOC entry 2509 (class 2606 OID 76565)
-- Name: pk_comprobanteadicional; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ComprobanteAdicional"
    ADD CONSTRAINT pk_comprobanteadicional PRIMARY KEY (id);


--
-- TOC entry 2511 (class 2606 OID 76567)
-- Name: pk_comprobantegenerado; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ComprobanteGenerado"
    ADD CONSTRAINT pk_comprobantegenerado PRIMARY KEY (id);


--
-- TOC entry 2513 (class 2606 OID 76569)
-- Name: pk_comprobanteobligacion; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ComprobanteObligacion"
    ADD CONSTRAINT pk_comprobanteobligacion PRIMARY KEY (idcomprobante, idobligacion, iddetalleservicio, idservicio);


--
-- TOC entry 2515 (class 2606 OID 76571)
-- Name: pk_correoelectronico; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "CorreoElectronico"
    ADD CONSTRAINT pk_correoelectronico PRIMARY KEY (id);


--
-- TOC entry 2517 (class 2606 OID 76573)
-- Name: pk_cronogramapago; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "CronogramaPago"
    ADD CONSTRAINT pk_cronogramapago PRIMARY KEY (nrocuota, idservicio);


--
-- TOC entry 2519 (class 2606 OID 76575)
-- Name: pk_cuentabancaria; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "CuentaBancaria"
    ADD CONSTRAINT pk_cuentabancaria PRIMARY KEY (id);


--
-- TOC entry 2521 (class 2606 OID 76577)
-- Name: pk_detallearchivocargado; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "DetalleArchivoCargado"
    ADD CONSTRAINT pk_detallearchivocargado PRIMARY KEY (id);


--
-- TOC entry 2523 (class 2606 OID 76579)
-- Name: pk_detallecomprobante; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "DetalleComprobanteGenerado"
    ADD CONSTRAINT pk_detallecomprobante PRIMARY KEY (id);


--
-- TOC entry 2525 (class 2606 OID 76581)
-- Name: pk_direccion; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Direccion"
    ADD CONSTRAINT pk_direccion PRIMARY KEY (id);


--
-- TOC entry 2527 (class 2606 OID 76583)
-- Name: pk_documentosadjuntosservicio; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "DocumentoAdjuntoServicio"
    ADD CONSTRAINT pk_documentosadjuntosservicio PRIMARY KEY (id);


--
-- TOC entry 2529 (class 2606 OID 76585)
-- Name: pk_eventoobsanuservicio; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "EventoObsAnuServicio"
    ADD CONSTRAINT pk_eventoobsanuservicio PRIMARY KEY (id);


--
-- TOC entry 2531 (class 2606 OID 76587)
-- Name: pk_maestroservicios; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "MaestroServicios"
    ADD CONSTRAINT pk_maestroservicios PRIMARY KEY (id);


--
-- TOC entry 2533 (class 2606 OID 76589)
-- Name: pk_movimientocuenta; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "MovimientoCuenta"
    ADD CONSTRAINT pk_movimientocuenta PRIMARY KEY (id);


--
-- TOC entry 2535 (class 2606 OID 76591)
-- Name: pk_obligacionesxpagar; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ObligacionesXPagar"
    ADD CONSTRAINT pk_obligacionesxpagar PRIMARY KEY (id);


--
-- TOC entry 2537 (class 2606 OID 76593)
-- Name: pk_pagoobligacion; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PagosObligacion"
    ADD CONSTRAINT pk_pagoobligacion PRIMARY KEY (idpago);


--
-- TOC entry 2539 (class 2606 OID 76595)
-- Name: pk_pagosservicio; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PagosServicio"
    ADD CONSTRAINT pk_pagosservicio PRIMARY KEY (idpago);


--
-- TOC entry 2541 (class 2606 OID 76597)
-- Name: pk_pasajeroservicio; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PasajeroServicio"
    ADD CONSTRAINT pk_pasajeroservicio PRIMARY KEY (id);


--
-- TOC entry 2545 (class 2606 OID 76599)
-- Name: pk_persona; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Persona"
    ADD CONSTRAINT pk_persona PRIMARY KEY (id, idtipopersona);


--
-- TOC entry 2549 (class 2606 OID 76601)
-- Name: pk_personacontactoproveedor; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PersonaContactoProveedor"
    ADD CONSTRAINT pk_personacontactoproveedor PRIMARY KEY (idproveedor, idcontacto);


--
-- TOC entry 2551 (class 2606 OID 76603)
-- Name: pk_personadireccion; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PersonaDireccion"
    ADD CONSTRAINT pk_personadireccion PRIMARY KEY (idpersona, iddireccion, idtipopersona);


--
-- TOC entry 2553 (class 2606 OID 76605)
-- Name: pk_personapotencial; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Personapotencial"
    ADD CONSTRAINT pk_personapotencial PRIMARY KEY (id);


--
-- TOC entry 2547 (class 2606 OID 76607)
-- Name: pk_personaproveedor; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PersonaAdicional"
    ADD CONSTRAINT pk_personaproveedor PRIMARY KEY (idpersona);


--
-- TOC entry 2555 (class 2606 OID 76609)
-- Name: pk_programanovios; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ProgramaNovios"
    ADD CONSTRAINT pk_programanovios PRIMARY KEY (id);


--
-- TOC entry 2557 (class 2606 OID 76611)
-- Name: pk_proveedorcuentabancaria; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ProveedorCuentaBancaria"
    ADD CONSTRAINT pk_proveedorcuentabancaria PRIMARY KEY (id);


--
-- TOC entry 2559 (class 2606 OID 76613)
-- Name: pk_proveedorpersona; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ProveedorPersona"
    ADD CONSTRAINT pk_proveedorpersona PRIMARY KEY (idproveedor);


--
-- TOC entry 2561 (class 2606 OID 76615)
-- Name: pk_proveedortiposervicio; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ProveedorTipoServicio"
    ADD CONSTRAINT pk_proveedortiposervicio PRIMARY KEY (idproveedor, idtiposervicio, idproveedorservicio);


--
-- TOC entry 2563 (class 2606 OID 76617)
-- Name: pk_rutaservicio; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "RutaServicio"
    ADD CONSTRAINT pk_rutaservicio PRIMARY KEY (id, idtramo);


--
-- TOC entry 2565 (class 2606 OID 76619)
-- Name: pk_saldosservicio; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "SaldosServicio"
    ADD CONSTRAINT pk_saldosservicio PRIMARY KEY (idsaldoservicio);


--
-- TOC entry 2567 (class 2606 OID 76621)
-- Name: pk_serviciocabecera; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ServicioCabecera"
    ADD CONSTRAINT pk_serviciocabecera PRIMARY KEY (id);


--
-- TOC entry 2571 (class 2606 OID 76623)
-- Name: pk_serviciodepente; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ServicioMaestroServicio"
    ADD CONSTRAINT pk_serviciodepente PRIMARY KEY (idservicio, idserviciodepende);


--
-- TOC entry 2569 (class 2606 OID 76625)
-- Name: pk_serviciodetalle; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ServicioDetalle"
    ADD CONSTRAINT pk_serviciodetalle PRIMARY KEY (id);


--
-- TOC entry 2573 (class 2606 OID 76627)
-- Name: pk_telefono; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Telefono"
    ADD CONSTRAINT pk_telefono PRIMARY KEY (id);


--
-- TOC entry 2575 (class 2606 OID 76629)
-- Name: pk_telefonodireccion; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "TelefonoDireccion"
    ADD CONSTRAINT pk_telefonodireccion PRIMARY KEY (idtelefono, iddireccion);


--
-- TOC entry 2577 (class 2606 OID 76631)
-- Name: pk_telefonopersona; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "TelefonoPersona"
    ADD CONSTRAINT pk_telefonopersona PRIMARY KEY (idtelefono, idpersona);


--
-- TOC entry 2579 (class 2606 OID 76633)
-- Name: pk_tipocambio; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "TipoCambio"
    ADD CONSTRAINT pk_tipocambio PRIMARY KEY (id, fechatipocambio);


--
-- TOC entry 2581 (class 2606 OID 76635)
-- Name: pk_tramo; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Tramo"
    ADD CONSTRAINT pk_tramo PRIMARY KEY (id);


--
-- TOC entry 2583 (class 2606 OID 76637)
-- Name: pk_transacciontipocambio; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "TransaccionTipoCambio"
    ADD CONSTRAINT pk_transacciontipocambio PRIMARY KEY (id);


SET search_path = seguridad, pg_catalog;

--
-- TOC entry 2591 (class 2606 OID 76639)
-- Name: pk_rol; Type: CONSTRAINT; Schema: seguridad; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rol
    ADD CONSTRAINT pk_rol PRIMARY KEY (id);


--
-- TOC entry 2593 (class 2606 OID 76641)
-- Name: pk_usuario; Type: CONSTRAINT; Schema: seguridad; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usuario
    ADD CONSTRAINT pk_usuario PRIMARY KEY (id);


--
-- TOC entry 2595 (class 2606 OID 76643)
-- Name: uq_usuario; Type: CONSTRAINT; Schema: seguridad; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usuario
    ADD CONSTRAINT uq_usuario UNIQUE (usuario);


SET search_path = soporte, pg_catalog;

--
-- TOC entry 2601 (class 2606 OID 76645)
-- Name: cons_uq_iata; Type: CONSTRAINT; Schema: soporte; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY destino
    ADD CONSTRAINT cons_uq_iata UNIQUE (codigoiata);


--
-- TOC entry 2603 (class 2606 OID 76647)
-- Name: pk_destino; Type: CONSTRAINT; Schema: soporte; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY destino
    ADD CONSTRAINT pk_destino PRIMARY KEY (id);


--
-- TOC entry 2587 (class 2606 OID 76649)
-- Name: pk_pais; Type: CONSTRAINT; Schema: soporte; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pais
    ADD CONSTRAINT pk_pais PRIMARY KEY (id);


--
-- TOC entry 2597 (class 2606 OID 76651)
-- Name: pk_parametro; Type: CONSTRAINT; Schema: soporte; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Parametro"
    ADD CONSTRAINT pk_parametro PRIMARY KEY (id);


--
-- TOC entry 2589 (class 2606 OID 76653)
-- Name: pk_tablamaestra; Type: CONSTRAINT; Schema: soporte; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Tablamaestra"
    ADD CONSTRAINT pk_tablamaestra PRIMARY KEY (id, idmaestro);


--
-- TOC entry 2599 (class 2606 OID 76655)
-- Name: pk_tipocambio; Type: CONSTRAINT; Schema: soporte; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "TipoCambio"
    ADD CONSTRAINT pk_tipocambio PRIMARY KEY (id);


--
-- TOC entry 2585 (class 2606 OID 76657)
-- Name: pk_ubigeo; Type: CONSTRAINT; Schema: soporte; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ubigeo
    ADD CONSTRAINT pk_ubigeo PRIMARY KEY (id);


SET search_path = auditoria, pg_catalog;

--
-- TOC entry 2606 (class 2606 OID 76658)
-- Name: fk_eventosesionsistema_usuario; Type: FK CONSTRAINT; Schema: auditoria; Owner: postgres
--

ALTER TABLE ONLY eventosesionsistema
    ADD CONSTRAINT fk_eventosesionsistema_usuario FOREIGN KEY (idusuario) REFERENCES seguridad.usuario(id);


SET search_path = licencia, pg_catalog;

--
-- TOC entry 2607 (class 2606 OID 76803)
-- Name: fk_contrato_empresa; Type: FK CONSTRAINT; Schema: licencia; Owner: postgres
--

ALTER TABLE ONLY "Contrato"
    ADD CONSTRAINT fk_contrato_empresa FOREIGN KEY (idempresa) REFERENCES "Empresa"(id);


SET search_path = negocio, pg_catalog;

--
-- TOC entry 2609 (class 2606 OID 76668)
-- Name: fk_archivodetallearchivo; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "DetalleArchivoCargado"
    ADD CONSTRAINT fk_archivodetallearchivo FOREIGN KEY (idarchivo) REFERENCES "ArchivoCargado"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2623 (class 2606 OID 76673)
-- Name: fk_cliente1; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "ServicioCabecera"
    ADD CONSTRAINT fk_cliente1 FOREIGN KEY (idcliente1) REFERENCES "Persona"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2624 (class 2606 OID 76678)
-- Name: fk_cliente2; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "ServicioCabecera"
    ADD CONSTRAINT fk_cliente2 FOREIGN KEY (idcliente2) REFERENCES "Persona"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2615 (class 2606 OID 76683)
-- Name: fk_contacto; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "PersonaContactoProveedor"
    ADD CONSTRAINT fk_contacto FOREIGN KEY (idcontacto) REFERENCES "Persona"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2608 (class 2606 OID 76688)
-- Name: fk_correopersona; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "CorreoElectronico"
    ADD CONSTRAINT fk_correopersona FOREIGN KEY (idpersona) REFERENCES "Persona"(id);


--
-- TOC entry 2610 (class 2606 OID 76693)
-- Name: fk_detallecabeceracomprobante; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "DetalleComprobanteGenerado"
    ADD CONSTRAINT fk_detallecabeceracomprobante FOREIGN KEY (idcomprobante) REFERENCES "ComprobanteGenerado"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2617 (class 2606 OID 76698)
-- Name: fk_direccion; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "PersonaDireccion"
    ADD CONSTRAINT fk_direccion FOREIGN KEY (iddireccion) REFERENCES "Direccion"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2626 (class 2606 OID 76703)
-- Name: fk_maestroservicio; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "ServicioMaestroServicio"
    ADD CONSTRAINT fk_maestroservicio FOREIGN KEY (idservicio) REFERENCES "MaestroServicios"(id) ON UPDATE CASCADE;


--
-- TOC entry 2611 (class 2606 OID 76708)
-- Name: fk_obligacionesxpagar; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "PagosObligacion"
    ADD CONSTRAINT fk_obligacionesxpagar FOREIGN KEY (idobligacion) REFERENCES "ObligacionesXPagar"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2613 (class 2606 OID 76713)
-- Name: fk_paxserviciocabecera; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "PasajeroServicio"
    ADD CONSTRAINT fk_paxserviciocabecera FOREIGN KEY (idservicio) REFERENCES "ServicioCabecera"(id);


--
-- TOC entry 2618 (class 2606 OID 76718)
-- Name: fk_persona; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "PersonaDireccion"
    ADD CONSTRAINT fk_persona FOREIGN KEY (idpersona) REFERENCES "Persona"(id);


--
-- TOC entry 2614 (class 2606 OID 76723)
-- Name: fk_personaproveedorpersona; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "PersonaAdicional"
    ADD CONSTRAINT fk_personaproveedorpersona FOREIGN KEY (idpersona) REFERENCES "Persona"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2616 (class 2606 OID 76728)
-- Name: fk_proveedor; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "PersonaContactoProveedor"
    ADD CONSTRAINT fk_proveedor FOREIGN KEY (idproveedor) REFERENCES "Persona"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2619 (class 2606 OID 76733)
-- Name: fk_proveedorcuentabancaria; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "ProveedorCuentaBancaria"
    ADD CONSTRAINT fk_proveedorcuentabancaria FOREIGN KEY (idproveedor) REFERENCES "Persona"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2620 (class 2606 OID 76738)
-- Name: fk_proveedorpersona; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "ProveedorPersona"
    ADD CONSTRAINT fk_proveedorpersona FOREIGN KEY (idproveedor) REFERENCES "Persona"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2621 (class 2606 OID 76743)
-- Name: fk_proveedorservicio; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "ProveedorTipoServicio"
    ADD CONSTRAINT fk_proveedorservicio FOREIGN KEY (idtiposervicio) REFERENCES "MaestroServicios"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2612 (class 2606 OID 76748)
-- Name: fk_servicio; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "PagosServicio"
    ADD CONSTRAINT fk_servicio FOREIGN KEY (idservicio) REFERENCES "ServicioCabecera"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2622 (class 2606 OID 76753)
-- Name: fk_servicio; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "SaldosServicio"
    ADD CONSTRAINT fk_servicio FOREIGN KEY (idservicio) REFERENCES "ServicioCabecera"(id);


--
-- TOC entry 2625 (class 2606 OID 76758)
-- Name: fk_serviciocabecera; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "ServicioDetalle"
    ADD CONSTRAINT fk_serviciocabecera FOREIGN KEY (idservicio) REFERENCES "ServicioCabecera"(id);


SET search_path = seguridad, pg_catalog;

--
-- TOC entry 2627 (class 2606 OID 76763)
-- Name: fk_usuario_rol; Type: FK CONSTRAINT; Schema: seguridad; Owner: postgres
--

ALTER TABLE ONLY usuario
    ADD CONSTRAINT fk_usuario_rol FOREIGN KEY (id_rol) REFERENCES rol(id);


SET search_path = soporte, pg_catalog;

--
-- TOC entry 2628 (class 2606 OID 76768)
-- Name: fk_configtiposervicio; Type: FK CONSTRAINT; Schema: soporte; Owner: postgres
--

ALTER TABLE ONLY "ConfiguracionTipoServicio"
    ADD CONSTRAINT fk_configtiposervicio FOREIGN KEY (idtiposervicio) REFERENCES negocio."MaestroServicios"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2848 (class 0 OID 0)
-- Dependencies: 12
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2016-02-11 19:16:26

--
-- PostgreSQL database dump complete
--

