class FzfObcTest
  def test_vi_home
    for short_filedir in (0..1).reverse_each do

      # vi use _filedir_xspec with extension filter
      create_files_dirs(
        dest: "#{temp_test_home_dir}",
        subdirs: %w{d1},
        files: %w{
          test.conf
          test\ 1.conf
          test.class
          test.mp3
        }
      )

      if short_filedir == 1
        start_dir = ""
      else
        @tty.send_keys("FZF_OBC_SHORT_FILEDIR=0","#{ENTER}")
        @tty.clear_screen()
        start_dir = "#{temp_test_home_dir}/"
      end

      @tty.send_keys("vi #{temp_test_home_dir}/","#{TAB}", delay: 0.01)
      @tty.assert_matches(<<~EOF)
        $ vi #{temp_test_home_dir}/
        >
          3/3
        > #{start_dir}d1/
          #{start_dir}test.conf
          #{start_dir}test 1.conf
      EOF
      @tty.send_keys("#{DOWN}")
      @tty.send_keys("#{DOWN}")
      @tty.send_keys("#{TAB}")
      @tty.assert_row(0,"$ vi #{temp_test_home_dir}/test\\ 1.conf")

      @tty.clear_screen()

      #############
      # With globs
      #############
      @tty.send_keys("vi #{temp_test_home_dir}/**","#{TAB}", sleep: 0.01)
      @tty.assert_matches(<<~EOF)
        $ vi #{temp_test_home_dir}/**
        >
          5/5
        > #{start_dir}d1/
          #{start_dir}d1/test.conf
          #{start_dir}d1/test 1.conf
          #{start_dir}test.conf
          #{start_dir}test 1.conf
      EOF
      @tty.send_keys("#{DOWN}")
      @tty.send_keys("#{DOWN}")
      @tty.send_keys("#{ENTER}")
      @tty.assert_row(0,"$ vi #{temp_test_home_dir}/d1/test\\ 1.conf")

      @tty.clear_screen()

    end
  end
end
