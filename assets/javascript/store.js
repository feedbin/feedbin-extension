class Store {
  constructor() {
    this.user = null
    this.browser = null
    this.pageInfo = null
  }

  setUser(user) {
    this.user = user
  }

  getUser() {
    return this.user
  }

  setBrowser(browser) {
    this.browser = browser
  }

  getBrowser() {
    return this.browser
  }

  setPageInfo(pageInfo) {
    this.pageInfo = pageInfo
  }

  getPageInfo() {
    return this.pageInfo
  }
}

export const sharedStore = new Store()
