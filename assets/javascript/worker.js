"use strict"

const root = globalThis.browser ?? globalThis.chrome

root.commands.onCommand.addListener(function (name, tab) {
  if (name === "open_in_background") {
    root.tabs.sendMessage(tab.id, name).then(function (response) {
      // At Chrome version 111 we cannot yet use URL.canParse(). Try-catch.
      try {
        !!new URL(response) &&
        root.tabs.create({
            active: false,
            openerTabId: tab.id,
            url: response
        })
      } catch (_) {}
    }, () => {})
  }
})
