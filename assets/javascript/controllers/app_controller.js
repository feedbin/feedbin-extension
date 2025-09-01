import { Controller } from "../lib/stimulus.js"
import { store, getHostname, detectBrowser, afterTransition, debounce } from "../helpers.js"

export default class extends Controller {
  static targets = ["footerSpacer", "scrollContainer", "contentContainer"]
  static values = {
    authorized: Boolean,
    browser: String,
    footerBorder: Boolean,
    headerBorder: Boolean,
    native: Boolean,
  }

  connect() {
    this.authorize()
    this.browserValue = detectBrowser()
    if ((this.browserValue === "ios" || this.browserValue === "ipad") && "sendNativeMessage" in browser.runtime) {
      this.nativeValue = true
      store.update("native", true)
    }
    store.update("browser", this.browserValue)
  }

  async authorize() {
    this.authorizedValue = false

    const result = await browser.storage.sync.get()
    if (!result.user?.email) {
      this.dispatch("notAuthorized")
      return
    }

    this.authorizedValue = true
    store.update("user", result.user)

    this.dispatch("authorized")
    await this.loadPageData()
  }

  checkScroll() {
    const visibleScrollContainer = this.scrollContainerTargets.find((element) => element.checkVisibility())
    if (!visibleScrollContainer) {
      return
    }

    const scrollTop = visibleScrollContainer.scrollTop
    const scrollHeight = visibleScrollContainer.scrollHeight
    const clientHeight = visibleScrollContainer.clientHeight
    const maxScroll = scrollHeight - clientHeight

    if (scrollTop > 0) {
      this.headerBorderValue = true
    } else {
      this.headerBorderValue = false
    }

    if (scrollHeight > clientHeight && scrollTop < maxScroll) {
      this.footerBorderValue = true
    } else {
      this.footerBorderValue = false
    }
  }

  delayedCheckScroll() {
    if (this.hasFooterSpacerTarget) {
      afterTransition(this.footerSpacerTarget, true, () => {
        this.checkScroll()
      })
    }
  }

  async loadPageData() {
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
      console.trace("Error getting tab information:", error)
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
    store.update("pageInfo", result)
    this.dispatch("pageInfoLoaded", { detail: result })
  }
}
