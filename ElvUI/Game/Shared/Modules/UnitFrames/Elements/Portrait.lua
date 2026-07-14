local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local rad = rad
local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame
local UnitClass = UnitClass

local classIcon = [[Interface\WorldStateFrame\Icons-Classes]]

local UnitGUID = UnitGUID
local UnitIsPlayer = UnitIsPlayer
local UnitIsVisible = UnitIsVisible
local UnitIsConnected = UnitIsConnected
local SetPortraitTexture = SetPortraitTexture
local IsUnitModelReadyForUI = IsUnitModelReadyForUI

local function HidePortraitFallback(element)
	if element.Fallback2DFrame then
		element.Fallback2DFrame:Hide()
	end
	if element.Fallback2D then
		element.Fallback2D:Hide()
	end
end

local function HasPortraitModel(element)
	return not element.GetModelFileID or element:GetModelFileID()
end

local function HidePortraitFallbackIfLoaded(element)
	if element.hasSecretUnit then return false end -- handled by OnModelLoadedCheck
	if HasPortraitModel(element) then
		HidePortraitFallback(element)
		return true
	end
end

-- A secret-identity unit cannot be passed to PlayerModel:SetUnit on 12.0.5+.
-- Ignore stale model callbacks for it and keep the supported 2D cover visible.
local function OnModelLoadedCheck(element)
	if element.hasSecretUnit then return end
	HidePortraitFallback(element)
end

local function RetryPortraitModel(element, unit)
	if not C_Timer then return end
	if element.modelRetryUnit == unit then return end

	element.modelRetryUnit = unit
	element.modelRetryCount = 0

	local function retry()
		if element.modelRetryUnit ~= unit then return end
		if not element:IsShown() then
			element.modelRetryUnit = nil
			element.modelRetryCount = nil
			return
		end
		if HidePortraitFallbackIfLoaded(element) then
			element.modelRetryUnit = nil
			element.modelRetryCount = nil
			return
		end

		local retryCount = (element.modelRetryCount or 0) + 1
		element.modelRetryCount = retryCount
		element:ClearModel()
		element:SetUnit(unit)
		if HidePortraitFallbackIfLoaded(element) then
			element.modelRetryUnit = nil
			element.modelRetryCount = nil
			return
		end

		if element.modelRetryUnit == unit and retryCount < 10 then
			C_Timer.After(0.25 * retryCount, retry)
		end
	end

	C_Timer.After(0.1, retry)
end

function UF.PortraitForceUpdate(frame, event, unit)
	if unit == frame.unit then
		local element = frame.Portrait
		if element and element.Override then
			element.Override(frame, event, unit)
		end
	end
end

function UF:ModelAlphaFix(value)
	local portrait = self.Portrait3D
	if not portrait then return end

	local alpha = portrait:GetAlpha()
	local modelAlpha = value * (E:IsSecretValue(alpha) and 1 or alpha)
	portrait:SetModelAlpha(modelAlpha)
	portrait.backdrop:SetAlpha(modelAlpha)
end

function UF:PortraitOverride(event)
	local element = self.Portrait
	if not element then return end
	element.elvPortraitPatch = 1

	local unit = self.unit
	if not unit then return end

	local guid = UnitGUID(unit)
	local secretGUID = E:IsSecretValue(guid)
	element.hasSecretUnit = secretGUID
	local storedGUID = element.guid
	local secretStoredGUID = E:IsSecretValue(storedGUID)
	local newGUID = secretGUID or secretStoredGUID or (storedGUID ~= guid)

	local nameplate = event == 'NAME_PLATE_UNIT_ADDED'
	if newGUID then
		element.modelRetryUnit = nil
		element.modelRetryCount = nil
		element.guid = not secretGUID and guid or nil
	elseif nameplate then
		return
	end

	if element.PreUpdate then element:PreUpdate(unit) end

	local isPlayerRaw = UnitIsPlayer(unit)
	local isPlayerSecret = E:IsSecretValue(isPlayerRaw)
	local isPlayer = not isPlayerSecret and isPlayerRaw == true
	local isVisibleRaw = UnitIsVisible(unit)
	local isVisible = not isPlayer or E:IsSecretValue(isVisibleRaw) or (isVisibleRaw == true)
	local isConnectedRaw = UnitIsConnected(unit)
	local isConnected = E:IsSecretValue(isConnectedRaw) or (isConnectedRaw == true)
	local isModelReadyRaw = IsUnitModelReadyForUI and IsUnitModelReadyForUI(unit)
	local isModelReady = E:IsSecretValue(isModelReadyRaw) or isModelReadyRaw == true
	local isAvailable = element:IsVisible() and isVisible and (not isPlayer or isPlayerSecret or (isModelReady and isConnected))
	local playerModel = element:IsObjectType('PlayerModel')
	local needsModel = playerModel and isAvailable and not HasPortraitModel(element)

	local hasStateChanged = newGUID or needsModel or (not nameplate or element.state ~= isAvailable)
	if hasStateChanged then
		element.playerModel = playerModel
		local prevState = element.state
		element.state = isAvailable

		if element.playerModel then
			if not element.modelLoadedHooked then
				element.modelLoadedHooked = true
				pcall(element.HookScript, element, "OnModelLoaded", OnModelLoadedCheck)
			end

			if isAvailable then
				if element.Fallback2D and HidePortraitFallbackIfLoaded(element) then
					element.modelRetryUnit = nil
					element.modelRetryCount = nil
				end

				element:SetCamDistanceScale(1)
				element:SetPortraitZoom(1)
				element:SetPosition(0, 0, 0)

				local noUnitChange = event == "UNIT_PORTRAIT_UPDATE" or event == "UNIT_CONNECTION" or event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE" or event == "UNIT_MODEL_CHANGED" or event == "OnUpdate"
				-- Secret GUIDs cannot be compared, so only refresh them for real events or
				-- eventless frames whose nested unit (such as targettarget) may have changed.
				local eventlessRefresh = event == "OnUpdate" and self.__eventless
				local needsLoad = (not secretGUID and needsModel) or (not secretGUID and newGUID) or (not secretGUID and event == "UNIT_MODEL_CHANGED") or (not prevState) or (event == "OnShow") or (secretGUID and (event == "UNIT_PORTRAIT_UPDATE" or eventlessRefresh or not noUnitChange))
				if needsLoad then
					if secretGUID then
						-- PlayerModel:SetUnit rejects secret identities on 12.0.5+.
						-- Cover any stale 3D model with the supported 2D portrait.
						if not element.Fallback2DFrame then
							local cover = CreateFrame("Frame", nil, element)
							cover:SetAllPoints(element)
							local tex = cover:CreateTexture(nil, "BACKGROUND")
							tex:SetAllPoints(cover)
							tex:SetTexCoord(0.15, 0.85, 0.15, 0.85)
							element.Fallback2D = tex
							element.Fallback2DFrame = cover
						end
						element.Fallback2DFrame:SetFrameLevel(element:GetFrameLevel() + 5)
						SetPortraitTexture(element.Fallback2D, unit)
						element.Fallback2DFrame:Show()
						element.Fallback2D:Show()
					else
						HidePortraitFallback(element)
						element:SetUnit(unit)

						if HidePortraitFallbackIfLoaded(element) then
							element.modelRetryUnit = nil
							element.modelRetryCount = nil
						else
							RetryPortraitModel(element, unit)
						end
					end
				end
			else
				HidePortraitFallback(element)
				element.modelRetryUnit = nil
				element.modelRetryCount = nil
				element:ClearModel()
				element:SetCamDistanceScale(0.25)
				element:SetPortraitZoom(0)
				element:SetPosition(0, 0, 0.25)
				element:SetModel([[Interface\Buttons\TalkToMeQuestionMark.m2]])
			end
		elseif element.useClassBase then
			local _, className = UnitClass(unit)
			if className then
				element:SetAtlas('classicon-' .. className)
			end
		elseif not element.customTexture then
			SetPortraitTexture(element, unit)
		end
	end

	if element.PostUpdate then
		return element:PostUpdate(unit, hasStateChanged)
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
	portrait.Override = UF.PortraitOverride

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

		if frame.Portrait3D then
			frame.Portrait3D:ClearModel()
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
			frame:RegisterEvent('UNIT_PORTRAIT_UPDATE', UF.PortraitForceUpdate)
		else
			portrait:SetParent(frame.USE_PORTRAIT_OVERLAY and frame.Health or frame)
			frame:UnregisterEvent('UNIT_PORTRAIT_UPDATE', UF.PortraitForceUpdate)
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

		if portrait.db.style == 'Class' then
			portrait:SetTexture(classIcon)
			portrait.customTexture = classIcon
		elseif portrait.db.style == '2D' then
			local left, right, top, bottom = 0.15, 0.85, 0.15, 0.85

			if not db.portrait.keepSizeRatio then
				local width, height = portrait:GetSize()
				if width > 0 then
					left, right, top, bottom = E:CropRatio(width, height, nil, left, right, top, bottom, true)
				end
			end

			portrait:SetTexCoord(left, right, top, bottom)
			portrait.customTexture = nil
		end
	elseif frame:IsElementEnabled('Portrait') then
		frame:DisableElement('Portrait')
		frame:UnregisterEvent('UNIT_PORTRAIT_UPDATE', UF.PortraitForceUpdate)
	end
end

function UF:PortraitUpdate(unit, hasStateChanged)
	if not hasStateChanged then return end

	local db = self.db
	if not db then return end

	if self.playerModel then
		if self.state then
			self:SetCamDistanceScale(db.camDistanceScale or 2)
			self:SetViewTranslation((db.xOffset or 0) * 100, (db.yOffset or 0) * 100)
			self:SetRotation(rad(db.rotation or 0))
		end

		-- mimic ModelAlphaFix, so when the module updates the correct alpha is set
		local frame = self.__owner
		local alpha = frame:GetAlpha()
		local modelAlpha = frame.USE_PORTRAIT_OVERLAY and db.overlayAlpha or 1
		self:SetModelAlpha(modelAlpha * (E:IsSecretValue(alpha) and 1 or alpha))

		-- handle the other settings
		self:SetDesaturation(db.desaturation or 0)
		self:SetPaused(db.paused or false)
	elseif self.customTexture then
		local _, className = UnitClass(unit)
		local left, right, top, bottom = E:GetClassCoords(className, true)

		if not db.keepSizeRatio then
			local width, height = self:GetSize()
			if width > 0 then
				left, right, top, bottom = E:CropRatio(width, height, nil, left, right, top, bottom, true)
			end
		end

		self:SetTexCoord(left, right, top, bottom)
	end
end
