import { Controller } from "../lib/stimulus.js"

// State for a single feed result. Tailwind variants do the showing and hiding,
// add_controller seeds the values while hydrating the template.
export default class extends Controller {
  static values = {
    subscribed: Boolean,
    // One of: url, tags, muted, error
    status: String
  }
}
