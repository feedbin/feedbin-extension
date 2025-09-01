class Store {
  constructor() {
    this.settings = {
      user: null,
      browser: null,
      pageInfo: null,
      native: false,
    }
  }

  update(key, value) {
    if (!(key in this.settings)) {
      throw new Error(`Unknown setting: ${key}`)
    }
    this.settings[key] = value
  }

  get(key) {
    if (!(key in this.settings)) {
      throw new Error(`Unknown setting: ${key}`)
    }
    return this.settings[key]
  }
}

export const store = new Store()