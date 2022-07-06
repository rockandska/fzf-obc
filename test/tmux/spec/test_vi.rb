class Filedir
  def test_vi

    # vi use _filedir_xspec with extension filter
    create_files_dirs(
      subdirs: %w{d1},
      files: %w{
        test.conf
        test\ 1.conf
        test.class
        test.mp3
      }
    )

    @tty.send_keys("vi #{@filedir_start}","#{TAB}")
    @tty.assert_matches(<<~EOF)
      $ vi #{@filedir_start}
      >
        3/3
      > #{@fzf_start_dir}d1
        #{@fzf_start_dir}test 1.conf
        #{@fzf_start_dir}test.conf
    EOF
    @tty.send_keys("#{DOWN}")
    @tty.send_keys("#{TAB}")
    @tty.assert_row(0,"$ vi #{@filedir_start}test\\ 1.conf")

    @tty.clear_screen()

    ######################
    # Test with symlinks #
    ######################
    File.symlink("#{@test_dir}/test.conf", "#{@test_dir}/linktest.conf")
    @tty.send_keys("vi #{@filedir_start}","#{TAB}")
    @tty.assert_matches(<<~EOF)
      $ vi #{@filedir_start}
      >
        4/4
      > #{@fzf_start_dir}d1
        #{@fzf_start_dir}linktest.conf
        #{@fzf_start_dir}test 1.conf
        #{@fzf_start_dir}test.conf
    EOF
    @tty.send_keys("#{DOWN}")
    @tty.send_keys("#{DOWN}")
    @tty.send_keys("#{DOWN}")
    @tty.send_keys("#{TAB}")
    @tty.assert_row(0,"$ vi #{@filedir_start}test.conf")
  
    @tty.clear_screen()

    @tty.send_keys("rm #{@filedir_start}test.conf","#{ENTER}")
    @tty.send_keys("vi #{@filedir_start}","#{TAB}")
    @tty.assert_matches(<<~EOF)
      $ rm #{@filedir_start}test.conf
      $ vi #{@filedir_start}
      >
        3/3
      > #{@fzf_start_dir}d1
        #{@fzf_start_dir}linktest.conf
        #{@fzf_start_dir}test 1.conf
    EOF
    @tty.send_keys("#{DOWN}")
    @tty.send_keys("#{TAB}")
    @tty.assert_row(1,"$ vi #{@filedir_start}linktest.conf")

    @tty.clear_screen()
  end
end
