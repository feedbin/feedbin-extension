"use strict"

const root = globalThis.browser ?? globalThis.chrome

root.commands.onCommand.addListener(async (command, tab) => {
  if (command === "open_in_background") {
    try {
      const results = await root.scripting.executeScript({
        target: { tabId: tab.id },
        func: () => {
          const sourceLink = document.getElementById("source_link")
          return sourceLink ? sourceLink.href : null
        },
      })

      const url = results?.[0]?.result
      if (url) {
        root.tabs.create({
          active: false,
          openerTabId: tab.id,
          url: url,
        })
      }
    } catch (error) {
      console.trace("Failed to execute script:", error)
    }
  }
})
