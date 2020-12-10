class Software
  def test_docker
    @tty.send_keys("docker p","#{TAB}", delay: 0.01)
    @tty.assert_matches(<<~EOF)
      $ docker p
      >
        6/6
      > pause
        plugin
        port
        ps
        pull
        push
    EOF

    @tty.send_keys("pl")
    @tty.assert_matches(<<~EOF)
      $ docker p
      > pl
        2/6
      > plugin
        pull
    EOF

    @tty.send_keys("#{TAB}","#{TAB}")
    @tty.assert_matches(<<~EOF)
      $ docker plugin
      >
        10/10
      > create
        disable
        enable
        inspect
        install
        ls
        push
        rm
    EOF
    @tty.send_keys("cre","#{TAB}")
    @tty.assert_row(0,"$ docker plugin create")

  end
end
