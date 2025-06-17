import { Controller } from "../lib/stimulus.js"
export default class extends Controller {
  static targets = []
  static values = {
    authorized: Boolean
  }

  connect() {
    this.authorize()
  }

  async authorize() {
    let result = await browser.storage.sync.get();
    if ("user" in result && "email" in result.user) {
      this.authorizedValue = true
    } else {
      this.authorizedValue = false
    }
  }
}
