local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')

local hooksecurefunc = hooksecurefunc
local UnitClass = UnitClass

local classIcon = [[Interface\WorldStateFrame\Icons-Classes]]

function NP:Update_PortraitBackdrop()
	if self.backdrop then
		self.backdrop:SetShown(self:IsShown())
	end
end

function NP:Portrait_PostUpdate(unit, hasStateChanged)
	if not hasStateChanged then return end

	local nameplate = self.__owner
	local db = NP:PlateDB(nameplate)

	if not db.portrait or not db.portrait.enable then return end

	local specIcon = db.portrait.specicon and nameplate.specIcon
	if specIcon then
		self:SetTexture(specIcon)
		self.backdrop:Show()
	elseif self.customTexture then
		local _, className = UnitClass(unit)
		self:SetTexCoord(E:GetClassCoords(className, true))
	end
end

function NP:Construct_Portrait(nameplate)
	local Portrait = nameplate.RaisedElement:CreateTexture(nameplate.frameName..'Portrait', 'OVERLAY', nil, 2)
	Portrait:CreateBackdrop(nil, nil, nil, nil, nil, true, true)
	Portrait:SetTexCoord(.18, .82, .18, .82)
	Portrait:SetSize(28, 28)
	Portrait:Hide()

	Portrait.PostUpdate = NP.Portrait_PostUpdate

	hooksecurefunc(Portrait, 'Hide', NP.Update_PortraitBackdrop)
	hooksecurefunc(Portrait, 'Show', NP.Update_PortraitBackdrop)

	return Portrait
end

function NP:Update_Portrait(nameplate)
	local db = NP:PlateDB(nameplate)

	if db.portrait and db.portrait.enable then
		if not nameplate:IsElementEnabled('Portrait') then
			nameplate:EnableElement('Portrait')
			nameplate.Portrait:ForceUpdate()
		end

		local specIcon = db.portrait.specicon and nameplate.specIcon
		if db.portrait.classicon and not specIcon then
			nameplate.Portrait:SetTexture(classIcon)
			nameplate.Portrait.customTexture = classIcon
		else -- spec icon or portrait
			nameplate.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			nameplate.Portrait.customTexture = nil
		end

		nameplate.Portrait:Size(db.portrait.width, db.portrait.height)

		-- These values are forced in name only mode inside of DisablePlate
		if not db.nameOnly then
			nameplate.Portrait:ClearAllPoints()
			nameplate.Portrait:Point(E.InversePoints[db.portrait.position], nameplate, db.portrait.position, db.portrait.xOffset, db.portrait.yOffset)
		end
	elseif nameplate:IsElementEnabled('Portrait') then
		nameplate:DisableElement('Portrait')
	end
end
