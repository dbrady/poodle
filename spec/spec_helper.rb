require "ruby-debug"
require_relative '../lib/poodle'

MAGIC_MD5_CHECKSUM="e59168e1dca8c81f9b92ac5b5179263a"

def md5(string)
  digest = Digest::MD5.new
  string.each_line do |line|
    digest << line
  end
  digest.hexdigest
end

