module AnyLogin
  class ApplicationController < ActionController::Base
    include AnyLogin.provider::Controller

    if AnyLogin.enabled
      if AnyLogin.http_basic_authentication_enabled
        http_basic_authenticate_with :name => AnyLogin.http_basic_authentication_user_name,
                                     :password => AnyLogin.http_basic_authentication_password
      end
    end

    DEFAULT_SIGN_IN = proc do |loginable|
      reset_session
      sign_in AnyLogin.klass.to_s.parameterize.underscore.to_sym, loginable
    end

    def any_login
      try_not_to_leak_any_login_is_installed
      head 403 && return unless AnyLogin.verify_access_proc.call(self)
      add_to_previous

      # Devise
      klass = params[:as].constantize
      @loginable = klass.find(user_id)
      sign_in = AnyLogin.sign_in || DEFAULT_SIGN_IN
      instance_exec(@loginable, &sign_in)

      redirect_to main_app.send(AnyLogin.redirect_path_after_login)
      # AnyLogin.provider::Controller.instance_method(:any_login_sign_in).bind(self).call
    end

    private

    def try_not_to_leak_any_login_is_installed
      try_to_render_404_not_found unless AnyLogin.enabled
    end

    def try_to_render_404_not_found
      raise ActiveRecord::RecordNotFound
    end

    def user_id
      params[:back_to_previous_id].presence || params[:selected_id].presence || params[:id]
    end

    def previous
      cookies[AnyLogin.cookie_name] ||= ""
    end

    def previous_list
      previous.split(',').take(AnyLogin.previous_limit)
    end

    def add_to_previous
      cookies[AnyLogin.cookie_name] = ([user_id] + previous_list).uniq.join(',')
    end

  end
end
