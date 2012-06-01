local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function ApplyMySkin(self)
	local xScale = self.db.width / 36
	local yScale = self.db.height / 36

	local t = self.elements.texMain
	t:ClearAllPoints()
	t:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -2)
	t:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 2)
	t:SetTexCoord(unpack(E.TexCoords))

	t = self.elements.texNormal
	t:Hide()
	
	t = self.elements.texHighlight
	t:SetTexture("Interface\\AddOns\\clcInfo\\textures\\IconHighlight")
	t:SetSize(self.db.width, self.db.height)
	t:ClearAllPoints()
	t:SetPoint("CENTER", self.elements, "CENTER", 0, 0)
	t:SetVertexColor(1, 1, 1, 1)
	
	t = self.elements.texGloss
	t:Hide()
	
	if not self.elements.backdropFrame then
		local bg = CreateFrame('Frame', nil, self.elements)
		bg:SetTemplate('Default')
		bg:SetPoint('TOPLEFT', self, 'TOPLEFT')
		bg:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT')
		bg:SetFrameLevel(self:GetFrameLevel() - 1)
		bg:Show()
		self.elements.backdropFrame = bg
	else
		self.elements.backdropFrame:Show()
	end
	
	-- adjust the text size
	local count = self.elements.count
	count:SetSize(40 * xScale, 10 * yScale)
	count:ClearAllPoints()
	count:SetPoint("CENTER", self.elements, "CENTER", -2 * xScale, -8 * yScale)
	count:FontTemplate()
end

local function TryGridPositioning(self)
	if self.db.gridId <= 0 then return end
	
	local f = clcInfo.display.grids.active[self.db.gridId]
	if not f then return end
	
	local g = f.db
	
	-- size
	self.db.width = g.cellWidth * self.db.sizeX + g.spacingX * (self.db.sizeX - 1) 
	self.db.height = g.cellHeight * self.db.sizeY + g.spacingY * (self.db.sizeY - 1)
	self:ClearAllPoints()
	self:SetWidth(self.db.width)
	self:SetHeight(self.db.height)
	
	-- position
	local x = g.cellWidth * (self.db.gridX - 1) + g.spacingX * (self.db.gridX - 1)
	local y = g.cellHeight * (self.db.gridY - 1) + g.spacingY * (self.db.gridY - 1)
	self:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", x, y)
		
	return true
end

local function UpdateLayout(self)
	self:OldUpdateLayout()

	-- select the skin from template/grid/self
	local onGrid = TryGridPositioning(self)
	local skinType, g
	if onGrid and self.db.skinSource == "Grid" then
		g = clcInfo.display.grids.active[self.db.gridId].db.skinOptions.icons
	elseif self.db.skinSource == "Template" then
		g = clcInfo.activeTemplate.skinOptions.icons
	else
		g = self.db.skin
	end
	skinType = g.skinType

	-- apply the skin
	if skinType == "ElvUI" then
		ApplyMySkin(self)
	elseif self.elements.backdropFrame then
		self.elements.backdropFrame:Hide()
	end	
end

local function New(self, index)
	self.oldNew(self, index)
	local icon = self.active[index]
	if icon then
		if not icon.OldUpdateLayout then
			icon.OldUpdateLayout = icon.UpdateLayout
		end
		
		icon.UpdateLayout = UpdateLayout
		icon:UpdateLayout()
	end
end

local function LoadActiveTemplate(self)
	self.OldLoadActiveTemplate(self)

	local options = self.options.args.activeTemplate.args.skins.args
	options.icons.args.selectType.args.skinType.values = options.icons.args.selectType.args.skinType.values()
	options.icons.args.selectType.args.skinType.values['ElvUI'] = 'ElvUI'
	
	options.micons.args.selectType.args.skinType.values = options.micons.args.selectType.args.skinType.values()
	options.micons.args.selectType.args.skinType.values['ElvUI'] = 'ElvUI'	
end

local function UpdateGridList(self)
	self.OldUpdateGridList(self)
	
	local db = clcInfo.display.grids.active
	local optionsGrids = self.options.args.activeTemplate.args.grids
	for i = 1, #db do
		local options = optionsGrids.args[tostring(i)].args.tabSkins.args
		options.icons.args.selectType.args.skinType.values = options.icons.args.selectType.args.skinType.values()
		options.icons.args.selectType.args.skinType.values['ElvUI'] = 'ElvUI'
		
		options.micons.args.selectType.args.skinType.values = options.micons.args.selectType.args.skinType.values()
		options.micons.args.selectType.args.skinType.values['ElvUI'] = 'ElvUI'		
	end
end

local function UpdateIconList(self)
	self.OldUpdateIconList(self)
	
	local db = clcInfo.display.icons.active
	local optionsIcons = self.options.args.activeTemplate.args.icons
	for i = 1, #db do
		local options = optionsIcons.args[tostring(i)].args.tabSkin.args
		options.selectType.args.skinType.values = options.selectType.args.skinType.values()
		options.selectType.args.skinType.values['ElvUI'] = 'ElvUI'
	end	
end

local function UpdateMIconList(self)
	self.OldUpdateMIconList(self)
	
	local db = clcInfo.display.micons.active
	local optionsMIcons = self.options.args.activeTemplate.args.micons
	for i = 1, #db do
		local options = optionsMIcons.args[tostring(i)].args.tabSkin.args
		options.selectType.args.skinType.values = options.selectType.args.skinType.values()
		options.selectType.args.skinType.values['ElvUI'] = 'ElvUI'	
	end	
end


local function CLCInfo()
	if not clcInfo then return; end
	local mod = clcInfo.display['icons']
	if not mod then return; end
	mod.oldNew = mod.New
	mod.New = New
end

local function CLCInfo_Options()
	local mod = clcInfo_Options
	if not mod then return; end
	
	mod.OldLoadActiveTemplate = mod.LoadActiveTemplate
	mod.LoadActiveTemplate = LoadActiveTemplate
	
	mod.OldUpdateGridList = mod.UpdateGridList
	mod.UpdateGridList = UpdateGridList
	
	mod.OldUpdateIconList = mod.UpdateIconList
	mod.UpdateIconList = UpdateIconList
	
	mod.OldUpdateMIconList = mod.UpdateMIconList
	mod.UpdateMIconList = UpdateMIconList	
end

S:RegisterSkin('clcInfo_Options', CLCInfo_Options)
S:RegisterSkin('clcInfo', CLCInfo)