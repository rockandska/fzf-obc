class FzfObcTest
  def test_git
    create_files_dirs(
      dest: "#{temp_test_dir}",
      subdirs: %w{},
      files: %w{
        README.md
      }
    )
    g = Git.init("#{temp_test_dir}")
    @tty.send_keys("git a", "#{TAB}", delay: 0.01)
    @tty.send_keys("dd", "#{TAB}",'.',"#{ENTER}")
    @tty.assert_matches(<<~EOF)
      $ git add .
      $
    EOF

    @tty.clear_screen()

    @tty.send_keys("git c","#{TAB}")
    @tty.send_keys("mm","#{TAB}")
    @tty.send_keys("--","#{TAB}","ssage","#{DOWN}","#{DOWN}", "#{TAB}","'First commit'","#{ENTER}")
    @tty.assert_row(0,"$ git commit --message='First commit'")

    @tty.clear_screen()

    g.branch('new_branch').checkout

    @tty.send_keys("git ", "#{TAB}")
    @tty.send_keys("check", "#{DOWN}", "#{TAB}")
    @tty.send_keys("#{TAB}")
    @tty.assert_matches(<<~EOF)
    $ git checkout
    >
      3/3
    > new_branch
      master
      HEAD
    EOF
    @tty.send_keys('new',"#{TAB}")
    @tty.assert_matches(<<~EOF)
      $ git checkout new_branch
    EOF

  end
end
