import { Controller } from "@hotwired/stimulus"

const currency = new Intl.NumberFormat("en-US", {
  style: "currency",
  currency: "USD",
  maximumFractionDigits: 0,
})

// Keeps a one-time giving amount within the scenario's remaining giving budget.
// Sets a custom-validity message so the browser blocks submission (via native
// constraint validation, regardless of number-input support) and shows a
// friendly error without closing the modal.
export default class extends Controller {
  static values = { max: Number }

  connect() {
    this.element.addEventListener("input", this.validate)
    this.validate()
  }

  disconnect() {
    this.element.removeEventListener("input", this.validate)
  }

  validate = () => {
    const over = this.element.value !== "" && Number(this.element.value) > this.maxValue
    this.element.setCustomValidity(over ? this.message : "")
  }

  get message() {
    return `Enter an amount of ${currency.format(this.maxValue)} or less — that's your remaining one-time giving budget.`
  }
}