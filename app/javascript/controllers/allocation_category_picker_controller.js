import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "search", "row", "tab", "tabPanel", "categoryId", "optionField", "label", "customInput"]
  static classes = ["activeTab", "inactiveTab"]

  connect() {
    this.activateInitialTab()
    document.addEventListener("click", this.onOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.onOutsideClick)
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

  onOutsideClick = (event) => {
    if (!this.element.contains(event.target)) this.close()
  }
}
