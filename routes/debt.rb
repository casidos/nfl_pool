# frozen_string_literal: true

class NFLPool
  route 'debt' do |r|
    r.is '' do
      view 'debt'
    end

    r.is do
      r.post do
        debt = Debt[r.params['id']]
        if @current_user.id == debt.payee_id
          debt.update(paid: !debt.paid)
          debt.paid.to_s
        else
          'bad_user'
        end
      end

      @debts_owed =
        @current_user.debts_owed_dataset.each_with_object({}) do |d, debts|
          debts[d[:payee_id]] ||= 0
          debts[d[:payee_id]] += d.amount.to_i
        end

      @debts_pending =
        @current_user.debts_pending_dataset.each_with_object({}) do |d, debts|
          debts[d[:loser_id]] ||= 0
          debts[d[:loser_id]] += d.amount.to_i
        end

      view 'debt'
    end
  end
end
