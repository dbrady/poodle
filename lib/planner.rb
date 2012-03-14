class Planner
  # TODO: Convert to a proper class that can be instantiated. Right now this is a module.
  # TODO: Break generate_pdf into front and back pages

  # Prawn-specific page layout units
  PAGE_WIDTH=720
  PAGE_HEIGHT=540
  TIME_SLOT_HEIGHT=9
  HEADER_HEIGHT=18
  CHECK_COLUMN_WIDTH=9
  TITLE_LABEL_WIDTH=140
  TITLE_LABEL_HEIGHT=18
  TITLE_X=510
  TITLE_Y=PAGE_HEIGHT+TITLE_LABEL_HEIGHT+4

  # Prawn-specific appearance characteristics
  THICK_LINE_WIDTH=0.2
  THIN_LINE_WIDTH=0.1
  LIGHT_LINE_OPACITY=0.75
  HOURLY_LABEL_FONT_SIZE=8

  # Some useful derived constants
  BODY_HEIGHT=PAGE_HEIGHT-HEADER_HEIGHT
  ROWS=BODY_HEIGHT/TIME_SLOT_HEIGHT

  # Total number of columns=8, but one is for TODO's
  DAYS_PER_WEEK=7
  TODO_COLUMNS=1
  # This is it--the number of columns on the front side of the planner
  COLUMNS=TODO_COLUMNS+DAYS_PER_WEEK
  COLUMN_WIDTH=PAGE_WIDTH/COLUMNS

  # Hour labels are marked on the planner
  START_HOUR=8
  END_HOUR=20

  # Right now time slots are 30 minutes
  HOUR_HEIGHT=TIME_SLOT_HEIGHT*2

  # The back page has 4x2 large sections, each filled with graph paper
  GRAPH_MAJOR_COLUMNS=4
  GRAPH_MAJOR_ROWS=2
  GRAPH_CELL_HEIGHT=9
  GRAPH_CELL_WIDTH=9

  def initialize(start_date)
    @start_date = start_date
  end

  def self.draw(start_date, filename)
    planner = Planner.new start_date.beginning_of_workweek
    pdf = planner.generate_pdf
    save_pdf pdf, filename
  end

  def generate_pdf
    Prawn::Document.new page_layout: :landscape do |pdf|
      generate_front_page pdf
      generate_back_page pdf
    end
  end

  def self.save_pdf(pdf, filename)
    open_file(filename, 'w') do |file|
      file.write pdf.render
    end
  end

  # This is just a wrapper to File.open so we can test this class
  # without stubbing File.open itself (which other programs in the
  # testing ecosystem are using). A later refactoring could make this
  # filename -> file conversion explicit, and eliminate the need for a
  # stub altogether.
  def self.open_file(filename, mode, &block)
    File.open(filename, mode) do |file|
      yield file
    end
  end

  def check_column_positions(&block)
    (0...PAGE_WIDTH).step(COLUMN_WIDTH) do |i|
      yield CHECK_COLUMN_WIDTH + i
    end
  end

  # Returns a label for the week starting on start_date, e.g. "Mar 5 -
  # 11, 2012". If the week spans a month, both month abbreviations are
  # included, e.g. "Mar 26 - Apr 1, 2012". The year is NOT duplicated
  # if it is spanned, mostly because it's very rare and the expansion
  # looks as weird as the unexpanded version. So the correct output
  # for Dec 26, 2011 would be e.g. "Dec 26 - Jan 1, 2012"
  def date_label_for_week
      end_date = @start_date + DAYS_PER_WEEK-1
      label = @start_date.strftime("%b %-d - ")
      label += end_date.strftime("%b ") if end_date.month != @start_date.month
      label += end_date.strftime("%-d, %Y")
  end

  def generate_front_page(pdf)
      # draw light horz lines--half-hour increments plus to-do list items
      pdf.line_width THIN_LINE_WIDTH
      pdf.opacity LIGHT_LINE_OPACITY do
        (0..BODY_HEIGHT).step(TIME_SLOT_HEIGHT) do |y|
          pdf.stroke_line [0,y], [PAGE_WIDTH,y]
        end
      end

      # ----------------------------------------------------------------------
      # Draw day boxes and outline
      # ----------------------------------------------------------------------
      # vertical lines at edges and between days
      pdf.line_width THICK_LINE_WIDTH
      (0..PAGE_WIDTH).step(COLUMN_WIDTH) do |x|
        pdf.stroke_line [x,0], [x,PAGE_HEIGHT]
      end

      # vertical lines inside day lines for ticking of to-dos
      pdf.line_width THIN_LINE_WIDTH
      check_column_positions do |x|
        pdf.stroke_line [x,0], [x,BODY_HEIGHT]
      end

      # horizontal lines across top and bottom
      pdf.line_width THICK_LINE_WIDTH
      [0,PAGE_HEIGHT].each do |y|
        pdf.stroke_line [0,y], [PAGE_WIDTH,y]
      end
      pdf.stroke_line [COLUMN_WIDTH,BODY_HEIGHT], [PAGE_WIDTH,BODY_HEIGHT]

      # ----------------------------------------------------------------------
      # Draw labels
      # ----------------------------------------------------------------------

      # Draw main title label, e.g "Jan 30-Feb 5, 2012
      label = date_label_for_week

      pdf.bounding_box [TITLE_X, TITLE_Y], width: TITLE_LABEL_WIDTH, height: TITLE_LABEL_HEIGHT do
        pdf.stroke_bounds
        pdf.text_box label, width: TITLE_LABEL_WIDTH, height: TITLE_LABEL_HEIGHT, align: :center, valign: :center, style: :bold
      end

      # Draw hourly column label 8, 9, 10, etc in Monday and Thursday columns
      old_font_size = pdf.font_size
      pdf.font_size HOURLY_LABEL_FONT_SIZE
      (START_HOUR..END_HOUR).each do |hour|
        # This is SO nasty. It sets how far down the page the hour
        # labels start counting--which was chosen arbitrarily.
        y = (BODY_HEIGHT+TIME_SLOT_HEIGHT)-hour*HOUR_HEIGHT
        [1,4].map {|column| column * COLUMN_WIDTH }.each do |x|
          label = (hour%12).to_s
          label = "12" if label == "0"
          pdf.bounding_box [x,y], width: CHECK_COLUMN_WIDTH, height: HOUR_HEIGHT do
            pdf.text_box label, width: CHECK_COLUMN_WIDTH, height: HOUR_HEIGHT, align: :right, valign: :center
          end
        end
      end
      pdf.font_size = old_font_size

      # Draw day labels, e.g. "Mon 1/30", "Tue 1/31", "Wed 2/1" etc.
      day_labels = (0...DAYS_PER_WEEK).map {|d| (@start_date + d).strftime("%a   %-m/%-d")}

      day_labels.map.with_index {|label, i| [label, (TODO_COLUMNS+i)*COLUMN_WIDTH]}.each do |label, x|
        pdf.text_box label, at: [x,PAGE_HEIGHT], height: HEADER_HEIGHT, width: COLUMN_WIDTH, align: :center, valign: :center, style: :bold
      end
  end

  def generate_back_page(pdf)
      pdf.start_new_page

      # lightweight graph
      pdf.line_width THIN_LINE_WIDTH

      pdf.opacity LIGHT_LINE_OPACITY do
        (0..PAGE_WIDTH).step(GRAPH_CELL_WIDTH) do |x|
          pdf.stroke_line [x,0], [x,PAGE_HEIGHT]
        end

        (0..PAGE_HEIGHT).step(GRAPH_CELL_HEIGHT) do |y|
          pdf.stroke_line [0,y], [PAGE_WIDTH,y]
        end
      end

      # bounds
      pdf.line_width THICK_LINE_WIDTH
      0.upto(GRAPH_MAJOR_COLUMNS).map { |i| i * PAGE_WIDTH/GRAPH_MAJOR_COLUMNS }.each do |x|
        pdf.stroke_line [x,0], [x,PAGE_HEIGHT]
      end

      0.upto(GRAPH_MAJOR_ROWS).map {|i| i * PAGE_HEIGHT/GRAPH_MAJOR_ROWS }.each do |y|
        pdf.stroke_line [0,y], [PAGE_WIDTH,y]
      end
  end
end

