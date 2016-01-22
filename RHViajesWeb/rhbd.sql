--
-- PostgreSQL database dump
--

-- Dumped from database version 9.2.8
-- Dumped by pg_dump version 9.2.8
-- Started on 2016-01-20 18:26:03

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 6 (class 2615 OID 67681)
-- Name: auditoria; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA auditoria;


ALTER SCHEMA auditoria OWNER TO postgres;

--
-- TOC entry 7 (class 2615 OID 67682)
-- Name: licencia; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA licencia;


ALTER SCHEMA licencia OWNER TO postgres;

--
-- TOC entry 8 (class 2615 OID 67683)
-- Name: negocio; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA negocio;


ALTER SCHEMA negocio OWNER TO postgres;

--
-- TOC entry 9 (class 2615 OID 67684)
-- Name: reportes; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA reportes;


ALTER SCHEMA reportes OWNER TO postgres;

--
-- TOC entry 10 (class 2615 OID 67685)
-- Name: seguridad; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA seguridad;


ALTER SCHEMA seguridad OWNER TO postgres;

--
-- TOC entry 11 (class 2615 OID 67686)
-- Name: soporte; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA soporte;


ALTER SCHEMA soporte OWNER TO postgres;

--
-- TOC entry 278 (class 3079 OID 11727)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2820 (class 0 OID 0)
-- Dependencies: 278
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 279 (class 3079 OID 67687)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 2821 (class 0 OID 0)
-- Dependencies: 279
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET search_path = auditoria, pg_catalog;

--
-- TOC entry 325 (class 1255 OID 67721)
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
-- TOC entry 523 (class 1255 OID 68713)
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
-- TOC entry 326 (class 1255 OID 67723)
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

SET search_path = negocio, pg_catalog;

--
-- TOC entry 436 (class 1255 OID 68598)
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
-- TOC entry 437 (class 1255 OID 68601)
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
-- TOC entry 439 (class 1255 OID 68602)
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
-- TOC entry 440 (class 1255 OID 68603)
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
-- TOC entry 438 (class 1255 OID 68604)
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
-- TOC entry 441 (class 1255 OID 68605)
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
-- TOC entry 442 (class 1255 OID 68606)
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
-- TOC entry 443 (class 1255 OID 68607)
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
-- TOC entry 444 (class 1255 OID 68609)
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
-- TOC entry 445 (class 1255 OID 68610)
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
-- TOC entry 446 (class 1255 OID 68611)
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
-- TOC entry 447 (class 1255 OID 68612)
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
select negocio.fn_ingresarservicioproveedor(
    p_idproveedor,
    p_idtiposervicio,
    p_idproveedorservicio,
    p_porcencomision,
    p_porcencominternacional,
    p_usuariomodificacion,
    p_ipmodificacion) into resultado;
end if;

return true;

 end;
$$;


ALTER FUNCTION negocio.fn_actualizarproveedorservicio(p_idempresa integer, p_idproveedor integer, p_idtiposervicio integer, p_idproveedorservicio integer, p_porcencomision numeric, p_porcencominternacional numeric, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 448 (class 1255 OID 68613)
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
-- TOC entry 449 (class 1255 OID 68614)
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
-- TOC entry 450 (class 1255 OID 68615)
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
-- TOC entry 451 (class 1255 OID 68616)
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
-- TOC entry 453 (class 1255 OID 68617)
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
-- TOC entry 327 (class 1255 OID 67742)
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
-- TOC entry 328 (class 1255 OID 67743)
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
-- TOC entry 331 (class 1255 OID 67744)
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
-- TOC entry 332 (class 1255 OID 67745)
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
-- TOC entry 333 (class 1255 OID 67746)
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
-- TOC entry 334 (class 1255 OID 67747)
-- Name: fn_consultarcheckinpendientes(integer, timestamp without time zone, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarcheckinpendientes(p_idempresa integer, p_fechahasta timestamp without time zone, p_idvendedor integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
select sc.id, negocio.fn_consultarnombrepersona(sc.idcliente1) as nombrecliente, 
       negocio.fn_consultarnombrepersona(sc.idcliente2) as nombrecliente2,
       t.descripcionorigen, t.descripciondestino, t.fechasalida, t.fechallegada, 
       negocio.fn_consultarnombrepersona(t.idaerolinea) nombreaerolinea,
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
-- TOC entry 335 (class 1255 OID 67748)
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
-- TOC entry 336 (class 1255 OID 67749)
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
-- TOC entry 337 (class 1255 OID 67750)
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
-- TOC entry 339 (class 1255 OID 67751)
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
-- TOC entry 340 (class 1255 OID 67752)
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
-- TOC entry 341 (class 1255 OID 67753)
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
-- TOC entry 342 (class 1255 OID 67754)
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
-- TOC entry 343 (class 1255 OID 67755)
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
-- TOC entry 344 (class 1255 OID 67756)
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
-- TOC entry 338 (class 1255 OID 67757)
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
-- TOC entry 346 (class 1255 OID 67758)
-- Name: fn_consultarcronogramapago(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarcronogramapago(p_idempresa integer, p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT nrocuota, idservicio, fechavencimiento, capital, interes, totalcuota, 
       idestadocuota, usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
       fechamodificacion, ipmodificacion, idestadoregistro
  FROM negocio."CronogramaPago"
 where idservicio = p_idservicio
   and idempresa  = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarcronogramapago(p_idempresa integer, p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 347 (class 1255 OID 67759)
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
-- TOC entry 348 (class 1255 OID 67760)
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
-- TOC entry 349 (class 1255 OID 67761)
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
-- TOC entry 350 (class 1255 OID 67762)
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
-- TOC entry 351 (class 1255 OID 67763)
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
-- TOC entry 352 (class 1255 OID 67764)
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
-- TOC entry 353 (class 1255 OID 67765)
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
-- TOC entry 357 (class 1255 OID 67766)
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
-- TOC entry 358 (class 1255 OID 67767)
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
       negocio.fn_consultarnombrepersona(idaerolinea) as nombreaerolina, codigoreserva, numeroboleto, fechavctopasaporte, fechanacimiento,
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
-- TOC entry 359 (class 1255 OID 67768)
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
-- TOC entry 360 (class 1255 OID 67769)
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
    pro.usuariocreacion, pro.fechacreacion, pro.ipcreacion, ppro.idrubro, pro.fecnacimiento,
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
-- TOC entry 361 (class 1255 OID 67770)
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
-- TOC entry 362 (class 1255 OID 67771)
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
-- TOC entry 363 (class 1255 OID 67772)
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
-- TOC entry 354 (class 1255 OID 67773)
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
-- TOC entry 364 (class 1255 OID 67774)
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
-- TOC entry 365 (class 1255 OID 67775)
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
-- TOC entry 366 (class 1255 OID 67776)
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
-- TOC entry 367 (class 1255 OID 67777)
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
-- TOC entry 368 (class 1255 OID 67778)
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
       sercab.usuariocreacion, sercab.fechacreacion, sercab.ipcreacion, 
       sercab.usuariomodificacion, sercab.fechamodificacion, sercab.ipmodificacion, sercab.generocomprobantes, sercab.guardorelacioncomprobantes, sercab.observaciones
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
-- TOC entry 369 (class 1255 OID 67779)
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
       sercab.usuariocreacion, sercab.fechacreacion, sercab.ipcreacion, 
       sercab.usuariomodificacion, sercab.fechamodificacion, sercab.ipmodificacion,
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
-- TOC entry 370 (class 1255 OID 67780)
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
       sercab.usuariocreacion, sercab.fechacreacion, sercab.ipcreacion, 
       sercab.usuariomodificacion, sercab.fechamodificacion, sercab.ipmodificacion,
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
       sercab.usuariocreacion, sercab.fechacreacion, sercab.ipcreacion, 
       sercab.usuariomodificacion, sercab.fechamodificacion, sercab.ipmodificacion,
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
-- TOC entry 371 (class 1255 OID 67781)
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
-- TOC entry 373 (class 1255 OID 67782)
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
-- TOC entry 374 (class 1255 OID 67783)
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
       codigoreserva, numeroboleto, idservicio 
  from negocio.vw_servicio_detalle 
 where idservicio = p_idservicio
   and idempresa  = p_idempresa;


return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarservicioventajr(p_idempresa integer, p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 375 (class 1255 OID 67784)
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
-- TOC entry 376 (class 1255 OID 67785)
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
-- TOC entry 377 (class 1255 OID 67786)
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
-- TOC entry 378 (class 1255 OID 67787)
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
-- TOC entry 379 (class 1255 OID 67788)
-- Name: fn_direccionesxpersona(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_direccionesxpersona(p_idempresa integer, p_idpersona integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT dir.id, dir.idvia, dir.nombrevia, dir.numero, dir.interior, dir.manzana, 
       dir.lote, dir.principal, dir.idubigeo, dir.usuariocreacion, 
       dir.fechacreacion, dir.ipcreacion, dep.iddepartamento, 
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
   AND pdir.iempresa                         = p_idempresa
   AND dir.idempresa                         = p_idempresa
   AND pdir.idpersona                        = p_idpersona;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_direccionesxpersona(p_idempresa integer, p_idpersona integer) OWNER TO postgres;

--
-- TOC entry 456 (class 1255 OID 68618)
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
-- TOC entry 458 (class 1255 OID 68619)
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
-- TOC entry 459 (class 1255 OID 68625)
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
-- TOC entry 460 (class 1255 OID 68624)
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
-- TOC entry 457 (class 1255 OID 68626)
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
-- TOC entry 462 (class 1255 OID 68627)
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
-- TOC entry 461 (class 1255 OID 68628)
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
-- TOC entry 463 (class 1255 OID 68629)
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
-- TOC entry 464 (class 1255 OID 68630)
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
-- TOC entry 455 (class 1255 OID 68631)
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
-- TOC entry 345 (class 1255 OID 67800)
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
-- TOC entry 454 (class 1255 OID 68632)
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
-- TOC entry 452 (class 1255 OID 68633)
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
-- TOC entry 465 (class 1255 OID 68634)
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
-- TOC entry 467 (class 1255 OID 68635)
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
-- TOC entry 382 (class 1255 OID 67804)
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
-- TOC entry 383 (class 1255 OID 67805)
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
-- TOC entry 470 (class 1255 OID 68636)
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
-- TOC entry 471 (class 1255 OID 68637)
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
-- TOC entry 472 (class 1255 OID 68638)
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
-- TOC entry 473 (class 1255 OID 68639)
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
-- TOC entry 475 (class 1255 OID 68640)
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
-- TOC entry 477 (class 1255 OID 68641)
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
-- TOC entry 385 (class 1255 OID 67812)
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
-- TOC entry 478 (class 1255 OID 68642)
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
-- TOC entry 479 (class 1255 OID 68643)
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
-- TOC entry 480 (class 1255 OID 68644)
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
-- TOC entry 481 (class 1255 OID 68645)
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
-- TOC entry 483 (class 1255 OID 68646)
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
-- TOC entry 484 (class 1255 OID 68647)
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
-- TOC entry 476 (class 1255 OID 68649)
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
-- TOC entry 474 (class 1255 OID 68648)
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
-- TOC entry 488 (class 1255 OID 68650)
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
-- TOC entry 490 (class 1255 OID 68651)
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
-- TOC entry 492 (class 1255 OID 68652)
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
-- TOC entry 493 (class 1255 OID 68653)
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
-- TOC entry 494 (class 1255 OID 68654)
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
-- TOC entry 495 (class 1255 OID 68655)
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
-- TOC entry 496 (class 1255 OID 68656)
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
-- TOC entry 499 (class 1255 OID 68657)
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
-- TOC entry 498 (class 1255 OID 68658)
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
-- TOC entry 497 (class 1255 OID 68659)
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
-- TOC entry 501 (class 1255 OID 68660)
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
-- TOC entry 502 (class 1255 OID 68661)
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
-- TOC entry 503 (class 1255 OID 68671)
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
-- TOC entry 500 (class 1255 OID 68672)
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
-- TOC entry 505 (class 1255 OID 68673)
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
-- TOC entry 504 (class 1255 OID 68674)
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
-- TOC entry 388 (class 1255 OID 67837)
-- Name: fn_ingresartelefonopersona(integer, integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresartelefonopersona(p_idempresa integer, p_idtelefono integer, p_idpersona integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

Begin

INSERT INTO negocio."TelefonoPersona"(
            idtelefono, idpersona, idempresa)
    VALUES (p_idtelefono, p_idpersona, p_idempresa);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresartelefonopersona(p_idempresa integer, p_idtelefono integer, p_idpersona integer) OWNER TO postgres;

--
-- TOC entry 466 (class 1255 OID 68675)
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
-- TOC entry 468 (class 1255 OID 68676)
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
-- TOC entry 389 (class 1255 OID 67840)
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
-- TOC entry 390 (class 1255 OID 67841)
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
-- TOC entry 391 (class 1255 OID 67842)
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
-- TOC entry 392 (class 1255 OID 67843)
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
-- TOC entry 393 (class 1255 OID 67844)
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
-- TOC entry 394 (class 1255 OID 67845)
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
-- TOC entry 395 (class 1255 OID 67846)
-- Name: fn_listardocumentosadicionales(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listardocumentosadicionales(p_idempresa integer, p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT das.id, idservicio, idtipodocumento, tm.nombre as nombredocumento, descripciondocumento, archivo, nombrearchivo, tipocontenido, 
       extensionarchivo, usuariocreacion, fechacreacion, ipcreacion, 
       usuariomodificacion, fechamodificacion, ipmodificacion, idestadoregistro
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
-- TOC entry 396 (class 1255 OID 67847)
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
   AND idempresa        = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarmaestroservicios(p_idempresa integer) OWNER TO postgres;

--
-- TOC entry 397 (class 1255 OID 67848)
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
   AND idempresa        = p_idempresa;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarmaestroserviciosadm(p_idempresa integer) OWNER TO postgres;

--
-- TOC entry 398 (class 1255 OID 67849)
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
-- TOC entry 399 (class 1255 OID 67850)
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
-- TOC entry 400 (class 1255 OID 67851)
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
-- TOC entry 401 (class 1255 OID 67852)
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
-- TOC entry 402 (class 1255 OID 67853)
-- Name: fn_listarpagos(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarpagos(p_idempresa integer, p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT idpago, idservicio, ps.idformapago, tmfp.nombre as nombreformapago, fechapago, montopagado, sustentopago, nombrearchivo, extensionarchivo, tipocontenido, espagodetraccion, espagoretencion, usuariocreacion, 
       fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
       ipmodificacion
  FROM negocio."PagosServicio" ps
 INNER JOIN soporte."Tablamaestra" tmfp ON tmfp.idempresa = p_idempresa AND ps.idformapago = tmfp.id AND tmfp.idmaestro = fn_maestroformapago()
 WHERE idestadoregistro = 1
   AND idempresa        = p_idempresa
   AND idservicio       = p_idservicio
 ORDER BY idpago DESC;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarpagos(p_idempresa integer, p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 403 (class 1255 OID 67854)
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
-- TOC entry 404 (class 1255 OID 67855)
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
   AND idempresa       = p_idempresa
 ORDER BY tc.id DESC;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listartipocambio(p_idempresa integer, p_fecha date) OWNER TO postgres;

--
-- TOC entry 406 (class 1255 OID 67856)
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
-- TOC entry 469 (class 1255 OID 68677)
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
-- TOC entry 482 (class 1255 OID 68678)
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
-- TOC entry 485 (class 1255 OID 68679)
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
-- TOC entry 507 (class 1255 OID 68680)
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
-- TOC entry 506 (class 1255 OID 68681)
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
-- TOC entry 508 (class 1255 OID 68682)
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

-- 1: ingreso
-- 2: egreso
if p_idformapago = 2 then
    v_tipotransaccion = 1;-- deposito en cuenta
    v_desctransaccion = 'Deposito en cuenta';
elsif p_idformapago = 3 then
    v_tipotransaccion = 2;-- transferencia
    v_desctransaccion = 'Transferencia de fondos a cuenta';
end if;

select negocio.fn_registrarmovimientocuenta(p_idempresa, p_idcuentadestino, 1, v_tipotransaccion, v_desctransaccion, p_montopago, null, null, p_usuariocreacion, p_ipcreacion) into v_registramovimiento;

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_registrarpagoservicio(p_idempresa integer, p_idservicio integer, p_idformapago integer, p_idcuentadestino integer, p_idbancotarjeta integer, p_idtipotarjeta integer, p_nombretitular character varying, p_numerotarjeta character varying, p_fechapago date, p_numerooperacion character varying, p_montopago numeric, p_idmoneda integer, p_sustentopago bytea, p_nombrearchivo character varying, p_extensionarchivo character varying, p_tipocontenido character varying, p_comentario character varying, p_espagodetraccion boolean, p_espagoretencion boolean, p_usuariocreacion integer, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 489 (class 1255 OID 68687)
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
-- TOC entry 491 (class 1255 OID 68688)
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
-- TOC entry 408 (class 1255 OID 67866)
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
-- TOC entry 409 (class 1255 OID 67867)
-- Name: fn_telefonosxdireccion(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_telefonosxdireccion(p_idempresa integer, p_iddireccion integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT tel.id, tel.numero, tel.idempresaproveedor, tel.usuariocreacion, tel.fechacreacion, 
       tel.ipcreacion, tel.usuariomodificacion, tel.fechamodificacion, tel.ipmodificacion
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
-- TOC entry 410 (class 1255 OID 67868)
-- Name: fn_telefonosxpersona(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_telefonosxpersona(p_idempresa integer, p_idpersona integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT tel.id, tel.numero, tel.idempresaproveedor, tel.usuariocreacion, tel.fechacreacion, 
       tel.ipcreacion, tel.usuariomodificacion, tel.fechamodificacion, tel.ipmodificacion
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
-- TOC entry 407 (class 1255 OID 67869)
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
-- TOC entry 329 (class 1255 OID 67870)
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
-- TOC entry 330 (class 1255 OID 67871)
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
-- TOC entry 355 (class 1255 OID 67872)
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
-- TOC entry 356 (class 1255 OID 67873)
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
-- TOC entry 372 (class 1255 OID 67874)
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
-- TOC entry 380 (class 1255 OID 67875)
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
-- TOC entry 381 (class 1255 OID 67876)
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
-- TOC entry 384 (class 1255 OID 67877)
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
-- TOC entry 386 (class 1255 OID 67878)
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
-- TOC entry 387 (class 1255 OID 67879)
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
-- TOC entry 405 (class 1255 OID 67880)
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
-- TOC entry 411 (class 1255 OID 67881)
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
-- TOC entry 412 (class 1255 OID 67882)
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
-- TOC entry 413 (class 1255 OID 67883)
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
-- TOC entry 414 (class 1255 OID 67884)
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
-- TOC entry 415 (class 1255 OID 67885)
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
-- TOC entry 416 (class 1255 OID 67886)
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
-- TOC entry 417 (class 1255 OID 67887)
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
-- TOC entry 418 (class 1255 OID 67888)
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
-- TOC entry 419 (class 1255 OID 67889)
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
-- TOC entry 420 (class 1255 OID 67890)
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
-- TOC entry 421 (class 1255 OID 67891)
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
-- TOC entry 509 (class 1255 OID 68693)
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
-- TOC entry 486 (class 1255 OID 68694)
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
       fechamodificacion     = fechahoy,
       ipmodificacion        = p_ipmodificacion
 where id 	             = p_idusuario
   and idempresa             = p_idempresa;

return salida;

end;
$$;


ALTER FUNCTION seguridad.fn_actualizarcredencialvencida(p_idempresa integer, p_idusuario integer, p_credencialnueva character varying, p_usuariomodificacion integer, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 487 (class 1255 OID 68695)
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
-- TOC entry 510 (class 1255 OID 68696)
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
-- TOC entry 422 (class 1255 OID 67896)
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
-- TOC entry 511 (class 1255 OID 68697)
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
-- TOC entry 423 (class 1255 OID 67898)
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
-- TOC entry 424 (class 1255 OID 67899)
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
-- TOC entry 425 (class 1255 OID 67900)
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

SET search_path = soporte, pg_catalog;

--
-- TOC entry 512 (class 1255 OID 68698)
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
-- TOC entry 513 (class 1255 OID 68703)
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
-- TOC entry 514 (class 1255 OID 68704)
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
-- TOC entry 426 (class 1255 OID 67904)
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
-- TOC entry 427 (class 1255 OID 67905)
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
-- TOC entry 428 (class 1255 OID 67906)
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
-- TOC entry 429 (class 1255 OID 67907)
-- Name: fn_consultardestino(integer, integer); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_consultardestino(p_idempresa integer, p_iddestino integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT d.id, d.idcontinente, d.idpais, p.descripcion as descpais, d.codigoiata, d.idtipodestino, d.descripcion as descdestino, 
       d.usuariocreacion, d.fechacreacion, d.ipcreacion, d.usuariomodificacion, 
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
-- TOC entry 430 (class 1255 OID 67908)
-- Name: fn_consultardestinoiata(integer, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_consultardestinoiata(p_idempresa integer, p_codigoiata character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT d.id, d.idcontinente, d.idpais, p.descripcion as descpais, d.codigoiata, d.idtipodestino, d.descripcion as descdestino, 
       d.usuariocreacion, d.fechacreacion, d.ipcreacion, d.usuariomodificacion, 
       d.fechamodificacion, d.ipmodificacion, p.abreviado
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
-- TOC entry 516 (class 1255 OID 68705)
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
-- TOC entry 517 (class 1255 OID 68707)
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
-- TOC entry 515 (class 1255 OID 68706)
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
-- TOC entry 521 (class 1255 OID 68708)
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
-- TOC entry 518 (class 1255 OID 68709)
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
-- TOC entry 519 (class 1255 OID 68710)
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
-- TOC entry 520 (class 1255 OID 68711)
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
-- TOC entry 431 (class 1255 OID 67916)
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
-- TOC entry 432 (class 1255 OID 67917)
-- Name: fn_listardestinos(integer); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_listardestinos(p_idempresa integer) RETURNS refcursor
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
-- TOC entry 433 (class 1255 OID 67918)
-- Name: fn_listarpaises(integer, integer); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_listarpaises(p_idempresa integer, p_idcontinente integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT id, descripcion, idcontinente, usuariocreacion, fechacreacion, 
       ipcreacion, usuariomodificacion, fechamodificacion, ipmodificacion, 
       idestadoregistro
  FROM soporte.pais
 WHERE idcontinente = coalesce(p_idcontinente,idcontinente)
   AND idempresa    = p_idempresa
 ORDER BY descripcion ASC;

return micursor;

end;
$$;


ALTER FUNCTION soporte.fn_listarpaises(p_idempresa integer, p_idcontinente integer) OWNER TO postgres;

--
-- TOC entry 434 (class 1255 OID 67919)
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
-- TOC entry 522 (class 1255 OID 68712)
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
-- TOC entry 435 (class 1255 OID 67921)
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
-- TOC entry 174 (class 1259 OID 67922)
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
-- TOC entry 175 (class 1259 OID 67926)
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
-- TOC entry 176 (class 1259 OID 67928)
-- Name: Contrato; Type: TABLE; Schema: licencia; Owner: postgres; Tablespace: 
--

CREATE TABLE "Contrato" (
    id integer NOT NULL,
    fechainicio date NOT NULL,
    fechafin date NOT NULL,
    precioxusuario numeric(12,2) NOT NULL,
    nrousuarios integer
);


ALTER TABLE licencia."Contrato" OWNER TO postgres;

--
-- TOC entry 177 (class 1259 OID 67931)
-- Name: Empresa; Type: TABLE; Schema: licencia; Owner: postgres; Tablespace: 
--

CREATE TABLE "Empresa" (
    id integer NOT NULL,
    razonsocial character varying(100) NOT NULL,
    nombrecomercial character varying(100),
    nombredominio character varying(100) NOT NULL,
    idtipodocumento integer,
    numerodocumento character varying(15)
);


ALTER TABLE licencia."Empresa" OWNER TO postgres;

SET search_path = negocio, pg_catalog;

--
-- TOC entry 178 (class 1259 OID 67934)
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
-- TOC entry 179 (class 1259 OID 67938)
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
-- TOC entry 180 (class 1259 OID 67945)
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
-- TOC entry 181 (class 1259 OID 67949)
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
-- TOC entry 182 (class 1259 OID 67953)
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
-- TOC entry 183 (class 1259 OID 67958)
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
-- TOC entry 184 (class 1259 OID 67965)
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
-- TOC entry 185 (class 1259 OID 67970)
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
-- TOC entry 186 (class 1259 OID 67978)
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
-- TOC entry 187 (class 1259 OID 67982)
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
-- TOC entry 188 (class 1259 OID 67989)
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
-- TOC entry 189 (class 1259 OID 67996)
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
-- TOC entry 190 (class 1259 OID 68000)
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
-- TOC entry 191 (class 1259 OID 68016)
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
-- TOC entry 192 (class 1259 OID 68021)
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
    idempresa integer NOT NULL
);


ALTER TABLE negocio."ObligacionesXPagar" OWNER TO postgres;

--
-- TOC entry 193 (class 1259 OID 68025)
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
-- TOC entry 194 (class 1259 OID 68032)
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
-- TOC entry 195 (class 1259 OID 68039)
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
-- TOC entry 196 (class 1259 OID 68043)
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
-- TOC entry 197 (class 1259 OID 68047)
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
-- TOC entry 198 (class 1259 OID 68051)
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
-- TOC entry 199 (class 1259 OID 68055)
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
-- TOC entry 200 (class 1259 OID 68059)
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
-- TOC entry 201 (class 1259 OID 68063)
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
-- TOC entry 202 (class 1259 OID 68070)
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
-- TOC entry 203 (class 1259 OID 68074)
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
-- TOC entry 204 (class 1259 OID 68078)
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
-- TOC entry 205 (class 1259 OID 68085)
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
-- TOC entry 206 (class 1259 OID 68089)
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
-- TOC entry 207 (class 1259 OID 68093)
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
-- TOC entry 208 (class 1259 OID 68102)
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
-- TOC entry 209 (class 1259 OID 68113)
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
-- TOC entry 210 (class 1259 OID 68117)
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
-- TOC entry 270 (class 1259 OID 68552)
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
-- TOC entry 271 (class 1259 OID 68558)
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
-- TOC entry 272 (class 1259 OID 68564)
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
-- TOC entry 273 (class 1259 OID 68570)
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
-- TOC entry 274 (class 1259 OID 68579)
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
-- TOC entry 211 (class 1259 OID 68144)
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
-- TOC entry 212 (class 1259 OID 68146)
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
-- TOC entry 213 (class 1259 OID 68148)
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
-- TOC entry 214 (class 1259 OID 68150)
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
-- TOC entry 215 (class 1259 OID 68152)
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
-- TOC entry 216 (class 1259 OID 68154)
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
-- TOC entry 217 (class 1259 OID 68156)
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
-- TOC entry 218 (class 1259 OID 68158)
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
-- TOC entry 219 (class 1259 OID 68160)
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
-- TOC entry 220 (class 1259 OID 68162)
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
-- TOC entry 221 (class 1259 OID 68164)
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
-- TOC entry 222 (class 1259 OID 68166)
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
-- TOC entry 223 (class 1259 OID 68168)
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
-- TOC entry 224 (class 1259 OID 68170)
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
-- TOC entry 225 (class 1259 OID 68172)
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
-- TOC entry 226 (class 1259 OID 68174)
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
-- TOC entry 227 (class 1259 OID 68176)
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
-- TOC entry 228 (class 1259 OID 68178)
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
-- TOC entry 229 (class 1259 OID 68180)
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
-- TOC entry 230 (class 1259 OID 68182)
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
-- TOC entry 231 (class 1259 OID 68184)
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
-- TOC entry 232 (class 1259 OID 68186)
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
-- TOC entry 233 (class 1259 OID 68188)
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
-- TOC entry 234 (class 1259 OID 68190)
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
-- TOC entry 235 (class 1259 OID 68192)
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
-- TOC entry 236 (class 1259 OID 68194)
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
-- TOC entry 237 (class 1259 OID 68196)
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
-- TOC entry 238 (class 1259 OID 68198)
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
-- TOC entry 239 (class 1259 OID 68200)
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
-- TOC entry 240 (class 1259 OID 68202)
-- Name: vw_clientesnova; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_clientesnova AS
    SELECT per.id, per.idtipopersona, per.nombres, per.apellidopaterno, per.apellidomaterno, per.idgenero, per.idestadocivil, per.idtipodocumento, per.numerodocumento, per.idusuariocreacion, per.fechacreacion, per.ipcreacion, per.idusuariomodificacion, per.fechamodificacion, per.ipmodificacion, per.idestadoregistro, per.fecnacimiento, per.idempresa FROM "Persona" per WHERE ((per.idestadoregistro = 1) AND (per.idtipopersona = 1));


ALTER TABLE negocio.vw_clientesnova OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 68206)
-- Name: vw_consultacontacto; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_consultacontacto AS
    SELECT pro.id, pro.nombres, pro.apellidopaterno, pro.apellidomaterno, pro.idgenero, pro.idestadocivil, pro.idtipodocumento, pro.numerodocumento, pro.idusuariocreacion, pro.fechacreacion, pro.ipcreacion, pro.idempresa FROM "Persona" pro WHERE ((pro.idtipopersona = 3) AND (pro.idestadoregistro = 1));


ALTER TABLE negocio.vw_consultacontacto OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 68210)
-- Name: vw_consultacorreocontacto; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_consultacorreocontacto AS
    SELECT cor.id, cor.correo, cor.idpersona, cor.recibirpromociones, cor.idusuariocreacion, cor.fechacreacion, cor.ipcreacion, cor.idusuariomodificacion, cor.fechamodificacion, cor.ipmodificacion, cor.idempresa FROM "CorreoElectronico" cor WHERE (cor.idestadoregistro = 1);


ALTER TABLE negocio.vw_consultacorreocontacto OWNER TO postgres;

SET search_path = soporte, pg_catalog;

--
-- TOC entry 243 (class 1259 OID 68214)
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
-- TOC entry 244 (class 1259 OID 68218)
-- Name: vw_consultadireccionproveedor; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_consultadireccionproveedor AS
    SELECT dir.id, dir.idvia, dir.nombrevia, dir.numero, dir.interior, dir.manzana, dir.lote, dir.principal, dir.idubigeo, dir.idusuariocreacion, dir.fechacreacion, dir.ipcreacion, dir.idpais, dep.iddepartamento, dep.descripcion AS departamento, pro.idprovincia, pro.descripcion AS provincia, dis.iddistrito, dis.descripcion AS distrito, pdir.idpersona, dir.observacion, dir.referencia, dir.idempresa FROM (((("Direccion" dir JOIN "PersonaDireccion" pdir ON (((pdir.idestadoregistro = 1) AND (dir.id = pdir.iddireccion)))) LEFT JOIN soporte.ubigeo dep ON (((((("substring"((dir.idubigeo)::text, 1, 2) || '0000'::text) = (dep.id)::text) AND ((dep.iddepartamento)::text <> '00'::text)) AND ((dep.idprovincia)::text = '00'::text)) AND ((dep.iddistrito)::text = '00'::text)))) LEFT JOIN soporte.ubigeo pro ON (((((("substring"((dir.idubigeo)::text, 1, 4) || '00'::text) = (pro.id)::text) AND ((pro.iddepartamento)::text <> '00'::text)) AND ((pro.idprovincia)::text <> '00'::text)) AND ((pro.iddistrito)::text = '00'::text)))) LEFT JOIN soporte.ubigeo dis ON (((dis.id)::bpchar = dir.idubigeo))) WHERE (dir.idestadoregistro = 1);


ALTER TABLE negocio.vw_consultadireccionproveedor OWNER TO postgres;

SET search_path = soporte, pg_catalog;

--
-- TOC entry 245 (class 1259 OID 68223)
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
-- TOC entry 246 (class 1259 OID 68227)
-- Name: vw_consultaproveedor; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_consultaproveedor AS
    SELECT pro.id, pro.nombres, pro.apellidopaterno, pro.apellidomaterno, pper.nombrecomercial, pro.idgenero, pro.idestadocivil, pro.idtipodocumento, pro.numerodocumento, pro.idusuariocreacion, pro.fechacreacion, pro.ipcreacion, ppro.idrubro, pper.idtipoproveedor, pro.idnacionalidad, pai.descripcion AS descnacionalidad, pro.idempresa FROM ((("Persona" pro JOIN "PersonaAdicional" ppro ON (((ppro.idestadoregistro = 1) AND (pro.idtipopersona = public.fn_tipopersonaproveedor())))) JOIN "ProveedorPersona" pper ON (((pro.id = ppro.idpersona) AND (pper.idproveedor = pro.id)))) LEFT JOIN soporte.pais pai ON ((pro.idnacionalidad = pai.id))) WHERE (pro.idestadoregistro = 1);


ALTER TABLE negocio.vw_consultaproveedor OWNER TO postgres;

SET search_path = soporte, pg_catalog;

--
-- TOC entry 247 (class 1259 OID 68232)
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
-- TOC entry 248 (class 1259 OID 68237)
-- Name: vw_contactoproveedor; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_contactoproveedor AS
    SELECT con.id, con.nombres, con.apellidopaterno, con.apellidomaterno, con.idgenero, con.idestadocivil, con.idtipodocumento, con.numerodocumento, con.idusuariocreacion, con.fechacreacion, con.ipcreacion, pcpro.idproveedor, pcpro.idarea, area.nombre, pcpro.anexo, con.idempresa FROM "Persona" con, ("PersonaContactoProveedor" pcpro LEFT JOIN soporte."Tablamaestra" area ON ((((pcpro.idarea = area.id) AND (area.estado = 'A'::bpchar)) AND (area.idmaestro = 4)))) WHERE ((((con.idestadoregistro = 1) AND (pcpro.idestadoregistro = 1)) AND (con.idtipopersona = 3)) AND (con.id = pcpro.idcontacto));


ALTER TABLE negocio.vw_contactoproveedor OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 68242)
-- Name: vw_direccioncliente; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_direccioncliente AS
    SELECT dir.id, dir.idvia, tvia.nombre AS nombretipovia, dir.nombrevia, dir.numero, dir.interior, dir.manzana, dir.lote, pdir.idpersona, pdir.idempresa FROM "PersonaDireccion" pdir, "Direccion" dir, soporte."Tablamaestra" tvia WHERE (((((pdir.idestadoregistro = 1) AND (dir.idestadoregistro = 1)) AND (pdir.iddireccion = dir.id)) AND (tvia.idmaestro = 2)) AND (dir.idvia = tvia.id));


ALTER TABLE negocio.vw_direccioncliente OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 68589)
-- Name: vw_proveedor; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_proveedor AS
    SELECT pro.id AS idproveedor, tdoc.id AS idtipodocumento, tdoc.nombre AS nombretipodocumento, pro.numerodocumento, pro.nombres, pro.apellidopaterno, pro.apellidomaterno, ppro.idrubro, trub.nombre AS nombrerubro, dir.idvia, tvia.nombre AS nombretipovia, dir.nombrevia, dir.numero, dir.interior, dir.manzana, dir.lote, (SELECT tel.numero FROM "TelefonoDireccion" tedir, "Telefono" tel WHERE ((((tedir.idestadoregistro = 1) AND (tel.idestadoregistro = 1)) AND (tedir.iddireccion = dir.id)) AND (tedir.idtelefono = tel.id)) LIMIT 1) AS teledireccion, pro.idempresa FROM "Persona" pro, soporte."Tablamaestra" tdoc, "PersonaAdicional" ppro, soporte."Tablamaestra" trub, (("PersonaDireccion" pdir LEFT JOIN "Direccion" dir ON (((pdir.iddireccion = dir.id) AND ((dir.principal)::text = 'S'::text)))) LEFT JOIN soporte."Tablamaestra" tvia ON (((tvia.idmaestro = 2) AND (dir.idvia = tvia.id)))) WHERE (((((((((((pro.idestadoregistro = 1) AND (pro.idtipopersona = 2)) AND (tdoc.idmaestro = 1)) AND (pro.idtipodocumento = tdoc.id)) AND (pro.id = ppro.idpersona)) AND (trub.idmaestro = 3)) AND (ppro.idestadoregistro = 1)) AND (ppro.idrubro = trub.id)) AND (dir.idestadoregistro = 1)) AND (pdir.idestadoregistro = 1)) AND (pro.id = pdir.idpersona)) ORDER BY pro.nombres, pro.apellidopaterno, pro.apellidomaterno;


ALTER TABLE negocio.vw_proveedor OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 68251)
-- Name: vw_proveedoresnova; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_proveedoresnova AS
    SELECT per.id, per.idtipopersona, per.nombres, per.apellidopaterno, per.apellidomaterno, per.idgenero, per.idestadocivil, per.idtipodocumento, per.numerodocumento, per.idusuariocreacion, per.fechacreacion, per.ipcreacion, per.idusuariomodificacion, per.fechamodificacion, per.ipmodificacion, per.idestadoregistro, per.fecnacimiento, per.idempresa FROM "Persona" per WHERE ((per.idestadoregistro = 1) AND (per.idtipopersona = 2));


ALTER TABLE negocio.vw_proveedoresnova OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 68255)
-- Name: vw_servicio_detalle; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_servicio_detalle AS
    SELECT serdet.cantidad, serdet.descripcionservicio, serdet.fechaida, serdet.fecharegreso, serdet.idmoneda, tmmo.abreviatura, serdet.preciobase, serdet.montototal, serdet.idservicio, serdet.idempresa FROM ("ServicioDetalle" serdet JOIN soporte."Tablamaestra" tmmo ON (((tmmo.idmaestro = 20) AND (serdet.idmoneda = tmmo.id))));


ALTER TABLE negocio.vw_servicio_detalle OWNER TO postgres;

--
-- TOC entry 277 (class 1259 OID 68594)
-- Name: vw_telefonocontacto; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_telefonocontacto AS
    SELECT tel.id, tel.numero, tel.idempresaproveedor, tper.idpersona, tper.idempresa FROM "Telefono" tel, "TelefonoPersona" tper, "Persona" per WHERE ((((((tel.idestadoregistro = 1) AND (tper.idestadoregistro = 1)) AND (tel.id = tper.idtelefono)) AND (per.idestadoregistro = 1)) AND (tper.idpersona = per.id)) AND (per.idtipopersona = 3));


ALTER TABLE negocio.vw_telefonocontacto OWNER TO postgres;

--
-- TOC entry 275 (class 1259 OID 68585)
-- Name: vw_telefonodireccion; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_telefonodireccion AS
    SELECT tel.id, tel.numero, tel.idempresaproveedor, teldir.iddireccion, teldir.idempresa FROM "Telefono" tel, "TelefonoDireccion" teldir WHERE (((tel.idestadoregistro = 1) AND (teldir.idestadoregistro = 1)) AND (tel.id = teldir.idtelefono));


ALTER TABLE negocio.vw_telefonodireccion OWNER TO postgres;

SET search_path = seguridad, pg_catalog;

--
-- TOC entry 252 (class 1259 OID 68268)
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
-- TOC entry 253 (class 1259 OID 68272)
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
-- TOC entry 2822 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN usuario.id; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN usuario.id IS 'identificador de usuario';


--
-- TOC entry 2823 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN usuario.usuario; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN usuario.usuario IS 'usuario de inicio de sesion';


--
-- TOC entry 254 (class 1259 OID 68279)
-- Name: vw_listarusuarios; Type: VIEW; Schema: seguridad; Owner: postgres
--

CREATE VIEW vw_listarusuarios AS
    SELECT u.id, u.usuario, u.credencial, u.id_rol, r.nombre, u.nombres, u.apepaterno, u.apematerno, u.vendedor, u.fecnacimiento, u.cambiarclave, u.feccaducacredencial, u.idempresa FROM usuario u, rol r WHERE (u.id_rol = r.id);


ALTER TABLE seguridad.vw_listarusuarios OWNER TO postgres;

SET search_path = soporte, pg_catalog;

--
-- TOC entry 255 (class 1259 OID 68283)
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
-- TOC entry 256 (class 1259 OID 68287)
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
-- TOC entry 257 (class 1259 OID 68291)
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
-- TOC entry 258 (class 1259 OID 68295)
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
-- TOC entry 259 (class 1259 OID 68299)
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
-- TOC entry 260 (class 1259 OID 68301)
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
-- TOC entry 261 (class 1259 OID 68303)
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
-- TOC entry 262 (class 1259 OID 68305)
-- Name: vw_catalogodepartamento; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_catalogodepartamento AS
    SELECT ubigeo.id, ubigeo.iddepartamento, ubigeo.descripcion, ubigeo.idempresa FROM ubigeo WHERE ((((ubigeo.idprovincia)::text = '00'::text) AND ((ubigeo.iddistrito)::text = '00'::text)) AND ((ubigeo.iddepartamento)::text <> '00'::text));


ALTER TABLE soporte.vw_catalogodepartamento OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 68309)
-- Name: vw_catalogodistrito; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_catalogodistrito AS
    SELECT ubigeo.id, ubigeo.iddepartamento, ubigeo.idprovincia, ubigeo.iddistrito, ubigeo.descripcion, ubigeo.idempresa FROM ubigeo WHERE (((ubigeo.iddepartamento)::text <> '00'::text) AND ((ubigeo.idprovincia)::text <> '00'::text));


ALTER TABLE soporte.vw_catalogodistrito OWNER TO postgres;

--
-- TOC entry 264 (class 1259 OID 68313)
-- Name: vw_catalogomaestro; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_catalogomaestro AS
    SELECT "Tablamaestra".id, "Tablamaestra".idmaestro, "Tablamaestra".nombre, "Tablamaestra".descripcion, "Tablamaestra".idempresa FROM "Tablamaestra" WHERE (("Tablamaestra".idmaestro <> 0) AND ("Tablamaestra".estado = 'A'::bpchar));


ALTER TABLE soporte.vw_catalogomaestro OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 68317)
-- Name: vw_catalogoprovincia; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_catalogoprovincia AS
    SELECT ubigeo.id, ubigeo.iddepartamento, ubigeo.idprovincia, ubigeo.descripcion, ubigeo.idempresa FROM ubigeo WHERE ((((ubigeo.iddistrito)::text = '00'::text) AND ((ubigeo.idprovincia)::text <> '00'::text)) AND ((ubigeo.iddepartamento)::text <> '00'::text));


ALTER TABLE soporte.vw_catalogoprovincia OWNER TO postgres;

--
-- TOC entry 266 (class 1259 OID 68321)
-- Name: vw_listahijosmaestro; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_listahijosmaestro AS
    SELECT "Tablamaestra".id, "Tablamaestra".idmaestro, "Tablamaestra".nombre, "Tablamaestra".descripcion, "Tablamaestra".orden, "Tablamaestra".estado, CASE WHEN ("Tablamaestra".estado = 'A'::bpchar) THEN 'Activo'::text ELSE 'Inactivo'::text END AS descestado, "Tablamaestra".abreviatura, "Tablamaestra".idempresa FROM "Tablamaestra" WHERE ("Tablamaestra".idmaestro <> 0);


ALTER TABLE soporte.vw_listahijosmaestro OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 68325)
-- Name: vw_listamaestros; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_listamaestros AS
    SELECT "Tablamaestra".id, "Tablamaestra".idmaestro, "Tablamaestra".nombre, "Tablamaestra".descripcion, "Tablamaestra".orden, "Tablamaestra".estado, CASE WHEN ("Tablamaestra".estado = 'A'::bpchar) THEN 'ACTIVO'::text ELSE 'INACTIVO'::text END AS descestado, "Tablamaestra".idempresa FROM "Tablamaestra" WHERE ("Tablamaestra".idmaestro = 0);


ALTER TABLE soporte.vw_listamaestros OWNER TO postgres;

--
-- TOC entry 268 (class 1259 OID 68329)
-- Name: vw_listaparametros; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_listaparametros AS
    SELECT "Parametro".id, "Parametro".nombre, "Parametro".descripcion, "Parametro".valor, "Parametro".estado, "Parametro".editable, "Parametro".idempresa FROM "Parametro";


ALTER TABLE soporte.vw_listaparametros OWNER TO postgres;

--
-- TOC entry 269 (class 1259 OID 68333)
-- Name: vw_ubigeo; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_ubigeo AS
    SELECT ubigeo.id, ubigeo.iddepartamento, ubigeo.idprovincia, ubigeo.iddistrito, ubigeo.descripcion, ubigeo.idempresa FROM ubigeo;


ALTER TABLE soporte.vw_ubigeo OWNER TO postgres;

SET search_path = auditoria, pg_catalog;

--
-- TOC entry 2730 (class 0 OID 67922)
-- Dependencies: 174
-- Data for Name: eventosesionsistema; Type: TABLE DATA; Schema: auditoria; Owner: postgres
--

INSERT INTO eventosesionsistema VALUES (165, 2, 'admin@innovaviajes.pe', '2016-01-20 11:29:43.213-05', 1, 1, 2, '2016-01-20 11:29:43.213-05', '127.0.0.1', 2, '2016-01-20 11:29:43.213-05', '127.0.0.1', 1);


--
-- TOC entry 2824 (class 0 OID 0)
-- Dependencies: 175
-- Name: seq_eventosesionsistema; Type: SEQUENCE SET; Schema: auditoria; Owner: postgres
--

SELECT pg_catalog.setval('seq_eventosesionsistema', 165, true);


SET search_path = licencia, pg_catalog;

--
-- TOC entry 2732 (class 0 OID 67928)
-- Dependencies: 176
-- Data for Name: Contrato; Type: TABLE DATA; Schema: licencia; Owner: postgres
--

INSERT INTO "Contrato" VALUES (1, '2016-01-01', '2016-12-31', 5.00, 10);


--
-- TOC entry 2733 (class 0 OID 67931)
-- Dependencies: 177
-- Data for Name: Empresa; Type: TABLE DATA; Schema: licencia; Owner: postgres
--

INSERT INTO "Empresa" VALUES (1, 'Innova Viajes RH', 'Innova Viajes', 'innovaviajes.pe', NULL, NULL);
INSERT INTO "Empresa" VALUES (2, 'Grupo Maral', 'Viajes Terra Nova', 'viajesterranova.com.pe', NULL, NULL);


SET search_path = negocio, pg_catalog;

--
-- TOC entry 2734 (class 0 OID 67934)
-- Dependencies: 178
-- Data for Name: ArchivoCargado; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2735 (class 0 OID 67938)
-- Dependencies: 179
-- Data for Name: ComprobanteAdicional; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2736 (class 0 OID 67945)
-- Dependencies: 180
-- Data for Name: ComprobanteGenerado; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2737 (class 0 OID 67949)
-- Dependencies: 181
-- Data for Name: ComprobanteObligacion; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2738 (class 0 OID 67953)
-- Dependencies: 182
-- Data for Name: CorreoElectronico; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2739 (class 0 OID 67958)
-- Dependencies: 183
-- Data for Name: CronogramaPago; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2740 (class 0 OID 67965)
-- Dependencies: 184
-- Data for Name: CuentaBancaria; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2741 (class 0 OID 67970)
-- Dependencies: 185
-- Data for Name: DetalleArchivoCargado; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2742 (class 0 OID 67978)
-- Dependencies: 186
-- Data for Name: DetalleComprobanteGenerado; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2743 (class 0 OID 67982)
-- Dependencies: 187
-- Data for Name: Direccion; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2744 (class 0 OID 67989)
-- Dependencies: 188
-- Data for Name: DocumentoAdjuntoServicio; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2745 (class 0 OID 67996)
-- Dependencies: 189
-- Data for Name: EventoObsAnuServicio; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2746 (class 0 OID 68000)
-- Dependencies: 190
-- Data for Name: MaestroServicios; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2747 (class 0 OID 68016)
-- Dependencies: 191
-- Data for Name: MovimientoCuenta; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2748 (class 0 OID 68021)
-- Dependencies: 192
-- Data for Name: ObligacionesXPagar; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2749 (class 0 OID 68025)
-- Dependencies: 193
-- Data for Name: PagosObligacion; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2750 (class 0 OID 68032)
-- Dependencies: 194
-- Data for Name: PagosServicio; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2751 (class 0 OID 68039)
-- Dependencies: 195
-- Data for Name: PasajeroServicio; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2752 (class 0 OID 68043)
-- Dependencies: 196
-- Data for Name: Persona; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2753 (class 0 OID 68047)
-- Dependencies: 197
-- Data for Name: PersonaAdicional; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2754 (class 0 OID 68051)
-- Dependencies: 198
-- Data for Name: PersonaContactoProveedor; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2755 (class 0 OID 68055)
-- Dependencies: 199
-- Data for Name: PersonaDireccion; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2756 (class 0 OID 68059)
-- Dependencies: 200
-- Data for Name: Personapotencial; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2757 (class 0 OID 68063)
-- Dependencies: 201
-- Data for Name: ProgramaNovios; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2758 (class 0 OID 68070)
-- Dependencies: 202
-- Data for Name: ProveedorCuentaBancaria; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2759 (class 0 OID 68074)
-- Dependencies: 203
-- Data for Name: ProveedorPersona; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2760 (class 0 OID 68078)
-- Dependencies: 204
-- Data for Name: ProveedorTipoServicio; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2761 (class 0 OID 68085)
-- Dependencies: 205
-- Data for Name: RutaServicio; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2762 (class 0 OID 68089)
-- Dependencies: 206
-- Data for Name: SaldosServicio; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2763 (class 0 OID 68093)
-- Dependencies: 207
-- Data for Name: ServicioCabecera; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2764 (class 0 OID 68102)
-- Dependencies: 208
-- Data for Name: ServicioDetalle; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2765 (class 0 OID 68113)
-- Dependencies: 209
-- Data for Name: ServicioMaestroServicio; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2766 (class 0 OID 68117)
-- Dependencies: 210
-- Data for Name: Telefono; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2808 (class 0 OID 68552)
-- Dependencies: 270
-- Data for Name: TelefonoDireccion; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2809 (class 0 OID 68558)
-- Dependencies: 271
-- Data for Name: TelefonoPersona; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2810 (class 0 OID 68564)
-- Dependencies: 272
-- Data for Name: TipoCambio; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2811 (class 0 OID 68570)
-- Dependencies: 273
-- Data for Name: Tramo; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2812 (class 0 OID 68579)
-- Dependencies: 274
-- Data for Name: TransaccionTipoCambio; Type: TABLE DATA; Schema: negocio; Owner: postgres
--



--
-- TOC entry 2825 (class 0 OID 0)
-- Dependencies: 211
-- Name: seq_archivocargado; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_archivocargado', 1, false);


--
-- TOC entry 2826 (class 0 OID 0)
-- Dependencies: 212
-- Name: seq_comprobanteadicional; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_comprobanteadicional', 1, false);


--
-- TOC entry 2827 (class 0 OID 0)
-- Dependencies: 213
-- Name: seq_comprobantegenerado; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_comprobantegenerado', 5, true);


--
-- TOC entry 2828 (class 0 OID 0)
-- Dependencies: 214
-- Name: seq_consolidador; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_consolidador', 17, true);


--
-- TOC entry 2829 (class 0 OID 0)
-- Dependencies: 215
-- Name: seq_correoelectronico; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_correoelectronico', 49, true);


--
-- TOC entry 2830 (class 0 OID 0)
-- Dependencies: 216
-- Name: seq_cuentabancaria; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_cuentabancaria', 1, false);


--
-- TOC entry 2831 (class 0 OID 0)
-- Dependencies: 217
-- Name: seq_cuentabancariaproveedor; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_cuentabancariaproveedor', 1, false);


--
-- TOC entry 2832 (class 0 OID 0)
-- Dependencies: 218
-- Name: seq_detallearchivocargado; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_detallearchivocargado', 1, false);


--
-- TOC entry 2833 (class 0 OID 0)
-- Dependencies: 219
-- Name: seq_detallecomprobantegenerado; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_detallecomprobantegenerado', 8, true);


--
-- TOC entry 2834 (class 0 OID 0)
-- Dependencies: 220
-- Name: seq_direccion; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_direccion', 74, true);


--
-- TOC entry 2835 (class 0 OID 0)
-- Dependencies: 221
-- Name: seq_documentoservicio; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_documentoservicio', 4, true);


--
-- TOC entry 2836 (class 0 OID 0)
-- Dependencies: 222
-- Name: seq_eventoservicio; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_eventoservicio', 1, false);


--
-- TOC entry 2837 (class 0 OID 0)
-- Dependencies: 223
-- Name: seq_maestroservicio; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_maestroservicio', 13, true);


--
-- TOC entry 2838 (class 0 OID 0)
-- Dependencies: 224
-- Name: seq_movimientocuenta; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_movimientocuenta', 1, false);


--
-- TOC entry 2839 (class 0 OID 0)
-- Dependencies: 225
-- Name: seq_novios; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_novios', 1, false);


--
-- TOC entry 2840 (class 0 OID 0)
-- Dependencies: 226
-- Name: seq_obligacionxpagar; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_obligacionxpagar', 1, false);


--
-- TOC entry 2841 (class 0 OID 0)
-- Dependencies: 227
-- Name: seq_pago; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_pago', 1, false);


--
-- TOC entry 2842 (class 0 OID 0)
-- Dependencies: 228
-- Name: seq_pax; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_pax', 66, true);


--
-- TOC entry 2843 (class 0 OID 0)
-- Dependencies: 229
-- Name: seq_persona; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_persona', 92, true);


--
-- TOC entry 2844 (class 0 OID 0)
-- Dependencies: 230
-- Name: seq_personapotencial; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_personapotencial', 1, false);


--
-- TOC entry 2845 (class 0 OID 0)
-- Dependencies: 231
-- Name: seq_ruta; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_ruta', 24, true);


--
-- TOC entry 2846 (class 0 OID 0)
-- Dependencies: 232
-- Name: seq_salsoservicio; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_salsoservicio', 22, true);


--
-- TOC entry 2847 (class 0 OID 0)
-- Dependencies: 233
-- Name: seq_serviciocabecera; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_serviciocabecera', 27, true);


--
-- TOC entry 2848 (class 0 OID 0)
-- Dependencies: 234
-- Name: seq_serviciodetalle; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_serviciodetalle', 119, true);


--
-- TOC entry 2849 (class 0 OID 0)
-- Dependencies: 235
-- Name: seq_serviciosnovios; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_serviciosnovios', 1, false);


--
-- TOC entry 2850 (class 0 OID 0)
-- Dependencies: 236
-- Name: seq_telefono; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_telefono', 140, true);


--
-- TOC entry 2851 (class 0 OID 0)
-- Dependencies: 237
-- Name: seq_tipocambio; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_tipocambio', 4, true);


--
-- TOC entry 2852 (class 0 OID 0)
-- Dependencies: 238
-- Name: seq_tramo; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_tramo', 55, true);


--
-- TOC entry 2853 (class 0 OID 0)
-- Dependencies: 239
-- Name: seq_transacciontipocambio; Type: SEQUENCE SET; Schema: negocio; Owner: postgres
--

SELECT pg_catalog.setval('seq_transacciontipocambio', 1, false);


SET search_path = seguridad, pg_catalog;

--
-- TOC entry 2799 (class 0 OID 68268)
-- Dependencies: 252
-- Data for Name: rol; Type: TABLE DATA; Schema: seguridad; Owner: postgres
--

INSERT INTO rol VALUES (1, 'Administrador', 1, 2, '2016-01-01 00:00:00-05', '0.0.0.0', 2, '2016-01-01 00:00:00-05', '0.0.0.0', 1);


--
-- TOC entry 2800 (class 0 OID 68272)
-- Dependencies: 253
-- Data for Name: usuario; Type: TABLE DATA; Schema: seguridad; Owner: postgres
--

INSERT INTO usuario VALUES (2, 'admin@innovaviajes.pe', 'F9jP2jxpZxi1Pi9dPuNQeA==', 1, 'Administrador', 'Innova Viajes', NULL, '2016-01-20', false, false, '2017-01-01', 1, 2, '2016-01-01 00:00:00-05', '0.0.0.0', 2, '2016-01-01 00:00:00-05', '0.0.0.0', 1);


SET search_path = soporte, pg_catalog;

--
-- TOC entry 2801 (class 0 OID 68283)
-- Dependencies: 255
-- Data for Name: ConfiguracionTipoServicio; Type: TABLE DATA; Schema: soporte; Owner: postgres
--



--
-- TOC entry 2802 (class 0 OID 68287)
-- Dependencies: 256
-- Data for Name: Parametro; Type: TABLE DATA; Schema: soporte; Owner: postgres
--



--
-- TOC entry 2798 (class 0 OID 68232)
-- Dependencies: 247
-- Data for Name: Tablamaestra; Type: TABLE DATA; Schema: soporte; Owner: postgres
--



--
-- TOC entry 2803 (class 0 OID 68291)
-- Dependencies: 257
-- Data for Name: TipoCambio; Type: TABLE DATA; Schema: soporte; Owner: postgres
--



--
-- TOC entry 2804 (class 0 OID 68295)
-- Dependencies: 258
-- Data for Name: destino; Type: TABLE DATA; Schema: soporte; Owner: postgres
--



--
-- TOC entry 2797 (class 0 OID 68223)
-- Dependencies: 245
-- Data for Name: pais; Type: TABLE DATA; Schema: soporte; Owner: postgres
--



--
-- TOC entry 2854 (class 0 OID 0)
-- Dependencies: 259
-- Name: seq_comun; Type: SEQUENCE SET; Schema: soporte; Owner: postgres
--

SELECT pg_catalog.setval('seq_comun', 215, true);


--
-- TOC entry 2855 (class 0 OID 0)
-- Dependencies: 260
-- Name: seq_destino; Type: SEQUENCE SET; Schema: soporte; Owner: postgres
--

SELECT pg_catalog.setval('seq_destino', 26, true);


--
-- TOC entry 2856 (class 0 OID 0)
-- Dependencies: 261
-- Name: seq_pais; Type: SEQUENCE SET; Schema: soporte; Owner: postgres
--

SELECT pg_catalog.setval('seq_pais', 26, true);


--
-- TOC entry 2796 (class 0 OID 68214)
-- Dependencies: 243
-- Data for Name: ubigeo; Type: TABLE DATA; Schema: soporte; Owner: postgres
--



SET search_path = auditoria, pg_catalog;

--
-- TOC entry 2478 (class 2606 OID 68338)
-- Name: pk_iniciosesion; Type: CONSTRAINT; Schema: auditoria; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY eventosesionsistema
    ADD CONSTRAINT pk_iniciosesion PRIMARY KEY (id);


SET search_path = licencia, pg_catalog;

--
-- TOC entry 2480 (class 2606 OID 68340)
-- Name: pk_contrato; Type: CONSTRAINT; Schema: licencia; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Contrato"
    ADD CONSTRAINT pk_contrato PRIMARY KEY (id);


--
-- TOC entry 2482 (class 2606 OID 68342)
-- Name: pk_empresa; Type: CONSTRAINT; Schema: licencia; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Empresa"
    ADD CONSTRAINT pk_empresa PRIMARY KEY (id);


SET search_path = negocio, pg_catalog;

--
-- TOC entry 2520 (class 2606 OID 68344)
-- Name: cons_uniq_idpersona; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Persona"
    ADD CONSTRAINT cons_uniq_idpersona UNIQUE (id);


--
-- TOC entry 2484 (class 2606 OID 68346)
-- Name: pk_archivocargado; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ArchivoCargado"
    ADD CONSTRAINT pk_archivocargado PRIMARY KEY (id);


--
-- TOC entry 2486 (class 2606 OID 68348)
-- Name: pk_comprobanteadicional; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ComprobanteAdicional"
    ADD CONSTRAINT pk_comprobanteadicional PRIMARY KEY (id);


--
-- TOC entry 2488 (class 2606 OID 68350)
-- Name: pk_comprobantegenerado; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ComprobanteGenerado"
    ADD CONSTRAINT pk_comprobantegenerado PRIMARY KEY (id);


--
-- TOC entry 2490 (class 2606 OID 68352)
-- Name: pk_comprobanteobligacion; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ComprobanteObligacion"
    ADD CONSTRAINT pk_comprobanteobligacion PRIMARY KEY (idcomprobante, idobligacion, iddetalleservicio, idservicio);


--
-- TOC entry 2492 (class 2606 OID 68354)
-- Name: pk_correoelectronico; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "CorreoElectronico"
    ADD CONSTRAINT pk_correoelectronico PRIMARY KEY (id);


--
-- TOC entry 2494 (class 2606 OID 68356)
-- Name: pk_cronogramapago; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "CronogramaPago"
    ADD CONSTRAINT pk_cronogramapago PRIMARY KEY (nrocuota, idservicio);


--
-- TOC entry 2496 (class 2606 OID 68358)
-- Name: pk_cuentabancaria; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "CuentaBancaria"
    ADD CONSTRAINT pk_cuentabancaria PRIMARY KEY (id);


--
-- TOC entry 2498 (class 2606 OID 68360)
-- Name: pk_detallearchivocargado; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "DetalleArchivoCargado"
    ADD CONSTRAINT pk_detallearchivocargado PRIMARY KEY (id);


--
-- TOC entry 2500 (class 2606 OID 68362)
-- Name: pk_detallecomprobante; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "DetalleComprobanteGenerado"
    ADD CONSTRAINT pk_detallecomprobante PRIMARY KEY (id);


--
-- TOC entry 2502 (class 2606 OID 68364)
-- Name: pk_direccion; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Direccion"
    ADD CONSTRAINT pk_direccion PRIMARY KEY (id);


--
-- TOC entry 2504 (class 2606 OID 68366)
-- Name: pk_documentosadjuntosservicio; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "DocumentoAdjuntoServicio"
    ADD CONSTRAINT pk_documentosadjuntosservicio PRIMARY KEY (id);


--
-- TOC entry 2506 (class 2606 OID 68368)
-- Name: pk_eventoobsanuservicio; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "EventoObsAnuServicio"
    ADD CONSTRAINT pk_eventoobsanuservicio PRIMARY KEY (id);


--
-- TOC entry 2508 (class 2606 OID 68370)
-- Name: pk_maestroservicios; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "MaestroServicios"
    ADD CONSTRAINT pk_maestroservicios PRIMARY KEY (id);


--
-- TOC entry 2510 (class 2606 OID 68372)
-- Name: pk_movimientocuenta; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "MovimientoCuenta"
    ADD CONSTRAINT pk_movimientocuenta PRIMARY KEY (id);


--
-- TOC entry 2512 (class 2606 OID 68374)
-- Name: pk_obligacionesxpagar; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ObligacionesXPagar"
    ADD CONSTRAINT pk_obligacionesxpagar PRIMARY KEY (id);


--
-- TOC entry 2514 (class 2606 OID 68376)
-- Name: pk_pagoobligacion; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PagosObligacion"
    ADD CONSTRAINT pk_pagoobligacion PRIMARY KEY (idpago);


--
-- TOC entry 2516 (class 2606 OID 68378)
-- Name: pk_pagosservicio; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PagosServicio"
    ADD CONSTRAINT pk_pagosservicio PRIMARY KEY (idpago);


--
-- TOC entry 2518 (class 2606 OID 68380)
-- Name: pk_pasajeroservicio; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PasajeroServicio"
    ADD CONSTRAINT pk_pasajeroservicio PRIMARY KEY (id);


--
-- TOC entry 2522 (class 2606 OID 68382)
-- Name: pk_persona; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Persona"
    ADD CONSTRAINT pk_persona PRIMARY KEY (id, idtipopersona);


--
-- TOC entry 2526 (class 2606 OID 68384)
-- Name: pk_personacontactoproveedor; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PersonaContactoProveedor"
    ADD CONSTRAINT pk_personacontactoproveedor PRIMARY KEY (idproveedor, idcontacto);


--
-- TOC entry 2528 (class 2606 OID 68386)
-- Name: pk_personadireccion; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PersonaDireccion"
    ADD CONSTRAINT pk_personadireccion PRIMARY KEY (idpersona, iddireccion, idtipopersona);


--
-- TOC entry 2530 (class 2606 OID 68388)
-- Name: pk_personapotencial; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Personapotencial"
    ADD CONSTRAINT pk_personapotencial PRIMARY KEY (id);


--
-- TOC entry 2524 (class 2606 OID 68390)
-- Name: pk_personaproveedor; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PersonaAdicional"
    ADD CONSTRAINT pk_personaproveedor PRIMARY KEY (idpersona);


--
-- TOC entry 2532 (class 2606 OID 68392)
-- Name: pk_programanovios; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ProgramaNovios"
    ADD CONSTRAINT pk_programanovios PRIMARY KEY (id);


--
-- TOC entry 2534 (class 2606 OID 68394)
-- Name: pk_proveedorcuentabancaria; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ProveedorCuentaBancaria"
    ADD CONSTRAINT pk_proveedorcuentabancaria PRIMARY KEY (id);


--
-- TOC entry 2536 (class 2606 OID 68396)
-- Name: pk_proveedorpersona; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ProveedorPersona"
    ADD CONSTRAINT pk_proveedorpersona PRIMARY KEY (idproveedor);


--
-- TOC entry 2538 (class 2606 OID 68398)
-- Name: pk_proveedortiposervicio; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ProveedorTipoServicio"
    ADD CONSTRAINT pk_proveedortiposervicio PRIMARY KEY (idproveedor, idtiposervicio, idproveedorservicio);


--
-- TOC entry 2540 (class 2606 OID 68400)
-- Name: pk_rutaservicio; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "RutaServicio"
    ADD CONSTRAINT pk_rutaservicio PRIMARY KEY (id, idtramo);


--
-- TOC entry 2542 (class 2606 OID 68402)
-- Name: pk_saldosservicio; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "SaldosServicio"
    ADD CONSTRAINT pk_saldosservicio PRIMARY KEY (idsaldoservicio);


--
-- TOC entry 2544 (class 2606 OID 68404)
-- Name: pk_serviciocabecera; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ServicioCabecera"
    ADD CONSTRAINT pk_serviciocabecera PRIMARY KEY (id);


--
-- TOC entry 2548 (class 2606 OID 68406)
-- Name: pk_serviciodepente; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ServicioMaestroServicio"
    ADD CONSTRAINT pk_serviciodepente PRIMARY KEY (idservicio, idserviciodepende);


--
-- TOC entry 2546 (class 2606 OID 68408)
-- Name: pk_serviciodetalle; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "ServicioDetalle"
    ADD CONSTRAINT pk_serviciodetalle PRIMARY KEY (id);


--
-- TOC entry 2550 (class 2606 OID 68410)
-- Name: pk_telefono; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Telefono"
    ADD CONSTRAINT pk_telefono PRIMARY KEY (id);


--
-- TOC entry 2572 (class 2606 OID 68557)
-- Name: pk_telefonodireccion; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "TelefonoDireccion"
    ADD CONSTRAINT pk_telefonodireccion PRIMARY KEY (idtelefono, iddireccion);


--
-- TOC entry 2574 (class 2606 OID 68563)
-- Name: pk_telefonopersona; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "TelefonoPersona"
    ADD CONSTRAINT pk_telefonopersona PRIMARY KEY (idtelefono, idpersona);


--
-- TOC entry 2576 (class 2606 OID 68569)
-- Name: pk_tipocambio; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "TipoCambio"
    ADD CONSTRAINT pk_tipocambio PRIMARY KEY (id, fechatipocambio);


--
-- TOC entry 2578 (class 2606 OID 68578)
-- Name: pk_tramo; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Tramo"
    ADD CONSTRAINT pk_tramo PRIMARY KEY (id);


--
-- TOC entry 2580 (class 2606 OID 68584)
-- Name: pk_transacciontipocambio; Type: CONSTRAINT; Schema: negocio; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "TransaccionTipoCambio"
    ADD CONSTRAINT pk_transacciontipocambio PRIMARY KEY (id);


SET search_path = seguridad, pg_catalog;

--
-- TOC entry 2558 (class 2606 OID 68422)
-- Name: pk_rol; Type: CONSTRAINT; Schema: seguridad; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rol
    ADD CONSTRAINT pk_rol PRIMARY KEY (id);


--
-- TOC entry 2560 (class 2606 OID 68424)
-- Name: pk_usuario; Type: CONSTRAINT; Schema: seguridad; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usuario
    ADD CONSTRAINT pk_usuario PRIMARY KEY (id);


--
-- TOC entry 2562 (class 2606 OID 68426)
-- Name: uq_usuario; Type: CONSTRAINT; Schema: seguridad; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usuario
    ADD CONSTRAINT uq_usuario UNIQUE (usuario);


SET search_path = soporte, pg_catalog;

--
-- TOC entry 2568 (class 2606 OID 68428)
-- Name: cons_uq_iata; Type: CONSTRAINT; Schema: soporte; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY destino
    ADD CONSTRAINT cons_uq_iata UNIQUE (codigoiata);


--
-- TOC entry 2570 (class 2606 OID 68430)
-- Name: pk_destino; Type: CONSTRAINT; Schema: soporte; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY destino
    ADD CONSTRAINT pk_destino PRIMARY KEY (id);


--
-- TOC entry 2554 (class 2606 OID 68432)
-- Name: pk_pais; Type: CONSTRAINT; Schema: soporte; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pais
    ADD CONSTRAINT pk_pais PRIMARY KEY (id);


--
-- TOC entry 2564 (class 2606 OID 68434)
-- Name: pk_parametro; Type: CONSTRAINT; Schema: soporte; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Parametro"
    ADD CONSTRAINT pk_parametro PRIMARY KEY (id);


--
-- TOC entry 2556 (class 2606 OID 68436)
-- Name: pk_tablamaestra; Type: CONSTRAINT; Schema: soporte; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Tablamaestra"
    ADD CONSTRAINT pk_tablamaestra PRIMARY KEY (id, idmaestro);


--
-- TOC entry 2566 (class 2606 OID 68438)
-- Name: pk_tipocambio; Type: CONSTRAINT; Schema: soporte; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "TipoCambio"
    ADD CONSTRAINT pk_tipocambio PRIMARY KEY (id);


--
-- TOC entry 2552 (class 2606 OID 68440)
-- Name: pk_ubigeo; Type: CONSTRAINT; Schema: soporte; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ubigeo
    ADD CONSTRAINT pk_ubigeo PRIMARY KEY (id);


SET search_path = auditoria, pg_catalog;

--
-- TOC entry 2581 (class 2606 OID 68441)
-- Name: fk_eventosesionsistema_usuario; Type: FK CONSTRAINT; Schema: auditoria; Owner: postgres
--

ALTER TABLE ONLY eventosesionsistema
    ADD CONSTRAINT fk_eventosesionsistema_usuario FOREIGN KEY (idusuario) REFERENCES seguridad.usuario(id);


SET search_path = negocio, pg_catalog;

--
-- TOC entry 2583 (class 2606 OID 68446)
-- Name: fk_archivodetallearchivo; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "DetalleArchivoCargado"
    ADD CONSTRAINT fk_archivodetallearchivo FOREIGN KEY (idarchivo) REFERENCES "ArchivoCargado"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2597 (class 2606 OID 68451)
-- Name: fk_cliente1; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "ServicioCabecera"
    ADD CONSTRAINT fk_cliente1 FOREIGN KEY (idcliente1) REFERENCES "Persona"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2598 (class 2606 OID 68456)
-- Name: fk_cliente2; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "ServicioCabecera"
    ADD CONSTRAINT fk_cliente2 FOREIGN KEY (idcliente2) REFERENCES "Persona"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2589 (class 2606 OID 68461)
-- Name: fk_contacto; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "PersonaContactoProveedor"
    ADD CONSTRAINT fk_contacto FOREIGN KEY (idcontacto) REFERENCES "Persona"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2582 (class 2606 OID 68466)
-- Name: fk_correopersona; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "CorreoElectronico"
    ADD CONSTRAINT fk_correopersona FOREIGN KEY (idpersona) REFERENCES "Persona"(id);


--
-- TOC entry 2584 (class 2606 OID 68471)
-- Name: fk_detallecabeceracomprobante; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "DetalleComprobanteGenerado"
    ADD CONSTRAINT fk_detallecabeceracomprobante FOREIGN KEY (idcomprobante) REFERENCES "ComprobanteGenerado"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2591 (class 2606 OID 68476)
-- Name: fk_direccion; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "PersonaDireccion"
    ADD CONSTRAINT fk_direccion FOREIGN KEY (iddireccion) REFERENCES "Direccion"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2600 (class 2606 OID 68666)
-- Name: fk_maestroservicio; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "ServicioMaestroServicio"
    ADD CONSTRAINT fk_maestroservicio FOREIGN KEY (idservicio) REFERENCES "MaestroServicios"(id) ON UPDATE CASCADE;


--
-- TOC entry 2585 (class 2606 OID 68486)
-- Name: fk_obligacionesxpagar; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "PagosObligacion"
    ADD CONSTRAINT fk_obligacionesxpagar FOREIGN KEY (idobligacion) REFERENCES "ObligacionesXPagar"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2587 (class 2606 OID 68491)
-- Name: fk_paxserviciocabecera; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "PasajeroServicio"
    ADD CONSTRAINT fk_paxserviciocabecera FOREIGN KEY (idservicio) REFERENCES "ServicioCabecera"(id);


--
-- TOC entry 2592 (class 2606 OID 68496)
-- Name: fk_persona; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "PersonaDireccion"
    ADD CONSTRAINT fk_persona FOREIGN KEY (idpersona) REFERENCES "Persona"(id);


--
-- TOC entry 2588 (class 2606 OID 68501)
-- Name: fk_personaproveedorpersona; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "PersonaAdicional"
    ADD CONSTRAINT fk_personaproveedorpersona FOREIGN KEY (idpersona) REFERENCES "Persona"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2590 (class 2606 OID 68506)
-- Name: fk_proveedor; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "PersonaContactoProveedor"
    ADD CONSTRAINT fk_proveedor FOREIGN KEY (idproveedor) REFERENCES "Persona"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2593 (class 2606 OID 68511)
-- Name: fk_proveedorcuentabancaria; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "ProveedorCuentaBancaria"
    ADD CONSTRAINT fk_proveedorcuentabancaria FOREIGN KEY (idproveedor) REFERENCES "Persona"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2594 (class 2606 OID 68516)
-- Name: fk_proveedorpersona; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "ProveedorPersona"
    ADD CONSTRAINT fk_proveedorpersona FOREIGN KEY (idproveedor) REFERENCES "Persona"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2595 (class 2606 OID 68521)
-- Name: fk_proveedorservicio; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "ProveedorTipoServicio"
    ADD CONSTRAINT fk_proveedorservicio FOREIGN KEY (idtiposervicio) REFERENCES "MaestroServicios"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2586 (class 2606 OID 68526)
-- Name: fk_servicio; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "PagosServicio"
    ADD CONSTRAINT fk_servicio FOREIGN KEY (idservicio) REFERENCES "ServicioCabecera"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2596 (class 2606 OID 68531)
-- Name: fk_servicio; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "SaldosServicio"
    ADD CONSTRAINT fk_servicio FOREIGN KEY (idservicio) REFERENCES "ServicioCabecera"(id);


--
-- TOC entry 2599 (class 2606 OID 68536)
-- Name: fk_serviciocabecera; Type: FK CONSTRAINT; Schema: negocio; Owner: postgres
--

ALTER TABLE ONLY "ServicioDetalle"
    ADD CONSTRAINT fk_serviciocabecera FOREIGN KEY (idservicio) REFERENCES "ServicioCabecera"(id);


SET search_path = seguridad, pg_catalog;

--
-- TOC entry 2601 (class 2606 OID 68541)
-- Name: fk_usuario_rol; Type: FK CONSTRAINT; Schema: seguridad; Owner: postgres
--

ALTER TABLE ONLY usuario
    ADD CONSTRAINT fk_usuario_rol FOREIGN KEY (id_rol) REFERENCES rol(id);


SET search_path = soporte, pg_catalog;

--
-- TOC entry 2602 (class 2606 OID 68546)
-- Name: fk_configtiposervicio; Type: FK CONSTRAINT; Schema: soporte; Owner: postgres
--

ALTER TABLE ONLY "ConfiguracionTipoServicio"
    ADD CONSTRAINT fk_configtiposervicio FOREIGN KEY (idtiposervicio) REFERENCES negocio."MaestroServicios"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2819 (class 0 OID 0)
-- Dependencies: 12
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2016-01-20 18:26:07

--
-- PostgreSQL database dump complete
--

