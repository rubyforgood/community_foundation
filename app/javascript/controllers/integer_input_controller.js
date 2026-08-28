import { Controller } from "@hotwired/stimulus"

// The app primarily accepts values in whole dollar amounts only (no cents),
// So we do not allow cents from being submitted in the UI.
export default class extends Controller {
  transform() {
    const value = this.element.value
    const sanitized = value.replace(/\D/g, "")
    if (value !== sanitized) {
      this.element.value = sanitized
    }
  }
}