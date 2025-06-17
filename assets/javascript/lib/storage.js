/* -------------------------------------------------
 *  Chrome-storage-to-localStorage shim
 *  — Mocks browser.storage.sync.{set,get}
 * -------------------------------------------------*/
(function () {
  // Re-use an existing browser object if one is already present
  const root = (typeof browser !== "undefined") ? browser : (window.browser = {});

  // Ensure the sub-namespaces exist
  root.storage = root.storage || {};
  root.storage.sync = root.storage.sync || {};

  /** Helper: convert whatever the caller passed to a canonical array of keys */
  function normalizeKeys(keys) {
    if (keys === undefined || keys === null) return null;          // signify “all keys”
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
      if (callback) callback();                      // Chrome spec: no args on success
      return Promise.resolve();                      // also return a promise for async/await
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

      if (callback) callback(result);                // first arg is the items object
      return Promise.resolve(result);
    } catch (err) {
      if (callback) callback(undefined, err);        // Chrome spec: (items) only, but we pass err in 2nd slot
      return Promise.reject(err);
    }
  };

  root.storage.sync.remove = function (keys, callback) {
      const toRemove = normalizeKeys(keys);
      try {
        if (toRemove === null) {                                     // spec: remove(null) → no-op
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
})();