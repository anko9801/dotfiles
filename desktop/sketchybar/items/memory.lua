local memory = sbar.add("item", "memory", {
  position = "right",
  icon = { color = colors.teal },
  label = { color = colors.teal },
  background = { drawing = false },
  update_freq = 5,
})

memory:subscribe("mouse.clicked", function()
  sbar.exec("open -a 'Activity Monitor'")
end)

local mem_graph = sbar.add("graph", "mem_graph", 60, {
  position = "right",
  graph = {
    color = colors.teal,
    fill_color = colors.with_alpha(colors.teal, 0x40),
    line_width = 1.0,
  },
  background = {
    drawing = true,
    color = 0x00000000,
    height = 24,
    border_width = 0,
  },
  label = { drawing = false },
  icon = { drawing = false },
  width = 60,
})

local mem_bracket = sbar.add("bracket", "mem_bracket", { "memory", "mem_graph" }, {
  background = {
    color = colors.surface,
    corner_radius = 8,
    height = 28,
    border_color = colors.teal,
    border_width = 2,
  },
})

memory:subscribe("routine", function()
  sbar.exec(
    [[vm_stat | awk '
      /Pages active/ {a=$3}
      /Pages wired/ {w=$4}
      /Pages speculative/ {s=$3}
      END {
        gsub(/\./,"",a); gsub(/\./,"",w); gsub(/\./,"",s)
        printf "%.0f", (a+w+s)*4096/1024/1024/1024
      }']],
    function(used_str)
      sbar.exec("sysctl -n hw.memsize", function(total_str)
        local used = tonumber(used_str) or 0
        local total = math.floor((tonumber(total_str) or 1) / 1024 / 1024 / 1024)
        local percent = total > 0 and math.floor(used * 100 / total) or 0
        local mem_percent = math.min(percent / 150, 1.0)

        local color
        if percent > 80 then
          color = colors.red
        elseif percent > 60 then
          color = colors.peach
        elseif percent > 30 then
          color = colors.yellow
        else
          color = colors.teal
        end

        memory:set({
          icon = { string = icons.memory, color = color },
          label = { string = percent .. "%", color = color },
        })
        mem_graph:set({ graph = { color = color } })
        mem_bracket:set({ background = { border_color = color } })
        mem_graph:push({ mem_percent })
      end)
    end
  )
end)
