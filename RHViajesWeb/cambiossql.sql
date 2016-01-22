alter table negocio."Direccion"
add column idpais integer;

-- Function: negocio.fn_ingresardireccion(integer, character varying, character varying, character varying, character varying, character varying, character varying, character, character varying, character varying, character varying, character varying)

-- DROP FUNCTION negocio.fn_ingresardireccion(integer, character varying, character varying, character varying, character varying, character varying, character varying, character, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION negocio.fn_ingresardireccion(p_idvia integer, p_nombrevia character varying, p_numero character varying, p_interior character varying, 
p_manzana character varying, p_lote character varying, p_principal character varying, p_idubigeo character, p_usuariocreacion character varying, p_ipcreacion character varying, 
p_observacion character varying, p_referencia character varying, p_idpais integer)
  RETURNS integer AS
$BODY$

declare maxdireccion integer;
declare fechahoy timestamp with time zone;

begin

select coalesce(max(id),0)
  into maxdireccion
  from negocio."Direccion";

maxdireccion = nextval('negocio.seq_direccion');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

insert into negocio."Direccion"(id, idvia, nombrevia, numero, interior, manzana, lote, principal, idubigeo, 
            usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
            fechamodificacion, ipmodificacion, observacion, referencia, idpais)
values (maxdireccion,p_idvia,p_nombrevia,p_numero,p_interior,p_manzana,p_lote,p_principal,p_idubigeo,p_usuariocreacion,fechahoy,
	p_ipcreacion,p_usuariocreacion,fechahoy,p_ipcreacion, p_observacion, p_referencia,p_idpais);

return maxdireccion;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

  
-- Function: negocio.fn_actualizardireccion(integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character, character varying, character varying, character varying, character varying)

-- DROP FUNCTION negocio.fn_actualizardireccion(integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION negocio.fn_actualizardireccion(p_id integer, p_idvia integer, p_nombrevia character varying, p_numero character varying, p_interior character varying, 
p_manzana character varying, p_lote character varying, p_principal character varying, p_idubigeo character, p_usuariomodificacion character varying, p_ipmodificacion character varying, 
p_observacion character varying, p_referencia character varying, p_idpais integer)
  RETURNS integer AS
$BODY$
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
   and idestadoregistro = 1;

if cantidad = 1 then
iddireccion           = p_id;
UPDATE 
  negocio."Direccion" 
SET 
  idvia                = p_idvia,
  nombrevia            = p_nombrevia,
  numero               = p_numero,
  interior             = p_interior,
  manzana              = p_manzana,
  lote                 = p_lote,
  principal            = p_principal,
  idubigeo             = p_idubigeo,
  observacion          = p_observacion,
  referencia           = p_referencia,
  usuariomodificacion  = p_usuariomodificacion,
  fechamodificacion    = fechahoy,
  ipmodificacion       = p_ipmodificacion,
  idpais               = p_idpais
WHERE idestadoregistro = 1
  AND id               = iddireccion;

elsif cantidad = 0 then
select 
negocio.fn_ingresardireccion(p_idvia, p_nombrevia, p_numero, p_interior, p_manzana, p_lote, p_principal, p_idubigeo, p_usuariomodificacion, p_ipmodificacion, 
p_observacion, p_referencia, p_idpais)
into iddireccion;

end if;

return iddireccion;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
