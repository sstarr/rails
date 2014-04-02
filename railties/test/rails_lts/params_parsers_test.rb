require "isolation/abstract_unit"

module RailsLtsTests
  class ParamsParsersTest < Test::Unit::TestCase
    include ActiveSupport::Testing::Isolation

    def setup
      build_app
      boot_rails
    end

    def teardown
      teardown_app
    end

    def load_environment
      require "#{rails_root}/config/environment"
    end

    def test_no_config_defaults
      load_environment

      assert !RailsLts.configuration.disable_json_parsing
      assert !RailsLts.configuration.disable_xml_parsing
    end

    def test_compatible_defaults
      add_to_config "config.rails_lts_options = { :default => :compatible }"
      load_environment

      assert !RailsLts.configuration.disable_json_parsing
      assert !RailsLts.configuration.disable_xml_parsing
    end

    def test_hardened_defaults
      add_to_config "config.rails_lts_options = { :default => :hardened }"
      load_environment

      assert RailsLts.configuration.disable_json_parsing
      assert RailsLts.configuration.disable_xml_parsing

      assert_equal [], ActionDispatch::ParamsParser::DEFAULT_PARSERS.keys
    end

    def test_disable_json_parsing
      add_to_config "config.rails_lts_options = { :disable_json_parsing => true }"
      load_environment

      assert !RailsLts.configuration.disable_xml_parsing
      assert RailsLts.configuration.disable_json_parsing

      assert_equal [Mime::XML], ActionDispatch::ParamsParser::DEFAULT_PARSERS.keys
    end

    def test_disable_xml_parsing
      add_to_config "config.rails_lts_options = { :disable_xml_parsing => true }"
      load_environment

      assert !RailsLts.configuration.disable_json_parsing
      assert RailsLts.configuration.disable_xml_parsing

      assert_equal [Mime::JSON], ActionDispatch::ParamsParser::DEFAULT_PARSERS.keys
    end

  end
end
