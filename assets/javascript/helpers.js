export function sanitize(text) {
    let decoded = document.createElement('textarea')
    decoded.innerHTML = text
    return decoded.value
}

export function hostname(url) {
  try {
    return new URL(url).hostname;
  } catch (e) {
    return url;
  }
}