require 'bundler'
Dir[File.dirname(__FILE__) + '/lib/**/*.rb'].each {|file| require file }

#Load Config
config = YAML::load_file(File.join(__dir__, 'config.yml'))

IRESCrawler.new(config).run



