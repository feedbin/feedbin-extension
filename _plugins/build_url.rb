require "uri"

module Jekyll
  module BuildUrlFilter
    def build_url(path)
      base = @context.registers[:site].config["api_host"]
      URI.join(base, path).to_s
    end
  end
end

Liquid::Template.register_filter(Jekyll::BuildUrlFilter)