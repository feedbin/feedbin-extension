import { Controller } from "../lib/stimulus.js"
import { sharedStore } from "../store.js"
import { gzip } from "../helpers.js"

export default class extends Controller {
  static targets = ["error", "submitButton"]
  static values = {
    state: String,
  }

  #states = {
    initial: "initial",
    loading: "loading",
    saved: "saved",
    error: "error"
  }

  async submit(event) {
    this.stateValue = this.#states.loading
    this.errorTarget.textContent = ""
    this.submitButtonTarget.disabled = true

    try {
      const user = sharedStore.getUser()
      const pageInfo = sharedStore.getPageInfo()

      const json = JSON.stringify({
        page_token: user.page_token,
        url: pageInfo.url,
        title: pageInfo.title,
        content: pageInfo.content
      })

      const body = await gzip(json)
      const request = {
        method: this.element.method || "POST",
        headers: {
          "Content-Type": "application/json",
          "Content-Encoding": "gzip",
        },
        body: body,
      }

      const response = await fetch(this.element.action, request)

      if (!response.ok) {
        const error = new Error(`Invalid response`)
        error.response = response
        throw error
      }

      this.stateValue = this.#states.saved;
    } catch (error) {
      this.stateValue = this.#states.error;
      if ("response" in error) {
        this.errorTarget.textContent = `Error Saving Page: ${error.response.statusText}`
      } else {
        this.errorTarget.textContent = `${error}`
      }
      console.log("save submit_error", error)
    }
  }
}
