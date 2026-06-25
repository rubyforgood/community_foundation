module ScenariosHelper
  CHART_COLORS = [ "#E07B39", "#D9632B", "#C99A2E", "#B8842B", "#E0954F", "#C76A28" ].freeze

  def allocation_chart_color(index)
    CHART_COLORS[index % CHART_COLORS.length]
  end
end
