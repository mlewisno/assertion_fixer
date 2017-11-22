require 'minitest/autorun'
require_relative 'fix_assertions'

class MyTest < Minitest::Test
  def test_simple_assert_difference_swap__count_needed
    find = build_simple_assert_difference_find_regex(count_needed: true, parenthesis_needed: false)
    replace = build_simple_assert_difference_replace_regex(count_needed: true)

    # Module namespacing, method calls
    text = 'assert_difference PayableInvoice::Thing.trust_me, :count, +2 do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_difference 'PayableInvoice::Thing.trust_me.count', +2 do", new_text

    # Instance variables, weirder method names
    text = 'assert_difference @my_variable_name, :not_my_name, 10 do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_difference '@my_variable_name.not_my_name', 10 do", new_text

    # Parenthesis

    find = build_simple_assert_difference_find_regex(count_needed: true, parenthesis_needed: true)
    replace = build_simple_assert_difference_replace_regex(count_needed: true)

    # Instance variables, weirder method names
    text = 'assert_difference(TrustMe, :count, -1) do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_difference 'TrustMe.count', -1 do", new_text

    text = 'assert_difference(TrustMe, :count, testing) do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_difference 'TrustMe.count', testing do", new_text
  end

  def test_simple_assert_difference_swap__count_not_needed
    find = build_simple_assert_difference_find_regex(count_needed: false, parenthesis_needed: false)
    replace = build_simple_assert_difference_replace_regex(count_needed: false)

    # Module namespacing, method calls
    text = 'assert_difference PayableInvoice::Thing.trust_me, :count do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_difference 'PayableInvoice::Thing.trust_me.count' do", new_text

    # Instance variables, weirder method names
    text = 'assert_difference @my_variable_name, :not_my_name do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_difference '@my_variable_name.not_my_name' do", new_text

    # Parenthesis

    find = build_simple_assert_difference_find_regex(count_needed: false, parenthesis_needed: true)
    replace = build_simple_assert_difference_replace_regex(count_needed: false)

    text = 'assert_difference(TrustMe, :count) do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_difference 'TrustMe.count' do", new_text
  end

  def test_simple_assert_no_difference_swap
    find = build_simple_assert_no_difference_find_regex(parenthesis_needed: false)
    replace = build_simple_assert_no_difference_replace_regex

    # Module namespacing, method calls
    text = 'assert_no_difference PayableInvoice::Thing.trust_me, :count do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_no_difference 'PayableInvoice::Thing.trust_me.count' do", new_text

    # Instance variables, weirder method names
    text = 'assert_no_difference @my_variable_name, :not_my_name do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_no_difference '@my_variable_name.not_my_name' do", new_text

    # Parenthesis

    find = build_simple_assert_no_difference_find_regex(parenthesis_needed: true)
    replace = build_simple_assert_no_difference_replace_regex

    text = 'assert_no_difference(TrustMe, :count) do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_no_difference 'TrustMe.count' do", new_text
  end

  def test_complex_assert_difference_swap__count_needed__multiple_objects
    find = build_complex_assert_difference_find_regex(number_of_classes: 3, count_needed: true, parenthesis_needed: false)
    replace = build_complex_assert_difference_replace_regex(number_of_classes: 3, count_needed: true)

    # Module namespacing, method calls, weird array spacing
    text = 'assert_difference [   PayableInvoice::Thing.trust_me,color   , @my_variable_name], :method_test, 5 do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_difference %w(PayableInvoice::Thing.trust_me.method_test color.method_test @my_variable_name.method_test), 5 do", new_text

    # Failed to translate for some reason...
    text = 'assert_difference [Email, ActsAsTaggableOn::Tag, ActsAsTaggableOn::Tagging], :count, 2 do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_difference %w(Email.count ActsAsTaggableOn::Tag.count ActsAsTaggableOn::Tagging.count), 2 do", new_text

    # Parenthesis

    find = build_complex_assert_difference_find_regex(number_of_classes: 3, count_needed: true, parenthesis_needed: true)
    replace = build_complex_assert_difference_replace_regex(number_of_classes: 3, count_needed: true)

    text = 'assert_difference([   PayableInvoice::Thing.trust_me,color   , @my_variable_name], :count, test_my_limits.try) do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_difference %w(PayableInvoice::Thing.trust_me.count color.count @my_variable_name.count), test_my_limits.try do", new_text
  end

  def test_multiline_replaces
    # Test multiline stuff
    find = build_complex_assert_difference_find_regex(number_of_classes: 2, count_needed: true, parenthesis_needed: false)
    replace = build_complex_assert_difference_replace_regex(number_of_classes: 2, count_needed: true)

    text = <<-TEXT
    assert_difference [RecurringReceivableInvoice, RecurringReceivableInvoiceDetail], :count, 6 do
          assert_difference [RecurringReceivableInvoice, RecurringReceivableInvoiceDetail], :count, 4 do
            invoice_attrs = {remarks: 'foo', party: @occupancy, due_on: Clock.today + 1 }
    TEXT

    new_text = text.gsub(Regexp.new(find), replace).gsub(Regexp.new(find), replace)

    expected_text = <<-TEXT
    assert_difference %w(RecurringReceivableInvoice.count RecurringReceivableInvoiceDetail.count), 6 do
          assert_difference %w(RecurringReceivableInvoice.count RecurringReceivableInvoiceDetail.count), 4 do
            invoice_attrs = {remarks: 'foo', party: @occupancy, due_on: Clock.today + 1 }
    TEXT
    assert_equal expected_text, new_text

    find = build_simple_assert_difference_find_regex(count_needed: true, parenthesis_needed: false)
    replace = build_simple_assert_difference_replace_regex(count_needed: true)

    text = <<-TEXT
    assert_difference ParallelJob, :count, 1 do
            assert_enqueued_jobs 1 do
              assert_enqueued_with(expected_job_attributes) do
    TEXT

    new_text = text.gsub(Regexp.new(find), replace).gsub(Regexp.new(find), replace)
    expected_text = <<-TEXT
    assert_difference 'ParallelJob.count', 1 do
            assert_enqueued_jobs 1 do
              assert_enqueued_with(expected_job_attributes) do
    TEXT

    assert_equal expected_text, new_text
  end

  def test_complex_assert_difference_swap__count_not_needed__multiple_objects
    find = build_complex_assert_difference_find_regex(number_of_classes: 3, count_needed: false, parenthesis_needed: false)
    replace = build_complex_assert_difference_replace_regex(number_of_classes: 3, count_needed: false)

    # Module namespacing, method calls, weird array spacing
    text = 'assert_difference [   PayableInvoice::Thing.trust_me,color   , @my_variable_name], :method_test do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_difference %w(PayableInvoice::Thing.trust_me.method_test color.method_test @my_variable_name.method_test) do", new_text

    # Parenthesis

    find = build_complex_assert_difference_find_regex(number_of_classes: 3, count_needed: false, parenthesis_needed: true)
    replace = build_complex_assert_difference_replace_regex(number_of_classes: 3, count_needed: false)

    text = 'assert_difference([   PayableInvoice::Thing.trust_me,color   , @my_variable_name], :count) do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_difference %w(PayableInvoice::Thing.trust_me.count color.count @my_variable_name.count) do", new_text
  end

  def test_complex_assert_difference_swap__count_needed__one_object
    find = build_complex_assert_difference_find_regex(number_of_classes: 1, count_needed: true, parenthesis_needed: false)
    replace = build_complex_assert_difference_replace_regex(number_of_classes: 1, count_needed: true)

    # Module namespacing, method calls, weird array spacing
    text = 'assert_difference [   PayableInvoice::Thing.trust_me], :method_test, 5 do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_difference 'PayableInvoice::Thing.trust_me.method_test', 5 do", new_text

    # Parenthesis

    find = build_complex_assert_difference_find_regex(number_of_classes: 1, count_needed: true, parenthesis_needed: true)
    replace = build_complex_assert_difference_replace_regex(number_of_classes: 1, count_needed: true)

    text = 'assert_difference([   PayableInvoice::Thing.trust_me], :count, test_my_limits.try) do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_difference 'PayableInvoice::Thing.trust_me.count', test_my_limits.try do", new_text
  end

  def test_complex_assert_difference_swap__count_not_needed__one_object
    find = build_complex_assert_difference_find_regex(number_of_classes: 1, count_needed: false, parenthesis_needed: false)
    replace = build_complex_assert_difference_replace_regex(number_of_classes: 1, count_needed: false)

    # Module namespacing, method calls, weird array spacing
    text = 'assert_difference [   PayableInvoice::Thing.trust_me], :method_test do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_difference 'PayableInvoice::Thing.trust_me.method_test' do", new_text

    # Parenthesis

    find = build_complex_assert_difference_find_regex(number_of_classes: 1, count_needed: false, parenthesis_needed: true)
    replace = build_complex_assert_difference_replace_regex(number_of_classes: 1, count_needed: false)

    text = 'assert_difference([   PayableInvoice::Thing.trust_me], :count) do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_difference 'PayableInvoice::Thing.trust_me.count' do", new_text
  end

  def test_complex_assert_no_difference_swap__multiple_objects
    find = build_complex_assert_no_difference_find_regex(number_of_classes: 3, parenthesis_needed: false)
    replace = build_complex_assert_no_difference_replace_regex(number_of_classes: 3)

    # Module namespacing, method calls, weird array spacing
    text = 'assert_no_difference [   PayableInvoice::Thing.trust_me,color   , @my_variable_name], :method_test do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_no_difference %w(PayableInvoice::Thing.trust_me.method_test color.method_test @my_variable_name.method_test) do", new_text

    # Parenthesis

    find = build_complex_assert_no_difference_find_regex(number_of_classes: 3, parenthesis_needed: true)
    replace = build_complex_assert_no_difference_replace_regex(number_of_classes: 3)

    text = 'assert_no_difference([   PayableInvoice::Thing.trust_me,color   , @my_variable_name], :count) do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_no_difference %w(PayableInvoice::Thing.trust_me.count color.count @my_variable_name.count) do", new_text
  end

  def test_complex_assert_no_difference_swap__one_object
    find = build_complex_assert_no_difference_find_regex(number_of_classes: 1, parenthesis_needed: false)
    replace = build_complex_assert_no_difference_replace_regex(number_of_classes: 1)

    # Module namespacing, method calls, weird array spacing
    text = 'assert_no_difference [   PayableInvoice::Thing.trust_me], :method_test do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_no_difference 'PayableInvoice::Thing.trust_me.method_test' do", new_text

    # Parenthesis

    find = build_complex_assert_no_difference_find_regex(number_of_classes: 1, parenthesis_needed: true)
    replace = build_complex_assert_no_difference_replace_regex(number_of_classes: 1)

    text = 'assert_no_difference([   PayableInvoice::Thing.trust_me], :count) do'
    new_text = text.gsub(Regexp.new(find), replace)

    assert_equal "assert_no_difference 'PayableInvoice::Thing.trust_me.count' do", new_text
  end
end
