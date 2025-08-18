import { gzip } from "./utilities.js"

export class HttpClient {
  async #makeRequest(url, options) {
    const response = await fetch(url, options)
    try {
      const data = await response.json()
      response.data = data
    } catch (e) {
      response.data = null
    }

    if (!response.ok) {
      const error = new Error(`Invalid response`)
      error.response = response
      throw error
    }

    return response
  }

  async sendRequest(method, action, data, event = null) {
    let formData = new FormData()
    if (event) {
      formData = new FormData(event.target)
      const button = event.submitter
      if (button?.name) {
        formData.append(button.name, button.value)
      }
    }

    Object.entries(data).forEach(([key, value]) => {
      formData.append(key, value)
    })

    const request = {
      method: method,
      body: new URLSearchParams(formData),
    }

    return this.#makeRequest(action, request)
  }

  async sendForm(event, data = {}) {
    return await this.sendRequest(event.target.method, event.target.action, data, event)
  }

  async sendJson(event, data) {
    let body = JSON.stringify(data)
    body = await gzip(body)

    const request = {
      method: event.target.method,
      headers: {
        "Content-Type": "application/json",
        "Content-Encoding": "gzip"
      },
      body
    }

    return this.#makeRequest(event.target.action, request)
  }
}

export const httpClient = new HttpClient()