import { Controller } from "@hotwired/stimulus"

// Collapses a wrapping row of chips down to a fixed number of rows, with a
// toggle button at the end of the last visible row to reveal the rest.
export default class extends Controller {
  static targets = ["chip", "button"]
  static values = { rows: { type: Number, default: 2 }, expanded: Boolean }

  connect() {
    // Default to expanded when a chip in this category is already selected, so
    // the active preference is visible without having to click "Show more".
    if (this.chipTargets.some((chip) => chip.querySelector("input")?.checked)) {
      this.expandedValue = true
    }
    this.onResize = () => this.layout()
    this.resizeObserver = new ResizeObserver(this.onResize)
    this.resizeObserver.observe(this.element)
    window.addEventListener("resize", this.onResize)
    this.layout()
  }

  disconnect() {
    if (this.resizeObserver) this.resizeObserver.disconnect()
    window.removeEventListener("resize", this.onResize)
  }

  toggle() {
    this.expandedValue = !this.expandedValue
    this.layout()
  }

  layout() {
    if (!this.hasButtonTarget) return

    // Reset: reveal everything so positions can be measured.
    this.chipTargets.forEach((chip) => (chip.hidden = false))
    this.buttonTarget.hidden = true

    if (this.expandedValue) {
      this.buttonTarget.textContent = "Show less"
      this.buttonTarget.hidden = false
      return
    }

    const tops = [...new Set(this.chipTargets.map((chip) => Math.round(chip.offsetTop)))].sort(
      (a, b) => a - b,
    )

    // Already fits within the row budget — nothing to collapse.
    if (tops.length <= this.rowsValue) return

    const cutoff = tops[this.rowsValue - 1]
    let hidden = 0
    this.chipTargets.forEach((chip) => {
      if (Math.round(chip.offsetTop) > cutoff) {
        chip.hidden = true
        hidden++
      }
    })

    // Reveal the button at the end of the last visible row. If it wrapped past
    // the cutoff, hide trailing chips until it fits.
    this.buttonTarget.hidden = false
    const visibleChips = this.chipTargets.filter((chip) => !chip.hidden)
    let i = visibleChips.length - 1
    while (Math.round(this.buttonTarget.offsetTop) > cutoff && i >= 0) {
      visibleChips[i].hidden = true
      hidden++
      i--
    }

    this.buttonTarget.textContent = `Show more (+${hidden})`
  }
}
