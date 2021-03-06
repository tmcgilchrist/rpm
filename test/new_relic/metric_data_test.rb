require File.expand_path(File.join(File.dirname(__FILE__),'..', 'test_helper'))
require 'new_relic/metric_data'
class NewRelic::MetricDataTest < Test::Unit::TestCase
  def test_initialize_basic
    spec = mock('metric_spec')
    stats = mock('stats')
    metric_id = mock('metric_id')
    md = NewRelic::MetricData.new(spec, stats, metric_id)
    assert_equal spec, md.metric_spec
    assert_equal stats, md.stats
    assert_equal metric_id, md.metric_id
  end

  def test_eql_basic
    spec = mock('metric_spec')
    stats = mock('stats')
    metric_id = mock('metric_id')
    md1 = NewRelic::MetricData.new(spec, stats, metric_id)
    md2 = NewRelic::MetricData.new(spec, stats, metric_id)
    assert(md1.eql?(md2), "The example metric data objects should be eql?: #{md1.inspect} #{md2.inspect}")
    assert(md2.eql?(md1), "The example metric data objects should be eql?: #{md1.inspect} #{md2.inspect}")
  end

  def test_eql_unequal_specs
    spec = mock('metric_spec')
    other_spec = mock('other_spec')
    stats = mock('stats')
    metric_id = mock('metric_id')
    md1 = NewRelic::MetricData.new(spec, stats, metric_id)
    md2 = NewRelic::MetricData.new(other_spec, stats, metric_id)
    assert(!md1.eql?(md2), "The example metric data objects should not be eql?: #{md1.inspect} #{md2.inspect}")
    assert(!md2.eql?(md1), "The example metric data objects should not be eql?: #{md1.inspect} #{md2.inspect}")
  end
  def test_eql_unequal_stats
    spec = mock('metric_spec')
    stats = mock('stats')
    other_stats = mock('other_stats')
    metric_id = mock('metric_id')
    md1 = NewRelic::MetricData.new(spec, stats, metric_id)
    md2 = NewRelic::MetricData.new(spec, other_stats, metric_id)
    assert(!md1.eql?(md2), "The example metric data objects should not be eql?: #{md1.inspect} #{md2.inspect}")
    assert(!md2.eql?(md1), "The example metric data objects should not be eql?: #{md1.inspect} #{md2.inspect}")
  end

  def test_eql_unequal_metric_ids_dont_matter
    spec = mock('metric_spec')
    stats = mock('stats')
    metric_id = mock('metric_id')
    other_metric_id = mock('other_metric_id')
    md1 = NewRelic::MetricData.new(spec, stats, metric_id)
    md2 = NewRelic::MetricData.new(spec, stats, other_metric_id)
    assert(md1.eql?(md2), "The example metric data objects should be eql? with different metric_ids: #{md1.inspect} #{md2.inspect}")
    assert(md2.eql?(md1), "The example metric data objects should be eql? with different metric_ids: #{md1.inspect} #{md2.inspect}")
  end

  def test_original_spec_basic
    spec = mock('metric_spec')
    stats = mock('stats')
    metric_id = mock('metric_id')
    md1 = NewRelic::MetricData.new(spec, stats, metric_id)
    original_spec = md1.instance_variable_get('@original_spec')
    assert_equal(nil, original_spec, "should start with a nil original spec, but was #{original_spec.inspect}")
    assert_equal(spec, md1.metric_spec, "should return the metric spec for original spec when original spec is nil, but was #{md1.original_spec}")
  end

  def test_metric_spec_equal_should_not_set_original_spec_with_no_metric_spec
    stats = mock('stats')
    metric_id = mock('metric_id')
    md1 = NewRelic::MetricData.new(nil, stats, metric_id)
    original_spec = md1.instance_variable_get('@original_spec')
    assert_equal(nil, original_spec, "should start with a nil original spec, but was #{original_spec.inspect}")

    new_spec = mock('new metric_spec')
    assert_equal(new_spec, md1.metric_spec=(new_spec), "should return the new spec")

    new_original_spec = md1.instance_variable_get('@original_spec')
    assert_equal(nil, new_original_spec, "should not set @original_spec  but was #{new_original_spec.inspect}")
  end

  def test_metric_spec_equal_should_set_original_spec_with_existing_metric_spec
    spec = mock('metric_spec')
    stats = mock('stats')
    metric_id = mock('metric_id')
    md1 = NewRelic::MetricData.new(spec, stats, metric_id)
    original_spec = md1.instance_variable_get('@original_spec')
    assert_equal(nil, original_spec, "should start with a nil original spec, but was #{original_spec.inspect}")

    new_spec = mock('new metric_spec')
    assert_equal(new_spec, md1.metric_spec=(new_spec), "should return the new spec")

    new_original_spec = md1.instance_variable_get('@original_spec')
    assert_equal(spec, new_original_spec, "should set @original_spec to the existing metric_spec  but was #{new_original_spec.inspect}")
  end

  def test_hash
    spec = mock('metric_spec')
    stats = mock('stats')
    metric_id = mock('metric_id')
    md1 = NewRelic::MetricData.new(spec, stats, metric_id)
    assert((spec.hash ^ stats.hash) == md1.hash, "expected #{spec.hash ^ stats.hash} to equal #{md1.hash}")
  end

  def test_to_json_no_metric_id
    md = NewRelic::MetricData.new(NewRelic::MetricSpec.new('Custom/test/method', ''), NewRelic::Agent::Stats.new, nil)
    json = md.to_json
    assert(json.include?('"Custom/test/method"'), "should include the metric spec in the json")
    assert(json.include?('"metric_id":null}'), "should have a null metric_id")
  end

  def test_to_json_with_metric_id
    md = NewRelic::MetricData.new(NewRelic::MetricSpec.new('Custom/test/method', ''), NewRelic::Agent::Stats.new, 12345)
    assert_equal('{"metric_spec":null,"stats":{"total_exclusive_time":0.0,"min_call_time":0.0,"call_count":0,"sum_of_squares":0.0,"total_call_time":0.0,"max_call_time":0.0},"metric_id":12345}', md.to_json, "should not include the metric spec and should have a metric_id")
  end

  def test_to_s_with_metric_spec
    md = NewRelic::MetricData.new(NewRelic::MetricSpec.new('Custom/test/method', ''), NewRelic::Agent::Stats.new, 12345)
    assert_equal('Custom/test/method(): [ 0 calls 0.0000s]', md.to_s, "should not include the metric id and should include the metric spec")
  end

  def test_to_s_without_metric_spec
    md = NewRelic::MetricData.new(nil, NewRelic::Agent::Stats.new, 12345)
    assert_equal('12345: [ 0 calls 0.0000s]', md.to_s, "should include the metric id and not have a metric spec")
  end

  def test_to_collector_array_with_spec
    stats = NewRelic::Agent::Stats.new
    stats.record_data_point(1.0)
    stats.record_data_point(2.0, 1.0)
    md = NewRelic::MetricData.new(NewRelic::MetricSpec.new('Custom/test/method', 'scope'),
                                  stats, nil)
    expected = [ {'name' => 'Custom/test/method', 'scope' => 'scope'},
                 [2, 3.0, 2.0, 1.0, 2.0, 5.0] ]
    assert_equal expected, md.to_collector_array
  end

  def test_to_collector_array_with_spec_and_id
    stats = NewRelic::Agent::Stats.new
    stats.record_data_point(1.0)
    stats.record_data_point(2.0, 1.0)
    md = NewRelic::MetricData.new(NewRelic::MetricSpec.new('Custom/test/method', 'scope'),
                                  stats, 1234)
    expected = [ 1234, [2, 3.0, 2.0, 1.0, 2.0, 5.0] ]
    assert_equal expected, md.to_collector_array
  end

  def test_to_collector_array_with_id
    stats = NewRelic::Agent::Stats.new
    stats.record_data_point(1.0)
    stats.record_data_point(2.0, 1.0)
    md = NewRelic::MetricData.new(nil, stats, 1234)
    expected = [ 1234, [2, 3.0, 2.0, 1.0, 2.0, 5.0] ]
    assert_equal expected, md.to_collector_array
  end

  # Rationals in metric data? -- https://support.newrelic.com/tickets/28053
  def test_to_collector_array_with_rationals
    stats = NewRelic::Agent::Stats.new
    stats.call_count = Rational(1, 1)
    stats.total_call_time = Rational(2, 1)
    stats.total_exclusive_time = Rational(3, 1)
    stats.min_call_time = Rational(4, 1)
    stats.max_call_time = Rational(5, 1)
    stats.sum_of_squares = Rational(6, 1)

    md = NewRelic::MetricData.new(nil, stats, 1234)
    expected = [1234, [1, 2.0, 3.0, 4.0, 5.0, 6.0]]
    assert_equal expected, md.to_collector_array
  end

  def test_to_collector_array_with_bad_values
    stats = NewRelic::Agent::Stats.new
    stats.call_count = nil
    stats.total_call_time = "junk"
    stats.total_exclusive_time = Object.new
    stats.min_call_time = []
    stats.max_call_time = {}
    stats.sum_of_squares = Exception.new("Boo")

    md = NewRelic::MetricData.new(nil, stats, 1234)
    expected = [1234, [0, 0, 0, 0, 0, 0]]
    assert_equal expected, md.to_collector_array
  end
end
