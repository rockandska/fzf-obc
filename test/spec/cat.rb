class FzfObcTest
  def test_cat
    create_files_dirs(
      dest: "#{temp_test_dir}",
      subdirs: %w{d1 d1\ 0},
      files: %w{
        yyy
        xxx
        xxx\ xxx
      }
    )
    @@tty.send_keys("cat #{temp_test_dir}/","#{TAB}", delay: 0.01)
    @@tty.assert_matches <<~TTY
      $ cat #{temp_test_dir}/
      >
        5/5
      > #{temp_test_dir}/yyy
        #{temp_test_dir}/xxx xxx
        #{temp_test_dir}/xxx
        #{temp_test_dir}/d1/
        #{temp_test_dir}/d1 0/
    TTY
    @@tty.send_keys('x',"#{TAB}")
    @@tty.assert_matches <<~TTY
      $ cat #{temp_test_dir}/xxx\\ xxx
    TTY

    @@tty.clear_screen()

    ################
    # With globs
    ################
    @@tty.send_keys("cat #{temp_test_dir}/**","#{TAB}", delay: 0.01)
    @@tty.assert_matches <<~TTY
      $ cat #{temp_test_dir}/**
      >
        11/11
      > #{temp_test_dir}/yyy
        #{temp_test_dir}/xxx xxx
        #{temp_test_dir}/xxx
        #{temp_test_dir}/d1/yyy
        #{temp_test_dir}/d1/xxx xxx
        #{temp_test_dir}/d1/xxx
        #{temp_test_dir}/d1/
        #{temp_test_dir}/d1 0/yyy
    TTY
    @@tty.send_keys(<<~EOF)
      x
      #{TAB}
      #{DOWN}
      #{DOWN}
      #{TAB}
      #{ENTER}
    EOF
    @@tty.assert_matches <<~TTY
      $ cat #{temp_test_dir}/xxx\\ xxx #{temp_test_dir}/d1/xxx
    TTY
  end

  def test_cat_home
    create_files_dirs(
      dest: "#{temp_test_home_dir}",
      subdirs: %w{d1 d1\ 0},
      files: %w{
        test-fzf-obc.test
        test\ fzf-obc.test
        fzf-obc.test
      }
    )
    @@tty.send_keys("cat #{temp_test_home_dir}/","#{TAB}",delay: 0.01)
    @@tty.send_keys("'fzf-obc.test")
    @@tty.assert_matches <<~TTY
      $ cat #{temp_test_home_dir}/
      > 'fzf-obc.test
        3/5
      > #{temp_test_home_dir}/test-fzf-obc.test
        #{temp_test_home_dir}/test fzf-obc.test
        #{temp_test_home_dir}/fzf-obc.test
    TTY
    @@tty.send_keys(<<~EOF)
      #{CTRLC}
      'test-fzf-obc.test
    EOF
    @@tty.assert_matches <<~TTY
      $ cat #{temp_test_home_dir}/
      > 'test-fzf-obc.test
        1/5
      > #{temp_test_home_dir}/test-fzf-obc.test
    TTY
    @@tty.send_keys(<<~EOF)
      #{CTRLC}
      #{DOWN}
      #{TAB}
    EOF
    @@tty.assert_matches <<~TTY
      $ cat #{temp_test_home_dir}/test\\ fzf-obc.test
    TTY

    @@tty.clear_screen()

    ################
    # With globs
    ################
    @@tty.send_keys("cat #{temp_test_home_dir}/**","#{TAB}",delay: 0.01)
    @@tty.send_keys("'fzf-obc.test")
    @@tty.assert_matches <<~TTY
      $ cat #{temp_test_home_dir}/**
      > 'fzf-obc.test
        9/11
      > #{temp_test_home_dir}/test-fzf-obc.test
        #{temp_test_home_dir}/test fzf-obc.test
        #{temp_test_home_dir}/fzf-obc.test
        #{temp_test_home_dir}/d1/test-fzf-obc.test
        #{temp_test_home_dir}/d1/test fzf-obc.test
        #{temp_test_home_dir}/d1/fzf-obc.test
        #{temp_test_home_dir}/d1 0/test-fzf-obc.test
        #{temp_test_home_dir}/d1 0/test fzf-obc.test
    TTY
    @@tty.send_keys(<<~EOF)
      #{CTRLC}
      'test-fzf-obc.test
    EOF
    @@tty.assert_matches <<~TTY
      $ cat #{temp_test_home_dir}/**
      > 'test-fzf-obc.test
        3/11
      > #{temp_test_home_dir}/test-fzf-obc.test
        #{temp_test_home_dir}/d1/test-fzf-obc.test
        #{temp_test_home_dir}/d1 0/test-fzf-obc.test
    TTY
    @@tty.send_keys(<<~EOF)
      #{CTRLC}
      'fzf-obc.test
      #{DOWN}
      #{TAB}
      #{TAB}
      #{ENTER}
    EOF
    @@tty.assert_matches <<~TTY
      $ cat #{temp_test_home_dir}/test\\ fzf-obc.test #{temp_test_home_dir[0..19]}
      #{temp_test_home_dir[20..-1]}/fzf-obc.test
    TTY
  end
end
