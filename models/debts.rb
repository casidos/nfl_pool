# frozen_string_literal: true

class Debt < Sequel::Model
  many_to_one :loser, class: :User
  many_to_one :payee, class: :User
  many_to_one :week

  dataset_module do
    def by_loser
      eager_graph(:loser).order(:loser__name)
    end
  end
end
