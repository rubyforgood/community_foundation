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
  }

  update() {
    const percent = Number(this.inputTarget.value)
    const max = Number(this.inputTarget.max) || 100
    const dollar = Math.round((percent / 100) * this.ongoingAmountValue)
    const perpetuity = Math.round(dollar * this.payoutRateValue)

    // --slider-value fills the track (0-max), which is distinct from percent
    // (0-100) once the slider's max is capped below 100 by remaining headroom.
    const fillPercent = max > 0 ? (percent / max) * 100 : 0
    this.inputTarget.style.setProperty("--slider-value", `${fillPercent}%`)
    this.percentTargets.forEach((el) => (el.textContent = `${percent}%`))
    this.dollarTargets.forEach((el) => (el.textContent = currency.format(dollar)))
    if (this.hasPerpetuityTarget) {
      this.perpetuityTarget.textContent = currency.format(perpetuity)
    }
  }

  save() {
    this.inputTarget.form?.requestSubmit()
  }
}
