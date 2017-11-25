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

      view 'debt'
    end
  end
end
