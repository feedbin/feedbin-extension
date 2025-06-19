import { Controller } from "../lib/stimulus.js"
import { pageToken } from "../helpers.js"

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

    const formData = new FormData(this.element);

    let token = await pageToken()
    console.log("token", token);
    formData.append("page_token", token);

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
        if (error.response.status == 401) {
          this.errorTarget.textContent = "Invalid email or password."
        } else {
          this.errorTarget.textContent = `Invalid response: ${error.response.statusText}`
        }
      } else {
        this.errorTarget.textContent = `Unknown error.`
      }
      console.error("Request failed:", error);
    }

    this.submitButtonTarget.disabled = false
    this.loadingValue = false
  }
}
