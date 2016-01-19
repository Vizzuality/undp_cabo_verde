module API::V1
  class CommentsController < API::ApiBaseController
    protect_from_forgery with: :null_session

    before_action :commentable,   only: :index
    before_action :set_user,      only: :create
    before_action :build_comment, only: :create

    def index
      @comments = @commentable.comments.filter_actives.recent
      respond_with @comments, each_serializer: CommentSerializer, root: 'comments', meta: { size: @comments.size, cache_date: @comments.last_max_created }
    end

    def create
      if @comment.save
        @comment.update(user: @user)
        render json: @comment, status: 201, serializer: CommentSerializer
      else
        render json: { success: false, message: 'Error creating comment' }, status: 422
      end
    end

    private

      def commentable
        @commentable = if params[:actor_id]
                         Actor.find(params[:actor_id])
                       elsif params[:act_id]
                         Act.find(params[:act_id])
                       elsif params[:indicator_id]
                         Indicator.find(params[:indicator_id])
                       end
      end

      def build_comment
        @required_params = params[:token].present? && params[:body].present?
        if @required_params && @user
          if @user.token_expired?
            render json: { success: false, message: 'Please login again' }, status: 422
          else
            @comment = commentable.comments.build(comment_params)
          end
        else
          render json: { success: false, message: 'Error creating comment' }, status: 422
        end
      end

      def set_user
        @user = User.find_by(authentication_token: params[:token])
      end

      def comment_params
        params.permit(:body)
      end
  end
end
