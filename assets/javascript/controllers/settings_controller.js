import { Controller } from "../lib/stimulus.js"
export default class extends Controller {
  static targets = [ "results", "email", "password", "submitButton", "error", "signedInAs" ]
  static values = {
    loading: Boolean,
    url: String
  }

  connect() {
    this.userData()
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
      } else {
        this.errorTarget.textContent = `Unknown error.`
      }
      console.error("Request failed:", error);
    }

    this.submitButtonTarget.disabled = false
    this.loadingValue = false

    if ("page_token" in data) {
      let user = {
        page_token: data.page_token,
        email: this.emailTarget.value
      }
      await browser.storage.sync.set({user});
      await this.userData();
      this.dispatch("authorize")
    }
  }

  async userData() {
    let result = await browser.storage.sync.get();
    if ("user" in result && "email" in result.user) {
      this.signedInAsTarget.textContent = result.user.email
    }
  }

  async signOut() {
    let result = await browser.storage.sync.remove("user");
    this.dispatch("authorize")
  }
}
