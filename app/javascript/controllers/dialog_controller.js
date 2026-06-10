import { Controller } from "@hotwired/stimulus"

// Opens/closes the <dialog> target within this controller's scope.
// Trigger with data-action="dialog#open" / "dialog#close".
export default class extends Controller {
  static targets = ["dialog"]

  open() {
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }
}
