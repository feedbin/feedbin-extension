(function() {
  'use strict';

  function getMetaContent(selector) {
    try {
      const element = document.querySelector(selector);
      return element && element.content ? element.content.trim() : null;
    } catch (e) {
      return null;
    }
  }

  function loadPageInfo() {
    return {
      description: getMetaContent('meta[property="og:description"]') || getMetaContent('meta[name="description"]') || getMetaContent('meta[name="twitter:description"]'),
      title:       getMetaContent('meta[property="og:title"]'),
      image:       getMetaContent('meta[property="og:image"]'),
      siteName:    getMetaContent('meta[property="og:site_name"]')
    };
  }

  browser.runtime.onMessage.addListener(function (request, sender, sendResponse) {
    if (request && request.action === "loadPageInfo") {
      sendResponse(loadPageInfo())
    } else {
      console.log("unkown request", request);
    }
  });
})();