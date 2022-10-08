require_relative '../lib/assistant/version'

system('gem build assistant.gemspec')
system("gem install ./assistant-#{Assistant::VERSION}.gem")
