function clicBoton(idBoton) {
	document.getElementById(idBoton).click();
}

function prueba(tttt) {
	alert(tttt);
}
function mostrarModal(idform) {
	try {
		var mostrarModal = document.getElementById('idFormHidden:idShowModal').value;
		var tipoModal = document.getElementById('idFormHidden:idTipoModal').value;

		if (tipoModal == "1" && eval(mostrarModal)) {
			document.getElementById(idform + ':idBotonModalCorrecto').click();
		} else if (tipoModal == "2" && eval(mostrarModal)) {
			document.getElementById(idform + ':idBotonModalError').click();
		}
	} catch (e) {
		// alert("ERROR JS::"+e);
	}
}

function mostrarModalP(idform, boton) {
	document.getElementById(boton).click();
	mostrarModal(idform);

}

function mostrarModalCC(idform) {
	var mostrarModal = document.getElementById('idFormHiddenCC:idShowModal').value;
	var tipoModal = document.getElementById('idFormHiddenCC:idTipoModal').value;

	if (tipoModal == "1" && eval(mostrarModal)) {
		document.getElementById(idform + ':idBotonModalCorrectoCC').click();
	} else if (tipoModal == "2" && eval(mostrarModal)) {
		document.getElementById(idform + ':idBotonModalErrorCC').click();
	}
}

function cerrarModalBoton(idform, idBoton) {
	try {
		var direccionAgregada = document.getElementById(idform + ':idHdDirAgr').value;
		if (eval(direccionAgregada)) {
			document.getElementById(idform + ':' + idBoton).click();
		}
	} catch (e) {
		alert("error ::" + e.message);
	}
}

function cerrarModalBoton(idform, idBoton, idHid) {
	try {
		var direccionAgregada = document.getElementById(idform + ':' + idHid).value;
		if (eval(direccionAgregada)) {
			document.getElementById(idform + ':' + idBoton).click();
		}
	} catch (e) {
		alert("error ::" + e.message);
	}
}

function dataTableSelectOneRadio(radio) {
	var id = radio.name.substring(radio.name.lastIndexOf(':'));
	var el = radio.form.elements;
	for (var i = 0; i < el.length; i++) {
		if (el[i].name.substring(el[i].name.lastIndexOf(':')) == id) {
			el[i].checked = false;
		}
	}
	radio.checked = true;
}

function cerrarModales(modales) {
	var modal = modales.split(",");
	cerrarModal(modal[0]);
}

function mostrarModal2(idform) {
	var mostrarModal = document.getElementById('idFormHidden:idShowModal').value;
	var tipoModal = document.getElementById('idFormHidden:idTipoModal').value;

	if (tipoModal == "1" && eval(mostrarModal)) {
		document.getElementById(idform + ':idBotonModalCorrecto').click();
	} else if (tipoModal == "2" && eval(mostrarModal)) {
		document.getElementById(idform + ':idBotonModalError').click();
	}

	document.getElementById(idform + ':idBotonCierraVista').click();
	document.getElementById(idform + ':idBotonCierraObsAnu').click();
}

function cerrarModal(idmodal) {
	try {
		RichFaces.$(idmodal).hide();
	} catch (e) {

	}
}
function mostrarModal3(idmodal) {
	try {
		RichFaces.$(idmodal).show();
	} catch (e) {

	}
}

function mostrarModalCredencial(idmodal) {
	var credencialvendida = document
			.getElementById('idFrInicio:idTxtHidCredvencida').value;

	if (eval(credencialvendida)) {
		mostrarModal3(idmodal);
	}

}

function mostrarMensajeModal(idModalCerrar) {
	try {
		var mostrarModal = document.getElementById('idFormHidden:idShowModal').value;
		var tipoModal = document.getElementById('idFormHidden:idTipoModal').value;

		if (tipoModal == "1" && eval(mostrarModal)) {
			mostrarModal3('idModalcorrecto');
		} else if (tipoModal == "2" && eval(mostrarModal)) {
			mostrarModal3('idModalError');
		} else {
			if (idModalCerrar != "") {
				cerrarModal(idModalCerrar);
			}
		}

	} catch (e) {
		// alert("ERROR JS::"+e);
	}
}

function mostrarMensajeModal2(idModalCerrar) {
	try {
		var mostrarModal = document.getElementById('idFormHidden:idShowModal').value;
		var tipoModal = document.getElementById('idFormHidden:idTipoModal').value;

		if (tipoModal == "1" && eval(mostrarModal)) {
			mostrarModal3('idModalcorrecto');
		} else if (tipoModal == "2" && eval(mostrarModal)) {
			mostrarModal3('idModalError');
		} 

	} catch (e) {
		// alert("ERROR JS::"+e);
	}
}