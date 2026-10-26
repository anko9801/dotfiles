sbar = require("sketchybar")
colors = require("colors")
icons = require("icons")
settings = require("settings")
require("helpers.menu").start()

sbar.begin_config()
require("bar")
require("default")
require("items")
sbar.add("item", "config.health", { drawing = false, updates = false, label = { string = sketchybar_generation or "development" } })
sbar.end_config()

sbar.event_loop()
