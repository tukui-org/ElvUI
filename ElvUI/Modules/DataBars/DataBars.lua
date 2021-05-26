local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DB = E:GetModule('DataBars')
local LSM = E.Libs.LSM

local _G = _G
local unpack, select = unpack, select
local pairs, ipairs = pairs, ipairs
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local UnitAffectingCombat = UnitAffectingCombat
local C_PvP_IsWarModeActive = C_PvP.IsWarModeActive

function DB:OnLeave()
	if self.db.mouseover then
		E:UIFrameFadeOut(self, 1, self:GetAlpha(), 0)
	end

	if not _G.GameTooltip:IsForbidden() then
		_G.GameTooltip:Hide()
	end
end

function DB:CreateBar(name, key, updateFunc, onEnter, onClick, points)
	local holder = CreateFrame('Frame', name..'Holder', E.UIParent)
	holder:SetTemplate(DB.db.transparent and 'Transparent')
	holder:SetScript('OnEnter', onEnter)
	holder:SetScript('OnLeave', DB.OnLeave)
	holder:SetScript('OnMouseDown', onClick)

	if points then
		holder:ClearAllPoints()
		holder:Point(unpack(points))
	end

	local bar = CreateFrame('StatusBar', name, holder)
	bar:SetStatusBarTexture(E.media.normTex)
	bar:EnableMouse(false)
	bar:SetInside()
	bar:Hide()

	bar.barTexture = bar:GetStatusBarTexture()
	bar.text = bar:CreateFontString(nil, 'OVERLAY', nil, 7)
	bar.text:FontTemplate()
	bar.text:Point('CENTER')

	bar.holder = holder
	bar.Update = updateFunc

	E.FrameLocks[holder] = true
	DB.StatusBars[key] = bar

	return bar
end

function DB:CreateBarBubbles(bar)
	if bar.bubbles then return end

	bar.bubbles = {}

	for i = 1, 19 do
		bar.bubbles[i] = bar:CreateTexture(nil, 'OVERLAY', nil, 0)
		bar.bubbles[i]:SetColorTexture(0, 0, 0)
	end
end

function DB:UpdateBarBubbles(bar)
	if not bar.bubbles then return end

	local width, height = bar.db.width, bar.db.height
	local vertical = bar:GetOrientation() ~= 'HORIZONTAL'
	local bubbleWidth, bubbleHeight = vertical and (width - 2) or 1, vertical and 1 or (height - 2)
	local offset = (vertical and height or width) / 20

	for i, bubble in ipairs(bar.bubbles) do
		bubble:ClearAllPoints()
		bubble:SetShown(bar.db.showBubbles)
		bubble:Size(bubbleWidth, bubbleHeight)

		if vertical then
			bubble:Point('TOP', bar, 'BOTTOM', 0, offset * i)
		else
			bubble:Point('RIGHT', bar, 'LEFT', offset * i, 0)
		end
	end
end

function DB:UpdateAll()
	local texture = DB.db.customTexture and LSM:Fetch('statusbar', DB.db.statusbar) or E.media.normTex

	for _, bar in pairs(DB.StatusBars) do
		bar.holder.db = bar.db
		bar.holder:Size(bar.db.width, bar.db.height)
		bar.holder:SetTemplate(DB.db.transparent and 'Transparent')
		bar.holder:EnableMouse(not bar.db.clickThrough)
		bar.holder:SetFrameLevel(bar.db.frameLevel)
		bar.holder:SetFrameStrata(bar.db.frameStrata)
		bar.text:FontTemplate(LSM:Fetch('font', bar.db.font), bar.db.fontSize, bar.db.fontOutline)
		bar:SetStatusBarTexture(texture)
		bar:SetReverseFill(bar.db.reverseFill)

		if bar.db.enable then
			bar.holder:SetAlpha(bar.db.mouseover and 0 or 1)
		end

		if bar.db.hideInVehicle then
			E:RegisterObjectForVehicleLock(bar.holder, E.UIParent)
		else
			E:UnregisterObjectForVehicleLock(bar.holder)
		end

		if bar.db.orientation == 'AUTOMATIC' then
			bar:SetOrientation(bar.db.height > bar.db.width and 'VERTICAL' or 'HORIZONTAL')
			bar:SetRotatesTexture(bar.db.height > bar.db.width)
		else
			bar:SetOrientation(bar.db.orientation)
			bar:SetRotatesTexture(bar.db.orientation ~= 'HORIZONTAL')
		end

		local orientation = bar:GetOrientation()
		local rotatesTexture = bar:GetRotatesTexture()
		local reverseFill = bar:GetReverseFill()

		for i = 1, bar.holder:GetNumChildren() do
			local child = select(i, bar.holder:GetChildren())
			if child:IsObjectType('StatusBar') then
				child:SetStatusBarTexture(texture)
				child:SetOrientation(orientation)
				child:SetRotatesTexture(rotatesTexture)
				child:SetReverseFill(reverseFill)
			end
		end

		DB:UpdateBarBubbles(bar)
	end

	DB:HandleVisibility()
end

function DB:SetVisibility(bar)
	if bar.showBar ~= nil then
		bar:SetShown(bar.showBar)
		bar.holder:SetShown(bar.showBar)
	elseif bar.db.enable then
		local hideBar = (bar == DB.StatusBars.Threat or bar.db.hideInCombat) and UnitAffectingCombat('player')
		or (bar.db.hideOutsidePvP and not (C_PvP_IsWarModeActive() or select(2, GetInstanceInfo()) == 'pvp'))
		or (bar.ShouldHide and bar:ShouldHide())

		bar:SetShown(not hideBar)
		bar.holder:SetShown(not hideBar)
	else
		bar:SetShown(false)
		bar.holder:SetShown(false)
	end
end

function DB:HandleVisibility()
	for _, bar in pairs(DB.StatusBars) do
		DB:SetVisibility(bar)
	end
end

function DB:Initialize()
	DB.Initialized = true
	DB.StatusBars = {}

	DB.db = E.db.databars

	DB:ExperienceBar()
	DB:ReputationBar()
	DB:HonorBar()
	DB:AzeriteBar()
	DB:ThreatBar()

	DB:UpdateAll()

	DB:RegisterEvent('PLAYER_LEVEL_UP', 'HandleVisibility')
	DB:RegisterEvent('PLAYER_ENTERING_WORLD', 'HandleVisibility')
	DB:RegisterEvent('PLAYER_REGEN_DISABLED', 'HandleVisibility')
	DB:RegisterEvent('PLAYER_REGEN_ENABLED', 'HandleVisibility')
	DB:RegisterEvent('PVP_TIMER_UPDATE', 'HandleVisibility')
end

E:RegisterModule(DB:GetName())
