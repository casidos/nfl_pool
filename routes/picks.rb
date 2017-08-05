# frozen_string_literal: true

class NFLPool
  route 'picks' do |r|
    default_week = Week.current.week
    current_week_path = "/picks/#{default_week}"

    r.is Integer do |week|
      @week = Week.first(season: shared[:season], week: week)
      @week ? view('picks') : r.redirect(current_week_path)
    end

    r.is '' do
      r.redirect current_week_path
    end

    r.is do
      r.redirect current_week_path
    end
  end
end
