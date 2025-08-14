import { Controller } from "../lib/stimulus.js"
import { store } from "../store.js"
import { loadFavicon, prettyUrl, debounce } from "../helpers.js"
import { httpClient } from "../http_client.js"
import { Hydrate } from "../hydrate.js"

export default class extends Controller {
  static targets = [
    "addressOutput", "numbers",
    "form", "verifiedTokenInput", "addressInput", "submitButton",
    "addressDescription", "addressTag", "addressList", "error", "copyButton",
    "addressTemplate", "optionTemplate"
  ]

  static values = {
    newAddressUrl: String,
    createAddressUrl: String,
    addressValid: Boolean,
    state: String,
    edited: Boolean
  }

  #states = {
    initial: "initial",
    hasResults: "hasResults",
    loading: "loading",
    success: "success",
    error: "error"
  }

  #createTimeout = null

  initialize() {
    this.submit = debounce(this.submit.bind(this), 100)
  }

  async new(event) {
    this.stateValue = this.#states.loading

    try {
      const user = store.get("user")
      const response = await httpClient.sendRequest("POST", this.newAddressUrlValue, {
        page_token: user.page_token
      })

      const data = await response.json()

      this.addressInputTarget.value = data.token
      this.addressInputTarget.dataset.originalValue = data.token
      this.addressOutputTargets.forEach((element) => element.textContent = data.email)

      this.updateTagsList(data.tags)
      this.updateAddressList(data.addresses)

      this.stateValue = this.#states.initial
    } catch (error) {
      this.stateValue = this.#states.error
      if ("response" in error) {
        this.errorTarget.textContent = `Invalid response: ${error.response.statusText}`
      } else {
        this.errorTarget.textContent = `Unknown error. ${error}`
      }
      console.trace("newsletters_error", error)
    }
  }

  disable(event) {
    this.submitButtonTarget.disabled = true
    clearTimeout(this.#createTimeout);
  }

  async submit(event) {
    const user = store.get("user")
    let response = await httpClient.sendForm(event, {
      page_token: user.page_token
    })

    const data = await response.json()

    if (data.error) {
      this.addressValidValue = false
    } else {
      this.addressValidValue = true
      this.numbersTarget.textContent = data.numbers
      this.addressOutputTargets.forEach((element) => element.textContent = data.email)
      this.verifiedTokenInputTarget.value = data.verified_token
      this.updateAddressList(data.addresses)

      this.#createTimeout = setTimeout(() => {
        this.submitButtonTarget.disabled = false
      }, 500);
    }
  }

  updateTagsList(tags) {
    tags.unshift("None");
    let content = tags.map((tag, index) => {
      const template = this.optionTemplateTarget.content.cloneNode(true)
      const hydrate  = new Hydrate(template)

      hydrate.attribute("option", "value", ((index === 0) ? "" : tag))
      hydrate.text("option", tag)

      return hydrate
    })

    Hydrate.hydrate(this.addressTagTarget, content)
  }

  updateAddressList(addresses) {
    let content = addresses.map((address, index) => {
      const template = this.addressTemplateTarget.content.cloneNode(true)
      const hydrate  = new Hydrate(template)

      hydrate.attribute("container", "data-copy-data-value", address.email)
      hydrate.text("email", address.email)
      hydrate.text("description", address.description || "")

      return hydrate
    })

    Hydrate.hydrate(this.addressListTarget, content)
  }

  addressInputChanged(event) {
    this.editedValue = true
    this.formTarget.requestSubmit()
  }
}
