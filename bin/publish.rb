require_relative '../lib/assistant/version'

system('gem build assistant.gemspec')
system("curl -F package=@assistant-#{Assistant::VERSION}.gem https://#{ENV["GEMFURY_TOKEN"]}@push.fury.io/#{ENV["GEMFURY_REPOSITORY"]}/")
