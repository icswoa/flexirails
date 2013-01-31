require "flexirails/version"

module Flexirails
end

if defined?(Rails::Railtie)
  module Flexirails
    class Railtie < ::Rails::Railtie
    end
  end
end

begin
  Rails::Engine
rescue
else
  module Flexirails
    class Engine < Rails::Engine
    end
  end
end
