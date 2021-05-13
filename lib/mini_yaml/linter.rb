# frozen_string_literal: true
require 'yaml'

module MiniYaml
  class Linter
    def initialize(yaml, paranoid: true, columns: 80)
      @comment_map = nil
      @parsed = parse(yaml)
      @columns = columns

      if paranoid
        before, before_e, after, after_e = nil

        begin
          before = YAML.load(yaml)
        rescue => e
          before_e = e
        end

        begin
          after = YAML.load(dump)
        rescue => e
          after_e = e
        end

        if before != after
          STDERR.puts "ERROR YAML mismatch:"
          STDERR.puts
          STDERR.puts "BEFORE TEXT"
          STDERR.puts yaml
          STDERR.puts "AFTER"
          STDERR.puts dump

          STDERR.puts "BEFORE OBJ"
          STDERR.puts before.inspect
          if before_e
            STDERR.puts before_e
          end
          STDERR.puts "AFTER OBJ"
          STDERR.puts after.inspect
          if after_e
            STDERR.puts after_e
          end

          raise "Failed to correctly generate YAML"
        end
      end
    end

    # malliable array/hash structure
    def contents
      @parsed
    end

    def dump
      buffer = +"---\n"

      if leading = @comment_map[:leading]
        buffer << leading
        buffer << "\n"
      end

      _dump(node: @parsed, buffer: buffer, indent: 0, path: "", prev_indent: 0)

      if trailing = @comment_map[:trailing]
        buffer << trailing
      end

      buffer
    end

    protected

    def to_multiline(val)
      buf = +""

      val.split("\n").each do |line|

        if line.match?(/^\s/)
          buf.rstrip!
          buf << "\n"
          buf << line
          buf << "\n"
        else
          col = 0

          index = 0
          while char = line[index]
            prev_char = line[index - 1]
            next_char = line[index + 1]

            if col > @columns && char == " " && prev_char.match?(/\S/) && next_char.match?(/\S/)
              buf << "\n"
              col = 0
            else
              buf << char
            end

            col += 1

            index += 1
          end
          buf << "\n" if buf[-1] != "\n"
          buf << "\n"
        end

      end

      buf.rstrip!
      buf
    end

    def format_string(val, comment)
      result = +""

      quote = false

      if String === val
        if !val.include?("\n") && !(String === scalar_scanner.tokenize(val))
          quote = true
        elsif val.match?(/[\{\}\(\)\/]/)
          quote = true
        end
      end

      val = val.to_s

      if val.include?("\n") || val.length > @columns
        lines = val.split("\n")
        force_short = lines.map(&:length).max > @columns
        strip_trailing_newline = val[-1] != "\n"

        if force_short
          result << ">"
          val = to_multiline(val)
        else
          result << "|"
        end

        if strip_trailing_newline
          result << "-"
        end

        if comment
          result << " ##{comment.gsub(/$#/,"").gsub("\n", " ")}"
        end
        result << "\n"
        result << val
      else
        if val.match?(/['":]/) || quote
          result << val.inspect
        else
          result << val
        end
        if comment
          result << " "
          first = true

          comment = comment.split("\n").map do |line|
            r = +""
            if !first
              r += " " * result.length
            else
              first = false
            end
            r << line
          end.join("\n")

          result << comment
        end
      end

      if result[-1] != "\n"
        result << "\n"
      end

      result
    end

    def _dump(node:, buffer:, indent:, path:, prev_indent:)
      case node
      when Array
        if node == []
          buffer << "[]\n"
        else
          node.each do |child|
            buffer << " " * indent if buffer[-1] == "\n"
            buffer << "- "
            _dump(node: child, buffer: buffer, indent: indent + 2, path: path + "-", prev_indent: indent)
          end
        end
      when Hash
        node.each do |key, value|
          buffer << " " * indent if buffer[-1] == "\n"
          buffer << "#{key}:"
          if value == []
            buffer << " []\n"
          elsif Hash === value || Array === value
            buffer << "\n"
            _dump(node: value, buffer: buffer, indent: indent + 2, path: path + ":#{key}", prev_indent: indent)
          else
            buffer << " "
            _dump(node: value, buffer: buffer, indent: indent + key.length + 2, path: path + ":#{key}", prev_indent: indent)
          end
        end
      else
        comment = @comment_map[path + node.to_s]

        string = format_string(node, comment)
        formatted = string.split("\n")
        buffer << formatted.shift.to_s
        buffer << "\n"

        formatted.each do |line|
          if line.length > 0
            buffer << " " * (prev_indent + 2)
            buffer << line
          end
          buffer << "\n"
        end
      end
    end

    def find_comment(lines, node, prev_node)
      start_col = 0
      start_line = 0
      if prev_node
        start_col = prev_node.end_column
        start_line = prev_node.end_line
      end

      finish_col = lines[-1].length
      finish_line = lines.count

      if node
        finish_col = node.start_column
        finish_line = node.start_line
      end

      current_lines = lines[start_line..finish_line]

      if current_lines.length == 0
        return ""
      end

      if current_lines.length == 1
        current_lines[0] = current_lines[0][start_col..finish_col]
      else
        current_lines[0] = current_lines[0][start_col..-1]
        current_lines[-1] = current_lines[-1][0...finish_col]
      end

      current_lines.map do |line|
        if idx = line.index("#")
          line[idx..-1]
        end
      end.compact.join("\n")
    end

    def parse(yaml)
      parsed = nil
      state = State.new(yaml)

      YAML.parse_stream(yaml).each do |node|
        if Psych::Nodes::Document === node
          parsed = to_simple(node, state: state, location: '')
          break
        end
      end

      @comment_map = state.comment_map

      parsed
    end

    def scalar_scanner
      @scalar_scanner ||= Psych::ScalarScanner.new(Psych::ClassLoader.new)
    end

    class State
      attr_accessor :lines, :comment_map, :nodes, :locations
      def initialize(yaml)
        @lines = yaml.split("\n")
        @comment_map = {}
        @nodes = []
        @locations = []
      end
    end

    def to_simple(node, state:, location:)
      comment = find_comment(state.lines, state.nodes[-1], state.nodes[-2])
      if !comment.empty? && !state.locations[-2].nil?
        state.comment_map[state.locations[-2]] = comment
      elsif state.locations.length == 1 && !comment.empty?
        state.comment_map[:leading] = comment
      end

      state.nodes << node
      state.locations << location

      if Psych::Nodes::Sequence === node
        container = node.children.map do |inner|
          to_simple(inner, location: location + "-", state: state)
        end
        return container
      end

      if Psych::Nodes::Mapping === node
        container = {}
        node.children.each_slice(2) do |key, value|
          k = to_simple(key, state: state, location: location + ":")
          v = to_simple(value, state: state, location: location + ":" + k)
          container[k] = v
        end
        return container
      end

      if Psych::Nodes::Scalar === node
        val =  node.quoted ? node.value : scalar_scanner.tokenize(node.value)
        state.locations[-1] += val.to_s
        return val
      end

      if Psych::Nodes::Document === node
        if node.children.count > 1
          raise "document with multiple children is not supported"
        end
        val = to_simple(node.children.first, location: location, state: state)

        comment = find_comment(state.lines, nil, state.nodes[-1])
        if !comment.empty?
          state.comment_map[:trailing] = comment
        end
        return val
      end

      raise "Unexpected node type #{node}"
    end
  end
end
