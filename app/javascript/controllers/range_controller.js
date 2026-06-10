import { Controller } from "@hotwired/stimulus"

// Mirrors a range input's value into an output element as it moves.
export default class extends Controller {
  static targets = ["input", "output"]

  update() {
    this.outputTarget.textContent = this.inputTarget.value
  }
}
