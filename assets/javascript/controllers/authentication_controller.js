import { Controller } from "../lib/stimulus.js"
import { checkAuth, signOut } from "../helpers.js"

export default class extends Controller {
  static targets = ["results", "email", "password", "submitButton", "error", "signedInAs", "form"]
  static values = {
    loading: Boolean,
    url: String,
    iosAuth: Boolean
  }

  async connect() {
    await this.appAuth()
  }

  async appAuth() {
    if ("sendNativeMessage" in browser.runtime) {
      const response = await browser.runtime.sendNativeMessage("application.id", {action: "authorize"})
      if (response.credentials) {
        this.emailTarget.value = response.credentials.email
        this.passwordTarget.value = response.credentials.password
        await this.submit()
      } else {
        this.iosAuthValue = false
        await signOut()
      }
    }
  }

  async submit(event) {
    this.submitButtonTarget.disabled = true
    this.loadingValue = true
    this.errorTarget.textContent = ""

    const formData = new FormData(this.formTarget)
    let data = {}
    try {
      const response = await fetch(this.formTarget.action, {
        method: this.formTarget.method || "POST",
        body: new URLSearchParams(formData),
      })

      if (!response.ok) {
        const error = new Error(`Invalid response`)
        error.response = response
        throw error
      }

      data = await response.json()
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
      console.trace("Request failed:", error)
    }

    this.submitButtonTarget.disabled = false
    this.loadingValue = false

    if ("page_token" in data) {
      let user = {
        page_token: data.page_token,
        email: this.emailTarget.value,
      }
      await browser.storage.sync.set({ user })
      checkAuth()
    }
  }
}
