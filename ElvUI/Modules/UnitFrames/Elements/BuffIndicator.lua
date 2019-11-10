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

		if frame.unit == 'pet' or isPet then
			frame.AuraWatch:SetNewTable(E.global.unitframe.buffwatch.PET)
		else
			frame.AuraWatch:SetNewTable(db.profileSpecific and E.db.unitframe.filters.buffwatch or E.global.unitframe.buffwatch[E.myclass])
		end

		frame.AuraWatch.size = db.size
	elseif frame:IsElementEnabled('AuraWatch') then
		frame:DisableElement('AuraWatch')
	end
end

function UF:BuffIndicator_PostCreateIcon(button)
	button.cd.CooldownOverride = 'unitframe'
	E:RegisterCooldown(button.cd)

	button.overlay:Hide()

	button.icon.border = button:CreateTexture(nil, "BACKGROUND");
	button.icon.border:SetOutside(button.icon, 1, 1)
	button.icon.border:SetTexture(E.media.blankTex)
	button.icon.border:SetVertexColor(0, 0, 0)
end

function UF:BuffIndicator_PostUpdateIcon(unit, button)
	local settings = self.watched[button.spellID]
	if settings then -- This should never fail.
		local style = settings.styleOverride ~= 'Default' and settings.styleOverride or self.__owner.db and self.__owner.db.buffIndicator.style

		button.icon.border:SetVertexColor(0, 0, 0)
		if style == 'coloredIcon' then
			button.icon:SetTexture(E.media.blankTex)
			button.icon:SetVertexColor(settings.color.r, settings.color.g, settings.color.b);
		else
			button.icon:SetVertexColor(1, 1, 1);
			button.icon:SetTexCoord(unpack(E.TexCoords))
		end

		if style ~= 'coloredIcon' and button.filter == "HARMFUL" then
			button.icon.border:SetVertexColor(1, 0, 0)
		end
	end
end
