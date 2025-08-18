export function sanitize(text) {
  let decoded = document.createElement("textarea")
  decoded.innerHTML = text
  return decoded.value
}

export function getHostname(url) {
  try {
    return new URL(url).hostname
  } catch (e) {
    return url
  }
}

export function checkAuth() {
  const event = new Event("helpers:checkAuth", { bubbles: true });
  window.dispatchEvent(event);
}

export async function signOut() {
  await browser.storage.sync.remove("user")
  await browser.storage.sync.remove("tab")
  checkAuth()
}

export async function gzip(text) {
  const encoder = new TextEncoder()
  const data = encoder.encode(text)

  const compressionStream = new CompressionStream("gzip")
  const writer = compressionStream.writable.getWriter()
  writer.write(data)
  writer.close()

  const chunks = []
  const reader = compressionStream.readable.getReader()

  while (true) {
    const { done, value } = await reader.read()
    if (done) break
    chunks.push(value)
  }

  const totalLength = chunks.reduce((acc, chunk) => acc + chunk.length, 0)
  const result = new Uint8Array(totalLength)
  let offset = 0

  for (const chunk of chunks) {
    result.set(chunk, offset)
    offset += chunk.length
  }

  return result
}

export function detectBrowser() {
  const userAgent = navigator.userAgent.toLowerCase()

  if (userAgent.includes("firefox")) {
    return "firefox"
  } else if (userAgent.includes("safari") && !userAgent.includes("chrome")) {
    if (userAgent.includes("mobile") || userAgent.includes("iphone") || userAgent.includes("ipad")) {
      return "ios"
    }
    return "safari"
  }

  return "chrome"
}

export function loadFavicon(context, element, store) {
  const pageInfo = store.get("pageInfo")
  const controller = context.application.getControllerForElementAndIdentifier(element, "favicon")
  if (pageInfo.favicon && controller) {
    controller.load(pageInfo.favicon)
  }
}

export function prettyUrl(url) {
  try {
    const parsed = new URL(url)
    const segments = parsed
      .pathname
      .split('/')
      .filter(segment => segment.length > 0)

    return [parsed.hostname, ...segments].join(' › ')
  } catch (error) {
    return url
  }
}

export function afterTransition(element, condition, callback) {
  let timeout = 0
  if (condition) {
    timeout = parseFloat(getComputedStyle(element).transitionDuration) * 1000
  }
  setTimeout(callback, timeout)
}

export function debounce(callback, delay = 10) {
  let timeoutId = null

  return (...args) => {
    const debouncedCallback = () => callback.apply(this, args)
    clearTimeout(timeoutId)
    timeoutId = setTimeout(debouncedCallback, delay)
  }
}
