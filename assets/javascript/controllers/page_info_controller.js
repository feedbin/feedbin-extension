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
          files: ['assets/javascript/lib/polyfill.js', 'assets/javascript/content.js']
        })
        const faviconUrl = tab.favIconUrl

        let info = await browser.tabs.sendMessage(tab.id, {action: "loadPageInfo"})
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
      console.error('Error getting tab information:', error)
    } finally {

    }
  }

}
