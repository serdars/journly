module ApplicationHelper
  def js_templates
    templates = [ ]
    Dir[File.join(Rails.root, "app/views/templates/**/*")].each do |template_file|
      if File.extname(template_file) == ".haml"
        stripped_path = Pathname(template_file).relative_path_from(Rails.root.join("app/views/templates/")).to_s
        stripped_path.gsub!("_", "") # For the _ required in the name of the partial templates
        stripped_path.gsub!(".haml", "") # For the extension
        render_path = File.join("templates", stripped_path.gsub(".hmtl", ""))
        templates << {
          :id => stripped_path,
          :render_path => render_path
        }
      end
    end
    templates
  end
end
