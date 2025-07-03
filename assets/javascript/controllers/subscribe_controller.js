import { Controller } from "../lib/stimulus.js"
import { sharedStore } from "../store.js"
import { loadFavicon, prettyUrl } from "../helpers.js"

export default class extends Controller {
  static targets = ["submitButton", "error", "checkbox", "feedTemplate", "feedResults", "tagTemplate", "tagResults", "favicon"]
  static values = {
    loading: Boolean,
    url: String,
    hasResults: Boolean,
    resultsCount: Number,
  }

  async submit(event) {
    console.log(event)

    this.submitButtonTarget.disabled = true
    this.loadingValue = true
    this.errorTarget.textContent = ""

    const user = sharedStore.getUser()
    const pageInfo = sharedStore.getPageInfo()

    const formData = new FormData(this.element)
    formData.append("page_token", user.page_token)
    formData.append("url", pageInfo.url)

    let body = new URLSearchParams(formData)
    console.log("body", body);

    try {
      const response = await fetch(this.element.action, {
        method: this.element.method || "POST",
        body: new URLSearchParams(formData)
      });

      if (!response.ok) {
        const error = new Error(`Invalid response`)
        error.response = response
        throw error;
      }

      data = await response.json();

      // The displayResults method will be called via the event listener
      // when the add controller dispatches the resultsLoaded event
      this.hasResultsValue = true
    } catch (error) {
      if ("response" in error) {
        this.errorTarget.textContent = `Invalid response: ${error.response.statusText}`
      } else {
        this.errorTarget.textContent = `Unknown error.`
      }
      console.log(error)
    }

    this.submitButtonTarget.disabled = false
    this.loadingValue = false
  }

  countSelected() {
    const count = this.checkboxTargets.filter((input) => input.checked).length
    this.submitButtonTarget.disabled = count === 0 ? true : false
  }

  displayResults(event) {
    let results = event.detail
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

      const checkboxName = `feed[${index}][subscribe]`
      checkboxDummy.setAttribute("name", checkboxName)
      checkbox.setAttribute("name", checkboxName)
      if (index === 0) {
        checkbox.checked = true
      }

      url.setAttribute("name", `feed[${index}][url]`)
      url.setAttribute("value", feed.feed_url)

      feedInput.setAttribute("name", `feed[${index}][title]`)
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

  faviconTargetConnected(element) {
    loadFavicon(this, element, sharedStore)
  }
}
