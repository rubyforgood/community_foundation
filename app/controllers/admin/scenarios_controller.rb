class Admin::ScenariosController < Admin::ApplicationController
  PER_PAGE = 50

  def index
    @query = params[:q].to_s.strip
    @page = [ params[:page].to_i, 1 ].max
    @offset = (@page - 1) * PER_PAGE

    scope = Current.organization.scenarios.search_by_user(@query).order(:name)
    @total = scope.count
    @has_more = @offset + PER_PAGE < @total
    @scenarios = scope.limit(PER_PAGE).offset(@offset)
  end
end
