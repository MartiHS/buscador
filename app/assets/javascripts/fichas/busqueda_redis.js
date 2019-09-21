// Función en con la que se llamará a redis y mostrará una lista
$(document).on('focus', '[id^=fichas_taxon_IdCAT]', function() {
    //$('[id^=metamares_proyecto_especies][id$=_nombre_cientifico]').off();
    soulmateBuscaParaFicha('por_IdCAT', this.id);
    console.log(this.id);
});

$(document).on('focus', '[id^=fichas_taxon_reino]', function() {
    //$('[id^=metamares_proyecto_especies][id$=_nombre_cientifico]').off();
    TYPES = eval(['Reino']);
    soulmateBuscaParaFicha('reino', this.id);
    console.log(this.id);
});

$(document).on('focus', '[id^=fichas_taxon_division]', function() {
    //$('[id^=metamares_proyecto_especies][id$=_nombre_cientifico]').off();
    TYPES = eval(['division']);
    soulmateBuscaParaFicha('divisionphylum', this.id);
    console.log(this.id);
});

$(document).on('focus', '[id^=fichas_taxon_clase]', function() {
    //$('[id^=metamares_proyecto_especies][id$=_nombre_cientifico]').off();
    TYPES = eval(['clase']);
    soulmateBuscaParaFicha('clase', this.id);
    console.log(this.id);
});

$(document).on('focus', '[id^=fichas_taxon_orden]', function() {
    //$('[id^=metamares_proyecto_especies][id$=_nombre_cientifico]').off();
    TYPES = eval(['orden']);
    soulmateBuscaParaFicha('orden', this.id);
    console.log(this.id);
});

$(document).on('focus', '[id^=fichas_taxon_familia]', function() {
    //$('[id^=metamares_proyecto_especies][id$=_nombre_cientifico]').off();
    TYPES = eval(['familia']);
    soulmateBuscaParaFicha('familia', this.id);
    console.log(this.id);
});

$(document).on('focus', '[id^=fichas_taxon_genero]', function() {
    //$('[id^=metamares_proyecto_especies][id$=_nombre_cientifico]').off();
    TYPES = eval(['genero']);
    soulmateBuscaParaFicha('genero', this.id);
    console.log(this.id);
});

$(document).on('focus', '[id^=fichas_taxon_especie]', function() {
    //$('[id^=metamares_proyecto_especies][id$=_nombre_cientifico]').off();
    TYPES = eval(['especie']);
    soulmateBuscaParaFicha('especie', this.id);
    console.log(this.id);
});


/**
 * Funcion para atachar que una caja de texto tenga funcionamiento con soulmate y redis
 * @param tipo_busqueda
 */
var soulmateBuscaParaFicha = function(tipo_busqueda, elem)
{
    if (elem == undefined)
        var elemento = 'nombre';
    else
        var elemento = elem;

    var render = function(term, data, type, index, id)
    {
        if (I18n.locale == 'es-cientifico')
        {
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

        if(tipo_busqueda === 'por_IdCAT')
            set_taxonomy(data.id);
        else {
            var nom_cientifico = data.nombre_cientifico.trim().toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/(^-|-$)/g,'').replace(/[\(\)]/g, '');
            $('#fichas_taxon_' + tipo_busqueda).attr('value', nom_cientifico).val(data.nombre_cientifico);
        }
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
};


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

