rex.bind("ctrl+b>n", "session.new")
rex.bind("ctrl+b>shift+n", "session.rename")
rex.bind("ctrl+b>shift+d", "session.close")
rex.bind("ctrl+b>t", "client.tab.new")
rex.bind("ctrl+b>shift+t", "client.tab.rename")
rex.bind("ctrl+b>shift+w", "client.tab.close")
rex.bind("ctrl+tab", "session.next")
rex.bind("ctrl+shift+tab", "session.previous")
rex.bind("ctrl+alt+tab", "client.tab.next")
rex.bind("ctrl+alt+shift+tab", "client.tab.previous")
-- Programs that use ctrl+b themselves still receive it.
rex.bind("ctrl+b>ctrl+b", "pane.send_key", { key = "ctrl+b" })
for i = 1, 9 do
  rex.bind("alt+" .. i, "client.tab.goto", { index = i })
end
