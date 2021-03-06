var por_nombre = function()
{
    $("#id").val("");
    $("#datos_cat").html("");
    $("#panelCategoriaTaxonomicaPt").hide();

    $("[id^='id_']").each(function(){
        $(this).prop('checked', false);
    });

    $('#por_gi, #por_nombre_fuente, #por_gi_fuente, #por_nombre').toggle('easeOutBounce');
};

var por_gi = function()
{
    $("#id").val("");
    $("#nombre").val('');
    $("#datos_cat").html("");
    $("#panelCategoriaTaxonomicaPt").hide();

    $('#por_gi, #por_nombre_fuente, #por_gi_fuente, #por_nombre').toggle('easeOutBounce');
};

var cat_tax_asociadas = function(id,nivel,cat)
{
    $.ajax(
        {
            url: "/cat_tax_asociadas",
            type: 'GET',
            data: {
                id: id,
                nivel: nivel,
                cat: cat
            }
        }).done(function(html)
    {
        $('#datos_cat').html('').html(html);
        $('#panelCategoriaTaxonomicaPt').show();
    });
};

var asignaFiltros = function(SET_PARAMS)
{
    // Escogio de grupo iconico
    if (SET_PARAMS.id != undefined && SET_PARAMS.nombre == undefined)
    {
        $('#id_gi_' + SET_PARAMS.id).prop('checked', true);
        $('#id').val(SET_PARAMS.id);

    } else if (SET_PARAMS.nombre != undefined) {
        por_nombre();
        $('#nombre').val(SET_PARAMS.nombre);
    }

    if (SET_PARAMS.por_pagina != undefined) $('#por_pagina').val(SET_PARAMS.por_pagina);

    if (SET_PARAMS.edo_cons != undefined) $('#edo_cons').val(SET_PARAMS.edo_cons);
    if (SET_PARAMS.dist != undefined) $('#dist').val(SET_PARAMS.dist);
    if (SET_PARAMS.uso != undefined) $('#uso').val(SET_PARAMS.uso);
    if (SET_PARAMS.prior != undefined) $('#prior').val(SET_PARAMS.prior);
    if (SET_PARAMS.ambiente != undefined) $('#ambiente').val(SET_PARAMS.ambiente);
    if (SET_PARAMS.reg != undefined) $('#reg').val(SET_PARAMS.reg);

    if (SET_PARAMS.estatus != undefined)
    {
        SET_PARAMS.estatus.forEach(function(valor){
            $('#estatus_' + valor).prop('checked', true);
        });
    }
};

$(document).ready(function()
{
    $('#busqueda_avanzada').on('change', ".radio input", function()
    {
        // El ID del grupo iconico
        var id_gi = $(this).val();
        $('#id').val(id_gi);
        cat_tax_asociadas(id_gi,'','');
    });

    $('#busqueda_avanzada').on('click', '#limpiar', function(){
        window.location.href = "/avanzada";
    });

    $('#busqueda_avanzada').on('click', '#por_nombre_fuente', function(){
        por_nombre();
        return false;
    });

    $('#busqueda_avanzada').on('click', '#por_gi_fuente', function(){
        por_gi();
        return false;
    });

    $('#busqueda_avanzada').on('click', '#boton-enviar-checklist', function(){
        var url = $(this).attr('url');

        if (url == "") return false;
        else window.open(url, '_blank');
    });

    $("#busqueda_avanzada").on('submit', '#b_avanzada', function() {
        $("#por_gi :input").attr("disabled", true);  // Deshabilita los grupos iconicos para que los repita en la URI
    });

    /*
    $(window).on('load', function(){
        $("html,body").animate({scrollTop: 122}, 1000);
    });

     */

    // Para la validacion del correo en la descarga del checklist
    dameValidacionCorreo('checklist', '#notice-avanzada');
});

