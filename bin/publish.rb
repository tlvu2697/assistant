require_relative '../lib/assistant/version'

system('gem install gemfury')
system('gem build assistant.gemspec')

system("fury yank assistant -v #{Assistant::VERSION} --api-token=#{ENV["GEMFURY_FULL_ACCESS_TOKEN"]}")
system("fury push assistant-#{Assistant::VERSION}.gem --api-token=#{ENV["GEMFURY_FULL_ACCESS_TOKEN"]}")
