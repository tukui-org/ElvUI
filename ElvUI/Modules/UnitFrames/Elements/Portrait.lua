local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

local rad = rad
local unpack = unpack
local select = select
local UnitClass = UnitClass
local CreateFrame = CreateFrame
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local classIcon = 'Interface\\WorldStateFrame\\Icons-Classes'

function UF:Construct_Portrait(frame, type)
	local portrait

	if type == 'texture' then
		local backdrop = CreateFrame('Frame', nil, frame)
		portrait = frame:CreateTexture(nil, 'OVERLAY')
		portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		backdrop:SetOutside(portrait)
		backdrop:SetFrameLevel(frame:GetFrameLevel())
		backdrop:SetTemplate()
		portrait.backdrop = backdrop
	else
		portrait = CreateFrame("PlayerModel", nil, frame)
		portrait:CreateBackdrop(nil, nil, nil, self.thinBorders, true)
	end

	portrait.PostUpdate = self.PortraitUpdate

	return portrait
end

function UF:Configure_Portrait(frame)
	local last = frame.Portrait
	if last then
		last:Hide()
		last.backdrop:Hide()
	end

	local db = frame.db
	local portrait = (db.portrait.style == '3D' and frame.Portrait3D) or frame.Portrait2D
	portrait.db = db.portrait
	frame.Portrait = portrait

	if portrait.db.style == 'Class' then
		portrait:SetTexture(classIcon)
		portrait.customTexture = classIcon
	elseif portrait.db.style == '2D' then
		portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		portrait.customTexture = nil
	end

	if frame.USE_PORTRAIT then
		if not frame:IsElementEnabled('Portrait') then
			frame:EnableElement('Portrait')
		end

		portrait:Show()
		portrait:ClearAllPoints()
		portrait.backdrop:ClearAllPoints()

		if portrait.db.style == '3D' then
			portrait:SetFrameLevel(frame.Health:GetFrameLevel())
		else
			portrait:SetParent(frame.USE_PORTRAIT_OVERLAY and frame.Health or frame)
		end

		if frame.USE_PORTRAIT_OVERLAY then
			portrait:SetAlpha(portrait.db.overlayAlpha)
			portrait.backdrop:Hide()

			if portrait.db.fullOverlay then
				portrait:SetAllPoints(frame.Health)
			else
				local healthTex = frame.Health:GetStatusBarTexture()
				if db.health.reverseFill then
					portrait:Point("TOPLEFT", healthTex, "TOPLEFT")
					portrait:Point("BOTTOMLEFT", healthTex, "BOTTOMLEFT")
					portrait:Point("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT")
				else
					portrait:Point("TOPLEFT", frame.Health, "TOPLEFT")
					portrait:Point("BOTTOMRIGHT", healthTex, "BOTTOMRIGHT")
					portrait:Point("BOTTOMLEFT", healthTex, "BOTTOMLEFT")
				end
			end
		else
			portrait:SetAlpha(1)
			portrait.backdrop:Show()
			portrait:SetInside(portrait.backdrop, frame.BORDER)

			if frame.ORIENTATION == "LEFT" then
				portrait.backdrop:Point("TOPLEFT", frame, "TOPLEFT", frame.SPACING, frame.USE_MINI_CLASSBAR and -(frame.CLASSBAR_YOFFSET+frame.SPACING) or -frame.SPACING)

				if frame.USE_MINI_POWERBAR or frame.USE_POWERBAR_OFFSET or not frame.USE_POWERBAR or frame.USE_INSET_POWERBAR or frame.POWERBAR_DETACHED then
					portrait.backdrop:Point("BOTTOMRIGHT", frame.Health.backdrop, "BOTTOMLEFT", frame.BORDER - frame.SPACING*3, 0)
				else
					portrait.backdrop:Point("BOTTOMRIGHT", frame.Power.backdrop, "BOTTOMLEFT", frame.BORDER - frame.SPACING*3, 0)
				end
			elseif frame.ORIENTATION == "RIGHT" then
				portrait.backdrop:Point("TOPRIGHT", frame, "TOPRIGHT", -frame.SPACING, frame.USE_MINI_CLASSBAR and -(frame.CLASSBAR_YOFFSET+frame.SPACING) or -frame.SPACING)

				if frame.USE_MINI_POWERBAR or frame.USE_POWERBAR_OFFSET or not frame.USE_POWERBAR or frame.USE_INSET_POWERBAR or frame.POWERBAR_DETACHED then
					portrait.backdrop:Point("BOTTOMLEFT", frame.Health.backdrop, "BOTTOMRIGHT", -frame.BORDER + frame.SPACING*3, 0)
				else
					portrait.backdrop:Point("BOTTOMLEFT", frame.Power.backdrop, "BOTTOMRIGHT", -frame.BORDER + frame.SPACING*3, 0)
				end
			end
		end
	else
		if frame:IsElementEnabled('Portrait') then
			frame:DisableElement('Portrait')
		end

		portrait.backdrop:Hide()
		portrait:Hide()
	end
end

function UF:PortraitUpdate(unit, event)
	if self.stateChanged or event == 'ElvUI_UpdateAllElements' then
		local db = self.db
		if not db then return end

		if self.playerModel then
			if self.state then
				self:SetCamDistanceScale(db.camDistanceScale)
				self:SetViewTranslation(db.xOffset * 100, db.yOffset * 100)
				self:SetRotation(rad(db.rotation))
			end

			self:SetDesaturation(db.desaturation)
			self:SetPaused(db.paused)
		elseif db.style == 'Class' then
			local Class = select(2, UnitClass(unit))
			self:SetTexCoord(unpack(CLASS_ICON_TCOORDS[Class]))
		end
	end
end
