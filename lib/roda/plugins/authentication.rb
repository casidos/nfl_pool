class Roda
  module RodaPlugins
    module Authentication
      def self.load_dependencies(app)
        configure_omniauth(app)
      end

      def self.configure_omniauth(app)
        app.use OmniAuth::Builder do
          provider :google_oauth2,
                   ENV['google_client_id'],
                   ENV['google_client_secret']
        end
      end

      module RequestMethods
        attr_accessor :context

        def authenticate!
          if user
            scope.instance_variable_set(:@current_user, user)
          else
            scope.request.redirect 'sign_in'
          end
        end

        def user
          User[session[:user_id]]
        end

        def user_id
          session[:user_id]
        end
      end
    end

    register_plugin(:authentication, Authentication)
  end
end

