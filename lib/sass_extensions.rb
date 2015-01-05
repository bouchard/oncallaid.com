require 'compass'
module Compass::SassExtensions::Functions::Files

  # Generate a filename with @2x appended to the end
  def retina_filename(image_file)
    filename = image_file.value
    parts = filename.split('.')
    ext = parts.pop
    f = parts.pop
    f = f + "@2x"
    parts.push(f)
    parts.push(ext)
    Sass::Script::String.new(parts.join('.'))
  end
end

module Sass::Script::Functions
  include Compass::SassExtensions::Functions::Files
end