# frozen_string_literal: true

class NFLPool
  route 'picks' do |r|
    r.on Integer do |week|
      r.is do
        @week = Week.first(season: shared[:season], week: week)
        @show_picks = @week && @week.betting_ended?
        @week ? view('picks') : r.redirect(@current_week_path)
      end
    end

    r.is 'edit' do
      r.require_bettable!
      view('set_picks')
    end

    r.is '' do
      r.redirect @current_week_path
    end

    r.is do
      r.post do
        r.require_bettable!

        odd = Odd[r.params['odd_id']]
        team = Team[r.params['team_id']]

        # TODO: throw_error unless odd.week.betting_period?
        # TODO: throw_error unless team is part of odd

        Pick.update_or_create(
          odd_id: odd.id,
          user_id: @current_user.id
        ) { |p| p.team_id = team.id }

        ''
      end

      r.redirect @current_week_path
    end
  end
end
