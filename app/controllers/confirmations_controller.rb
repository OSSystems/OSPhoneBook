class ConfirmationsController < Devise::ConfirmationsController
  skip_before_filter(:authenticate_user!)

  def update
    with_unconfirmed_confirmable do
      if @confirmable.has_no_password?
        @confirmable.attempt_set_password(params[:user])
        if @confirmable.has_no_password?
          do_show
        elsif @confirmable.valid?
          do_confirm
        else
          do_show
        end
      else
        render "/404", :status => :not_found
      end
    end
  end

  def show
    with_unconfirmed_confirmable do
      if @confirmable.has_no_password?
        do_show
      else
        do_confirm
      end
    end
  end

  protected
  def with_unconfirmed_confirmable
    @confirmable = User.where(confirmation_token: params[:confirmation_token].to_s, confirmed_at: nil).first unless params[:confirmation_token].blank?
    @confirmable.nil? ? raise(ActiveRecord::RecordNotFound) : (@confirmable.only_if_unconfirmed{yield})
  end

  def do_show
    @confirmation_token = params[:confirmation_token]
    @requires_password = true
    self.resource = @confirmable
    render :show
  end

  def do_confirm
    @confirmable.confirm
    set_flash_message :notice, :confirmed
    sign_in_and_redirect(resource_name, @confirmable)
  end
end
