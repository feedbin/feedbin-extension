require "yaml"
require "json"

module Jekyll
  class ManifestGenerator < Generator
    safe true
    priority :high

    def generate(site)
      manifest_yml = File.join(site.source, "manifest.yml")
      data = YAML.safe_load_file(manifest_yml, aliases: true)

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