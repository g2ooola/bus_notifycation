require 'yaml'

module Toolkits
  class Secret
    def self.info
      @@data ||= YAML.load_file('private/secret.yml')
    end
  end
end