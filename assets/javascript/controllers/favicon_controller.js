import { Controller } from "../lib/stimulus.js"

export default class extends Controller {
  static targets = ["favicon"];
  static values = { hasFavicon: Boolean };

  load(url) {
    if (url) {
      this.faviconTarget.src = url;
      this.hasFaviconValue = true;
    }
  }
}