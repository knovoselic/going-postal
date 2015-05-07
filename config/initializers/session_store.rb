# Be sure to restart your server when you modify this file.
Rails.logger.warn 'Change key name and remove this'\
                  'line (initializers/session_store.rb).'
Rails.application.config.session_store :cookie_store,
                                       key: '_changeme-web_session'
