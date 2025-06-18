import { Controller } from "../lib/stimulus.js"
export default class extends Controller {
  static targets = ["tab"]
  static values = {
    authorized: Boolean
  }

  connect() {
    this.authorize()
  }

  async authorize() {
    let selectedTab = "tab-settings"
    this.authorizedValue = false

    const result = await browser.storage.sync.get();
    if ("user" in result && "email" in result.user) {
      this.authorizedValue = true
      selectedTab = "tab-add"
      this.dispatch("authorized")
    }

    this.tabTargets.forEach((element, index) => {
      if (element.value === selectedTab) {
        element.checked = true
      }
    })
  }
}
