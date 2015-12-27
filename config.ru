$stdout.sync = true

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|f| require f}
Dir[File.dirname(__FILE__) + '/lib/helpers/*.rb'].each {|f| require f}
Dir[File.dirname(__FILE__) + '/lib/web/*.rb'].each {|f| require f}

run DiTrello::Web.new