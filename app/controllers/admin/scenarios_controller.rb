class Admin::ScenariosController < Admin::ApplicationController
  PER_PAGE = 50

  def index
    @query = params[:q].to_s.strip
    @page = [ params[:page].to_i, 1 ].max
    @offset = (@page - 1) * PER_PAGE

    scope = Current.organization.scenarios
                   .includes(:user)
                   .references(:user)
                   .order("users.name", "users.email_address", :name)

    if @query.present?
      like = "%#{Scenario.sanitize_sql_like(@query.downcase)}%"
      scope = scope.where("LOWER(users.name) LIKE :q OR LOWER(users.email_address) LIKE :q", q: like)
    end

    @total = scope.count
    @scenarios = scope.limit(PER_PAGE).offset(@offset)
    @has_more = @offset + @scenarios.size < @total
  end
end
