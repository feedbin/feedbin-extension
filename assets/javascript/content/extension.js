;(function () {
  "use strict"

  function getMetaContent(selector) {
    try {
      const element = document.querySelector(selector)
      return element && element.content ? element.content.trim() : null
    } catch (e) {
      return null
    }
  }

  function loadPageInfo() {
    return {
      description:
                getMetaContent('meta[property="og:description" i]') ||
                getMetaContent('meta[name="description" i]') ||
                getMetaContent('meta[name="twitter:description" i]'),
      title:    getMetaContent('meta[property="og:title" i]'),
      image:    getMetaContent('meta[property="og:image" i]'),
      siteName: getMetaContent('meta[property="og:site_name" i]'),
      favicon:  document.querySelector('link[rel="shortcut icon" i]')?.href || document.querySelector('link[rel="icon" i]')?.href,
      content:  document.documentElement.outerHTML
    }
  }

  browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request && request.action === "loadPageInfo") {
      sendResponse(loadPageInfo())
    } else {
      console.trace("unkown request", request)
    }
  })
})()
