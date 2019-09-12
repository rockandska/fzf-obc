class FzfObcTest
  def test_docker
    @tty.send_keys("docker ","#{TAB}", delay: 0.01)
    @tty.assert_matches(<<~EOF)
      $ docker
      >
        54/54
      > wait
        volume
        version
        update
        unpause
        trust
        top
        tag
    EOF

    @tty.send_keys("pl")
    @tty.assert_matches(<<~EOF)
      $ docker
      > pl
        2/54
      > pull
        plugin
    EOF

    @tty.send_keys("#{DOWN}","#{TAB}","#{TAB}")
    @tty.assert_matches(<<~EOF)
      $ docker plugin
      >
        10/10
      > upgrade
        set
        rm
        push
        ls
        install
        inspect
        enable
    EOF
    @tty.send_keys("cre","#{TAB}")
    @tty.assert_row(0,"$ docker plugin create")

  end
end
