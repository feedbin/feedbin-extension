# Feedbin Extension - Project Documentation

## Project Overview
This is a Safari extension for Feedbin (RSS reader service) built with Jekyll static site generation and Phlex Ruby components for view rendering. The extension provides functionality for subscribing to feeds, saving pages, managing newsletter addresses, and authentication.

## Tech Stack
- **Jekyll**: Static site generator for building the extension
- **Phlex**: Ruby view framework for building HTML/SVG components (https://www.phlex.fun/)
- **Stimulus**: JavaScript framework for behavior (preserved via data attributes)
- **Tailwind CSS**: Styling (processed via PostCSS)

## Architecture

### Phlex Integration with Jekyll

The project uses a custom Jekyll + Phlex integration via `_plugins/phlex_renderer.rb`:

**Thread-local Storage Pattern**
- Jekyll site and page objects are stored in thread-local storage (`Thread.current[:jekyll_site]`, `Thread.current[:jekyll_page]`)
- This makes them globally accessible to all components without parameter passing
- Set in `PhlexRenderer.render` before component rendering

**Jekyll::Component Base Class**
All components inherit from `Jekyll::Component < Phlex::HTML` which provides:
- `site` - Access to Jekyll site object
- `page` - Access to Jekyll page object
- `config` - Access to site.config
- `data` - Access to site.data
- `environment` - Access to JEKYLL_ENV
- `build_url(url_key)` - Helper to construct full URLs from config

**Component Loading**
- All `.rb` files in `_views/` directory are loaded at startup via Jekyll hooks
- Components are organized in `Views` module namespace
- Liquid tag `{% phlex view_name %}` renders Phlex components in Jekyll templates

### Directory Structure

```
_views/
├── add.rb              # Feed subscription interface
├── save.rb             # Page bookmarking interface
├── settings.rb         # Authentication/settings
├── newsletters.rb      # Newsletter address management
├── index.rb            # Main entry point (renders all views)
├── page_info.rb        # Page metadata display component
└── shared/             # Reusable components
    ├── checkbox.rb
    ├── error.rb
    ├── favicon.rb
    ├── icon.rb         # SVG icon rendering
    ├── message_icon.rb
    ├── nav.rb
    ├── spinner.rb
    └── tab.rb

_plugins/
└── phlex_renderer.rb   # Phlex/Jekyll integration

_data/
└── icons.yml           # SVG icon definitions (width, height, markup)
```

## Key Components

### Icon System

**Views::Shared::Icon** - Main icon component
- Inherits from `Jekyll::Component`
- Renders SVG wrapper with icon dimensions
- Uses `IconUse` component to render `<use>` element

**Views::Shared::IconUse** - SVG use element
- Inherits from `Phlex::SVG` (NOT Phlex::HTML)
- Renders `<use href="#icon_name">` elements
- Uses native Phlex SVG methods

**IconSymbols** - Symbol definitions
- Defined inline in `index.rb`
- Inherits from `Phlex::SVG`
- Renders hidden `<svg>` with all icon `<symbol>` definitions
- Loaded from `site.data["icons"]`

### URL Building

**build_url(url_key)** - Helper method in Jekyll::Component
- Combines `site.config["api_host"]` (base URL) with `site.config["urls"][url_key]` (path)
- Example: `build_url("subscribe")` → `"https://api.feedbin.com/v2/subscriptions.json"`
- Used throughout components for API endpoints and external links

## Build Commands

```bash
# Development build
source ~/.bash_profile && bundle exec jekyll build

# Watch mode
source ~/.bash_profile && bundle exec jekyll serve --watch

# Run tests (if Rakefile exists)
source ~/.bash_profile && bundle exec rake
```

## Important Conventions

### Component Patterns

1. **No parameter passing for site/page** - Always access via instance methods:
   ```ruby
   # ✅ Correct
   class MyComponent < Jekyll::Component
     def view_template
       div { site.config["something"] }
     end
   end

   # ❌ Wrong
   class MyComponent < Jekyll::Component
     def initialize(site:, page:)
       @site = site
       @page = page
     end
   end
   ```

2. **SVG components use Phlex::SVG**:
   ```ruby
   # ✅ Correct
   class MySvgComponent < Phlex::SVG
     def view_template
       circle(cx: "50", cy: "50", r: "40")
     end
   end

   # ❌ Wrong - Don't use raw HTML strings
   class MySvgComponent < Jekyll::Component
     def view_template
       raw Phlex::SGML::SafeValue.new("<circle ...>")
     end
   end
   ```

3. **Use build_url for API/external URLs**:
   ```ruby
   # ✅ Correct
   form(action: build_url("subscribe"))

   # ❌ Wrong
   form(action: site.config["urls"]["subscribe"])
   ```

4. **Rendering child components**:
   ```ruby
   # ✅ Correct - No site/page parameters
   render Shared::Icon.new(icon: "logo")

   # ❌ Wrong
   render Shared::Icon.new(site: site, page: page, icon: "logo")
   ```

## Configuration Files

### _config.yml
Contains:
- `api_host` - Base URL for API calls
- `urls` - Hash of API endpoints and external links
- Jekyll configuration

### _data/icons.yml
Structure:
```yaml
icon_name:
  width: 24
  height: 24
  markup: "<path d='...' />"
```

## Recent Refactorings

1. **SVG Rendering** - Migrated from raw HTML strings to native Phlex::SVG components
2. **Parameter Elimination** - Removed site/page parameter passing using thread-local storage
3. **URL Helper** - Centralized URL construction with build_url method

## Common Gotchas

- Always use `source ~/.bash_profile` before Ruby commands (per user's global CLAUDE.md)
- SVG components must inherit from `Phlex::SVG`, not `Phlex::HTML`
- Components with `**attributes` will capture all keyword arguments as HTML attributes
- Thread-local storage is set per-render, safe for concurrent builds
- Icon markup from YAML is rendered with `raw Phlex::SGML::SafeValue.new()`

## Testing

After making changes:
1. Run `bundle exec jekyll build` to verify no errors
2. Check `_site/` directory for generated HTML
3. Test in Safari extension context if needed
