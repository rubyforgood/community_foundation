class Users::BiographiesController < ApplicationController
  before_action :set_biography

  def show
  end

  def update
    if @biography.update(biography_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "flash", partial: "shared/toast", locals: { type: :notice, message: "Saved." }
          )
        end
        format.html { redirect_to users_biography_path, notice: "Saved." }
      end
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_biography
    @biography = Current.user.biography || Current.user.build_biography
  end

  def biography_params
    params.require(:user_biography).permit(:birth_date, :birthplace, *UserBiography::NARRATIVE_FIELDS)
  end
end
