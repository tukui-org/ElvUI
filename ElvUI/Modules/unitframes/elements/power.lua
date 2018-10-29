local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions
local random = random
--WoW API / Variables
local CreateFrame = CreateFrame

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

function UF:Construct_PowerBar(frame, bg, text, textPos)
	local power = CreateFrame('StatusBar', nil, frame)
	UF.statusbars[power] = true

	power.RaisedElementParent = CreateFrame('Frame', nil, power)
	power.RaisedElementParent:SetFrameLevel(power:GetFrameLevel() + 100)
	power.RaisedElementParent:SetAllPoints()

	power.PostUpdate = self.PostUpdatePower

	if bg then
		power.bg = power:CreateTexture(nil, 'BORDER')
		power.bg:SetAllPoints()
		power.bg:SetTexture(E.media.blankTex)
		power.bg.multiplier = 0.2
	end

	if text then
		power.value = frame.RaisedElementParent:CreateFontString(nil, 'OVERLAY')
		UF:Configure_FontString(power.value)

		local x = -2
		if textPos == 'LEFT' then
			x = 2
		end

		power.value:Point(textPos, frame.Health, textPos, x, 0)
	end

	power.colorDisconnected = false
	power.colorTapping = false
	power:CreateBackdrop('Default', nil, nil, self.thinBorders, true)

	return power
end

function UF:Configure_Power(frame)
	if not frame.VARIABLES_SET then return end
	local db = frame.db
	local power = frame.Power
	power.origParent = frame

	if frame.USE_POWERBAR then
		if not frame:IsElementEnabled('Power') then
			frame:EnableElement('Power')
			power:Show()
		end

		power.Smooth = self.db.smoothbars

		--Text
		local attachPoint = self:GetObjectAnchorPoint(frame, db.power.attachTextTo)
		power.value:ClearAllPoints()
		power.value:Point(db.power.position, attachPoint, db.power.position, db.power.xOffset, db.power.yOffset)
		frame:Tag(power.value, db.power.text_format)

		if db.power.attachTextTo == "Power" then
			power.value:SetParent(power.RaisedElementParent)
		else
			power.value:SetParent(frame.RaisedElementParent)
		end

		if db.power.reverseFill then
			power:SetReverseFill(true)
		else
			power:SetReverseFill(false)
		end

		--Colors
		power.colorClass = nil
		power.colorReaction = nil
		power.colorPower = nil

		if self.db.colors.powerclass then
			power.colorClass = true
			power.colorReaction = true
		else
			power.colorPower = true
		end

		--Fix height in case it is lower than the theme allows
		local heightChanged = false
		if (not self.thinBorders and not E.PixelMode) and frame.POWERBAR_HEIGHT < 7 then --A height of 7 means 6px for borders and just 1px for the actual power statusbar
			frame.POWERBAR_HEIGHT = 7
			if db.power then db.power.height = 7 end
			heightChanged = true
		elseif (self.thinBorders or E.PixelMode) and frame.POWERBAR_HEIGHT < 3 then --A height of 3 means 2px for borders and just 1px for the actual power statusbar
			frame.POWERBAR_HEIGHT = 3
			if db.power then db.power.height = 3 end
			heightChanged = true
		end
		if heightChanged then
			--Update health size
			frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame)
			UF:Configure_HealthBar(frame)
		end

		--Position
		power:ClearAllPoints()
		if frame.POWERBAR_DETACHED then
			power:Width(frame.POWERBAR_WIDTH - ((frame.BORDER + frame.SPACING)*2))
			power:Height(frame.POWERBAR_HEIGHT - ((frame.BORDER + frame.SPACING)*2))
			if not power.Holder or (power.Holder and not power.Holder.mover) then
				power.Holder = CreateFrame("Frame", nil, power)
				power.Holder:Size(frame.POWERBAR_WIDTH, frame.POWERBAR_HEIGHT)
				power.Holder:Point("BOTTOM", frame, "BOTTOM", 0, -20)
				power:ClearAllPoints()
				power:Point("BOTTOMLEFT", power.Holder, "BOTTOMLEFT", frame.BORDER+frame.SPACING, frame.BORDER+frame.SPACING)
				--Currently only Player and Target can detach power bars, so doing it this way is okay for now
				if frame.unitframeType and frame.unitframeType == "player" then
					E:CreateMover(power.Holder, 'PlayerPowerBarMover', L["Player Powerbar"], nil, nil, nil, 'ALL,SOLO', nil, 'unitframe,player,power')
				elseif frame.unitframeType and frame.unitframeType == "target" then
					E:CreateMover(power.Holder, 'TargetPowerBarMover', L["Target Powerbar"], nil, nil, nil, 'ALL,SOLO', nil, 'unitframe,target,power')
				end
			else
				power.Holder:Size(frame.POWERBAR_WIDTH, frame.POWERBAR_HEIGHT)
				power:ClearAllPoints()
				power:Point("BOTTOMLEFT", power.Holder, "BOTTOMLEFT", frame.BORDER+frame.SPACING, frame.BORDER+frame.SPACING)
				power.Holder.mover:SetScale(1)
				power.Holder.mover:SetAlpha(1)
			end

			power:SetFrameLevel(50) --RaisedElementParent uses 100, we want lower value to allow certain icons and texts to appear above power
		elseif frame.USE_POWERBAR_OFFSET then
			if frame.ORIENTATION == "LEFT" then
				power:Point("TOPRIGHT", frame.Health, "TOPRIGHT", frame.POWERBAR_OFFSET, -frame.POWERBAR_OFFSET)
				power:Point("BOTTOMLEFT", frame.Health, "BOTTOMLEFT", frame.POWERBAR_OFFSET, -frame.POWERBAR_OFFSET)
			elseif frame.ORIENTATION == "MIDDLE" then
				power:Point("TOPLEFT", frame, "TOPLEFT", frame.BORDER + frame.SPACING, -frame.POWERBAR_OFFSET -frame.CLASSBAR_YOFFSET)
				power:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -frame.BORDER - frame.SPACING, frame.BORDER)
			else
				power:Point("TOPLEFT", frame.Health, "TOPLEFT", -frame.POWERBAR_OFFSET, -frame.POWERBAR_OFFSET)
				power:Point("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", -frame.POWERBAR_OFFSET, -frame.POWERBAR_OFFSET)
			end
			power:SetFrameLevel(frame.Health:GetFrameLevel() -5) --Health uses 10
		elseif frame.USE_INSET_POWERBAR then
			power:Height(frame.POWERBAR_HEIGHT  - ((frame.BORDER + frame.SPACING)*2))
			power:Point("BOTTOMLEFT", frame.Health, "BOTTOMLEFT", frame.BORDER + (frame.BORDER*2), frame.BORDER + (frame.BORDER*2))
			power:Point("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", -(frame.BORDER + (frame.BORDER*2)), frame.BORDER + (frame.BORDER*2))
			power:SetFrameLevel(50)
		elseif frame.USE_MINI_POWERBAR then
			power:Height(frame.POWERBAR_HEIGHT  - ((frame.BORDER + frame.SPACING)*2))

			if frame.ORIENTATION == "LEFT" then
				power:Width(frame.POWERBAR_WIDTH - frame.BORDER*2)
				power:Point("RIGHT", frame, "BOTTOMRIGHT", -(frame.BORDER*2 + 4), ((frame.POWERBAR_HEIGHT-frame.BORDER)/2))
			elseif frame.ORIENTATION == "RIGHT" then
				power:Width(frame.POWERBAR_WIDTH - frame.BORDER*2)
				power:Point("LEFT", frame, "BOTTOMLEFT", (frame.BORDER*2 + 4), ((frame.POWERBAR_HEIGHT-frame.BORDER)/2))
			else
				power:Point("LEFT", frame, "BOTTOMLEFT", (frame.BORDER*2 + 4), ((frame.POWERBAR_HEIGHT-frame.BORDER)/2))
				power:Point("RIGHT", frame, "BOTTOMRIGHT", -(frame.BORDER*2 + 4 + (frame.PVPINFO_WIDTH or 0)), ((frame.POWERBAR_HEIGHT-frame.BORDER)/2))
			end

			power:SetFrameLevel(50)
		else
			power:Point("TOPRIGHT", frame.Health.backdrop, "BOTTOMRIGHT", -frame.BORDER,  -frame.SPACING*3)
			power:Point("TOPLEFT", frame.Health.backdrop, "BOTTOMLEFT", frame.BORDER, -frame.SPACING*3)
			power:Height(frame.POWERBAR_HEIGHT  - ((frame.BORDER + frame.SPACING)*2))

			power:SetFrameLevel(frame.Health:GetFrameLevel() - 5)
		end

		--Hide mover until we detach again
		if not frame.POWERBAR_DETACHED then
			if power.Holder and power.Holder.mover then
				power.Holder.mover:SetScale(0.0001)
				power.Holder.mover:SetAlpha(0)
			end
		end

		if db.power.strataAndLevel and db.power.strataAndLevel.useCustomStrata then
			power:SetFrameStrata(db.power.strataAndLevel.frameStrata)
		else
			power:SetFrameStrata("LOW")
		end
		if db.power.strataAndLevel and db.power.strataAndLevel.useCustomLevel then
			power:SetFrameLevel(db.power.strataAndLevel.frameLevel)
			power.backdrop:SetFrameLevel(power:GetFrameLevel() - 1)
		end

		if frame.POWERBAR_DETACHED and db.power.parent == "UIPARENT" then
			E.FrameLocks[power] = true
			power:SetParent(E.UIParent)
		else
			E.FrameLocks[power] = nil
			power:SetParent(frame)
		end

	elseif frame:IsElementEnabled('Power') then
		frame:DisableElement('Power')
		power:Hide()
		frame:Tag(power.value, "")
	end

	--Transparency Settings
	UF:ToggleTransparentStatusBar(UF.db.colors.transparentPower, frame.Power, frame.Power.bg)
end

local tokens = { [0] = "MANA", "RAGE", "FOCUS", "ENERGY", "RUNIC_POWER" }
function UF:PostUpdatePower(unit, _, _, max)
	local parent = self.origParent or self:GetParent()

	if parent.isForced then
		local pType = random(0, 4)
		local color = ElvUF.colors.power[tokens[pType]]
		local min = random(1, max)
		self:SetValue(min)

		if not self.colorClass then
			self:SetStatusBarColor(color[1], color[2], color[3])
			local mu = self.bg.multiplier or 1
			self.bg:SetVertexColor(color[1] * mu, color[2] * mu, color[3] * mu)
		end
	end

	local db = parent.db
	if db and db.power and db.power.hideonnpc then
		UF:PostNamePosition(parent, unit)
	end

	--Force update to AdditionalPower in order to reposition text if necessary
	if parent:IsElementEnabled("AdditionalPower") then
		E:Delay(0.01, parent.AdditionalPower.ForceUpdate, parent.AdditionalPower) --Delay it slightly so Power text has a chance to clear itself first
	end
end
