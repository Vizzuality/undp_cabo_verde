module FavouriteActions
  extend ActiveSupport::Concern

  def create_favourite
    begin
      @favourite = current_user.favourites.build(name: @object.name, uri: path_to(@object), favorable_id: @object.id, favorable_type: @object.class.name.to_s)
      if @favourite.save
        respond_to do |format|
          format.js { render file: 'shared/create_favourite.js.slim' }
        end
      else
        render nothing: true, status: 404
      end
    rescue ActiveRecord::RecordInvalid
      render nothing: true, status: 404
    end
  end

  def destroy_favourite
    begin
      @favourite = Favourite.find_by(user_id: current_user.id, favorable_id: @object.id, favorable_type: @object.class.name.classify.constantize.to_s)
      @favourite.destroy
      respond_to do |format|
        format.js { render file: 'shared/destroy_favourite.js.slim' }
      end
    rescue ActiveRecord::RecordInvalid
      render nothing: true, status: 404
    end
  end

  def path_to(object)
    controller_name = if object.class.name.include?('Actor')
                        ("Actor").classify.constantize.to_s.underscore.pluralize
                      elsif object.class.name.include?('Act')
                        ("Act").classify.constantize.to_s.underscore.pluralize
                      else
                        object.class.to_s.underscore.pluralize
                      end

    url_for( controller: controller_name,
             action: :show,
             id: object.to_param,
             only_path: true )
  end
end
