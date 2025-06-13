import { Controller } from "../lib/stimulus.js"

export default class extends Controller {
    static targets = ["result"]
    static values = {
        loading: { type: Boolean, default: false },
        error: { type: String, default: "" },
        retryCount: { type: Number, default: 0 }
    }

    connect() {
        console.log("TabInfo controller connected")
        this.element.classList.add("stimulus-connected")
        this.loadTabInfo()
    }

    disconnect() {
        console.log("TabInfo controller disconnected")
        this.element.classList.remove("stimulus-connected")
    }

    loadingValueChanged() {
        this.element.classList.toggle("loading", this.loadingValue)
    }

    errorValueChanged() {
        this.element.classList.toggle("has-error", this.errorValue !== "")
    }

    async loadTabInfo() {
        this.setLoading(true)
        this.clearError()

        try {
            // Query for the active tab in the current window
            const [tab] = await browser.tabs.query({
                active: true,
                currentWindow: true
            })

            if (tab) {
                // Display the tab title and favicon first
                const faviconUrl = tab.favIconUrl || this.getDefaultFaviconSvg()

                // Try to get meta information from the page
                let metaInfo = null
                try {
                    // Check if we can inject scripts on this tab (avoid chrome:// pages, etc.)
                    if (this.canInjectScript(tab.url)) {
                        try {
                            await browser.scripting.executeScript({
                                target: { tabId: tab.id },
                                files: ['lib/polyfill.js', 'content.js']
                            })

                            metaInfo = await this.sendMessageWithTimeout(tab.id, { action: 'getMetaInfo' }, 3000)
                        } catch (injectionError) {
                            console.log('Script injection failed:', injectionError)
                        }
                    }
                } catch (scriptError) {
                    console.log('Could not inject content script:', scriptError)
                }

                this.displayTabInfo(tab, metaInfo)
                this.retryCountValue = 0
            } else {
                this.setError('Could not get tab information')
            }
        } catch (error) {
            console.error('Error getting tab information:', error)
            this.setError(`Error: Could not access tab information`)
            this.retryCountValue++
        } finally {
            this.setLoading(false)
        }
    }

    displayTabInfo(tab, metaInfo) {
        const faviconUrl = tab.favIconUrl || this.getDefaultFaviconSvg()
        const ogDescription = metaInfo?.ogDescription || null

        this.resultTarget.innerHTML = `
            <div class="tab-info">
                <div class="favicon-container">
                    <img src="${faviconUrl}" alt="Favicon" class="favicon" onerror="this.src='${this.getDefaultFaviconSvg()}'">
                </div>
                <div class="tab-details">
                    <div class="title-row">
                        <p class="tab-title">${this.escapeHtml(tab.title || 'No title')}</p>
                        <button data-action="click->tab-info#copyToClipboard" class="inline-copy-btn" title="Copy title">📋</button>
                    </div>
                    <p class="tab-url">${this.escapeHtml(tab.url || 'No URL')}</p>
                    ${ogDescription ? `<p class="og-description">${this.escapeHtml(ogDescription)}</p>` : '<p class="no-description">No description available</p>'}
                </div>
            </div>
        `
    }

    setError(message) {
        this.errorValue = message
        this.resultTarget.innerHTML = `
            <div class="error-container">
                <p class="error">${this.escapeHtml(message)}</p>
                ${this.retryCountValue < 3 ? '<button data-action="click->tab-info#retry" class="retry-btn">Try Again</button>' : ''}
            </div>
        `
    }

    clearError() {
        this.errorValue = ""
    }

    setLoading(isLoading) {
        this.loadingValue = isLoading
        if (isLoading) {
            this.resultTarget.innerHTML = '<p class="loading">Loading tab information...</p>'
        }
    }

    canInjectScript(url) {
        if (!url) return false

        const restrictedPrefixes = [
            'chrome://',
            'chrome-extension://',
            'edge://',
            'about:',
            'moz-extension://',
            'safari-extension://'
        ]

        return !restrictedPrefixes.some(prefix => url.startsWith(prefix))
    }

    getDefaultFaviconSvg() {
        return 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjE2IiBoZWlnaHQ9IjE2IiBmaWxsPSIjZGRkIiByeD0iMiIvPgo8dGV4dCB4PSI4IiB5PSIxMiIgZm9udC1mYW1pbHk9IkFyaWFsIiBmb250LXNpemU9IjEwIiBmaWxsPSIjOTk5IiB0ZXh0LWFuY2hvcj0ibWlkZGxlIj4/PC90ZXh0Pgo8L3N2Zz4K'
    }

    // Helper function to escape HTML to prevent XSS
    escapeHtml(text) {
        const div = document.createElement('div')
        div.textContent = text
        return div.innerHTML
    }

    // Action method that can be called from buttons or other triggers
    refresh() {
        console.log("Refreshing tab info...")
        this.loadTabInfo()
    }

    // Action method for retrying after errors
    retry() {
        console.log("Retrying tab info load...")
        this.loadTabInfo()
    }

    // Action method to copy tab info to clipboard
    async copyToClipboard() {
        try {
            const tabInfo = this.element.querySelector('.tab-title')?.textContent || ''
            if (tabInfo) {
                await navigator.clipboard.writeText(tabInfo)
                this.showToast("Tab title copied! 📋")
            } else {
                this.showToast("Nothing to copy")
            }
        } catch (error) {
            console.error('Failed to copy:', error)
            // Fallback for browsers that don't support clipboard API
            this.fallbackCopy(tabInfo)
        }
    }

    showToast(message) {
        const toast = document.createElement('div')
        toast.className = 'toast'
        toast.textContent = message
        this.element.appendChild(toast)

        setTimeout(() => {
            toast.classList.add('show')
        }, 100)

        setTimeout(() => {
            toast.classList.remove('show')
            setTimeout(() => toast.remove(), 300)
        }, 2000)
    }

    // Detect if running in Firefox
    isFirefox() {
        return typeof InstallTrigger !== 'undefined' ||
               navigator.userAgent.toLowerCase().includes('firefox') ||
               (typeof browser !== 'undefined' && browser.runtime && browser.runtime.getBrowserInfo)
    }

    // Helper method to send messages with timeout (Firefox compatibility)
    async sendMessageWithTimeout(tabId, message, timeoutMs = 5000) {
        return new Promise((resolve, reject) => {
            const timeout = setTimeout(() => {
                reject(new Error('Message timeout'))
            }, timeoutMs)

            browser.tabs.sendMessage(tabId, message)
                .then(response => {
                    clearTimeout(timeout)
                    resolve(response)
                })
                .catch(error => {
                    clearTimeout(timeout)
                    reject(error)
                })
        })
    }

    // Fallback copy method for browsers without clipboard API
    fallbackCopy(text) {
        try {
            const textArea = document.createElement('textarea')
            textArea.value = text
            textArea.style.position = 'fixed'
            textArea.style.opacity = '0'
            document.body.appendChild(textArea)
            textArea.select()
            document.execCommand('copy')
            document.body.removeChild(textArea)
            this.showToast("Title copied! 📋")
        } catch (error) {
            console.error('Fallback copy failed:', error)
            this.showToast("Copy failed ❌")
        }
    }
}