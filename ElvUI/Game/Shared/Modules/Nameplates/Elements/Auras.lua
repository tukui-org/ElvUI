local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local UF = E:GetModule('UnitFrames')

local next = next
local unpack = unpack
local strfind = strfind

local CreateFrame = CreateFrame

local PLATETOKENS = 40 -- this is stupid
local AURA_TYPES = {
	Auras = 'auras',
	Buffs = 'buffs',
	Debuffs = 'debuffs'
}

function NP:Construct_Auras(nameplate)
	local Auras, Buffs, Debuffs

	local container = E.Retail and NP:GetAuraContainer(nameplate.frameName, nameplate.frameType)
	if E.Retail then
		Auras = (container and container.Auras) or E:Auras_Create(nameplate, 'Auras')
	else
		Auras = CreateFrame('Frame', '$parentAuras', nameplate)

		Auras:Size(1)
		Auras.size = 27
		Auras.num = 4
		Auras.spacing = E.Border * 2
		Auras.onlyShowPlayer = false
		Auras.disableMouse = true
		Auras.initialAnchor = 'BOTTOMLEFT'
		Auras.growthX = 'RIGHT'
		Auras.growthY = 'UP'
		Auras.type = 'auras'
		Auras.forceShow = nameplate == NP.TestFrame
		Auras.stacks = {}
		Auras.rows = {}
	end

	if E.Retail then
		Buffs = (container and container.Buffs) or E:Auras_Create(nameplate, 'Buffs')
	else
		Buffs = CreateFrame('Frame', '$parentBuffs', nameplate)

		Buffs:Size(1)
		Buffs.size = 27
		Buffs.num = 4
		Buffs.spacing = E.Border * 2
		Buffs.onlyShowPlayer = false
		Buffs.disableMouse = true
		Buffs.initialAnchor = 'BOTTOMLEFT'
		Buffs.growthX = 'RIGHT'
		Buffs.growthY = 'UP'
		Buffs.type = 'buffs'
		Buffs.forceShow = nameplate == NP.TestFrame
		Buffs.stacks = {}
		Buffs.rows = {}
	end

	if E.Retail then
		Debuffs = (container and container.Debuffs) or E:Auras_Create(nameplate, 'Debuffs')
	else
		Debuffs = CreateFrame('Frame', '$parentDebuffs', nameplate)

		Debuffs:Size(1)
		Debuffs.size = 27
		Debuffs.num = 4
		Debuffs.spacing = E.Border * 2
		Debuffs.onlyShowPlayer = false
		Debuffs.disableMouse = true
		Debuffs.initialAnchor = 'BOTTOMLEFT'
		Debuffs.growthX = 'RIGHT'
		Debuffs.growthY = 'UP'
		Debuffs.type = 'debuffs'
		Debuffs.forceShow = nameplate == NP.TestFrame
		Debuffs.stacks = {}
		Debuffs.rows = {}
	end

	Auras.PreUpdate = UF.PreUpdateAura
	Auras.PreSetPosition = UF.SortAuras
	Auras.SetPosition = UF.SetPosition
	Auras.PostCreateButton = NP.Construct_AuraIcon
	Auras.PostUpdateButton = UF.PostUpdateAura
	Auras.CustomFilter = NP.AuraFilter

	Buffs.PreUpdate = UF.PreUpdateAura
	Buffs.PreSetPosition = UF.SortAuras
	Buffs.SetPosition = UF.SetPosition
	Buffs.PostCreateButton = NP.Construct_AuraIcon
	Buffs.PostUpdateButton = UF.PostUpdateAura
	Buffs.CustomFilter = NP.AuraFilter

	Debuffs.PreUpdate = UF.PreUpdateAura
	Debuffs.PreSetPosition = UF.SortAuras
	Debuffs.SetPosition = UF.SetPosition
	Debuffs.PostCreateButton = NP.Construct_AuraIcon
	Debuffs.PostUpdateButton = UF.PostUpdateAura
	Debuffs.CustomFilter = NP.AuraFilter

	nameplate.Auras_, nameplate.Buffs_, nameplate.Debuffs_ = Auras, Buffs, Debuffs
	nameplate.Auras, nameplate.Buffs, nameplate.Debuffs = Auras, Buffs, Debuffs
end

function NP:Construct_AuraIcon(button)
	if not button then return end

	button:SetTemplate(nil, nil, nil, nil, nil, true, true)

	button.Icon:SetDrawLayer('ARTWORK')
	button.Icon:SetInside()

	button.Count:ClearAllPoints()
	button.Count:Point('BOTTOMRIGHT', 1, 1)
	button.Count:SetJustifyH('RIGHT')

	button.Overlay:SetTexture()
	button.Stealable:SetTexture()

	button.Cooldown:SetAllPoints(button.Icon)

	local auras = button:GetParent()
	local nameplate = auras:GetParent()

	local db = NP:PlateDB(nameplate)
	button.db = db[auras.type]

	E:RegisterCooldown(button.Cooldown, 'nameplates', nameplate.frameType, auras.type)

	NP:UpdateAuraSettings(button)
end

do
	local elements = { Auras = 'Auras_', Buffs = 'Buffs_', Debuffs = 'Debuffs_' }
	function NP:Configure_AuraUpdate(nameplate)
		for _, real in next, elements do
			E:Auras_UpdateButtons(nameplate[real])
		end -- this is so we can keep Auras_UpdateButtons outside of
	end -- the normal configure that happens when a plate type changes

	function NP:Configure_AuraContainers(nameplate, added)
		local plateDB = NP:PlateDB(nameplate)
		local current
		for which in next, elements do
			local auraType = AURA_TYPES[which]
			local db = plateDB[auraType]

			for frameType in next, NP.AuraContainerFilterKeys do
				local container = NP:GetAuraContainer(nameplate.frameName, frameType)
				local auras = container and container[which]
				if auras then
					if frameType == nameplate.frameType then
						current = container

						E:Auras_SetUnit(auras, nameplate.__unit)

						auras:SetEnabled(added and db.enable)
						auras:SetShown(added and db.enable)
					else
						auras:SetEnabled(false)
						auras:SetShown(false)
					end
				end
			end
		end

		return current
	end
end

function NP:Configure_AuraFilters(nameplate, which)
	local frameType = nameplate.frameType
	if not frameType then return end

	local obj = NP.AuraContainerFilterTypes[frameType]
	local info = obj and obj[which]
	if not info then return end

	return info.filters
end

function NP:AuraContainer_ConstructFilters()
	for frameType, data in next, NP.AuraContainerFilterTypes do
		local plateDB = NP:PlateDB(nil, frameType)
		for which, auraType in next, AURA_TYPES do
			local info = data[which]
			if not info then
				info = { filters = {} }
				data[which] = info
			end

			local db = plateDB[auraType]
			if db then
				info.filterLists = db.filterLists

				UF:GroupFilters(info, info.filterLists)
			end
		end
	end
end

function NP:AuraContainer_ConstructAuraTypes(frameType, name)
	local object = {}
	local scale = E.global.general.UIScale
	for which in next, AURA_TYPES do
		local auras = E:Auras_Create(nil, which, name..which)
		auras:SetEnabled(false)
		auras:SetScale(scale)

		auras.frameType = frameType
		NP:Configure_Auras(auras, which, true)

		object[which] = auras
	end

	return object
end

function NP:AuraContainer_CreateFrameType(name)
	local object = {}
	for frameType, nameKey in next, NP.AuraContainerFilterKeys do
		object[frameType] = NP:AuraContainer_ConstructAuraTypes(frameType, name..nameKey)
	end

	return object
end

function NP:AuraContainer_ConstructContainers()
	for i = 1, PLATETOKENS do
		NP.AuraContainers['ElvNP_NamePlate'..i] = NP:AuraContainer_CreateFrameType('ElvNP_AuraContainer'..i)
	end
end

function NP:GetAuraContainer(plateName, frameType)
	local object = NP.AuraContainers[plateName]
	return object and object[frameType] or nil
end

function NP:GetAuraFilter(which, db)
	if which == 'Auras' then -- this wont actually use helpful for blizzard auras its just to stop it from trying debuffs too
		return db.filter or 'HARMFUL'
	elseif E.Retail then
		return (which == 'Buffs' and 'HELPFUL') or 'HARMFUL'
	end
end

function NP:Configure_Auras(nameplate, which, preallocated)
	local plateDB = NP:PlateDB(nameplate)
	local auraType = AURA_TYPES[which]
	local db = plateDB[auraType]

	local auras = (preallocated and nameplate) or (nameplate.AuraContainer and nameplate.AuraContainer[which]) or nameplate[which]
	auras.isNameplate = true
	auras.useWidth = true -- this helps keeps row count proper when using keepSizeRatio
	auras.size = db.size
	auras.height = not db.keepSizeRatio and db.height
	auras.numAuras = db.numAuras
	auras.numRows = db.numRows
	auras.spacing = db.spacing
	auras.growthY = UF.MatchGrowthY[db.anchorPoint] or db.growthY
	auras.growthX = UF.MatchGrowthX[db.anchorPoint] or db.growthX
	auras.xOffset = db.xOffset
	auras.yOffset = db.yOffset
	auras.anchorPoint = db.anchorPoint
	auras.colorByType = NP.db.colors.auraByType
	auras.auraSort = UF.SortAuraFuncs[E.Retail and 'PLAYER' or db.sortMethod]
	auras.smartPosition, auras.smartFluid = UF:SetSmartPosition(nameplate)
	auras.attachTo = not preallocated and UF:GetAuraAnchorFrame(nameplate, db.attachTo, nameplate.AuraContainer) or nil -- keep below SetSmartPosition
	auras.num = db.numAuras * db.numRows
	auras.db = db -- for auraSort

	local growDown = auras.yOffset == 'DOWN'
	auras.paddingLeft, auras.paddingRight, auras.paddingTop, auras.paddingBottom = 0, 0, growDown and 1 or 0, growDown and 0 or 1

	local initialAnchor = E.InversePoints[db.anchorPoint]
	if E.Retail then
		auras.noMouse = true
		auras.auraType = auraType
		auras.maxFrameCount = auras.num
		auras.nameplateType = nameplate.frameType
		auras.initialAnchor = E.CenterPoint[db.anchorPoint] or initialAnchor
		auras.keepSizeRatio = db.keepSizeRatio
		auras.sortMethod = E.AuraContainerSortMethod[db.sortMethod]
		auras.countPosition, auras.countXOffset, auras.countYOffset = db.countPosition, db.countXOffset, db.countYOffset
		auras.countFont, auras.countFontSize, auras.countFontOutline = db.countFont, db.countFontSize, db.countFontOutline
		auras.forceShowAuras = nameplate == NP.TestFrame

		auras.filters = NP:Configure_AuraFilters(nameplate, which)

		E:Auras_SetContainer(auras)
		E:Auras_SetLineSize(auras)
	else
		auras.filterList = UF:ConvertFilters(auras, db.priority)
		auras.initialAnchor = initialAnchor

		local index = 1
		while auras[index] do
			local button = auras[index]
			if button then
				button.db = db
				NP:UpdateAuraSettings(button)
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end

			index = index + 1
		end

		auras:Size(db.numAuras * db.size + ((db.numAuras - 1) * db.spacing), 1)
	end

	auras:SetFrameLevel(7)
	auras:ClearAllPoints()
	auras:Point(auras.initialAnchor, auras.attachTo, auras.anchorPoint, auras.xOffset, auras.yOffset)
end

function NP:Update_Auras(nameplate)
	local db = NP:PlateDB(nameplate)

	if db.auras.enable or db.debuffs.enable or db.buffs.enable then
		if not nameplate:IsElementEnabled('Auras') then
			nameplate:EnableElement('Auras')
		end

		if db.auras.enable then
			nameplate.Auras = nameplate.Auras_
			NP:Configure_Auras(nameplate, 'Auras')
			nameplate.Auras:Show()
		elseif nameplate.Auras then
			nameplate.Auras:Hide()
			nameplate.Auras = nil
		end

		if db.debuffs.enable then
			nameplate.Debuffs = nameplate.Debuffs_
			NP:Configure_Auras(nameplate, 'Debuffs')
			nameplate.Debuffs:Show()
		elseif nameplate.Debuffs then
			nameplate.Debuffs:Hide()
			nameplate.Debuffs = nil
		end

		if db.buffs.enable then
			nameplate.Buffs = nameplate.Buffs_
			NP:Configure_Auras(nameplate, 'Buffs')
			nameplate.Buffs:Show()
		elseif nameplate.Buffs then
			nameplate.Buffs:Hide()
			nameplate.Buffs = nil
		end
	elseif E.Retail then
		NP:Configure_AuraContainers(nameplate, false)
	elseif nameplate:IsElementEnabled('Auras') then
		nameplate:DisableElement('Auras')
	end
end

function NP:UpdateAuraSettings(button)
	local db = button.db
	if db then
		if button.Count then
			local point = db.countPosition or 'CENTER'
			button.Count:SetJustifyH(strfind(point, 'RIGHT') and 'RIGHT' or 'LEFT')
			button.Count:FontTemplate(db.countFont, db.countFontSize, db.countFontOutline)
			button.Count:ClearAllPoints()
			button.Count:Point(point, db.countXOffset, db.countYOffset)
		end

		if button.Text then
			local point = db.sourceText.position or 'TOP'
			button.Text:SetJustifyH(strfind(point, 'RIGHT') and 'RIGHT' or 'LEFT')
			button.Text:FontTemplate(db.sourceText.font, db.sourceText.fontSize, db.sourceText.fontOutline)
			button.Text:ClearAllPoints()
			button.Text:Point(point or 'TOP', db.sourceText.xOffset, db.sourceText.yOffset)
		end
	end

	button.needsButtonTrim = true
end
