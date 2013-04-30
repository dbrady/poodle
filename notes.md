# Notes

---
# 2013-04-22

Prior to MWRC, planner.rb contained the code for bin/draw_planner and
there were no methods or classes anywhere; all I did to refactor it
was to extract the Planner class and separate the driver script from
the application. Everything in Planner is still in there, and it's
screamingly obvious that this is a huge SRP violation.

At least Randy and I got it broken down into a bunch of methods; this
should make things easier to move around.

But let's think for a minute what this app does. Given a date and a
filename, a planner sheet is generated as a PDF and saved to that
file. The week starts on Monday (my arbitrary preference), so any
non-Monday date you give it is rewound to the previous Monday.

Seems to me that the entire contents of the planner main application
should be as simple as "given a date and a filename, generate a PDF
planner sheet". There is something that knows the template or layout
of the planner sheet, and it plugs those dates into that template.

A Wild Goal Appears!

I would like changing that template to have no effect on the rest of
the application: the date ranging, the file generation, or even the
PDF library. As much as I hate -er class names let's call this
PlannerDrawer. It could be a PlannerPresenter or even a
PlannerPdfRenderer, both just as bad, IMO. Hrm, now that I think about
it PlannerTemplate might be a sufficient name. A Draw-er or Render-er
or Present-er or a Template all express slightly different intentions
and therefore I need to think on the responsibilities a bit more--

Goal uses Analysis Paralysis!

NO, no wait. I need to refactor this ugly thing right NOW, and ANY of
these classes are WAY better than none at all, and I can refactor from
one to the other later. I like Template for now, I'll use that.

dbrady uses JFDI! It's super effective! Goal faints!

Okay, so a Planner works with a Template. The Template knows how to
make a drawing of a planner sheet, and maybe how to plug in the data
it needs from the Planner. That might end up being the job of a
Renderer or Presenter. Rails doesn't have the Template do the actual
drawing, for example, but in pure Ruby's, the Erb class does just
that--you yield your binding into the template.result() method.

For now, and in the spirit of JFDI, let's let Template act like
Erb. That way we can tuck all of Prawn inside the Template and tease
the Template/Render/Prawn stuff apart later.

Another hidden responsibility thus exposed is that a single date is
given but several formatted strings are calculated and
emitted. Consider the week containing March 7th, 2012. That's a
Wednesday, so the planner rewinds to Monday, March 5th. It generates
daily headers like "Mon 3/5", "Tue 3/6", etc for each weekday. It also
generates a title date range "Mar 5 - 11, 2012" that I use as an index
label for searching through old planner sheets once I have filed
them. I monkeypatched `beginning_of_workweek` onto the Date class, which
is okay I guess, but now that I see I have 2 different day/date
formats that are special to this planner, some kind of DateFormatting
robot would be of help here. That or `workweek_date_range` could also
be patched onto Date, but that starts to smell. The problem with
`workweek_date_range` is that it's pretty complicated. If the date
range spans months, it must include them, e.g. "Apr 29 - May 28, 2013"
and once a year the date can span years as well: "Dec 31, 2012 - Jan 6
2013". Template or even Date can handle the daily headers, they're
just `strftime "%a %-m/%-d"` but the date range is a special
formatter. Pass a helper method to Template? Dunno, let's burn that
bridge when we get to it.


---
# 2013-04-24

Finished the conversion to MiniTest. In it I saw that the specs (and
thus the tests that I converted) for Planner concern themselves almost
entirely with the `date_label_for_week` method. I don't want to get
off into the weeds messing with DateRange formatting but this is the
strongest smell coming out of my test suite right now so I'm willing
to follow it.

I also found that `beginning_of_workweek` has two annoying
dependencies: it is currently monkeypatched into Date, and it makes a
key assumption about the first day of the week. I'm kind of okay about
the second one because I don't see me changing that, ever, and the
change seems simple enough should we want to make it more generic. But
adding the monkeypatch got awkward from the test suite in some odd
places (specifically when trying to test the Planner class without the
monkeypatch loaded in advance. Seems like this is a weird load-order
dependency that I should be able to clear up.)

So, today's goals:

* [X] Add Guard

* [X] Extract `date_label_for_week` to some other class. Possibly a
  `DateRange` of some kind. Look at ActiveSupport; they play around
  with making `Date` an acceptable value to go inside a `Range`
  object, though I'm pretty sure it makes no sense to try to teach
  `Range` how to format times...

* [X] Actually ended up extracting the `beginning_of_week` monkeypatch
  into a Week class, where I expect `date_label_for_week` to reside
  soon as well.

* [X] Isolate the `date_patches.rb` dependency so it's cleaner.

* [X] Ditto for `prawn_patches.rb` if possible?

* [-] Try to refactor `test_draw_planner` to JUST test the bin driver
  WITHOUT actually needing to call system() to do it. Probably could
  do it by creating a `PlannerApplication` class and having
  `draw_planner` just call `PlannerApplication.new(ARGV).run!` but I'm
  not sure that's really the way I want to go. Will have to
  see. Deferred for now. Can probably push args onto ARGV and then
  spy out the Planner.create call; unsure.

---
# 2013-04-25

Really pleased with the refactorings in `test_planner.rb`, but also
surprised at how long it took--close to three hours. I think saving
that time would have been a good example of a false economy, however:
While those refactorings will not make the code better *enough* to
make it worth three hours of refactoring, the refactorings *did* need
to be done *and* I needed to get the *practice* doing them. I could
now probably refactor code of the same complexity in about an hour,
maybe less, and the benefits to that test file would be totally worth
that amount of time. So in short, let's say it was a one-point
refactoring, and thus totally worth it, but because I was learning as
I went, it took me three hours instead of one.

For today, I still have this task hanging out from yesterday:

* [ ] The last big obvious smell coming from the code (so far--I
  assume many more layers of smell are buried under this surface
  layer) is from all the Prawn code. Start grouping up and isolating
  all the Prawn drawing code. Right now we create and pass around a
  `@pdf` ivar and do all our Prawn operations on it. See about
  isolating that and extracting it to another class.

I also have the following goals for today:

* [ ] Refactor the `test_date_label_for_week` tests. Yes, really--MORE
  refactorings in the stupid tests. Because they read like crap right
  now.

* [ ] Rename `Week#date_label_for_week` to `Week#date_label` and come
  up with a format language or give it a set of options, eg
  `:date_separator => ' - '`, `:show_year_change_on_left => false`,
  `:month_format => '%b'`, etc.

---
# 2013-04-28

Got sidetracked, spent most of the last 3 days writing the
`scoped_attr_accessors` gem. Worth it. Will include it in the project
as soon as appropriate, and then I'll be able to use this to
demonstrate Refinements in my talk as a way to box-in the monkeypatch.
Then if Poodle ever becomes a library, it won't do "Dependency
Infection" of the SAR monkeypatch into Poodle's client.

Same goals as where I left off, then, plus a few other refactorings

- [X] Privatize all of Planner except for the three external methods;
  see if it works. It does! Unit tests even still pass. Worried about
  the `generate_into` method, though; not sure it really belongs on
  Planner. But at least all the constants, prawn methods, and utility
  crap has been tucked away where I can move it around without
  breaking any client code.

* [X] Refactor the `test_date_label_for_week` tests. Yes, really--MORE
  refactorings in the stupid tests. Because they read like crap right
  now.

* [X] Rename `Week#date_label_for_week` to `Week#date_label` and come
  up with a format language or give it a set of options, eg
  `:date_separator => ' - '`, `:show_year_change_on_left => false`,
  `:month_format => '%b'`, etc. (Did the rename, not the format lang.)

A note on the formatting language. One possible language might be to
express a single date format, but use () and [] to express things that
should appear on one side or the other if they are the same, but on
both sides if they change. So the format `(%b )%d[, %Y]` would be
interpreted as

* Check both sides against `%b`; if it doesn't change, it only goes on
  the left hand side.
* Check both sides against `, %Y`; if it doesn't change, it only goes
  on the right hand side.
* For the week of Monday, March 12th, 2012, then, the start date would
  be formatted with `%b %d` and the end date would be formatted with
  `%d, %Y`. This would yield `Mar 12` and `18, 2012` respectively,
  which would be glued together with the separator string.
* The week of Monday, December 26th, 2012, however, would end on a
  different month and year, so both sides would receive `%b %d, %Y` as
  their format strings.
* One bug with this: I'm thinking towards generalizing this towards
  arbitrary date ranges, and I could see problems with ranges that
  span exactly 1 year (so the month wouldn't change, giving a
  resulting label of `Mar 12, 2012-12, 2013`). There's also the odd
  special case of date ranges that begin and end on the same
  day. They'd show up as `Mar 12-12, 2012`. So I think I'm right in
  shelving this one for now. Hard to make a smart enough general
  template for formatting date spans, so for now it's okay to
  custom-code it.

More dev goals today:

* [X] `use_thick_pen` and friends should restore pen to previous
  state. Update: Yup, found several drawing methods that were
  depending on the pen state being left over from previous
  methods. Sadly, producing pixel-perfect, identical output still
  yields a PDF file with a different hash. Might be worth it someday
  to add an extra step to export the PDF as a very-high-resolution
  image (e.g. BMP or TIFF, but be sure to suppress any changeable
  metadata like timestamps) and then checksum the images. That way 2
  PDFs that yield the same printed output would still look the same to
  the acceptance test plan.

  At any rate, I can tick this off my bucket list: unit-testing code
  by holding two sheets of printed output over each other on a light
  table to visually inspect for differences.

Okay, I'm grinding over and over the code and I just can't see where
to start the next refactoring. There's just SO MUCH Prawn junk in
there. I think maybe the next refactoring should be to create a
`prawn_wrapper` that lets me talk to prawn the way I want to, and
would also let me get all the SRP-violating guts out of planner and
into some other file.

The `generate_pdf` method seems to have an SRP violation, too. It's a
weird 5-layer sandwich. Here's what happens there, in Planner's own
words:

1. I create a new pdf document.
2. I send a `generate_front_page` message to myself, which triggers a
   self-message cascade, like `draw_planner_skeleton` and
   `draw_labels`, both which ultimately send drawing commands to pdf.
3. I send a `start_new_page` message directly to pdf.
4. I send a `generate_back_page` message to myself, with the same
   effect of triggering a cascade of messages that ultimately send
   drawing commands to pdf.
5. I return the pdf document object. Now `generate_pdf` doesn't
   actually know this, but I, Planner, do: the only reason I have this
   message return the pdf object is so that in the calling code I can
   send the `render` message to pdf and then write the result into a
   buffer. That buffer is either an in-memory StringIO during testing,
   or a disk file in production.

So (I'm still in-character as Planner) I create an external PDF object
and return it, which guarantees a Law of Demeter violation in the
caller. This whole method is poorly composed, stateful,
order-dependent and procedural. Do I clean this up or should I start
over with a whole new strategy?

Ultimately (OC now) I have a problem if I want to go document-style
agnostic, and that is that the system outputs PDF files. There's not
really a dependency I can inject there, is there? I can see injecting
the the responsibility for writing to a buffer or to disk; that
actually might make the `generate_into` method go away but still leave
us with a testable program.

Blarg, screw it. I'm gonna call it a night. Maybe go read some more
POODR for inspiration. :-) Need to sleep on the core responsibilities
here: Prawn ("I can create and draw on a PDF document"), Planner ("I
orchestrate the generation of planner sheet"), some kind of
PlannerDrawer ("I know how to what a planner sheet looks
like"). Sounds like I need to lock down the interface between
PlannerDrawer and Prawn. Were this C# or Java I'd create something
like IDrawable or IDrawingSurface, create a Prawn wrapper to implement
it, then have PlannerDrawer use IDrawer exclusively to create the
planner sheet.

Hmph. I can visualize that process nicely, actually:

    | Planner | PlannerDrawer | IDrawing  | PrawnWrapper  | Prawn |
    | draw--->| draw_line x,y | draw_line | convert x,y;  |       |
    |         |               |           | stroke_line-->|       |


But (hence the "Hmph") at the end of all that, though, I'm not really
sure where a PDF comes back to the buffer without violating LoD or
Tell Don't Ask. Hmm... maybe it *doesn't*? Maybe we pass a buffer
object continuously eastward? Maybe Planner passes a buffer to
PlannerDrawer, or even gets a PdfBuffer injected from its caller?

Thoughts as I meditate on POODR:

* Consider the messages, not the objects. This may reveal the
  application. For example, Planner needs to stop going into Prawn's
  kitchen and telling it how to cook. It needs to simply order a
  PlannerSheet from the menu. AHHH! A wild PlannerSheet appears! NOW
  we're getting somewhere. So Planner simply tells PlannerSheet "I
  want a PDF planner sheet for the week of April 29, 2013." Maybe it
  even tells PlannerSheet where to render it; not sure. Or maybe it
  gets back the PlannerSheet all set to be rendered and then it calls
  `planner_sheet.render_on(buffer)` and we're done. Interesting!
* "Do not succumb to a class that has an ill-defined or absent public
  interface." (p79) Prawn requires me to use PDF metrics to speak to
  it; I may wish to change this. For example, to draw a vertical line
  on the page, I shouldn't need to know that this is at x coordinate
  360 in PDF twips. Care must be taken, however, that switching to a
  system that allows floating point geometry doesn't lose me my
  pixel-perfect drawings! Hmm, and by "care must be taken" I mean
  "tests must be assayed". I am already working with Prawn in
  fractions of PDF twips, perhaps a Float could hold everything I
  need.

Perhaps a sequence diagram like:

    Planner       PlannerSheet        Week    Drawing
       |                |              |         |
       |                |              |         |
       |               +-+             |         |
       |draw(date)---->| |             |         |
       |               | |new(date)--->|         |
       |               | |<- - - - - - |         |
       |               | |             |         |
       |               | |new------------------->|
       |               | |<- - - - - - - - - - - |
       |               | |             |         |

No. this is West-facing code. Instead of Drawing we need a
Template, and `PlannerSheet` calls `Template.new(self)` Oh, except
that now the Template needs to know to call back to the planner sheet
for the data items it needs to draw, so *it* really knows how to
draw... wait. Maybe that's NOT crazy. Maybe that's EXACTLY how it
works. Drawing calls back to PlannerSheet for it's title, which will
return the date range label "Mar 12-19, 2012" etc. Then it calls back
for the dates in the 7-day range... hmmmm!

---
# 2013-04-29

Okay, at the end of today the design is what it is. I'm tagging it as
the ruby 1.8 code (even though it doesn't actually run on 1.8
anymore--ssshhhh! It's not my fault, some of the gems are no longer
available from three years back) and starting the ruby 2 port so I can
write my talk.

Today:

- [X] Work out message flows. Try to discover objects and interfaces
  using the messages.

- [X] Wow. Lots of classes popped out, notably PlannerApplication and
  PlannerTemplate. The PlannerTemplate class is still doing WAY too
  much but at least it's extricated from Prawn and the Planner logic

- [X] Convert to Seattle.rb paren style

- [X] Tune planner sheet visually the way I like it

- [X] Sweep code and mark with TODOs for refactorings

- [X] DO said refactorings :-)

YAY! It is what it is, mates. It isn't what I love but compared to
what it was a month ago I think I almost *like* this code. Tomorrow
I'll begin writing my talk, explaining the app as it is in this state,
and then begin a catalog of Ruby 2 refactorings for the talk. Then
I'll do the refactorings, tagging as I go along, and we'll be able to
work through the code collectively during the talk.

Woo, excited!

---
# 2013-04-30

It's talk-write o'clock!

Oops, used require_relative where I should've used that horrific
`File.expand_path(File.join(File.dirname(__FILE__), ...))`
business. Ahem, "Fixing."
