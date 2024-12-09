local wezterm = require("wezterm")

local EVENT_NAME = "lazy-workspace-layout-switched"

local LWL = {}

local workspaces = {}
local choices = {}

function LWL.init(ws)
	workspaces = ws

	for _, item in ipairs(ws) do
		table.insert(choices, {
			id = item["cwd"],
			label = item["label"],
		})
	end

	wezterm.on(EVENT_NAME, function(_, label)
		local current_ws = LWL.get_workspace_by_label(label)

		if current_ws == nil then
			wezterm.log_error("lazy-workspace-layout: workspace not found by label: " .. label)
			return
		end

		if LWL.is_workspace_initialized(label) == true then
			wezterm.log_info("lazy-workspace-layout: switched to " .. current_ws["label"])
		else
			local window = LWL.get_active_window_by_workspace_label(label)
			if window == nil then
				wezterm.log_error("lazy-workspace-layout: window not found by label: " .. label)
				return
			end
			wezterm.log_info("lazy-workspace-layout: apply layout " .. current_ws["label"])
			current_ws.layout(window, window:active_pane(), current_ws)

			LWL.mark_workspace_as_initialized(label)
		end
	end)
end

function LWL.bind()
	return wezterm.action_callback(function(window, pane)
		window:perform_action(
			wezterm.action.InputSelector({
				action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
					inner_window:perform_action(
						wezterm.action.SwitchToWorkspace({
							name = label,
							spawn = {
								label = "Workspace: " .. label,
								cwd = id,
							},
						}),
						inner_pane
					)
					wezterm.emit(EVENT_NAME, id, label)
				end),
				title = "Choose Workspace",
				choices = choices,
				fuzzy = true,
				-- Nightly version only: https://wezfurlong.org/wezterm/config/lua/keyassignment/InputSelector.html?h=input+selector#:~:text=These%20additional%20fields%20are%20also%20available%3A
				-- fuzzy_description = "Fuzzy find and/or make a workspace",
			}),
			pane
		)
	end)
end

-- utils
function LWL.get_workspace_by_label(label)
	for _, item in ipairs(workspaces) do
		if item["label"] == label then
			return item
		end
	end
end

function LWL.get_active_window_by_workspace_label(label)
	for _, item in ipairs(wezterm.mux:all_windows()) do
		if item:get_workspace() == label then
			return item
		end
	end
end

function LWL.is_workspace_initialized(label)
	local flags = wezterm.GLOBAL.lwl_initialized_workspaces
	if flags == nil then
		return false
	end
	local is_initialized = flags[label]
	if is_initialized == nil then
		return false
	end
	return is_initialized
end

function LWL.mark_workspace_as_initialized(label)
	local flags = wezterm.GLOBAL.lwl_initialized_workspaces
	if flags == nil then
		wezterm.GLOBAL.lwl_initialized_workspaces = {}
	end
	wezterm.GLOBAL.lwl_initialized_workspaces[label] = true
end

return LWL
