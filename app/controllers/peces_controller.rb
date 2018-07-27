class PecesController < ApplicationController
  before_action do
    @no_render_busqueda_basica = true
  end

  before_action :set_pez, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_usuario!, :except => [:show, :busqueda, :dameNombre]
  before_action :only => [:new, :update, :edit, :create, :destroy] do
    tiene_permiso?('Administrador', true)  # Minimo administrador
  end


  # GET /peces/1
  def show
    @pez = Pez.find(params[:id])
    @criterios = @pez.criterio_propiedades.select('*, valor').order(:ancestry)
    render :layout => false and return if params[:layout].present?
  end

  # GET /peces/new
  def new
    @pez = Pez.new
  end

  # GET /peces/1/edit
  def edit
  end

  # POST /peces
  def create
    @pez = Pez.new(pez_params)

    if @pez.save
      redirect_to pez_path(@pez), notice: 'El pez fue creado satisfactoriamente.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /peces/1
  def update
    if @pez.update_attributes(pez_params)
      redirect_to @pez, notice: 'El Pez fue actualizado satisfactoriamente.'
    else
      render action: 'edit'
    end
  end

  # DELETE /peces/1
  def destroy
    @pez.destroy
    redirect_to '/peces/busqueda', notice: 'El pez fue destruido satisfactoriamente.'
  end

  def busqueda
    @filtros =  Criterio.dame_filtros

    if params[:commit].present?
      @peces = Pez.filtros_peces

      # Busqueda por nombre científico o comunes
      @peces = @peces.where(especie_id: params[:especie_id]) if params[:especie_id].present?

      # Busqueda con estrella
      @peces = @peces.where(con_estrella: params[:con_estrella]) if params[:con_estrella].present?

      # Busqueda con pesquerias
      @peces = @peces.where(especie_id: params[:pesquerias]) if params[:pesquerias].present?

      # Filtros globales
      @peces = @peces.where("propiedades.id = ?", params[:grupos]) if params[:grupos].present?
      @peces = @peces.where("criterios.id IN (#{params[:tipo_capturas].join(',')})") if params[:tipo_capturas].present?
      @peces = @peces.where("criterios.id IN (#{params[:tipo_vedas].join(',')})") if params[:tipo_vedas].present?
      @peces = @peces.where("criterios.id IN (#{params[:procedencias].join(',')})") if params[:procedencias].present?
      @peces = @peces.where("criterios.id IN (#{params[:nom].join(',')})") if params[:nom].present?
      @peces = @peces.where("criterios.id IN (#{params[:iucn].join(',')})") if params[:iucn].present?
      @peces = @peces.where("criterios.id IN (#{params[:cnp].join(',')})") if params[:cnp].present?

      # Filtros del SEMAFORO de RECOMENDACIÓN
      if params[:semaforo_recomendacion].present? && params[:zonas].present?
        regexp = dame_regexp_zonas(zonas: params[:zonas], color_seleccionado: "[#{params[:semaforo_recomendacion].join('')}]")
        @peces = @peces.where("valor_zonas REGEXP '#{regexp}'")
      elsif params[:semaforo_recomendacion].present?
        # Selecciono el valor de sin datos
        if params[:semaforo_recomendacion].include?('sn')
          rec = "[#{params[:semaforo_recomendacion].join('')}]{6}"
        else # Cualquier otra combinacion
          rec = params[:semaforo_recomendacion].map{ |r| r.split('') }.join('|')
        end

        @peces = @peces.where("valor_zonas REGEXP '#{rec}'")
      elsif params[:zonas].present?
        regexp = dame_regexp_zonas(zonas: params[:zonas])
        @peces = @peces.where("valor_zonas REGEXP '#{regexp}'")
      end

      render :file => 'peces/resultados'
    end
  end

  def dameNombre
    tipo = params[:tipo]
    case tipo
    when 'cientifico'
      render json: Pez.nombres_cientificos_peces.where("nombre_cientifico LIKE ?", "%#{params[:term]}%").to_json
    when 'comunes'
      render json: Pez.nombres_comunes_peces.where("nombres_comunes LIKE ?", "%#{params[:term]}%").to_json
    else
      render json: [{error: 'no encontre'}].to_json
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_pez
    @pez = Pez.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def pez_params
    params.require(:pez).permit(:especie_id, peces_criterios_attributes: [:id, :criterio_id, :_destroy],
                                peces_propiedades_attributes: [:id, :propiedad_id, :_destroy])
  end

  def dame_regexp_zonas(opc = {})
    colores_default = opc[:colores_default] || '[varns]'
    color_seleccionado = opc[:color_seleccionado] || '[var]'
    valor_por_zona = Array.new(6, colores_default)
    opc[:zonas].each do |z|
      valor_por_zona[z.to_i] = color_seleccionado
    end
    valor_por_zona.join('')
  end
end
