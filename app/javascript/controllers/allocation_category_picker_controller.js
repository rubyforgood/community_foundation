import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "search", "row", "tab", "tabPanel", "categoryId", "optionField", "label", "customInput", "trigger", "error"]
  static classes = ["activeTab", "inactiveTab", "invalid", "valid"]

  connect() {
    this.activateInitialTab()
    document.addEventListener("click", this.onOutsideClick)
    this.form = this.element.closest("form")
    this.form?.addEventListener("submit", this.onSubmit)
    this.dialog = this.element.closest("dialog")
    this.dialog?.addEventListener("close", this.onDialogClose)
  }

  disconnect() {
    document.removeEventListener("click", this.onOutsideClick)
    this.form?.removeEventListener("submit", this.onSubmit)
    this.dialog?.removeEventListener("close", this.onDialogClose)
  }

  toggle() {
    this.panelTarget.hidden = !this.panelTarget.hidden
  }

  close() {
    this.panelTarget.hidden = true
  }

  select(event) {
    const row = event.currentTarget
    this.categoryIdTarget.value = row.dataset.id
    this.optionFieldTarget.value = ""
    if (this.hasCustomInputTarget) this.customInputTarget.value = ""
    this.labelTarget.textContent = row.dataset.name
    this.clearError()
    this.close()
  }

  switchTab(event) {
    this.activateTab(event.currentTarget.dataset.type)
  }

  filter() {
    const query = this.searchTarget.value.trim().toLowerCase()
    this.rowTargets.forEach((row) => {
      row.hidden = !row.dataset.name.toLowerCase().includes(query)
    })
  }

  addCustom() {
    const value = this.customInputTarget.value.trim()
    if (!value) return
    this.optionFieldTarget.value = value
    this.categoryIdTarget.value = ""
    this.labelTarget.textContent = value
    this.clearError()
    this.close()
  }

  activateInitialTab() {
    const active = this.tabTargets.find((tab) => tab.dataset.active === "true") || this.tabTargets[0]
    if (active) this.activateTab(active.dataset.type)
  }

  activateTab(type) {
    this.tabTargets.forEach((tab) => {
      const on = tab.dataset.type === type
      tab.classList.add(...(on ? this.activeTabClasses : this.inactiveTabClasses))
      tab.classList.remove(...(on ? this.inactiveTabClasses : this.activeTabClasses))
    })
    this.tabPanelTargets.forEach((panel) => {
      panel.classList.toggle("hidden", panel.dataset.type !== type)
    })
  }

  // Mirrors Allocation#category_or_option_present so an incomplete form stays
  // open with the error attached to the field instead of closing on submit.
  onSubmit = (event) => {
    if (this.categoryIdTarget.value || this.optionFieldTarget.value) return this.clearError()

    event.preventDefault()
    this.errorTarget.hidden = false
    this.triggerTarget.classList.remove(...this.validClasses)
    this.triggerTarget.classList.add(...this.invalidClasses)
    this.triggerTarget.focus()
  }

  // Cancel, Esc, and backdrop clicks all fire the dialog's close event: reopening
  // should start clean rather than showing the previous attempt's error.
  onDialogClose = () => {
    this.clearError()
    this.close()
  }

  clearError() {
    this.errorTarget.hidden = true
    this.triggerTarget.classList.remove(...this.invalidClasses)
    this.triggerTarget.classList.add(...this.validClasses)
  }

  onOutsideClick = (event) => {
    if (!this.element.contains(event.target)) this.close()
  }
}
