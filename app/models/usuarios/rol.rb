class Rol < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.ev}.roles"

  has_ancestry

  has_many :roles_categorias_contenidos, :class_name=> 'RolCategoriasContenido', :foreign_key => :rol_id
  has_many :categorias_contenidos, :through => :roles_categorias_contenidos, :source => :categorias_contenido

  has_many :usuario_roles, :class_name => 'UsuarioRol', :foreign_key => :rol_id
  has_many :usuarios, :through => :usuario_roles, :source => :usuario

  #METAMARES_ROLES = %w(AdminMetamares AdminMetamaresManager AdminMetamaresUsuario)
  METAMARES_ROLES = [:'20', :'21', :'22']
  #METAMARES_ROLES = [20.to_s.to_sym, 21.to_s.to_sym, 22.to_s.to_sym]

end