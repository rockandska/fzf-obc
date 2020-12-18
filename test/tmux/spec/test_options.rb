class Filedir
  def test_options

    create_files_dirs(
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

    # default display
    @tty.send_keys("cat #{@filedir_start}","#{TAB}", delay: 0.01)
    @tty.assert_matches <<~TTY
      $ cat #{@filedir_start}
      >
        7/7
      > #{@fzf_start_dir}xxx
        #{@fzf_start_dir}yyy
        #{@fzf_start_dir}.a3
        #{@fzf_start_dir}.d1/
        #{@fzf_start_dir}.l1
        #{@fzf_start_dir}.p1
        #{@fzf_start_dir}.p2
    TTY
    @tty.send_keys("#{CTRLC}")
    @tty.clear_screen()

    @tty.send_keys("cat #{@filedir_start}.a","#{TAB}", delay: 0.01)
    @tty.assert_matches <<~TTY
      $ cat #{@filedir_start}.a3
    TTY
    @tty.clear_screen()

    # hidden first display
    @tty.send_keys("FZF_OBC_STD_FILEDIR_HIDDEN_FIRST=1","#{ENTER}")
    @tty.clear_screen()

    @tty.send_keys("cat #{@filedir_start}","#{TAB}", delay: 0.01)
    @tty.assert_matches <<~TTY
      $ cat #{@filedir_start}
      >
        7/7
      > #{@fzf_start_dir}.a3
        #{@fzf_start_dir}.d1/
        #{@fzf_start_dir}.l1
        #{@fzf_start_dir}.p1
        #{@fzf_start_dir}.p2
        #{@fzf_start_dir}xxx
        #{@fzf_start_dir}yyy
    TTY
    @tty.send_keys("#{CTRLC}")
    @tty.clear_screen()

    @tty.send_keys("cat #{@filedir_start}.a","#{TAB}", delay: 0.01)
    @tty.assert_matches <<~TTY
      $ cat #{@filedir_start}.a3
    TTY
    @tty.clear_screen()

    # clear the option
    @tty.send_keys("unset FZF_OBC_STD_FILEDIR_HIDDEN_FIRST","#{ENTER}")
    @tty.clear_screen()

  end
end
