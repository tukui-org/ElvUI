local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local LSM = E.Libs.LSM
local LCG = E.Libs.CustomGlow

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc
local IsSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed

function S:CooldownManager_CountText(text)
	local db = E.db.general.cooldownManager
	local color = db.countFontColor
	text:SetIgnoreParentScale(true)
	text:SetTextColor(color.r, color.g, color.b)
	text:FontTemplate(LSM:Fetch('font', db.countFont), db.countFontSize, db.countFontOutline)
	text:ClearAllPoints()
	text:Point(db.countPosition, db.countxOffset, db.countyOffset)
end

function S:CooldownManager_UpdateTextContainer(container)
	local countText = container.Applications and container.Applications.Applications
	if countText then
		S:CooldownManager_CountText(countText)
	end

	local chargeText = container.ChargeCount and container.ChargeCount.Current
	if chargeText then
		S:CooldownManager_CountText(chargeText)
	end
end

function S:CooldownManager_UpdateTextBar(bar)
	local db = E.db.general.cooldownManager
	if bar.Name then
		local color = db.nameFontColor
		bar.Name:SetTextColor(color.r, color.g, color.b)
		bar.Name:FontTemplate(LSM:Fetch('font', db.nameFont), db.nameFontSize, db.nameFontOutline)
		bar.Name:ClearAllPoints()
		bar.Name:Point(db.namePosition, db.namexOffset, db.nameyOffset)
	end

	if bar.Duration then
		local color = db.durationFontColor
		bar.Duration:SetTextColor(color.r, color.g, color.b)
		bar.Duration:FontTemplate(LSM:Fetch('font', db.durationFont), db.durationFontSize, db.durationFontOutline)
		bar.Duration:ClearAllPoints()
		bar.Duration:Point(db.durationPosition, db.durationxOffset, db.durationyOffset)
	end
end

function S:CooldownManager_SkinIcon(container, icon)
	S:CooldownManager_UpdateTextContainer(container)
	S:HandleIcon(icon, true)

	for _, region in next, { container:GetRegions() } do
		if region:IsObjectType('Texture') then
			local texture = region:GetTexture()
			local atlas = region:GetAtlas()

			if texture == 6707800 then
				region:SetTexture(E.media.blankTex)
			elseif atlas == 'UI-HUD-CoolDownManager-IconOverlay' then -- 6704514
				region:SetAlpha(0)
			end
		end
	end
end

function S:CooldownManager_SkinBar(frame, bar)
	S:CooldownManager_UpdateTextBar(bar)

	if frame.Icon then
		bar:Point('LEFT', frame.Icon, 'RIGHT', 3, 0)

		S:CooldownManager_SkinIcon(frame.Icon, frame.Icon.Icon)
	end

	for _, region in next, { bar:GetRegions() } do
		if region:IsObjectType('Texture') then
			local atlas = region:GetAtlas()

			if atlas == 'UI-HUD-CoolDownManager-Bar' then
				region:Point('TOPLEFT', 1, 0)
				region:Point('BOTTOMLEFT', -1, 0)
			elseif atlas == 'UI-HUD-CoolDownManager-Bar-BG' and not region.backdrop then
				region:StripTextures()
				region:CreateBackdrop('Transparent', nil, true)
				region.backdrop:SetOutside()
			end
		end
	end
end

function S:CooldownManager_RefreshSpellCooldownInfo()
	if not self.Cooldown then return end

	local db = E.db.general.cooldownManager
	local color = (self.cooldownUseAuraDisplayTime and db.swipeColorAura) or db.swipeColorSpell
	self.Cooldown:SetSwipeColor(color.r, color.g, color.b, color.a)
end

function S:CooldownManager_UpdateSwipeColor(frame)
	S.CooldownManager_RefreshSpellCooldownInfo(frame)
end

function S:CooldownManager_SetTimerShown()
	if self.Cooldown then
		E:ToggleBlizzardCooldownText(self.Cooldown, self.Cooldown.timer)
	end
end

function S:CooldownManager_RefreshOverlayGlow()
	_G.ActionButtonSpellAlertManager:HideAlert(self) -- hide blizzards

	local spellID = self:GetSpellID()
	if spellID and IsSpellOverlayed(spellID) then
		LCG.ShowOverlayGlow(self)
	else
		LCG.HideOverlayGlow(self)
	end
end

function S:CooldownManager_ShowGlowEvent(spellID)
	if not self:NeedSpellActivationUpdate(spellID) then return end

	_G.ActionButtonSpellAlertManager:HideAlert(self) -- hide blizzards
	LCG.ShowOverlayGlow(self)
end

function S:CooldownManager_HideGlowEvent(spellID)
	if not self:NeedSpellActivationUpdate(spellID) then return end

	_G.ActionButtonSpellAlertManager:HideAlert(self)
	LCG.HideOverlayGlow(self)
end

do
	local hookFunctions = {
		RefreshSpellCooldownInfo = S.CooldownManager_RefreshSpellCooldownInfo,
		OnSpellActivationOverlayGlowShowEvent = S.CooldownManager_ShowGlowEvent,
		OnSpellActivationOverlayGlowHideEvent = S.CooldownManager_HideGlowEvent,
		RefreshOverlayGlow = S.CooldownManager_RefreshOverlayGlow,
		SetTimerShown = S.CooldownManager_SetTimerShown
	}

	function S:CooldownManager_SkinItemFrame(frame)
		if frame.Cooldown then
			frame.Cooldown:SetSwipeTexture(E.media.blankTex)

			if not frame.Cooldown.isRegisteredCooldown then
				E:RegisterCooldown(frame.Cooldown, 'cdmanager')

				for key, func in next, hookFunctions do
					if frame[key] then
						hooksecurefunc(frame, key, func)
					end
				end
			end
		end

		if frame.Bar then
			S:CooldownManager_SkinBar(frame, frame.Bar)
		elseif frame.Icon then
			S:CooldownManager_SkinIcon(frame, frame.Icon)
		end
	end
end

function S:CooldownManager_AcquireItemFrame(frame)
	S:CooldownManager_SkinItemFrame(frame)
end

function S:CooldownManager_HandleViewer(element)
	hooksecurefunc(element, 'OnAcquireItemFrame', S.CooldownManager_AcquireItemFrame)

	for frame in element.itemFramePool:EnumerateActive() do
		S:CooldownManager_SkinItemFrame(frame)
	end
end

function S:CooldownManager_UpdateViewer(element)
	for frame in element.itemFramePool:EnumerateActive() do
		if frame.Bar then
			S:CooldownManager_UpdateTextBar(frame.Bar)
			S:CooldownManager_UpdateTextContainer(frame)
			S:CooldownManager_UpdateSwipeColor(frame)
		elseif frame.Icon then
			S:CooldownManager_UpdateTextContainer(frame)
			S:CooldownManager_UpdateSwipeColor(frame)
		end
	end
end

function S:CooldownManager_UpdateViewers()
	S:CooldownManager_UpdateViewer(_G.UtilityCooldownViewer)
	S:CooldownManager_UpdateViewer(_G.BuffBarCooldownViewer)
	S:CooldownManager_UpdateViewer(_G.BuffIconCooldownViewer)
	S:CooldownManager_UpdateViewer(_G.EssentialCooldownViewer)
end

function S:Blizzard_CooldownViewer()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.cooldownManager) then return end

	local db = E.db.general.cooldownManager
	E:UpdateClassColor(db.swipeColorSpell)
	E:UpdateClassColor(db.swipeColorAura)
	E:UpdateClassColor(db.nameFontColor)
	E:UpdateClassColor(db.durationFontColor)
	E:UpdateClassColor(db.countFontColor)

	S:CooldownManager_HandleViewer(_G.UtilityCooldownViewer)
	S:CooldownManager_HandleViewer(_G.BuffBarCooldownViewer)
	S:CooldownManager_HandleViewer(_G.BuffIconCooldownViewer)
	S:CooldownManager_HandleViewer(_G.EssentialCooldownViewer)
end

S:AddCallbackForAddon('Blizzard_CooldownViewer')
