module Jekyll
  class EnvConfig < Generator
    def generate(site)
      site.config["api_host"] = case Jekyll.env
      when "test"
        "https://example.com"
      when "production"
        "https://feedbin.com"
      else
        "https://feedbin.resolv.app"
      end
    end
  end
end