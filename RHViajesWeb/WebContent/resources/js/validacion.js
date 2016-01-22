
function js_soloEntero(event){
	var code = event.keyCode;
	
	var valida = (parseInt(code) >= 48 && parseInt(code) <= 57);
	
	return valida;
}

function js_soloDecimal(event){
	var code = event.keyCode;
	
	var valida = ((parseInt(code) >= 48 && parseInt(code) <= 57) || parseInt(code) == 46);
	
	return valida;
}

function js_soloCadena(event){
	var code = event.keyCode;
	
	var valida = ((parseInt(code) >= 65 && parseInt(code) <= 90) || (parseInt(code) >= 97 && parseInt(code) <= 122));
	
	return valida;
}