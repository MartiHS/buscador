
$(window).load(function() {

    $('#fichas_taxon_IdCAT').soulmate({
        url:            "http://"+ IP + ":" + PORT + "sm/search",
        types:          TYPES,
        renderCallback: render,
        selectCallback: select,
        minQueryLength: 2,
        maxResults:     5,
        timeout:        3500
    });

    $('.campoBusquedaTaxon').on('focus', function (event) {

        // Obtener el id del campo de texto
        tBusqueda = this.id.replace("fichas_taxon_", "");

        // Según el campo de texto, cambiar el tipo de búsqueda
        switch(tBusqueda) {
            case 'IdCAT':
                // Movel el <ul id='soulmate'> al campo de texto seleccionado
                $("#" + this.id).after($("#soulmate"));
                // Movel la indicación
                $("#indicacionAgregarTaxo").css('display', 'block');
                $("#fichas_taxon_IdCAT").after($("#indicacionAgregarTaxo"));
                break;
        }

    });
});


var render = function(term, data, type, index, id) {

    if (I18n.locale == 'es-cientifico') {
        var nombres = '<h5> ' + data.nombre_comun + '</h5>' + '<h5><a href="" class="not-active">' + data.nombre_cientifico + ' </a><i>' + data.autoridad + '</i></h5><h5>&nbsp;</h5>';
        return nombres;
    }else{
        if(data.nombre_comun == null) {
            var nombres = '<a href="" class="not-active">' + data.nombre_cientifico + '</a>';
        }else {
            var nombres = '<b>' + primeraEnMayuscula(data.nombre_comun) + ' </b><sub>' + data.lengua + '</sub><a href="" class="not-active">' + data.nombre_cientifico + '</a>';
        }

        if(data.foto == null) {
            var foto = '<i class="soulmate-img ev1-ev-icon pull-left"></i>';
        }else{
            var foto_url = data.foto;
            var foto = "<i class='soulmate-img pull-left' style='background-image: url(\"" + foto_url + "\")';></i>";
        }

        var iconos = "";
        var ev = '-ev-icon';

        $.each(data.cons_amb_dist, function(i, val){
            if (i == 'no-endemica' || i =='actual') return true;
            iconos = iconos + "<span class='btn-title' tooltip-title='" + val + "'><i class='" + i + ev +"'></i></span>"
        });

        if(data.geodatos != undefined && data.geodatos.length > 0){
            iconos = iconos + "<span class='btn-title' tooltip-title='Tiene datos geográficos'><i class='glyphicon glyphicon-globe'></i></span>";
        }

        if(data.fotos > 0) {
            iconos = iconos + "<span class='btn-title' tooltip-title='Tiene imágenes'><i class='picture-ev-icon'></i><sub>" + data.fotos + "</sub></span>";
        }

        return foto + " " + nombres + "<h5 class='soulmate-icons'>" + iconos + "</h5>";
    }
};

var select = function(term, data, type) {

    $('ul#soulmate').hide();    // esconde el autocomplete cuando escoge uno
    var elemento = 'IdCAT';
    //console.log("\nModificar: " + elemento);

    if(elemento === 'IdCAT')
        set_taxonomy(data.id);
    else {
        var nom_cientifico = data.nombre_cientifico.trim().toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/(^-|-$)/g,'').replace(/[\(\)]/g, '');
        $('#fichas_taxon_' + elemento).attr('value', nom_cientifico).val(data.nombre_cientifico);
    }
    //console.log("---SELECCCIONADO---");
};

function set_taxonomy(especieId) {
    $.ajax({
        url: "http://"+ IP + ":" + PORT + "fichas/taxa/taxonomia_especie/" + especieId,
        context: document.body
    }).done(function(taxonomy) {

        $('#fichas_taxon_IdCAT').attr('value', taxonomy['idCat']).val(taxonomy['idCat']);

        $('#fichas_taxon_reino').val(taxonomy['reino']);


        $('#fichas_taxon_divisionphylum').append($('<option>', {
            value: taxonomy['divisionphylum'],
            text : taxonomy['divisionphylum']
        })).val(taxonomy['divisionphylum']);

        $('#fichas_taxon_clase').append($('<option>', {
            value: taxonomy['clase'],
            text : taxonomy['clase']
        })).val(taxonomy['clase']);

        $('#fichas_taxon_orden').append($('<option>', {
            value: taxonomy['orden'],
            text : taxonomy['orden']
        })).val(taxonomy['orden']);;

        $('#fichas_taxon_familia').append($('<option>', {
            value: taxonomy['familia'],
            text : taxonomy['familia']
        })).val(taxonomy['familia']);

        $('#fichas_taxon_genero').append($('<option>', {
            value: taxonomy['genero'],
            text : taxonomy['genero']
        })).val(taxonomy['genero']);

        $('#fichas_taxon_especie').append($('<option>', {
            value: taxonomy['especie'],
            text : taxonomy['especie']
        })).val(taxonomy['especie']);

        reload('campoBusqueda_Taxon');
        /*
        $('#fichas_taxon_IdCAT').attr('value', taxonomy['idCat']).val(taxonomy['idCat']);
        $('#fichas_taxon_reino').attr('value', taxonomy['reino']).val(taxonomy['reino']);
        $('#fichas_taxon_divisionphylum').attr('value', taxonomy['divisionphylum']).val(taxonomy['divisionphylum']);
        $('#fichas_taxon_clase').attr('value', taxonomy['clase']).val(taxonomy['clase']);
        $('#fichas_taxon_orden').attr('value', taxonomy['orden']).val(taxonomy['orden']);
        $('#fichas_taxon_familia').attr('value', taxonomy['familia']).val(taxonomy['familia']);
        $('#fichas_taxon_genero').attr('value', taxonomy['genero']).val(taxonomy['genero']);
        $('#fichas_taxon_especie').attr('value', taxonomy['especie']).val(taxonomy['especie']);
        */
        return taxonomy;
    });
}

function muestraFiltroTaxo() {
    $('#filtroTaxo').css('display', 'block');
}

function cargaOpciones(elemento, campo) {

    var e = document.getElementById(elemento.id);
    var selectedOp = "";

    if(elemento.id === 'fichas_taxon_reino' ) {

        switch (e.options[e.selectedIndex].value) {
            case 'Animalia':
                selectedOp = 1;
                break;
            case 'Plantae':
                selectedOp = 2;
                break;
            case 'Prokaryotae':
                selectedOp = 3;
                break;
            case 'Fungi':
                selectedOp = 4;
                break;
            default:
                // Protoctista
                selectedOp = 5;
                break;
        }
    } else {
        selectedOp = e.options[e.selectedIndex].getAttribute('idEspecie');
    }

    get_descendientes(selectedOp, campo);

    //console.log(selectedOp);
}

function get_descendientes(especieId, elemento) {
    $.ajax({
        url: "http://"+ IP + ":" + PORT + "fichas/taxa/taxonomia_siguiente/" + especieId,
        context: document.body
    }).done(function(resultados) {

        var select = document.getElementById('fichas_taxon_' + elemento);
        var length = select.options.length;
        for (i = 0; i < length; i++) {
            select.options[i] = null;
        }

        $.each(resultados, function (i, taxo) {
            $('#fichas_taxon_' + elemento).append($('<option>', {
                idEspecie: taxo.id,
                value: taxo.value,
                text : taxo.value
            }));
        });

        reload('campoBusqueda_Taxon');
    });
}