import { Controller } from "../lib/stimulus.js"
import { store, loadFavicon, prettyUrl, httpClient, Hydrate } from "../helpers.js"

export default class extends Controller {
  static targets = ["submitButton", "subscribeForm", "error", "checkbox", "feedTemplate", "feedResults", "tagTemplate", "tagResults", "favicon"]

  static values = {
    searchUrl: String,
    state: String
  }

  #states = {
    initial: "initial",
    hasResults: "hasResults",
    loading: "loading",
    success: "success",
    error: "error"
  }

  async search(event) {
    try {
      const user = store.get("user")
      const pageInfo = store.get("pageInfo")

      const response = await httpClient.sendRequest("POST", this.searchUrlValue, {
        page_token: user.page_token,
        url: pageInfo.url
      })

      const data = response.data

      if (data.feeds.length === 0) {
        this.noFeeds()
      } else {
        this.displayResults(data)
      }
    } catch (error) {
      this.stateValue = this.#states.error
      if ("response" in error) {
        this.errorTarget.textContent = `Invalid response: ${error.response.statusText}`
      } else {
        this.errorTarget.textContent = `Unknown error. ${error}`
      }
      console.trace("search_error", error)
    }
  }

  async subscribe(event) {
    this.submitButtonTarget.disabled = true
    this.stateValue = this.#states.loading
    this.errorTarget.textContent = ""

    try {
      const user = store.get("user")

      const response = await httpClient.sendForm(event, {
        page_token: user.page_token
      })

      this.stateValue = this.#states.success
    } catch (error) {
      this.stateValue = this.#states.error
      if ("response" in error) {
        this.errorTarget.textContent = `Invalid response: ${error.response.statusText}`
      } else {
        this.errorTarget.textContent = `Unknown error.`
      }
      console.trace("subscribe_error", error)
    }
  }

  noFeeds() {
    this.stateValue = this.#states.error
    this.errorTarget.textContent = "No feeds found"
  }

  displayResults(results) {
    this.resultsCountValue = results.feeds.length
    this.hasResultsValue = true
    this.stateValue = this.#states.hasResults

    const feedContent = results.feeds.map((feed, index) => {
      const template = this.feedTemplateTarget.content.cloneNode(true)
      const hydrate = new Hydrate(template)

      const inputBase = `feeds[${feed.id}]`
      const checkboxName = `${inputBase}[subscribe]`

      if (index === 0 && feed.subscribed == false) {
        hydrate.attribute("checkbox", "checked", "true")
      }

      hydrate.attribute("checkbox_dummy", "name", checkboxName)
      hydrate.attribute("checkbox", "name", checkboxName)
      if (feed.subscribed === true) {
        hydrate.attribute("checkbox", "disabled", "true")
      }

      hydrate.attribute("url", "name", `${inputBase}[url]`)
      hydrate.attribute("url", "value", feed.feed_url)

      hydrate.attribute("feed_input", "name", `${inputBase}[title]`)
      hydrate.attribute("feed_input", "value", feed.title)
      hydrate.attribute("feed_input", "placeholder", feed.title)
      if (feed.subscribed === true) {
        hydrate.attribute("feed_input", "disabled", "true")
      }

      hydrate.text("display_url", prettyUrl(feed.feed_url))
      hydrate.attribute("display_url", "href", feed.feed_url)
      hydrate.text("volume", feed.volume)

      hydrate.attribute("feed", "data-feed-subscribed-value", feed.subscribed)
      hydrate.attribute("feed", "data-feed-status-value", this.feedStatus(feed))
      if (feed.subscribed === true) {
        hydrate.attribute("manage", "href", feed.manage_url)
        hydrate.text("tag_names", feed.tags.join(", "))
      }

      return hydrate
    })

    const tagContent = results.tags.map((tag, index) => {
      const template = this.tagTemplateTarget.content.cloneNode(true)
      const hydrate = new Hydrate(template)

      hydrate.attribute("checkbox", "value", tag)
      hydrate.text("label", tag)

      return hydrate
    })

    Hydrate.hydrate(this.feedResultsTarget, feedContent)
    Hydrate.hydrate(this.tagResultsTarget, tagContent)
    this.countSelected()
  }

  // What to show on the left of a subscribed feed's meta row. A crawl error
  // wins over mute because it's the more actionable problem.
  feedStatus(feed) {
    if (feed.subscribed !== true) {
      return "url"
    } else if (feed.crawl_error === true) {
      return "error"
    } else if (feed.muted === true) {
      return "muted"
    } else if (feed.tags.length > 0) {
      return "tags"
    }
    return "url"
  }

  countSelected() {
    const count = this.checkboxTargets.filter((input) => input.checked).length
    this.submitButtonTarget.disabled = count === 0 ? true : false
  }

  faviconTargetConnected(element) {
    loadFavicon(this, element, store)
  }
}
