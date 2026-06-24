import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { basePath: String, type: String }

  connect() {
    this.setType(this.typeValue)
  }

  update(event) {
    this.setType(event.detail.type)
  }

  setType(type) {
    if (!type) return
    this.element.href = `${this.basePathValue}?type=${encodeURIComponent(type)}`
  }
}
