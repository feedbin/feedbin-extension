import { Controller } from "../lib/stimulus.js"
import { store } from "../store.js"
import { loadFavicon, prettyUrl } from "../helpers.js"

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

      const formData = new FormData()
      formData.append("page_token", user.page_token)
      formData.append("url", pageInfo.url)

      const request = {
        method: "POST",
        body: new URLSearchParams(formData),
      }

      const response = await fetch(this.searchUrlValue, request)

      if (!response.ok) {
        const error = new Error(`Invalid response`)
        error.response = response
        throw error
      }

      const data = await response.json()

      if (data.feeds.length === 0) {
        this.noFeeds()
      } else {
        this.displayResults(data)
        this.stateValue = this.#states.hasResults
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
      const pageInfo = store.get("pageInfo")
      const formData = new FormData(this.subscribeFormTarget)
      formData.append("page_token", user.page_token)

      const request = {
        method: this.subscribeFormTarget.method || "POST",
        body: new URLSearchParams(formData)
      }

      const response = await fetch(this.subscribeFormTarget.action, request);

      if (!response.ok) {
        const error = new Error(`Invalid response`)
        error.response = response
        throw error;
      }

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

    let feedContent = results.feeds.map((feed, index) => {
      const template = this.feedTemplateTarget.content.cloneNode(true)
      const checkboxDummy = template.querySelector("[data-template=checkbox_dummy]")
      const checkbox = template.querySelector("[data-template=checkbox]")
      const feedInput = template.querySelector("[data-template=feed_input]")
      const url = template.querySelector("[data-template=url]")
      const displayUrl = template.querySelector("[data-template=display_url]")
      const volume = template.querySelector("[data-template=volume]")

      const inputBase = `feeds[${feed.id}]`

      const checkboxName = `${inputBase}[subscribe]`
      checkboxDummy.setAttribute("name", checkboxName)
      checkbox.setAttribute("name", checkboxName)
      if (index === 0) {
        checkbox.checked = true
      }

      url.setAttribute("name", `${inputBase}[url]`)
      url.setAttribute("value", feed.feed_url)

      feedInput.setAttribute("name", `${inputBase}[title]`)
      feedInput.setAttribute("value", feed.title)
      feedInput.setAttribute("placeholder", feed.title)

      displayUrl.textContent = prettyUrl(feed.feed_url)
      volume.textContent = feed.volume

      return template
    })

    this.feedResultsTarget.innerHTML = ""
    this.feedResultsTarget.append(...[feedContent].flat())

    let tagContent = results.tags.map((tag, index) => {
      const template = this.tagTemplateTarget.content.cloneNode(true)
      const checkbox = template.querySelector("[data-template=checkbox]")
      const label = template.querySelector("[data-template=label]")

      checkbox.setAttribute("value", tag)
      label.textContent = tag

      return template
    })

    this.tagResultsTarget.innerHTML = ""
    this.tagResultsTarget.append(...[tagContent].flat())
  }

  countSelected() {
    const count = this.checkboxTargets.filter((input) => input.checked).length
    this.submitButtonTarget.disabled = count === 0 ? true : false
  }

  faviconTargetConnected(element) {
    loadFavicon(this, element, store)
  }
}
