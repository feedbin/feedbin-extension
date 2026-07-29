export class Hydrate {
  constructor(element) {
    this.element = element
  }

  static hydrate(target, items) {
    target.replaceChildren(...items.map(item => item.element))
  }

  #find(selector) {
    const element = this.element.querySelector(`[data-template~=${selector}]`)
    if (!element) {
      console.trace(`template missing selector: ${selector}`)
    }
    return element
  }

  text(selector, value) {
    const element = this.#find(selector)
    if (element) {
      element.textContent = value
    }
  }

  html(selector, value) {
    const element = this.#find(selector)
    if (element) {
      element.innerHTML = value
    }
  }

  attribute(selector, attr, value) {
    const element = this.#find(selector)
    if (element) {
      element.setAttribute(attr, value)
    }
  }
}
