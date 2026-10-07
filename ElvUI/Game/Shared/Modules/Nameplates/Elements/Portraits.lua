local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')

local hooksecurefunc = hooksecurefunc
local UnitClass = UnitClass

local classIcon = [[Interface\WorldStateFrame\Icons-Classes]]

function NP:Portrait_BackdropShow()
	if not self.backdrop then return end

	self.backdrop:Show()
end

function NP:Portrait_BackdropHide()
	if not self.backdrop then return end

	self.backdrop:Hide()
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
		local _, classToken = UnitClass(unit)
		local unitClass = E:NotSecretValue(classToken) and classToken or nil
		local left, right, top, bottom = E:GetClassCoords(unitClass, true)

		if not db.portrait.keepSizeRatio then
			local width, height = db.portrait.width, db.portrait.height
			left, right, top, bottom = E:CropRatio(width, height, nil, left, right, top, bottom, true)
		end

		self:SetTexCoord(left, right, top, bottom)
	end
end

function NP:Construct_Portrait(nameplate)
	local Portrait = nameplate.RaisedElement:CreateTexture(nameplate.frameName..'Portrait', 'OVERLAY', nil, 2)
	Portrait:CreateBackdrop(nil, nil, nil, nil, nil, true, true)
	Portrait.backdrop:Hide()

	Portrait:SetTexCoord(.18, .82, .18, .82)
	Portrait:SetSize(28, 28)
	Portrait:Hide()

	Portrait:HookScript('OnShow', NP.Portrait_BackdropShow)
	Portrait:HookScript('OnHide', NP.Portrait_BackdropHide)

	Portrait.PostUpdate = NP.Portrait_PostUpdate

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
			local left, right, top, bottom = 0.15, 0.85, 0.15, 0.85

			if not db.portrait.keepSizeRatio then
				local width, height = db.portrait.width, db.portrait.height
				if specIcon then
					left, right, top, bottom = E:CropRatio(width, height)
				else
					left, right, top, bottom = E:CropRatio(width, height, nil, left, right, top, bottom, true)
				end
			end

			nameplate.Portrait:SetTexCoord(left, right, top, bottom)
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
