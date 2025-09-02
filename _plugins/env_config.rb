module Jekyll
  class EnvConfig < Generator
    def generate(site)
      ENV["API_HOST"] = site.config["api_host"] = case Jekyll.env
      when "test"
        "https://example.com"
      when "production"
        "https://feedbin.com"
      else
        "https://feedbin.mac.resolv.app"
      end
    end
  end
end
