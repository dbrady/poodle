require 'digest/md5'
require 'stringio'

# FOR NOW: If you change the drawing template, visually inspect the
# planner sheet and then update this checksum.
#
# TODO: Isolate the Template dependency, then create a testing-only
# template that represents a decent cut at the planner, the inject
# it here. Now we can change the planner without breaking the
# test. (May still want to update the test template and checksum,
# however.)
MAGIC_MD5_CHECKSUM="4b8ec4584fce157d810896ddd4a0f701"

module StringMd5
  def md5
    Digest::MD5.hexdigest self
  end
end

class String
  include StringMd5
end

StringIO.__send__(:define_method, :md5) do
  string.md5
end
