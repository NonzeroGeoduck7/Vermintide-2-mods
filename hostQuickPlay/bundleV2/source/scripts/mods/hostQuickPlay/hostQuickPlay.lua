local mod = get_mod("hostQuickPlay")

--[[
	Source
	
	https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/04a4a9e353bd5bba37dec23ee1bd416aec2d6c55/scripts/ui/views/start_game_view/windows/definitions/start_game_window_adventure_settings_definitions.lua
	
	https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/04a4a9e353bd5bba37dec23ee1bd416aec2d6c55/scripts/ui/views/start_game_view/windows/start_game_window_settings.lua
--]]

mod.host = false
mod.private = false

mod.toggle_host = function()
	
	mod.host = not mod.host
	if not mod.host then
		mod.private = false
	end
	
	if mod.host then
		mod:echo("Host Quick Play matches - activated")
	else
		mod:echo("Host Quick Play matches - deactivated")
	end
end


--[[
	Hooks
--]]

mod:hook(MatchmakingManager, "find_game", function (func, self, search_config)
	
	if self.is_server and mod.host then
		search_config.always_host = true
	end
	
	if self.is_server and mod.private and mod.in_modded_realm() then
		search_config.private_game = true
	end

	return func(self, search_config)
end)


--[[
	Callbacks
--]]

-- Called when the checkbox for this mod is unchecked
mod.on_disabled = function(is_first_call)
	mod:disable_all_commands()
end

-- Called when the checkbox for this is checked
mod.on_enabled = function(is_first_call)
	mod:enable_all_commands()
end


--[[
	Initialization
--]]

mod:command("host_toggle", "host your quick play games in a solo lobby", function(...) mod.toggle_host(...) end)



--[[
	Changes to UI
--]]

mod:hook(StartGameWindowAdventureSettings, "create_ui_elements", function(func, self, params, offset)

	if not mod:get("noUI") then
		return func(self, params, offset)
	end
	
	local ui_scenegraph = UISceneGraph.init_scenegraph(adventure_definitions.scenegraph_definition)
	self.ui_scenegraph = ui_scenegraph
	local widgets = {}
	local widgets_by_name = {}

	for name, widget_definition in pairs(adventure_definitions.widgets) do
		local widget = UIWidget.init(widget_definition)
		widgets[#widgets + 1] = widget
		widgets_by_name[name] = widget
	end

	local other_options_widgets = {}

	for name, widget_definition in pairs(adventure_definitions.other_options_widgets) do
		local widget = UIWidget.init(widget_definition)
		other_options_widgets[#other_options_widgets + 1] = widget
		widgets_by_name[name] = widget
	end

	self._other_options_widgets = other_options_widgets

	self._widgets = widgets
	self._widgets_by_name = widgets_by_name

	UIRenderer.clear_scenegraph_queue(self.ui_renderer)

	self.ui_animator = UIAnimator:new(ui_scenegraph, adventure_definitions.animation_definitions)

	if offset then
		local window_position = ui_scenegraph.window.local_position
		window_position[1] = window_position[1] + offset[1]
		window_position[2] = window_position[2] + offset[2]
		window_position[3] = window_position[3] + offset[3]
	end

	widgets_by_name.play_button.content.button_hotspot.disable_button = true
	widgets_by_name.game_option_reward.content.button_hotspot.disable_button = true
	local game_option_difficulty = widgets_by_name.game_option_difficulty
	local anim = self:_animate_pulse(game_option_difficulty.style.glow_frame.color, 1, 255, 100, 2)

	UIWidget.animate(game_option_difficulty, anim)
	
	self.parent:set_always_host_option_enabled(mod.host)
	
	if mod.in_modded_realm() then
		self.parent:set_private_option_enabled(mod.private)
	else
		local private_button = widgets_by_name.private_button
		private_button.content.button_hotspot.disable_button = true
	end
	
end)

mod:hook(StartGameWindowAdventureSettings, "draw", function(func, self, dt)
	
	if not mod:get("noUI") then
		return func(self, dt)
	end
	
	func(self, dt)
	
	local ui_renderer = self.ui_renderer
	local ui_scenegraph = self.ui_scenegraph
	local input_service = self.parent:window_input_service()

	UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, self.render_settings)
	
	local other_options_widgets = self._other_options_widgets

	for i = 1, #other_options_widgets, 1 do
		local widget = other_options_widgets[i]

		UIRenderer.draw_widget(ui_renderer, widget)
	end

	UIRenderer.end_pass(ui_renderer)
end)

mod:hook(StartGameWindowAdventureSettings, "update", function(func, self, ...)

	if not mod:get("noUI") then
		return func(self, ...)
	end
	
	mod.update_additional_options(self)
	func(self, ...)
end)

mod:hook(StartGameWindowAdventureSettings, "_handle_input", function(func, self, dt, ...)

	if not mod:get("noUI") then
		return func(self, dt, ...)
	end
	
	func(self, dt, ...)
	
	local parent = self.parent
	local widgets_by_name = self._widgets_by_name
	
	local host_button = widgets_by_name.host_button
	local private_button = widgets_by_name.private_button
	
	UIWidgetUtils.animate_default_checkbox_button(private_button, dt)
	UIWidgetUtils.animate_default_checkbox_button(host_button, dt)

	if self:_is_button_hover_enter(private_button) or self:_is_button_hover_enter(host_button) then
		self:_play_sound("play_gui_lobby_button_01_difficulty_confirm_hover")
	end

	local changed_selection = mod._is_other_option_button_selected(self, private_button, self._private_enabled)

	if changed_selection ~= nil then
		parent:set_private_option_enabled(changed_selection)
		mod.private = changed_selection
		if changed_selection then -- if private is selected, host will automatically be selected
			mod.host = true
			parent:set_always_host_option_enabled(true)
		end
	end

	changed_selection = mod._is_other_option_button_selected(self, host_button, self._always_host_enabled)

	if changed_selection ~= nil then
		parent:set_always_host_option_enabled(changed_selection)
		mod.host = changed_selection
	end
	
end)

mod.update_additional_options = function (self)
	local parent = self.parent
	local private_enabled = parent:is_private_option_enabled()
	local always_host_enabled = parent:is_always_host_option_enabled()
	local strict_matchmaking_enabled = parent:is_strict_matchmaking_option_enabled()
	local twitch_active = Managers.twitch and Managers.twitch:is_connected()

	if private_enabled ~= self._private_enabled or always_host_enabled ~= self._always_host_enabled or strict_matchmaking_enabled ~= self._strict_matchmaking_enabled or twitch_active ~= self._twitch_active then
		local widgets_by_name = self._widgets_by_name
		local private_is_selected = private_enabled
		local private_is_disabled = twitch_active
		local private_hotspot = widgets_by_name.private_button.content.button_hotspot
		
		if mod.in_modded_realm() then
			private_hotspot.is_selected = private_is_selected
			private_hotspot.disable_button = private_is_disabled
		end
		local always_host_is_selected = private_enabled or always_host_enabled
		local always_host_is_disabled = private_enabled or twitch_active
		local host_hotspot = widgets_by_name.host_button.content.button_hotspot
		host_hotspot.is_selected = always_host_is_selected
		host_hotspot.disable_button = always_host_is_disabled
		
		self._private_enabled = private_enabled
		self._always_host_enabled = always_host_enabled
		self._twitch_active = twitch_active
	end
end

mod._is_other_option_button_selected = function(self, widget, current_option)
	if self:_is_button_released(widget) then
		local is_selected = not current_option

		if is_selected then
			self:_play_sound("play_gui_lobby_button_03_private")
		else
			self:_play_sound("play_gui_lobby_button_03_public")
		end

		return is_selected
	end

	return nil
end

mod.in_modded_realm = function()
	return script_data["eac-untrusted"]
end


































mod:hook(StartGameWindowEventSettings, "create_ui_elements", function(func, self, params, offset)

	if not mod:get("noUI") then
		return func(self, params, offset)
	end
	
	local ui_scenegraph = UISceneGraph.init_scenegraph(event_definitions.scenegraph_definition)
	self.ui_scenegraph = ui_scenegraph
	local widgets = {}
	local widgets_by_name = {}

	for name, widget_definition in pairs(event_definitions.widgets) do
		local widget = UIWidget.init(widget_definition)
		widgets[#widgets + 1] = widget
		widgets_by_name[name] = widget
	end

	local other_options_widgets = {}

	for name, widget_definition in pairs(event_definitions.other_options_widgets) do
		local widget = UIWidget.init(widget_definition)
		other_options_widgets[#other_options_widgets + 1] = widget
		widgets_by_name[name] = widget
	end

	self._other_options_widgets = other_options_widgets

	self._widgets = widgets
	self._widgets_by_name = widgets_by_name

	UIRenderer.clear_scenegraph_queue(self.ui_renderer)

	self.ui_animator = UIAnimator:new(ui_scenegraph, event_definitions.animation_definitions)

	if offset then
		local window_position = ui_scenegraph.window.local_position
		window_position[1] = window_position[1] + offset[1]
		window_position[2] = window_position[2] + offset[2]
		window_position[3] = window_position[3] + offset[3]
	end

	widgets_by_name.play_button.content.button_hotspot.disable_button = true
	local game_option_difficulty = widgets_by_name.game_option_difficulty
	local anim = self:_animate_pulse(game_option_difficulty.style.glow_frame.color, 1, 255, 100, 2)

	UIWidget.animate(game_option_difficulty, anim)
	
	self.parent:set_always_host_option_enabled(mod.host)
	
	if mod.in_modded_realm() then
		self.parent:set_private_option_enabled(mod.private)
	else
		local private_button = widgets_by_name.private_button
		private_button.content.button_hotspot.disable_button = true
	end
	
	self:_setup_content_from_backend()
end)

mod:hook(StartGameWindowEventSettings, "draw", function(func, self, dt)
	
	if not mod:get("noUI") then
		return func(self, dt)
	end
	
	func(self, dt)
	
	local ui_renderer = self.ui_renderer
	local ui_scenegraph = self.ui_scenegraph
	local input_service = self.parent:window_input_service()

	UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, self.render_settings)
	
	local other_options_widgets = self._other_options_widgets

	for i = 1, #other_options_widgets, 1 do
		local widget = other_options_widgets[i]

		UIRenderer.draw_widget(ui_renderer, widget)
	end

	UIRenderer.end_pass(ui_renderer)
	
end)

mod:hook(StartGameWindowEventSettings, "_handle_input", function(func, self, dt, ...)

	if not mod:get("noUI") then
		return func(self, dt)
	end
	
	func(self, dt, ...)
	
	local parent = self.parent
	local widgets_by_name = self._widgets_by_name
	
	local host_button = widgets_by_name.host_button
	local private_button = widgets_by_name.private_button
	
	UIWidgetUtils.animate_default_checkbox_button(private_button, dt)
	UIWidgetUtils.animate_default_checkbox_button(host_button, dt)

	if self:_is_button_hover_enter(private_button) or self:_is_button_hover_enter(host_button) then
		self:_play_sound("play_gui_lobby_button_01_difficulty_confirm_hover")
	end

	local changed_selection = mod._is_other_option_button_selected(self, private_button, self._private_enabled)

	if changed_selection ~= nil then
		parent:set_private_option_enabled(changed_selection)
		mod.private = changed_selection
		if changed_selection then -- if private is selected, host will automatically be selected
			mod.host = true
			parent:set_always_host_option_enabled(true)
		end
	end

	changed_selection = mod._is_other_option_button_selected(self, host_button, self._always_host_enabled)

	if changed_selection ~= nil then
		parent:set_always_host_option_enabled(changed_selection)
		mod.host = changed_selection
	end
	
end)

mod:hook(StartGameWindowEventSettings, "update", function(func, self, ...)

	if not mod:get("noUI") then
		return func(self, ...)
	end
	
	mod.update_additional_options(self)
	func(self, ...)
end)


-- SYNC WITH CUSTOM GAME SETTINGS
mod:hook(StartGameWindowSettings, "create_ui_elements", function(func, self, ...)
	
	func(self,...)
	
	self.parent:set_always_host_option_enabled(mod.host)
	self.parent:set_private_option_enabled(mod.private)
end)

mod:hook(StartGameWindowSettings, "_update_additional_options", function(func, self)
	
	func(self)
	
	local parent = self.parent
	mod.host = parent:is_always_host_option_enabled()
	mod.private = parent:is_private_option_enabled()
end)
