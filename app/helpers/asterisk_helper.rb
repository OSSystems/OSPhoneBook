module AsteriskHelper
  def current_user_can_dial?
    user_signed_in? && !current_user.extension.blank?
  end
end
