import { Controller } from "../lib/stimulus.js"
import { sharedStore } from "../store.js"

export default class extends Controller {
  static targets = ["submitButton", "error", "feedTemplate", "feedResults"]
  static values = {
    loading: Boolean,
    url: String,
    hasResults: Boolean
  }

  async submit(event) {
    console.log(event);

    this.submitButtonTarget.disabled = true
    this.loadingValue = true
    this.errorTarget.textContent = ""

    const user = sharedStore.getUser()
    const pageInfo = sharedStore.getPageInfo()

    const formData = new FormData(this.element);
    formData.append("page_token", user.page_token);
    formData.append("url", pageInfo.url);

    try {
      // const response = await fetch(this.element.action, {
      //   method: this.element.method || "POST",
      //   body: new URLSearchParams(formData)
      // });
      //
      // if (!response.ok) {
      //   const error = new Error(`Invalid response`)
      //   error.response = response
      //   throw error;
      // }
      //
      // data = await response.json();
      const results = [
        {
          url: "https://daringfireball.net/feeds",
          title: "Daring Fireball",
          display_url: "daringfireball.net › index.xml",
          volume: "16h ago, 98/mo"
        },
        {
          url: "https://daringfireball.net/feeds/json",
          title: "Daring Fireball",
          display_url: "daringfireball.net › feed.json",
          volume: "16h ago, 98/mo"
        },
      ]
      this.displayResults(results)
      this.hasResultsValue = true
    } catch (error) {
      if ("response" in error) {
        this.errorTarget.textContent = `Invalid response: ${error.response.statusText}`
      } else {
        this.errorTarget.textContent = `Unknown error.`
      }
      console.log(error);
    }

    this.submitButtonTarget.disabled = false
    this.loadingValue = false
  }

  displayResults(results) {
    let content = results.map((result, index) => {
      const template = this.feedTemplateTarget.content.cloneNode(true)

      const checkbox = template.querySelector("[data-template=checkbox]")

      console.log(template);
      const feedInput  = template.querySelector("[data-template=feed_input]")
      const url        = template.querySelector("[data-template=url]")
      const displayUrl = template.querySelector("[data-template=display_url]")
      const volume     = template.querySelector("[data-template=volume]")

      checkbox.setAttribute("name", `feed[${index}][subscribe]`)
      checkbox.setAttribute("value", "1")
      if (index === 0) {
        checkbox.checked = true
      }

      url.setAttribute("name", `feed[${index}][url]`)
      url.setAttribute("value", result.url)

      feedInput.setAttribute("name", `feed[${index}][title]`)
      feedInput.setAttribute("value", result.title)
      feedInput.setAttribute("placeholder", result.title)

      displayUrl.textContent = result.display_url
      volume.textContent = result.volume

      return template
    })
    this.feedResultsTarget.innerHTML = ""
    this.feedResultsTarget.append(...[content].flat())
  }
}
