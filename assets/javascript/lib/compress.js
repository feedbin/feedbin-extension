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
