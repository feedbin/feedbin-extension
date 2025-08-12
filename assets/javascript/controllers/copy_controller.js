import { Controller } from "../lib/stimulus.js"

export default class extends Controller {
  static targets = ["copyMessage"]
  static values = {
    copied: Boolean,
    data: String,
  }

  copy(event) {
    this.copiedValue = true
    setTimeout(() => {
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
