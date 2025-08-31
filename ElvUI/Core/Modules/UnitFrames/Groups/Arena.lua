local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local ElvUF = E.oUF

local unpack = unpack
local CreateFrame = CreateFrame

local ArenaHeader = CreateFrame('Frame', 'ArenaHeader', E.UIParent)

function UF:ToggleArenaPreparationInfo(frame, specID)
	local specInfo = E.SpecInfoBySpecID[specID]

	local show = specInfo and not not specInfo.classFile
	frame.forceInRange = show -- used to force unitframe range

	local visibility = not show
	if show then frame.Trinket:Hide() end

	UF:ToggleVisibility_CustomTexts(frame, visibility)

	frame.Health.value:SetShown(visibility)
	frame.Power.value:SetShown(visibility)
	frame.Health.ClipFrame:SetShown(visibility)
	frame.PvPClassificationIndicator:SetAtlas(nil)
	frame.Trinket.cd:Clear()

	if not E.Classic then -- during `PostUpdateArenaPreparation` this means spec class and name exist
		frame.ArenaPrepSpec:SetFormattedText(show and '%s - %s' or '', show and specInfo.name or '', show and specInfo.classMale or '')

		if show and frame.db and frame.db.pvpSpecIcon and frame:IsElementEnabled('PVPSpecIcon') then
			frame.PVPSpecIcon.Icon:SetTexture(specInfo.icon or [[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
			frame.PVPSpecIcon.Icon:SetTexCoord(unpack(E.TexCoords))
			frame.PVPSpecIcon:Show()
		end
	end
end

function UF:PostUpdateArenaFrame(event)
	if self and event and (event ~= 'ARENA_PREP_OPPONENT_SPECIALIZATIONS' and event ~= 'PLAYER_ENTERING_WORLD') then
		UF:ToggleArenaPreparationInfo(self)
	end
end

function UF:PostUpdateArenaPreparation(_, specID)
	UF:ToggleArenaPreparationInfo(self and self.__owner, specID)
end

function UF:Construct_ArenaFrames(frame)
	UF:PrepareFrame(frame, 'arena')
	UF:ConstructFrame(frame, 'arena')

	frame.Health = UF:Construct_HealthBar(frame, true, true, 'RIGHT')
	frame.Name = UF:Construct_NameText(frame)

	if not frame.isChild then
		frame.Power = UF:Construct_PowerBar(frame, true, true, 'LEFT')
		frame.PowerPrediction = UF:Construct_PowerPrediction(frame)

		frame.Portrait3D = UF:Construct_Portrait(frame, 'model')
		frame.Portrait2D = UF:Construct_Portrait(frame, 'texture')

		frame.Auras = UF:Construct_Auras(frame)
		frame.Buffs = UF:Construct_Buffs(frame)
		frame.Debuffs = UF:Construct_Debuffs(frame)
		frame.Castbar = UF:Construct_Castbar(frame)
		frame.HealthPrediction = UF:Construct_HealComm(frame)
		frame.MouseGlow = UF:Construct_MouseGlow(frame)
		frame.TargetGlow = UF:Construct_TargetGlow(frame)
		frame.FocusGlow = UF:Construct_FocusGlow(frame)
		frame.Trinket = UF:Construct_Trinket(frame)
		frame.InfoPanel = UF:Construct_InfoPanel(frame)
		frame.PvPClassificationIndicator = UF:Construct_PvPClassificationIndicator(frame) -- Cart / Flag / Orb / Assassin Bounty
		frame.Fader = UF:Construct_Fader()

		if not E.Classic then
			frame.PVPSpecIcon = UF:Construct_PVPSpecIcon(frame)

			frame.ArenaPrepSpec = frame.Health:CreateFontString(nil, 'OVERLAY')
			frame.ArenaPrepSpec:Point('CENTER')
			UF:Configure_FontString(frame.ArenaPrepSpec)
		end

		frame.Health.PostUpdateArenaPreparation = self.PostUpdateArenaPreparation -- used to update arena prep info
		frame.PostUpdate = self.PostUpdateArenaFrame -- used to hide arena prep info
	end

	frame.Cutaway = UF:Construct_Cutaway(frame)

	ArenaHeader:Point('BOTTOMRIGHT', E.UIParent, 'RIGHT', -105, -165)
	E:CreateMover(ArenaHeader, 'ArenaHeaderMover', L["Arena Frames"], nil, nil, nil, 'ALL,ARENA', nil, 'unitframe,groupUnits,arena,generalGroup')
	frame.mover = ArenaHeader.mover
end

function UF:Update_ArenaFrames(frame, db)
	frame.db = db
	frame.colors = ElvUF.colors

	do
		frame.ORIENTATION = db.orientation --allow this value to change when unitframes position changes on screen?
		frame.UNIT_WIDTH = db.width
		frame.UNIT_HEIGHT = db.infoPanel.enable and (db.height + db.infoPanel.height) or db.height
		frame.USE_POWERBAR = db.power.enable
		frame.POWERBAR_DETACHED = db.power.detachFromFrame
		frame.USE_INSET_POWERBAR = not frame.POWERBAR_DETACHED and db.power.width == 'inset' and frame.USE_POWERBAR
		frame.USE_MINI_POWERBAR = (not frame.POWERBAR_DETACHED and db.power.width == 'spaced' and frame.USE_POWERBAR)
		frame.USE_POWERBAR_OFFSET = (db.power.width == 'offset' and db.power.offset ~= 0) and frame.USE_POWERBAR and not frame.POWERBAR_DETACHED
		frame.POWERBAR_OFFSET = frame.USE_POWERBAR_OFFSET and db.power.offset or 0
		frame.POWERBAR_HEIGHT = not frame.USE_POWERBAR and 0 or db.power.height
		frame.POWERBAR_WIDTH = frame.USE_MINI_POWERBAR and (frame.UNIT_WIDTH - (UF.BORDER*2))*0.5 or (frame.POWERBAR_DETACHED and db.power.detachedWidth or (frame.UNIT_WIDTH - ((UF.BORDER+UF.SPACING)*2)))
		frame.USE_PORTRAIT = db.portrait and db.portrait.enable
		frame.USE_PORTRAIT_OVERLAY = frame.USE_PORTRAIT and (db.portrait.overlay or frame.ORIENTATION == 'MIDDLE')
		frame.PORTRAIT_WIDTH = (frame.USE_PORTRAIT_OVERLAY or not frame.USE_PORTRAIT) and 0 or db.portrait.width
		frame.CLASSBAR_YOFFSET = 0
		frame.USE_INFO_PANEL = not frame.USE_MINI_POWERBAR and not frame.USE_POWERBAR_OFFSET and db.infoPanel.enable
		frame.INFO_PANEL_HEIGHT = frame.USE_INFO_PANEL and db.infoPanel.height or 0
		frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame)
		frame.PVPINFO_WIDTH = (not E.Classic and frame.ORIENTATION ~= 'MIDDLE' and db.pvpSpecIcon and frame.UNIT_HEIGHT) or 0
	end

	frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)
	frame:SetFrameStrata(db.strataAndLevel and db.strataAndLevel.useCustomStrata and db.strataAndLevel.frameStrata or 'LOW')
	frame:SetFrameLevel(db.strataAndLevel and db.strataAndLevel.useCustomLevel and db.strataAndLevel.frameLevel or 1)

	UF:ConfigureFrame(frame, 'arena')

	frame:ClearAllPoints()

	if frame.index == 1 then
		if db.growthDirection == 'UP' then
			frame:Point('BOTTOMRIGHT', ArenaHeader.mover, 'BOTTOMRIGHT')
		elseif db.growthDirection == 'RIGHT' then
			frame:Point('LEFT', ArenaHeader.mover, 'LEFT')
		elseif db.growthDirection == 'LEFT' then
			frame:Point('RIGHT', ArenaHeader.mover, 'RIGHT')
		else --Down
			frame:Point('TOPRIGHT', ArenaHeader.mover, 'TOPRIGHT')
		end
	else
		if db.growthDirection == 'UP' then
			frame:Point('BOTTOMRIGHT', UF['arena'..frame.index-1], 'TOPRIGHT', 0, db.spacing)
		elseif db.growthDirection == 'RIGHT' then
			frame:Point('LEFT', UF['arena'..frame.index-1], 'RIGHT', db.spacing, 0)
		elseif db.growthDirection == 'LEFT' then
			frame:Point('RIGHT', UF['arena'..frame.index-1], 'LEFT', -db.spacing, 0)
		else --Down
			frame:Point('TOPRIGHT', UF['arena'..frame.index-1], 'BOTTOMRIGHT', 0, -db.spacing)
		end
	end

	if db.growthDirection == 'UP' or db.growthDirection == 'DOWN' then
		ArenaHeader:Width(frame.UNIT_WIDTH)
		ArenaHeader:Height(frame.UNIT_HEIGHT + ((frame.UNIT_HEIGHT + db.spacing) * 4))
	elseif db.growthDirection == 'LEFT' or db.growthDirection == 'RIGHT' then
		ArenaHeader:Width(frame.UNIT_WIDTH + ((frame.UNIT_WIDTH + db.spacing) * 4))
		ArenaHeader:Height(frame.UNIT_HEIGHT)
	end
end

if not E.Classic then
	UF.unitgroupstoload.arena = {5}
end
