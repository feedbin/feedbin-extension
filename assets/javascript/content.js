// Firefox-compatible content script for extracting meta information
// This version avoids structured cloning issues by using simpler patterns

(function() {
    'use strict';

    // Simple function to safely get meta content
    function getMetaContent(selector) {
        try {
            const element = document.querySelector(selector);
            return element && element.content ? element.content.trim() : null;
        } catch (e) {
            return null;
        }
    }

    // Get og:description with fallbacks
    function getDescription() {
        return getMetaContent('meta[property="og:description"]') ||
               getMetaContent('meta[name="description"]') ||
               getMetaContent('meta[name="twitter:description"]') ||
               null;
    }

    // Get all meta information as plain object
    function extractMetaInfo() {
        return {
            ogDescription: getDescription(),
            ogTitle: getMetaContent('meta[property="og:title"]'),
            ogImage: getMetaContent('meta[property="og:image"]'),
            ogSiteName: getMetaContent('meta[property="og:site_name"]')
        };
    }

    // Firefox-compatible message handling
    function handleMessage(request, sender, sendResponse) {
        if (!request || request.action !== 'getMetaInfo') {
            return false;
        }

        try {
            const metaInfo = extractMetaInfo();
            sendResponse(metaInfo);
        } catch (error) {
            console.error('Firefox content script error:', error);
            sendResponse({
                ogDescription: null,
                ogTitle: null,
                ogImage: null,
                ogSiteName: null
            });
        }

        return true; // Keep message channel open
    }

    browser.runtime.onMessage.addListener(handleMessage);
})();