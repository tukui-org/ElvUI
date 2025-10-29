local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local rad = rad
local unpack = unpack
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

function UF:ModelAlphaFix(value)
	local portrait = self.Portrait3D
	if portrait then
		local alpha = value * portrait:GetAlpha()
		portrait:SetModelAlpha(alpha)
		portrait.backdrop:SetAlpha(alpha)
	end
end

function UF:Construct_Portrait(frame, which)
	local portrait

	if which == 'texture' then
		local backdrop = CreateFrame('Frame', nil, frame)
		portrait = frame:CreateTexture(nil, 'OVERLAY')
		portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		backdrop:SetOutside(portrait)
		backdrop:OffsetFrameLevel(nil, frame)
		backdrop:SetTemplate(nil, nil, nil, nil, true)
		portrait.backdrop = backdrop
		portrait.useClassBase = true
	else
		portrait = CreateFrame('PlayerModel', nil, frame)
		portrait:CreateBackdrop(nil, nil, nil, nil, true)

		-- https://github.com/Stanzilla/WoWUIBugs/issues/295
		-- since this seems to be forced on models because of a bug
		portrait:SetIgnoreParentAlpha(true) -- lets handle it ourselves
		portrait.backdrop:SetIgnoreParentAlpha(true)
		hooksecurefunc(frame, 'SetAlpha', UF.ModelAlphaFix)
	end

	portrait.__owner = frame -- set this for both, oUF will only set it when active
	portrait.PostUpdate = UF.PortraitUpdate

	return portrait
end

function UF:Configure_Portrait(frame)
	local db = frame.db
	local portrait = (db.portrait.style == '3D' and frame.Portrait3D) or frame.Portrait2D
	portrait.db = db.portrait

	if frame.Portrait ~= portrait then
		if frame.Portrait then -- previous style, so we hide it
			frame.Portrait:Hide()
			frame.Portrait.backdrop:Hide()
		end

		frame.Portrait = portrait -- then update the new one
	end

	portrait.backdrop:SetShown(frame.USE_PORTRAIT and not frame.USE_PORTRAIT_OVERLAY)
	portrait:SetAlpha(frame.USE_PORTRAIT_OVERLAY and portrait.db.overlayAlpha or 1)
	portrait:SetShown(frame.USE_PORTRAIT)

	if frame.USE_PORTRAIT then
		if not frame:IsElementEnabled('Portrait') then
			frame:EnableElement('Portrait')
		end

		if portrait.db.style == '3D' then
			portrait:OffsetFrameLevel(nil, frame.Health)
		else
			portrait:SetParent(frame.USE_PORTRAIT_OVERLAY and frame.Health or frame)
		end

		portrait:ClearAllPoints()
		portrait.backdrop:ClearAllPoints()

		if frame.USE_PORTRAIT_OVERLAY then
			if portrait.db.fullOverlay then
				portrait:SetInside(frame.Health, 0, 0)
			else
				local healthTex = frame.Health:GetStatusBarTexture()
				local orientation = frame.Health:GetOrientation()
				if orientation == 'VERTICAL' then
					if db.health.reverseFill then
						portrait:SetInside(frame.Health, 0, 0, healthTex)
					else
						portrait:SetInside(healthTex, 0, 0, frame.Health)
					end
				elseif db.health.reverseFill then
					portrait:SetInside(healthTex, 0, 0, frame.Health)
				else
					portrait:SetInside(frame.Health, 0, 0, healthTex)
				end
			end
		else
			portrait:SetInside(portrait.backdrop, UF.BORDER, UF.BORDER)

			if frame.ORIENTATION == 'LEFT' then
				portrait.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', UF.SPACING, frame.USE_MINI_CLASSBAR and -(frame.CLASSBAR_YOFFSET+UF.SPACING) or -UF.SPACING)

				if frame.USE_MINI_POWERBAR or frame.USE_POWERBAR_OFFSET or not frame.USE_POWERBAR or frame.USE_INSET_POWERBAR or frame.POWERBAR_DETACHED then
					portrait.backdrop:Point('BOTTOMRIGHT', frame.Health.backdrop, 'BOTTOMLEFT', UF.BORDER - UF.SPACING*3, 0)
				else
					portrait.backdrop:Point('BOTTOMRIGHT', frame.Power.backdrop, 'BOTTOMLEFT', UF.BORDER - UF.SPACING*3, 0)
				end
			elseif frame.ORIENTATION == 'RIGHT' then
				portrait.backdrop:Point('TOPRIGHT', frame, 'TOPRIGHT', -UF.SPACING, frame.USE_MINI_CLASSBAR and -(frame.CLASSBAR_YOFFSET+UF.SPACING) or -UF.SPACING)

				if frame.USE_MINI_POWERBAR or frame.USE_POWERBAR_OFFSET or not frame.USE_POWERBAR or frame.USE_INSET_POWERBAR or frame.POWERBAR_DETACHED then
					portrait.backdrop:Point('BOTTOMLEFT', frame.Health.backdrop, 'BOTTOMRIGHT', -UF.BORDER + UF.SPACING*3, 0)
				else
					portrait.backdrop:Point('BOTTOMLEFT', frame.Power.backdrop, 'BOTTOMRIGHT', -UF.BORDER + UF.SPACING*3, 0)
				end
			end
		end
	elseif frame:IsElementEnabled('Portrait') then
		frame:DisableElement('Portrait')
	end
end

function UF:PortraitUpdate(unit, hasStateChanged, texCoords)
	if not hasStateChanged then return end

	if self.playerModel then
		local db = self.db
		if not db then return end

		if self.state then
			self:SetCamDistanceScale(db.camDistanceScale or 2)
			self:SetViewTranslation((db.xOffset or 0) * 100, (db.yOffset or 0) * 100)
			self:SetRotation(rad(db.rotation or 0))
		end

		-- mimic ModelAlphaFix, so when the module updates the correct alpha is set
		local frame = self.__owner
		local alpha = frame.USE_PORTRAIT_OVERLAY and db.overlayAlpha or 1
		self:SetModelAlpha(alpha * frame:GetAlpha())

		-- handle the other settings
		self:SetDesaturation(db.desaturation or 0)
		self:SetPaused(db.paused or false)
	elseif self.useClassBase then
		if texCoords then
			local left, right, top, bottom = unpack(texCoords)
			self:SetTexCoord(left+0.02, right-0.02, top+0.02, bottom-0.02)
		else
			self:SetTexCoords()
		end
	end
end
