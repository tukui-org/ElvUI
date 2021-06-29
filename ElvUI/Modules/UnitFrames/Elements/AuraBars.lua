local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames')

local _G = _G
local ipairs = ipairs
local unpack = unpack
local CreateFrame = CreateFrame

function UF:Construct_AuraBars(statusBar)
	statusBar:CreateBackdrop(nil, nil, nil, nil, true)
	statusBar:SetScript('OnMouseDown', UF.Aura_OnClick)
	statusBar:Point('LEFT')
	statusBar:Point('RIGHT')

	statusBar.icon:CreateBackdrop(nil, nil, nil, nil, true)
	UF.statusbars[statusBar] = true
	UF:Update_StatusBar(statusBar)

	UF:Configure_FontString(statusBar.timeText)
	UF:Configure_FontString(statusBar.nameText)

	UF:Update_FontString(statusBar.timeText)
	UF:Update_FontString(statusBar.nameText)

	statusBar.nameText:SetJustifyH('LEFT')
	statusBar.nameText:SetJustifyV('MIDDLE')
	statusBar.nameText:Point('RIGHT', statusBar.timeText, 'LEFT', -4, 0)
	statusBar.nameText:SetWordWrap(false)

	statusBar.bg = statusBar:CreateTexture(nil, 'BORDER')
	statusBar.bg:Show()

	local frame = statusBar:GetParent()
	statusBar.db = frame.db and frame.db.aurabar
end

function UF:AuraBars_SetPosition(from, to)
	local anchor = self.initialAnchor
	local growth = (self.growth == 'BELOW' and -1) or 1
	local SPACING = UF.thinBorders and 1 or 5

	for i = from, to do
		local button = self[i]
		if not button then break end

		button:ClearAllPoints()
		button:Point(anchor, self, anchor, SPACING, (i == 1 and 0) or (growth * ((i - 1) * (self.height + self.spacing))))

		button.icon:ClearAllPoints()
		button.icon:Point('RIGHT', button, 'LEFT', -SPACING, 0)
	end
end

function UF:Construct_AuraBarHeader(frame)
	local auraBar = CreateFrame('Frame', '$parent_AuraBars', frame)
	auraBar:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 10)
	auraBar:Height(1)
	auraBar.PreSetPosition = UF.SortAuras
	auraBar.PostCreateBar = UF.Construct_AuraBars
	auraBar.PostUpdateBar = UF.PostUpdateBar_AuraBars
	auraBar.CustomFilter = UF.AuraFilter
	auraBar.SetPosition = UF.AuraBars_SetPosition

	auraBar.sparkEnabled = true
	auraBar.initialAnchor = 'BOTTOMRIGHT'
	auraBar.type = 'aurabar'

	return auraBar
end

function UF:Configure_AuraBars(frame)
	local auraBars = frame.AuraBars
	local db = frame.db
	auraBars.db = db.aurabar

	if db.aurabar.enable then
		if not frame:IsElementEnabled('AuraBars') then
			frame:EnableElement('AuraBars')
		end

		auraBars.height = db.aurabar.height
		auraBars.growth = db.aurabar.anchorPoint
		auraBars.maxBars = db.aurabar.maxBars
		auraBars.spacing = db.aurabar.spacing
		auraBars.friendlyAuraType = db.aurabar.friendlyAuraType
		auraBars.enemyAuraType = db.aurabar.enemyAuraType
		auraBars.disableMouse = db.aurabar.clickThrough
		auraBars.filterList = UF:ConvertFilters(auraBars, db.aurabar.priority)

		for _, statusBar in ipairs(auraBars) do
			statusBar.db = auraBars.db
			UF:Update_FontString(statusBar.timeText)
			UF:Update_FontString(statusBar.nameText)
		end

		local colors = UF.db.colors.auraBarBuff
		if E:CheckClassColor(colors.r, colors.g, colors.b) then
			local classColor = E:ClassColor(E.myclass, true)
			colors.r, colors.g, colors.b = classColor.r, classColor.g, classColor.b
		end

		colors = UF.db.colors.auraBarDebuff
		if E:CheckClassColor(colors.r, colors.g, colors.b) then
			local classColor = E:ClassColor(E.myclass, true)
			colors.r, colors.g, colors.b = classColor.r, classColor.g, classColor.b
		end

		if not auraBars.Holder then
			local holder = CreateFrame('Frame', nil, auraBars)
			holder:Point('BOTTOM', frame, 'TOP', 0, 0)
			auraBars.Holder = holder

			if frame.unitframeType == 'player' then
				E:CreateMover(holder, 'ElvUF_PlayerAuraMover', 'Player Aura Bars', nil, nil, nil, 'ALL,SOLO', nil, 'unitframe,individualUnits,player,aurabar')
			elseif frame.unitframeType == 'target' then
				E:CreateMover(holder, 'ElvUF_TargetAuraMover', 'Target Aura Bars', nil, nil, nil, 'ALL,SOLO', nil, 'unitframe,individualUnits,target,aurabar')
			elseif frame.unitframeType == 'pet' then
				E:CreateMover(holder, 'ElvUF_PetAuraMover', 'Pet Aura Bars', nil, nil, nil, 'ALL,SOLO', nil, 'unitframe,individualUnits,pet,aurabar')
			elseif frame.unitframeType == 'focus' then
				E:CreateMover(holder, 'ElvUF_FocusAuraMover', 'Focus Aura Bars', nil, nil, nil, 'ALL,SOLO', nil, 'unitframe,individualUnits,focus,aurabar')
			end
		end

		local attachTo = frame
		local BORDER, SPACING, xOffset, yOffset = UF.BORDER + UF.SPACING
		if db.aurabar.attachTo == 'BUFFS' then
			attachTo = frame.Buffs
		elseif db.aurabar.attachTo == 'DEBUFFS' then
			attachTo = frame.Debuffs
		elseif db.aurabar.attachTo == 'DETACHED' then
			attachTo = auraBars.Holder
		elseif db.aurabar.attachTo == 'PLAYER_AURABARS' and _G.ElvUF_Player then
			attachTo = _G.ElvUF_Player.AuraBars
			xOffset = 0
		end

		local anchorPoint, anchorTo = 'BOTTOM', 'TOP'
		if db.aurabar.anchorPoint == 'BELOW' then
			anchorPoint, anchorTo = 'TOP', 'BOTTOM'
		end

		if db.aurabar.attachTo == 'DETACHED' then
			E:EnableMover(auraBars.Holder.mover:GetName())
			SPACING = UF.thinBorders and 1 or 5

			auraBars.Holder:Size(db.aurabar.detachedWidth, db.aurabar.height + (BORDER * 2))

			if db.aurabar.anchorPoint == 'BELOW' then
				yOffset = BORDER + (UF.BORDER - UF.SPACING)
			else
				yOffset = -(db.aurabar.height + BORDER)
			end
		else
			E:DisableMover(auraBars.Holder.mover:GetName())
			SPACING = UF.thinBorders and 1 or 4

			local offset = db.aurabar.yOffset + (UF.thinBorders and 0 or 2)
			if db.aurabar.anchorPoint == 'BELOW' then
				yOffset = -(db.aurabar.height + offset)
			else
				yOffset = offset + 1 -- 1 is connecting pixel
			end
		end

		local POWER_OFFSET = 0
		if db.aurabar.attachTo ~= 'DETACHED' and db.aurabar.attachTo ~= 'FRAME' then
			POWER_OFFSET = frame.POWERBAR_OFFSET

			if frame.ORIENTATION == 'MIDDLE' then
				POWER_OFFSET = POWER_OFFSET * 2
			end
		end

		auraBars:ClearAllPoints()
		auraBars:Point(anchorPoint..'LEFT', attachTo, anchorTo..'LEFT', xOffset or -SPACING, yOffset)
		auraBars:Point(anchorPoint..'RIGHT', attachTo, anchorTo..'RIGHT', xOffset or -(SPACING + BORDER), yOffset)

		auraBars.width = E:Scale((db.aurabar.attachTo == 'DETACHED' and db.aurabar.detachedWidth or frame.UNIT_WIDTH) - (BORDER * 4) - auraBars.height - POWER_OFFSET + 1) -- 1 is connecting pixel
		auraBars:Show()
	elseif frame:IsElementEnabled('AuraBars') then
		frame:DisableElement('AuraBars')
		auraBars:Hide()
	end
end

local GOTAK_ID = 86659
local GOTAK = GetSpellInfo(GOTAK_ID)
function UF:PostUpdateBar_AuraBars(_, statusBar, _, _, _, _, debuffType) -- unit, statusBar, index, position, duration, expiration, debuffType, isStealable
	local spellID = statusBar.spellID
	local spellName = statusBar.spell

	statusBar.db = self.db
	statusBar.icon:SetTexCoord(unpack(E.TexCoords))

	local colors = E.global.unitframe.AuraBarColors[spellID] and E.global.unitframe.AuraBarColors[spellID].enable and E.global.unitframe.AuraBarColors[spellID].color

	if E.db.unitframe.colors.auraBarTurtle and (E.global.unitframe.aurafilters.TurtleBuffs.spells[spellID] or E.global.unitframe.aurafilters.TurtleBuffs.spells[spellName]) and not colors and (spellName ~= GOTAK or (spellName == GOTAK and spellID == GOTAK_ID)) then
		colors = E.db.unitframe.colors.auraBarTurtleColor
	end

	if not colors then
		if UF.db.colors.auraBarByType and statusBar.filter == 'HARMFUL' then
			if not debuffType or (debuffType == '' or debuffType == 'none') then
				colors = UF.db.colors.auraBarDebuff
			else
				colors = _G.DebuffTypeColor[debuffType]
			end
		elseif statusBar.filter == 'HARMFUL' then
			colors = UF.db.colors.auraBarDebuff
		else
			colors = UF.db.colors.auraBarBuff
		end
	end

	statusBar.custom_backdrop = UF.db.colors.customaurabarbackdrop and UF.db.colors.aurabar_backdrop

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
