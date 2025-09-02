require "yaml"
require "json"
require "erb"

module Jekyll
  class ManifestGenerator < Generator
    def generate(site)
      path = File.join(site.source, "manifest.yml")
      data = ERB.new(File.read(path)).result
      data = YAML.load(data, aliases: true)

      target = ENV["BUILD_TARGET"] || "firefox"

      manifest = data[target]
      name = "manifest.json"
      path = File.join(site.dest, name)
      FileUtils.mkdir_p(site.dest)
      File.write(path, JSON.pretty_generate(manifest))
      site.keep_files << name
    end
  end
end
