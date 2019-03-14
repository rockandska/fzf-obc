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
        raise <<~HEREDOC
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
        raise <<~HEREDOC
          #{MatchError}
          Was expecting to see #{operator} #{int} none empty rows
          But only #{nb_rows} none empty rows were found
        HEREDOC
      end
    end
    METHODS_TO_ADD = ['assert_rows_include','assert_rows_count']
  end

  class Terminal
    def_delegators :@driver_terminal, :clear_screen
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
      def send_keys(*keys)
        keys.each do |key|
          cmds = key.split("\n")
          cmds.each do |item|
            if TTYtest.debug and TTYtest.pause
              printf "Press enter to send: " + item.dump
              while ! gets
                sleep 0.05
              end
            end
            driver.tmux(*%W[send-keys -t #{name}], *item)
            sleep TTYtest.send_keys_delay
          end
        end
      end

      def clear_screen
        if TTYtest.debug and TTYtest.pause
          printf 'Press enter will clear the screen'
          while ! gets
            sleep 0.05
          end
        end
        driver.tmux(*%W[send-keys -Rt #{name}], 'C-c')
        sleep TTYtest.send_keys_delay
        driver.tmux(*%W[send-keys -Rt #{name}], 'C-c')
        sleep TTYtest.send_keys_delay
        driver.tmux(*%W[send-keys -Rt #{name}], 'printf "\\033c"')
        sleep TTYtest.send_keys_delay
        driver.tmux(*%W[send-keys -Rt #{name}], 'Enter')
        sleep TTYtest.send_keys_delay
      end
    end
  end
end

def check_cmds(cmds)
  if cmds.is_a? String
    cmds = cmds.split(',')
  end
  for bin in cmds do
    if ! find_executable "#{bin}"
      raise "=====> Missing executable '#{bin}' <=====\n#{to_s}"
      exit 1
    end
  end
  puts "\nRequired binaries : OK\n\n"
end

