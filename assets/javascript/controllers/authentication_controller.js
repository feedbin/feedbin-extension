import { Controller } from "../lib/stimulus.js"
import { checkAuth, signOut } from "../helpers.js"
import { httpClient } from "../http_client.js"
import { store } from "../store.js"

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
    const browserName = store.get("browser")
    if (browserName === "ios" && "sendNativeMessage" in browser.runtime) {
      const response = await browser.runtime.sendNativeMessage("application.id", {action: "authorize"})
      if (response.credentials) {
        this.emailTarget.value = response.credentials.email
        this.passwordTarget.value = response.credentials.password
        await this.formTarget.requestSubmit()
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

    let data = {}
    try {
      const response = await httpClient.sendForm(event)

      data = await response.json()
    } catch (error) {
      if ("response" in error) {
        if (error.response.status === 401) {
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
