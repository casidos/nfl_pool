# frozen_string_literal: true

class NFLPool
  route 'picks' do |r|
    r.on Integer do |week|
      @week = Week.first(season: shared[:season], week: week)

      r.is 'edit' do
        if @week && @week.betting_period?
           view('set_picks')
        else
          # TODO: make this look prettier
          r.redirect(@current_week_path)
        end
      end

      r.is do
        @show_picks = @week && @week.betting_ended?
        @week ? view('picks') : r.redirect(@current_week_path)
      end
    end

    r.is '' do
      r.redirect @current_week_path
    end

    r.is do
      r.redirect @current_week_path
    end
  end
end
