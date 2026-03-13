local memory = sbar.add("item", "widgets.memory.label", {
  position = "right",
  padding_right = 12,
  icon = { string = icons.memory, color = colors.teal },
  label = {
    string = "??%",
    width = 34,
    color = colors.teal,
    font = { family = settings.font.numbers },
  },
  background = { drawing = false },
  update_freq = 5,
})

local mem_graph = sbar.add("graph", "widgets.memory.graph", 42, {
  position = "right",
  graph = { color = colors.teal },
  background = {
    height = 22,
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = true,
  },
  icon = { drawing = false },
  label = { drawing = false },
  width = 42,
})

memory:subscribe("routine", function()
  sbar.exec(
    [[memory_pressure | awk '/percentage/{print 100-$5}']],
    function(result)
      if not result then return end
      local percent = tonumber(result) or 0
      local graph_val = math.min(percent / 100.0, 1.0)
      mem_graph:push({ graph_val })

      local color = colors.teal
      if percent > 30 then
        if percent < 60 then
          color = colors.yellow
        elseif percent < 80 then
          color = colors.peach
        else
          color = colors.red
        end
      end

      memory:set({
        icon = { color = color },
        label = { string = percent .. "%", color = color },
      })
      mem_graph:set({ graph = { color = color } })
    end
  )
end)

memory:subscribe("mouse.clicked", function()
  sbar.exec("open -a 'Activity Monitor'")
end)
