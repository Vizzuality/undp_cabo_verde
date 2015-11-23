class CommentsController < ApplicationController
  load_and_authorize_resource

  before_action :authenticate_user!
  before_action :set_comment, except: :create
  before_action :build_comment, only: :create

  def create
    if @comment.save
      @comment.update(user: current_user) and redirect_to redirect_paths
    else
      redirect_to redirect_paths, notice: "Comment's body can't be blank"
    end
  end

  def deactivate
    if @comment.try(:deactivate)
      redirect_to redirect_paths
    end
  end

  def activate
    if @comment.try(:activate)
      redirect_to redirect_paths
    end
  end

  private

    def commentable
      @commentable = if params[:actor_id]
                       Actor.find(params[:actor_id])
                     elsif params[:act_id]
                       Act.find(params[:act_id])
                     end
    end

    def build_comment
      @comment = commentable.comments.build(comment_params)
    end

    def set_comment
      @comment = commentable.comments.find(params[:id])
    end

    def redirect_paths
      if @commentable.class.name.include?('Actor')
        actor_path(@commentable)
      else
        act_path(@commentable)
      end
    end

    def comment_params
      params.require(:comment).permit!
    end
end
