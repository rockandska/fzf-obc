class FzfObcTest
  def test_insmod
    # insmod use _filedir with extension filter
    create_files_dirs(
      subdirs: %w{d1},
      files: %w{
        test.ko.gz
        test\ 1.ko.gz
        test.log
        test.mp3
      }
    )
    @@tty.send_keys("insmod #{temp_test_dir}/","#{TAB}", delay: 0.01)
    @@tty.assert_matches(<<~EOF)
      $ insmod #{temp_test_dir}/
      >
        3/3
      > #{temp_test_dir}/test.ko.gz
        #{temp_test_dir}/test 1.ko.gz
        #{temp_test_dir}/d1/
    EOF
    @@tty.send_keys("#{DOWN}")
    @@tty.send_keys("#{TAB}")
    @@tty.assert_row(0,"$ insmod #{temp_test_dir}/test\\ 1.ko.gz")
  end

  def test_insmod_home
    # insmod use _filedir with extension filter
    create_files_dirs(
      dest: "#{temp_test_home_dir}",
      subdirs: %w{d1},
      files: %w{
        test.ko.gz
        test\ 1.ko.gz
        test.log
        test.mp3
      }
    )
    @@tty.send_keys("insmod #{temp_test_home_dir}/","#{TAB}", delay: 0.01)
    @@tty.assert_matches(<<~EOF)
      $ insmod #{temp_test_home_dir}/
      >
        3/3
      > #{temp_test_home_dir}/test.ko.gz
        #{temp_test_home_dir}/test 1.ko.gz
        #{temp_test_home_dir}/d1/
    EOF
    @@tty.send_keys("#{DOWN}")
    @@tty.send_keys("#{TAB}")
    @@tty.assert_row(0,"$ insmod #{temp_test_home_dir}/test\\ 1.ko.gz")
  end
end
