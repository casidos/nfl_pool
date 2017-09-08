# frozen_string_literal: true

class Pick < Sequel::Model
  many_to_one :odd
  many_to_one :team
  many_to_one :user

  dataset_module do
    def won
      where(won: true)
    end
  end
end
