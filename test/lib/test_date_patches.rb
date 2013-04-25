require 'minitest/autorun'
require_relative '../../lib/date_patches'

class TestDatePatches < MiniTest::Unit::TestCase
  # from_wday is provided here merely as an executable comment so you
  # can see that beginning_of_workwook rewinds all days except Monday
  # to the previous Monday. (Mondays are returned unchanged.)
  def assert_rewinds(opts)
    from = Date.parse opts[:from]
    to = Date.parse opts[:to]
    opts[:from_wday].must_equal from.strftime("%a")
    to.must_equal from.beginning_of_workweek
  end

  def test_rewinds_to_previous_monday
    assert_rewinds :from => '2013-04-22', :from_wday => "Mon", :to => '2013-04-22'
    assert_rewinds :from => '2013-04-23', :from_wday => "Tue", :to => '2013-04-22'
    assert_rewinds :from => '2013-04-24', :from_wday => "Wed", :to => '2013-04-22'
    assert_rewinds :from => '2013-04-25', :from_wday => "Thu", :to => '2013-04-22'
    assert_rewinds :from => '2013-04-26', :from_wday => "Fri", :to => '2013-04-22'
    assert_rewinds :from => '2013-04-27', :from_wday => "Sat", :to => '2013-04-22'
    assert_rewinds :from => '2013-04-28', :from_wday => "Sun", :to => '2013-04-22'
  end
end
