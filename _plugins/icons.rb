module Jekyll
  class Icons < Generator
    def generate(site)
      svg_dir = File.join(site.source, "_svg")

      site.config["icons"] = Dir.glob(File.join(svg_dir, "*.svg")).each_with_object({}) do |path, hash|
        name    = File.basename(path, ".svg")
        doc     = Nokogiri::XML(File.read(path))
        svg     = doc.at_xpath("//*[local-name()='svg']")
        viewbox = svg["viewBox"]

        width, height = if viewbox
          parts = viewbox.split.map(&:to_f)
          parts.last(2).map {_1.to_f}
        end

        markup = svg.children.to_xml

        hash[name.to_sym] = OpenStruct.new(name:, width:, height:, markup:)
      end
    end
  end
end
