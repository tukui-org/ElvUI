local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

--Cache global variables
--Lua functions
local _G = _G
local pairs, unpack = pairs, unpack
local tinsert = table.insert
local ceil = math.ceil
local format = format
--WoW API / Variables
local IsAddOnLoaded = IsAddOnLoaded
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local MAX_COMBO_POINTS = MAX_COMBO_POINTS

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ElvUF_Player

function UF:Construct_TargetFrame(frame)
	frame.Health = self:Construct_HealthBar(frame, true, true, 'RIGHT')
	frame.Health.frequentUpdates = true;

	frame.Power = self:Construct_PowerBar(frame, true, true, 'LEFT')
	frame.Power.frequentUpdates = true;

	frame.Name = self:Construct_NameText(frame)

	frame.Portrait3D = self:Construct_Portrait(frame, 'model')
	frame.Portrait2D = self:Construct_Portrait(frame, 'texture')

	frame.Buffs = self:Construct_Buffs(frame)

	frame.Debuffs = self:Construct_Debuffs(frame)
	frame.Threat = self:Construct_Threat(frame)
	frame.Castbar = self:Construct_Castbar(frame, 'RIGHT', L["Target Castbar"])
	frame.Castbar.SafeZone = nil
	frame.Castbar.LatencyTexture:Hide()
	frame.RaidIcon = UF:Construct_RaidIcon(frame)
	frame.CPoints = self:Construct_Combobar(frame)
	frame.HealPrediction = self:Construct_HealComm(frame)
	frame.DebuffHighlight = self:Construct_DebuffHighlight(frame)
	frame.GPS = self:Construct_GPS(frame)

	frame.AuraBars = self:Construct_AuraBarHeader(frame)
	frame.Range = UF:Construct_Range(frame)
	frame.customTexts = {}
	frame:Point('BOTTOMRIGHT', E.UIParent, 'BOTTOM', 413, 68)
	E:CreateMover(frame, frame:GetName()..'Mover', L["Target Frame"], nil, nil, nil, 'ALL,SOLO')
end

function UF:Update_TargetFrame(frame, db)
	frame.db = db

	if frame.Portrait then
		frame.Portrait:Hide()
		frame.Portrait:ClearAllPoints()
		frame.Portrait.backdrop:Hide()
	end
	frame.Portrait = db.portrait.style == '2D' and frame.Portrait2D or frame.Portrait3D
	frame:RegisterForClicks(self.db.targetOnMouseDown and 'AnyDown' or 'AnyUp')
	local BORDER = E.Border;
	local SPACING = E.Spacing;
	local UNIT_WIDTH = db.width
	local UNIT_HEIGHT = db.height
	local SHADOW_SPACING = E.PixelMode and 3 or 4
	local USE_POWERBAR = db.power.enable
	local USE_INSET_POWERBAR = db.power.width == 'inset' and USE_POWERBAR
	local USE_MINI_POWERBAR = db.power.width == 'spaced' and USE_POWERBAR
	local USE_POWERBAR_OFFSET = db.power.offset ~= 0 and USE_POWERBAR
	local POWERBAR_DETACHED = db.power.detachFromFrame
	local POWERBAR_OFFSET = db.power.offset
	local POWERBAR_HEIGHT = db.power.height
	local POWERBAR_WIDTH = POWERBAR_DETACHED and db.power.detachedWidth or (db.width - (BORDER*2))

	local USE_COMBOBAR = db.combobar.enable
	local USE_MINI_COMBOBAR = db.combobar.fill == "spaced" and USE_COMBOBAR and not db.combobar.detachFromFrame
	local COMBOBAR_HEIGHT = db.combobar.height
	local COMBOBAR_WIDTH = db.width - (BORDER*2)

	local USE_PORTRAIT = db.portrait.enable
	local USE_PORTRAIT_OVERLAY = db.portrait.overlay and USE_PORTRAIT
	local PORTRAIT_WIDTH = db.portrait.width

	local unit = self.unit

	frame.colors = ElvUF.colors
	frame:Size(UNIT_WIDTH, UNIT_HEIGHT)
	_G[frame:GetName()..'Mover']:Size(frame:GetSize())

	if not IsAddOnLoaded("Clique") then
		if db.middleClickFocus then
			frame:SetAttribute("type3", "focus")
		elseif frame:GetAttribute("type3") == "focus" then
			frame:SetAttribute("type3", nil)
		end
	end

	--Adjust some variables
	do
		if not USE_POWERBAR then
			POWERBAR_HEIGHT = 0
		end

		if USE_PORTRAIT_OVERLAY or not USE_PORTRAIT then
			PORTRAIT_WIDTH = 0
			if USE_POWERBAR_OFFSET then
				COMBOBAR_WIDTH = COMBOBAR_WIDTH - POWERBAR_OFFSET
			end
		elseif USE_PORTRAIT then
			COMBOBAR_WIDTH = ceil((UNIT_WIDTH - (BORDER*2)) - PORTRAIT_WIDTH)

			if USE_POWERBAR_OFFSET then
				COMBOBAR_WIDTH = COMBOBAR_WIDTH - POWERBAR_OFFSET
			end
		elseif USE_POWERBAR_OFFSET then
			COMBOBAR_WIDTH = COMBOBAR_WIDTH - POWERBAR_OFFSET
		end

		if USE_MINI_COMBOBAR then
			COMBOBAR_WIDTH = COMBOBAR_WIDTH * 4/5
		end

		if USE_MINI_POWERBAR and not POWERBAR_DETACHED then
			POWERBAR_WIDTH = POWERBAR_WIDTH / 2
		end
		
		if not USE_POWERBAR_OFFSET then
			POWERBAR_OFFSET = 0
		end
	end

	--Health
	do
		local health = frame.Health
		health.Smooth = self.db.smoothbars

		--Text
		local x, y = self:GetPositionOffset(db.health.position)
		health.value:ClearAllPoints()
		health.value:Point(db.health.position, health, db.health.position, x + db.health.xOffset, y + db.health.yOffset)
		frame:Tag(health.value, db.health.text_format)

		--Colors
		health.colorSmooth = nil
		health.colorHealth = nil
		health.colorClass = nil
		health.colorReaction = nil
		if self.db['colors'].healthclass ~= true then
			if self.db['colors'].colorhealthbyvalue == true then
				health.colorSmooth = true
			else
				health.colorHealth = true
			end
		else
			health.colorClass = (not self.db['colors'].forcehealthreaction)
			health.colorReaction = true
		end

		--Position
		health:ClearAllPoints()
		health:Point("TOPRIGHT", frame, "TOPRIGHT", -BORDER, -BORDER)

		if POWERBAR_DETACHED then
			health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, BORDER)
		elseif USE_POWERBAR_OFFSET then
			health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER+POWERBAR_OFFSET, BORDER+POWERBAR_OFFSET)
		elseif USE_INSET_POWERBAR then
			health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, BORDER)
		elseif USE_MINI_POWERBAR then
			health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, BORDER + (POWERBAR_HEIGHT/2))
		else
			health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, (USE_POWERBAR and ((BORDER + SPACING)*2) or BORDER) + POWERBAR_HEIGHT)
		end

		health.bg:ClearAllPoints()
		if not USE_PORTRAIT_OVERLAY then
			health:Point("TOPRIGHT", -(PORTRAIT_WIDTH+BORDER), -BORDER)
			health.bg:SetParent(health)
			health.bg:SetAllPoints()
		else
			health.bg:Point('BOTTOMLEFT', health:GetStatusBarTexture(), 'BOTTOMRIGHT')
			health.bg:Point('TOPRIGHT', health)
			health.bg:SetParent(frame.Portrait.overlay)
		end
	end

	--Name
	UF:UpdateNameSettings(frame)

	--Power
	do
		local power = frame.Power

		if USE_POWERBAR then
			if not frame:IsElementEnabled('Power') then
				frame:EnableElement('Power')
				power:Show()
			end
			power.Smooth = self.db.smoothbars

			--Text
			local x, y = self:GetPositionOffset(db.power.position)
			power.value:ClearAllPoints()
			power.value:Point(db.power.position, db.power.attachTextToPower and power or frame.Health, db.power.position, x + db.power.xOffset, y + db.power.yOffset)
			frame:Tag(power.value, db.power.text_format)

			if db.power.attachTextToPower then
				power.value:SetParent(power)
			else
				power.value:SetParent(frame.RaisedElementParent)
			end

			--Colors
			power.colorClass = nil
			power.colorReaction = nil
			power.colorPower = nil
			if self.db['colors'].powerclass then
				power.colorClass = true
				power.colorReaction = true
			else
				power.colorPower = true
			end

			--Position
			power:ClearAllPoints()

			if POWERBAR_DETACHED then
				power:Width(POWERBAR_WIDTH)
				power:Height(POWERBAR_HEIGHT)
				if not power.mover then
					power:ClearAllPoints()
					power:Point("BOTTOM", frame, "BOTTOM", 0, -20)
					E:CreateMover(power, 'TargetPowerBarMover', L["Target Powerbar"], nil, nil, nil, 'ALL,SOLO')
				else
					power:ClearAllPoints()
					power:SetPoint("BOTTOMLEFT", power.mover, "BOTTOMLEFT")
					power.mover:SetScale(1)
					power.mover:SetAlpha(1)
				end

				power:SetFrameStrata("MEDIUM")
				power:SetFrameLevel(frame:GetFrameLevel() + 3)
			elseif USE_POWERBAR_OFFSET then
				power:Point("TOPLEFT", frame.Health, "TOPLEFT", -POWERBAR_OFFSET, -POWERBAR_OFFSET)
				power:Point("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", -POWERBAR_OFFSET, -POWERBAR_OFFSET)
				power:SetFrameStrata("LOW")
				power:SetFrameLevel(2)
			elseif USE_MINI_POWERBAR then
				power:Width(POWERBAR_WIDTH - BORDER*2)
				power:Height(POWERBAR_HEIGHT)
				power:Point("LEFT", frame, "BOTTOMLEFT", (BORDER*2 + 4), BORDER + (POWERBAR_HEIGHT/2))
				power:SetFrameStrata("MEDIUM")
				power:SetFrameLevel(frame:GetFrameLevel() + 3)
			elseif USE_INSET_POWERBAR then
				power:Height(POWERBAR_HEIGHT)
				power:Point("BOTTOMLEFT", frame.Health, "BOTTOMLEFT", BORDER + (BORDER*2), BORDER + (BORDER*2))
				power:Point("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", -(BORDER + (BORDER*2)), BORDER + (BORDER*2))
				power:SetFrameStrata("MEDIUM")
				power:SetFrameLevel(frame:GetFrameLevel() + 3)
			else
				power:Point("TOPLEFT", frame.Health.backdrop, "BOTTOMLEFT", BORDER, -(E.PixelMode and 0 or (BORDER + SPACING)))
				power:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -(BORDER + PORTRAIT_WIDTH), BORDER)
			end
			
			if db.power.strataAndLevel.useCustomStrata then
				power:SetFrameStrata(db.power.strataAndLevel.frameStrata)
			end
			if db.power.strataAndLevel.useCustomLevel then
				power:SetFrameLevel(db.power.strataAndLevel.frameLevel)
			end
			
			if POWERBAR_DETACHED and db.power.parent == "UIPARENT" then
				power:SetParent(E.UIParent)
			else
				power:SetParent(frame)
			end
		elseif frame:IsElementEnabled('Power') then
			frame:DisableElement('Power')
			power:Hide()
		end
	end

	--Portrait
	do
		local portrait = frame.Portrait

		--Set Points
		if USE_PORTRAIT then
			if not frame:IsElementEnabled('Portrait') then
				frame:EnableElement('Portrait')
			end

			portrait:ClearAllPoints()

			if USE_PORTRAIT_OVERLAY then
				if db.portrait.style == '3D' then
					portrait:SetFrameLevel(frame.Health:GetFrameLevel() + 1)
				end
				portrait:SetAllPoints(frame.Health)
				portrait:SetAlpha(0.3)
				portrait:Show()
				portrait.backdrop:Hide()
			else
				portrait:SetAlpha(1)
				portrait:Show()
				portrait.backdrop:Show()
				portrait.backdrop:ClearAllPoints()
				portrait.backdrop:SetPoint("TOPRIGHT", frame, "TOPRIGHT", E.PixelMode and -1 or 0, 0)

				if db.portrait.style == '3D' then
					portrait:SetFrameLevel(frame:GetFrameLevel() + 5)
				end

				if USE_MINI_POWERBAR or USE_POWERBAR_OFFSET or not USE_POWERBAR or USE_INSET_POWERBAR or POWERBAR_DETACHED then
					portrait.backdrop:Point("BOTTOMLEFT", frame.Health.backdrop, "BOTTOMRIGHT", E.PixelMode and -1 or SPACING, 0)
				else
					portrait.backdrop:Point("BOTTOMLEFT", frame.Power.backdrop, "BOTTOMRIGHT", E.PixelMode and -1 or SPACING, 0)
				end

				portrait:Point('BOTTOMLEFT', portrait.backdrop, 'BOTTOMLEFT', BORDER, BORDER)
				portrait:Point('TOPRIGHT', portrait.backdrop, 'TOPRIGHT', -BORDER, -BORDER)
			end
		else
			if frame:IsElementEnabled('Portrait') then
				frame:DisableElement('Portrait')
				portrait:Hide()
				portrait.backdrop:Hide()
			end
		end
	end

	--Threat
	do
		local threat = frame.Threat

		if db.threatStyle ~= 'NONE' and db.threatStyle ~= nil then
			if not frame:IsElementEnabled('Threat') then
				frame:EnableElement('Threat')
			end

			if db.threatStyle == "GLOW" then
				threat:SetFrameStrata('BACKGROUND')
				threat.glow:ClearAllPoints()
				threat.glow:SetBackdropBorderColor(0, 0, 0, 0)
				threat.glow:Point("TOPLEFT", frame.Health.backdrop, "TOPLEFT", -SHADOW_SPACING, SHADOW_SPACING)
				threat.glow:Point("TOPRIGHT", frame.Health.backdrop, "TOPRIGHT", SHADOW_SPACING, SHADOW_SPACING)
				threat.glow:Point("BOTTOMLEFT", frame.Power.backdrop, "BOTTOMLEFT", -SHADOW_SPACING, -SHADOW_SPACING)
				threat.glow:Point("BOTTOMRIGHT", frame.Power.backdrop, "BOTTOMRIGHT", SHADOW_SPACING, -SHADOW_SPACING)

				if USE_MINI_POWERBAR or USE_POWERBAR_OFFSET or USE_INSET_POWERBAR or POWERBAR_DETACHED then
					threat.glow:Point("BOTTOMLEFT", frame.Health.backdrop, "BOTTOMLEFT", -SHADOW_SPACING, -SHADOW_SPACING)
					threat.glow:Point("BOTTOMRIGHT", frame.Health.backdrop, "BOTTOMRIGHT", SHADOW_SPACING, -SHADOW_SPACING)
				end

				if USE_PORTRAIT and not USE_PORTRAIT_OVERLAY then
					threat.glow:Point("TOPRIGHT", frame.Portrait.backdrop, "TOPRIGHT", SHADOW_SPACING, -SHADOW_SPACING)
					threat.glow:Point("BOTTOMRIGHT", frame.Portrait.backdrop, "BOTTOMRIGHT", SHADOW_SPACING, -SHADOW_SPACING)
				end
			elseif db.threatStyle == "ICONTOPLEFT" or db.threatStyle == "ICONTOPRIGHT" or db.threatStyle == "ICONBOTTOMLEFT" or db.threatStyle == "ICONBOTTOMRIGHT" or db.threatStyle == "ICONTOP" or db.threatStyle == "ICONBOTTOM" or db.threatStyle == "ICONLEFT" or db.threatStyle == "ICONRIGHT" then
				threat:SetFrameStrata('HIGH')
				local point = db.threatStyle
				point = point:gsub("ICON", "")

				threat.texIcon:ClearAllPoints()
				threat.texIcon:SetPoint(point, frame.Health, point)
			end
		elseif frame:IsElementEnabled('Threat') then
			frame:DisableElement('Threat')
		end
	end

	--Auras Disable/Enable
	--Only do if both debuffs and buffs aren't being used.
	do
		if db.debuffs.enable or db.buffs.enable then
			if not frame:IsElementEnabled('Aura') then
				frame:EnableElement('Aura')
			end
		else
			if frame:IsElementEnabled('Aura') then
				frame:DisableElement('Aura')
			end
		end

		frame.Buffs:ClearAllPoints()
		frame.Debuffs:ClearAllPoints()
	end

	--Buffs
	do
		local buffs = frame.Buffs
		local rows = db.buffs.numrows

		if USE_POWERBAR_OFFSET then
			buffs:SetWidth(UNIT_WIDTH - POWERBAR_OFFSET)
		else
			buffs:SetWidth(UNIT_WIDTH)
		end

		buffs.forceShow = frame.forceShowAuras
		buffs.num = db.buffs.perrow * rows
		buffs.size = db.buffs.sizeOverride ~= 0 and db.buffs.sizeOverride or ((((buffs:GetWidth() - (buffs.spacing*(buffs.num/rows - 1))) / buffs.num)) * rows)

		if db.buffs.sizeOverride and db.buffs.sizeOverride > 0 then
			buffs:SetWidth(db.buffs.perrow * db.buffs.sizeOverride)
		end

		local x, y = E:GetXYOffset(db.buffs.anchorPoint)
		local attachTo = self:GetAuraAnchorFrame(frame, db.buffs.attachTo)

		buffs:Point(E.InversePoints[db.buffs.anchorPoint], attachTo, db.buffs.anchorPoint, x + db.buffs.xOffset, y + db.buffs.yOffset + (E.PixelMode and (db.buffs.anchorPoint:find('TOP') and -1 or 1) or 0))
		buffs:Height(buffs.size * rows)
		buffs["growth-y"] = db.buffs.anchorPoint:find('TOP') and 'UP' or 'DOWN'
		buffs["growth-x"] = db.buffs.anchorPoint == 'LEFT' and 'LEFT' or  db.buffs.anchorPoint == 'RIGHT' and 'RIGHT' or (db.buffs.anchorPoint:find('LEFT') and 'RIGHT' or 'LEFT')
		buffs.initialAnchor = E.InversePoints[db.buffs.anchorPoint]
		
		buffs.attachTo = attachTo
		buffs.point = E.InversePoints[db.buffs.anchorPoint]
		buffs.anchorPoint = db.buffs.anchorPoint
		buffs.xOffset = x + db.buffs.xOffset
		buffs.yOffset = y + db.buffs.yOffset + (E.PixelMode and (db.buffs.anchorPoint:find('TOP') and -1 or 1) or 0)

		if db.buffs.enable then
			buffs:Show()
			UF:UpdateAuraIconSettings(buffs)
		else
			buffs:Hide()
		end
	end

	--Debuffs
	do
		local debuffs = frame.Debuffs
		local rows = db.debuffs.numrows

		if USE_POWERBAR_OFFSET then
			debuffs:SetWidth(UNIT_WIDTH - POWERBAR_OFFSET)
		else
			debuffs:SetWidth(UNIT_WIDTH)
		end

		debuffs.forceShow = frame.forceShowAuras
		debuffs.num = db.debuffs.perrow * rows
		debuffs.size = db.debuffs.sizeOverride ~= 0 and db.debuffs.sizeOverride or ((((debuffs:GetWidth() - (debuffs.spacing*(debuffs.num/rows - 1))) / debuffs.num)) * rows)

		if db.debuffs.sizeOverride and db.debuffs.sizeOverride > 0 then
			debuffs:SetWidth(db.debuffs.perrow * db.debuffs.sizeOverride)
		end

		local x, y = E:GetXYOffset(db.debuffs.anchorPoint)
		local attachTo = self:GetAuraAnchorFrame(frame, db.debuffs.attachTo, db.debuffs.attachTo == 'BUFFS' and db.buffs.attachTo == 'DEBUFFS')

		debuffs:Point(E.InversePoints[db.debuffs.anchorPoint], attachTo, db.debuffs.anchorPoint, x + db.debuffs.xOffset, y + db.debuffs.yOffset)
		debuffs:Height(debuffs.size * rows)
		debuffs["growth-y"] = db.debuffs.anchorPoint:find('TOP') and 'UP' or 'DOWN'
		debuffs["growth-x"] = db.debuffs.anchorPoint == 'LEFT' and 'LEFT' or  db.debuffs.anchorPoint == 'RIGHT' and 'RIGHT' or (db.debuffs.anchorPoint:find('LEFT') and 'RIGHT' or 'LEFT')
		debuffs.initialAnchor = E.InversePoints[db.debuffs.anchorPoint]

		debuffs.attachTo = attachTo
		debuffs.point = E.InversePoints[db.debuffs.anchorPoint]
		debuffs.anchorPoint = db.debuffs.anchorPoint
		debuffs.xOffset = x + db.debuffs.xOffset
		debuffs.yOffset = y + db.debuffs.yOffset
		
		if db.debuffs.enable then
			debuffs:Show()
			UF:UpdateAuraIconSettings(debuffs)
		else
			debuffs:Hide()
		end
	end

	--Smart Aura Position
	do
		local position = db.smartAuraPosition

		if position == "BUFFS_ON_DEBUFFS" then
			if db.debuffs.attachTo == "BUFFS" then
				E:Print(format(L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."], L["Buffs"], L["Debuffs"], L["Frame"]))
				db.debuffs.attachTo = "FRAME"
				frame.Debuffs.attachTo = frame
			end
			frame.Buffs.PostUpdate = nil
			frame.Debuffs.PostUpdate = UF.UpdateBuffsHeaderPosition
		elseif position == "DEBUFFS_ON_BUFFS" then
			if db.buffs.attachTo == "DEBUFFS" then
				E:Print(format(L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."], L["Debuffs"], L["Buffs"], L["Frame"]))
				db.buffs.attachTo = "FRAME"
				frame.Buffs.attachTo = frame
			end
			frame.Buffs.PostUpdate = UF.UpdateDebuffsHeaderPosition
			frame.Debuffs.PostUpdate = nil
		else
			frame.Buffs.PostUpdate = nil
			frame.Debuffs.PostUpdate = nil
		end
	end

	--Castbar
	do
		local castbar = frame.Castbar
		castbar:Width(db.castbar.width - (BORDER * 2))
		castbar:Height(db.castbar.height)
		castbar.Holder:Width(db.castbar.width)
		castbar.Holder:Height(db.castbar.height + (E.PixelMode and 2 or (BORDER * 2)))
		castbar.Holder:GetScript('OnSizeChanged')(castbar.Holder)

		--Latency
		if db.castbar.latency then
			castbar.SafeZone = castbar.LatencyTexture
			castbar.LatencyTexture:Show()
		else
			castbar.SafeZone = nil
			castbar.LatencyTexture:Hide()
		end

		--Icon
		if db.castbar.icon then
			castbar.Icon = castbar.ButtonIcon
			castbar.Icon.bg:Width(db.castbar.height + (E.Border * 2))
			castbar.Icon.bg:Height(db.castbar.height + (E.Border * 2))

			castbar:Width(db.castbar.width - castbar.Icon.bg:GetWidth() - (E.PixelMode and 1 or 5))
			castbar.Icon.bg:Show()
		else
			castbar.ButtonIcon.bg:Hide()
			castbar.Icon = nil
		end

		if db.castbar.spark then
			castbar.Spark:Show()
		else
			castbar.Spark:Hide()
		end

		if db.castbar.enable and not frame:IsElementEnabled('Castbar') then
			frame:EnableElement('Castbar')
		elseif not db.castbar.enable and frame:IsElementEnabled('Castbar') then
			frame:DisableElement('Castbar')
		end
	end

	--Combo Bar
	do
		local CPoints = frame.CPoints
		CPoints:ClearAllPoints()

		if not db.combobar.detachFromFrame then
			CPoints:SetParent(frame)
		else
			CPoints:SetParent(E.UIParent)
		end

		if not USE_COMBOBAR or db.combobar.autoHide then
			CPoints:Hide()
		end

		if USE_MINI_COMBOBAR and not db.combobar.detachFromFrame then
			CPoints:Point("CENTER", frame.Health.backdrop, "TOP", -(BORDER*3 + 6), -SPACING)
			CPoints:SetFrameStrata("MEDIUM")
			if CPoints.mover then
				CPoints.mover:SetScale(0.000001)
				CPoints.mover:SetAlpha(0)
			end
		elseif not db.combobar.detachFromFrame then
			CPoints:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", BORDER, (E.PixelMode and 0 or (BORDER + SPACING)))
			CPoints:SetFrameStrata("LOW")
			if CPoints.mover then
				CPoints.mover:SetScale(0.000001)
				CPoints.mover:SetAlpha(0)
			end
		else
			COMBOBAR_WIDTH = db.combobar.detachedWidth - (BORDER*2)

			if not CPoints.mover then
				CPoints:Width(COMBOBAR_WIDTH)
				CPoints:Height(COMBOBAR_HEIGHT - (E.PixelMode and 1 or 4))
				CPoints:ClearAllPoints()
				CPoints:Point("BOTTOM", E.UIParent, "BOTTOM", 0, 150)
				E:CreateMover(CPoints, 'ComboBarMover', L["Combobar"], nil, nil, nil, 'ALL,SOLO')
			else
				CPoints:ClearAllPoints()
				CPoints:SetPoint("BOTTOMLEFT", CPoints.mover, "BOTTOMLEFT")
				CPoints.mover:SetScale(1)
				CPoints.mover:SetAlpha(1)
			end

			CPoints:SetFrameStrata("LOW")
		end

		CPoints:Width(COMBOBAR_WIDTH)
		CPoints:Height(COMBOBAR_HEIGHT - (E.PixelMode and 1 or 4))

		for i = 1, MAX_COMBO_POINTS do
			CPoints[i]:SetStatusBarColor(unpack(ElvUF.colors.ComboPoints[i]))
			CPoints[i]:SetHeight(CPoints:GetHeight())
			if db.combobar.fill == "spaced" then
				CPoints[i]:SetWidth(E:Scale(CPoints:GetWidth() - ((SPACING+(BORDER*2)+2) * (MAX_COMBO_POINTS - 1))) / MAX_COMBO_POINTS)
				CPoints[i].backdrop:Show()
			else
				CPoints[i]:SetWidth(E:Scale(CPoints:GetWidth() - (MAX_COMBO_POINTS - 1)) / MAX_COMBO_POINTS)
				CPoints[i].backdrop:Hide()
			end

			CPoints[i]:ClearAllPoints()
			if i == 1 then
				CPoints[i]:SetPoint("LEFT", CPoints)
			else
				if db.combobar.fill == "spaced" then
					CPoints[i]:Point("LEFT", CPoints[i-1], "RIGHT", SPACING+(BORDER*2)+2, 0)
				else
					CPoints[i]:Point("LEFT", CPoints[i-1], "RIGHT", 1, 0)
				end
			end

			if db.combobar.fill ~= "spaced" then
				CPoints[i].backdrop:Hide()
			else
				CPoints[i].backdrop:Show()
			end
		end

		if db.combobar.fill ~= "spaced" then
			CPoints.backdrop:Show()
		else
			CPoints.backdrop:Hide()
		end

		if USE_COMBOBAR and not frame:IsElementEnabled('CPoints') then
			frame:EnableElement('CPoints')
		elseif not USE_COMBOBAR and frame:IsElementEnabled('CPoints') then
			frame:DisableElement('CPoints')
			CPoints:Hide()
		end
	end

	--Debuff Highlight
	do
		local dbh = frame.DebuffHighlight
		if E.db.unitframe.debuffHighlighting ~= 'NONE' then
			if not frame:IsElementEnabled('DebuffHighlight') then
				frame:EnableElement('DebuffHighlight')
				frame.DebuffHighlightFilterTable = E.global.unitframe.DebuffHighlightColors
				if E.db.unitframe.debuffHighlighting == 'GLOW' then
					frame.DebuffHighlightBackdrop = true
					frame.DBHGlow:SetAllPoints(frame.Threat.glow)
				else
					frame.DebuffHighlightBackdrop = false
				end				
			end
		else
			if frame:IsElementEnabled('DebuffHighlight') then
				frame:DisableElement('DebuffHighlight')
			end
		end
	end

	--OverHealing
	do
		local healPrediction = frame.HealPrediction
		local c = UF.db.colors.healPrediction
		if db.healPrediction then
			if not frame:IsElementEnabled('HealPrediction') then
				frame:EnableElement('HealPrediction')
			end

			if not USE_PORTRAIT_OVERLAY then
				healPrediction.myBar:SetParent(frame)
				healPrediction.otherBar:SetParent(frame)
				healPrediction.absorbBar:SetParent(frame)
			else
				healPrediction.myBar:SetParent(frame.Portrait.overlay)
				healPrediction.otherBar:SetParent(frame.Portrait.overlay)
				healPrediction.absorbBar:SetParent(frame.Portrait.overlay)
			end
			healPrediction.myBar:SetStatusBarColor(c.personal.r, c.personal.g, c.personal.b, c.personal.a)
			healPrediction.otherBar:SetStatusBarColor(c.others.r, c.others.g, c.others.b, c.others.a)
			healPrediction.absorbBar:SetStatusBarColor(c.absorbs.r, c.absorbs.g, c.absorbs.b, c.absorbs.a)
		else
			if frame:IsElementEnabled('HealPrediction') then
				frame:DisableElement('HealPrediction')
			end
		end
	end
	
	--GPSArrow
	do
		local GPS = frame.GPS
		if db.GPSArrow.enable then
			if not frame:IsElementEnabled('GPS') then
				frame:EnableElement('GPS')
			end

			GPS:Size(db.GPSArrow.size)
			GPS.onMouseOver = db.GPSArrow.onMouseOver
			GPS.outOfRange = db.GPSArrow.outOfRange

			GPS:SetPoint("CENTER", frame, "CENTER", db.GPSArrow.xOffset, db.GPSArrow.yOffset)
		else
			if frame:IsElementEnabled('GPS') then
				frame:DisableElement('GPS')
			end
		end
	end

	--Raid Icon
	do
		local RI = frame.RaidIcon
		if db.raidicon.enable then
			frame:EnableElement('RaidIcon')
			RI:Show()
			RI:Size(db.raidicon.size)

			local x, y = self:GetPositionOffset(db.raidicon.attachTo)
			RI:ClearAllPoints()
			RI:Point(db.raidicon.attachTo, frame, db.raidicon.attachTo, x + db.raidicon.xOffset, y + db.raidicon.yOffset)
		else
			frame:DisableElement('RaidIcon')
			RI:Hide()
		end
	end

	--AuraBars
	do
		local auraBars = frame.AuraBars

		if db.aurabar.enable then
			if not frame:IsElementEnabled('AuraBars') then
				frame:EnableElement('AuraBars')
			end
			auraBars:Show()
			auraBars.friendlyAuraType = db.aurabar.friendlyAuraType
			auraBars.enemyAuraType = db.aurabar.enemyAuraType
			auraBars.scaleTime = db.aurabar.uniformThreshold

			local buffColor = UF.db.colors.auraBarBuff
			local debuffColor = UF.db.colors.auraBarDebuff
			local attachTo = frame

			if(E:CheckClassColor(buffColor.r, buffColor.g, buffColor.b)) then
				buffColor = E.myclass == 'PRIEST' and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])
			end

			if(E:CheckClassColor(debuffColor.r, debuffColor.g, debuffColor.b)) then
				debuffColor = E.myclass == 'PRIEST' and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])
			end

			if db.aurabar.attachTo == 'BUFFS' then
				attachTo = frame.Buffs
			elseif db.aurabar.attachTo == 'DEBUFFS' then
				attachTo = frame.Debuffs
			elseif db.aurabar.attachTo == 'PLAYER_AURABARS' and ElvUF_Player then
				attachTo = ElvUF_Player.AuraBars
			end

			local anchorPoint, anchorTo = 'BOTTOM', 'TOP'
			if db.aurabar.anchorPoint == 'BELOW' then
				anchorPoint, anchorTo = 'TOP', 'BOTTOM'
			end

			auraBars.auraBarHeight = db.aurabar.height

			local yOffset = 0;
			if E.PixelMode then
				if db.aurabar.anchorPoint == 'BELOW' then
					yOffset = 1;
				else
					yOffset = -1;
				end
			end

			auraBars:ClearAllPoints()
			auraBars:SetPoint(anchorPoint..'LEFT', attachTo, anchorTo..'LEFT', attachTo == frame and -POWERBAR_OFFSET * (anchorTo == 'BOTTOM' and 0 or -1) or 0, db.aurabar.attachTo == 'PLAYER_AURABARS' and 5 or yOffset)
			auraBars:SetPoint(anchorPoint..'RIGHT', attachTo, anchorTo..'RIGHT', (attachTo == frame and anchorTo == 'BOTTOM') and -POWERBAR_OFFSET or 0, db.aurabar.attachTo == 'PLAYER_AURABARS' and 5 or yOffset)

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
				auraBars.sort = UF.SortAuraBarReverse
			elseif db.aurabar.sort == 'TIME_DURATION' then
				auraBars.sort = UF.SortAuraBarDuration
			elseif db.aurabar.sort == 'TIME_DURATION_REVERSE' then
				auraBars.sort = UF.SortAuraBarDurationReverse
			elseif db.aurabar.sort == 'NAME' then
				auraBars.sort = UF.SortAuraBarName
			else
				auraBars.sort = nil
			end

			auraBars.maxBars = db.aurabar.maxBars
			auraBars.forceShow = frame.forceShowAuras
			auraBars:SetAnchors()
		else
			if frame:IsElementEnabled('AuraBars') then
				frame:DisableElement('AuraBars')
				auraBars:Hide()
			end
		end
	end

	--Range
	do
		local range = frame.Range
		if db.rangeCheck then
			if not frame:IsElementEnabled('Range') then
				frame:EnableElement('Range')
			end

			range.outsideAlpha = E.db.unitframe.OORAlpha
		else
			if frame:IsElementEnabled('Range') then
				frame:DisableElement('Range')
			end
		end
	end

	for objectName, object in pairs(frame.customTexts) do
		if (not db.customTexts) or (db.customTexts and not db.customTexts[objectName]) then
			object:Hide()
			frame.customTexts[objectName] = nil
		end
	end

	if db.customTexts then
		local customFont = UF.LSM:Fetch("font", UF.db.font)
		for objectName, _ in pairs(db.customTexts) do
			if not frame.customTexts[objectName] then
				frame.customTexts[objectName] = frame.RaisedElementParent:CreateFontString(nil, 'OVERLAY')
			end

			local objectDB = db.customTexts[objectName]

			if objectDB.font then
				customFont = UF.LSM:Fetch("font", objectDB.font)
			end

			frame.customTexts[objectName]:FontTemplate(customFont, objectDB.size or UF.db.fontSize, objectDB.fontOutline or UF.db.fontOutline)
			frame:Tag(frame.customTexts[objectName], objectDB.text_format or '')
			frame.customTexts[objectName]:SetJustifyH(objectDB.justifyH or 'CENTER')
			frame.customTexts[objectName]:ClearAllPoints()
			frame.customTexts[objectName]:SetPoint(objectDB.justifyH or 'CENTER', frame, objectDB.justifyH or 'CENTER', objectDB.xOffset, objectDB.yOffset)
		end
	end

	if UF.db.colors.transparentHealth then
		UF:ToggleTransparentStatusBar(true, frame.Health, frame.Health.bg)
	else
		UF:ToggleTransparentStatusBar(false, frame.Health, frame.Health.bg, (USE_PORTRAIT and USE_PORTRAIT_OVERLAY) ~= true)
	end

	UF:ToggleTransparentStatusBar(UF.db.colors.transparentPower, frame.Power, frame.Power.bg)

	E:SetMoverSnapOffset(frame:GetName()..'Mover', -(12 + db.castbar.height))
	frame:UpdateAllElements()
end

tinsert(UF['unitstoload'], 'target')
