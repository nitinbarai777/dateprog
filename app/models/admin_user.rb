class AdminUser < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable
         #, request_keys: [:subdomain]

  # has_many :users, :inverse_of => :admin_user

  has_many :adminuser_users, inverse_of: :admin_user, dependent: :delete_all
  has_many :users, -> { uniq }, through: :adminuser_users
  accepts_nested_attributes_for :adminuser_users, allow_destroy: true

  # has_many :adminuser_users, :validate => false
  # has_many :users, :through => :adminuser_users

  validates_exclusion_of :subdomain, in: %w( admin ), message: "You cannot use this subdomain"

  validates_uniqueness_of :subdomain, message: "Subdomain already taken"

  validates_uniqueness_of :email, message: "already taken"

  after_create :add_default_role

  accepts_nested_attributes_for :roles, allow_destroy: true

  def is_superadmin?
    self.has_role?(:superadmin)
  end

  def add_default_role
    self.add_role :admin if self.roles.empty?
    @admin_roles = self.roles
  end
end
