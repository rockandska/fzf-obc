FILE = File.expand_path(__FILE__)
BASE = File.expand_path('../../', __FILE__)
TEST_DIR = "test/structure"
HOME_TEST_DIR = ".local/tmp/fzf-obc/test/structure"
Dir.chdir BASE

DOWN='Down'
UP='Up'
LEFT='Left'
RIGHT='Right'
TAB='Tab'
ENTER='Enter'
ESCAPE='Escape'
CTRLC='C-c'

require 'minitest'
require 'minitest/autorun'
require 'ttytest'
require_relative 'lib/ttytest_addons'
require 'mkmf'

puts "\nChecking for binaries required for those tests\n\n"

check_cmds(%w{
  fzf
  git
  insmod
})


class FzfObcTest < Minitest::Test

  @@prepare_tmux_done = false

  def setup
    prepare_tmux
    cleanup
    @@tty.clear_screen()
  end

  def prepare_tmux
    return if @@prepare_tmux_done
    @@prepare_tmux_done = true

    puts 'Preparing the environment for testing.......'

    @@tty = TTYtest.new_terminal(<<~HEREDOC,width: 230)
      env -i \
        PS1='$ ' \
        PATH="#{ENV['PATH']}" \
        PROMPT_COMMAND='' \
        TESTS_DEBUG="#{ENV['TESTS_DEBUG']}" \
        TESTS_PAUSE="#{ENV['TESTS_PAUSE']}" \
        TESTS_KEYS_DELAY="#{ENV['TESTS_KEYS_DELAY']}" \
        HISTFILE='' \
        FZF_OBC_HEIGHT='90%' \
        FZF_OBC_OPTS="--select-1 --exit-0 --no-sort --no-mouse --bind 'ctrl-c:cancel'" \
        FZF_OBC_GLOBS_OPTS="-m --select-1 --exit-0 --no-sort --no-mouse --bind 'ctrl-c:cancel'" \
        /bin/bash --norc --noprofile
    HEREDOC
    sleep(1)

    if ENV['TESTS_DEBUG']
      TTYtest.debug = true
    elsif ENV['TESTS_PAUSE']
      TTYtest.debug = true
      TTYtest.pause = true
    end

    if ENV['TESTS_KEYS_DELAY']
      TTYtest.send_keys_delay = ENV['TESTS_KEYS_DELAY'].to_f
    end

    if TTYtest.debug
      puts(<<~EOF)
        ***************************
        Debug session start
        Please, open a new terminal and join the debug session with:
        tmux -L ttytest attach
        Then, come back here and press 'Enter' to start
        To stop the debug session, press Ctrl+c
        ***************************
      EOF
      while ! gets
        sleep 0.1
      end
    end

    @@tty.send_keys(<<~EOF)
      source /etc/bash_completion; echo $?
      #{ENTER}
    EOF
    @@tty.assert_matches(<<~EOF)
      $ source /etc/bash_completion; echo $?
      0
      $
    EOF
    @@tty.clear_screen()

    @@tty.max_wait_time = 3
    @@tty.send_keys(<<~EOF)
      source fzf-obc.bash; echo $?
      #{ENTER}
    EOF
    @@tty.assert_matches(<<~EOF)
      $ source fzf-obc.bash; echo $?
      0
      $
    EOF
    @@tty.clear_screen()

    @@tty.max_wait_time = 2
    @@tty.send_keys(<<~EOF)
      complete | grep __fzf
      #{ENTER}
    EOF
    @@tty.assert_rows_count(:>,2)
    @@tty.assert_row(-1, '$')

    puts 'Preparation finished !'
    puts 'Starting tests..........'
  end

  def files_creation
    (1..10).each do |idx|
      FileUtils.mkdir_p "#{TEST_DIR}/d#{idx}"
    end
    FileUtils.mkdir_p "#{TEST_DIR}/d1 0"
    FileUtils.touch "#{TEST_DIR}/xxx"
    FileUtils.touch "#{TEST_DIR}/xxx xxx"
    FileUtils.touch "#{TEST_DIR}/d10/xxx"
    FileUtils.touch "#{TEST_DIR}/yyy"
    FileUtils.touch "#{TEST_DIR}/d10/yyy yyy"
  end

  def files_glob_creation
    files_creation
  end

  def create_files_dirs(
    dest: TEST_DIR,
    subdirs: %w{
      d1
      d10
      d1\ 0
      d2
      d\ 20
    },
    files: %w{
      file1.test
      file\ 1.test
      file2.test
      file\ 2.test
    }
  )
    dest = File.expand_path(dest)
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

  def files_home_completion
    FileUtils.mkdir_p "#{ENV['HOME']}/#{HOME_TEST_DIR}"
    FileUtils.touch "#{ENV['HOME']}/#{HOME_TEST_DIR}/fzf-obc.test"
    FileUtils.touch "#{ENV['HOME']}/#{HOME_TEST_DIR}/test-fzf-obc.test"
    FileUtils.touch "#{ENV['HOME']}/#{HOME_TEST_DIR}/test fzf-obc.test"
  end

  def files_home_glob_completion
    files_home_completion
  end

  def test_files_completion
    puts "\nDebug: inside " + __method__.to_s + "\n" if TTYtest.debug
    files_creation
    @@tty.send_keys(<<~EOF)
      cat #{TEST_DIR}/
      #{TAB}
    EOF
    @@tty.assert_matches <<~TTY
      $ cat #{TEST_DIR}/
      >
        14/14
      > #{TEST_DIR}/yyy
        #{TEST_DIR}/xxx xxx
        #{TEST_DIR}/xxx
        #{TEST_DIR}/d9/
        #{TEST_DIR}/d8/
        #{TEST_DIR}/d7/
        #{TEST_DIR}/d6/
        #{TEST_DIR}/d5/
        #{TEST_DIR}/d4/
        #{TEST_DIR}/d3/
        #{TEST_DIR}/d2/
        #{TEST_DIR}/d10/
        #{TEST_DIR}/d1/
        #{TEST_DIR}/d1 0/
    TTY
    @@tty.send_keys(<<~EOF)
      x
      #{TAB}
    EOF
    @@tty.assert_matches <<~TTY
      $ cat #{TEST_DIR}/xxx\\ xxx
    TTY
  end

  def test_files_glob_completion
    puts "\nDebug: inside " + __method__.to_s + "\n" if TTYtest.debug
    files_glob_creation
    @@tty.send_keys(<<~EOF)
      cat #{TEST_DIR}/**
      #{TAB}
    EOF
    @@tty.assert_matches <<~TTY
      $ cat #{TEST_DIR}/**
      >
        16/16
      > #{TEST_DIR}/yyy
        #{TEST_DIR}/xxx xxx
        #{TEST_DIR}/xxx
        #{TEST_DIR}/d9/
        #{TEST_DIR}/d8/
        #{TEST_DIR}/d7/
        #{TEST_DIR}/d6/
        #{TEST_DIR}/d5/
        #{TEST_DIR}/d4/
        #{TEST_DIR}/d3/
        #{TEST_DIR}/d2/
        #{TEST_DIR}/d10/yyy yyy
        #{TEST_DIR}/d10/xxx
        #{TEST_DIR}/d10/
        #{TEST_DIR}/d1/
        #{TEST_DIR}/d1 0/
    TTY
    @@tty.send_keys(<<~EOF)
      x
      #{TAB}
      #{DOWN}
      #{DOWN}
      #{TAB}
      #{ENTER}
    EOF
    @@tty.assert_matches <<~TTY
      $ cat #{TEST_DIR}/xxx\\ xxx #{TEST_DIR}/d10/xxx
    TTY
  end

  def test_files_home_completion
    puts "\nDebug: inside " + __method__.to_s + "\n" if TTYtest.debug
    files_home_completion
    @@tty.send_keys(<<~EOF)
      cat ~/#{HOME_TEST_DIR}/
      #{TAB}
      'fzf-obc.test
    EOF
    @@tty.assert_matches <<~TTY
      $ cat ~/#{HOME_TEST_DIR}/
      > 'fzf-obc.test
        3/3
      > ~/#{HOME_TEST_DIR}/test-fzf-obc.test
        ~/#{HOME_TEST_DIR}/test fzf-obc.test
        ~/#{HOME_TEST_DIR}/fzf-obc.test
    TTY
    @@tty.send_keys(<<~EOF)
      #{CTRLC}
      'test-fzf-obc.test
    EOF
    @@tty.assert_matches <<~TTY
      $ cat ~/#{HOME_TEST_DIR}/
      > 'test-fzf-obc.test
        1/3
      > ~/#{HOME_TEST_DIR}/test-fzf-obc.test
    TTY
    @@tty.send_keys(<<~EOF)
      #{CTRLC}
      #{DOWN}
      #{TAB}
    EOF
    @@tty.assert_matches <<~TTY
      $ cat ~/#{HOME_TEST_DIR}/test\\ fzf-obc.test
    TTY
  end

  def test_files_home_glob_completion
    puts "\nDebug: inside " + __method__.to_s + "\n" if TTYtest.debug
    files_home_glob_completion
    @@tty.send_keys(<<~EOF)
      cat ~/#{HOME_TEST_DIR}/**
      #{TAB}
      'fzf-obc.test
    EOF
    @@tty.assert_matches <<~TTY
      $ cat ~/#{HOME_TEST_DIR}/**
      > 'fzf-obc.test
        3/3
      > ~/#{HOME_TEST_DIR}/test-fzf-obc.test
        ~/#{HOME_TEST_DIR}/test fzf-obc.test
        ~/#{HOME_TEST_DIR}/fzf-obc.test
    TTY
    @@tty.send_keys(<<~EOF)
      #{CTRLC}
      'test-fzf-obc.test
    EOF
    @@tty.assert_matches <<~TTY
      $ cat ~/#{HOME_TEST_DIR}/**
      > 'test-fzf-obc.test
        1/3
      > ~/#{HOME_TEST_DIR}/test-fzf-obc.test
    TTY
    @@tty.send_keys(<<~EOF)
      #{CTRLC}
      'fzf-obc.test
      #{DOWN}
      #{TAB}
      #{TAB}
      #{ENTER}
    EOF
    @@tty.assert_matches <<~TTY
      $ cat ~/#{HOME_TEST_DIR}/test\\ fzf-obc.test ~/#{HOME_TEST_DIR}/fzf-obc.test
    TTY
  end

  def test__filedir_with_insmod
    # insmod use _filedir with extension filter
    puts "\nDebug: inside " + __method__.to_s + "\n" if TTYtest.debug
    create_files_dirs(
      subdirs: %w{d1},
      files: %w{
        test.ko.gz
        test\ 1.ko.gz
        test.log
        test.mp3
      }
    )
    @@tty.send_keys(<<~EOF)
      insmod #{TEST_DIR}/
      #{TAB}
    EOF
    @@tty.assert_matches(<<~EOF)
      $ insmod #{TEST_DIR}/
      >
        3/3
      > #{TEST_DIR}/test.ko.gz
        #{TEST_DIR}/test 1.ko.gz
        #{TEST_DIR}/d1/
    EOF
  end

  def test__filedir_with_insmod_in_home
    # insmod use _filedir with extension filter
    puts "\nDebug: inside " + __method__.to_s + "\n" if TTYtest.debug
    create_files_dirs(
      dest: "~/#{HOME_TEST_DIR}",
      subdirs: %w{d1},
      files: %w{
        test.ko.gz
        test\ 1.ko.gz
        test.log
        test.mp3
      }
    )
    @@tty.send_keys(<<~EOF)
      insmod ~/#{HOME_TEST_DIR}/
      #{TAB}
    EOF
    @@tty.assert_matches(<<~EOF)
      $ insmod ~/#{HOME_TEST_DIR}/
      >
        3/3
      > ~/#{HOME_TEST_DIR}/test.ko.gz
        ~/#{HOME_TEST_DIR}/test 1.ko.gz
        ~/#{HOME_TEST_DIR}/d1/
    EOF
  end

end

def cleanup
  Dir.chdir BASE
  FileUtils.rm_rf "#{TEST_DIR}"
  FileUtils.rm_rf "#{ENV['HOME']}/#{HOME_TEST_DIR}"
end

MiniTest.after_run do
  if !TTYtest.debug
    # Don't cleanup in debug mode to keep the last test structure
    cleanup
  end
end
