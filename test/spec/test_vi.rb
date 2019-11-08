class FzfObcTest
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
    @tty.send_keys("vi #{temp_test_dir}/","#{TAB}", delay: 0.01)
    @tty.assert_matches(<<~EOF)
      $ vi #{temp_test_dir}/
      >
        3/3
      > #{temp_test_dir}/test.conf
        #{temp_test_dir}/test 1.conf
        #{temp_test_dir}/d1/
    EOF
    @tty.send_keys("#{DOWN}")
    @tty.send_keys("#{TAB}")
    @tty.assert_row(0,"$ vi #{temp_test_dir}/test\\ 1.conf")

    @tty.clear_screen()

    #############
    # With globs
    #############
    @tty.send_keys("vi #{temp_test_dir}/**","#{TAB}", sleep: 0.01)
    @tty.assert_matches(<<~EOF)
      $ vi #{temp_test_dir}/**
      >
        5/5
      > #{temp_test_dir}/test.conf
        #{temp_test_dir}/test 1.conf
        #{temp_test_dir}/d1/test.conf
        #{temp_test_dir}/d1/test 1.conf
        #{temp_test_dir}/d1/
    EOF
    @tty.send_keys("#{DOWN}")
    @tty.send_keys("#{DOWN}")
    @tty.send_keys("#{ENTER}")
    @tty.assert_row(0,"$ vi #{temp_test_dir}/d1/test.conf")

    @tty.clear_screen()

    ######################
    # Test with symlinks #
    ######################
    File.symlink("#{BASE}/#{temp_test_dir}/test.conf", "#{BASE}/#{temp_test_dir}/link_test.conf")
    @tty.send_keys("vi #{temp_test_dir}/","#{TAB}", delay: 0.01)
    @tty.assert_matches(<<~EOF)
      $ vi #{temp_test_dir}/
      >
        4/4
      > #{temp_test_dir}/test.conf
        #{temp_test_dir}/test 1.conf
        #{temp_test_dir}/link_test.conf
        #{temp_test_dir}/d1/
    EOF
    @tty.send_keys("#{TAB}")
    @tty.assert_row(0,"$ vi #{temp_test_dir}/test.conf")
  
    @tty.clear_screen()

    @tty.send_keys("rm #{temp_test_dir}/test.conf","#{ENTER}", delay: 0.01)
    @tty.send_keys("vi #{temp_test_dir}/","#{TAB}", delay: 0.01)
    @tty.assert_matches(<<~EOF)
      $ rm #{temp_test_dir}/test.conf
      $ vi #{temp_test_dir}/
      >
        3/3
      > #{temp_test_dir}/test 1.conf
        #{temp_test_dir}/link_test.conf
        #{temp_test_dir}/d1/
    EOF
    @tty.send_keys("#{DOWN}")
    @tty.send_keys("#{TAB}")
    @tty.assert_row(1,"$ vi #{temp_test_dir}/link_test.conf")
    @tty.send_keys("#{ENTER}")

  end
  
end
