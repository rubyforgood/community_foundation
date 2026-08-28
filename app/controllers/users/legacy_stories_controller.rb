class Users::LegacyStoriesController < ApplicationController
  def show
    @user_legacy_story = user_legacy_story
  end

  def update
    @user_legacy_story = user_legacy_story

    if @user_legacy_story.update(user_legacy_story_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "flash", partial: "shared/toast", locals: { type: :notice, message: "Saved." }
          )
        end
        format.html { redirect_to users_legacy_story_path, notice: "Saved." }
      end
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def user_legacy_story
    Current.user.user_legacy_story || Current.user.build_user_legacy_story
  end

  def user_legacy_story_params
    params.require(:user_legacy_story).permit(*UserLegacyStory::FIELDS)
  end
end
