class User < ActiveRecord::Base
  devise :database_authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

  validates_presence_of :name

  def attempt_set_password(params)
    params = {} unless params.is_a?(Hash)
    p = {}
    p[:password] = params[:password]
    p[:password_confirmation] = params[:password_confirmation]
    update_attributes(p)
  end

  def has_no_password?
    self.encrypted_password.blank?
  end

  def only_if_unconfirmed
    pending_any_confirmation {yield}
  end

  private
  def password_required?
    persisted? and !password.nil? || !password_confirmation.nil?
  end
end
