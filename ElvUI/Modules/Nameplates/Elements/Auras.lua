local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')
local UF = E:GetModule('UnitFrames')
local LSM = E.Libs.LSM

local _G = _G
local floor = floor
local unpack = unpack
local CreateFrame = CreateFrame

function NP:Construct_Auras(nameplate)
	local frameName = nameplate:GetName()

	local Buffs = CreateFrame('Frame', frameName..'Buffs', nameplate)
	Buffs:SetFrameStrata(nameplate:GetFrameStrata())
	Buffs:SetFrameLevel(5)
	Buffs:Size(300, 27)
	Buffs.disableMouse = true
	Buffs.size = 27
	Buffs.num = 4
	Buffs.spacing = E.Border * 2
	Buffs.onlyShowPlayer = false
	Buffs.initialAnchor = 'BOTTOMLEFT'
	Buffs['growth-x'] = 'RIGHT'
	Buffs['growth-y'] = 'UP'
	Buffs.type = 'buffs'
	Buffs.forceShow = nameplate == _G.ElvNP_Test

	local Debuffs = CreateFrame('Frame', frameName..'Debuffs', nameplate)
	Debuffs:SetFrameStrata(nameplate:GetFrameStrata())
	Debuffs:SetFrameLevel(5)
	Debuffs:Size(300, 27)
	Debuffs.disableMouse = true
	Debuffs.size = 27
	Debuffs.num = 4
	Debuffs.spacing = E.Border * 2
	Debuffs.onlyShowPlayer = false
	Debuffs.initialAnchor = 'BOTTOMLEFT'
	Debuffs['growth-x'] = 'RIGHT'
	Debuffs['growth-y'] = 'UP'
	Debuffs.type = 'debuffs'
	Debuffs.forceShow = nameplate == _G.ElvNP_Test

	Buffs.PostCreateIcon = NP.Construct_AuraIcon
	Buffs.PostUpdateIcon = UF.PostUpdateAura
	Buffs.CustomFilter = UF.AuraFilter
	Debuffs.PostCreateIcon = NP.Construct_AuraIcon
	Debuffs.PostUpdateIcon = UF.PostUpdateAura
	Debuffs.CustomFilter = UF.AuraFilter

	nameplate.Buffs_, nameplate.Debuffs_ = Buffs, Debuffs
	nameplate.Buffs, nameplate.Debuffs = Buffs, Debuffs
end

function NP:Construct_AuraIcon(button)
	if not button then return end
	button:SetTemplate(nil, nil, nil, nil, nil, true)

	button.cd:SetReverse(true)
	button.cd:SetInside(button)

	button.icon:SetDrawLayer('ARTWORK')
	button.icon:SetInside()

	button.count:ClearAllPoints()
	button.count:Point('BOTTOMRIGHT', 1, 1)
	button.count:SetJustifyH('RIGHT')

	button.overlay:SetTexture()
	button.stealable:SetTexture()

	button.cd.CooldownOverride = 'nameplates'
	E:RegisterCooldown(button.cd)

	local auras = button:GetParent()
	button.db = auras and NP.db.units and NP.db.units[auras.__owner.frameType] and NP.db.units[auras.__owner.frameType][auras.type]

	NP:UpdateAuraSettings(button)
end

function NP:Configure_Auras(nameplate, auras, db)
	auras.size = db.size
	auras.num = db.numAuras
	auras.onlyShowPlayer = false
	auras.spacing = db.spacing
	auras['growth-y'] = db.growthY
	auras['growth-x'] = db.growthX
	auras.initialAnchor = E.InversePoints[db.anchorPoint]
	auras.filterList = UF:ConvertFilters(auras, db.priority)

	local index = 1
	while auras[index] do
		local button = auras[index]
		if button then
			button.db = db
			NP:UpdateAuraSettings(button)
		end

		index = index + 1
	end

	local mult = floor((nameplate.width or 150) / db.size) < db.numAuras
	auras:Size((nameplate.width or 150), (mult and 1 or 2) * db.size)
	auras:ClearAllPoints()
	auras:Point(E.InversePoints[db.anchorPoint] or 'TOPRIGHT', db.attachTo == 'BUFFS' and nameplate.Buffs or nameplate, db.anchorPoint or 'TOPRIGHT', db.xOffset, db.yOffset)
end

function NP:Update_Auras(nameplate)
	local db = NP:PlateDB(nameplate)

	if db.debuffs.enable or db.buffs.enable then
		nameplate:SetAuraUpdateMethod(E.global.nameplate.effectiveAura)
		nameplate:SetAuraUpdateSpeed(E.global.nameplate.effectiveAuraSpeed)

		if not nameplate:IsElementEnabled('Auras') then
			nameplate:EnableElement('Auras')
		end

		if db.debuffs.enable then
			nameplate.Debuffs = nameplate.Debuffs_
			NP:Configure_Auras(nameplate, nameplate.Debuffs, db.debuffs)
			nameplate.Debuffs:Show()
			nameplate.Debuffs:ForceUpdate()
		elseif nameplate.Debuffs then
			nameplate.Debuffs:Hide()
			nameplate.Debuffs = nil
		end

		if db.buffs.enable then
			nameplate.Buffs = nameplate.Buffs_
			NP:Configure_Auras(nameplate, nameplate.Buffs, db.buffs)
			nameplate.Buffs:Show()
			nameplate.Buffs:ForceUpdate()
		elseif nameplate.Buffs then
			nameplate.Buffs:Hide()
			nameplate.Buffs = nil
		end
	elseif nameplate:IsElementEnabled('Auras') then
		nameplate:DisableElement('Auras')
	end
end

function NP:UpdateAuraSettings(button)
	if button.db then
		button.count:FontTemplate(LSM:Fetch('font', button.db.countFont), button.db.countFontSize, button.db.countFontOutline)
		button.count:ClearAllPoints()

		local point = (button.db and button.db.countPosition) or 'CENTER'
		if point == 'CENTER' then
			button.count:Point(point, 1, 0)
		else
			local bottom, right = point:find('BOTTOM'), point:find('RIGHT')
			button.count:SetJustifyH(right and 'RIGHT' or 'LEFT')
			button.count:Point(point, right and -1 or 1, bottom and 1 or -1)
		end
	end

	if button.icon then
		button.icon:SetTexCoord(unpack(E.TexCoords))
	end

	button:Size((button.db and button.db.size) or 26)

	button.needsUpdateCooldownPosition = true
end
