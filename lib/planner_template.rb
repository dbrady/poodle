require "prawn"
require_relative 'prawn_wrapper'
require_relative 'required_keyword_args'

class PlannerTemplate
  # Text string to separate beginning and end dates in date range
  DATE_RANGE_SEPARATOR = "-"

  private_attr_reader :prawn, :planner

  def initialize(planner: required('planner'))
    @planner = planner
  end

  def write_to file
    file.write prawn.render
  end

  def generate_pdf
    @prawn = PrawnWrapper.new
    generate_front_page
    prawn.start_new_page
    generate_back_page
    @prawn
  end

  # Returns a text string representing the date range of the week. If
  # both the year and the month change, both will be present in the
  # range, e.g. "Dec 26, 2011-Jan 1, 2012". Year will be omitted from
  # the first date if the year does not change: "Mar 26-Apr 1,
  # 2012". Month will be omitted from the second date if it does not
  # change: "Mar 12-18, 2012".
  def format_week week
    label = ""
    label += week.first.strftime "%b %-d"
    label += week.first.strftime ", %Y" if week.year_differs?
    label += DATE_RANGE_SEPARATOR
    label += week.last.strftime "%b " if week.month_differs?
    label += week.last.strftime "%-d, %Y"
  end

  def format_day date
    date.strftime "%a   %-m/%-d"
  end

  private

  # Prawn-specific page layout units
  PDF_GUTTER_OVERLAP_X=30.0
  PDF_GUTTER_OVERLAP_Y=30.0
  PAGE_WIDTH=720.0
  PAGE_HEIGHT=540.0
  PAGE_LEFT=0.0
  PAGE_TOP=540.0
  PAGE_BOTTOM=0.0
  TIME_SLOT_HEIGHT=9.0
  HEADER_HEIGHT=18.0
  CHECK_COLUMN_WIDTH=9.0

  # Prawn-specific appearance characteristics
  THICK_LINE_WIDTH=0.2
  THIN_LINE_WIDTH=0.1
  LIGHT_LINE_OPACITY=0.75
  HOURLY_LABEL_FONT_SIZE=8.0

  # Some useful derived constants
  BODY_TOP=PAGE_TOP-HEADER_HEIGHT
  BODY_BOTTOM=PAGE_BOTTOM
  BODY_LEFT=PAGE_LEFT-PDF_GUTTER_OVERLAP_X
  BODY_HEIGHT=PAGE_HEIGHT-HEADER_HEIGHT
  BODY_WIDTH=PAGE_WIDTH+PDF_GUTTER_OVERLAP_X*2
  BODY_RIGHT=PAGE_WIDTH+PDF_GUTTER_OVERLAP_X
  ROWS=BODY_HEIGHT/TIME_SLOT_HEIGHT

  # Title label position
  TITLE_LABEL_WIDTH=150.0
  TITLE_LABEL_HEIGHT=18.0
  TITLE_X=BODY_RIGHT-TITLE_LABEL_WIDTH
  TITLE_Y=PAGE_HEIGHT+TITLE_LABEL_HEIGHT+4.0

  # Total number of columns=8, but one is for TODO's
  DAYS_PER_WEEK=7
  TODO_COLUMNS=1
  # This is it--the number of columns on the front side of the planner
  COLUMNS=TODO_COLUMNS+DAYS_PER_WEEK
  COLUMN_WIDTH=BODY_WIDTH/COLUMNS

  # Hour labels are marked on the planner
  START_HOUR=8
  END_HOUR=20

  # Right now time slots are 30 minutes
  HOUR_HEIGHT=TIME_SLOT_HEIGHT*2

  # The back page has 4x2 large sections, each filled with graph paper
  GRAPH_CELL_HEIGHT=9.0
  GRAPH_CELL_WIDTH=9.0

  def generate_front_page
    draw_planner_skeleton
    draw_labels
  end

  def generate_back_page
    draw_graph_paper
  end

  def with_prawn_setting setting, value, &block
    old_value = prawn.send setting
    prawn.send "#{setting}=", value
    yield
    prawn.send "#{setting}=", old_value
  end

  def with_font_size font_size, &block
    with_prawn_setting(:font_size, font_size) do
      yield
    end
  end

  def with_line_width line_width, &block
    with_prawn_setting(:line_width, line_width) do
      yield
    end
  end

  def with_thick_pen &block
    with_line_width(THICK_LINE_WIDTH) do
      yield
    end
  end

  def with_thin_pen &block
    with_line_width(THIN_LINE_WIDTH) do
      yield
    end
  end

  def with_light_pen &block
    prawn.opacity LIGHT_LINE_OPACITY do
      yield
    end
  end

  def draw_time_slots
    with_thin_pen do
      with_light_pen do
        (PAGE_BOTTOM..BODY_HEIGHT).step(TIME_SLOT_HEIGHT) do |y|
          # TODO: Can we skip the tick boxes with times in them?
          # I mean, duhhhh, YES we can. But... easily? Not
          # really. It's a pain how we lay in the time labels right
          # now. Need to refactor this code until we're drawing cells
          # instead of drawing lines across the whole page. Then it
          # becomes easy. I'll leave that one for later.
          prawn.stroke_line [BODY_LEFT,y], [BODY_RIGHT,y]
        end
      end
    end
  end

  def column_x_position(i)
    BODY_LEFT + i * COLUMN_WIDTH
  end

  def column_x_positions
    (0..Float::INFINITY).lazy.map {|i| column_x_position i }
  end

  def draw_columns
    with_thick_pen do
      column_x_positions.first(COLUMNS+1).each do |x|
        prawn.stroke_line [x,0], [x,PAGE_HEIGHT]
      end
    end
  end

  def draw_checkoff_columns
    with_thin_pen do
      column_x_positions.first(COLUMNS).each do |x|
        prawn.stroke_line [x+CHECK_COLUMN_WIDTH,0], [x+CHECK_COLUMN_WIDTH,BODY_HEIGHT]
      end
    end
  end

  def draw_lines_around_header_and_bottom
    with_thick_pen do
      [0,BODY_HEIGHT,PAGE_HEIGHT].each do |y|
        prawn.stroke_line [BODY_LEFT,y], [BODY_RIGHT,y]
      end
    end
  end

  def draw_planner_skeleton
    draw_time_slots
    draw_columns
    draw_checkoff_columns
    draw_lines_around_header_and_bottom
  end

  def draw_page_title
    label = format_week planner.week

    with_thick_pen do
      prawn.bounding_box [TITLE_X, TITLE_Y], width: TITLE_LABEL_WIDTH, height: TITLE_LABEL_HEIGHT do
        prawn.stroke_bounds
        prawn.text_box label, width: TITLE_LABEL_WIDTH, height: TITLE_LABEL_HEIGHT, align: :center, valign: :center, style: :bold
      end
    end
  end

  def draw_hour_labels
    (START_HOUR..END_HOUR).each do |hour|
      # This is kinda nasty and implicit, but I think I'll leave it
      # for another day to clean up. What we do is decide that each
      # pair of time slots is an hour, and we start right at the top
      # of the planner. But we don't SHOW times until START_HOUR, and
      # we stop showing them after END_HOUR.
      y = BODY_HEIGHT + TIME_SLOT_HEIGHT - hour * HOUR_HEIGHT
      [1,4].map {|column| BODY_LEFT + column * COLUMN_WIDTH }.each do |x|
        label = (hour%12).to_s
        label = "12" if label == "0"
        prawn.bounding_box [x,y], width: CHECK_COLUMN_WIDTH, height: HOUR_HEIGHT do
          prawn.text_box label, width: CHECK_COLUMN_WIDTH, height: HOUR_HEIGHT, align: :right, valign: :center
        end
      end
    end
  end

  def draw_task_column_labels
    prawn.text_box "Tasks", at: [BODY_LEFT, PAGE_TOP], height: HEADER_HEIGHT, width: COLUMN_WIDTH, align: :center, valign: :center, style: :bold
  end

  def draw_day_column_labels
    day_labels = planner.week.days.map {|d| format_day d }

    day_labels.map.with_index {|label, i| [label, BODY_LEFT + (TODO_COLUMNS+i)*COLUMN_WIDTH]}.each do |label, x|
      prawn.text_box label, at: [x,PAGE_TOP], height: HEADER_HEIGHT, width: COLUMN_WIDTH, align: :center, valign: :center, style: :bold
    end
  end

  def draw_labels
    draw_page_title
    with_font_size(HOURLY_LABEL_FONT_SIZE) do
      draw_hour_labels
      draw_task_column_labels
      draw_day_column_labels
    end
  end

  def draw_graph_paper
    with_thin_pen do
      with_light_pen do
        (BODY_LEFT..BODY_RIGHT).step(GRAPH_CELL_WIDTH) do |x|
          prawn.stroke_line [x,BODY_BOTTOM], [x,PAGE_TOP+PDF_GUTTER_OVERLAP_Y-3] # 6 is a fudge factor; need to clean this up a bit
        end

        (BODY_BOTTOM..PAGE_TOP+PDF_GUTTER_OVERLAP_Y).step(GRAPH_CELL_HEIGHT) do |y|
          prawn.stroke_line [BODY_LEFT,y], [BODY_RIGHT-6,y] # 3 is a fudge factor; need to clean this up a bit
        end
      end
    end
  end
end
