require_relative "../spec_helper"

def execute_draw_planner(date, filename)
  system "bin/draw_planner -d #{@date} -f #{@planner_filename}"
end

def execute_delete_planner(filename)
  system "rm -f #{filename}"
end

def get_md5_for_planner(filename)
  # OSX
  # `md5 #{filename} | awk '{ print $4 }'`.strip
  # Linux
  `md5sum #{filename} | awk '{print $1 }'`.strip
end

describe "Draw Planner (BLACK BOX API)" do
  describe "Generating planner for 2012-03-11" do
    before do
      @date = "2012-03-11"
      @planner_filename = "spec_planner_sheet.pdf"
      execute_delete_planner @planner_filename
      execute_draw_planner @date, @planner_filename
    end

    after do
      execute_delete_planner @planner_filename
    end

    it "has the correct md5 checksum" do
      get_md5_for_planner(@planner_filename).should == MAGIC_MD5_CHECKSUM
    end
  end
end
