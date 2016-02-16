module API::V1
  class FavouritesController < API::ApiBaseController
    include ApiAuthenticable

    before_action :set_user_by_token
    before_action :set_favourite,   only: [:update, :destroy]
    before_action :build_favourite, only: :create

    def index
      @favourites = @user.favourites.positioned.recent
      respond_with @favourites, each_serializer: FavouriteSerializer, root: 'favourites', meta: { size: @favourites.size, cache_date: @favourites.last_max_updated }
    end

    def update
      if @favourite.update(update_favourite_params)
        render json: @favourite, status: 201, serializer: FavouriteSerializer
      else
        render json: { success: false, message: 'Error creating favourite' }, status: 422
      end
    end

    def create
      if @favourite.save
        render json: @favourite, status: 201, serializer: FavouriteSerializer
      else
        render json: { success: false, message: 'Error creating favourite' }, status: 422
      end
    end

    def destroy
      @favourite.destroy
      begin
        render json: { message: 'Favourite deleted' }, status: 200
      rescue ActiveRecord::RecordNotDestroyed
        return render json: @favourite.erors, message: 'Favorite could not be deleted', status: 422
      end
    end

    private

      def build_favourite
        @required_params = params[:token].present? && params[:uri].present?
        if @required_params && @user
          if session_invalid?(@user)
            reset_auth_token(@user)
          else
            @favourite = @user.favourites.build(favourite_params)
          end
        else
          render json: { success: false, message: 'Error creating favourite' }, status: 422
        end
      end

      def set_user_by_token
        @user = User.find_by(authentication_token: params[:token])
      end

      def set_user_by_token
        if params[:token].present?
          @user = User.find_by(authentication_token: params[:token])
          if @user.blank?
            render json: { success: false, message: 'Please login again' }, status: 422
          elsif @user && session_invalid?(@user)
            reset_auth_token(@user)
          else
            return
          end
        else
          render json: { success: false, message: 'Please provide authentication token' }, status: 422
        end
      end

      def set_favourite
        @favourite = @user.favourites.find(params[:id])
      end

      def favourite_params
        params.permit(:name, :uri, :favorable_type, :favorable_id, :position)
      end

      def update_favourite_params
        params.permit(:name, :position)
      end
  end
end
