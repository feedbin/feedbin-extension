import { Controller } from "../lib/stimulus.js"
import { sharedStore } from "../store.js"

export default class extends Controller {
  static targets = ["submitButton", "error"]
  static values = {
    loading: Boolean,
    url: String
  }

  async submit(event) {
    console.log(event);

    this.submitButtonTarget.disabled = true
    this.loadingValue = true
    this.errorTarget.textContent = ""

    const user = sharedStore.getUser()
    const pageInfo = sharedStore.getPageInfo()

    const formData = new FormData(this.element);
    formData.append("page_token", user.page_token);
    formData.append("url", pageInfo.url);

    let data = {}
    try {
      const response = await fetch(this.element.action, {
        method: this.element.method || "POST",
        body: new URLSearchParams(formData)
      });

      if (!response.ok) {
        const error = new Error(`Invalid response`)
        error.response = response
        throw error;
      }

      data = await response.json();
      console.log(data);
    } catch (error) {
      if ("response" in error) {
        this.errorTarget.textContent = `Invalid response: ${error.response.statusText}`
      } else {
        this.errorTarget.textContent = `Unknown error.`
      }
    }

    this.submitButtonTarget.disabled = false
    this.loadingValue = false
  }
}
