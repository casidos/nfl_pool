# frozen_string_literal: true

class Pick < Sequel::Model
  many_to_one :odd
  many_to_one :team
  many_to_one :user

  dataset_module do
    %i[spread total].each do |type|
      define_method(type) do
        eager_graph(:odd).where(type: "#{type.capitalize}Odd")
      end
    end

    def won
      where(won: true)
    end
  end
end
