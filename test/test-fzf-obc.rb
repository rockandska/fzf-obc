require 'minitest'
require 'minitest/autorun'
require 'ttytest'
require 'mkmf'
require 'git'
require_relative 'lib/ttytest_addons'

# Env variables available
# TESTS_DEBUG: set to true to access debug session
# TESTS_PAUSE: set to true to ask confirmation on each keypress
# TESTS_KEYS_DELAY: set delay between keypress
#
FILE = File.expand_path(__FILE__)
BASE = File.expand_path('../../', __FILE__)

TEST_DIR = "test/tmp/tty"
TEST_HOME_DIR = "~/.local/tmp/fzf-obc"
TEST_REC_DIR = "#{TEST_DIR}/casts"
TEST_BASHRC = "#{BASE}/#{TEST_DIR}/test_bashrc"

TERMINAL_COLUMNS=80
TERMINAL_LINES=24

DOWN='Down'
UP='Up'
LEFT='Left'
RIGHT='Right'
TAB='Tab'
ENTER='Enter'
ESCAPE='Escape'
CTRLC='C-c'
CTRLG='C-g'
CTRLU='C-u'
CTRLL='C-l'

TTYtest.debug = true if ENV['TESTS_DEBUG']
TTYtest.pause = true if ENV['TESTS_PAUSE']
TTYtest.send_keys_delay = ENV['TESTS_KEYS_DELAY'].to_f if ENV['TESTS_KEYS_DELAY']

unless TTYtest.debug
  Minitest::Test.parallelize_me!
end

Dir.chdir BASE
FileUtils.rm_rf File.expand_path("#{TEST_DIR}")
FileUtils.rm_rf File.expand_path("#{TEST_HOME_DIR}")
FileUtils.rm_rf File.expand_path("#{TEST_REC_DIR}")
FileUtils.mkdir_p File.expand_path("#{TEST_DIR}")
FileUtils.mkdir_p File.expand_path("#{TEST_HOME_DIR}")
FileUtils.mkdir_p File.expand_path("#{TEST_REC_DIR}")

check_cmds(%w{
  fzf
  git
  docker
  insmod
  vi
  asciinema
})

rcfile = File.open("#{TEST_BASHRC}", "w")
rcfile.puts <<~EOF
  LS_COLORS="#{ENV['LS_COLORS']}"
  PS1='$ '
  FZF_OBC_HEIGHT='40%'
  FZF_OBC_OPTS="--select-1 --exit-0 --no-sort --no-mouse --bind 'ctrl-c:cancel'"
  FZF_OBC_GLOBS_OPTS="-m --select-1 --exit-0 --no-sort --no-mouse --bind 'ctrl-c:cancel'"
  source /etc/bash_completion
  source #{BASE}/bin/fzf-obc.bash
EOF
rcfile.close

class FzfObcTest < Minitest::Test

  def temp_test_dir
    "#{TEST_DIR}/#{self.name}"
  end

  def temp_test_home_dir
    "#{TEST_HOME_DIR}/#{self.name}"
  end

  def setup
    method_file = File.basename(self.method("#{self.name}").source_location[0],'.rb')
    assert_equal \
      method_file, \
      self.name, \
      "Method '#{self.name}' need to be in its own file but is in #{method_file}"
    Dir.chdir BASE
    prepare_tmux
    if TTYtest.debug
      puts "\nDebug: #{self.name}\n"
    end
    @tty.assert_row(0,'$')
  end

  def teardown
    @tty.kill_session
  end

  def prepare_tmux
    @tty = TTYtest.new_terminal(<<~HEREDOC,width: "#{TERMINAL_COLUMNS}", height: "#{TERMINAL_LINES}")
      env -i \
        LC_ALL="en_US.UTF-8" \
        PATH="#{ENV['PATH']}" \
        HOME="#{ENV['HOME']}" \
        TERM="#{ENV['TERM']}" \
        PROMPT_COMMAND='' \
        HISTFILE='' \
        PS1='' \
        GIT_WORK_TREE=#{temp_test_dir} \
        GIT_DIR=#{temp_test_dir}/.git \
        #{BASE}/test/bin/asciinema rec --quiet -t 'fzf-obc #{self.name}' -i '#{TTYtest.send_keys_delay}' -c 'bash --rcfile #{TEST_BASHRC} --noprofile' #{TEST_REC_DIR}/#{self.name}.cast
    HEREDOC

    if TTYtest.debug
      puts(<<~EOF)
        ***************************
        Debug session started for #{self.name}
        - Open a new terminal
        - Join the debug session with:
        tmux -L ttytest attach -t #{@tty.session_name} \\; setw force-width #{TERMINAL_COLUMNS} \\; setw force-height #{TERMINAL_LINES}
        Then, come back here and press 'Enter' to start
        To stop the debug session, press Ctrl+c
        ***************************
      EOF
      while ! gets
        sleep 0.1
      end
    end

  end

  def create_files_dirs(
    dest: "#{temp_test_dir}",
    subdirs: %w{},
    files: %w{}
  )
    dest = File.expand_path(dest)
    FileUtils.rm_rf "#{dest}"
    FileUtils.mkdir_p "#{dest}"
    for file in files
      FileUtils.touch "#{dest}/#{file}"
    end
    for dir in subdirs
      FileUtils.mkdir_p "#{dest}/#{dir}"
      for file in files
        FileUtils.touch "#{dest}/#{dir}/#{file}"
      end
    end
  end

end

Dir.chdir BASE
files = Dir.glob("test/spec/**/*.rb")
files.each{|file| require_relative file.gsub(/^test\/|\.rb$/,'')}
