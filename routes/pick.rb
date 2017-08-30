# frozen_string_literal: true

class NFLPool
  route 'pick' do |r|
    r.is do
      r.post do
        odd = Odd[r.params['odd_id']]
        team = Team[r.params['team_id']]

        # TODO: throw_error unless odd.week.betting_period?
        # TODO: throw_error unless team is part of odd

        pick = Pick.update_or_create(
          odd_id: odd.id,
          user_id: @current_user.id
        ) { |p| p.team_id = team.id }

        ''
      end
    end
  end
end
