import { Application } from "@hotwired/stimulus"
window.Stimulus = Application.start()

console.log(window.Stimulus);
document.addEventListener('DOMContentLoaded', async function() {
    const resultDiv = document.getElementById('result');

    try {
        // Query for the active tab in the current window
        const [tab] = await chrome.tabs.query({
            active: true,
            currentWindow: true
        });

        if (tab) {
            // Display the tab title and favicon first
            const faviconUrl = tab.favIconUrl || 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjE2IiBoZWlnaHQ9IjE2IiBmaWxsPSIjZGRkIiByeD0iMiIvPgo8dGV4dCB4PSI4IiB5PSIxMiIgZm9udC1mYW1pbHk9IkFyaWFsIiBmb250LXNpemU9IjEwIiBmaWxsPSIjOTk5IiB0ZXh0LWFuY2hvcj0ibWlkZGxlIj4/PC90ZXh0Pgo8L3N2Zz4K';

            // Try to get meta information from the page
            let metaInfo = null;
            try {
                // Check if we can inject scripts on this tab (avoid chrome:// pages, etc.)
                if (tab.url && !tab.url.startsWith('chrome://') && !tab.url.startsWith('chrome-extension://') && !tab.url.startsWith('edge://') && !tab.url.startsWith('about:')) {
                    // Inject content script to get meta information
                    const results = await chrome.scripting.executeScript({
                        target: { tabId: tab.id },
                        files: ['content.js']
                    });

                    // Send message to content script to get meta info
                    metaInfo = await chrome.tabs.sendMessage(tab.id, { action: 'getMetaInfo' });
                }
            } catch (scriptError) {
                console.log('Could not inject content script:', scriptError);
                // This is expected for restricted pages or when permissions are insufficient
            }

            const ogDescription = metaInfo?.ogDescription || null;

            resultDiv.innerHTML = `
                <div class="tab-info">
                    <div class="favicon-container">
                        <img src="${faviconUrl}" alt="Favicon" class="favicon" onerror="this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjE2IiBoZWlnaHQ9IjE2IiBmaWxsPSIjZGRkIiByeD0iMiIvPgo8dGV4dCB4PSI4IiB5PSIxMiIgZm9udC1mYW1pbHk9IkFyaWFsIiBmb250LXNpemU9IjEwIiBmaWxsPSIjOTk5IiB0ZXh0LWFuY2hvcj0ibWlkZGxlIj4/PC90ZXh0Pgo8L3N2Zz4K'">
                    </div>
                    <div class="tab-details">
                        <p class="tab-title">${escapeHtml(tab.title || 'No title')}</p>
                        <p class="tab-url">${escapeHtml(tab.url || 'No URL')}</p>
                        ${ogDescription ? `<p class="og-description">${escapeHtml(ogDescription)}</p>` : ''}
                    </div>
                </div>
            `;
        } else {
            resultDiv.innerHTML = '<p class="error">Could not get tab information</p>';
        }
    } catch (error) {
        console.error('Error getting tab information:', error);
        resultDiv.innerHTML = '<p class="error">Error: Could not access tab information</p>';
    }
});

// Helper function to escape HTML to prevent XSS
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}