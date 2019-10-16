local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Lua functions
local _G = _G
local tostring = tostring
local format = format
--WoW API / Variables
local CreateFrame = CreateFrame
local IsShiftKeyDown = IsShiftKeyDown
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown

-- GLOBALS: ElvUF_Player

local function OnClick(self)
	local mod = E.db.unitframe.auraBlacklistModifier
	if mod == "NONE" or not ((mod == "SHIFT" and IsShiftKeyDown()) or (mod == "ALT" and IsAltKeyDown()) or (mod == "CTRL" and IsControlKeyDown())) then return end
	local auraName = self.name

	if auraName then
		E:Print(format(L["The spell '%s' has been added to the Blacklist unitframe aura filter."], auraName))
		E.global.unitframe.aurafilters.Blacklist.spells[auraName] = { enable = true, priority = 0 }
		UF:Update_AllFrames()
	end
end

function UF:Construct_AuraBars(statusBar)
	statusBar:CreateBackdrop(nil, nil, nil, UF.thinBorders, true)
	statusBar:SetScript('OnMouseDown', OnClick)

	UF.statusbars[statusBar] = true
	UF:Update_StatusBar(statusBar)

	UF:Configure_FontString(statusBar.timeText)
	UF:Configure_FontString(statusBar.nameText)
	UF:Configure_FontString(statusBar.countText)

	UF:Update_FontString(statusBar.countText)
	UF:Update_FontString(statusBar.timeText)
	UF:Update_FontString(statusBar.nameText)

	statusBar.iconFrame:CreateBackdrop(nil, nil, nil, UF.thinBorders, true)
	statusBar:SetPoint("LEFT")
	statusBar:SetPoint("RIGHT")

	statusBar.bg = statusBar:CreateTexture(nil, 'BORDER')
	statusBar.bg:Show()

	statusBar.iconFrame:RegisterForClicks('RightButtonUp')
	statusBar.iconFrame:SetScript('OnClick', OnClick)
	statusBar.icon:SetInside(statusBar.iconFrame.backdrop)

	local frame = statusBar:GetParent()
	statusBar.db = frame.db and frame.db.aurabar
end

function UF:Construct_AuraBarHeader(frame)
	local auraBar = CreateFrame('Frame', nil, frame)
	auraBar:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 10) --Make them appear above any text element
	auraBar:SetHeight(1)
	auraBar.PreSetPosition = UF.SortAuras
	auraBar.PostCreateBar = UF.Construct_AuraBars
	auraBar.PostUpdateBar = UF.PostUpdateBar_AuraBars
	auraBar.CustomFilter = UF.AuraFilter

	auraBar.gap = (frame.BORDER + frame.SPACING*3)
	auraBar.spacing = (frame.BORDER + frame.SPACING*3)
	auraBar.sparkEnabled = true
	auraBar.type = 'aurabar'

	return auraBar
end

function UF:Configure_AuraBars(frame)
	if not frame.VARIABLES_SET then return end
	local auraBars = frame.AuraBars
	auraBars.db = frame.db
	local db = frame.db

	if db.aurabar.enable then
		if not frame:IsElementEnabled('AuraBars') then
			frame:EnableElement('AuraBars')
		end
		auraBars:Show()

		local buffColor = self.db.colors.auraBarBuff
		local debuffColor = self.db.colors.auraBarDebuff
		local attachTo = frame

		if(E:CheckClassColor(buffColor.r, buffColor.g, buffColor.b)) then
			buffColor = E.myclass == 'PRIEST' and E.PriestColors or (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[E.myclass] or _G.RAID_CLASS_COLORS[E.myclass])
		end

		if(E:CheckClassColor(debuffColor.r, debuffColor.g, debuffColor.b)) then
			debuffColor = E.myclass == 'PRIEST' and E.PriestColors or (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[E.myclass] or _G.RAID_CLASS_COLORS[E.myclass])
		end

		if db.aurabar.attachTo == 'BUFFS' then
			attachTo = frame.Buffs
		elseif db.aurabar.attachTo == 'DEBUFFS' then
			attachTo = frame.Debuffs
		elseif db.aurabar.attachTo == "PLAYER_AURABARS" and ElvUF_Player then
			attachTo = ElvUF_Player.AuraBars
		end

		local anchorPoint, anchorTo = 'BOTTOM', 'TOP'
		if db.aurabar.anchorPoint == 'BELOW' then
			anchorPoint, anchorTo = 'TOP', 'BOTTOM'
		end

		local yOffset
		local spacing = (((db.aurabar.attachTo == "FRAME" and 3) or (db.aurabar.attachTo == "PLAYER_AURABARS" and 4) or 2) * frame.SPACING)
		local border = (((db.aurabar.attachTo == "FRAME" or db.aurabar.attachTo == "PLAYER_AURABARS") and 2 or 1) * frame.BORDER)

		if db.aurabar.anchorPoint == 'BELOW' then
			yOffset = -spacing + border - (not db.aurabar.yOffset and 0 or db.aurabar.yOffset)
		else
			yOffset = spacing - border + (not db.aurabar.yOffset and 0 or db.aurabar.yOffset)
		end

		local xOffset = (db.aurabar.attachTo == "FRAME" and frame.SPACING or 0)
		local offsetLeft = xOffset + ((db.aurabar.attachTo == "FRAME" and ((anchorTo == "TOP" and frame.ORIENTATION ~= "LEFT") or (anchorTo == "BOTTOM" and frame.ORIENTATION == "LEFT"))) and frame.POWERBAR_OFFSET or 0)
		local offsetRight = -xOffset - ((db.aurabar.attachTo == "FRAME" and ((anchorTo == "TOP" and frame.ORIENTATION ~= "RIGHT") or (anchorTo == "BOTTOM" and frame.ORIENTATION == "RIGHT"))) and frame.POWERBAR_OFFSET or 0)

		auraBars.height = db.aurabar.height

		auraBars:ClearAllPoints()
		auraBars:Point(anchorPoint..'LEFT', attachTo, anchorTo..'LEFT', offsetLeft, yOffset)
		auraBars:Point(anchorPoint..'RIGHT', attachTo, anchorTo..'RIGHT', offsetRight, yOffset)

		auraBars.buffColor = { buffColor.r, buffColor.g, buffColor.b }

		if UF.db.colors.auraBarByType then
			auraBars.debuffColor = nil;
			auraBars.defaultDebuffColor = {debuffColor.r, debuffColor.g, debuffColor.b}
		else
			auraBars.debuffColor = {debuffColor.r, debuffColor.g, debuffColor.b}
			auraBars.defaultDebuffColor = nil;
		end

		auraBars.spacing = ((-frame.BORDER + frame.SPACING*3) + db.aurabar.spacing)
		auraBars.width = frame.UNIT_WIDTH - auraBars.height
	else
		if frame:IsElementEnabled('AuraBars') then
			frame:DisableElement('AuraBars')
			auraBars:Hide()
		end
	end
end

local GOTAK_ID = 86659
local GOTAK = GetSpellInfo(GOTAK_ID)
function UF:PostUpdateBar_AuraBars(unit, statusBar, index, position, duration, expiration, debuffType, isStealable)
	local spellID = statusBar.spellID
	local spellName = statusBar.spell

	statusBar.icon:SetTexCoord(unpack(E.TexCoords))

	local colors = E.global.unitframe.AuraBarColors[spellID] or E.global.unitframe.AuraBarColors[tostring(spellID)] or E.global.unitframe.AuraBarColors[spellName]

	statusBar.custom_backdrop = UF.db.colors.customaurabarbackdrop and UF.db.colors.aurabar_backdrop
	if E.db.unitframe.colors.auraBarTurtle and (E.global.unitframe.aurafilters.TurtleBuffs.spells[spellID] or E.global.unitframe.aurafilters.TurtleBuffs.spells[spellName]) and not colors and (spellName ~= GOTAK or (spellName == GOTAK and spellID == GOTAK_ID)) then
		colors = E.db.unitframe.colors.auraBarTurtleColor
	end

	if statusBar.bg then
		if (UF.db.colors.transparentAurabars and not statusBar.isTransparent) or (statusBar.isTransparent and (not UF.db.colors.transparentAurabars or statusBar.invertColors ~= UF.db.colors.invertAurabars)) then
			UF:ToggleTransparentStatusBar(UF.db.colors.transparentAurabars, statusBar, statusBar.bg, nil, UF.db.colors.invertAurabars)
		else
			local sbTexture = statusBar:GetStatusBarTexture()
			if not statusBar.bg:GetTexture() then UF:Update_StatusBar(statusBar.bg, sbTexture:GetTexture()) end

			UF:SetStatusBarBackdropPoints(statusBar, sbTexture, statusBar.bg)
		end
	end

	if colors then
		statusBar:SetStatusBarColor(colors.r, colors.g, colors.b)

		if not statusBar.hookedColor then
			UF.UpdateBackdropTextureColor(statusBar, colors.r, colors.g, colors.b)
		end
	else
		local r, g, b = statusBar:GetStatusBarColor()
		UF.UpdateBackdropTextureColor(statusBar, r, g, b)
	end
end
