import { Controller } from "../lib/stimulus.js"
export default class extends Controller {
  static targets = [ "results", "email", "password", "submitButton", "error" ]
  static values = {
    loading: Boolean,
    url: String
  }

  connect() {
    console.log("sign in");
  }

  async submit(event) {
    console.log(event);

    this.submitButtonTarget.disabled = true
    this.loadingValue = true
    this.errorTarget.textContent = ""

    const formData = new FormData(this.element);
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
    } catch (error) {
      if ("response" in error) {
        if (error.response.status == 401) {
          this.errorTarget.textContent = "Invalid email or password."
        } else {
          this.errorTarget.textContent = `Invalid response: ${error.response.statusText}`
        }
      }
      console.error("Request failed:", error);
    }

    this.submitButtonTarget.disabled = false
    this.loadingValue = false

    if ("page_token" in data) {
      await browser.storage.sync.set({ page_token: data.page_token });
      let result = await browser.storage.sync.get("page_token");
      console.log("result", result);
      this.resultsTarget.textContent = result
    }
  }
}
