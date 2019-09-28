/* * /
$(document).on('focus', '.campoBusquedaTaxon', function(event) {

    var listeners = [''];

    console.log($('#' + this.id));

    var tBusqueda = this.id.replace("fichas_taxon_", "");

    switch(tBusqueda) {
        case 'IdCAT':
            TYPES = eval('especie,subespecie,variedad,subvariedad,forma,subforma,Reino,subreino,superphylum,division,subdivision,phylum,subphylum,superclase,grado,clase,subclase,infraclase,superorden,orden,suborden,infraorden,superfamilia,familia,subfamilia,supertribu,tribu,subtribu,genero,subgenero,seccion,subseccion,serie,subserie'.split(','));
            break;
        case 'divisionphylum':
            TYPES = eval(['division', 'phylum']);
            break;
        default:
            TYPES = eval([tBusqueda]);
            break;
    }

    var soulmate = $("#soulmate");
    $("#" + this.id).after(soulmate);

    console.log('Se buscará por: ' + TYPES);
    console.log(getEventListeners(document));


    soulmateBuscaParaFicha(tBusqueda, this.id, event);
});

/* */

/* *
 * Funcion para atachar que una caja de texto tenga funcionamiento con soulmate y redis
 * @param tipo_busqueda
 * /
var soulmateBuscaParaFicha = function(tipo_busqueda, elemento, event) {

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
        console.log("\nModificar: " + tipo_busqueda);
        if(tipo_busqueda === 'IdCAT')
            set_taxonomy(data.id);
        else {
            var nom_cientifico = data.nombre_cientifico.trim().toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/(^-|-$)/g,'').replace(/[\(\)]/g, '');
            $('#fichas_taxon_' + tipo_busqueda).attr('value', nom_cientifico).val(data.nombre_cientifico);
        }
        console.log("---SELECCCIONADO---");
    };



    $('#' + elemento).soulmate({
        url:            "http://"+ IP + ":" + PORT + "sm/search",
        types:          TYPES,
        renderCallback: render,
        selectCallback: select,
        minQueryLength: 2,
        maxResults:     5,
        timeout:        3500
    });

    console.log('\n\n.........');
};

/*  - - - - - - - - - - - */

var tBusqueda = '';


$(window).load(function(){



    $('.campoBusquedaTaxon').on('focus', function (event) {

        //event.stopPropagation();
        //event.preventDefault();

        console.log(this.id)

        //$('.campoBusquedaTaxon').off();


        // Obtener el id del campo de texto
        tBusqueda = this.id.replace("fichas_taxon_", "");

        // Movel el <ul id='soulmate'> al campo de texto seleccionado
        $("#" + this.id).after($("#soulmate"));

        console.log('Se buscará por: ' + tBusqueda);

        // Según el campo de texto, cambiar el tipo de búsqueda
        switch(tBusqueda) {
            case 'IdCAT':
                //TYPES = eval('especie,subespecie,variedad,subvariedad,forma,subforma,Reino,subreino,superphylum,division,subdivision,phylum,subphylum,superclase,grado,clase,subclase,infraclase,superorden,orden,suborden,infraorden,superfamilia,familia,subfamilia,supertribu,tribu,subtribu,genero,subgenero,seccion,subseccion,serie,subserie'.split(','));
                buscardorSoulmate.buscaIdCAT(tBusqueda, TYPES).resultados;
                break;
            case 'divisionphylum':
                TYPES = eval(['division', 'phylum']);
                buscardorSoulmate.buscaDivisionphylum(tBusqueda, eval(['division', 'phylum'])).resultados;
                break;
            case 'reino':
                TYPES = eval([tBusqueda]);
                buscardorSoulmate.buscaReino(tBusqueda, eval([tBusqueda])).resultados;
                break;
            case 'clase':
                TYPES = eval([tBusqueda]);
                buscardorSoulmate.buscaClase(tBusqueda, eval([tBusqueda])).resultados;
            default:
                TYPES = eval([tBusqueda]);
                break;
        }



    });


});







var buscardorSoulmate = {
    _porIdCAT: null,
    _porReino: null,
    _porDivisionphylum: null,
    _porClase: null,

    buscaIdCAT: function(tBusqueda, filtro) {
        if (this._porIdCAT===null) {
            this._porIdCAT = { resultados: getSoulmateSearcher(tBusqueda, filtro)}
        }
        return this._porIdCAT;
    },

    buscaReino: function(tBusqueda, filtro) {
        if (this._porReino===null) {
            this._porReino = { resultados: getSoulmateSearcher(tBusqueda, filtro) }
        }
        return this._porReino;
    },

    buscaDivisionphylum: function(tBusqueda, filtro) {
        if (this._porDivisionphylum===null) {
            this._porDivisionphylum = { resultados: getSoulmateSearcher(tBusqueda, filtro)}
        }
        return this._porDivisionphylum;
    },

    buscaClase: function(tBusqueda, filtro) {
        if (this._porClase===null) {
            this._porClase = { resultados: getSoulmateSearcher(tBusqueda, filtro)}
        }
        return this._porClase;
    },

};


function getSoulmateSearcher(elemento, losTypes) {

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
        console.log("\nModificar: " + elemento);
        console.log(elemento);
        console.log(elemento === 'IdCAT');

        if(elemento === 'IdCAT')
            set_taxonomy(data.id);
        else {
            var nom_cientifico = data.nombre_cientifico.trim().toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/(^-|-$)/g,'').replace(/[\(\)]/g, '');
            $('#fichas_taxon_' + elemento).attr('value', nom_cientifico).val(data.nombre_cientifico);
        }
        console.log("---SELECCCIONADO---");
    };

    return $('#fichas_taxon_' + elemento).soulmate({
        url:            "http://"+ IP + ":" + PORT + "sm/search",
        types:          losTypes,
        renderCallback: render,
        selectCallback: select,
        minQueryLength: 2,
        maxResults:     5,
        timeout:        3500
    });
}


function set_taxonomy(especieId) {
    $.ajax({
        url: "http://"+ IP + ":" + PORT + "fichas/taxa/taxonomia_especie/" + especieId,
        context: document.body
    }).done(function(taxonomy) {
        $('#fichas_taxon_IdCAT').attr('value', taxonomy['idCat']).val(taxonomy['idCat']);
        $('#fichas_taxon_reino').attr('value', taxonomy['reino']).val(taxonomy['reino']);
        $('#fichas_taxon_divisionphylum').attr('value', taxonomy['divisionphylum']).val(taxonomy['divisionphylum']);
        $('#fichas_taxon_clase').attr('value', taxonomy['clase']).val(taxonomy['clase']);
        $('#fichas_taxon_orden').attr('value', taxonomy['orden']).val(taxonomy['orden']);
        $('#fichas_taxon_familia').attr('value', taxonomy['familia']).val(taxonomy['familia']);
        $('#fichas_taxon_genero').attr('value', taxonomy['genero']).val(taxonomy['genero']);
        $('#fichas_taxon_especie').attr('value', taxonomy['especie']).val(taxonomy['especie']);
        return taxonomy;
    });
}
