import { Controller } from "@hotwired/stimulus"

// The app primarily accepts values in whole dollar amounts only (no cents),
// So we do not allow cents from being submitted in the UI.
export default class extends Controller {
  static values = { invalidMessage: { type: String, default: "Whole numbers only" } }

  connect() {
    this.element.addEventListener("keydown", this.rejectInvalidKey)
    this.element.addEventListener("paste", this.rejectInvalidPaste)
  }

  disconnect() {
    this.element.removeEventListener("keydown", this.rejectInvalidKey)
    this.element.removeEventListener("paste", this.rejectInvalidPaste)
    this.clearCustomValidity()
  }

  rejectInvalidKey = (event) => {
    if (event.ctrlKey || event.metaKey || event.altKey) return
    if (event.key.length > 1) return
    if (/\D/.test(event.key)) {
      event.preventDefault()
      this.reportError()
    }
  }

  rejectInvalidPaste = (event) => {
    const text = event.clipboardData.getData("text")
    if (/\D/.test(text)) {
      event.preventDefault()
      this.reportError()
    }
  }

  transform() {
    const value = this.element.value
    const sanitized = value.replace(/\D/g, "")
    if (value !== sanitized) {
      this.element.value = sanitized
      this.reportError()
    } else {
      this.clearCustomValidity()
    }
  }

  reportError() {
    const input = this.element
    if (input.setCustomValidity) {
      input.setCustomValidity(this.invalidMessageValue)
      input.reportValidity()
    }
  }

  clearCustomValidity() {
    if (this.element.setCustomValidity) {
      this.element.setCustomValidity("")
    }
  }
}
