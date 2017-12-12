# frozen_string_literal: true

class NFLPool
  route 'stats' do |r|
    @stats =
      Team.where{id > 0}.order(:id).all.each_with_object({}) do |team, stats|
        stats[team.id] = {}
        stats[team.id][:away_games] = 0
        stats[team.id][:away_games_covered] = 0
        stats[team.id][:away_games_covered_when_favored] = 0
        stats[team.id][:away_games_favored] = 0
        stats[team.id][:away_games_won] = 0
        stats[team.id][:home_games] = 0
        stats[team.id][:home_games_covered] = 0
        stats[team.id][:home_games_covered_when_favored] = 0
        stats[team.id][:home_games_favored] = 0
        stats[team.id][:home_games_won] = 0
        stats[team.id][:total_games] = 0
        stats[team.id][:total_games_covered] = 0
        stats[team.id][:total_games_covered_when_favored] = 0
        stats[team.id][:total_games_favored] = 0
        stats[team.id][:total_games_won] = 0
      end

    Game.finished.all.each do |game|
      # game counts
      @stats[game.away_team_id][:total_games] += 1
      @stats[game.home_team_id][:total_games] += 1

      @stats[game.away_team_id][:away_games] += 1
      @stats[game.home_team_id][:home_games] += 1

      # games won
      if game.game_winner_id == game.away_team_id
        @stats[game.away_team_id][:total_games_won] += 1
        @stats[game.away_team_id][:away_games_won] += 1
      elsif game.game_winner_id == game.home_team_id
        @stats[game.home_team_id][:total_games_won] += 1
        @stats[game.home_team_id][:home_games_won] += 1
      else
        @stats[game.away_team_id][:total_games_tied] += 1
        @stats[game.away_team_id][:away_games_tied] += 1
        @stats[game.home_team_id][:total_games_tied] += 1
        @stats[game.home_team_id][:home_games_tied] += 1
      end


      # odds
      odd = game.spread_odd
      away_favored = odd.favored_team_id == game.away_team_id && odd.odd != 0
      home_favored = odd.favored_team_id == game.home_team_id && odd.odd != 0
      away_covered = odd.winning_team_id == game.away_team_id
      home_covered = odd.winning_team_id == game.home_team_id

      # games favored
      if away_favored
        @stats[game.away_team_id][:away_games_favored] += 1
        @stats[game.away_team_id][:total_games_favored] += 1
      elsif home_favored
        @stats[game.home_team_id][:home_games_favored] += 1
        @stats[game.home_team_id][:total_games_favored] += 1
      end

      # games covered
      if away_covered
        @stats[game.away_team_id][:away_games_covered] += 1
        @stats[game.away_team_id][:total_games_covered] += 1
      elsif home_covered
        @stats[game.home_team_id][:home_games_covered] += 1
        @stats[game.home_team_id][:total_games_covered] += 1
      end

      # games covered when favored
      if away_covered && away_favored
        @stats[game.away_team_id][:away_games_covered_when_favored] += 1
        @stats[game.away_team_id][:total_games_covered_when_favored] += 1
      elsif home_covered && home_favored
        @stats[game.home_team_id][:home_games_covered_when_favored] += 1
        @stats[game.home_team_id][:total_games_covered_when_favored] += 1
      end
    end

    @user_teams = @teams.select { |k, v| @users.map(&:team_id).include? k }.values

    r.is '' do
      view 'stats'
    end

    r.is do
      view 'stats'
    end
  end
end
