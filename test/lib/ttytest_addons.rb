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

    def assert_matches_inline(expected)
      expected_line = expected.gsub(/\s*\n/,'')
      matched = true
      actual_line = rows.join("")
      if actual_line != expected_line
        matched = false
      end

      if !matched
        raise MatchError, "screen did not match expected content:\n--- expected :\n#{expected_line}\n+++ actual :\n#{actual_line}\n"
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

def which(cmd)
  if $container
    exe = $container.exec(['bash', '-c', "command -v #{cmd} 2> /dev/null"])
    return exe[0] if exe[2] == 0
  else
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each do |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        return exe if File.executable?(exe) && !File.directory?(exe)
      end
    end
  end
  nil
end

def debug(msg)
  if TTYtest.debug
    $stderr.puts "== DEBUG : " + msg
  end
end
