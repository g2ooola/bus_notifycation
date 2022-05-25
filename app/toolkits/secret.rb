require 'yaml'

module Toolkits
  class Secret
    def self.info
      @@data ||= begin
        thing = YAML.load_file('private/secret.yml')
        thing.inspect
      end
    end
  end
end