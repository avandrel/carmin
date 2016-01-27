$stdout.sync = true
require 'newrelic_rpm'

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|f| require f}
Dir[File.dirname(__FILE__) + '/lib/creators/*.rb'].each {|f| require f}
Dir[File.dirname(__FILE__) + '/lib/helpers/*.rb'].each {|f| require f}
Dir[File.dirname(__FILE__) + '/lib/repositories/*.rb'].each {|f| require f}
Dir[File.dirname(__FILE__) + '/lib/web/*.rb'].each {|f| require f}

NewRelic::Agent.manual_start
run Carmin::Web.new