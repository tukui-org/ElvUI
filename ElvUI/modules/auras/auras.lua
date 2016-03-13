local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local A = E:NewModule('Auras', 'AceHook-3.0', 'AceEvent-3.0');
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions
local GetTime = GetTime
local select, unpack = select, unpack
local floor = math.floor
local format, find, join = string.format, string.find, string.join
--WoW API / Variables
local CreateFrame = CreateFrame
local C_TimerAfter = C_Timer.After
local RegisterStateDriver = RegisterStateDriver
local RegisterAttributeDriver = RegisterAttributeDriver
local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local UnitAura = UnitAura
local GetItemQualityColor = GetItemQualityColor
local GetInventoryItemQuality = GetInventoryItemQuality
local GetInventoryItemTexture = GetInventoryItemTexture
local IsAddOnLoaded = IsAddOnLoaded

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: BuffFrame, ConsolidatedBuffs, TemporaryEnchantFrame, DebuffTypeColor
-- GLOBALS: Minimap, LeftMiniPanel, InterfaceOptionsFrameCategoriesButton12

local Masque = LibStub("Masque", true)
local MasqueGroupBuffs = Masque and Masque:Group("ElvUI", "Buffs")
local MasqueGroupDebuffs = Masque and Masque:Group("ElvUI", "Debuffs")
local StrataFixEnabled

local DIRECTION_TO_POINT = {
	DOWN_RIGHT = "TOPLEFT",
	DOWN_LEFT = "TOPRIGHT",
	UP_RIGHT = "BOTTOMLEFT",
	UP_LEFT = "BOTTOMRIGHT",
	RIGHT_DOWN = "TOPLEFT",
	RIGHT_UP = "BOTTOMLEFT",
	LEFT_DOWN = "TOPRIGHT",
	LEFT_UP = "BOTTOMRIGHT",
}

local DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = 1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = -1,
	RIGHT_DOWN = 1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = -1,
}

local DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = -1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = 1,
	RIGHT_DOWN = -1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = 1,
}

local IS_HORIZONTAL_GROWTH = {
	RIGHT_DOWN = true,
	RIGHT_UP = true,
	LEFT_DOWN = true,
	LEFT_UP = true,
}

function A:UpdateTime(elapsed)
	if(self.offset) then
		local expiration = select(self.offset, GetWeaponEnchantInfo())
		if(expiration) then
			self.timeLeft = expiration / 1e3
		else
			self.timeLeft = 0
		end
	else
		self.timeLeft = self.timeLeft - elapsed
	end

	if(self.nextUpdate > 0) then
		self.nextUpdate = self.nextUpdate - elapsed
		return
	end

	local timerValue, formatID
	timerValue, formatID, self.nextUpdate = E:GetTimeInfo(self.timeLeft, A.db.fadeThreshold)
	self.time:SetFormattedText(("%s%s|r"):format(E.TimeColors[formatID], E.TimeFormats[formatID][1]), timerValue)

	if self.timeLeft > E.db.auras.fadeThreshold then
		E:StopFlash(self)
	else
		E:Flash(self, 1)
	end
end

local function DelaydReSkinBuffs()
	MasqueGroupBuffs:ReSkin()
end

local function DelaydReSkinDebuffs()
	MasqueGroupDebuffs:ReSkin()
end

function A:CreateIcon(button)
	local font = LSM:Fetch("font", self.db.font)

	button.texture = button:CreateTexture(nil, "BORDER")
	button.texture:SetInside()
	button.texture:SetTexCoord(unpack(E.TexCoords))

	button.count = button:CreateFontString(nil, "ARTWORK")
	button.count:Point("BOTTOMRIGHT", -1 + self.db.countXOffset, 1 + self.db.countYOffset)
	button.count:FontTemplate(font, self.db.fontSize, self.db.fontOutline)

	button.time = button:CreateFontString(nil, "ARTWORK")
	button.time:Point("TOP", button, 'BOTTOM', 1 + self.db.timeXOffset, 0 + self.db.timeYOffset)
	button.time:FontTemplate(font, self.db.fontSize, self.db.fontOutline)

	button.highlight = button:CreateTexture(nil, "HIGHLIGHT")
	button.highlight:SetTexture(1, 1, 1, 0.45)
	button.highlight:SetInside()

	E:SetUpAnimGroup(button)

	button:SetScript("OnAttributeChanged", A.OnAttributeChanged)

	local ButtonData = {
		FloatingBG = nil,
		Icon = button.texture,
		Cooldown = nil,
		Flash = nil,
		Pushed = nil,
		Normal = nil,
		Disabled = nil,
		Checked = nil,
		Border = nil,
		AutoCastable = nil,
		Highlight = button.highlight,
		HotKey = nil,
		Count = false,
		Name = nil,
		Duration = false,
		AutoCast = nil,
	}

	local header = button:GetParent()
	local auraType = header:GetAttribute("filter")

	if auraType == "HELPFUL" then
		if MasqueGroupBuffs and E.private.auras.masque.buffs then
			MasqueGroupBuffs:AddButton(button, ButtonData)
			if StrataFixEnabled then
				C_TimerAfter(0.01, DelaydReSkinBuffs) --Fix bug caused by StrataFix.
			end
		else
			button:SetTemplate('Default')
		end
	elseif auraType == "HARMFUL" then
		if MasqueGroupDebuffs and E.private.auras.masque.debuffs then
			MasqueGroupDebuffs:AddButton(button, ButtonData)
			if StrataFixEnabled then
				C_TimerAfter(0.01, DelaydReSkinDebuffs) --Fix bug caused by StrataFix.
			end
		else
			button:SetTemplate('Default')
		end
	end
end

function A:UpdateAura(button, index)
	local filter = button:GetParent():GetAttribute('filter')
	local unit = button:GetParent():GetAttribute("unit")
	local name, rank, texture, count, dtype, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff = UnitAura(unit, index, filter)

	if(name) then
		if(duration > 0 and expirationTime) then
			local timeLeft = expirationTime - GetTime()
			if(not button.timeLeft) then
				button.timeLeft = timeLeft
				button:SetScript("OnUpdate", A.UpdateTime)
			else
				button.timeLeft = timeLeft
			end

			button.nextUpdate = -1
			A.UpdateTime(button, 0)
		else
			button.timeLeft = nil
			button.time:SetText("")
			button:SetScript("OnUpdate", nil)
		end

		if(count > 1) then
			button.count:SetText(count)
		else
			button.count:SetText("")
		end

		if filter == "HARMFUL" then
			local color = DebuffTypeColor[dtype or ""]
			button:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end

		button.texture:SetTexture(texture)
		button.offset = nil
	end
end

function A:UpdateTempEnchant(button, index)
	local quality = GetInventoryItemQuality("player", index)
	button.texture:SetTexture(GetInventoryItemTexture("player", index))

	-- time left
	local offset = 2
	local weapon = button:GetName():sub(-1)
	if weapon:match("2") then
		offset = 6
	end

	if(quality) then
		button:SetBackdropBorderColor(GetItemQualityColor(quality))
	end

	local expirationTime = select(offset, GetWeaponEnchantInfo())
	if(expirationTime) then
		button.offset = offset
		button:SetScript("OnUpdate", A.UpdateTime)
		button.nextUpdate = -1
		A.UpdateTime(button, 0)
	else
		button.timeLeft = nil
		button.offset = nil
		button:SetScript("OnUpdate", nil)
		button.time:SetText("")
	end
end

function A:OnAttributeChanged(attribute, value)
	if(attribute == "index") then
		A:UpdateAura(self, value)
	elseif(attribute == "target-slot") then
		A:UpdateTempEnchant(self, value)
	end
end

function A:UpdateHeader(header)
	if(not E.private.auras.enable) then return end
	local db = self.db.debuffs
	if header:GetAttribute('filter') == 'HELPFUL' then
		db = self.db.buffs
		header:SetAttribute("consolidateTo", self.db.consolidatedBuffs.enable == true and E.private.general.minimap.enable == true and 1 or 0)
		header:SetAttribute('weaponTemplate', ("ElvUIAuraTemplate%d"):format(db.size))
	end

	header:SetAttribute("separateOwn", db.seperateOwn)
	header:SetAttribute("sortMethod", db.sortMethod)
	header:SetAttribute("sortDirection", db.sortDir)
	header:SetAttribute("maxWraps", db.maxWraps)
	header:SetAttribute("wrapAfter", db.wrapAfter)

	header:SetAttribute("point", DIRECTION_TO_POINT[db.growthDirection])

	if(IS_HORIZONTAL_GROWTH[db.growthDirection]) then
		header:SetAttribute("minWidth", ((db.wrapAfter == 1 and 0 or db.horizontalSpacing) + db.size) * db.wrapAfter)
		header:SetAttribute("minHeight", (db.verticalSpacing + db.size) * db.maxWraps)
		header:SetAttribute("xOffset", DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[db.growthDirection] * (db.horizontalSpacing + db.size))
		header:SetAttribute("yOffset", 0)
		header:SetAttribute("wrapXOffset", 0)
		header:SetAttribute("wrapYOffset", DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[db.growthDirection] * (db.verticalSpacing + db.size))
	else
		header:SetAttribute("minWidth", (db.horizontalSpacing + db.size) * db.maxWraps)
		header:SetAttribute("minHeight", ((db.wrapAfter == 1 and 0 or db.verticalSpacing) + db.size) * db.wrapAfter)
		header:SetAttribute("xOffset", 0)
		header:SetAttribute("yOffset", DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[db.growthDirection] * (db.verticalSpacing + db.size))
		header:SetAttribute("wrapXOffset", DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[db.growthDirection] * (db.horizontalSpacing + db.size))
		header:SetAttribute("wrapYOffset", 0)
	end

	header:SetAttribute("template", ("ElvUIAuraTemplate%d"):format(db.size))
	local index = 1
	local child = select(index, header:GetChildren())
	while(child) do
		if((floor(child:GetWidth() * 100 + 0.5) / 100) ~= db.size) then
			child:SetSize(db.size, db.size)
		end

		if(child.time) then
			local font = LSM:Fetch("font", self.db.font)
			child.time:ClearAllPoints()
			child.time:Point("TOP", child, 'BOTTOM', 1 + self.db.timeXOffset, 0 + self.db.timeYOffset)
			child.time:FontTemplate(font, self.db.fontSize, self.db.fontOutline)

			child.count:ClearAllPoints()
			child.count:Point("BOTTOMRIGHT", -1 + self.db.countXOffset, 0 + self.db.countYOffset)
			child.count:FontTemplate(font, self.db.fontSize, self.db.fontOutline)
		end

		--Blizzard bug fix, icons arent being hidden when you reduce the amount of maximum buttons
		if(index > (db.maxWraps * db.wrapAfter) and child:IsShown()) then
			child:Hide()
		end

		index = index + 1
		child = select(index, header:GetChildren())
	end

	if MasqueGroupBuffs and E.private.auras.masque.buffs then MasqueGroupBuffs:ReSkin() end
	if MasqueGroupDebuffs and E.private.auras.masque.debuffs then MasqueGroupDebuffs:ReSkin() end
end

function A:CreateAuraHeader(filter)
	local name = "ElvUIPlayerDebuffs"
	if filter == "HELPFUL" then
		name = "ElvUIPlayerBuffs"
	end

	local header = CreateFrame("Frame", name, E.UIParent, "SecureAuraHeaderTemplate")
	header:SetClampedToScreen(true)
	header:SetAttribute("unit", "player")
	header:SetAttribute("filter", filter)
	RegisterStateDriver(header, "visibility", "[petbattle] hide; show")
	RegisterAttributeDriver(header, "unit", "[vehicleui] vehicle; player")

	if filter == "HELPFUL" then
		header:SetAttribute('consolidateDuration', -1)
		header:SetAttribute("includeWeapons", 1)
	end

	A:UpdateHeader(header)
	header:Show()

	return header
end

function A:Initialize()
	self:Construct_ConsolidatedBuffs()

	if(E.private.auras.disableBlizzard) then
		BuffFrame:Kill()
		ConsolidatedBuffs:Kill()
		TemporaryEnchantFrame:Kill();
		InterfaceOptionsFrameCategoriesButton12:SetScale(0.0001)
	end

	if(not E.private.auras.enable) then return end

	self.db = E.db.auras

	self.BuffFrame = self:CreateAuraHeader("HELPFUL")
	self.BuffFrame:Point("TOPRIGHT", MMHolder, "TOPLEFT", -(6 + E.Border), -E.Border - E.Spacing)
	E:CreateMover(self.BuffFrame, "BuffsMover", L["Player Buffs"])

	self.DebuffFrame = self:CreateAuraHeader("HARMFUL")
	self.DebuffFrame:Point("BOTTOMRIGHT", MMHolder, "BOTTOMLEFT", -(6 + E.Border), E.Border + E.Spacing)
	E:CreateMover(self.DebuffFrame, "DebuffsMover", L["Player Debuffs"])

	if Masque then
		if MasqueGroupBuffs then A.BuffsMasqueGroup = MasqueGroupBuffs end
		if MasqueGroupDebuffs then A.DebuffsMasqueGroup = MasqueGroupDebuffs end
	end
end

--StrataFix causes the icon to appear above the border texture
--We need to call :ReSkin() when icons are created, but we only do it if StrataFix is enabled
local function CheckForStrataFix(self, event)
	if not E.private.auras.enable then return; end
	if IsAddOnLoaded("StrataFix") then
		StrataFixEnabled = true
	end
	self:UnregisterEvent(event)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", CheckForStrataFix)

E:RegisterModule(A:GetName())