class VerifyTestInvocations
  TESTS_FILES = `find ~/gh/dotfiles/zshrc/zshrc-tests -name '*.zsh'`.split

  def initialize
    # Verification result
    @failed = []
    @passes = 0
    @total = 0
  end

  def run
    current_test = nil

    TESTS_FILES.each do |test_file|
      File.open(test_file).each do |line|
        is_test_definition = /^function (?<test>test--.+) {$/ =~ line
        if is_test_definition
          @failed << "Test was not called: #{current_test}" if current_test
          current_test = test
        end

        is_test_skipped = /^	# Skip: / =~line
        current_test = nil if is_test_skipped

        is_test_invocation = /^}; run-with-filter (?<test>test--.+)$/ =~ line
        if is_test_invocation
          if test == current_test
            current_test = nil

            system('echo -n .')
            @passes += 1
          else
            system('echo -n f')
            @failed << "#{test} was invoked after #{current_test} was just defined"
          end

          @total += 1
        end
      end
    end

    print_summary
  end

  private

  def print_summary
    system("echo \"\n(#{@passes}/#{@total} tests defined were invoked)\"")

    unless @failed.empty?
      system('echo')
      @failed.each { |failure| system("echo #{failure}") }
    end
  end
end

verify_test_invocations = VerifyTestInvocations.new
verify_test_invocations.run
