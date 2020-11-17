require 'minitest'
require 'ttytest'
require 'git'
require 'docker-api'
require 'etc'
require_relative 'lib/ttytest_addons'

TMP_DIR = Dir.mktmpdir("fzf-obc_")
$container = nil

at_exit {
  if $container
    $stderr.puts "Removing '" + CONTAINER_NAME + "' container...."
    $container.delete(:force => true)
  end
  $stderr.puts "Removing '" + TMP_DIR + "' directory..."
  FileUtils.remove_entry TMP_DIR
}

require 'minitest/autorun'

# Env variables available
# TESTS_DEBUG: set to true to access debug session
# TESTS_PAUSE: set to true to ask confirmation on each keypress
# TESTS_KEYS_DELAY: set delay between keypress
# TESTS_DOCKER_IMAGE: launch tests inside a container with a specific image
#                     instead of running them locally

CURRENT_FILE = File.expand_path(__FILE__)
SRC_DIR = File.expand_path('../../', __FILE__)

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

# start container if needed
if ENV['DOCKER_IMAGE']
  debug("Docker tests asked with " + ENV['DOCKER_IMAGE'] + " image")
  CONTAINER_NAME = File.basename(TMP_DIR)
  $container = Docker::Container.create(
    'name' => CONTAINER_NAME,
    'Image' => ENV['DOCKER_IMAGE'],
    'User' => "#{Etc.getpwuid.uid}:#{Etc.getpwuid.gid}",
    'Cmd' => ['tail','-f','/dev/null'],
    'Volumes' => {
      TMP_DIR => { TMP_DIR => 'rw' },
      SRC_DIR => { SRC_DIR => 'ro' }
    },
    'Binds' => [
      "#{TMP_DIR}:#{TMP_DIR}",
      "#{SRC_DIR}:#{SRC_DIR}"
    ]
  )
  $container.start()
end

class FzfObcTest < Minitest::Test

  def create_rcfile
    debug("Creating '#{@rcfile_name}'...")
    rcfile = File.open("#{@rcfile_name}", "w")
    rcfile.puts <<~EOF
      export LS_COLORS="#{ENV['LS_COLORS']}"
      export PS1='$ '
      export PATH="#{ENV['PATH']}"
      export TERM="#{ENV['TERM']}"
      export HISTFILE=''
      export PROMPT_COMMAND=''
      export FZF_OBC_HEIGHT='40%'
      export FZF_OBC_OPTS="--select-1 --exit-0 --no-sort --no-mouse --bind 'ctrl-c:cancel'"
      export FZF_OBC_GLOBS_OPTS="-m --select-1 --exit-0 --no-sort --no-mouse --bind 'ctrl-c:cancel'"
      export HOME="#{TMP_DIR}"
      export GIT_COMMITTER_NAME=test
      export GIT_AUTHOR_NAME=test
      export EMAIL=test@test.com
      source /etc/bash_completion
      source #{SRC_DIR}/bin/fzf-obc.bash
      cd #{temp_test_dir}
    EOF
    rcfile.close
  end

  def temp_test_dir
    "#{TMP_DIR}/#{self.name}"
  end

  def temp_test_home_dir
    "#{TMP_DIR}/#{self.name}"
  end

  def setup
    @test_dir = "#{TMP_DIR}/#{self.name}"
    @rcfile_name = "#{TMP_DIR}/#{self.name}.bashrc"
    @castfile_name = "#{TMP_DIR}/#{self.name}.cast"
    debug("Creating '#{@test_dir}'...")
    FileUtils.mkdir_p @test_dir
    create_rcfile
    method_file = File.basename(self.method("#{self.name}").source_location[0],'.rb')
    assert_equal \
      method_file, \
      self.name, \
      "Method '#{self.name}' need to be in its own file but is in #{method_file}"
    prepare_tmux
    @tty.assert_row(0,'$')
  end

  def teardown
    @tty.kill_session
  end

  def prepare_tmux
    if $container
      rec_cmd = "docker exec -ti #{CONTAINER_NAME} /bin/bash --rcfile #{@rcfile_name} --noprofile"
    else
      rec_cmd = "env -i HOME=#{ENV['HOME']} bash --rcfile #{@rcfile_name} --noprofile"
    end
    @tty = TTYtest.new_terminal(<<~HEREDOC,width: "#{TERMINAL_COLUMNS}", height: "#{TERMINAL_LINES}")
      #{SRC_DIR}/test/bin/asciinema rec --quiet -t 'fzf-obc #{self.name}' -i '#{TTYtest.send_keys_delay}' -c '#{rec_cmd}' #{@castfile_name}
    HEREDOC
    debug("tmux session started with '#{rec_cmd}' command...")

    if TTYtest.debug
      $stderr.puts(<<~EOF)

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
    dest: "#{TMP_DIR}/#{self.name}",
    subdirs: %w{},
    files: %w{}
  )
    dest = File.expand_path(dest)
    FileUtils.mkdir_p "#{dest}"
    FileUtils.rm_rf Dir.glob("#{dest}/*")
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

Dir.chdir SRC_DIR
files = Dir.glob("test/spec/**/*.rb")
files.each{|file| require_relative file.gsub(/^test\/|\.rb$/,'')}
