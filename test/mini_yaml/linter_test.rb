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

  def test_multiline
    multiline = <<~YAML
      - this text is long let's ensure it is displayed as multiline
    YAML

    linted = MiniYaml::Linter.new(multiline, columns: 20).dump

    expected = <<~YAML
      ---
      - >-
        this text is long let's
        ensure it is displayed
        as multiline
    YAML

    assert_equal(expected, linted)
  end

  def test_edits
    yaml = <<~YAML
      # a comment
      - hello world
    YAML

    linter = MiniYaml::Linter.new(yaml)
    linter.contents << "another '\" world"

    expected = <<~YAML
      ---
      # a comment
      - hello world
      - "another '\\" world"
    YAML

    assert_equal(expected, linter.dump)
  end
end
