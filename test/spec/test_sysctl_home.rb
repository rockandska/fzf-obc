class FzfObcTest
  def test_sysctl_home
    # sysctl use _filedir with extension filter
    create_files_dirs(
      dest: "#{temp_test_home_dir}",
      subdirs: %w{d1},
      files: %w{
        test.ko.gz
        test\ 1.ko.gz
        test.log
        test.conf
        test3.conf
      }
    )
    @tty.send_keys("sysctl -p #{temp_test_home_dir}/","#{TAB}", delay: 0.01)
    @tty.assert_matches(<<~EOF)
      $ sysctl -p #{temp_test_home_dir}/
      >
        3/3
      > #{temp_test_home_dir}/test3.conf
        #{temp_test_home_dir}/test.conf
        #{temp_test_home_dir}/d1/
    EOF
    @tty.send_keys("#{DOWN}")
    @tty.send_keys("#{TAB}")
    @tty.assert_row(0,"$ sysctl -p #{temp_test_home_dir}/test.conf")
  end
end
