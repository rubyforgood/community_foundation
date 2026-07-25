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

  # The slider's max must never sit below the allocation's own current percentage —
  # otherwise pre-existing over-allocated data (from before this cap existed) would
  # render as if maxed out at the wrong position. It still blocks dragging any higher.
  def allocation_slider_max(scenario, allocation)
    [ remaining_ongoing_percentage(scenario, allocation), allocation.percentage.to_i ].max
  end

  # The slider's CSS fill (--slider-value) is a percentage of the *track*, not of the
  # underlying value, so once max drops below 100 it must be rescaled or the colored
  # fill and the native thumb position (which follows value/max) drift apart.
  def allocation_slider_fill_percent(percentage, max)
    return 0 if max.to_i.zero?

    (percentage.to_f / max * 100).round(2)
  end
end
