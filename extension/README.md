# Tab Info Display Extension

A browser extension that displays the current tab's title, favicon, and OpenGraph description information.

## Features

- Displays current tab title and favicon
- Extracts OpenGraph description from web pages
- Fallback to standard meta description
- Copy tab title to clipboard
- Compatible with Chrome, Edge, and Firefox

## Installation

### Chrome/Edge
1. Open Chrome/Edge and navigate to `chrome://extensions/` or `edge://extensions/`
2. Enable "Developer mode"
3. Click "Load unpacked" and select the extension folder

### Firefox
1. Open Firefox and navigate to `about:debugging`
2. Click "This Firefox"
3. Click "Load Temporary Add-on"
4. Select the `manifest.json` file from the extension folder

## Firefox Compatibility

This extension has been specifically updated to work with Firefox's stricter content security and structured cloning requirements.

### Firefox-Specific Features
- Uses Firefox-compatible content script injection
- Handles structured cloning limitations
- Includes browser-specific polyfills
- Provides fallback mechanisms for restricted pages

### Known Firefox Issues and Solutions

#### "Script result is non-structured-clonable data" Error
This error was addressed by:
- Wrapping content scripts in IIFE to avoid global pollution
- Using only plain objects in message passing
- Implementing Firefox-specific injection methods
- Adding proper error handling and fallbacks

#### Content Script Injection Failures
The extension includes multiple fallback mechanisms:
- Primary: Firefox-optimized content script (`content-firefox.js`)
- Fallback: Direct function injection
- Error handling for restricted pages (chrome://, about:, etc.)

## Files Structure

```
extension/
├── manifest.json           # Extension manifest with Firefox compatibility
├── popup.html             # Extension popup interface
├── popup.js              # Popup entry point with Stimulus
├── popup.css             # Popup styling
├── application.js        # Stimulus application setup
├── content.js            # Standard content script (Chrome/Edge)
├── content-firefox.js    # Firefox-optimized content script
├── test.html            # Test page for development
├── controllers/
│   └── tab_info_controller.js  # Main controller with Firefox detection
└── lib/
    ├── stimulus.js       # Stimulus framework
    └── polyfill.js      # WebExtension polyfill
```

## Development

### Testing
1. Load the test page (`test.html`) in your browser
2. Install the extension
3. Navigate to the test page
4. Click the extension icon to verify functionality

### Debugging Firefox Issues
1. Open Firefox Developer Tools (F12)
2. Go to Console tab
3. Look for any extension-related errors
4. Check `about:debugging` for extension logs

### Common Firefox Debugging Steps
1. Verify the extension loads without errors in `about:debugging`
2. Test on the included `test.html` page first
3. Check browser console for structured cloning errors
4. Ensure the extension works on standard HTTP/HTTPS pages before testing on special pages

## Browser Compatibility

| Browser | Version | Status |
|---------|---------|--------|
| Chrome  | 88+     | ✅ Full support |
| Edge    | 88+     | ✅ Full support |
| Firefox | 109+    | ✅ Full support with optimizations |

## Permissions

- `activeTab`: Access to the currently active tab
- `scripting`: Ability to inject content scripts
- `host_permissions`: Access to HTTP/HTTPS pages for content extraction

## Technical Notes

### Firefox-Specific Optimizations
- Separate content script for Firefox to avoid structured cloning issues
- Browser detection to use appropriate injection method
- Enhanced error handling and timeout mechanisms
- Simplified message passing with plain objects only

### Structured Cloning
Firefox is stricter about structured cloning when passing data between extension contexts. This extension addresses this by:
- Using only plain objects and primitive values in messages
- Avoiding function references and DOM nodes in return values
- Implementing proper error boundaries

## Troubleshooting

### Extension doesn't work on certain pages
- The extension cannot access `chrome://`, `about:`, `moz-extension://` pages
- This is by design for security reasons
- Test on regular websites (HTTP/HTTPS)

### "Could not inject content script" errors
- Normal for restricted pages
- Extension includes fallback mechanisms
- Check browser console for specific error details

### Firefox-specific issues
- Ensure Firefox version 109 or higher
- Check `about:debugging` for extension errors
- Verify the extension ID is properly set in manifest
- Test with the included `test.html` page first

## License

This extension is provided as-is for educational and development purposes.