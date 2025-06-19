import { Controller } from "../lib/stimulus.js"
import { sanitize, getHostname } from "../helpers.js"

export default class extends Controller {
  static targets = ["error", "favicon", "title", "description", "url", "formUrl"]
  static values = {
    hasError: Boolean,
    hasData: Boolean,
    hasFavicon: Boolean,
    format: String,
  }

  pageInfoError(event) {
    this.hasDataValue = false
    this.hasErrorValue = true
  }

  pageInfoLoaded(event) {
    this.hasErrorValue = false
    this.hasDataValue = true

    if (event.detail?.favicon) {
      this.hasFaviconValue = true
      this.faviconTarget.setAttribute("src", event.detail?.favicon)
    }

    if (this.formatValue === "add") {
      const addSiteName = event.detail?.siteName || event.detail?.hostname
      this.titleTarget.textContent = sanitize(addSiteName)
      if (addSiteName !== event.detail?.hostname) {
        this.urlTarget.textContent = event.detail?.hostname
      }
    }

    if (this.formatValue === "save") {
      this.titleTarget.textContent = sanitize(event.detail?.title)

      if (event.detail?.description) {
        this.descriptionTarget.textContent = sanitize(event.detail?.description)
      }

      this.urlTarget.textContent = sanitize(event.detail?.url)
    }
  }
}
