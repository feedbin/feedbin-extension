/* -------------------------------------------------
 *  Browser API shims for testing
 *  — Mocks browser.storage, browser.scripting, browser.runtime, browser.tabs
 * -------------------------------------------------*/
(function () {

  // do not load in an extension context
  if ((window.browser && window.browser.runtime && window.browser.runtime.id)) {
    return
  }

  // Re-use an existing browser object if one is already present
  const root = typeof browser !== "undefined" ? browser : (window.browser = {});

  // Ensure the sub-namespaces exist
  root.storage = root.storage || {};
  root.storage.sync = root.storage.sync || {};
  root.scripting = root.scripting || {};
  root.runtime = root.runtime || {};
  root.tabs = root.tabs || {};

  /** Helper: convert whatever the caller passed to a canonical array of keys */
  function normalizeKeys(keys) {
    if (keys === undefined || keys === null) return null; // signify “all keys”
    if (typeof keys === "string") return [keys];
    if (Array.isArray(keys)) return keys;
    if (typeof keys === "object") return Object.keys(keys);
    throw new TypeError("Invalid keys argument for browser.storage.sync.get");
  }

  /** browser.storage.sync.set shim */
  root.storage.sync.set = function (items, callback) {
    if (typeof items !== "object" || items === null)
      throw new TypeError("browser.storage.sync.set expects an object");

    try {
      for (const [k, v] of Object.entries(items)) {
        localStorage.setItem(k, JSON.stringify(v));
      }
      if (callback) callback(); // Chrome spec: no args on success
      return Promise.resolve(); // also return a promise for async/await
    } catch (err) {
      if (callback) callback(err);
      return Promise.reject(err);
    }
  };

  /** browser.storage.sync.get shim */
  root.storage.sync.get = function (keys, callback) {
    const wantedKeys = normalizeKeys(keys);
    const result = {};

    try {
      // If no keys supplied, return *all* keys
      if (wantedKeys === null) {
        for (let i = 0; i < localStorage.length; i++) {
          const k = localStorage.key(i);
          result[k] = JSON.parse(localStorage.getItem(k));
        }
      } else {
        for (const k of wantedKeys) {
          const raw = localStorage.getItem(k);
          result[k] = raw === null ? undefined : JSON.parse(raw);
        }
      }

      if (callback) callback(result); // first arg is the items object
      return Promise.resolve(result);
    } catch (err) {
      if (callback) callback(undefined, err); // Chrome spec: (items) only, but we pass err in 2nd slot
      return Promise.reject(err);
    }
  };

  root.storage.sync.remove = function (keys, callback) {
    const toRemove = normalizeKeys(keys);
    try {
      if (toRemove === null) {
        // spec: remove(null) → no-op
        if (callback) callback();
        return Promise.resolve();
      }
      for (const k of toRemove) {
        localStorage.removeItem(k);
      }
      if (callback) callback();
      return Promise.resolve();
    } catch (err) {
      if (callback) callback(err);
      return Promise.reject(err);
    }
  };

  // Mock browser.scripting.executeScript
  root.scripting.executeScript = function (options) {
    // Simulate script execution by dispatching content script setup
    if (
      options.files &&
      options.files.includes("assets/javascript/content.js")
    ) {
      // Simulate content script being loaded
      setTimeout(() => {
        if (window.mockContentScriptLoaded) {
          window.mockContentScriptLoaded();
        }
      }, 10);
    }

    return Promise.resolve([{ result: null }]);
  };

  // Mock browser.runtime.onMessage for content script side
  root.runtime.onMessage = {
    addListener: function (callback) {
      window.mockRuntimeMessageListener = callback;
    },
  };

  // Mock browser.tabs.query
  root.tabs.query = function (queryInfo) {
    // Check if we should simulate no tabs found
    if (window.mockNoTabsFound) {
      return Promise.resolve([]);
    }

    // Return a mock tab object
    const mockTab = {
      id: 1,
      url: "http://daringfireball.net",
      title: "Page Title",
      favIconUrl:
        'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16"><circle cx="8" cy="8" r="6" fill="%23007acc"/></svg>',
      active: true,
      windowId: 1,
    };

    return Promise.resolve([mockTab]);
  };

  // Mock browser.tabs.sendMessage
  root.tabs.sendMessage = function (tabId, message) {
    // Check if we should simulate a sendMessage failure
    if (window.mockSendMessageShouldFail) {
      return Promise.reject(new Error("Failed to send message"));
    }

    // Simulate sending message to content script
    if (
      message.action === "loadPageInfo" &&
      window.mockRuntimeMessageListener
    ) {
      const mockSender = { tab: { id: tabId } };
      const mockSendResponse = (response) => response;

      // Call the content script message listener
      const response = window.mockRuntimeMessageListener(
        message,
        mockSender,
        mockSendResponse,
      );
      return Promise.resolve(response);
    }

    return Promise.resolve(null);
  };

  // Helper function to simulate content script injection
  root.mockContentScriptInjection = function () {
    // Simulate the content script's getMetaContent function
    function getMetaContent(selector) {
      try {
        const element = document.querySelector(selector);
        return element && element.content ? element.content.trim() : null;
      } catch (e) {
        return null;
      }
    }

    // Simulate the content script's loadPageInfo function
    function loadPageInfo() {
      return {
        description: "Description",
        title: "Title",
        image: "http://example.com/image.png",
        siteName: "Site Name",
        content: "<html><body>Test content</body></html>",
      };
    }

    // Set up the message listener that would normally be in the content script
    window.mockRuntimeMessageListener = function (
      request,
      sender,
      sendResponse,
    ) {
      if (request && request.action === "loadPageInfo") {
        return sendResponse(loadPageInfo());
      } else {
        return null;
      }
    };

    // Reset error flags
    window.mockNoTabsFound = false;
    window.mockSendMessageShouldFail = false;
  };

  // Auto-setup if we're in a browser environment (not extension context)
  if (typeof window !== "undefined" && !window.chrome?.runtime?.id) {
    // Delay setup to ensure DOM is ready
    if (document.readyState === "loading") {
      document.addEventListener(
        "DOMContentLoaded",
        root.mockContentScriptInjection,
      );
    } else {
      root.mockContentScriptInjection();
    }
  }
})();
