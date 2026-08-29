import { Controller } from "@hotwired/stimulus"

const currency = new Intl.NumberFormat("en-US", {
  style: "currency",
  currency: "USD",
  maximumFractionDigits: 0,
})

export default class extends Controller {
  static targets = ["input", "percent", "dollar", "perpetuity"]
  static values = {
    ongoingAmount: Number,
    payoutRate: Number,
    limit: { type: Number, default: 100 },
  }

  update() {
    const percent = this.clampedValue()
    const dollar = Math.round((percent / 100) * this.ongoingAmountValue)
    const perpetuity = Math.round(dollar * this.payoutRateValue)

    // Unitless: the stylesheet scales these into the thumb's travel space.
    this.inputTarget.style.setProperty("--slider-value", String(percent))
    this.inputTarget.style.setProperty("--slider-limit", String(this.limitValue))
    this.inputTarget.classList.toggle("allocation-slider--capped", this.limitValue < 100)
    this.percentTargets.forEach((el) => (el.textContent = `${percent}%`))
    this.dollarTargets.forEach((el) => (el.textContent = currency.format(dollar)))
    if (this.hasPerpetuityTarget) {
      this.perpetuityTarget.textContent = currency.format(perpetuity)
    }
  }

  save() {
    this.clampedValue()
    this.inputTarget.form?.requestSubmit()
  }

  // The input's own max stays at 100 so its value and the CSS fill share one
  // coordinate space; the remaining headroom is enforced here instead.
  clampedValue() {
    const percent = Math.min(Number(this.inputTarget.value), this.limitValue)
    if (percent !== Number(this.inputTarget.value)) {
      this.inputTarget.value = String(percent)
    }
    return percent
  }
}
