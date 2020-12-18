class Filedir
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

    @tty.send_keys("insmod #{@filedir_start}","#{TAB}", delay: 0.01)
    @tty.assert_matches(<<~EOF)
      $ insmod #{@filedir_start}
      >
        3/3
      > #{@fzf_start_dir}d1/
        #{@fzf_start_dir}test.ko.gz
        #{@fzf_start_dir}test 1.ko.gz
    EOF
    @tty.send_keys("#{DOWN}")
    @tty.send_keys("#{DOWN}")
    @tty.send_keys("#{TAB}")
    @tty.assert_matches_inline("$ insmod #{@filedir_start}test\\ 1.ko.gz")
    @tty.clear_screen()
  end
end
