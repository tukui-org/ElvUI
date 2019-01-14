local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local NP = E:GetModule('NamePlates')

function NP:Construct_Portrait(nameplate)
	local Portrait = nameplate:CreateTexture(nil, 'OVERLAY')
	Portrait:SetSize(32, 32)
	Portrait:SetPoint('RIGHT', nameplate, 'LEFT')
	Portrait:SetTexCoord(.18, .82, .18, .82)

	function Portrait:PostUpdate(unit)
		if UnitIsPlayer(unit) then
			local _, class = UnitClass(unit);
			Portrait:SetTexture([[Interface\WorldStateFrame\Icons-Classes]])
			Portrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[strupper(class)]))
		else
			Portrait:SetTexCoord(.18, .82, .18, .82)
		end
	end

	return Portrait
end

function NP:Update_Portrait(nameplate)
	if (NP.db.units[nameplate.frameType].portrait and NP.db.units[nameplate.frameType].portrait.enable) then
		nameplate:EnableElement('Portrait')
		nameplate.Portrait:SetSize(NP.db.units[nameplate.frameType].portrait.width, NP.db.units[nameplate.frameType].portrait.height)
		nameplate.Portrait:SetPoint('RIGHT', nameplate, 'LEFT')
	else
		nameplate:DisableElement('Portrait')
	end
end