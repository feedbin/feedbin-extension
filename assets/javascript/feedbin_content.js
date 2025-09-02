;(function () {
  "use strict"

  const root = globalThis.browser ?? globalThis.chrome

  root.runtime.onMessage.addListener(function (message, _, sendResponse) {
    if (message === "open_in_background") {
      sendResponse(document.getElementById("source_link")?.href)
    }
  })
})()
