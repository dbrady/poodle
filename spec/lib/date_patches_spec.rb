require_relative '../spec_helper'

describe Date do
  describe ".beginning_of_workweek" do
    it "rewinds date to previous Monday" do
      Date.parse('2012-03-15').beginning_of_workweek.should == Date.parse('2012-03-12')
    end

    it "does not rewind if given date is a Monday" do
      Date.parse('2012-03-12').beginning_of_workweek.should == Date.parse('2012-03-12')
    end

    it "rewinds if given date is a Sunday" do
      Date.parse('2012-03-11').beginning_of_workweek.should == Date.parse('2012-03-05')
    end
  end
end

