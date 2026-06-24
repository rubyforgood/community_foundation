import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static classes = ["activeTab", "inactiveTab"]

  connect() {
    const active = this.tabTargets.find((tab) => tab.dataset.active === "true") || this.tabTargets[0]
    if (active) this.activate(active.dataset.type)
  }

  switch(event) {
    this.activate(event.params.type)
  }

  activate(type) {
    this.tabTargets.forEach((tab) => {
      const on = tab.dataset.type === type
      tab.classList.add(...(on ? this.activeTabClasses : this.inactiveTabClasses))
      tab.classList.remove(...(on ? this.inactiveTabClasses : this.activeTabClasses))
    })
    this.panelTargets.forEach((panel) => {
      panel.classList.toggle("hidden", panel.dataset.type !== type)
    })
    this.dispatch("change", { detail: { type } })
  }
}
