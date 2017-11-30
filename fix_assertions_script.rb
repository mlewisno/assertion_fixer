require 'find'
require_relative 'fix_assertions'

Find.find('.') do |path|
  if path =~ /.*test\.rb$/
    text = File.read(path)

    6.times do
      # Apply the complex assert_difference calls
      10.downto(1) do |time|
        find = build_complex_assert_difference_find_regex(number_of_classes: time + 1, count_needed: true, parenthesis_needed: false)
        replace = build_complex_assert_difference_replace_regex(number_of_classes: time + 1, count_needed: true)
        text = text.gsub(Regexp.new(find), replace)

        find = build_complex_assert_difference_find_regex(number_of_classes: time + 1, count_needed: true, parenthesis_needed: true)
        replace = build_complex_assert_difference_replace_regex(number_of_classes: time + 1, count_needed: true)
        text = text.gsub(Regexp.new(find), replace)

        find = build_complex_assert_difference_find_regex(number_of_classes: time + 1, count_needed: false, parenthesis_needed: false)
        replace = build_complex_assert_difference_replace_regex(number_of_classes: time + 1, count_needed: false)
        text = text.gsub(Regexp.new(find), replace)

        find = build_complex_assert_difference_find_regex(number_of_classes: time + 1, count_needed: false, parenthesis_needed: true)
        replace = build_complex_assert_difference_replace_regex(number_of_classes: time + 1, count_needed: false)
        text = text.gsub(Regexp.new(find), replace)

        find = build_complex_assert_no_difference_find_regex(number_of_classes: time + 1, parenthesis_needed: false)
        replace = build_complex_assert_no_difference_replace_regex(number_of_classes: time + 1)
        text = text.gsub(Regexp.new(find), replace)

        find = build_complex_assert_no_difference_find_regex(number_of_classes: time + 1, parenthesis_needed: true)
        replace = build_complex_assert_no_difference_replace_regex(number_of_classes: time + 1)
        text = text.gsub(Regexp.new(find), replace)
      end

      # Apply the simple assert_difference calls
      find = build_simple_assert_difference_find_regex(count_needed: true, parenthesis_needed: false)
      replace = build_simple_assert_difference_replace_regex(count_needed: true)
      text = text.gsub(Regexp.new(find), replace)

      find = build_simple_assert_difference_find_regex(count_needed: true, parenthesis_needed: true)
      replace = build_simple_assert_difference_replace_regex(count_needed: true)
      text = text.gsub(Regexp.new(find), replace)

      find = build_simple_assert_difference_find_regex(count_needed: false, parenthesis_needed: false)
      replace = build_simple_assert_difference_replace_regex(count_needed: false)
      text = text.gsub(Regexp.new(find), replace)

      find = build_simple_assert_difference_find_regex(count_needed: false, parenthesis_needed: true)
      replace = build_simple_assert_difference_replace_regex(count_needed: false)
      text = text.gsub(Regexp.new(find), replace)

      find = build_simple_assert_no_difference_find_regex(parenthesis_needed: false)
      replace = build_simple_assert_no_difference_replace_regex
      text = text.gsub(Regexp.new(find), replace)

      find = build_simple_assert_no_difference_find_regex(parenthesis_needed: true)
      replace = build_simple_assert_no_difference_replace_regex
      text = text.gsub(Regexp.new(find), replace)
    end

    File.open(path, "w") {|file| file.puts text }
  end
end
