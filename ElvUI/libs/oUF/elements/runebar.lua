--[[ Element: Runes Bar

 Handle updating and visibility of the Death Knight's Rune indicators.

 Widget

 Runes - An array holding six StatusBar's.

 Sub-Widgets

 .bg - A Texture which functions as a background. It will inherit the color of
       the main StatusBar.

 Notes

 The default StatusBar texture will be applied if the UI widget doesn't have a
             status bar texture or color defined.

 Sub-Widgets Options

 .multiplier - Defines a multiplier, which is used to tint the background based
               on the main widgets R, G and B values. Defaults to 1 if not
               present.

 Examples

   local Runes = {}
   for index = 1, 6 do
      -- Position and size of the rune bar indicators
      local Rune = CreateFrame('StatusBar', nil, self)
      Rune:SetSize(120 / 6, 20)
      Rune:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', index * 120 / 6, 0)
   
      Runes[index] = Rune
   end
   
   -- Register with oUF
   self.Runes = Runes
]]

if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then return end


local parent, ns = ...
local oUF = ns.oUF
local floor = math.floor

oUF.colors.Runes = {
	{1, 0, 0},   -- blood
	{0, .5, 0},  -- unholy
	{0, 1, 1},   -- frost
	{.9, .1, 1}, -- death
}

local runemap = { 1, 2, 5, 6, 3, 4 }

local OnUpdate = function(self, elapsed)
	local duration = self.duration + elapsed
	if(duration >= self.max) then
		return self:SetScript("OnUpdate", nil)
	else
		self.duration = duration
		return self:SetValue(duration)
	end
end

local UpdateType = function(self, event, rid, alt)
	local rune = self.Runes[runemap[rid]]
	local runeType = GetRuneType(rid) or alt
	if not runeType then return; end
	local colors = oUF.colors.Runes[runeType]
	local r, g, b = colors[1], colors[2], colors[3]
	rune:SetStatusBarColor(r, g, b)

	if(rune.bg) then
		local mu = rune.bg.multiplier or 1
		rune.bg:SetVertexColor(r * mu, g * mu, b * mu)
	end
end

local UpdateRune = function(self, event, rid)
	local rune = self.Runes[runemap[rid]]
	if(rune) then
		local start, duration, runeReady = GetRuneCooldown(rid)
		if(runeReady) then
			rune:SetMinMaxValues(0, 1)
			rune:SetValue(1)
			rune:SetScript("OnUpdate", nil)
		elseif(start and duration) then
			rune.duration = GetTime() - start
			rune.max = duration
			rune:SetMinMaxValues(1, duration)
			rune:SetScript("OnUpdate", OnUpdate)
		end
	end
end

local Update = function(self, event)
	for i=1, 6 do
		UpdateRune(self, event, i)
	end
end

local function UpdateAllRuneTypes(self)
	if(self) then
		for i=1, 6 do
			UpdateType(self, nil, i)
		end
	end
end

local ForceUpdate = function(element)
	return Update(element.__owner, 'ForceUpdate')
end

local Enable = function(self, unit)
	local runes = self.Runes
	if(runes and unit == 'player') then
		runes.__owner = self
		runes.ForceUpdate = ForceUpdate

		self:RegisterEvent("RUNE_POWER_UPDATE", UpdateRune, true)
		self:RegisterEvent("RUNE_TYPE_UPDATE", UpdateType, true)	--I have no idea why this won't fire on initial login.
		self:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateAllRuneTypes)
		
		if not runes.UpdateAllRuneTypes then runes.UpdateAllRuneTypes = UpdateAllRuneTypes end;
		
		for i=1, 6 do
			local rune = runes[runemap[i]]
			if(rune:IsObjectType'StatusBar' and not rune:GetStatusBarTexture()) then
				rune:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
			end

			-- From my minor testing this is a okey solution. A full login always remove
			-- the death runes, or at least the clients knowledge about them.
			UpdateType(self, nil, i, floor((runemap[i]+1)/2))
		end

		-- oUF leaves the vehicle events registered on the player frame, so
		-- buffs and such are correctly updated when entering/exiting vehicles.
		--
		-- This however makes the code also show/hide the RuneFrame.
		RuneFrame.Show = RuneFrame.Hide
		RuneFrame:Hide()

		return true
	end
end

local Disable = function(self)
	RuneFrame.Show = nil
	RuneFrame:Show()
	

	local runes = self.Runes
	if(runes) then
		runes:SetScript('OnUpdate', nil)

		self:UnregisterEvent("RUNE_POWER_UPDATE", UpdateRune)
		self:UnregisterEvent("RUNE_TYPE_UPDATE", UpdateType)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", UpdateAllRuneTypes)
	end	
end

oUF:AddElement("Runes", Update, Enable, Disable)
