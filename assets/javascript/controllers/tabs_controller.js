import { Controller } from "../lib/stimulus.js"

export default class extends Controller {
  static targets = ["tab", "tabContainer"]

  #separatorClass = "hide-separator"

  connect() {
    this.selectTab()
  }

  async selectTab() {
    let selectedTab = "tab-settings"

    const result = await browser.storage.sync.get()
    if ("user" in result && "email" in result.user) {
      selectedTab = result.tab || "tab-add"
    }

    this.select(selectedTab)
  }

  select(tab) {
    this.tabTargets.forEach((element, index) => {
      if (element.value === tab) {
        element.checked = true
        const event = new Event("change", { bubbles: true })
        element.dispatchEvent(event)
      }
    })
  }

  async save(event) {
    const tab = event.target.value
    if (tab === "tab-settings") {
      return
    }
    await browser.storage.sync.set({ tab })
  }

  separator(event) {
    this.tabContainerTargets.forEach((element) => element.classList.remove(this.#separatorClass) )
    this.tabContainerTargets.forEach((element, index) => {
      if (element.contains(event.target)) {
        const sibling = this.tabContainerTargets[index + 1]
        if (sibling) {
          sibling.classList.add(this.#separatorClass)
        }
      }
    })
  }
}
