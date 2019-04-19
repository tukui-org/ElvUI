local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

-- Cache global variables
-- Lua functions
local _G = _G
local unpack = unpack
-- WoW API / Variables
local UnitClass = UnitClass
local UnitIsPlayer = UnitIsPlayer

function NP:Portrait_PostUpdate(unit)
	local db = NP.db.units[self.__owner.frameType]
	if not db then return end

	if (db.portrait and db.portrait.classicon) and UnitIsPlayer(unit) then
		local _, class = UnitClass(unit);
		self:SetTexture([[Interface\WorldStateFrame\Icons-Classes]])
		self:SetTexCoord(unpack(_G.CLASS_ICON_TCOORDS[class]))
		self.backdrop:Hide()
	elseif self.__owner.PortraitShown or (db.portrait and db.portrait.enable) then
		self:SetTexCoord(.18, .82, .18, .82)
		self.backdrop:Show()
	else
		self.backdrop:Hide()
	end
end

function NP:Construct_Portrait(nameplate)
	local Portrait = nameplate:CreateTexture(nil, 'OVERLAY')
	Portrait:SetTexCoord(.18, .82, .18, .82)
	Portrait:CreateBackdrop()
	Portrait:Hide()

	Portrait.PostUpdate = NP.Portrait_PostUpdate

	return Portrait
end

function NP:Update_Portrait(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if nameplate.PortraitShown or (db.portrait and db.portrait.enable) then
		if not nameplate:IsElementEnabled('Portrait') then
			nameplate:EnableElement('Portrait')
			nameplate.Portrait.backdrop:Show()
		end

		nameplate.Portrait:ClearAllPoints()
		nameplate.Portrait:Size(db.portrait.width, db.portrait.height)
		nameplate.Portrait:Point(E.InversePoints[db.portrait.position], nameplate, db.portrait.position, db.portrait.xOffset, db.portrait.yOffset)
	else
		if nameplate:IsElementEnabled('Portrait') then
			nameplate:DisableElement('Portrait')
			nameplate.Portrait.backdrop:Hide()
		end
	end
end
