class FzfObcTest
  def test_option_filedir_hidden_first

    create_files_dirs(
      dest: "#{temp_test_dir}",
      subdirs: %w{.d1},
      files: %w{
        yyy
        xxx
        .a3
        .l1
        .p1
        .p2
      }
    )

    for short_filedir in (0..1).reverse_each do

      if short_filedir == 1
        start_dir = ""
      else
        @tty.send_keys("FZF_OBC_SHORT_FILEDIR=0","#{ENTER}")
        @tty.clear_screen()
        start_dir = "#{temp_test_dir}/"
      end

      # default display
      @tty.send_keys("cat #{temp_test_dir}/","#{TAB}", delay: 0.01)
      @tty.assert_matches <<~TTY
        $ cat #{temp_test_dir}/
        >
          7/7
        > #{start_dir}xxx
          #{start_dir}yyy
          #{start_dir}.a3
          #{start_dir}.d1/
          #{start_dir}.l1
          #{start_dir}.p1
          #{start_dir}.p2
      TTY
      @tty.send_keys("#{CTRLC}")
      @tty.clear_screen()

      @tty.send_keys("cat #{temp_test_dir}/.a","#{TAB}", delay: 0.01)
      @tty.assert_matches <<~TTY
        $ cat #{temp_test_dir}/.a3
      TTY
      @tty.clear_screen()

      # hidden first display
      @tty.send_keys("FZF_OBC_STD_FILEDIR_HIDDEN_FIRST=1","#{ENTER}")
      @tty.clear_screen()

      @tty.send_keys("cat #{temp_test_dir}/","#{TAB}", delay: 0.01)
      @tty.assert_matches <<~TTY
        $ cat #{temp_test_dir}/
        >
          7/7
        > #{start_dir}.a3
          #{start_dir}.d1/
          #{start_dir}.l1
          #{start_dir}.p1
          #{start_dir}.p2
          #{start_dir}xxx
          #{start_dir}yyy
      TTY
      @tty.send_keys("#{CTRLC}")
      @tty.clear_screen()

      @tty.send_keys("cat #{temp_test_dir}/.a","#{TAB}", delay: 0.01)
      @tty.assert_matches <<~TTY
        $ cat #{temp_test_dir}/.a3
      TTY
      @tty.clear_screen()

      # clear the option
      @tty.send_keys("unset FZF_OBC_STD_FILEDIR_HIDDEN_FIRST","#{ENTER}")
      @tty.clear_screen()

    end
  end
end
