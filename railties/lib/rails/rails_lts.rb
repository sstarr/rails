module Rails

  module RailsLts

    class << self

      attr_accessor :configuration

      def finalize
        finalize_param_parsers
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

    end


    class Configuration

      attr_accessor :disable_json_parsing
      attr_accessor :disable_xml_parsing

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
        when :compatible
          self.disable_json_parsing = false
          self.disable_xml_parsing = false
        end
      end

    end

  end

end
