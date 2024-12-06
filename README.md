# lazy-workspace-layout
Wezterm plugin for lazy worskpace layout 


Based on [Aaron's Dev Blog](https://www.railsdev.dev/blog/wezterm-workspace-switcher-api/)


## Usage

```lua
local wezterm = require("wezterm")
local lwl = wezterm.plugin.require("https://github.com/estin/lazy-workspace-layout?rev=master")

-- configure layout for each project
local home = wezterm.home_dir
local workspaces = {
	{
		-- project working dir
		cwd = home,
		-- project name
		label = "Home",
		-- project layout initialization function
		layout = function(window, pane, ws)
			-- crate tabs/panes
			pane:split({ direction = "Top", size = 0.5 })
		end,
	},
	{
		cwd = home,
		label = "Work",
		layout = function(_, pane, _)
			pane:split({ direction = "Top", size = 0.5 })
		end,
	},
}
lwl.init(workspaces)

return {
	keys = {
		-- workspace switcher by name
		{ key = "s", mods = "CTRL", action = lwl.bind() },
	},
}
```
