require_relative "../spec_helper"

def execute_draw_planner(date, filename)
  system "bin/draw_planner -d #{date} -o #{filename}"
end

def execute_delete_planner(filename)
  system "rm #{filename}"
end

def get_md5_for_planner(filename)
  `md5 #{filename} | awk '{ print $4 }'`.strip
end

describe "Draw Planner (BLACK BOX API)" do
  describe "Generating planner for 2012-03-11" do
    before do
      @date = "2012-03-11"
      @planner_filename = "spec_planner_sheet.pdf"
      execute_draw_planner @date, @planner_filename
    end

    after do
      execute_delete_planner @planner_filename
    end


    it "should have correct md5 checksum" do
      get_md5_for_planner(@planner_filename).should == "772e21f0b42db4f59caaeaaa2e95f6ac"
    end
  end
end
