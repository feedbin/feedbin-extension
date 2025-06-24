import { Controller } from "../lib/stimulus.js"
import { sharedStore } from "../store.js"

export default class extends Controller {
  static targets = ["error"]
  static values = {
    url: String,
    hasError: Boolean,
    hasResults: Boolean,
  }

  async search(event) {
    const user = sharedStore.getUser()
    const pageInfo = sharedStore.getPageInfo()

    const formData = new FormData(this.element)
    formData.append("page_token", user.page_token)
    formData.append("url", pageInfo.url)

    try {
      const response = await fetch(this.element.action, {
        method: this.element.method || "POST",
        body: new URLSearchParams(formData),
      })

      if (!response.ok) {
        const error = new Error(`Invalid response`)
        error.response = response
        throw error
      }

      const data = await response.json()

      if (data.feeds.length === 0) {
        this.hasErrorValue = true
        this.errorTarget.textContent = "No feeds found"
      } else {
        this.hasResultsValue = true
        this.dispatch("resultsLoaded", { detail: data })
      }
    } catch (error) {
      this.hasErrorValue = true
      if ("response" in error) {
        this.errorTarget.textContent = `Invalid response: ${error.response.statusText}`
      } else {
        this.errorTarget.textContent = `Unknown error. ${error}`
      }
    }
  }
}
