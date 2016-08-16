class ComentariosController < ApplicationController
  skip_before_filter :set_locale, only: [:show, :show_respuesta, :new, :create, :update, :destroy, :update_admin, :ultimo_id_comentario]
  before_action :set_comentario, only: [:show, :show_respuesta, :edit, :update, :destroy, :update_admin, :ultimo_id_comentario]
  before_action :authenticate_usuario!, :except => [:new, :create, :show_respuesta]
  before_action :only => [:index, :show, :update, :edit, :destroy, :admin, :update_admin, :extrae_comentarios_generales, :dame_correo, :ultimo_id_comentario] do
    permiso = tiene_permiso?(100)  # Minimo administrador
    render :_error unless permiso
  end
  before_action :only => [:extrae_comentarios_generales, :dame_correo, :mueve_correo] do
  @xolo_url = "https://#{CONFIG.smtp.user_name}:#{CONFIG.smtp.password}@#{CONFIG.smtp.address}/home/enciclovida/"
    Mail.defaults do
      retriever_method :imap, { :address => CONFIG.smtp.address,
                                :user_name => CONFIG.smtp.user_name,
                                :password => CONFIG.smtp.password
                            }
    end
  end
  layout false, only:[:update, :show, :dame_correo, :ultimo_id_comentario]


  # GET /comentarios
  # GET /comentarios.json
  def index
    @comentarios = Comentario.all
  end

  # GET /comentarios/1
  # GET /comentarios/1.json
  # Show de la vista de admins
  def show
    cuantos = @comentario.descendants.count

    if cuantos > 0
      resp = @comentario.descendants.map{ |c|

        if usuario = c.usuario
          nombre = "#{usuario.nombre} #{usuario.apellido}"
          correo = usuario.email
        else
          nombre = c.nombre
          correo = c.correo
        end

        { id: c.id, especie_id: c.especie_id, comentario: c.comentario, nombre: nombre, correo: correo, created_at: c.created_at, estatus: c.estatus }
      }

      @comentarios = {estatus:1, cuantos: cuantos, resp: resp}

    else
      @comentarios = {estatus:1, cuantos: cuantos}
    end

    # Para saber el id del ultimo comentario, antes de sobreescribir a @comentario
    ultimo_comentario = @comentario.subtree.order('ancestry ASC').map(&:id).reverse.first

    # Especie
    especie_id = @comentario.especie_id

    # Crea el nuevo comentario con las clases de la gema ancestry
    @comentario = Comentario.children_of(ultimo_comentario).new

    # El ID del administrador
    @comentario.usuario_id = current_usuario.id

    # Estatus 6 quiere decir que es parte del historial de un comentario
    @comentario.estatus = 6

    # Categoria comentario ID
    @comentario.categoria_comentario_id = 26

    # Para no poner la caseta de verificacion
    @comentario.con_verificacion = false

    # Proviene de un administrador
    @comentario.es_admin = true

    # Asigna la especie
    @comentario.especie_id = especie_id
  end

  def show_respuesta
    comentario_root = @comentario.root

    if comentario_root.created_at.strftime('%d-%m-%y_%H-%M-%S') != params[:created_at]
      render :file => "/public/404.html", :status => 404, :layout => false
      #redirect_to :root, notice: 'Lo sentimos esa página no existe'.html_safe
    else

      @comentario_resp = @comentario
      cuantos = @comentario_resp.descendants.count

      if cuantos > 0
        resp = @comentario_resp.descendants.map{ |c|

          c.completa_nombre_correo_especie
          { id: c.id, especie_id: c.especie_id, comentario: c.comentario, nombre: c.nombre, correo: c.correo, created_at: c.created_at, estatus: c.estatus }
        }

        @comentarios = {estatus:1, cuantos: cuantos, resp: resp}

      else
        @comentarios = {estatus:1, cuantos: cuantos}
      end

      # Para saber el id del ultimo comentario, antes de sobreescribir a @comentario
      ultimo_comentario = @comentario_resp.subtree.order('ancestry ASC').map(&:id).reverse.first

      # Crea el nuevo comentario con las clases de la gema ancestry
      @comentario = Comentario.children_of(ultimo_comentario).new

      # Datos del usuario
      @comentario.usuario_id = @comentario_resp.usuario_id
      @comentario.nombre = @comentario_resp.nombre
      @comentario.correo = @comentario_resp.correo
      @comentario.institucion = @comentario.institucion

      # Estatus 6 quiere decir que es parte del historial de un comentario
      @comentario.estatus = 6

      # Categoria comentario ID
      @comentario.categoria_comentario_id = 26

      # Caseta de verificacion
      @comentario.con_verificacion = true

      # Proviene de un administrador
      @comentario.es_admin = false

      # Si es una respuesta de un usuario
      @comentario.es_respuesta = true

      # Asigna la especie
      @comentario.especie_id = @comentario_resp.especie_id

      render 'show'
    end
  end

  # GET /comentarios/new
  def new
    @especie_id = params[:especie_id]
    @comentario = Comentario.new
    @comentario.con_verificacion = true
  end

  # GET /comentarios/1/edit
  def edit
  end

  # POST /comentarios
  # POST /comentarios.json
  def create
    especie_id = params[:especie_id]
    @comentario = Comentario.new(comentario_params.merge(especie_id: especie_id))

    params = comentario_params

    respond_to do |format|
      if params[:con_verificacion].present? && params[:con_verificacion] == '1'
        if verify_recaptcha(:model => @comentario, :message => t('recaptcha.errors.missing_confirm')) && @comentario.save

          if params[:es_respuesta].present? && params[:es_respuesta] == '1'
            comentario_root = @comentario.root
            format.json {render json: {estatus: 1, comentario_id: comentario_root.id, especie_id: comentario_root.especie_id,
                                       created_at: comentario_root.created_at.strftime('%d-%m-%y_%H-%M-%S')}.to_json}
          else
            format.html { redirect_to especie_path(especie_id), notice: '¡Gracias! Tu comentario fue enviado satisfactoriamente.' }
          end

        else
          # Hubo un error al enviar el formulario
          if params[:es_respuesta].present? && params[:es_respuesta] == '1'
            format.json {render json: {estatus: 0}.to_json}
          else
            format.html { render action: 'new' }
          end

        end

      # Para evitar el google captcha a los usuarios administradores, la respuesta siempre es en json
      else
        if params[:es_admin].present? && params[:es_admin] == '1' && @comentario.save
          EnviaCorreo.respuesta_comentario(@comentario).deliver #if Rails.env.production?
          format.json {render json: {estatus: 1, ancestry: "#{@comentario.ancestry}/#{@comentario.id}"}.to_json}
        else
          format.json {render json: {estatus: 0}.to_json}
        end

      end  # end con_verificacion
    end  # end tipo response
  end

  # PATCH/PUT /comentarios/1
  # PATCH/PUT /comentarios/1.json
  def update
    if params[:estatus].present?
      @comentario.estatus = params[:estatus]
      @comentario.usuario_id2 = current_usuario.id
      @comentario.fecha_estatus = Time.now
    end

    @comentario.categoria_comentario_id = params[:categoria_comentario_id] if params[:categoria_comentario_id].present?

    if @comentario.save
      render json: {estatus: 1}.to_json
    else
      render json: {estatus: 0}.to_json
    end
  end

  # DELETE /comentarios/1
  # DELETE /comentarios/1.json
  def destroy
    @comentario.resuelto = 3

    if @comentario.save
      render text: '1'
    else
      render text: '0'
    end
  end

  # Administracion de los comentarios
  def admin
    if params[:comentario].present?
      params = comentario_params
      consulta = 'Comentario'

      if params[:categoria_comentario_id].present?
        consulta << ".where(categoria_comentario_id: #{params[:categoria_comentario_id].to_i})"
      end

      if params[:estatus].present?
        consulta << ".where(estatus: #{params[:estatus].to_i})"
      end

      # Para ordenar por created_at
      if params[:created_at].present?
        @comentarios = eval(consulta).where('estatus < 5').order("created_at #{params[:created_at]}")
      else
        @comentarios = eval(consulta).where('estatus < 5').order('estatus ASC, created_at ASC')
      end

    else
      # estatus =5 quiere decir oculto a la vista
      @comentarios = Comentario.where('estatus < 5').order('estatus ASC, created_at ASC')
    end

    @comentarios.each do |c|
      c.cuantos = c.descendants.count
      c.completa_nombre_correo_especie
    end
  end

  #Extrae los correos de la cuenta enciclovida@conabio.gob.mx y los guarda en la base
  # en el formato de la tabla comentarios para tener un front-end adminsitrable




  def extrae_comentarios_generales
    #address = "https://#{CONFIG.smtp.user_name}:#{CONFIG.smtp.password}@#{CONFIG.smtp.address}/home/enciclovida/"
    #response = JSON.parse(RestClient.get @xolo_url+"Pendientes", {:params => {'auth' => 'ba', 'fmt' => 'json'}})
    #n=1
    #response['m'].each do |v|
      #print n.to_s
      #RestClient.get("https://#{CONFIG.smtp.user_name}:#{CONFIG.smtp.password}@xolo.conabio.gob.mx/home/enciclovida/?id=323")

      #mueve_correo RestClient.get(@xolo_url, {:params => {'auth' => 'ba', 'id' => v['id']}}), "Resueltos"
      #sleep(1.0/10.0)
      #n=n+1
    #end
    #response = JSON.parse(RestClient.get @xolo_url+"Pendientes", {:params => {'auth' => 'ba', 'fmt' => 'json'}})
    #render inline: response.to_s

    # Mail.defaults do
    #   retriever_method :imap, { :address             => CONFIG.smtp.address,
    #                             #:port                => 993,
    #                             :user_name           => CONFIG.smtp.user_name,
    #                             :password            => CONFIG.smtp.password}
    #                             #:enable_ssl          => true }
    # end

    #response = Mail.find(count: 1000, mailbox: "Pendientes", order: :desc, keys: ["SUBJECT", "kasdaklsa"])[0].to_s
    #NOTA, CAMBIAR PENDIENTES POR INBOS Y RESUELTOS POR PENDIENTES

    #Mail.find(count: 1000, mailbox: "Pendientes", order: :desc, delete_after_find: true) { |m|
    #  mueve_correo(m, "Resueltos")
    #}
    procesa_correos({mborigen: 'Inbox', mbdestino: 'Pendientes'})
    response = Comentario.find_all_by_categoria_comentario_id(29)
    render 'comentarios/generales', :locals => {:response => response}
  end

  def dame_correo
    #address = "https://#{CONFIG.smtp.user_name}:#{CONFIG.smtp.password}@#{CONFIG.smtp.address}/home/enciclovida/"
    #puts address
    #response = RestClient.get @xolo_url, {:params => {'id' => params[:id].to_s, 'auth' => 'ba', 'part' => '1'}}

    #AHORA SE HARAÁ CON mail.find
    c = Comentario.find(params[:id].to_s)
    s = "#{Base64.decode64(c.comentario).force_encoding('UTF-8')} - [Comentario con ID - (#{c.id})]".force_encoding('ASCII-8BIT')
    response = Mail.find(count: 1000, order: :asc, mailbox: 'Resueltos' ,delete_after_find: false, keys: ['SUBJECT', s])

    render text: response[0].html_part.decoded
  end

  private

  #No importa como se le pase el correo, se sube a la nueva carpeta con REST.put, y se borra de la anterior con MAIL.find_and_delete
  def mueve_correo(correo, mbdestino)
    #xolo_url = "https://#{CONFIG.smtp.user_name}:#{CONFIG.smtp.password}@#{CONFIG.smtp.address}/home/enciclovida/"
    RestClient.put(@xolo_url+mbdestino, correo.to_s)
  end

  def mueve_correos #carpeta entera

  end

  def borra_correo

  end

  def borra_correos #carpeta entera

  end

  def procesa_correo

  end

  def procesa_correos(opts={}) #carpeta entera
    Mail.find(count: 1000, mailbox: opts[:mborigen], order: :asc, delete_after_find: false, keys: opts[:search]||='ALL') { |m|
      guarda_correo_bd(m)
      mueve_correo(m, opts[:mbdestino])
    }
    #Mail.find(count: 1000, mailbox: opts[:mbdestino], order: :desc).each { |m| m.body = '' }
  end

  def guarda_correo_bd(correo)
    comment = Comentario.new

    comment.comentario = correo.subject.codifica64 ##Para poder guardar en la bd, si se desea ver en browser hacer un force_encoding(utf-8)
    comment.correo = correo.from.first#.encode('ASCII-8BIT').force_encoding('UTF-8')
    comment.nombre = correo.header[:from].display_names.join(',')
    comment.especie_id = 0
    comment.categoria_comentario_id = 29
    comment.created_at = correo.header[:date].value.to_time #FALLA por q la asignación de id es por fecha y no por autoincremental ¬¬ CORREGIR ESO#
    if comment.save
      correo.subject = correo.subject.to_s + " - [Comentario con ID - (#{comment.id})]"
      puts 'Guarde correo con subject: ' + correo.subject.to_s + ' en la BD'
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_comentario
    @comentario = Comentario.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def comentario_params
    params.require(:comentario).permit(:comentario, :usuario_id, :correo, :nombre, :estatus, :ancestry, :institucion,
                                       :con_verificacion, :es_admin, :es_respuesta, :especie_id, :categoria_comentario_id, :created_at)
  end

  def dame_correos

  end
end
