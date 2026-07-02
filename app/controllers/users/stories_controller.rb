class Users::StoriesController < ApplicationController
  def show
    @user = Current.user
  end

  def update
    @user = Current.user

    if @user.update(story_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "flash", partial: "shared/toast", locals: { type: :notice, message: "Saved." }
          )
        end
        format.html { redirect_to users_story_path, notice: "Saved." }
      end
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def story_params
    params.require(:user).permit(:background, :family, :formative_experiences)
  end
end
