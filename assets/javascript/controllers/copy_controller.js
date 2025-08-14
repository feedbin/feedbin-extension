import { Controller } from "../lib/stimulus.js"

export default class extends Controller {
  static targets = ["copyMessage"]
  static values = {
    copied: Boolean,
    data: String,
  }

  #timeout = null

  copy(event) {
    this.copiedValue = true
    clearTimeout(this.#timeout)
    this.#timeout = setTimeout(() => {
      this.copiedValue = false
    }, 1000)
    navigator.clipboard.writeText(this.dataValue).then(
      () => {
        this.successValue = true
        setTimeout(() => {
          this.successValue = false
        }, 1000)
      },
      () => {
        console.log("failed")
      }
    )
    event.preventDefault()
  }
}
