# frozen_string_literal: true

class Pick < Sequel::Model
  many_to_one :odd
  many_to_one :team
  many_to_one :user

  one_through_many :week, [
    [:odds, :id, :game_id],
    [:games, :id, :week_id]
  ],
    left_primary_key: :odd_id

  dataset_module do
    %i[spread total].each do |type|
      define_method(type) do
        eager_graph(:odd).where(odd__type: "#{type.capitalize}Odd")
      end
    end

    def won
      where(won: true)
    end
  end
end
