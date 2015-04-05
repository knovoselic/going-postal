# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
# Compile controller-specific assets
controllers_path = Rails.root.join('app/controllers/*_controller.rb')
precompile_names = Dir[controllers_path].flat_map do |path|
  name = path.match(/(?<name>\w+)_controller\.rb/)[:name]
  ["#{name}.js", "#{name}.css"]
end
Rails.application.config.assets.precompile += precompile_names
