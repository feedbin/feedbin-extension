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

    const title       = event.detail?.title || event.detail?.tab?.title || event.detail?.tab?.url
    const siteName    = event.detail?.siteName
    const description = event.detail?.description || ""
    const url         = event.detail?.tab?.url
    const hostname    = getHostname(url)

    // use native favIconUrl except if not available (like Safari)
    const favicon     = event.detail?.tab?.favIconUrl || event.detail?.favicon

    this.formUrlTarget.value = url

    if (favicon) {
      this.hasFaviconValue = true
      this.faviconTarget.setAttribute("src", favicon)
    }

    if (this.formatValue === "add") {
      const addSiteName = siteName || hostname
      this.titleTarget.textContent = sanitize(addSiteName)
      if (addSiteName !== hostname) {
        this.urlTarget.textContent = hostname
      }
    }

    if (this.formatValue === "save") {
      this.titleTarget.textContent = sanitize(title)
      this.descriptionTarget.textContent = sanitize(description)
      if (title !== url) {
        this.urlTarget.textContent = sanitize(url)
      }
    }
  }

  async load() {
    console.log("load");
    try {
      const [tab] = await browser.tabs.query({
        active: true,
        currentWindow: true
      })

      if (tab) {
        await browser.scripting.executeScript({
          target: { tabId: tab.id },
          files: ["assets/javascript/lib/polyfill.js", "assets/javascript/content.js"]
        })
        const faviconUrl = tab.favIconUrl

        let info = await browser.tabs.sendMessage(tab.id, {action: "loadPageInfo"}) || {}
        info["tab"] = tab

        console.log("info", info);
        this.pageInfoLoaded({ detail: info })
      } else {
        console.log("could not get tab info");
        this.pageInfoError()
      }
    } catch (error) {
      if (typeof tab !== "undefined") {
        this.pageInfoLoaded({ detail: { tab } })
      } else {
        this.pageInfoError()
      }
      console.error("Error getting tab information:", error)
    } finally {

    }
  }

}
