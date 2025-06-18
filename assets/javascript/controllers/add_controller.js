import { Controller } from "../lib/stimulus.js"
export default class extends Controller {
  static targets = ["error", "favicon", "title", "description", "url"]
  static values = {
    hasError: Boolean,
    hasData: Boolean,
    hasFavicon: Boolean,
  }

  pageInfoError(event) {
    console.log("pageInfoError", event);
    this.hasDataValue = false
    this.hasErrorValue = true
  }

  pageInfoLoaded(event) {
    console.log("pageInfoLoaded", event);
    this.hasErrorValue = false
    this.hasDataValue = true

    if (event.detail?.tab?.favIconUrl) {
      this.hasFaviconValue = true
      this.faviconTarget.setAttribute("src", event.detail.tab.favIconUrl)
    }

    this.titleTarget.textContent = event.detail?.title || event.detail?.tab?.title || event.detail?.tab?.url
    this.descriptionTarget.textContent = event.detail?.description || ""
    if (this.titleTarget.textContent !== event.detail?.tab?.url) {
      this.urlTarget.textContent = event.detail?.tab?.url
    }
  }
}
