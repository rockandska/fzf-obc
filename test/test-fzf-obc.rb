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

TEST_DIR = "test/tmp"
TEST_HOME_DIR = "~/.local/tmp/fzf-obc"
TEST_REC_FILE = "/tmp/fzf-obc.cast"

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

Dir.chdir BASE
FileUtils.rm_rf File.expand_path("#{TEST_DIR}")
FileUtils.rm_rf File.expand_path("#{TEST_HOME_DIR}")
FileUtils.mkdir_p File.expand_path("#{TEST_DIR}")
FileUtils.mkdir_p File.expand_path("#{TEST_HOME_DIR}")
FileUtils.rm_rf File.expand_path("#{TEST_REC_FILE}")

puts "\nChecking for binaries required for those tests\n\n"

check_cmds(%w{
  fzf
  git
  docker
  insmod
  vi
  asciinema
})

class FzfObcTest < Minitest::Test

  @@prepare_tmux_done = false

  def temp_test_dir
    "#{TEST_DIR}/#{self.name}"
  end

  def temp_test_home_dir
    "#{TEST_HOME_DIR}/#{self.name}"
  end

  def setup
    Dir.chdir BASE
    prepare_tmux
    if TTYtest.debug
      puts "\nDebug: #{self.name}\n"
    end
    sleep TTYtest.send_keys_delay
    @@tty.clear_screen()
    @@tty.assert_row(0,'$')
  end

  def prepare_tmux
    return if @@prepare_tmux_done
    @@prepare_tmux_done = true
    @@tty = TTYtest.new_terminal(<<~HEREDOC,width: "#{TERMINAL_COLUMNS}", height: "#{TERMINAL_LINES}")
      env -i \
        LC_ALL="en_US.UTF-8" \
        LS_COLORS="#{ENV['LS_COLORS']}" \
        HOME="#{ENV['HOME']}" \
        TERM="#{ENV['TERM']}" \
        PS1='$ ' \
        PATH="#{ENV['PATH']}" \
        PROMPT_COMMAND='' \
        HISTFILE='' \
        FZF_OBC_HEIGHT='40%' \
        FZF_OBC_OPTS="--select-1 --exit-0 --no-sort --no-mouse --bind 'ctrl-c:cancel'" \
        FZF_OBC_GLOBS_OPTS="-m --select-1 --exit-0 --no-sort --no-mouse --bind 'ctrl-c:cancel'" \
        /bin/bash --norc --noprofile
    HEREDOC

    if TTYtest.debug
      puts(<<~EOF)
        ***************************
        Debug session started
        - Open a new terminal
        - Resize to the corresponding size:
        resize -s #{TERMINAL_LINES} #{TERMINAL_COLUMNS}
        - Join the debug session with:
        tmux -L ttytest attach
        Then, come back here and press 'Enter' to start
        To stop the debug session, press Ctrl+c
        ***************************
      EOF
      while ! gets
        sleep 0.1
      end
    end

    @@tty.max_wait_time = 3
    @@tty.send_keys("source /etc/bash_completion; source fzf-obc.bash","#{ENTER}", sleep: 0.01)
    @@tty.assert_matches(<<~EOF)
      $ source /etc/bash_completion; source fzf-obc.bash
      $
    EOF
    @@tty.max_wait_time = 2

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
