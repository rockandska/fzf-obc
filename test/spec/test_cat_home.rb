class FzfObcTest
  def test_cat_home
    for short_filedir in (0..1).reverse_each do

      create_files_dirs(
        dest: "#{temp_test_home_dir}",
        subdirs: %w{d1 d1\ 0},
        files: %w{
          test-fzf-obc.test
          test\ fzf-obc.test
          fzf-obc.test
        }
      )

      if short_filedir == 1
        start_dir = ""
      else
        @tty.send_keys("FZF_OBC_SHORT_FILEDIR=0","#{ENTER}")
        @tty.clear_screen()
        start_dir = "#{temp_test_home_dir}/"
      end

      @tty.send_keys("cat #{temp_test_home_dir}/","#{TAB}",delay: 0.01)
      @tty.send_keys("'fzf-obc.test")
      @tty.assert_matches <<~TTY
        $ cat #{temp_test_home_dir}/
        > 'fzf-obc.test
          3/5
        > #{start_dir}test-fzf-obc.test
          #{start_dir}test fzf-obc.test
          #{start_dir}fzf-obc.test
      TTY
      @tty.send_keys(<<~EOF)
        #{CTRLC}
        'test-fzf-obc.test
      EOF
      @tty.assert_matches <<~TTY
        $ cat #{temp_test_home_dir}/
        > 'test-fzf-obc.test
          1/5
        > #{start_dir}test-fzf-obc.test
      TTY
      @tty.send_keys(<<~EOF)
        #{CTRLC}
        #{DOWN}
        #{TAB}
      EOF
      @tty.assert_matches <<~TTY
        $ cat #{temp_test_home_dir}/test\\ fzf-obc.test
      TTY

      @tty.clear_screen()

      ################
      # With globs
      ################
      @tty.send_keys("cat #{temp_test_home_dir}/**","#{TAB}",delay: 0.01)
      @tty.send_keys("'fzf-obc.test")
      @tty.assert_matches <<~TTY
        $ cat #{temp_test_home_dir}/**
        > 'fzf-obc.test
          9/11
        > #{start_dir}test-fzf-obc.test
          #{start_dir}test fzf-obc.test
          #{start_dir}fzf-obc.test
          #{start_dir}d1/test-fzf-obc.test
          #{start_dir}d1/test fzf-obc.test
          #{start_dir}d1/fzf-obc.test
          #{start_dir}d1 0/test-fzf-obc.test
          #{start_dir}d1 0/test fzf-obc.test
      TTY
      @tty.send_keys(<<~EOF)
        #{CTRLC}
        'test-fzf-obc.test
      EOF
      @tty.assert_matches <<~TTY
        $ cat #{temp_test_home_dir}/**
        > 'test-fzf-obc.test
          3/11
        > #{start_dir}test-fzf-obc.test
          #{start_dir}d1/test-fzf-obc.test
          #{start_dir}d1 0/test-fzf-obc.test
      TTY
      @tty.send_keys(<<~EOF)
        #{CTRLC}
        'fzf-obc.test
        #{DOWN}
        #{TAB}
        #{TAB}
        #{ENTER}
      EOF
      @tty.assert_matches <<~TTY
        $ cat #{temp_test_home_dir}/test\\ fzf-obc.test #{temp_test_home_dir[0..19]}
        #{temp_test_home_dir[20..-1]}/fzf-obc.test
      TTY
      @tty.clear_screen()
    end
  end
end
