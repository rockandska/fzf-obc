module TTYtest
  class << self
    attr_accessor :debug
    attr_accessor :pause
    attr_accessor :send_keys_delay
  end
  self.debug = false
  self.pause = false
  self.send_keys_delay = 0.1

  module Matchers
    def assert_rows_include(expected)
      expected = expected.rstrip
      if !to_s.match(/^#{Regexp.quote(expected)}$/)
        raise MatchError, <<~HEREDOC
          #{MatchError}
          Was expecting to find:
          #{expected}
          In :
          #{to_s}
        HEREDOC
      end
    end

    def assert_rows_count(operator,int)
      nb_rows = rows.count { |s| s != "" }
      if !nb_rows.send(operator,int)
        raise MatchError, <<~HEREDOC
          #{MatchError}
          Was expecting to see #{operator} #{int} none empty rows
          But only #{nb_rows} none empty rows were found
        HEREDOC
      end
    end

    def assert_last_row(expected)
      expected = expected.rstrip
      rows_clean = rows.reject { |c| c.empty? }
      if rows_clean[-1] != expected
        raise MatchError, <<~HEREDOC
          #{MatchError}
          Expecting to see on last non empty row:
          '#{expected}'
          But the last row is:
          '#{rows_clean[-1]}'
        HEREDOC
      end
    end
    METHODS_TO_ADD = public_instance_methods
  end

  class Terminal
    def_delegators :@driver_terminal, :clear_screen, :session_name, :kill_session
    TTYtest::Matchers::METHODS_TO_ADD.each do |matcher_name|
      define_method matcher_name do |*args|
        synchronize do
          capture.public_send(matcher_name, *args)
        end
      end
    end
  end

  module Tmux
    class Session

      def session_name
        "#{name}"
      end

      def kill_session
        driver.tmux(*%W[kill-session -t #{name}])
      end

      def send_keys(*keys, delay: TTYtest.send_keys_delay, sleep: TTYtest.send_keys_delay)
        sleep delay
        keys.each_with_index do |key, keys_index|
          cmds = key.split("\n")
          cmds.each_with_index do |item, item_index|
            if TTYtest.pause
              printf "Press enter to send: " + item.dump
              while ! gets
                sleep 0.05
              end
            end
            sleep sleep if item_index > 0 or keys_index > 0
            driver.tmux(*%W[send-keys -t #{name} -- #{item}])
          end
        end
      end

      def clear_screen(delay: TTYtest.send_keys_delay, sleep: 0.01)
        sleep delay
        if TTYtest.pause
          printf 'Press enter will clear the screen'
          while ! gets
            sleep 0.05
          end
        end
        driver.tmux(*%W[send-keys -Rt #{name}], "#{CTRLG}")
        driver.tmux(*%W[send-keys -Rt #{name}], "#{CTRLU}")
        driver.tmux(*%W[send-keys -Rt #{name}], "#{CTRLL}")
      end
    end
  end

end

module MakeMakefile::Logging
  @logfile = File::NULL
  @quiet = true
end

def check_cmds(cmds)
  if cmds.is_a? String
    cmds = cmds.split(',')
  end
  for bin in cmds do
    if ! find_executable("#{bin}",path="#{BASE}/test/bin:#{ENV['PATH']}")
      raise "=====> Missing executable '#{bin}' needed for tests <=====\n#{to_s}"
      exit 1
    end
  end
  puts "\nRequired binaries : OK\n\n"
end

