module Pod

  class ConfigureSwift
    attr_reader :configurator

    def self.perform(options)
      new(options).perform
    end

    def initialize(options)
      @configurator = options.fetch(:configurator)
    end

    def perform
      keep_demo = configurator.ask_with_answers("Would you like to include a demo application with your library", ["Yes", "No"]).to_sym

      framework = configurator.ask_with_answers("Which testing frameworks will you use", ["Quick", "None"]).to_sym
      case framework
        when :quick
          configurator.add_pod_to_podfile "Quick', '~> 1.2.0"
          configurator.add_pod_to_podfile "Nimble', '~> 7.0"
          configurator.set_test_framework "quick", "swift", "swift"

        when :none
          configurator.set_test_framework "xctest", "swift", "swift"
      end

      snapshots = configurator.ask_with_answers("Would you like to do view based testing", ["Yes", "No"]).to_sym
      case snapshots
        when :yes
          configurator.add_pod_to_podfile "FBSnapshotTestCase' , '~> 2.1.4"

          if keep_demo == :no
              puts " Putting demo application back in, you cannot do view tests without a host application."
              keep_demo = :yes
          end

          if framework == :quick
              configurator.add_pod_to_podfile "Nimble-Snapshots' , '~> 6.3.0"
          end
      end

      Pod::ProjectManipulator.new({
        :configurator => @configurator,
        :xcodeproj_path => "templates/swift/PROJECT.xcodeproj",
        :platform => :ios,
        :remove_demo_project => (keep_demo == :no),
        :prefix => ""
      }).run

      `mv ./templates/swift/* ./`
    end
  end

end
