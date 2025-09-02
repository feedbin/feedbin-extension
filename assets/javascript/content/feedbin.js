;(function () {
  "use strict"

  const root = globalThis.browser ?? globalThis.chrome

  root.runtime.onMessage.addListener((message, sender, sendResponse) => {
    if (message === "open_in_background") {
      const url = document.getElementById("source_link")?.href
      if (url) {
        sendResponse({ url })
        return
      }
    }
    sendResponse(null)
  })
})()
