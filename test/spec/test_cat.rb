class FzfObcTest
  def test_cat
    for short_filedir in (0..1).reverse_each do

      create_files_dirs(
        dest: "#{temp_test_dir}",
        subdirs: %w{d1 d1\ 0},
        files: %w{
          yyy
          xxx
          xxx\ xxx
        }
      )

      if short_filedir == 1
        start_dir = ""
      else
        @tty.send_keys("FZF_OBC_SHORT_FILEDIR=0","#{ENTER}")
        @tty.clear_screen()
        start_dir = "#{temp_test_dir}/"
      end

      @tty.send_keys("cat #{temp_test_dir}/","#{TAB}", delay: 0.01)
      @tty.assert_matches <<~TTY
        $ cat #{temp_test_dir}/
        >
          5/5
        > #{start_dir}yyy
          #{start_dir}xxx xxx
          #{start_dir}xxx
          #{start_dir}d1/
          #{start_dir}d1 0/
      TTY
      @tty.send_keys('x',"#{TAB}")
      @tty.assert_matches <<~TTY
        $ cat #{temp_test_dir}/xxx\\ xxx
      TTY

      @tty.clear_screen()

      ################
      # With globs
      ################
      @tty.send_keys("cat #{temp_test_dir}/**","#{TAB}", delay: 0.01)
      @tty.assert_matches <<~TTY
        $ cat #{temp_test_dir}/**
        >
          11/11
        > #{start_dir}yyy
          #{start_dir}xxx xxx
          #{start_dir}xxx
          #{start_dir}d1/yyy
          #{start_dir}d1/xxx xxx
          #{start_dir}d1/xxx
          #{start_dir}d1/
          #{start_dir}d1 0/yyy
      TTY
      @tty.send_keys(<<~EOF)
        x
        #{TAB}
        #{DOWN}
        #{DOWN}
        #{TAB}
        #{ENTER}
      EOF
      @tty.assert_matches <<~TTY
        $ cat #{temp_test_dir}/xxx\\ xxx #{temp_test_dir}/d1/xxx
      TTY

      @tty.clear_screen()
    end
  end
end
