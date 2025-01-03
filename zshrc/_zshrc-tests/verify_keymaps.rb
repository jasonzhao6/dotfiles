class VerifyKeymaps
  # Run-command files
  HOME = `echo $HOME`.chomp
  ZSHRC_DIR = "#{HOME}/gh/dotfiles/zshrc"
  ZSHRC = "#{ZSHRC_DIR}/zshrc.zsh"
  ZSHRC_SECRETS = "#{HOME}/.zshrc.secrets"

  # Keymap namespaces
  GIT = 'Git'
  KUBECTL = 'Kubectl'
  TERRAFORM = 'Terraform'
  SINGLES = 'Singles'
  DOUBLES = 'Doubles'
  KEYMAP_NAMESPACES = [GIT, KUBECTL, TERRAFORM, SINGLES, DOUBLES]

  # Keymap partition labels
  SPACE = ' ' # means not used
  BRACKET = '[' # means defined in `ZSHRC`
  PAREN = '(' # means defined in `ZSHRC` for `args`
  BRACE = '{' # means defined in `ZSHRC_SECRETS`
  ANGLE = '<' # means already taken, e.g `go`
  KEYMAP_PARTITION_LABELS = [SPACE, BRACKET, PAREN, BRACE, ANGLE]

  # Keymap format
  # `#` is start of a comment
  # `[]` represents a partition label
  # `_` represents a keyboard key
  # `|` separates left-hand vs right-right keys
  KEYMAP_FORMAT = '# [_] [_] [_] [_] [_] | [_] [_] [_] [_] [_]'
  #                  ^^  ^^  ^^  ^^  ^^    ^^  ^^  ^^  ^^  ^^
  TO_EXTRACT = KEYMAP_FORMAT.chars
    .each.with_index.select { |char, _index| char == '[' }
    .map { |_char, index| [index, 2] }

  def initialize
    # Info needed to perform verification
    @zshrc_functions = []
    @zshrc_sub_files = []
    @zshrc_secrets_functions = []

    # Keymap partitions
    @non_secrets = nil # Should be in `ZSHRC` or a sub file
    @secrets = nil     # Should be in `ZSHRC_SECRETS`
    @not_used = nil    # Should be in neither

    # Verification result
    @failed = []
    @passes = 0
    @total = 0
  end

  def run
    current_namespace = nil

    # Gather info from `ZSHRC` to prepare to verification
    File.open(ZSHRC).each do |line|
      name = extract_function_name(line)
      @zshrc_functions << name if name

      file = extract_sourced_file(line)
      @zshrc_sub_files << file if file
    end

    # Gather info from `ZSHRC` sub files to prepare to verification
    @zshrc_sub_files.each do |file|
      File.open("#{ZSHRC_DIR}/#{file}").each do |line|
        name = extract_function_name(line)
        @zshrc_functions << name if name
      end
    end

    # Gather info from `ZSHRC_SECRETS` to prepare to verification
    File.open(ZSHRC_SECRETS).each do |line|
      name = extract_function_name(line)
      @zshrc_secrets_functions << name if name
    end

    # Do verification with info gathered
    File.open(ZSHRC).each do |line|
      current_namespace = extract_keymap_namespace(line) || current_namespace

      next unless current_namespace
      next unless has_keymaps?(line)

      partition_keymaps(current_namespace, line)

      verify_non_secrets
      verify_secrets
      verify_not_used
    end

    print_summary
  end

  private

  def extract_function_name(line)
    # Note: `(.+?) {` not greedy in case line contains multiple `{`
    has_function = /^function (?<name>.+?) {/ =~ line
    name if has_function
  end

  def extract_sourced_file(line)
    has_sourced_file = /^source "\$ZSHRC_DIR\/(?<file>.+)"/ =~ line
    file if has_sourced_file
  end

  def extract_keymap_namespace(line)
    has_namespace = /^### (?<namespace>\w+) keymap$/ =~ line
    if has_namespace
      return namespace if KEYMAP_NAMESPACES.include?(namespace)
      raise "Unexpected keymap namespace: #{namespace}"
    end
  end

  def has_keymaps?(line)
    KEYMAP_FORMAT.chars.each.with_index.all? do |char, index|
      case char
      when '#', ' ', '|' then char == line[index]
      when '[' then KEYMAP_PARTITION_LABELS.include?(line[index])
      when '_' then /[ 0-9a-z]/ =~ line[index]
      when ']' then true
      else raise 'Unhandled keymap format char'
      end
    end
  end

  def partition_keymaps(namespace, line)
    # Reset keymap partitions for each line
    @non_secrets = []
    @secrets = []
    @not_used = []

    # Extract non-empty keymaps
    keymaps = TO_EXTRACT.map { |index_length_pair| line[*index_length_pair] }
    keymaps.reject! { |keymap| SPACE == keymap[1] }

    # Partition keymaps
    keymaps.each do |keymap|
      case keymap[0]
      when PAREN, BRACKET then @non_secrets << keymap[1]
      when BRACE then @secrets << keymap[1]
      when SPACE, ANGLE then @not_used << keymap[1]
      else raise "Unexpected keymap partition label: #{keymap[0]}"
      end
    end

    # Prepend namespaces to keymaps
    [@non_secrets, @secrets, @not_used].each do |partition|
      partition.map! do |keymap|
        case namespace
          when GIT then "g#{keymap}"
          when KUBECTL then "k#{keymap}"
          when TERRAFORM then "tf#{keymap}"
          when SINGLES then keymap
          when DOUBLES then keymap * 2
          end
      end
    end
  end

  # Verify `@non_secrets` are present only in `ZSHRC`
  def verify_non_secrets
    @non_secrets.each do |keymap|
      failing = false

      if !@zshrc_functions.include?(keymap)
        failing = true
        @failed << "fail: \"'#{keymap}'\" is not in #{ZSHRC}"
      end

      if @zshrc_secrets_functions.include?(keymap)
        failing = true
        @failed << "fail: \"'#{keymap}'\" is in #{ZSHRC_SECRETS}"
      end

      update_verification_result(failing)
    end
  end

  # Verify `@secrets` are present only in `ZSHRC_SECRETS`
  def verify_secrets
    @secrets.each do |keymap|
      failing = false

      if @zshrc_functions.include?(keymap)
        failing = true
        @failed << "fail: \"'#{keymap}'\" is in #{ZSHRC}"
      end

      if !@zshrc_secrets_functions.include?(keymap)
        failing = true
        @failed << "fail: \"'#{keymap}'\" is not in #{ZSHRC_SECRETS}"
      end

      update_verification_result(failing)
    end
  end

  # Verify `@not_used` are not present in `ZSHRC, ZSHRC_SECRETS`
  def verify_not_used
    @not_used.each do |keymap|
      failing = false

      if @zshrc_functions.include?(keymap)
        failing = true
        @failed << "fail: \"'#{keymap}'\" is in #{ZSHRC}"
      end

      if @zshrc_secrets_functions.include?(keymap)
        failing = true
        @failed << "fail: \"'#{keymap}'\" is in #{ZSHRC_SECRETS}"
      end

      update_verification_result(failing)
    end
  end

  def update_verification_result(failing)
    if failing
      system('echo -n f')
    else
      system('echo -n .')
      @passes += 1
    end

    @total += 1
  end

  def print_summary
    system("echo \"\n(#{@passes}/#{@total} keymaps are up-to-date)\"")

    unless @failed.empty?
      system('echo')
      @failed.each { |failure| system("echo #{failure}") }
    end
  end
end

verify_keymaps = VerifyKeymaps.new
verify_keymaps.run
