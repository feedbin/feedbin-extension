import { Controller } from "../lib/stimulus.js"
import { sharedStore } from "../store.js"
import { getHostname } from "../helpers.js"

export default class extends Controller {
  static values = {
    authorized: Boolean,
  }

  connect() {
    this.authorize()
  }

  async authorize() {
    this.authorizedValue = false

    const result = await browser.storage.sync.get()
    if (!result.user?.email) {
      return
    }

    this.authorizedValue = true
    sharedStore.setUser(result.user)
    this.dispatch("authorized")

    await this.loadPageData()
  }

  async loadPageData() {
    console.log("load")
    try {
      const [tab] = await browser.tabs.query({
        active: true,
        currentWindow: true,
      })

      if (tab) {
        await browser.scripting.executeScript({
          target: { tabId: tab.id },
          files: ["assets/javascript/lib/extension-polyfill.js", "assets/javascript/content.js"],
        })

        let data = (await browser.tabs.sendMessage(tab.id, { action: "loadPageInfo" })) || {}
        this.pageDataLoaded(tab, data)
      } else {
        this.dispatch("pageInfoError")
      }
    } catch (error) {
      if (typeof tab !== "undefined") {
        this.pageDataLoaded(tab, {})
      } else {
        this.dispatch("pageInfoError")
      }
      console.error("Error getting tab information:", error)
    }
  }

  pageDataLoaded(tab, data) {
    const result = {
      title: data.title || tab?.title || "Untitled",
      siteName: data.siteName,
      description: data.description,
      url: tab.url,
      hostname: getHostname(tab.url),
      favicon: tab.favIconUrl || data.favicon,
      content: data.content,
    }
    sharedStore.setPageInfo(result)
    console.log("sharedStore", sharedStore.getPageInfo())
    this.dispatch("pageInfoLoaded", { detail: result })
  }
}
