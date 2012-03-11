module Prawn
  class Document
    # fix POLS violation in Prawn; ideally should also rewrite transparent(t) to call transparent_orig(1.0-t)
    alias :opacity :transparent
  end
end

