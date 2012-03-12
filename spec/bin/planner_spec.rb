require_relative '../spec_helper'

describe Planner do
  describe ".rewind_to_monday" do
    it "rewinds date to previous Monday" do
      Planner.rewind_to_monday(Date.parse('2012-03-15')).should == Date.parse('2012-03-12')
    end

    it "does not rewind if given date is a Monday" do
      Planner.rewind_to_monday(Date.parse('2012-03-12')).should == Date.parse('2012-03-12')
    end
  end
end
