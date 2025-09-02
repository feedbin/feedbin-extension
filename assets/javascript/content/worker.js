"use strict"

const root = globalThis.browser ?? globalThis.chrome

root.commands.onCommand.addListener((command, tab) => {
  if (command === "open_in_background") {
    root.tabs.sendMessage(tab.id, command).then((response) => {
      if (!response || !response.url) {
        return
      }
      root.tabs.create({
        active: false,
        openerTabId: tab.id,
        url: response.url
      })
    })
  }
})
