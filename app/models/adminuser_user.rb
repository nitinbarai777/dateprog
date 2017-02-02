class AdminuserUser < ActiveRecord::Base
  belongs_to :admin_user, inverse_of: :adminuser_users
  belongs_to :user, inverse_of: :adminuser_users

  validates_uniqueness_of :admin_user_id, :scope => :user_id, message: "already added"
end
