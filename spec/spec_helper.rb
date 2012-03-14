require "ruby-debug"
require_relative '../lib/poodle'

MAGIC_MD5_CHECKSUM="77a10eeca7f747b91f0d2133fe11e30f"

def md5(string)
  digest = Digest::MD5.new
  string.each_line do |line|
    digest << line
  end
  digest.hexdigest
end

