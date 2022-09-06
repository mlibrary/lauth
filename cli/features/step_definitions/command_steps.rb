When("I enter lauth -n {string} -p {string} {string}") do |user, password, args|
  @output = `bin/lauth -n #{user} -p #{password} #{args}`.chomp
end
