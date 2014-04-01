require "isolation/abstract_unit"

module RailsLtsTests
  class EscapeHtmlEntitiesTest < Test::Unit::TestCase
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

      assert !Rails::RailsLts.configuration.escape_html_entities_in_json
    end

    def test_compatible_defaults
      add_to_config "config.rails_lts_options = { :default => :compatible }"
      load_environment

      assert !Rails::RailsLts.configuration.escape_html_entities_in_json
    end

    def test_hardened_defaults
      add_to_config "config.rails_lts_options = { :default => :hardened }"
      load_environment

      assert Rails::RailsLts.configuration.escape_html_entities_in_json
    end

    def test_enable_html_entities_escaping
      add_to_config "config.rails_lts_options = { :escape_html_entities_in_json => true }"
      load_environment

      assert_equal '"\\u003Cscript\\u003E"', ActiveSupport::JSON::Encoding.escape('<script>')
    end

    def test_disable_html_entities_escaping
      add_to_config "config.rails_lts_options = { :escape_html_entities_in_json => false }"
      load_environment

      assert_equal '"<script>"', ActiveSupport::JSON::Encoding.escape('<script>')
    end

  end
end
