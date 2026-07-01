import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "label"]
  static values = { confirmDuration: { type: Number, default: 1500 } }

  select() {
    this.sourceTarget.select()
  }

  async copy() {
    try {
      await navigator.clipboard.writeText(this.sourceTarget.value)
    } catch {
      this.sourceTarget.select()
      document.execCommand("copy")
    }

    if (this.hasLabelTarget) {
      const original = this.labelTarget.textContent
      this.labelTarget.textContent = "Copied!"
      setTimeout(() => { this.labelTarget.textContent = original }, this.confirmDurationValue)
    }
  }
}
