import { Controller } from "@hotwired/stimulus"

// Floating flash toast: fades in on connect, auto-dismisses after delayValue ms,
// and can be dismissed early via data-action="toast#close".
export default class extends Controller {
  static values = { delay: { type: Number, default: 5000 } }

  connect() {
    // Animate in on the next frame so the initial hidden classes apply first.
    requestAnimationFrame(() => {
      this.element.classList.remove("opacity-0", "translate-x-2")
    })

    if (this.delayValue > 0) {
      this.timeout = setTimeout(() => this.close(), this.delayValue)
    }
  }

  close() {
    clearTimeout(this.timeout)
    this.element.classList.add("opacity-0", "translate-x-2")
    this.element.addEventListener("transitionend", () => this.element.remove(), { once: true })
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
