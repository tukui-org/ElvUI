local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')

local unpack = unpack
local hooksecurefunc = hooksecurefunc

function NP:Portrait_PreUpdate()
	local nameplate = self.__owner

	if self.backdrop then
		self.backdrop:Hide()
	end

	local db = NP:PlateDB(nameplate)
	local specIcon = db.portrait and db.portrait.specicon and nameplate.specIcon
	self.useClassBase = not specIcon
end

function NP:Portrait_PostUpdate()
	local nameplate = self.__owner
	local db = NP:PlateDB(nameplate)
	local sf = NP:StyleFilterChanges(nameplate)

	if db.portrait and (sf.Portrait or db.portrait.enable) then
		local specIcon = db.portrait.specicon and nameplate.specIcon
		if specIcon then
			self:SetTexture(specIcon)
			self.backdrop:Show()
		elseif self.useClassBase then
			self.backdrop:Show()
		end

		if db.portrait.keepSizeRatio then
			self:SetTexCoord(unpack(E.TexCoords))
		else
			self:SetTexCoord(E:CropRatio(self))
		end
	end
end

function NP:Update_PortraitBackdrop()
	if self.backdrop then
		self.backdrop:SetShown(self:IsShown())
	end
end

function NP:Construct_Portrait(nameplate)
	local Portrait = nameplate:CreateTexture(nameplate:GetName() .. 'Portrait', 'OVERLAY', nil, 2)
	Portrait:CreateBackdrop(nil, nil, nil, nil, nil, true, true)
	Portrait:SetTexCoord(.18, .82, .18, .82)
	Portrait:SetSize(28, 28)
	Portrait:Hide()

	Portrait.PreUpdate = NP.Portrait_PreUpdate
	Portrait.PostUpdate = NP.Portrait_PostUpdate

	hooksecurefunc(Portrait, 'Hide', NP.Update_PortraitBackdrop)
	hooksecurefunc(Portrait, 'Show', NP.Update_PortraitBackdrop)

	return Portrait
end

function NP:Update_Portrait(nameplate)
	local db = NP:PlateDB(nameplate)
	local sf = NP:StyleFilterChanges(nameplate)

	if db.portrait and (sf.Portrait or db.portrait.enable) then
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
