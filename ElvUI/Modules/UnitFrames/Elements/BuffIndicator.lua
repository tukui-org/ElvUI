local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--WoW API / Variables
local unpack = unpack
local CreateFrame = CreateFrame

function UF:Construct_AuraWatch(frame)
	local auras = CreateFrame("Frame", nil, frame)
	auras:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 10)
	auras:SetInside(frame.Health)
	auras.presentAlpha = 1
	auras.missingAlpha = 0
	auras.strictMatching = true;
	auras.PostCreateIcon = UF.BuffIndicator_PostCreateIcon
	auras.PostUpdateIcon = UF.BuffIndicator_PostUpdateIcon

	return auras
end

function UF:Configure_AuraWatch(frame, isPet)
	local db = frame.db.buffIndicator
	if db and db.enable then
		if not frame:IsElementEnabled('AuraWatch') then
			frame:EnableElement('AuraWatch')
		end

		frame.AuraWatch.size = db.size

		if frame.unit == 'pet' or isPet then
			frame.AuraWatch:SetNewTable(E.global.unitframe.buffwatch.PET)
		else
			frame.AuraWatch:SetNewTable(db.profileSpecific and E.db.unitframe.filters.buffwatch or E.global.unitframe.buffwatch[E.myclass])
		end
	elseif frame:IsElementEnabled('AuraWatch') then
		frame:DisableElement('AuraWatch')
	end
end

function UF:BuffIndicator_PostCreateIcon(button)
	button.cd.CooldownOverride = 'unitframe'
	button.cd.skipScale = true

	E:RegisterCooldown(button.cd)

	button.overlay:Hide()

	button.icon.border = button:CreateTexture(nil, "BACKGROUND");
	button.icon.border:SetOutside(button.icon, 1, 1)
	button.icon.border:SetTexture(E.media.blankTex)
	button.icon.border:SetVertexColor(0, 0, 0)

	UF:Configure_FontString(button.count)
	UF:Update_FontString(button.count)
end

function UF:BuffIndicator_PostUpdateIcon(_, button)
	local settings = self.watched[button.spellID]
	if settings then -- This should never fail.
		button.cd.textThreshold = settings.textThreshold ~= -1 and settings.textThreshold

		local timer = button.cd.timer
		if (settings.style == 'coloredIcon' or settings.style == 'texturedIcon') and not button.icon:IsShown() then
			button.icon:Show()
			button.icon.border:Show()
			button.cd:SetDrawSwipe(true)
		elseif settings.style == 'timerOnly' and button.icon:IsShown() then
			button.icon:Hide()
			button.icon.border:Hide()
			button.cd:SetDrawSwipe(false)
		end

		if settings.style == 'timerOnly' then
			button.cd.hideText = nil
			if timer then
				timer.skipTextColor = true

				if timer.text then
					timer.text:SetTextColor(settings.color.r, settings.color.g, settings.color.b)
				end
			end
		else
			button.cd.hideText = not settings.displayText
			if timer then timer.skipTextColor = nil end

			if settings.style == 'coloredIcon' then
				button.icon:SetTexture(E.media.blankTex)
				button.icon:SetVertexColor(settings.color.r, settings.color.g, settings.color.b)
			elseif settings.style == 'texturedIcon' then
				button.icon:SetVertexColor(1, 1, 1)
				button.icon:SetTexCoord(unpack(E.TexCoords))
			end
		end

		if settings.style == 'texturedIcon' and button.filter == "HARMFUL" then
			button.icon.border:SetVertexColor(1, 0, 0)
		else
			button.icon.border:SetVertexColor(0, 0, 0)
		end
	end
end
