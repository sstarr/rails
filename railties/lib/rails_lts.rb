module RailsLts

  class << self

    attr_accessor :configuration

    def finalize
      finalize_param_parsers
      finalize_json_html_entity_escaping
    end


    private

    def finalize_param_parsers
      if configuration.disable_json_parsing
        ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::JSON)
      end
      if configuration.disable_xml_parsing
        ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::XML)
      end
    end

    def finalize_json_html_entity_escaping
      if configuration.escape_html_entities_in_json
        ActiveSupport::JSON::Encoding.escape_html_entities_in_json = true
      end
    end

  end


  class Configuration

    attr_accessor :disable_json_parsing
    attr_accessor :disable_xml_parsing

    attr_accessor :escape_html_entities_in_json

    def initialize(options)
      if options.blank?
        $stderr.puts(%{Please configure your rails_lts_options using config.rails_lts_options inside Rails::Initializer.run. Defaulting to "rails_lts_options = { :default => :compatible }"})
      end

      options ||= {}

      set_defaults(options.delete(:default) || :compatible)

      options.each do |key, value|
        self.send("#{key}=", value)
      end
    end

    def set_defaults(default)
      unless [:hardened, :compatible].include?(default)
        raise ArgumentError.new("Rails LTS: default needs to be :hardened or :compatible")
      end
      case default
      when :hardened
        self.disable_json_parsing = true
        self.disable_xml_parsing = true
        self.escape_html_entities_in_json = true
      when :compatible
        self.disable_json_parsing = false
        self.disable_xml_parsing = false
        self.escape_html_entities_in_json = false
      end
    end

  end

end
