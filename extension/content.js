// Content script to extract og:description and other meta information from the page
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
    return {
        ogDescription: getOgDescription(),
        ogTitle: document.querySelector('meta[property="og:title"]')?.content?.trim() || null,
        ogImage: document.querySelector('meta[property="og:image"]')?.content?.trim() || null,
        ogSiteName: document.querySelector('meta[property="og:site_name"]')?.content?.trim() || null
    };
}

// Listen for messages from the popup
browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === 'getMetaInfo') {
        const metaInfo = getMetaInfo();
        sendResponse(metaInfo);
    }
});

// Also make the function available globally in case of direct execution
if (typeof window !== 'undefined') {
    window.getMetaInfo = getMetaInfo;
}