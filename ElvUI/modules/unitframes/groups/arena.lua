local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions
local _G = _G
local pairs, unpack = pairs, unpack
local tinsert = table.insert
local format = format
--WoW API / Variables
local CreateFrame = CreateFrame
local IsInInstance = IsInInstance
local UnitExists = UnitExists
local GetArenaOpponentSpec = GetArenaOpponentSpec
local GetSpecializationInfoByID = GetSpecializationInfoByID
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: UIParent, ArenaHeaderMover

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

local ArenaHeader = CreateFrame('Frame', 'ArenaHeader', UIParent)

function UF:UpdatePrep(event, unit, status)
	if (event == "ARENA_OPPONENT_UPDATE" or event == "UNIT_NAME_UPDATE") and unit ~= self.unit then return end

	local _, instanceType = IsInInstance();
	if not UF.db.units.arena.enable or instanceType ~= "arena" or (UnitExists(self.unit) and status ~= "unseen") then
		self:Hide()
		return
	end

	local s = GetArenaOpponentSpec(UF[self.unit]:GetID())
	local _, spec, texture, class

	if s and s > 0 then
		_, spec, _, texture, _, _, class = GetSpecializationInfoByID(s)
	end

	if class and spec then
		local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
		self.SpecClass:SetText(spec.."  -  "..LOCALIZED_CLASS_NAMES_MALE[class])
		self.Health:SetStatusBarColor(color.r, color.g, color.b)
		self.Icon:SetTexture(texture or [[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
		self:Show()
	else
		self:Hide()
	end
end

function UF:Construct_ArenaFrames(frame)
	frame.Health = self:Construct_HealthBar(frame, true, true, 'RIGHT')
	frame.Name = self:Construct_NameText(frame)

	if(not frame.isChild) then
		frame.Power = self:Construct_PowerBar(frame, true, true, 'LEFT')

		frame.Portrait3D = self:Construct_Portrait(frame, 'model')
		frame.Portrait2D = self:Construct_Portrait(frame, 'texture')

		frame.Buffs = self:Construct_Buffs(frame)

		frame.Debuffs = self:Construct_Debuffs(frame)

		frame.Castbar = self:Construct_Castbar(frame, 'RIGHT')

		frame.HealPrediction = UF:Construct_HealComm(frame)
		frame.Trinket = self:Construct_Trinket(frame)
		frame.PVPSpecIcon = self:Construct_PVPSpecIcon(frame)
		frame.Range = UF:Construct_Range(frame)
		frame:SetAttribute("type2", "focus")

		frame.TargetGlow = UF:Construct_TargetGlow(frame)
		tinsert(frame.__elements, UF.UpdateTargetGlow)
		frame:RegisterEvent('PLAYER_TARGET_CHANGED', UF.UpdateTargetGlow)
		frame:RegisterEvent('PLAYER_ENTERING_WORLD', UF.UpdateTargetGlow)
		frame:RegisterEvent('GROUP_ROSTER_UPDATE', UF.UpdateTargetGlow)

		frame.customTexts = {}
		frame.InfoPanel = self:Construct_InfoPanel(frame)
		frame.unitframeType = "arena"
	end

	if not frame.PrepFrame and not frame.isChild then
		frame.prepFrame = CreateFrame('Frame', frame:GetName()..'PrepFrame', UIParent)
		frame.prepFrame:SetFrameStrata('BACKGROUND')
		frame.prepFrame:SetAllPoints(frame)
		frame.prepFrame:SetID(frame:GetID())
		frame.prepFrame:SetScript("OnEvent", UF.UpdatePrep)
		frame.prepFrame.unit = frame.unit

		frame.prepFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		frame.prepFrame:RegisterEvent("ARENA_OPPONENT_UPDATE")
		frame.prepFrame:RegisterEvent("UNIT_NAME_UPDATE")
		frame.prepFrame:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")

		frame.prepFrame.Health = CreateFrame('StatusBar', nil, frame.prepFrame)
		frame.prepFrame.Health:Point('BOTTOMLEFT', frame.prepFrame, 'BOTTOMLEFT', E.Border, E.Border)
		frame.prepFrame.Health:Point('TOPRIGHT', frame.prepFrame, 'TOPRIGHT', -(E.Border + E.db.unitframe.units.arena.height), -E.Border)
		frame.prepFrame.Health:CreateBackdrop()

		frame.prepFrame.Icon = frame.prepFrame:CreateTexture(nil, 'OVERLAY')
		frame.prepFrame.Icon.bg = CreateFrame('Frame', nil, frame.prepFrame)
		frame.prepFrame.Icon.bg:Point('TOPLEFT', frame.prepFrame.Health.backdrop, 'TOPRIGHT', E.PixelMode and -1 or 1, 0)
		frame.prepFrame.Icon.bg:Point('BOTTOMRIGHT', frame.prepFrame, 'BOTTOMRIGHT', 0, 0)
		frame.prepFrame.Icon.bg:SetTemplate('Default')
		frame.prepFrame.Icon:SetParent(frame.prepFrame.Icon.bg)
		frame.prepFrame.Icon:SetTexCoord(unpack(E.TexCoords))
		frame.prepFrame.Icon:SetInside(frame.prepFrame.Icon.bg)
		UF['statusbars'][frame.prepFrame.Health] = true;

		frame.prepFrame.SpecClass = frame.prepFrame.Health:CreateFontString(nil, "OVERLAY")
		frame.prepFrame.SpecClass:Point("CENTER")
		UF:Configure_FontString(frame.prepFrame.SpecClass)
		--frame.prepFrame:Hide()
	end

	ArenaHeader:Point('BOTTOMRIGHT', E.UIParent, 'RIGHT', -105, -165)
	E:CreateMover(ArenaHeader, ArenaHeader:GetName()..'Mover', L["Arena Frames"], nil, nil, nil, 'ALL,ARENA')
	frame.mover = ArenaHeader.mover
end

function UF:Update_ArenaFrames(frame, db)
	frame.db = db

	do
		frame.ORIENTATION = db.orientation --allow this value to change when unitframes position changes on screen?
		frame.UNIT_WIDTH = db.width
		frame.UNIT_HEIGHT = (E.global.tukuiMode and not db.infoPanel.enable) and db.height + db.infoPanel.height or db.height

		frame.USE_POWERBAR = db.power.enable
		frame.POWERBAR_DETACHED = db.power.detachFromFrame
		frame.USE_INSET_POWERBAR = not frame.POWERBAR_DETACHED and db.power.width == 'inset' and frame.USE_POWERBAR
		frame.USE_MINI_POWERBAR = (not frame.POWERBAR_DETACHED and db.power.width == 'spaced' and frame.USE_POWERBAR)
		frame.USE_POWERBAR_OFFSET = db.power.offset ~= 0 and frame.USE_POWERBAR and not frame.POWERBAR_DETACHED
		frame.POWERBAR_OFFSET = frame.USE_POWERBAR_OFFSET and db.power.offset or 0

		frame.POWERBAR_HEIGHT = not frame.USE_POWERBAR and 0 or db.power.height
		frame.POWERBAR_WIDTH = frame.USE_MINI_POWERBAR and (frame.UNIT_WIDTH - (frame.BORDER*2))/2 or (frame.POWERBAR_DETACHED and db.power.detachedWidth or (frame.UNIT_WIDTH - ((frame.BORDER+frame.SPACING)*2)))

		frame.USE_PORTRAIT = db.portrait and db.portrait.enable
		frame.USE_PORTRAIT_OVERLAY = frame.USE_PORTRAIT
		frame.PORTRAIT_WIDTH = (frame.USE_PORTRAIT_OVERLAY or not frame.USE_PORTRAIT) and 0 or db.portrait.width

		frame.STAGGER_WIDTH = db.pvpSpecIcon and frame.UNIT_HEIGHT or 0
		frame.CLASSBAR_YOFFSET = 0

		frame.USE_INFO_PANEL = not frame.USE_MINI_POWERBAR and not frame.USE_POWERBAR_OFFSET and (db.infoPanel.enable or E.global.tukuiMode)
		frame.INFO_PANEL_HEIGHT = frame.USE_INFO_PANEL and db.infoPanel.height or 0

		frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame)

		frame.USE_TARGET_GLOW = db.targetGlow
	end

	frame.colors = ElvUF.colors
	frame.Portrait = frame.Portrait or (db.portrait.style == '2D' and frame.Portrait2D or frame.Portrait3D)
	frame:RegisterForClicks(self.db.targetOnMouseDown and 'AnyDown' or 'AnyUp')
	frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)

	UF:Configure_InfoPanel(frame)

	--Health
	UF:Configure_HealthBar(frame)

	--Name
	UF:UpdateNameSettings(frame)

	--Power
	UF:Configure_Power(frame)

	--Portrait
	UF:Configure_Portrait(frame)

	--Target Glow
	UF:Configure_TargetGlow(frame)

	--Auras
	UF:EnableDisable_Auras(frame)
	UF:Configure_Auras(frame, 'Buffs')
	UF:Configure_Auras(frame, 'Debuffs')

	--Castbar
	UF:Configure_Castbar(frame)

	--PVPSpecIcon
	UF:Configure_PVPSpecIcon(frame)

	--Trinket
	UF:Configure_Trinket(frame)

	--Range
	UF:Configure_Range(frame)

	--Heal Prediction
	UF:Configure_HealComm(frame)

	--CustomTexts
	UF:Configure_CustomTexts(frame)

	frame:ClearAllPoints()
	if frame.index == 1 then
		if db.growthDirection == 'UP' then
			frame:Point('BOTTOMRIGHT', ArenaHeaderMover, 'BOTTOMRIGHT')
		elseif db.growthDirection == 'RIGHT' then
			frame:Point('LEFT', ArenaHeaderMover, 'LEFT')
		elseif db.growthDirection == 'LEFT' then
			frame:Point('RIGHT', ArenaHeaderMover, 'RIGHT')
		else --Down
			frame:Point('TOPRIGHT', ArenaHeaderMover, 'TOPRIGHT')
		end
	else
		if db.growthDirection == 'UP' then
			frame:Point('BOTTOMRIGHT', _G['ElvUF_Arena'..frame.index-1], 'TOPRIGHT', 0, db.spacing)
		elseif db.growthDirection == 'RIGHT' then
			frame:Point('LEFT', _G['ElvUF_Arena'..frame.index-1], 'RIGHT', db.spacing, 0)
		elseif db.growthDirection == 'LEFT' then
			frame:Point('RIGHT', _G['ElvUF_Arena'..frame.index-1], 'LEFT', -db.spacing, 0)
		else --Down
			frame:Point('TOPRIGHT', _G['ElvUF_Arena'..frame.index-1], 'BOTTOMRIGHT', 0, -db.spacing)
		end
	end

	if db.growthDirection == 'UP' or db.growthDirection == 'DOWN' then
		ArenaHeader:Width(frame.UNIT_WIDTH)
		ArenaHeader:Height(frame.UNIT_HEIGHT + ((frame.UNIT_HEIGHT + db.spacing) * 4))
	elseif db.growthDirection == 'LEFT' or db.growthDirection == 'RIGHT' then
		ArenaHeader:Width(frame.UNIT_WIDTH + ((frame.UNIT_WIDTH + db.spacing) * 4))
		ArenaHeader:Height(frame.UNIT_HEIGHT)
	end

	frame:UpdateAllElements()
end

UF['unitgroupstoload']['arena'] = {5, 'ELVUI_UNITTARGET'}
