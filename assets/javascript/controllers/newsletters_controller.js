import { Controller } from "../lib/stimulus.js"
import { store } from "../store.js"
import { loadFavicon, prettyUrl, sendForm, sendRequest, debounce } from "../helpers.js"

export default class extends Controller {
  static targets = ["submitButton", "form", "verifiedTokenInput", "addressOutput", "numbers", "addressInput", "addressDescription", "addressTag", "addressTemplate", "addressList", "error"]

  static values = {
    newAddressUrl: String,
    createAddressUrl: String,
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
      const response = await sendRequest("POST", this.newAddressUrlValue, {
        page_token: user.page_token
      })

      const data = await response.json()

      this.addressInputTarget.value = data.token
      this.addressInputTarget.dataset.originalValue = data.token

      this.addressOutputTarget.textContent = data.email

      data.tags.forEach(tag => {
        const option = document.createElement('option')
        option.value = tag
        option.textContent = tag
        this.addressTagTarget.appendChild(option)
      })

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
    let response = await sendForm(event, {
      page_token: user.page_token
    })

    const data = await response.json()

    if (data.token) {
      this.numbersTarget.textContent = data.numbers
      this.addressOutputTarget.textContent = data.email
      this.verifiedTokenInputTarget.value = data.verified_token
      this.updateAddressList(data.addresses)

      this.#createTimeout = setTimeout(() => {
        this.submitButtonTarget.disabled = false
      }, 500);
    } else {
      // if there is an empty response it means no valid input was given
      this.numbersTarget.textContent = ""
      this.addressOutputTarget.textContent = "Invalid Address"
    }
  }

  updateAddressList(addresses) {
    let addressesContent = addresses.map((address, index) => {
      const template    = this.addressTemplateTarget.content.cloneNode(true)

      const container   = template.querySelector("[data-template=container]")
      const email       = template.querySelector("[data-template=email]")
      const description = template.querySelector("[data-template=description]")

      container.dataset.copyDataValue = address.email
      email.textContent               = address.email
      description.textContent         = address.description || ""

      return template
    })

    this.addressListTarget.innerHTML = ""
    this.addressListTarget.append(...[addressesContent].flat())
  }

  addressInputChanged(event) {
    this.editedValue = true
    this.formTarget.requestSubmit()
  }

  error(event) {
    this.stateValue = this.#states.error
    this.errorTarget.textContent = "Error loading newsletter addresses"
  }
}
