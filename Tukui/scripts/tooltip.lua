-- credits : Aezay (TipTac) and Caellian for some parts of code.

local db = TukuiCF["tooltip"]
if not db.enable then return end

local TukuiTooltip = CreateFrame("Frame", nil, UIParent)

local _G = getfenv(0)

local GameTooltip, GameTooltipStatusBar = _G["GameTooltip"], _G["GameTooltipStatusBar"]

local gsub, find, format = string.gsub, string.find, string.format

local Tooltips = {GameTooltip,ItemRefTooltip,ShoppingTooltip1,ShoppingTooltip2,ShoppingTooltip3,WorldMapTooltip}

local linkTypes = {item = true, enchant = true, spell = true, quest = true, unit = true, talent = true, achievement = true, glyph = true}

local classification = {
	worldboss = "|cffAF5050Boss|r",
	rareelite = "|cffAF5050+ Rare|r",
	elite = "|cffAF5050+|r",
	rare = "|cffAF5050Rare|r",
}
 	
local NeedBackdropBorderRefresh = false

local yOffset = 0
local xOffset = 0

yOffset = yOffset + TukuiCF["tooltip"].yOfs
xOffset = xOffset + TukuiCF["tooltip"].xOfs


--Check if our embed right addon is shown
local function CheckAddOnShown()
	if TukuiDB.ChatRightShown == true then
		return true
	elseif TukuiCF["general"].embedright == "Omen" and IsAddOnLoaded("Omen") and OmenAnchor then
		if OmenAnchor:IsShown() then
			return true
		else
			return false
		end
	elseif TukuiCF["general"].embedright == "Recount" and IsAddOnLoaded("Recount") and Recount_MainWindow then
		if Recount_MainWindow:IsShown() then
			return true
		else
			return false
		end
	elseif  TukuiCF["general"].embedright ==  "Skada" and IsAddOnLoaded("Skada") and SkadaBarWindowSkada then
		if SkadaBarWindowSkada:IsShown() then
			return true
		else
			return false
		end
	else
		return false
	end
end

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
	if db.cursor == true then
		self:SetOwner(parent, "ANCHOR_CURSOR")	
	else
		self:SetOwner(parent, "ANCHOR_NONE")
		self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -15+xOffset, TukuiDB.Scale(42+yOffset))	
	end
	self.default = 1
end)

GameTooltip:HookScript("OnUpdate",function(self, ...)
	local inInstance, instanceType = IsInInstance()
	if self:GetAnchorType() == "ANCHOR_CURSOR" and NeedBackdropBorderRefresh == true and db.cursor ~= true then
		-- h4x for world object tooltip border showing last border color 
		-- or showing background sometime ~blue :x
		NeedBackdropBorderRefresh = false
		self:SetBackdropColor(unpack(TukuiCF.media.backdropfadecolor))
		self:SetBackdropBorderColor(unpack(TukuiCF.media.bordercolor))
	elseif self:GetAnchorType() == "ANCHOR_NONE" then
		self:ClearAllPoints()
		if InCombatLockdown() and db.hidecombat == true and (TukuiCF["tooltip"].hidecombatraid == true and inInstance and (instanceType == "raid")) then
			self:Hide()
		elseif InCombatLockdown() and db.hidecombat == true and TukuiCF["tooltip"].hidecombatraid == false then
			self:Hide()
		else
			if TukuiCF["others"].enablebag == true and StuffingFrameBags and StuffingFrameBags:IsShown() and xOffset == 0 and yOffset == 0 then
				self:SetPoint("BOTTOMRIGHT", StuffingFrameBags, "TOPRIGHT", -1, TukuiDB.Scale(18))	
			else
				if CheckAddOnShown() == true and xOffset == 0 and yOffset == 0 then
					if TukuiCF["chat"].showbackdrop == true and TukuiDB.ChatRightShown == true then
						self:SetPoint("BOTTOMRIGHT", RDummyFrame, "TOPRIGHT", -1, TukuiDB.Scale(42))	
					else
						self:SetPoint("BOTTOMRIGHT", RDummyFrame, "TOPRIGHT", -1, TukuiDB.Scale(18))		
					end	
				else
					self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -15+xOffset, TukuiDB.Scale(42+yOffset))	
				end
			end
		end
	end
end)

local function Hex(color)
	return string.format('|cff%02x%02x%02x', color.r * 255, color.g * 255, color.b * 255)
end

local function GetColor(unit)
	if(UnitIsPlayer(unit) and not UnitHasVehicleUI(unit)) then
		local _, class = UnitClass(unit)
		local color = RAID_CLASS_COLORS[class]
		if not color then return end -- sometime unit too far away return nil for color :(
		local r,g,b = color.r, color.g, color.b
		return Hex(color), r, g, b	
	else
		local color = FACTION_BAR_COLORS[UnitReaction(unit, "player")]
		if not color then return end -- sometime unit too far away return nil for color :(
		local r,g,b = color.r, color.g, color.b		
		return Hex(color), r, g, b		
	end
end

-- update HP value on status bar
GameTooltipStatusBar:SetScript("OnValueChanged", function(self, value)
	if not value then
		return
	end
	local min, max = self:GetMinMaxValues()
	
	if (value < min) or (value > max) then
		return
	end
	local _, unit = GameTooltip:GetUnit()
	
	-- fix target of target returning nil
	if (not unit) then
		local GMF = GetMouseFocus()
		unit = GMF and GMF:GetAttribute("unit")
	end

	if not self.text then
		self.text = self:CreateFontString(nil, "OVERLAY")
		self.text:SetPoint("CENTER", GameTooltipStatusBar, 0, TukuiDB.Scale(-3))
		self.text:SetFont(TukuiCF["media"].font, 12, "THINOUTLINE")
		self.text:Show()
		if unit then
			min, max = UnitHealth(unit), UnitHealthMax(unit)
			local hp = TukuiDB.ShortValue(min).." / "..TukuiDB.ShortValue(max)
			if UnitIsGhost(unit) then
				self.text:SetText(tukuilocal.unitframes_ouf_ghost)
			elseif min == 0 or UnitIsDead(unit) or UnitIsGhost(unit) then
				self.text:SetText(tukuilocal.unitframes_ouf_dead)
			else
				self.text:SetText(hp)
			end
		end
	else
		if unit then
			min, max = UnitHealth(unit), UnitHealthMax(unit)
			self.text:Show()
			local hp = TukuiDB.ShortValue(min).." / "..TukuiDB.ShortValue(max)
			if min == 0 or min == 1 then
				self.text:SetText(tukuilocal.unitframes_ouf_dead)
			else
				self.text:SetText(hp)
			end
		else
			self.text:Hide()
		end
	end
end)

local healthBar = GameTooltipStatusBar
healthBar:ClearAllPoints()
healthBar:SetHeight(TukuiDB.Scale(5))
healthBar:SetPoint("TOPLEFT", healthBar:GetParent(), "BOTTOMLEFT", TukuiDB.Scale(2), TukuiDB.Scale(-5))
healthBar:SetPoint("TOPRIGHT", healthBar:GetParent(), "BOTTOMRIGHT", -TukuiDB.Scale(2), TukuiDB.Scale(-5))
healthBar:SetStatusBarTexture(TukuiCF.media.normTex)


local healthBarBG = CreateFrame("Frame", "StatusBarBG", healthBar)
healthBarBG:SetFrameLevel(healthBar:GetFrameLevel() - 1)
healthBarBG:SetPoint("TOPLEFT", -TukuiDB.Scale(2), TukuiDB.Scale(2))
healthBarBG:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), -TukuiDB.Scale(2))
TukuiDB.SetTemplate(healthBarBG)
healthBarBG:SetBackdropColor(unpack(TukuiCF.media.backdropfadecolor))

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
	local lines = self:NumLines()
	local GMF = GetMouseFocus()
	local unit = (select(2, self:GetUnit())) or (GMF and GMF:GetAttribute("unit"))
	
	-- A mage's mirror images sometimes doesn't return a unit, this would fix it
	if (not unit) and (UnitExists("mouseover")) then
		unit = "mouseover"
	end
	
	-- Sometimes when you move your mouse quicky over units in the worldframe, we can get here without a unit
	if not unit then self:Hide() return end
	
	-- for hiding tooltip on unitframes
	if (self:GetOwner() ~= UIParent and db.hideuf) then self:Hide() return end

	if self:GetOwner() ~= UIParent and unit then
		self:ClearAllPoints()
		if InCombatLockdown() and db.hidecombat == true and (TukuiCF["tooltip"].hidecombatraid == true and inInstance and (instanceType == "raid")) then
			self:Hide()
			return
		elseif InCombatLockdown() and db.hidecombat == true and TukuiCF["tooltip"].hidecombatraid == false then
			self:Hide()
			return
		else
			if TukuiCF["others"].enablebag == true and StuffingFrameBags and StuffingFrameBags:IsShown() and xOffset == 0 and yOffset == 0 then
				self:SetPoint("BOTTOMRIGHT", StuffingFrameBags, "TOPRIGHT", -1, TukuiDB.Scale(18))	
			else
				if CheckAddOnShown() == true and xOffset == 0 and yOffset == 0 then
					if TukuiCF["chat"].showbackdrop == true and TukuiDB.ChatRightShown == true then
						self:SetPoint("BOTTOMRIGHT", RDummyFrame, "TOPRIGHT", -1, TukuiDB.Scale(42))	
					else
						self:SetPoint("BOTTOMRIGHT", RDummyFrame, "TOPRIGHT", -1, TukuiDB.Scale(18))		
					end
				else
					self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -15+xOffset, TukuiDB.Scale(42+yOffset))	
				end
			end
		end
	end	
	
	-- A "mouseover" unit is better to have as we can then safely say the tip should no longer show when it becomes invalid.
	if (UnitIsUnit(unit,"mouseover")) then
		unit = "mouseover"
	end

	local race = UnitRace(unit)
	local class = UnitClass(unit)
	local level = UnitLevel(unit)
	local guild = GetGuildInfo(unit)
	local name, realm = UnitName(unit)
	local crtype = UnitCreatureType(unit)
	local classif = UnitClassification(unit)
	local title = UnitPVPName(unit)
	local r, g, b = GetQuestDifficultyColor(level).r, GetQuestDifficultyColor(level).g, GetQuestDifficultyColor(level).b

	local color = GetColor(unit)	
	if not color then color = "|CFFFFFFFF" end -- just safe mode for when GetColor(unit) return nil for unit too far away

	_G["GameTooltipTextLeft1"]:SetFormattedText("%s%s%s", color, title or name, realm and realm ~= "" and " - "..realm.."|r" or "|r")

	if(UnitIsPlayer(unit)) then
		if UnitIsAFK(unit) then
			self:AppendText((" %s"):format(CHAT_FLAG_AFK))
		elseif UnitIsDND(unit) then 
			self:AppendText((" %s"):format(CHAT_FLAG_DND))
		end

		local offset = 2
		if guild then
			local guildName, guildRankName, guildRankIndex = GetGuildInfo(unit);
			if guildRankName then
			-- can't use setformated text because some assholes have % signs in their guild ranks
				_G["GameTooltipTextLeft2"]:SetText("<|cffFFD700"..GetGuildInfo(unit).."|r> [|cffFFD700"..guildRankName.."|r]")
			else
				_G["GameTooltipTextLeft2"]:SetFormattedText("<|cffFFD700%s|r>", GetGuildInfo(unit))
			end
			offset = offset + 1
		end

		for i= offset, lines do
			if(_G["GameTooltipTextLeft"..i]:GetText():find("^"..LEVEL)) then
				_G["GameTooltipTextLeft"..i]:SetFormattedText("|cff%02x%02x%02x%s|r %s %s%s", r*255, g*255, b*255, level > 0 and level or "??", race, color, class.."|r")
				break
			end
		end
	else
		for i = 2, lines do
			if((_G["GameTooltipTextLeft"..i]:GetText():find("^"..LEVEL)) or (crtype and _G["GameTooltipTextLeft"..i]:GetText():find("^"..crtype))) then
				_G["GameTooltipTextLeft"..i]:SetFormattedText("|cff%02x%02x%02x%s|r%s %s", r*255, g*255, b*255, classif ~= "worldboss" and level ~= 0 and level or "", classification[classif] or "", crtype or "")
				break
			end
		end
	end

	local pvpLine
	for i = 1, lines do
		local text = _G["GameTooltipTextLeft"..i]:GetText()
		if text and text == PVP_ENABLED then
			pvpLine = _G["GameTooltipTextLeft"..i]
			pvpLine:SetText()
			break
		end
	end

	-- ToT line
	if UnitExists(unit.."target") and unit~="player" then
		local hex, r, g, b = GetColor(unit.."target")
		if not r and not g and not b then r, g, b = 1, 1, 1 end
		GameTooltip:AddLine(UnitName(unit.."target"), r, g, b)
	end
	
	-- Sometimes this wasn't getting reset, the fact a cleanup isn't performed at this point, now that it was moved to "OnTooltipCleared" is very bad, so this is a fix
	self.fadeOut = nil
end)

local Colorize = function(self)
	local GMF = GetMouseFocus()
	local unit = (select(2, self:GetUnit())) or (GMF and GMF:GetAttribute("unit"))
		
	local reaction = unit and UnitReaction(unit, "player")
	local player = unit and UnitIsPlayer(unit)
	local tapped = unit and UnitIsTapped(unit)
	local tappedbyme = unit and UnitIsTappedByPlayer(unit)
	local connected = unit and UnitIsConnected(unit)
	local dead = unit and UnitIsDead(unit)
	

	if (reaction) and (tapped and not tappedbyme or not connected or dead) then
		r, g, b = 0.55, 0.57, 0.61
		self:SetBackdropBorderColor(r, g, b)
		healthBarBG:SetBackdropBorderColor(r, g, b)
		healthBar:SetStatusBarColor(r, g, b)
	elseif player and not TukuiCF["tooltip"].colorreaction == true then
		local class = select(2, UnitClass(unit))
		if TukuiCF.unitframes.enable == true then
			local c = TukuiDB.oUF_colors.class[class]
			if c then
				r, g, b = c[1], c[2], c[3]
			end
		else
			r, g, b = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b
		end
		self:SetBackdropBorderColor(r, g, b)
		healthBarBG:SetBackdropBorderColor(r, g, b)
		healthBar:SetStatusBarColor(r, g, b)
	elseif reaction then
		if TukuiCF.unitframes.enable == true then
			local c = TukuiDB.oUF_colors.reaction[reaction]
			r, g, b = c[1], c[2], c[3]
		else
			r, g, b = FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b
		end
		self:SetBackdropBorderColor(r, g, b)
		healthBarBG:SetBackdropBorderColor(r, g, b)
		healthBar:SetStatusBarColor(r, g, b)
	else
		local _, link = self:GetItem()
		local quality = link and select(3, GetItemInfo(link))
		if quality and quality >= 2 then
			local r, g, b = GetItemQualityColor(quality)
			self:SetBackdropBorderColor(r, g, b)
		else
			self:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
			healthBarBG:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
			healthBar:SetStatusBarColor(unpack(TukuiCF["media"].bordercolor))
		end
	end	
	-- need this
	NeedBackdropBorderRefresh = true
end

local SetStyle = function(self)
	TukuiDB.SetTemplate(self)
	self:SetBackdropColor(unpack(TukuiCF.media.backdropfadecolor))
	Colorize(self)
end

TukuiTooltip:RegisterEvent("PLAYER_ENTERING_WORLD")
TukuiTooltip:SetScript("OnEvent", function(self)
	for _, tt in pairs(Tooltips) do
		tt:HookScript("OnShow", SetStyle)
	end
	
	TukuiDB.SetTemplate(FriendsTooltip)
	FriendsTooltip:SetBackdropColor(unpack(TukuiCF.media.backdropfadecolor))
	TukuiDB.SetTemplate(BNToastFrame)
	BNToastFrame:SetBackdropColor(unpack(TukuiCF.media.backdropfadecolor))
	TukuiDB.SetTemplate(DropDownList1MenuBackdrop)
	DropDownList1MenuBackdrop:SetBackdropColor(unpack(TukuiCF.media.backdropfadecolor))
	TukuiDB.SetTemplate(DropDownList2MenuBackdrop)
	DropDownList2MenuBackdrop:SetBackdropColor(unpack(TukuiCF.media.backdropfadecolor))
	TukuiDB.SetTemplate(DropDownList1Backdrop)
	DropDownList1Backdrop:SetBackdropColor(unpack(TukuiCF.media.backdropfadecolor))
	TukuiDB.SetTemplate(DropDownList2Backdrop)
	DropDownList2Backdrop:SetBackdropColor(unpack(TukuiCF.media.backdropfadecolor))
	
	BNToastFrame:HookScript("OnShow", function(self)
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, TukuiDB.Scale(5))
	end)
		
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnEvent", nil)
	
	-- Hide tooltips in combat for actions, pet actions and shapeshift
	if db.hidebuttons == true then
		local CombatHideActionButtonsTooltip = function(self)
			if not IsShiftKeyDown() then
				self:Hide()
			end
		end
	 
		hooksecurefunc(GameTooltip, "SetAction", CombatHideActionButtonsTooltip)
		hooksecurefunc(GameTooltip, "SetPetAction", CombatHideActionButtonsTooltip)
		hooksecurefunc(GameTooltip, "SetShapeshift", CombatHideActionButtonsTooltip)
	end
end)


