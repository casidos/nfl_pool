class Roda
  module RodaPlugins
    module Bettable
      module RequestMethods
        attr_accessor :context

        def require_bettable!
          return unless betting_period?
          return unless no_odds?
        end

        def week
          scope.instance_variable_get(:@current_week)
        end

        def week_path
          scope.instance_variable_get(:@current_week_path)
        end

        private

        def betting_period?
          return true if week.betting_period?
          scope.flash['warning'] = 'Picks are now locked for the current week.'
          scope.request.redirect(week_path)
          false
        end

        def no_odds?
          return true if week.odds_dataset.any?
          scope.flash['warning'] = 'Odds have not been generated yet.'
          scope.request.redirect(week_path)
          false
        end
      end
    end

    register_plugin(:bettable, Bettable)
  end
end

