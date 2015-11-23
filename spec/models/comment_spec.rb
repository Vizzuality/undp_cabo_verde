require 'rails_helper'

RSpec.describe Comment, type: :model do
  before :each do
    @user    = create(:user)
    @macro   = create(:actor_macro, user_id: @user.id)
    @comment = create(:comment, user: @user, commentable: @macro)
  end

  it 'Create Comment' do
    expect(@comment.body).not_to be_nil
    expect(@comment.commentable.name).to eq('Organization one')
    expect(@comment.user.email).to eq('pepe-moreno@sample.com')
  end

  it 'Comment body validation' do
    @comment_reject = Comment.new(body: '', user: @user, commentable: @macro)

    @comment_reject.valid?
    expect {@comment_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Body can't be blank")
  end
end
