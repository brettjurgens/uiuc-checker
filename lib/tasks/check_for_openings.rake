require_relative 'check'

namespace :course_check do
  desc "check for course changes"
  task :check_em do
    UIUCCheck.get_crns
    UIUCCheck.check_for_openings
  end
end