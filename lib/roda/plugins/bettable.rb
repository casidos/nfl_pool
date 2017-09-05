class Roda
  module RodaPlugins
    module Bettable
      module RequestMethods
        attr_accessor :context

        def require_bettable!
          return if week.betting_period?
          return if week.odds_dataset.any?
          scope.flash['warning'] = 'Picks are now locked for the current week.'
          scope.request.redirect(week_path)
        end

        def week
          scope.instance_variable_get(:@current_week)
        end

        def week_path
          scope.instance_variable_get(:@current_week_path)
        end
      end
    end

    register_plugin(:bettable, Bettable)
  end
end

