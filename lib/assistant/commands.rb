# frozen_string_literal: true

require_relative 'commands/apps/base'
require_relative 'commands/apps/bat'
require_relative 'commands/apps/grpcurl'
require_relative 'commands/apps/lazydocker'
require_relative 'commands/apps/lazygit'
require_relative 'commands/apps/omada'
require_relative 'commands/apps/overmind'
require_relative 'commands/apps/postman'

require_relative 'commands/circleci/base'
require_relative 'commands/circleci/approve'
require_relative 'commands/circleci/rerun'

require_relative 'commands/omada/base'
require_relative 'commands/omada/availability_notify'
require_relative 'commands/omada/certification_convert'

require_relative 'commands/eh/tick_checklist'

require_relative 'commands/linux/base'
require_relative 'commands/linux/clean'
require_relative 'commands/linux/stress'
require_relative 'commands/linux/tweak'
require_relative 'commands/linux/update'
require_relative 'commands/linux/setup/dev'
require_relative 'commands/linux/setup/dependencies'
