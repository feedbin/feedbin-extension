// Content script to extract og:description and other meta information from the page
// Wrap everything in an IIFE to avoid global pollution and return issues
(function() {
    'use strict';
    
    // Function to get og:description from the page
    function getOgDescription() {
        // Try to find og:description meta tag
        const ogDescriptionTag = document.querySelector('meta[property="og:description"]');
        if (ogDescriptionTag && ogDescriptionTag.content) {
            return ogDescriptionTag.content.trim();
        }

        // Fallback to regular description meta tag
        const descriptionTag = document.querySelector('meta[name="description"]');
        if (descriptionTag && descriptionTag.content) {
            return descriptionTag.content.trim();
        }

        // Fallback to twitter:description
        const twitterDescriptionTag = document.querySelector('meta[name="twitter:description"]');
        if (twitterDescriptionTag && twitterDescriptionTag.content) {
            return twitterDescriptionTag.content.trim();
        }

        return null;
    }

    // Function to get additional meta information
    function getMetaInfo() {
        const ogTitleElement = document.querySelector('meta[property="og:title"]');
        const ogImageElement = document.querySelector('meta[property="og:image"]');
        const ogSiteNameElement = document.querySelector('meta[property="og:site_name"]');
        
        return {
            ogDescription: getOgDescription(),
            ogTitle: ogTitleElement ? (ogTitleElement.content ? ogTitleElement.content.trim() : null) : null,
            ogImage: ogImageElement ? (ogImageElement.content ? ogImageElement.content.trim() : null) : null,
            ogSiteName: ogSiteNameElement ? (ogSiteNameElement.content ? ogSiteNameElement.content.trim() : null) : null
        };
    }

    // Listen for messages from the popup
    if (typeof browser !== 'undefined' && browser.runtime && browser.runtime.onMessage) {
        browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
            if (request && request.action === 'getMetaInfo') {
                try {
                    const metaInfo = getMetaInfo();
                    sendResponse(metaInfo);
                } catch (error) {
                    console.error('Error getting meta info:', error);
                    sendResponse({
                        ogDescription: null,
                        ogTitle: null,
                        ogImage: null,
                        ogSiteName: null
                    });
                }
                return true; // Keep message channel open for async response
            }
        });
    }

    // Don't expose anything globally to avoid cloning issues
    // The script will only respond to messages
})();