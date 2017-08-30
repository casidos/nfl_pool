# frozen_string_literal: true

class NFLPool
  route 'picks' do |r|
    default_week = Week.current.week
    current_week_path = "/picks/#{default_week}"

    r.on Integer do |week|
      @week = Week.first(season: shared[:season], week: week)

      r.is 'edit' do
        if @week && @week.betting_period?
           view('set_picks')
        else
          # TODO: make this look prettier
          r.redirect(current_week_path)
        end
      end

      r.is do
        @week ? view('picks') : r.redirect(current_week_path)
      end
    end

    r.is '' do
      r.redirect current_week_path
    end

    r.is do
      r.redirect current_week_path
    end
  end
end
