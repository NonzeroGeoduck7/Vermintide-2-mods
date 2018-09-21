local mod = get_mod("ChatWheel")

-- was used when update_rotation method was hooked -> lead to errors
mod.next = false

mod.timing = {0,0,0}
mod.reset_time = 10

-- hotkey set to 'T', when mod is started for the first time
mod.hotkey = 0

mod.phrases = {
	"message (1)",
	"on how to change (2)",
	"and these phrases (3)",
	"item description (4)",
	"in the workshop (5)",
	"check out the (6)",
	"the keybinding (7)",
	"For information (8)"
}

-- new hotkey: charr must be UPPERCASE (A - Z) or else chat wheel won't be opened
mod.set_hotkey = function(charr)
	
	local number = string.byte(charr)
	
	if tonumber(number) >= 65 and tonumber(number) <= 90 then
	
		mod:set("hotkey", tonumber(number))
		mod.hotkey = tonumber(number)
		
		mod:echo("Hotkey for chatWheel set to: " .. string.char(number))
		
	else
		mod:echo("Use an uppercase letter [A - Z] of a key to rebind the Chat Wheel.")
	end
	
end


mod.set_phrase = function(number, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10)
	-- mod:echo("num "..tostring(number) .. " " .. tostring(tonumber(number)))
	
	phrase = ''
	if w1 then phrase = phrase .. tostring(w1) end
	if w2 then phrase = phrase .." ".. tostring(w2) end
	if w3 then phrase = phrase .." ".. tostring(w3) end
	if w4 then phrase = phrase .." ".. tostring(w4) end
	if w5 then phrase = phrase .." ".. tostring(w5) end
	if w6 then phrase = phrase .." ".. tostring(w6) end
	if w7 then phrase = phrase .." ".. tostring(w7) end
	if w8 then phrase = phrase .." ".. tostring(w8) end
	if w9 then phrase = phrase .." ".. tostring(w9) end
	if w10 then phrase = phrase .." ".. tostring(w10) end
	
	
	if tonumber(number) <= 8 and tonumber(number) > 0 then
		
		mod.phrases[tonumber(number)] = tostring(phrase)
		mod:set(tostring(number), tostring(phrase))
		
		mod:echo("phrase " .. tostring(number) .. " changed to " .. phrase .. ".")
		
	end
end


-- gw_head_64
-- gw_head_64_masked
local font_name = "gw_head_64"
local font_mtrl = "materials/fonts/" .. font_name
local font_size = 40

local standard_color = {
	255,
	255,
	255,
	255
}
local choice_color = {
	255,
	155,
	155,
	155
}


-- MAYBE SLIDER IN OPTIONS? FROM 1 TO 2?
-- its multiplied with normal mouse speed
local sensitivity = 1.5


--[[
	functions
--]]

mod.enable = false

mod.choice = nil

-- called when pressing chat wheel key
mod.open_chat_wheel = function (...)
	
	mod.enable = true
	
end


--[[
	Hooks
--]]

mod.x = nil
mod.y = nil

-- not used atm, maybe needed later
local function try(f, catch_f)
	local status, exception = pcall(f)
	if not status then	
		catch_f(exception)
	else
		return status
	end
end


-- earlier version used this, error when you get hit, crash when you die while chat wheel open_chat_wheel

--[[
mod:hook(PlayerUnitFirstPerson, "update_rotation", function (func, self, ...)
	
	if self.look_delta ~= nil and mod.enable then
		try(function()
			local look_delta = self.look_delta
			
			if mod.x == nil then
					mod.x = Vector3.x(look_delta) * sensitivity
					mod.y = Vector3.y(look_delta) * sensitivity
			else
			
				mod.x = mod.x + Vector3.x(look_delta) * sensitivity
				mod.y = mod.y + Vector3.y(look_delta) * sensitivity
			
			end
		end, function(e)
		
			mod:echo("error look_delta")
			mod.next = true
			--mod.enable = false
		
		end)
	end
	
	
	if not mod.enable then
		
		return func(self, ...)
		
	else
		if mod.next then mod.enable = false mod.next = false end
	end
	
end)
--]]


-- hook mouse input to select chat phrases
mod:hook(InputManager, "update_devices", function (func, self, dt, t)

	
	if mod.enable then
		local input_devices = self.input_devices
		for input_device, device_data in pairs(input_devices) do
			for key = 0, device_data.num_axes - 1, 1 do

				if input_device.axis_name(key) ~= "cursor" and Vector3.length(input_device.axis(key)) ~= 0 then
					
					local look_delta = input_device.axis(key)
					
					-- mod:echo(input_device.axis(key))
					if mod.x == nil then
							mod.x = Vector3.x(look_delta) * sensitivity
							mod.y = Vector3.y(look_delta) * sensitivity
					else
					
						mod.x = mod.x + Vector3.x(look_delta) * sensitivity
						mod.y = mod.y - Vector3.y(look_delta) * sensitivity
					
					end
					
					
				end
			end
			
			
			-- right click disables the wheel
			local any_pressed = input_device.any_pressed()

			if any_pressed then
				local num_buttons = device_data.num_buttons - 1
				
				for key = 0, num_buttons, 1 do
					
					if input_device.pressed(key) then
					
						-- right click is button 1
						if key == 1 then
							mod.enable = false
						end
					end
					
				end
			end

			
		end
	
	end
	
	-- orig
	return func(self, dt, t)
	
end)

--[[
mod:hook(ChatGui, "update", function(func, self, dt, menu_active, menu_input_service, no_unblock, chat_enabled)

	mod:echo(tostring(self).." "..tostring(dt))
	
	return func(self, dt, menu_active, menu_input_service, no_unblock, chat_enabled)
	

end)
--]]


-- key presses are caught in this function, wheel print done in this function
mod:hook(IngameHud, "_draw", function (func, self, ...)

	try(function()
		local input = Keyboard.any_pressed()
		
		
		if input and input == mod.hotkey then
			mod.open_chat_wheel()
		end
		
		
		-- typing ENTER disables chat wheel
		-- to prevent bug when using the key when entering text in chat
		if input and input == Keyboard.ENTER then
			mod.enable = false
			
			mod.x = nil
			mod.y = nil
		end
		
		
		if mod.enable and mod.x and mod.y then

			local screen_w, screen_h = UIResolution()
			
			local distance = screen_h / 6
			
			local position = {	
								screen_w / 2,
								screen_h / 2,
								0
							 }
						
			
			
			local radius = distance / 2
			local size = 5
			
			-- UIRenderer.draw_circle(self.ui_renderer, position, radius, size, color)
			
			-- top/right/bottom/left
			if mod.choice and mod.choice == 1 then color = choice_color end
			local width, height, _ = UIRenderer.text_size(self.ui_renderer, mod.phrases[1], font_mtrl, font_size)
			UIRenderer.draw_text(self.ui_renderer, mod.phrases[1], font_mtrl, font_size, font_name, {
					screen_w / 2 - width/2,
					screen_h / 2 + distance
			}, color)
			if mod.choice and mod.choice == 1 then color = standard_color end
			
			if mod.choice and mod.choice == 3 then color = choice_color end
			local width, height, _ = UIRenderer.text_size(self.ui_renderer, mod.phrases[3], font_mtrl, font_size)
			UIRenderer.draw_text(self.ui_renderer, mod.phrases[3], font_mtrl, font_size, font_name, {
					screen_w / 2 + distance,
					screen_h / 2 - height/4
			}, color)
			if mod.choice and mod.choice == 3 then color = standard_color end
			
			if mod.choice and mod.choice == 5 then color = choice_color end
			local width, height, _ = UIRenderer.text_size(self.ui_renderer, mod.phrases[5], font_mtrl, font_size)
			UIRenderer.draw_text(self.ui_renderer, mod.phrases[5], font_mtrl, font_size, font_name, {
					screen_w / 2 - width/2,
					screen_h / 2 - distance - height
			}, color)
			if mod.choice and mod.choice == 5 then color = standard_color end
			
			if mod.choice and mod.choice == 7 then color = choice_color end
			local width, height, _ = UIRenderer.text_size(self.ui_renderer, mod.phrases[7], font_mtrl, font_size)
			UIRenderer.draw_text(self.ui_renderer, mod.phrases[7], font_mtrl, font_size, font_name, {
					screen_w / 2 - distance - width,
					screen_h / 2 - height/4
			}, color)
			if mod.choice and mod.choice == 7 then color = standard_color end
			
			
			-- diagonal ones
			
			distance = math.sqrt(math.pow(distance, 2)/2)
			
			if mod.choice and mod.choice == 2 then color = choice_color end
			local width, height, _ = UIRenderer.text_size(self.ui_renderer, mod.phrases[2], font_mtrl, font_size)
			UIRenderer.draw_text(self.ui_renderer, mod.phrases[2], font_mtrl, font_size, font_name, {
					screen_w / 2 + distance,
					screen_h / 2 + distance - height/2
			}, color)
			if mod.choice and mod.choice == 2 then color = standard_color end
			
			if mod.choice and mod.choice == 4 then color = choice_color end
			local width, height, _ = UIRenderer.text_size(self.ui_renderer, mod.phrases[4], font_mtrl, font_size)
			UIRenderer.draw_text(self.ui_renderer, mod.phrases[4], font_mtrl, font_size, font_name, {
					screen_w / 2 + distance,
					screen_h / 2 - distance - height/2
			}, color)
			if mod.choice and mod.choice == 4 then color = standard_color end
			
			if mod.choice and mod.choice == 6 then color = choice_color end
			local width, height, _ = UIRenderer.text_size(self.ui_renderer, mod.phrases[6], font_mtrl, font_size)
			UIRenderer.draw_text(self.ui_renderer, mod.phrases[6], font_mtrl, font_size, font_name, {
					screen_w / 2 - distance - width,
					screen_h / 2 - distance - height/2
			}, color)
			if mod.choice and mod.choice == 6 then color = standard_color end
		
			if mod.choice and mod.choice == 8 then color = choice_color end
			local width, height, _ = UIRenderer.text_size(self.ui_renderer, mod.phrases[8], font_mtrl, font_size)
			UIRenderer.draw_text(self.ui_renderer, mod.phrases[8], font_mtrl, font_size, font_name, {
					screen_w / 2 - distance - width,
					screen_h / 2 + distance - height/2
			}, color)
			if mod.choice and mod.choice == 8 then color = standard_color end
			
			
			-- VISUALISATION WHEN CHOSING CHAT WHEEL PHRASE
			position = {
				screen_w / 2 + mod.x, screen_h / 2 + mod.y, 0
			}
			radius = 5
			size = 5
			local color = {
				255, 0, 255, 0
			}
			
			for i=1,30,1 do
				position = {
					screen_w / 2 + i*1/30*mod.x,
					screen_h / 2 + i*1/30*mod.y,
					0
				}
				color = {
					i*1/30*255, color[2], color[3], color[4]
				}
				UIRenderer.draw_circle(self.ui_renderer, position, radius, size, color)
			end
			
			
			
			local dist = math.sqrt((mod.x ^ 2) + (mod.y ^ 2))
			
			if math.abs(dist) > distance/2 then
				
				-- find message
				
				-- angle between 
				local angle = nil
				if mod.x > 0 and mod.y > 0 then angle = math.atan(mod.x/mod.y) end
				if mod.x > 0 and mod.y < 0 then angle = math.pi+math.atan(mod.x/mod.y) end
				if mod.x < 0 and mod.y < 0 then angle = math.pi+math.atan(mod.x/mod.y) end
				if mod.x < 0 and mod.y > 0 then angle = 2*math.pi+math.atan(mod.x/mod.y) end
				
				-- special cases
				if mod.x == 0 and mod.y > 0 then angle = 0 end
				if mod.x == 0 and mod.y < 0 then angle = math.pi end
				if mod.x > 0 and mod.y == 0 then angle = math.pi/2 end
				if mod.x < 0 and mod.y == 0 then angle = 3/2*math.pi end
				
				mod.choice = math.floor((angle/(2*math.pi/8))+0.5)
				mod.choice = mod.choice % 8 + 1
				
				mod.message = mod.phrases[mod.choice]
				
			
				--[[
				if mod.x > 0 and mod.y > 0 then
					mod.message = phrases[1]
				end
				if mod.x > 0 and mod.y < 0 then
					mod.message = phrases[2]
				end
				if mod.x < 0 and mod.y < 0 then
					mod.message = phrases[3]
				end
				if mod.x < 0 and mod.y > 0 then
					mod.message = phrases[4]
				end
				--]]
				
			else
			
				mod.message = nil
				mod.choice = nil
				
			end
			
			
			local button = Keyboard.any_released()
			
			if button and mod.enable then
				
				-- button released -> print message
				if button == mod.hotkey then
					
					if mod.message then
						-- only send if not max messages sent in last seconds
						-- mod:echo(os.time())
						if (os.time() - mod.timing[3]) > mod.reset_time then
							Managers.chat:send_chat_message(1, 1, mod.message)
							
							-- save time
							mod.timing[3] = mod.timing[2]
							mod.timing[2] = mod.timing[1]
							mod.timing[1] = os.time()
						else
							mod:echo("You can only send max. 3 messages in 10 seconds")
						end
						
					end
					
					mod.enable = false
					
					
					mod.x = nil
					mod.y = nil
					
				end
				
			end
		
		else
			mod.choice = nil
		end
	end, function(e)
	
	end)
	
	return func( self, ...)

end)

--[[
	Callbacks
--]]


-- makes sure 
mod.on_game_state_changed = function(status, state)
	mod.enable = false
end

-- maybe we need this when providing a sider to adjust sensibility of phrase selection
mod.on_setting_changed = function(setting_name)
	
end



-- DISABLE IN MOD OPTIONS
-- is_first_call - true if called right after mod initialization
mod.on_disabled = function(is_first_call)
	mod:disable_all_hooks()
end

-- ENABLE IN MOD OPTIONS
-- is_first_call - true if called right after mod initialization
-- 		FIRST CALL -> LOAD PHRASES FROM MEMORY
mod.on_enabled = function(is_first_call)

	mod:enable_all_hooks()
	
	
	if is_first_call then
		-- mod:echo("Chat Wheel initialized")
		
		if type(mod:get("hotkey")) == "number" then
			mod.hotkey = mod:get("hotkey")
			mod:echo("ChatWheel is bound to "..string.char(mod.hotkey))
		else
			-- default Y
			mod:echo("ChatWheel started for the first time:")
			mod:echo("default Key: T")
			mod.hotkey = 84
			
			mod:echo("For information on how to change the phrases and the keybinding, check out the item description on the workshop page.")
			
		end
		
		
		if mod:get("1") then
			mod.phrases[1] = mod:get("1")
		end
		if mod:get("2") then
			mod.phrases[2] = mod:get("2")
		end
		if mod:get("3") then
			mod.phrases[3] = mod:get("3")
		end
		if mod:get("4") then
			mod.phrases[4] = mod:get("4")
		end
		if mod:get("5") then
			mod.phrases[5] = mod:get("5")
		end
		if mod:get("6") then
			mod.phrases[6] = mod:get("6")
		end
		if mod:get("7") then
			mod.phrases[7] = mod:get("7")
		end
		if mod:get("8") then
			mod.phrases[8] = mod:get("8")
		end
		
	end
end


--[[
	Initialization
--]]

-- commands to customize the wheel
mod:command("set_phrase", "customize the chat wheel phrases", function(number, ...) mod.set_phrase(number, ...) end)
mod:command("set_keybind", "change the hotkey for the chat wheel", function(number) mod.set_hotkey(number) end)

-- new commands
mod:command("chat_wheel_set_phrase", "customize the chat wheel phrases", function(number, ...) mod.set_phrase(number, ...) end)
mod:command("chat_wheel_set_keybind", "change the hotkey for the chat wheel", function(number) mod.set_hotkey(number) end)

