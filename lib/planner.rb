class Planner
  def self.draw(start_date, filename)
    start_date = self.rewind_to_monday start_date
    pdf = generate_planner_pdf start_date
    save_pdf pdf, filename
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

  # Returns first Monday on or before start_date
  def self.rewind_to_monday(start_date)
    delta = start_date.wday - 1
    delta += 7 if delta < 0 # Sundays will advance the date by default
    start_date -= delta
  end

  PAGE_WIDTH=720
  PAGE_HEIGHT=540
  TIME_SLOT_HEIGHT=9
  HEADER_HEIGHT=18
  CHECK_COLUMN_WIDTH=9
  GRID_HEIGHT=9
  GRID_WIDTH=9
  TITLE_LABEL_WIDTH=140
  TITLE_LABEL_HEIGHT=18
  TITLE_X=510
  TITLE_Y=PAGE_HEIGHT+TITLE_LABEL_HEIGHT+4

  BODY_HEIGHT=PAGE_HEIGHT-HEADER_HEIGHT

  ROWS=BODY_HEIGHT/TIME_SLOT_HEIGHT
  DAYS_PER_WEEK=7
  TODO_COLUMNS=1
  COLUMNS=TODO_COLUMNS+DAYS_PER_WEEK
  COLUMN_WIDTH=PAGE_WIDTH/COLUMNS

  THICK_LINE_WIDTH=0.2
  THIN_LINE_WIDTH=0.1
  LIGHT_LINE_OPACITY=0.75

  START_HOUR=8
  END_HOUR=20

  HOUR_HEIGHT=TIME_SLOT_HEIGHT*2

  def self.check_column_positions(&block)
    (0...PAGE_WIDTH).step(COLUMN_WIDTH) do |i|
      yield CHECK_COLUMN_WIDTH + i
    end
  end

  def self.generate_planner_pdf(start_date)
    pdf = Prawn::Document.new page_layout: :landscape do
      # ======================================================================
      # Front Page

      # draw light horz lines--half-hour increments plus to-do list items
      line_width THIN_LINE_WIDTH
      opacity LIGHT_LINE_OPACITY do
        (0..BODY_HEIGHT).step(TIME_SLOT_HEIGHT) do |y|
          stroke_line [0,y], [PAGE_WIDTH,y]
        end
      end

      # ----------------------------------------------------------------------
      # Draw day boxes and outline
      # ----------------------------------------------------------------------
      # vertical lines at edges and between days
      line_width THICK_LINE_WIDTH
      (0..PAGE_WIDTH).step(COLUMN_WIDTH) do |x|
        stroke_line [x,0], [x,PAGE_HEIGHT]
      end

      # vertical lines inside day lines for ticking of to-dos
      line_width THIN_LINE_WIDTH
      Planner.check_column_positions do |x|
        stroke_line [x,0], [x,BODY_HEIGHT]
      end

      # horizontal lines across top and bottom
      line_width THICK_LINE_WIDTH
      [0,PAGE_HEIGHT].each do |y|
        stroke_line [0,y], [PAGE_WIDTH,y]
      end
      stroke_line [COLUMN_WIDTH,BODY_HEIGHT], [PAGE_WIDTH,BODY_HEIGHT]

      # ----------------------------------------------------------------------
      # Draw labels
      # ----------------------------------------------------------------------

      # calculate dates for this planner
      # TODO: EXTRACT AND TEST ME, DAVID
      # TODO: OR YOUR LIFE IS FORFEIT AND RANDY WILL MAKE HIS POO FACE
      end_date = start_date + DAYS_PER_WEEK-1
      label = start_date.strftime("%b %-d - ")
      label += end_date.strftime("%b ") if end_date.month != start_date.month
      label += end_date.strftime("%-d, %Y")

      # Draw main title label, e.g "Jan 30-Feb 5, 2012
      bounding_box [TITLE_X, TITLE_Y], width: TITLE_LABEL_WIDTH, height: TITLE_LABEL_HEIGHT do
        stroke_bounds
        text_box label, width: TITLE_LABEL_WIDTH, height: TITLE_LABEL_HEIGHT, align: :center, valign: :center, style: :bold
      end

      # Draw hourly column label 8, 9, 10, etc in Monday and Thursday columns
      old_font_size = font_size
      font_size 8
      (START_HOUR..END_HOUR).each do |hour|
        # This is SO nasty. It sets how far down the page the hour labels start counting.
        y = (BODY_HEIGHT+TIME_SLOT_HEIGHT)-hour*HOUR_HEIGHT
        [1,4].each do |column|
          x = column * COLUMN_WIDTH
          label = (hour%12).to_s
          label = "12" if label == "0"
          bounding_box [x,y], width: CHECK_COLUMN_WIDTH, height: HOUR_HEIGHT do
            text_box label, width: CHECK_COLUMN_WIDTH, height: HOUR_HEIGHT, align: :right, valign: :center
          end
        end
      end
      font_size = old_font_size

      # Draw day labels, e.g. "Mon 1/30", "Tue 1/31", "Wed 2/1" etc.
      days = (0...DAYS_PER_WEEK).map {|d| (start_date + d).strftime("%a   %-m/%-d")}

      (0..DAYS_PER_WEEK).each do |i|
        next if i.zero?
        x = i * COLUMN_WIDTH
        y = PAGE_HEIGHT
        text_box days[i-1], at: [x,y], height: HEADER_HEIGHT, width: COLUMN_WIDTH, align: :center, valign: :center, style: :bold
      end

      # ======================================================================
      # Back Page

      start_new_page

      # lightweight graph
      line_width THIN_LINE_WIDTH

      opacity LIGHT_LINE_OPACITY do
        x = 0
        while x <= PAGE_WIDTH
          stroke_line [x,0], [x,PAGE_HEIGHT]
          x += GRID_WIDTH
        end

        y = 0
        while y <= PAGE_HEIGHT
          stroke_line [0,y], [PAGE_WIDTH,y]
          y += GRID_HEIGHT
        end
      end

      # bounds
      line_width THICK_LINE_WIDTH
      (0..4).each do |i|
        x = i * PAGE_WIDTH/4.0
        stroke_line [x,0], [x,PAGE_HEIGHT]
      end

      (0..2).each do |i|
        y = i * PAGE_HEIGHT/2.0
        stroke_line [0,y], [PAGE_WIDTH,y]
      end
    end
  end
end

