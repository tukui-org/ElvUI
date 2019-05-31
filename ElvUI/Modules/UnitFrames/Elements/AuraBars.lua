local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Lua functions
local _G = _G
local strmatch = strmatch
local strsplit = strsplit
local tostring = tostring
local format = format
local select = select
--WoW API / Variables
local CreateFrame = CreateFrame
local IsShiftKeyDown = IsShiftKeyDown
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local UnitIsFriend = UnitIsFriend
local UnitIsUnit = UnitIsUnit
local UnitCanAttack = UnitCanAttack
-- GLOBALS: ElvUF_Player

local function OnClick(self)
	local mod = E.db.unitframe.auraBlacklistModifier
	if mod == "NONE" or not ((mod == "SHIFT" and IsShiftKeyDown()) or (mod == "ALT" and IsAltKeyDown()) or (mod == "CTRL" and IsControlKeyDown())) then return end
	local auraName = self:GetParent().aura.name

	if auraName then
		E:Print(format(L["The spell '%s' has been added to the Blacklist unitframe aura filter."], auraName))
		E.global.unitframe.aurafilters.Blacklist.spells[auraName] = { enable = true, priority = 0 }
		UF:Update_AllFrames()
	end
end

function UF:Construct_AuraBars()
	local bar = self.statusBar

	self:SetTemplate(nil, nil, nil, UF.thinBorders, true)
	local inset = UF.thinBorders and E.mult or nil
	bar:SetInside(self, inset, inset)
	UF.statusbars[bar] = true
	UF:Update_StatusBar(bar)

	UF:Configure_FontString(bar.spelltime)
	UF:Configure_FontString(bar.spellname)
	UF:Update_FontString(bar.spelltime)
	UF:Update_FontString(bar.spellname)

	bar.spellname:ClearAllPoints()
	bar.spellname:Point('LEFT', bar, 'LEFT', 2, 0)
	bar.spellname:Point('RIGHT', bar.spelltime, 'LEFT', -4, 0)
	bar.spellname:SetWordWrap(false)

	bar.iconHolder:SetTemplate(nil, nil, nil, UF.thinBorders, true)
	bar.icon:SetInside(bar.iconHolder, inset, inset)
	bar.icon:SetDrawLayer('OVERLAY')

	bar.bg = bar:CreateTexture(nil, 'BORDER')
	bar.bg:Show()

	bar.iconHolder:RegisterForClicks('RightButtonUp')
	bar.iconHolder:SetScript('OnClick', OnClick)
end

function UF:Construct_AuraBarHeader(frame)
	local auraBar = CreateFrame('Frame', nil, frame)
	auraBar:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 10) --Make them appear above any text element
	auraBar.PostCreateBar = UF.Construct_AuraBars
	auraBar.gap = (-frame.BORDER + frame.SPACING*3)
	auraBar.spacing = (-frame.BORDER + frame.SPACING*3)
	auraBar.spark = true
	auraBar.filter = UF.AuraBarFilter
	auraBar.PostUpdate = UF.ColorizeAuraBars

	return auraBar
end

function UF:Configure_AuraBars(frame)
	if not frame.VARIABLES_SET then return end
	local auraBars = frame.AuraBars
	local db = frame.db
	if db.aurabar.enable then
		if not frame:IsElementEnabled('AuraBars') then
			frame:EnableElement('AuraBars')
		end
		auraBars:Show()
		auraBars.friendlyAuraType = db.aurabar.friendlyAuraType
		auraBars.enemyAuraType = db.aurabar.enemyAuraType
		auraBars.scaleTime = db.aurabar.uniformThreshold

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

		auraBars.auraBarHeight = db.aurabar.height
		auraBars:ClearAllPoints()
		auraBars:Point(anchorPoint..'LEFT', attachTo, anchorTo..'LEFT', offsetLeft, yOffset)
		auraBars:Point(anchorPoint..'RIGHT', attachTo, anchorTo..'RIGHT', offsetRight, yOffset)
		auraBars.buffColor = {buffColor.r, buffColor.g, buffColor.b}
		if UF.db.colors.auraBarByType then
			auraBars.debuffColor = nil;
			auraBars.defaultDebuffColor = {debuffColor.r, debuffColor.g, debuffColor.b}
		else
			auraBars.debuffColor = {debuffColor.r, debuffColor.g, debuffColor.b}
			auraBars.defaultDebuffColor = nil;
		end
		auraBars.down = db.aurabar.anchorPoint == 'BELOW'

		if db.aurabar.sort == 'TIME_REMAINING' then
			auraBars.sort = true --default function
		elseif db.aurabar.sort == 'TIME_REMAINING_REVERSE' then
			auraBars.sort = self.SortAuraBarReverse
		elseif db.aurabar.sort == 'TIME_DURATION' then
			auraBars.sort = self.SortAuraBarDuration
		elseif db.aurabar.sort == 'TIME_DURATION_REVERSE' then
			auraBars.sort = self.SortAuraBarDurationReverse
		elseif db.aurabar.sort == 'NAME' then
			auraBars.sort = self.SortAuraBarName
		else
			auraBars.sort = nil
		end

		auraBars.maxBars = db.aurabar.maxBars
		auraBars.forceShow = frame.forceShowAuras
		auraBars.spacing = ((-frame.BORDER + frame.SPACING*3) + db.aurabar.spacing)
		auraBars:SetAnchors()
	else
		if frame:IsElementEnabled('AuraBars') then
			frame:DisableElement('AuraBars')
			auraBars:Hide()
		end
	end
end

local huge = math.huge
function UF.SortAuraBarReverse(a, b)
	local compa, compb = a.noTime and huge or a.expirationTime, b.noTime and huge or b.expirationTime
	return compa < compb
end

function UF.SortAuraBarDuration(a, b)
	local compa, compb = a.noTime and huge or a.duration, b.noTime and huge or b.duration
	return compa > compb
end

function UF.SortAuraBarDurationReverse(a, b)
	local compa, compb = a.noTime and huge or a.duration, b.noTime and huge or b.duration
	return compa < compb
end

function UF.SortAuraBarName(a, b)
	return a.name > b.name
end

function UF:CheckFilter(name, caster, spellID, isFriend, isPlayer, isUnit, isBossDebuff, allowDuration, noDuration, canDispell, casterIsPlayer, ...)
	for i=1, select('#', ...) do
		local filterName = select(i, ...)
		local friendCheck = (isFriend and strmatch(filterName, "^Friendly:([^,]*)")) or (not isFriend and strmatch(filterName, "^Enemy:([^,]*)")) or nil
		if friendCheck ~= false then
			if friendCheck ~= nil and (G.unitframe.specialFilters[friendCheck] or E.global.unitframe.aurafilters[friendCheck]) then
				filterName = friendCheck -- this is for our filters to handle Friendly and Enemy
			end
			local filter = E.global.unitframe.aurafilters[filterName]
			if filter then
				local filterType = filter.type
				local spellList = filter.spells
				local spell = spellList and (spellList[spellID] or spellList[name])

				if filterType and (filterType == 'Whitelist') and (spell and spell.enable) and allowDuration then
					return true, spell.priority -- this is the only difference from auarbars code
				elseif filterType and (filterType == 'Blacklist') and (spell and spell.enable) then
					return false
				end
			elseif filterName == 'Personal' and isPlayer and allowDuration then
				return true
			elseif filterName == 'nonPersonal' and (not isPlayer) and allowDuration then
				return true
			elseif filterName == 'Boss' and isBossDebuff and allowDuration then
				return true
			elseif filterName == 'CastByUnit' and (caster and isUnit) and allowDuration then
				return true
			elseif filterName == 'notCastByUnit' and (caster and not isUnit) and allowDuration then
				return true
			elseif filterName == 'Dispellable' and canDispell and allowDuration then
				return true
			elseif filterName == 'notDispellable' and (not canDispell) and allowDuration then
				return true
			elseif filterName == 'CastByNPC' and (not casterIsPlayer) and allowDuration then
				return true
			elseif filterName == 'CastByPlayers' and casterIsPlayer and allowDuration then
				return true
			elseif filterName == 'blockCastByPlayers' and casterIsPlayer then
				return false
			elseif filterName == 'blockNoDuration' and noDuration then
				return false
			elseif filterName == 'blockNonPersonal' and (not isPlayer) then
				return false
			elseif filterName == 'blockDispellable' and canDispell then
				return false
			elseif filterName == 'blockNotDispellable' and (not canDispell) then
				return false
			end
		end
	end
end

function UF:AuraBarFilter(unit, name, _, _, debuffType, duration, _, unitCaster, isStealable, _, spellID, _, isBossDebuff, casterIsPlayer)
	if not self.db then return; end
	local db = self.db.aurabar

	if not name then return nil end
	local filterCheck, isUnit, isFriend, isPlayer, canDispell, allowDuration, noDuration

	if db.priority ~= '' then
		noDuration = (not duration or duration == 0)
		isFriend = unit and UnitIsFriend('player', unit) and not UnitCanAttack('player', unit)
		isPlayer = (unitCaster == 'player' or unitCaster == 'vehicle')
		isUnit = unit and unitCaster and UnitIsUnit(unit, unitCaster)

		local auraType = (isFriend and db.friendlyAuraType) or (not isFriend and db.enemyAuraType)
		canDispell = (auraType == 'HELPFUL' and isStealable) or (auraType == 'HARMFUL' and debuffType and E:IsDispellableByMe(debuffType))
		allowDuration = noDuration or (duration and (duration > 0) and (db.maxDuration == 0 or duration <= db.maxDuration) and (db.minDuration == 0 or duration >= db.minDuration))
		filterCheck = UF:CheckFilter(name, unitCaster, spellID, isFriend, isPlayer, isUnit, isBossDebuff, allowDuration, noDuration, canDispell, casterIsPlayer, strsplit(',', db.priority))
	else
		filterCheck = true -- Allow all auras to be shown when the filter list is empty
	end

	return filterCheck
end

local GOTAK_ID = 86659
local GOTAK = GetSpellInfo(GOTAK_ID)
function UF:ColorizeAuraBars()
	local bars = self.bars
	for index = 1, #bars do
		local frame = bars[index]
		if not frame:IsVisible() then break end

		local sb = frame.statusBar
		local spellName = sb.aura.name
		local spellID = sb.aura.spellID
		local colors = E.global.unitframe.AuraBarColors[spellID] or E.global.unitframe.AuraBarColors[tostring(spellID)] or E.global.unitframe.AuraBarColors[spellName]

		sb.custom_backdrop = UF.db.colors.customaurabarbackdrop and UF.db.colors.aurabar_backdrop
		if E.db.unitframe.colors.auraBarTurtle and (E.global.unitframe.aurafilters.TurtleBuffs.spells[spellID] or E.global.unitframe.aurafilters.TurtleBuffs.spells[spellName]) and not colors and (spellName ~= GOTAK or (spellName == GOTAK and spellID == GOTAK_ID)) then
			colors = E.db.unitframe.colors.auraBarTurtleColor
		end

		if sb.bg then
			if (UF.db.colors.transparentAurabars and not sb.isTransparent) or (sb.isTransparent and (not UF.db.colors.transparentAurabars or sb.invertColors ~= UF.db.colors.invertAurabars)) then
				UF:ToggleTransparentStatusBar(UF.db.colors.transparentAurabars, sb, sb.bg, nil, UF.db.colors.invertAurabars)
			else
				local sbTexture = sb:GetStatusBarTexture()
				if not sb.bg:GetTexture() then UF:Update_StatusBar(sb.bg, sbTexture:GetTexture()) end

				UF:SetStatusBarBackdropPoints(sb, sbTexture, sb.bg)
			end
		end

		if colors then
			sb:SetStatusBarColor(colors.r, colors.g, colors.b)

			if not sb.hookedColor then
				UF.UpdateBackdropTextureColor(sb, colors.r, colors.g, colors.b)
			end
		else
			local r, g, b = sb:GetStatusBarColor()
			UF.UpdateBackdropTextureColor(sb, r, g, b)
		end
	end
end
