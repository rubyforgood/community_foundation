module ScenariosHelper
  CHART_COLORS = [ "#E07B39", "#D9632B", "#C99A2E", "#B8842B", "#E0954F", "#C76A28" ].freeze

  def allocation_chart_color(index)
    CHART_COLORS[index % CHART_COLORS.length]
  end

  def allocation_pie_gradient(allocations, remaining, total)
    # Mirrors the bar chart's flexbox shrink: percentages are only scaled down
    # when they overallocate past 100%, never stretched to fill an underallocation.
    divisor = [ total, 100 ].max.to_f
    cumulative = 0
    stops = allocations.each_with_index.map do |allocation, index|
      start = cumulative
      cumulative += allocation.percentage.to_f / divisor * 100
      "#{allocation_chart_color(index)} #{start}% #{cumulative}%"
    end
    stops << "var(--color-line-soft) #{cumulative}% 100%" if remaining.positive?
    "conic-gradient(#{stops.join(', ')})"
  end

  def remaining_ongoing_percentage(scenario, allocation)
    others = scenario.ongoing_allocations.where.not(id: allocation.id).sum(:percentage)
    [ 100 - others, 0 ].max
  end
end
