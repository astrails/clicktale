require 'fileutils'

system '/usr/bin/env', 'ruby', File.join(File.dirname(__FILE__), "bin/clicktaleize"), RAILS_ROOT
