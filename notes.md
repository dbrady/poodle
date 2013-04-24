# Notes

## 2013-04-22

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
