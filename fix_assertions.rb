# Update script to keep applying gsub until the pattern match is completely blank for the find regexp

def build_simple_assert_difference_find_regex(count_needed:, parenthesis_needed:)
  if parenthesis_needed
    regex_suffix = count_needed ? ',\s*([^\)\s]*[^\)]*[^\)\s]+)\s*\)\s*do' : '\s*\)\s*do'
    'assert_difference\s*\(\s*([@A-Za-z:_.]*),\s*:([a-z_]*)' + regex_suffix
  else
    regex_suffix = count_needed ? ',\s*([^\)\s]*[^\)]*[^\)\s]+)\s*do' : '\s*do'
    'assert_difference\s*([@A-Za-z:_.]*),\s*:([a-z_]*)' + regex_suffix
  end
end

def build_simple_assert_difference_replace_regex(count_needed:)
  regex_suffix = count_needed ? ', \3 do' : ' do'
  'assert_difference \'\1.\2\'' + regex_suffix
end

def build_simple_assert_no_difference_find_regex(parenthesis_needed:)
  if parenthesis_needed
    'assert_no_difference\s*\(\s*([@A-Za-z:_.]*),\s*:([a-z_]*)\s*\)\s*do'
  else
    'assert_no_difference\s*([@A-Za-z:_.]*),\s*:([a-z_]*)\s*do'
  end
end

def build_simple_assert_no_difference_replace_regex
  'assert_no_difference \'\1.\2\' do'
end

def build_complex_assert_difference_find_regex(number_of_classes:, count_needed:, parenthesis_needed:)
  class_constant_string = (['([@A-Za-z:_.]*)\s*'] * number_of_classes).join(',\s*')
  if parenthesis_needed
    regex_suffix = count_needed ? ',\s*([^\)\s]*[^\)]*[^\)\s])\s*\)\s*do' : '\s*\)\s*do'
    'assert_difference\s*\(\s*\[\s*' + class_constant_string + '\]\s*,\s*:([a-z_]*)' + regex_suffix
  else
    regex_suffix = count_needed ? ',\s*([^\)\s]*[^\)]*[^\)\s])\s*do' : '\s*do'
    'assert_difference\s*\[\s*' + class_constant_string + '\]\s*,\s*:([a-z_]*)' + regex_suffix
  end
end

def build_complex_assert_difference_replace_regex(number_of_classes:, count_needed:)
  regex_suffix = count_needed ? ", \\#{number_of_classes + 2} do" : ' do'
  if number_of_classes == 1
    'assert_difference \'\1.\2\'' + regex_suffix
  else
    class_constant_and_method_string = build_replace_class_constant_and_method_array(number_of_classes: number_of_classes).join(' ')

    'assert_difference %w(' + class_constant_and_method_string + ')' + regex_suffix
  end
end

def build_complex_assert_no_difference_find_regex(number_of_classes:, parenthesis_needed:)
  class_constant_string = (['([@A-Za-z:_.]*)\s*'] * number_of_classes).join(',\s*')
  if parenthesis_needed
    '^\s*assert_no_difference\s*\(\s*\[\s*' + class_constant_string + '\]\s*,\s*:([a-z_]*)\s*\)\s*do'
  else
    '^\s*assert_no_difference\s*\[\s*' + class_constant_string + '\]\s*,\s*:([a-z_]*)\s*do'
  end
end

def build_complex_assert_no_difference_replace_regex(number_of_classes:)
  if number_of_classes == 1
    'assert_no_difference \'\1.\2\' do'
  else
    class_constant_and_method_string = build_replace_class_constant_and_method_array(number_of_classes: number_of_classes).join(' ')

    'assert_no_difference %w(' + class_constant_and_method_string + ') do'
  end
end

def build_replace_class_constant_and_method_array(number_of_classes:)
  [].tap do |array|
    number_of_classes.times do |number|
      array <<  "\\#{number + 1}.\\#{number_of_classes + 1}"
    end
  end
end
