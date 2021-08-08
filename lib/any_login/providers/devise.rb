module AnyLogin
  module Provider
    module Devise

      module Controller

        def initialize(klass_name)
          @klass_name = klass_name
        end

        DEFAULT_SIGN_IN = proc do |loginable|
          reset_session
          sign_in AnyLogin.klass.to_s.parameterize.underscore.to_sym, loginable
        end

        def self.any_login_current_user_method
          @@any_login_current_user_method ||= "current_#{AnyLogin.klass.to_s.parameterize.underscore}".to_sym
        end

        def any_login_sign_in
          @loginable = @klass_name.constantize.find(user_id)

          sign_in = AnyLogin.sign_in || DEFAULT_SIGN_IN
          instance_exec(@loginable, &sign_in)

          redirect_to main_app.send(AnyLogin.redirect_path_after_login)
        end

      end

    end
  end
end

AnyLogin.provider = AnyLogin::Provider::Devise
