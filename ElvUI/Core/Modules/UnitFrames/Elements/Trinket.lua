local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local CreateFrame = CreateFrame

function UF:Construct_Trinket(frame)
	local trinket = CreateFrame('Button', frame:GetName()..'Trinket', frame)
	trinket:SetTemplate(nil, nil, nil, nil, true)

	local cd = CreateFrame('Cooldown', '$parentCooldown', frame, 'CooldownFrameTemplate')
	cd:SetInside(trinket, UF.BORDER, UF.BORDER)

	local icon = trinket:CreateTexture(nil, 'ARTWORK')
	icon:SetInside(trinket, UF.BORDER, UF.BORDER)

	E:RegisterCooldown(cd)

	trinket.cd = cd
	trinket.icon = icon

	return trinket
end

function UF:Configure_Trinket(frame)
	local db = frame.db
	local trinket = frame.Trinket

	trinket:Size(db.pvpTrinket.size)
	trinket:ClearAllPoints()
	trinket.icon:SetTexCoords()

	if db.pvpTrinket.position == 'RIGHT' then
		trinket:Point('LEFT', frame, 'RIGHT', db.pvpTrinket.xOffset, db.pvpTrinket.yOffset)
	else
		trinket:Point('RIGHT', frame, 'LEFT', db.pvpTrinket.xOffset, db.pvpTrinket.yOffset)
	end

	local enabled = frame:IsElementEnabled('Trinket')
	if db.pvpTrinket.enable and not enabled then
		frame:EnableElement('Trinket')
	elseif not db.pvpTrinket.enable and enabled then
		frame:DisableElement('Trinket')
	end
end
