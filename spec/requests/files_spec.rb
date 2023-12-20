require 'rails_helper'

RSpec.describe 'download submission files', type: :request, authorized: true do
  example do
    user = create(:user, api_key: 'API_KEY')

    create :request, user:, db: 'JVar' do |request|
      create :obj, request:, _id: 'Excel', file: uploaded_file(name: 'myexcel.xlsx'), destination: 'dest'
      create :submission, request:, id: 42, created_at: '2023-12-05'
    end

    get '/api/submissions/X-42/files/dest/myexcel.xlsx'

    expect(response).to redirect_to(%r(\Ahttp://www.example.com/rails/active_storage/disk/))
  end
end
