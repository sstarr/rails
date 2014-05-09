require "isolation/abstract_unit"

module RailsLtsTests
  class StrictUnambiguousTableNamesTest < Test::Unit::TestCase
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

      assert !RailsLts.configuration.strict_unambiguous_table_names
    end

    def test_compatible_defaults
      add_to_config "config.rails_lts_options = { :default => :compatible }"
      load_environment

      assert !RailsLts.configuration.strict_unambiguous_table_names
    end

    def test_hardened_defaults
      add_to_config "config.rails_lts_options = { :default => :hardened }"
      load_environment

      assert RailsLts.configuration.strict_unambiguous_table_names
    end

  end
end
