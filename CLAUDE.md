# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a browser extension for Feedbin that allows users to subscribe to websites and save pages to read in Feedbin. It's built using Jekyll as a static site generator with the following architecture:

- **Browser Extension**: Manifest v3 WebExtension targeting Chrome and Firefox
- **Frontend Framework**: Stimulus.js for JavaScript controllers
- **Build System**: Jekyll with PostCSS and Tailwind CSS
- **Testing**: Ruby with Capybara for system tests using Cuprite (headless Chrome)

## Development Commands

### Build and Development
```bash
# Build the extension (Jekyll generates static files to _site/)
source ~/.bash_profile && bundle exec jekyll build

# Watch and rebuild during development
source ~/.bash_profile && bundle exec jekyll serve --watch

# Test Firefox extension
npm run start:firefox

# Lint extension
npm run lint

# Lint individual files (run after any edits)
npx prettier --write [file_path]
```

### Testing
```bash
# Run all tests
source ~/.bash_profile && bundle exec rake test

# Run specific test file
source ~/.bash_profile && bundle exec ruby _test/add_test.rb
```
## Stimulus with Tailwind classes

When creating a stimulus controller, never set styles or classes directly on elements. Instead leverage stimulus `values` combined with tailwind data attributes. Here is an example:

<div class="group" data-controller="chat" data-chat-icon-value="true">
  <img class="hidden group-data-[chat-icon-value=true]:block">
</div>

Then to toggle the icon visibility you only need to toggle the `this.iconValue = true` to show the icon

## Architecture

### File Structure
- `assets/javascript/`: Main JavaScript source files
  - `application.js`: Entry point that registers all Stimulus controllers
  - `controllers/`: Stimulus controllers for different extension features
  - `store.js`: Shared state management
  - `helpers.js`: Utility functions
- `_includes/`: Jekyll partial templates for UI components
- `_test/`: Ruby system tests using Capybara
- `_site/`: Generated extension files (build output)

### Key Components

**Stimulus Controllers Architecture**:
- `app_controller.js`: Main controller handling authorization and page data loading
- `settings_controller.js`: User authentication and settings
- `tabs_controller.js`: Tab navigation within popup
- `add_controller.js`: Subscribe to feeds functionality
- `save_controller.js`: Save pages to Feedbin
- `page_info_controller.js`: Extract page metadata
- `subscribe_controller.js`: Handle subscription workflow

**Extension Permissions**:
- `activeTab`: Access current tab information
- `scripting`: Inject content scripts for page data extraction
- `storage`: Store user credentials and settings

**API Integration**:
The extension integrates with Feedbin API endpoints defined in `_config.yml`:
- Authentication: `/extension/authentication.json`
- Save pages: `/extension/pages.json`
- Find feeds: `/extension/subscriptions/new.json`
- Subscribe: `/extension/subscriptions/create.json`

### Content Script Architecture
The extension uses content scripts to extract page metadata (title, description, feeds) from visited pages. The main controller (`app_controller.js:38-41`) injects both polyfill and content script files into the active tab.

### State Management
Uses a simple Store class (`store.js`) to manage:
- User authentication state
- Current page information (title, URL, favicon, etc.)

### Testing Strategy
System tests use Capybara with Cuprite (headless Chrome) to test the full extension UI. Tests include authentication flows, feed discovery, and save functionality. Mock API responses are handled via CapybaraMock.

## Build Process

Jekyll processes the source files and outputs a complete browser extension to `_site/`. The build includes:
1. JavaScript bundling and ES6 module support
2. CSS processing with PostCSS and Tailwind
3. Asset optimization and copying
4. Manifest.json generation

The extension supports both development and production builds with different debug settings and polyfill loading.