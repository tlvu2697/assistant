require_relative '../lib/assistant/version'

system('gem uninstall -ax assistant')
system('gem build assistant.gemspec')
system("gem install ./assistant-#{Assistant::VERSION}.gem")
system("rm ./assistant-#{Assistant::VERSION}.gem")
