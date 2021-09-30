local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')

local _G = _G
local unpack = unpack
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

function NP:Update_PortraitBackdrop()
	if self.backdrop then
		self.backdrop:SetShown(self:IsShown())
	end
end

function NP:Construct_Portrait(nameplate)
	local Portrait = nameplate:CreateTexture(nameplate:GetName() .. 'Portrait', 'OVERLAY', nil, 2)
	Portrait:SetTexCoord(.18, .82, .18, .82)
	Portrait:CreateBackdrop(nil, nil, nil, nil, nil, true, true)
	Portrait:Hide()

	Portrait.PostUpdate = NP.Portrait_PostUpdate
	hooksecurefunc(Portrait, 'Hide', NP.Update_PortraitBackdrop)
	hooksecurefunc(Portrait, 'Show', NP.Update_PortraitBackdrop)

	return Portrait
end

function NP:Update_Portrait(nameplate)
	local db = NP:PlateDB(nameplate)
	local sf = NP:StyleFilterChanges(nameplate)

	if sf.Portrait or (db.portrait and db.portrait.enable) then
		if not nameplate:IsElementEnabled('Portrait') then
			nameplate:EnableElement('Portrait')
			nameplate.Portrait:ForceUpdate()
		end

		nameplate.Portrait:Size(db.portrait.width, db.portrait.height)

		-- These values are forced in name only mode inside of DisablePlate
		if not (db.nameOnly or sf.NameOnly) then
			nameplate.Portrait:ClearAllPoints()
			nameplate.Portrait:Point(E.InversePoints[db.portrait.position], nameplate, db.portrait.position, db.portrait.xOffset, db.portrait.yOffset)
		end
	elseif nameplate:IsElementEnabled('Portrait') then
		nameplate:DisableElement('Portrait')
	end
end
