# Tab Info Display Chrome Extension

A minimal Chrome browser extension that automatically displays the current tab's title, favicon, and Open Graph description when the popup opens.

## Features

- Automatic tab information loading (no button clicks required)
- Displays current tab title and favicon
- Shows tab URL for reference
- Extracts and displays Open Graph description (og:description) from the page
- Fallback to standard meta description if og:description is not available
- Clean, minimal design with favicon integration
- Uses Manifest V3
- No external dependencies (vanilla HTML, CSS, JavaScript)

## Installation

1. Open Chrome and navigate to `chrome://extensions/`
2. Enable "Developer mode" in the top right corner
3. Click "Load unpacked" button
4. Select the folder containing these extension files
5. The extension will appear in your extensions bar

## Usage

1. Click on the extension icon in the Chrome toolbar
2. The popup will automatically load and display:
   - The current tab's favicon
   - The current tab's title
   - The current tab's URL
   - The page's Open Graph description (if available)

## Files

- `manifest.json` - Extension configuration and permissions
- `popup.html` - Popup interface
- `popup.css` - Styling for the popup with favicon and description support
- `popup.js` - JavaScript functionality to automatically load tab information
- `content.js` - Content script to extract meta information from web pages

## Permissions

This extension requires the `activeTab` and `scripting` permissions to access the title, URL, favicon, and meta description of the currently active tab. The scripting permission is used to inject a content script that reads the page's meta tags. No other data is accessed or stored.

**Note**: The og:description feature will not work on restricted pages like `chrome://` URLs or other browser-internal pages due to security restrictions.