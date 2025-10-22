module Jekyll
  class ControllersGenerator < Generator
    safe true
    priority :high

    def generate(site)
      controllers_dir = File.join(site.source, "assets", "javascript", "controllers")

      return unless File.directory?(controllers_dir)

      controllers = []

      Dir.glob(File.join(controllers_dir, "**", "*_controller.js")).sort.each do |file_path|
        relative_path = file_path.sub(controllers_dir + "/", "")

        path_parts = relative_path.split("/")
        filename = path_parts.pop

        base_name = filename.sub(/_controller\.js$/, "")
        base_name_parts = base_name.split("_")

        name_components = [path_parts.join("--")] + [base_name_parts.join("-")]
        name_components.reject!(&:empty?)
        name = name_components.join("--")

        class_name = [path_parts + base_name_parts].flatten.compact.map(&:capitalize).join + "Controller"

        path = "./controllers/#{relative_path}"

        controllers << {
          "name" => name,
          "class_name" => class_name,
          "path" => path,
          "filename" => filename,
          "relative_path" => relative_path
        }
      end

      site.data["controllers"] = controllers
    end
  end
end
