# frozen_string_literal: true

require "test_helper"

class LinterTest < Minitest::Test
  def test_simple_list
    list = <<~YAML
      - 1
      - "one ' "
      - 'one'
      - 77 things
      - 77.1
    YAML

    linted = MiniYaml::Linter.new(list).dump

    expected = <<~YAML
      ---
      - 1
      - "one ' "
      - one
      - 77 things
      - 77.1
    YAML

    assert_equal(expected, linted)
  end
end
