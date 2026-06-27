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
    const dollar = Math.round((percent / 100) * this.ongoingAmountValue)
    const perpetuity = Math.round(dollar * this.payoutRateValue)

    this.inputTarget.style.setProperty("--slider-value", `${percent}%`)
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
