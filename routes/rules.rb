# frozen_string_literal: true

class NFLPool
  route 'rules' do |r|
    r.is '' do
      view 'rules'
    end

    r.is do
      view 'rules'
    end
  end
end
