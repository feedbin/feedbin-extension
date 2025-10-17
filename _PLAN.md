# Jekyll to Phlex Migration Plan

## Overview
This document outlines the step-by-step plan for migrating all Jekyll views and includes from the Feedbin Extension to Phlex components. The migration will maintain the existing directory structure and ensure all functionality is preserved. Read `phlex_renderer.rb` to help with understanding how to integrate jekyll variables and config into phlex views. After each step, verify your changes worked by running `bundle exec jekyll build`

## Current Structure
- **Jekyll Views**: `_includes/` directory with HTML templates
- **Phlex Views**: `_views/` directory with Ruby component classes
- **Entry Point**: `_views/index.rb` (already partially migrated)

## Files to Migrate

### Shared Components (`_includes/shared/` → `_views/shared/`)
- `icon.html` → `icon.rb`
- `checkbox.html` → `checkbox.rb`
- `favicon.html` → `favicon.rb`
- `spinner.html` → `spinner.rb`
- `message-icon.html` → `message_icon.rb`
- `error.html` → `error.rb`
- `tab.html` → `tab.rb`
- `nav.html` → `nav.rb`

### Main Components (`_includes/` → `_views/`)
- `page-info.html` → `page_info.rb`
- `add.html` → `add.rb`
- `save.html` → `save.rb`
- `newsletters.html` → `newsletters.rb`
- `settings.html` → `settings.rb`

## Migration Steps

### ✅ Phase 0: Planning
- [x] Document migration plan

### Phase 1: Shared Components Foundation
**Order**: Migrate in dependency order (most basic → most complex)

1. **Create _views/shared directory structure**
   - [ ] Create `_views/shared/` directory

2. **Migrate shared/icon.html to _views/shared/icon.rb**
   - [ ] Convert SVG template with dynamic width/height
   - [ ] Handle `include.icon` and `include.class` parameters
   - [ ] Reference `site.data.icons` for icon data

3. **Migrate shared/checkbox.html to _views/shared/checkbox.rb**
   - [ ] Convert checkbox input with extensive styling
   - [ ] Handle `include.attributes` for dynamic attributes

4. **Migrate shared/favicon.html to _views/shared/favicon.rb**
   - [ ] Convert favicon component
   - [ ] Handle `include.attributes` parameter

5. **Migrate shared/spinner.html to _views/shared/spinner.rb**
   - [ ] Convert spinner/loading indicator component

6. **Migrate shared/message-icon.html to _views/shared/message_icon.rb**
   - [ ] Convert message icon component
   - [ ] Handle `include.type` and `include.icon` parameters
   - [ ] Support different icon types (success, error, neutral)

7. **Migrate shared/error.html to _views/shared/error.rb**
   - [ ] Convert error message component
   - [ ] Handle `include.content` and `include.attributes` parameters

8. **Migrate shared/tab.html to _views/shared/tab.rb**
   - [ ] Convert scrollable tab container
   - [ ] Handle `include.content` and `include.button` parameters
   - [ ] Preserve scroll container and footer spacing logic

9. **Migrate shared/nav.html to _views/shared/nav.rb**
   - [ ] Convert navigation tabs component
   - [ ] Iterate over `site.data.tabs`
   - [ ] Use Icon component (dependency)
   - [ ] Handle radio button tab selection
   - [ ] Implement conditional hiding for native iOS

### Phase 2: Main Components
**Order**: Migrate in complexity order (simplest → most complex)

10. **Migrate page-info.html to _views/page_info.rb**
    - [ ] Convert page info display component
    - [ ] Use Favicon component (dependency)
    - [ ] Handle `include.format` parameter
    - [ ] Implement Stimulus controller data attributes

11. **Migrate save.html to _views/save.rb**
    - [ ] Convert save page form
    - [ ] Use MessageIcon, PageInfo, and Tab components (dependencies)
    - [ ] Handle form submission and state management
    - [ ] Implement Stimulus controller integration

12. **Migrate add.html to _views/add.rb**
    - [ ] Convert add/subscribe page form
    - [ ] Use Spinner, MessageIcon, Checkbox, Favicon, Icon, and Tab components (dependencies)
    - [ ] Handle feed and tag templates
    - [ ] Implement complex form logic and Stimulus integration

13. **Migrate newsletters.html to _views/newsletters.rb**
    - [ ] Convert newsletters management page
    - [ ] Use Spinner, Error, MessageIcon, Icon, and Tab components (dependencies)
    - [ ] Handle address and option templates
    - [ ] Implement complex form validation and state management

14. **Migrate settings.html to _views/settings.rb**
    - [ ] Convert settings/authentication page
    - [ ] Use Icon and Error components (dependencies)
    - [ ] Handle both authenticated and unauthenticated states
    - [ ] Implement sign-in form and iOS-specific behavior

### Phase 3: Integration & Testing

15. **Update _views/index.rb to use new Phlex components**
    - [ ] Replace `# TODO: {% include shared/nav.html %}` with Nav component
    - [ ] Replace `# TODO: {% include add.html %}` with Add component
    - [ ] Replace `# TODO: {% include save.html %}` with Save component
    - [ ] Replace `# TODO: {% include newsletters.html %}` with Newsletters component
    - [ ] Replace `# TODO: {% include settings.html %}` with Settings component
    - [ ] Replace icon symbols comment with actual icon implementation

16. **Test the application to ensure all components render correctly**
    - [ ] Verify all pages load without errors
    - [ ] Check that all Stimulus controllers are properly connected
    - [ ] Verify styling is preserved
    - [ ] Test all interactive functionality
    - [ ] Validate that data attributes are correctly applied
    - [ ] Test both authorized and unauthorized states
    - [ ] Verify iOS-specific behaviors

## Migration Guidelines

### Phlex Component Structure
```ruby
module Views
  module Shared
    class ComponentName < Phlex::HTML
      def initialize(**options)
        @options = options
      end

      def view_template
        # Component HTML structure
      end
    end
  end
end
```

### Key Considerations
1. **Naming Conventions**: Convert hyphenated filenames to snake_case (e.g., `message-icon.html` → `message_icon.rb`)
2. **Module Structure**: Use `Views::Shared` for shared components, `Views` for main components
3. **Parameters**: Replace Jekyll `include.param` with Ruby instance variables or method parameters
4. **Data Access**: Replace `site.data.x` with appropriate data access in Jekyll integration
5. **Conditionals**: Replace Liquid `{% if %}` with Ruby `if` statements
6. **Loops**: Replace Liquid `{% for %}` with Ruby iterators
7. **Attributes**: Use Phlex's attribute handling for dynamic HTML attributes
8. **Templates**: Convert `<template>` tags to appropriate Phlex structures

### Testing Strategy
- Test each component in isolation after migration
- Verify integration with parent components
- Check Stimulus controller connections
- Validate responsive behavior and styling
- Test edge cases and error states

## Notes
- Preserve all CSS classes exactly as they are
- Maintain all `data-` attributes for Stimulus controllers
- Keep all accessibility features (e.g., `sr-only` classes)
- Ensure proper nesting and structure is maintained
- Test thoroughly after each phase

## Current Status
- **Phase 0**: ✅ Complete
- **Phase 1**: 🔄 In Progress
- **Phase 2**: ⏳ Pending
- **Phase 3**: ⏳ Pending
