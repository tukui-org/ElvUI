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

 Hooks

 Override(self)           - Used to completely override the internal update
                            function. Removing the table key entry will make the
                            element fall-back to its internal function again.

]]

if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then return end
local isBetaClient = select(4, GetBuildInfo()) >= 70000

local parent, ns = ...
local oUF = ns.oUF

local runemap, UpdateType
if(not isBetaClient) then
	oUF.colors.runes = {
		{1, 0, 0},   -- blood
		{0, .5, 0},  -- unholy
		{0, 1, 1},   -- frost
		{.9, .1, 1}, -- death
	}

	runemap = { 1, 2, 5, 6, 3, 4 }

	UpdateType = function(self, event, rid, alt)
		local runes = self.Runes
		local rune = runes[runemap[rid]]
		local colors = self.colors.runes[GetRuneType(rid) or alt]
		local r, g, b = colors[1], colors[2], colors[3]

		rune:SetStatusBarColor(r, g, b)

		if(rune.bg) then
			local mu = rune.bg.multiplier or 1
			rune.bg:SetVertexColor(r * mu, g * mu, b * mu)
		end

		if(runes.PostUpdateType) then
			return runes:PostUpdateType(rune, rid, alt)
		end
	end
end

local OnUpdate = function(self, elapsed)
	local duration = self.duration + elapsed
	if(duration >= self.max) then
		return self:SetScript("OnUpdate", nil)
	else
		self.duration = duration
		return self:SetValue(duration)
	end
end

local Update = function(self, event, rid)
	local runes = self.Runes
	local rune = runes[isBetaClient and rid or runemap[rid]]
	if(not rune) then return end

	local start, duration, runeReady
	if(UnitHasVehicleUI'player') then
		rune:Hide()
	else
		start, duration, runeReady = GetRuneCooldown(rid)
		if(not start) then
			-- As of 6.2.0 GetRuneCooldown returns nil values when zoning
			return
		end

		if(runeReady) then
			rune:SetMinMaxValues(0, 1)
			rune:SetValue(1)
			rune:SetScript("OnUpdate", nil)
		else
			rune.duration = GetTime() - start
			rune.max = duration
			rune:SetMinMaxValues(1, duration)
			rune:SetScript("OnUpdate", OnUpdate)
		end

		rune:Show()
	end

	if(runes.PostUpdate) then
		return runes:PostUpdate(rune, rid, start, duration, runeReady)
	end
end

local Path = function(self, event, ...)
	local UpdateMethod = self.Runes.Override or Update
	if(event == 'RUNE_POWER_UPDATE') then
		return UpdateMethod(self, event, ...)
	else
		for index = 1, 6 do
			UpdateMethod(self, event, index)
		end
	end
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate')
end

local Enable = function(self, unit)
	local runes = self.Runes
	if(runes and unit == 'player') then
		runes.__owner = self
		runes.ForceUpdate = ForceUpdate

		for i=1, 6 do
			local rune = runes[isBetaClient and i or runemap[i]]
			if(rune:IsObjectType'StatusBar' and not rune:GetStatusBarTexture()) then
				rune:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]

				if(isBetaClient) then
					local colors = oUF.colors.power.RUNES
					rune:SetStatusBarColor(colors[1], colors[2], colors[3])

					if(rune.bg) then
						local mu = rune.bg.multiplier or 1
						rune.bg:SetVertexColor(r * mu, g * mu, b * mu)
					end
				end
			end

			if(not isBetaClient) then
				-- From my minor testing this is a okey solution. A full login always remove
				-- the death runes, or at least the clients knowledge about them.
				UpdateType(self, nil, i, math.floor((i+1)/2))
			end
		end

		self:RegisterEvent("RUNE_POWER_UPDATE", Path, true)

		if(not isBetaClient) then
			self:RegisterEvent("RUNE_TYPE_UPDATE", UpdateType, true)
		end

		return true
	end
end

local Disable = function(self)
	self:UnregisterEvent("RUNE_POWER_UPDATE", Path)

	if(not isBetaClient) then
		self:UnregisterEvent("RUNE_TYPE_UPDATE", UpdateType)
	end
end

oUF:AddElement("Runes", Path, Enable, Disable)
