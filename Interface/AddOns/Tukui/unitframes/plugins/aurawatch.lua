--[[------------------------------------------------------------------------------------------------------
oUF_AuraWatch by Astromech
Please leave comments, suggestions, and bug reports on this addon's WoWInterface page

To setup, create a table with the following entries:
	
	icons
		A table of frames to be used as icons. oUF_Aurawatch does not position
		these frames, so you must do so yourself. Each icon needs a sid entry,
		which is the spell ID of the aura to watch. Table should be set up
		such that values are icon frames, but the keys can be anything.
	missingAlpha
		This is the alpha for icons not present on the unit.
	presentAlpha
		This is the alpha for icons present on the unit.
	onlyShowMissing
		If this is true, oUF_AW will hide icons if they are present on the unit.
		You can specify this in the icons as well for individual auras.
	onlyShowPresent
		If this is true, oUF_AW will hide icons if they are missing on the unit.
		You can specify this in the icons as well for individual auras.
	hideCooldown
		If this is true, oUF_AW will hide the cooldown frame
	fromUnits
		A table of units from which auras can originate from. Have the units be the keys
		and "true" be the values. If this is nil, oUF_AuraWatch will only display
		auras originating from units "player", "pet", and "vehicle."
		You can specify this in the icons as well for individual auras.
	anyUnit
		Set to true for oUF_AW to to show an aura no matter what unit it 
		originates from. This will override any fromUnits setting.
		You can specify this in the icons as well for individual auras.
	PostCreateIcon
		A function to call when an icon is created to modify it, such as adding
		a border or repositioning the count fontstring. Leave as nil to ignore.
		The arguements are: icon, auraSpellID, auraName

Here is an example of how to set oUF_AW up:

	local createAuraWatch = function(self, unit)
		if unit ~= "target" then return end
		-- We only want to create this for the target
		local auras = CreateFrame("Frame", nil, self)
		auras:SetWidth(24)
		auras.SetHeight(128)
		auras:SetPoint("BOTTOM", self, "TOP")
		
		-- A table of spellIDs to create icons for
		-- To find spellIDs, look up a spell on www.wowhead.com and look at the URL
		-- http://www.wowhead.com/?spell=SPELL_ID
		local spellIDs = { ... }
		
		auras.presentAlpha = 1
		auras.expiredAlpha = .7
		auras.PostCreateIcon = myCustomIconSkinnerFunction
		auras.icons = {}
		for i, sid in pairs(spellIDs) do
			local icon = CreateFrame("Frame", nil, auras)
			icon.spellID = sid
			icon:SetWidth(24)
			icon:SetHeight(24)
			icon:SetPoint("BOTTOM", auras, "BOTTOM", 0, 28 * i)
			auras.icons[sid] = icon
		end
		self.AuraWatch = auras
	end
-----------------------------------------------------------------------------------------------------------]]

if not TukuiDB["unitframes"].enable == true then return end

local parent = debugstack():match[[\AddOns\(.-)\]]
local global = GetAddOnMetadata(parent, 'X-oUF')
assert(global, 'X-oUF needs to be defined in the parent add-on.')
local oUF = _G[global]

local UnitBuff, UnitDebuff, UnitGUID = UnitBuff, UnitDebuff, UnitGUID
local GUIDs = {}

local PLAYER_UNITS = {
	player = true,
	vehicle = true,
	pet = true,
}

local setupGUID
do 
	local cache = setmetatable({}, {__type = "k"})

	local frame = CreateFrame"Frame"
	frame:SetScript("OnEvent", function(self, event)
		for k,t in pairs(GUIDs) do
			GUIDs[k] = nil
			for a in pairs(t) do
				t[a] = nil
			end
			cache[t] = true
		end
	end)
	frame:RegisterEvent"PLAYER_REGEN_ENABLED"
	frame:RegisterEvent"PLAYER_ENTERING_WORLD"
	
	function setupGUID(guid)
		local t = next(cache)
		if t then
			cache[t] = nil
		else
			t = {}
		end
		GUIDs[guid] = t
	end
end


local function resetIcon(icon, frame, count, duration, remaining)
	if icon.onlyShowMissing then
		icon:Hide()
	else
		icon:Show()
		if not frame.hideCooldown and duration and duration > 0 then
			icon.cd:SetCooldown(remaining - duration, duration)
			icon.cd:Show()
		else
			icon.cd:Hide()
		end
		icon.count:SetText((count > 1 and count))
		icon.overlay:Hide()
		icon:SetAlpha(frame.presentAlpha)
	end
end

local function expireIcon(icon, frame)
	if icon.onlyShowPresent then
		icon:Hide()
	else
		icon.cd:Hide()
		icon.count:SetText()
		icon:SetAlpha(frame.missingAlpha)
		icon.overlay:Show()
		icon:Show()
	end
end

local found = {}
local function Update(frame, event, unit)
	if frame.unit ~= unit then return end
	local watch = frame.AuraWatch
	local index, icons = 1, watch.watched
	local name, rank, texture, count, type, duration, remaining, caster, key, icon
	local guid = UnitGUID(unit)
	if not GUIDs[guid] then setupGUID(guid) end
	
	for key, icon in pairs(icons) do
		icon:Hide()
	end
	
	while true do
		if index > 40 then
			name, rank, texture, count, type, duration, remaining, caster = UnitDebuff(unit, index-40)
		else
			name, rank, texture, count, type, duration, remaining, caster = UnitBuff(unit, index)
		end
		if not name then 
			if index > 40 then 
				break 
			else 
				index = 40 
			end 
		else
			key = name..texture
			icon = icons[key]
			if icon and (icon.anyUnit or (caster and icon.fromUnits[caster])) then
				resetIcon(icon, watch, count, duration, remaining)
				GUIDs[guid][key] = true
				found[key] = true
			end
		end
		index = index + 1
	end
	
	for key in pairs(GUIDs[guid]) do
		if icons[key] and not found[key] then
			expireIcon(icons[key], watch)
		end
	end
	
	for k in pairs(found) do
		found[k] = nil
	end
end

local function setupIcons(self)

	local frame = self.AuraWatch
	local icons = frame.icons
	frame.watched = {}
	if not frame.missingAlpha then frame.missingAlpha = 0.75 end
	if not frame.presentAlpha then frame.presentAlpha = 1 end
	
	for _,icon in pairs(icons) do
	
		local name, _, image = GetSpellInfo(icon.spellID)
		if not name then error("oUF_AuraWatch error: no spell with "..tostring(icon.spellID).." spell ID exists") end
		icon.name = name
	
		if not icon.cd then
			local cd = CreateFrame("Cooldown", nil, icon)
			cd:SetAllPoints(icon)
			icon.cd = cd
		end

		if not icon.icon then
			local tex = icon:CreateTexture(nil, "BACKGROUND")
			tex:SetAllPoints(icon)
			tex:SetTexture(image)
			icon.icon = tex
		end

		if not icon.count then
			local count = icon:CreateFontString(nil, "OVERLAY")
			count:SetFontObject(NumberFontNormal)
			count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -1, 0)
			icon.count = count
		end

		if not icon.overlay then
			local overlay = icon:CreateTexture(nil, "OVERLAY")
			overlay:SetTexture"Interface\\Buttons\\UI-Debuff-Overlays"
			overlay:SetAllPoints(icon)
			overlay:SetTexCoord(.296875, .5703125, 0, .515625)
			overlay:SetVertexColor(1, 0, 0)
			icon.overlay = overlay
		end

		if icon.onlyShowMissing == nil then
			icon.onlyShowMissing = frame.onlyShowMissing
		end
		if icon.onlyShowPresent == nil then
			icon.onlyShowPresent = frame.onlyShowPresent
		end
		if icon.fromUnits == nil then
			icon.fromUnits = frame.fromUnits or PLAYER_UNITS
		end
		if icon.anyUnit == nil then
			icon.anyUnit = frame.anyUnit
		end
		
		frame.watched[name..image] = icon

		if frame.PostCreateIcon then frame:PostCreateIcon(icon, icon.spellID, name) end
	end
end

local function Enable(self)
	if self.AuraWatch then
		self:RegisterEvent("UNIT_AURA", Update)
		setupIcons(self)
		return true
	else
		return false
	end
end

local function Disable(self)
	if self.AuraWatch then
		self:UnregisterEvent("UNIT_AURA", Update)
		for _,icon in pairs(self.AuraWatch.icons) do
			icon:Hide()
		end
	end
end

oUF:AddElement("AuraWatch", Update, Enable, Disable)
