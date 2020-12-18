class Filedir
  def test_cat
    create_files_dirs(
      subdirs: %w{d1 d1\ 0},
      files: %w{
        yyy
        xxx
        xxx\ xxx
      }
    )

    @tty.send_keys("cat #{@filedir_start}","#{TAB}", delay: 0.01)
    @tty.assert_matches <<~TTY
      $ cat #{@filedir_start}
      >
        5/5
      > #{@fzf_start_dir}d1/
        #{@fzf_start_dir}d1 0/
        #{@fzf_start_dir}xxx
        #{@fzf_start_dir}xxx xxx
        #{@fzf_start_dir}yyy
    TTY
    @tty.send_keys('x',"#{DOWN}","#{TAB}")
    @tty.assert_matches <<~TTY
      $ cat #{@filedir_start}xxx\\ xxx
    TTY

    @tty.clear_screen()

    ################
    # With globs
    ################
    @tty.send_keys("cat #{@filedir_start}**","#{TAB}", delay: 0.01)
    @tty.assert_matches <<~TTY
      $ cat #{@filedir_start}**
      >
        11/11
      > #{@fzf_start_dir}d1/
        #{@fzf_start_dir}d1/xxx
        #{@fzf_start_dir}d1/xxx xxx
        #{@fzf_start_dir}d1/yyy
        #{@fzf_start_dir}d1 0/
        #{@fzf_start_dir}d1 0/xxx
        #{@fzf_start_dir}d1 0/xxx xxx
        #{@fzf_start_dir}d1 0/yyy
    TTY
    @tty.send_keys(<<~EOF)
      x
      #{DOWN}
      #{TAB}
      #{DOWN}
      #{TAB}
      #{ENTER}
    EOF
    @tty.assert_matches_inline <<~TTY
      $ cat #{@filedir_start}d1/xxx\\ xxx #{@filedir_start}d1\\ 0/xxx\\ xxx
    TTY

    @tty.clear_screen()
  end
end
