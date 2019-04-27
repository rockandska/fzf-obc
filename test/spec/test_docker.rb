class FzfObcTest
  def test_docker
    @tty.send_keys("docker ","#{TAB}", delay: 0.01)
    @tty.assert_matches(<<~EOF)
      $ docker
      >
        54/54
      > config
        container
        image
        network
        node
        plugin
        secret
        service
    EOF

    @tty.send_keys("pl")
    @tty.assert_matches(<<~EOF)
      $ docker
      > pl
        2/54
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
    @tty.send_keys("#{TAB}")
    @tty.assert_row(0,"$ docker plugin create")

  end
end
