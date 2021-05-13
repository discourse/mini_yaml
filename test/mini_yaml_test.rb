# frozen_string_literal: true

require "test_helper"

class MiniYamlTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::MiniYaml::VERSION
  end
end
