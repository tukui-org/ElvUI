local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

local _G = _G
local unpack = unpack
local UnitClass = UnitClass
local UnitIsPlayer = UnitIsPlayer
local hooksecurefunc = hooksecurefunc

function NP:Portrait_PostUpdate()
	local nameplate = self.__owner
	local db = NP:PlateDB(nameplate)

	local sf = NP:StyleFilterChanges(nameplate)
	if sf.Portrait or (db.portrait and db.portrait.enable) then
		if db.portrait.classicon and nameplate.isPlayer then
			self:SetTexture([[Interface\WorldStateFrame\Icons-Classes]])
			self:SetTexCoord(unpack(_G.CLASS_ICON_TCOORDS[nameplate.classFile]))
			self.backdrop:Hide()
		else
			self:SetTexCoord(.18, .82, .18, .82)
			self.backdrop:Show()
		end
	else
		self.backdrop:Hide()
	end
end

local function syncBackdrop(element)
	if element.backdrop then
		element.backdrop:SetShown(element:IsShown())
	end
end

function NP:Construct_Portrait(nameplate)
	local Portrait = nameplate:CreateTexture(nil, 'OVERLAY')
	Portrait:SetTexCoord(.18, .82, .18, .82)
	Portrait:CreateBackdrop()
	Portrait:Hide()

	Portrait.PostUpdate = NP.Portrait_PostUpdate
	hooksecurefunc(Portrait, 'Hide', syncBackdrop)
	hooksecurefunc(Portrait, 'Show', syncBackdrop)

	return Portrait
end

function NP:Update_Portrait(nameplate)
	local db = NP:PlateDB(nameplate)

	local sf = NP:StyleFilterChanges(nameplate)
	if sf.Portrait or (db.portrait and db.portrait.enable) then
		if not nameplate:IsElementEnabled('Portrait') then
			nameplate:EnableElement('Portrait')
		end

		nameplate.Portrait:ClearAllPoints()
		nameplate.Portrait:Size(db.portrait.width, db.portrait.height)
		nameplate.Portrait:Point(E.InversePoints[db.portrait.position], nameplate, db.portrait.position, db.portrait.xOffset, db.portrait.yOffset)
	elseif nameplate:IsElementEnabled('Portrait') then
		nameplate:DisableElement('Portrait')
	end
end
