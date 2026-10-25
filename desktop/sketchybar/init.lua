sbar = require("sketchybar")
colors = require("colors")
icons = require("icons")
settings = require("settings")

sbar.begin_config()
require("bar")
require("default")
require("items")
sbar.end_config()
sbar.exec("sketchybar --update")

sbar.event_loop()
