source "http://rubygems.org"

gem "rake", "~>10.0"
gem "prawn", "~>0.12"
gem "trollop", "~>2.0"
gem "scoped_attr_accessor", "~>1.1", path: "../scoped_attr_accessor/"

group :development do
  gem "debugger", "~>1.5"
  gem "flay", "~>2.2"
  gem "guard", "~>1.0"
  gem "guard-minitest", "~>0.5"
  gem "growl", "~>1.0"

  # ----------------------------------------------------------------------
  # Guard File System listeners
  #
  # Kudos to the guard devs for knowing to only activate the FS
  # listener that works for each given OS (Here linux, OSX, and
  # Windows respectively)
  gem 'rb-inotify', '~>0.9', :require => false
  gem 'rb-fsevent', '~>0.9', :require => false
  gem 'rb-fchange', '~>0.0', :require => false

  # TODO: Post 1.9.3 this is more efficient on Windows than rb-fchange
  # gem 'wdm', '~>0.1', :require => false
  # ----------------------------------------------------------------------
end
