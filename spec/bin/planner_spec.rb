require_relative '../spec_helper'

describe Planner do
  describe ".munge_start_date" do
    it "rewinds date to previous Monday" do
      Planner.munge_start_date(Date.parse('2012-03-15')).should == Date.parse('2012-03-12')
    end

    it "does not rewind if given date is a Monday"
  end
end
