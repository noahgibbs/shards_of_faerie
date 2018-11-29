require "rails/test_unit/runner"

namespace :test do
  task :channels => "test:prepare" do
    $: << "test"
    test_files = FileList['test/channels/*_test.rb']
    Rails::TestUnit::Runner.run(test_files)
  end

  task :connections => "test:prepare" do
    $: << "test"
    test_files = FileList['test/connections/*_test.rb']
    Rails::TestUnit::Runner.run(test_files)
  end

  task :subgames => "test:prepare" do
    $: << "test"
    test_files = FileList['test/subgames/*_test.rb']
    Rails::TestUnit::Runner.run(test_files)
  end

  #task :without_long_running_tests => "test:prepare" do
  #  $: << "test"
  #  test_files = FileList['test/**/*_test.rb'].exclude('test/long_running/**/*_test.rb')
  #  Rails::TestUnit::Runner.run(test_files)
  #end
end
