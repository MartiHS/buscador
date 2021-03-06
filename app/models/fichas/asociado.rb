class Fichas::Asociado < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.asociado"
	self.primary_key = 'asociadoId'

	belongs_to :responsable, :class_name => 'Fichas::Responsable', :foreign_key => 'responsableId'
	belongs_to :puesto, :class_name => 'Fichas::Puesto', :foreign_key => 'puestoId'
	belongs_to :organizacion, :class_name => 'Fichas::Organizacion', :foreign_key => 'organizacionId'

	has_many :relAsociadosContactos, class_name: 'Fichas::Relasociadocontacto', :foreign_key => 'contactoId'
	has_many :relMetadatosAsociados , class_name: 'Fichas::Relmetadatosasociado', :foreign_key => :asociadoId

	has_many :contacto, class_name: 'Fichas::Contacto', through: :relAsociadosContactos

	accepts_nested_attributes_for :contacto, allow_destroy: true, reject_if: :all_blank
end
