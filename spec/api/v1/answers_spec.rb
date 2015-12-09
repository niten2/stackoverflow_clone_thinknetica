require 'rails_helper'

describe 'Answer API' do

  describe 'GET /index' do
      let(:access_token) { create(:access_token) }
      let!(:question) { create(:question) }
      let!(:answer) { create(:answer, question: question) }

    context 'unauthorized' do
      it 'returns 401 status if there is no access_token' do
        get "/api/v1/questions/#{question.id}/answers", format: :json
        expect(response.status).to eq 401
      end

      it 'returns 401 status if access_token is invalid' do
        get "/api/v1/questions/#{question.id}/answers", format: :json, access_token: '1234'
        expect(response.status).to eq 401
      end
    end

    context 'authorized' do
      before { get "/api/v1/questions/#{question.id}/answers", format: :json, access_token: access_token.token }

      it 'included in answer object' do
        expect(response.body).to have_json_size(1).at_path("answers")
      end

      %w(id content created_at updated_at).each do |attr|
        it "contains #{attr}" do
          expect(response.body).to be_json_eql(answer.send(attr.to_sym).to_json).at_path("answers/0/#{attr}")
        end
      end
    end

  describe 'GET /show' do
    let(:access_token) { create(:access_token) }
    let!(:question) { create(:question) }
    let!(:answer) { create(:answer, question: question) }

    context 'unauthorized' do
      it 'returns 401 status if there is no access_token' do
        get "/api/v1/questions/#{question.id}/answers/#{answer.id}", format: :json
        expect(response.status).to eq 401
      end

      it 'returns 401 status if access_token is invalid' do
        get "/api/v1/questions/#{question.id}/answers/#{answer.id}", format: :json, access_token: '1234'
        expect(response.status).to eq 401
      end
    end

    context 'authorized' do
      let!(:comment_answer) { create(:comment, commentable: answer) }
      let!(:attachment_answer) { create(:attachment, attachable: answer) }

      before { get "/api/v1/questions/#{question.id}/answers/#{answer.id}", format: :json, access_token: access_token.token }

      it 'returns 200 status code' do
        expect(response).to be_success
      end

      %w(id content created_at updated_at).each do |attr|
        it "answer object contains #{attr}" do
          expect(response.body).to be_json_eql(answer.send(attr.to_sym).to_json).at_path("answer/#{attr}")
        end
      end

      %w(id content created_at updated_at).each do |attr|
        it "answer object contains comment with #{attr}" do
          expect(response.body).to be_json_eql(comment_answer.send(attr.to_sym).to_json).at_path("answer/comments/0/#{attr}")
        end
      end

      %w(id file created_at updated_at).each do |attr|
        it "answer object contains attachment with #{attr}" do
          expect(response.body).to be_json_eql(attachment_answer.send(attr.to_sym).to_json).at_path("answer/attachments/0/#{attr}")
        end
      end
    end
  end
  end
end
