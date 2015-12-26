Dir[File.dirname(__FILE__) + '/lib/**/*.rb'].each {|f| require f}

run DiTrello::Web.new