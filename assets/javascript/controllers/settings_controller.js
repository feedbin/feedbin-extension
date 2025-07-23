import { Controller } from "../lib/stimulus.js"
import { signOut } from "../helpers.js"

export default class extends Controller {
  static targets = ["signedInAs"]

  connect() {
    this.userData()
  }

  async userData() {
    let result = await browser.storage.sync.get()
    if ("user" in result && "email" in result.user) {
      this.signedInAsTarget.textContent = result.user.email
    }
  }

  async signOut() {
    await signOut()
  }
}
