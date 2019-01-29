local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local NP = E:GetModule('NamePlates')

function NP:Construct_Portrait(nameplate)
	local Portrait = nameplate:CreateTexture(nil, 'OVERLAY')
	Portrait:SetTexCoord(.18, .82, .18, .82)
	Portrait:CreateBackdrop()
	Portrait:Hide()

	function Portrait:PostUpdate(unit)
		local db = NP.db.units[self.__owner.frameType]
		if not db then return end

		if db.portrait and db.portrait.classicon and UnitIsPlayer(unit) then
			local _, class = UnitClass(unit);
			self:SetTexture([[Interface\WorldStateFrame\Icons-Classes]])
			self:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
			self.backdrop:Hide()
		else
			self:SetTexCoord(.18, .82, .18, .82)
			self.backdrop:Show()
		end
	end

	return Portrait
end

function NP:Update_Portrait(nameplate)
	local db = NP.db.units[nameplate.frameType]
	if (db.portrait and db.portrait.enable) then
		if not nameplate:IsElementEnabled('Portrait') then
			nameplate:EnableElement('Portrait')
			nameplate.Portrait.backdrop:Show()
		end

		nameplate.Portrait:SetSize(db.portrait.width, db.portrait.height)
		nameplate.Portrait:ClearAllPoints()
		if db.portrait.position == 'RIGHT' then
			nameplate.Portrait:SetPoint('LEFT', nameplate, 'RIGHT', db.portrait.xOffset, db.portrait.yOffset)
		elseif db.portrait.position == 'LEFT' then
			nameplate.Portrait:SetPoint('RIGHT', nameplate, 'LEFT', db.portrait.xOffset, db.portrait.yOffset)
		else
			nameplate.Portrait:SetPoint('CENTER', nameplate, 'CENTER', db.portrait.xOffset, db.portrait.yOffset)
		end
	else
		if nameplate:IsElementEnabled('Portrait') then
			nameplate:DisableElement('Portrait')
			nameplate.Portrait.backdrop:Hide()
		end
	end
end