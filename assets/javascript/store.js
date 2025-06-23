class Store {
  constructor() {
    this.user = null
    this.pageInfo = null
  }

  setUser(user) {
    this.user = user
  }

  getUser() {
    return this.user
  }

  setPageInfo(pageInfo) {
    this.pageInfo = pageInfo
  }

  getPageInfo() {
    return this.pageInfo
  }
}

export const sharedStore = new Store()
