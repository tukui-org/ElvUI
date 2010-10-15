if not TukuiCF["actionbar"].enable == true then return end

---------------------------------------------------------------------------
-- Setup Main Action Bar.
-- Now used for stances, Bonus, Vehicle at the same time.
-- Since t12, it's also working for druid cat stealth. (a lot requested)
---------------------------------------------------------------------------

local bar = CreateFrame("Frame", "TukuiMainMenuBar", TukuiActionBarBackground, "SecureHandlerStateTemplate")
bar:ClearAllPoints()
bar:SetAllPoints(TukuiActionBarBackground)

--[[ 
	Bonus bar classes id

	DRUID: Caster: 0, Cat: 1, Tree of Life: 2, Bear: 3, Moonkin: 4
	WARRIOR: Battle Stance: 1, Defensive Stance: 2, Berserker Stance: 3 
	ROGUE: Normal: 0, Stealthed: 1
	PRIEST: Normal: 0, Shadowform: 1
	
	When Possessing a Target: 5
]]--

local Page = {
	["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] %s; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	["WARRIOR"] = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
	["PRIEST"] = "[bonusbar:1] 7;",
	["ROGUE"] = "[bonusbar:1] 7; [form:3] 7;",
	["DEFAULT"] = "[bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6; [bonusbar:5] 11;",
}

local function GetBar()
	local condition = Page["DEFAULT"]
	local class = TukuiDB.myclass
	local page = Page[class]
	if page then
		if class == "DRUID" then
			-- Handles prowling, prowling has no real stance, so this is a hack which utilizes the Tree of Life bar for non-resto druids.
			if IsSpellKnown(33891) then -- Tree of Life form
				page = page:format(7)
			else
				page = page:format(8)
			end
		end
		condition = condition.." "..page
	end
	condition = condition.." 1"
	return condition
end

bar:RegisterEvent("PLAYER_LOGIN")
bar:RegisterEvent("PLAYER_ENTERING_WORLD")
bar:RegisterEvent("PLAYER_TALENT_UPDATE")
bar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
bar:RegisterEvent("KNOWN_CURRENCY_TYPES_UPDATE")
bar:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
bar:RegisterEvent("BAG_UPDATE")
bar:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		local button
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			button = _G["ActionButton"..i]
			self:SetFrameRef("ActionButton"..i, button)
		end	

		self:Execute([[
			buttons = table.new()
			for i = 1, 12 do
				table.insert(buttons, self:GetFrameRef("ActionButton"..i))
			end
		]])

		self:SetAttribute("_onstate-page", [[ 
			for i, button in ipairs(buttons) do
				button:SetAttribute("actionpage", tonumber(newstate))
			end
		]])
		
		RegisterStateDriver(self, "page", GetBar())
	elseif event == "PLAYER_ENTERING_WORLD" then
		MainMenuBar_UpdateKeyRing()
		local button
		for i = 1, 12 do
			button = _G["ActionButton"..i]
			button:SetSize(TukuiDB.buttonsize, TukuiDB.buttonsize)
			button:ClearAllPoints()
			button:SetParent(TukuiMainMenuBar)
			if i == 1 then
				button:SetPoint("BOTTOMLEFT", TukuiMainMenuBar, TukuiDB.Scale(4), TukuiDB.Scale(4))
			else
				local previous = _G["ActionButton"..i-1]
				button:SetPoint("LEFT", previous, "RIGHT", TukuiDB.buttonspacing, 0)
			end
		end
	elseif event == "PLAYER_TALENT_UPDATE" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
		if not InCombatLockdown() then -- Just to be safe
			RegisterStateDriver(self, "page", GetBar())
			-- Due to some odd reason these bars (MultiBarRight, MultiBarLeft) are changing position after you spent a talent point, and switch spec,
			-- I couldn't watch the exact event that does it even by using ':RegisterAllEvents()', until I'll figure it out, here is an awful hack. 
			if event == "ACTIVE_TALENT_GROUP_CHANGED" then 
				local t = 0
				self:SetScript("OnUpdate", function(self, elapsed)
					t = t + elapsed
					MainMenuBar:Hide()
					UIParent_ManageFramePositions()
					if t > 5 then
						t = 0
						self:SetScript("OnUpdate", nil)
					end
				end)
			end
		end
	else
		MainMenuBar_OnEvent(self, event, ...)
	end
end)