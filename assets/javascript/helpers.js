export function sanitize(text) {
    let decoded = document.createElement('textarea')
    decoded.innerHTML = text
    return decoded.value
}

export function getHostname(url) {
  try {
    return new URL(url).hostname;
  } catch (e) {
    return url;
  }
}

export async function pageToken() {
  let result = await browser.storage.sync.get();
  return result.user?.page_token || null
}
