require "ruby-debug"
require_relative '../lib/poodle'

MAGIC_MD5_CHECKSUM="4b8ec4584fce157d810896ddd4a0f701"

def md5(string)
  digest = Digest::MD5.new
  string.each_line do |line|
    digest << line
  end
  digest.hexdigest
end

