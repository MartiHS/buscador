class Fichas::TaxaController < Fichas::FichasController
  before_action :set_taxon, only: [:show, :edit, :update, :destroy]

  # GET /taxa
  # GET /taxa.json
  def index
    @taxa = Fichas::Taxon.all
  end

  # GET /taxa/1
  # GET /taxa/1.json
  def show
  end

  # GET /taxa/new
  def new
    @form_params = { url: '/fichas/taxa', method: 'post' }
    @taxon = Fichas::Taxon.new
    @taxon.habitats = Fichas::Habitat.new
    @taxon.distribuciones.new
    @taxon.endemicas.new
    @taxon.historiaNatural = Fichas::Historianatural.new
    @taxon.demografiaAmenazas = Fichas::Demografiaamenazas.new
    @taxon.conservacion.new
    @taxon.invasividad = Fichas::Invasividad.new
    @taxon.metadatos.new
    @taxon.referenciasBibliograficas.new
  end

  # GET /taxa/1/edit
  def edit
    @form_params = { url: "/fichas/taxa/#{@taxon.IdCAT}", method: 'put' }
  end


  # POST /taxa
  # POST /taxa.json
  def create
    @taxon = Fichas::Taxon.new(taxon_params)

    respond_to do |format|
      if @taxon.save
        format.html { redirect_to @taxon, notice: 'Taxon was successfully created.' }
        format.json { render :show, status: :created, location: @taxon }
      else
        format.html { render :new }
        format.json { render json: @taxon.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /taxa/1
  # PATCH/PUT /taxa/1.json
  def update
    respond_to do |format|
      puts taxon_params.inspect
      if @taxon.update(taxon_params)
        format.html { redirect_to fichas_front_path(@taxon.IdCAT), notice: 'Taxon was successfully updated.' }
        format.json { render :show, status: :ok, location: @taxon }
      else
        format.html { render :edit }
        format.json { render json: @taxon.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /taxa/1
  # DELETE /taxa/1.json
  def destroy
    @taxon.destroy
    respond_to do |format|
      format.html { redirect_to taxa_url, notice: 'Taxon was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_taxon
      begin
        @taxon = Fichas::Taxon.where(IdCat: params[:id]).first
      rescue
        render :_error and return
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def taxon_params
      p = params.require(:fichas_taxon).permit(
          # Parámetros desde taxón:
          :tipoficha,
          :IdCAT,
          # SECCIÓN CLASIFICACIÓN
          :resumenEspecie, :descEspecie, :especiesSmilares, :origen, :descripcionOrigen, :presencia, :adicinalPresencia, :invasora, :adicionalInvasora,
          :largoinicialhembras, :largofinalhembras, :edadinicialhembras, :edadfinalhembras, :tiempoedadhembra, :pesoinicialhembras, :pesofinalhembras,
          :largoinicialmachos, :largofinalmachos, :edadinicialmachos, :edadfinalmachos, :tiempoedadmacho, :pesoinicialmachos, :pesofinalmachos,
          # SECCIÓN ESPECIES PRIORITARIAS
          :prioritaria, :publicadaEn, :nivelPrioridad, :justificacionPrioritaria,
          # SECCIÓN NECESIDADES
          :necesidadesEspecie,

          :id, :_destroy,

          # Opciones multiples que se agregan a Caracteristicaesoecie
          opciones_pregunta_ids: [],

          # OK
          legislaciones_attributes: [
              :legislacionId,
              :especieId,
              :nombreLegislacion,
              :estatusLegalProteccion,
              :infoAdicional,
              :id,
              :_destroy
          ],

          distribuciones_attributes: [
              { pai_ids: [] }, # PENDIENTE
              { estado_ids: [] },
              { municipio_ids: [] },
              { pais_inv_ids: [] },
              { pais_inv2_ids: [] },

              :infoadicionalmexedo,
              :infoAdicionalMun,
              :historicaPotencial,
              :alcanceDistribucion,
              :infoAdicionalAlcance,
              :comoExoticaMundial,
              :distribucionOriginal,
              :tipoDistribucion,
              :infoAdicionalTipo,
              :uso,
              :id,
              :_destroy
          ],

          # ERROR
          #distribucion_historica_attributes: [
          #    :especieId,
          #    :regLoc,
          #    :anioinicial,
          #    :mesinicial,
          #    :aniofinal,
          #    :mesfinal,
          #    :id,
          #    :_destroy
          #],

          # OK
          endemicas_attributes: [
              :endemicaMexico,
              :endemicaA,
              :infoAdicionalEndemica,
              :id,
              :_destroy
          ],

          habitats_attributes: [
              { ecorregion_ids: [] },
              { ecosistema_ids: [] },
              { vegetacion_ids: [] }, # PENDIENTE
              { vegetacion_acuatica_ids: [] }, # PENDIENTE
              :tipoAmbiente,
              :tipoVegetacion,
              :estadoHabitat,
              :addinfoestadoHabitat,
              :habitatAgropecuario,
              :zonaUrbana,
              :temperaturainicial,
              :temperaturafinal,
              :intervaloaltitudinalinicial,
              :intervaloaltitudinalfinal,
              :infoAddintervaloaltitudinal,
              :climaAdicional,
              :infoaddtemperatura,
              :temperaturainicialexo,
              :temperaturafinalexo,
              :infoaddtemperaturaexo,
              :precipitacioninicial,
              :precipitacionfinal,
              :infoaddprecipitacion,
              :precipitacioninicialexo,
              :precipitacionfinalexo,
              :infoaddprecipitacionexo,
              :humedadinicial,
              :humedadfinal,
              :infoaddhumedad,
              :biotipos,
              :salinidadinicial,
              :salinidadfinal,
              :unidadsalinidad,
              :oxigenoinicial,
              :oxigenofinal,
              :phinicial,
              :phfinal,
              :temeperaturainicial,
              :temeperaturafinal,
              :corrientes,
              :infoaddcaracagua,
              :intervaloaltitudinalacuainicial,
              :intervaloaltitudinalacuafinal,
              :infoAddintervaloaltitudinalacua,
              :interbatimetricoinicial,
              :interbatimetricofinal,
              :infoaddinterbatimetrico,
              :amplitudmareasinicial,
              :amplitudmareasfinal,
              :infoaddamplitudmareas,
              :tipoVegetacionexo,
              :uso,
              :id,
              :_destroy
          ],

          # OK
          historiaNatural_attributes: [
              { culturaUso_ids: [],
                pais_importacion_ids: [],
              },
              :tipoReproduccion,
              :estrategiaTrofica,
              :descripcionEstrofica,
              :conducta,
              :tipopHabito,
              :infoaddperiodoactividad,
              :infoaddhibernacion,
              :infoaddterritorialidad,
              :ambitoHogareno,
              :mecanismosDefensa,
              :infoaddmecdefensa,
              :distanciadispercioninicial,
              :distanciadispercionfinal,
              :variabilidadGenetica,
              :marcadorGenetico,
              :secuencias,
              :mexbol,
              :ImportanciaBiologica,
              :funcionEcologica,
              :importanciaEconomica,
              :comercioIlicitoNal,
              :comercioIlicitoInter,
              :descComIlicito,
              :descUsos,
              :hibernacion,
              :territorialidad,
              :id,
              :_destroy,
              {# OK
                reproduccionVegetal_attributes: [
                    :descripcion,
                    :aislamientoOrganos,
                    :descAislaOrganos,
                    :sistReproAsexuales,
                    :DescsistReproAsexuales,
                    :fecuandacion,
                    :descFecundacion,
                    :aperturaFlor,
                    :descApertura,
                    :tiempoFloracion,
                    :addinfolongevidadflor,
                    :mesInicio,
                    :mesFinal,
                    :addinfotiempoflora,
                    :cantidadnectarinicial,
                    :cantidadnectarfinal,
                    :addinfocantidadnectar,
                    :cantidadpolen,
                    :mesInicialFructi,
                    :mesFinalFructi,
                    :addinfotiempofructi,
                    :nofrutosinicial,
                    :nofrutosfinal,
                    :caracFruto,
                    :descCaracFruto,
                    :noEventos,
                    :descNoEventos,
                    :nosemillasinicial,
                    :nosemillasfinal,
                    :tamanioSemilla,
                    :caracToxica,
                    :germinacioninicial,
                    :germinacionfinal,
                    :infoaddgerminacion,
                    :plantulasinicial,
                    :plantulasfinal,
                    :infoaddplantulas,
                    :arregloEspacial,
                    :descripcionArregloespacial,
                    :agentesPolinizacion,
                    :descAgentesPol,
                    :patronesFloracion,
                    :patronesFructificacion,
                    :id,
                    :_destroy
                ]
              },
              {# OK
                reproduccionAnimal_attributes: [
                    :dimorfismoSexual,
                    :descripcion,
                    :additionalInfoDimorfiasmo,
                    :coloracion,
                    :ornamentacion,
                    :descripcionSistema,
                    :noEventos,
                    :descripcionNoEventos,
                    :tiempoentrecriasinicial,
                    :tiempoentrecriasfinal,
                    :tipoFecundacion,
                    :descripcionTipoFec,
                    :edadPrimeraRepro,
                    :duracionVidaRepro,
                    :frecuenciaApareamineto,
                    :noHuevosCrias,
                    :cuidadoParental,
                    :cuidadoParentalPor,
                    :desCuidadoParental,
                    :tiempoCuidadoParental,
                    :id,
                    :_destroy
                ]
              }
          ],
          # OK
          productocomercio_nal_attributes: [
              :nacionalinternacional,
              :tipoproducto,
              :unidadcomerciada,
              :cantidadcomerciada,
              :id,
              :_destroy
          ],
          # OK
          productocomercio_inter_attributes: [
              :nacionalinternacional,
              :tipoproducto,
              :unidadcomerciada,
              :cantidadcomerciada,
              :id,
              :_destroy
          ],
          # OK
          demografiaAmenazas_attributes: [
              { amenazaDirectum_ids: [] },
              :organizacionSocial,
              :infoaddorgsocial,
              :tamanioPoblacional,
              :abundancia,
              :densidad,
              :patronOcupacion,
              :descripcionPatron,
              :parametrosPoblacionales,
              :poblacionminviableinicial,
              :poblacionminviablefinal,
              :descPresionesAmenazas,
              :tendenciaPoblacional,
              :descTendenciaPoblacional,
              :id,
              :_destroy
          ],
          # OK
          conservacion_attributes: [
              :estadoConser,
              :descManejoAprov,
              :tipoAprovEsp,
              :grupoEspecies,
              :tallacapturainicial,
              :tallacapturafinal,
              :tipoCaptura,
              :marcolegal,
              :tipoVeda,
              :infoaddveda,
              :id,
              :_destroy
          ],
          # OK
          referenciasBibliograficas_attributes: [
              :especieId,
              :referencia,
              :id,
              :_destroy
          ],

          # Información adicional que se agrega en Observacionscarac
          ambi_info_ecorregiones_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          ambi_especies_asociadas_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          ambi_vegetacion_esp_mundo_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          ambi_info_clima_exotico_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          ambi_infotiposuelo_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          ambi_infogeoforma_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          infoalimenta_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          infoaddforrajeo_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          infoaddhabito_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          infosistaparea_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          infocrianza_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          infodisp_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          infostruct_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          infointer_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          infocons_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          infoAP_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          infoarresp_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],

          # Información sobre las especies invasoras (SECCION EXTRA)
          edopoblacion_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          persistenciapob_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          abundanciapob_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          historiaintro_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          otrossitios_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          adahabitat_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          adaclima_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          congeneres_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          frecintro_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          impactosei_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          impactobio_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          impactoeco_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          impactoinfra_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          impactosocial_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          impactootros_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          prevencion_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          manejocontrol_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          erradicacion_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          cuarentena_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          susceptibilidad_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          controlbiol_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          regulacion_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          benecologicos_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          beneconomicos_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          bensociales_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          conclimatica_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          conecologica_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          plasconductual_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          plasrepro_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          hibridacion_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          crecimientosei_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          spequivalentes_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          cca_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          fisk_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          fiisk_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          mfisk_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          miisk_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          aisk_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          tiisk_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          pier_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          meri_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          otroar_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          naturalizacion_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          mecanismoimpacto_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          efectoimpacto_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          intensidadimpacto_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          especiesasociadas_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          plasticidad_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          platencia_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          seguridad_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          enfermedadesei_attributes: [:id, :especieId, :idpregunta, :infoadicional, :_destroy],
          # -
      )

      itera_preguntas_observaciones(p)

      p
    end

  def itera_preguntas_observaciones(p)
    lista = %w(
      referenciasBibliograficas_attributes
      conservacion_attributes
      productocomercio_nal_attributes
      productocomercio_inter_attributes
      endemicas_attributes
      distribucion_historica_attributes
      ambi_info_ecorregiones_attributes
      ambi_especies_asociadas_attributes
      ambi_vegetacion_esp_mundo_attributes
      ambi_info_clima_exotico_attributes
      ambi_infotiposuelo_attributes
      infoalimenta_attributes
      infoaddforrajeo_attributes
      infoaddhabito_attributes
      infosistaparea_attributes
      infocrianza_attributes
      infodisp_attributes
      infostruct_attributes
      infoAP_attributes
      infoarresp_attributes
      infointer_attributes
      ambi_infogeoforma_attributes
      edopoblacion_attributes
      persistenciapob_attributes
      abundanciapob_attributes
      historiaintro_attributes
      otrossitios_attributes
      adahabitat_attributes
      adaclima_attributes
      congeneres_attributes
      frecintro_attributes
      impactosei_attributes
      impactobio_attributes
      impactoeco_attributes
      impactoinfra_attributes
      impactosocial_attributes
      impactootros_attributes
      prevencion_attributes
      manejocontrol_attributes
      erradicacion_attributes
      cuarentena_attributes
      susceptibilidad_attributes
      controlbiol_attributes
      regulacion_attributes
      benecologicos_attributes
      beneconomicos_attributes
      bensociales_attributes
      conclimatica_attributes
      conecologica_attributes
      plasconductual_attributes
      plasrepro_attributes
      hibridacion_attributes
      crecimientosei_attributes
      spequivalentes_attributes
      cca_attributes
      fisk_attributes
      fiisk_attributes
      mfisk_attributes
      miisk_attributes
      aisk_attributes
      tiisk_attributes
      pier_attributes
      meri_attributes
      otroar_attributes
      naturalizacion_attributes
      mecanismoimpacto_attributes
      efectoimpacto_attributes
      intensidadimpacto_attributes
      especiesasociadas_attributes
      plasticidad_attributes
      platencia_attributes
      seguridad_attributes
      enfermedadesei_attributes
      infocons_attributes
    )
    lista.each do |acceso|
      if p.key?(acceso)
        p[acceso].each do |k,v|
          break unless v["id"].present?
          ids = v["id"].split(' ')
          v["id"] = ids
        end
      end
    end
    p
  end
end