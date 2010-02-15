--[[ Runebar:
	Authors: Zariel, Haste

	Usage: expects self.Runes to be a frame, setup and positiononed by the layout
	itself, it also requires self.Runes through 6 to be a statusbar again setup by
	the user.

	Options

	Required:
	.height: (int)          Height of the bar
	.width: (int)           Width of each bar

	Optional:
	.spacing: (float)       Spacing between each bar
	.anchor: (string)       Initial anchor to the parent rune frame
	.growth: (string)       LEFT or RIGHT or UP or DOWN
	.runeMap: (table)       Set custom order, only remapped runes are required.
	                        Example: .runeMap = {[3] = 5, [4] = 6}
]]

if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then return end

local parent, ns = ...
local oUF = ns.oUF

oUF.colors.runes = {
	{1, 0, 0};
	{0, .5, 0};
	{0, 1, 1};
	{.9, .1, 1};
}

local OnUpdate = function(self, elapsed)
	local duration = self.duration + elapsed
	if(duration >= self.max) then
		return self:SetScript("OnUpdate", nil)
	else
		self.duration = duration
		return self:SetValue(duration)
	end
end

local UpdateType = function(self, event, rune, alt)
	local colors = self.colors.runes[GetRuneType(rune) or alt]
	local rune = self.Runes[rune]
	local r, g, b = colors[1], colors[2], colors[3]

	rune:SetStatusBarColor(r, g, b)

	if(rune.bg) then
		local mu = rune.bg.multiplier or 1
		rune.bg:SetVertexColor(r * mu, g * mu, b * mu)
	end
end

local Update = function(self, event, rid, usable)
	local rune = self.Runes[rid]
	if(rune) then
		local start, duration, runeReady = GetRuneCooldown(rune:GetID())
		if(runeReady) then
			rune:SetValue(duration)
			rune:SetScript("OnUpdate", nil)
		else
			rune.duration = GetTime() - start
			rune.max = duration
			rune:SetMinMaxValues(1, duration)
			rune:SetScript("OnUpdate", OnUpdate)
		end
	end
end

local Enable = function(self, unit)
	local runes = self.Runes
	if(runes and unit == 'player') then
		for i=1, 6 do
			local rune = runes[i]
			rune:SetID(i)
			-- From my minor testing this is a okey solution. A full login always remove
			-- the death runes, or at least the clients knowledge about them.
			UpdateType(self, nil, i, math.floor((i+1)/2))

			if(not rune:GetStatusBarTexture()) then
				rune:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
			end
		end

		self:RegisterEvent("RUNE_POWER_UPDATE", Update)
		self:RegisterEvent("RUNE_TYPE_UPDATE", UpdateType)

		runes:Show()
		RuneFrame:Hide()

		-- さあ兄様、どうぞ姉様に
		local runeMap = runes.runeMap
		if(runeMap) then
			for f, t in pairs(runeMap) do
				runes[f], runes[t] = runes[t], runes[f]
			end
		else
			runes[3], runes[5] = runes[5], runes[3]
			runes[4], runes[6] = runes[6], runes[4]
		end

		-- XXX: Fix this for 1.4.
		-- I really hate how this is done:
		local width = runes.width
		local height = runes.height
		local spacing = runes.spacing or 0
		local anchor = runes.anchor or "BOTTOMLEFT"
		local growthX, growthY = 0, 0

		if runes.growth == "LEFT" then
			growthX = - 1
		elseif runes.growth == "DOWN" then
			growthY = - 1
		elseif runes.growth == "UP" then
			growthY = 1
		else
			growthX = 1
		end

		for i=1, 6 do
			local bar = runes[i]
			if(bar) then
				bar:SetWidth(width)
				bar:SetHeight(height)

				bar:SetPoint(anchor, runes, anchor, (i - 1) * (width + spacing) * growthX, (i - 1) * (height + spacing) * growthY)
			end
		end

		-- ええ、兄様。
		if(runeMap) then
			for f, t in pairs(runeMap) do
				runes[f], runes[t] = runes[t], runes[f]
			end
		else
			runes[3], runes[5] = runes[5], runes[3]
			runes[4], runes[6] = runes[6], runes[4]
		end

		return true
	end
end

local Disable = function(self)
	self.Runes:Hide()
	RuneFrame:Show()

	self:UnregisterEvent("RUNE_POWER_UPDATE", Update)
	self:UnregisterEvent("RUNE_TYPE_UPDATE", UpdateType)
end

oUF:AddElement("Runes", Update, Enable, Disable)
