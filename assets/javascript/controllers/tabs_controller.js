import { Controller } from "../lib/stimulus.js"
export default class extends Controller {
  static targets = ["tab"]

  connect() {
    this.selectTab()
  }

  async selectTab() {
    let selectedTab = "tab-settings"

    const result = await browser.storage.sync.get()
    if ("user" in result && "email" in result.user) {
      selectedTab = "tab-add"
    }

    this.tabTargets.forEach((element, index) => {
      if (element.value === selectedTab) {
        element.checked = true
      }
    })
  }
}
