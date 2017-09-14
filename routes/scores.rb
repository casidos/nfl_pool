# frozen_string_literal: true

class NFLPool
  route 'scores' do |r|
    r.post do
      Week.current.winner!
      ''
    end
  end
end
