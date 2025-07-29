# Feedbin Subscribe & Save

The official Feedbin browser extension to subscribe to feeds and save pages to read later.

<img width="1280" height="800" alt="Extension screenshot" src="https://github.com/user-attachments/assets/158405ad-6920-499c-a667-39480bef9835" />

The extension currently targets these browsers:

- [Safari](https://apps.apple.com/us/app/feedbin/id1444961766) - Bundled with the Feedbin app, works on macOS, iOS & iPadOS
- [Firefox](https://addons.mozilla.org/en-US/firefox/addon/feedbin-subscribe-save/)
- [Chrome](https://chromewebstore.google.com/detail/feedbin-subscribe-save/dokieklajbcljjhhaabkjceopenlimco) - Should also work in Chromium based browsers like Edge, Arc, Brave, etc…

Development
-----------

The extension uses [Jekyll](https://github.com/jekyll/jekyll), the ruby static-site generator as a build tool. You'll need ruby and node installed.

After cloning, you can use the included cli tool to get started:

```bash
bin/extension setup
```

The extension is built to run in a browser as well as an extension context to make development easier.

Running

```bash
bin/extension run
```

Will open Firefox with the local extension loaded, as well as your browser. You call also use jekyll's commands to build the site like:

```bash
BUILD_TARGET=safari bundle exec jekyll serve --open-url --livereload --destination _site/safari
```

The other `BUILD_TARGET`s are `firefox` and `chrome`

Contributing & Support
----------------------

You can report issues and get support by emailing [support@feedbin.com](mailto:support@feedbin.com).

You can contribute by opening a pull request.

