local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not Skada or not C["skin"].skada == true then return end

local Skada = Skada
local barSpacing = E.Scale(1, 1)
local borderWidth = E.Scale(2, 2)

-- Used to strip unecessary options from the in-game config
local function StripOptions(options)
	options.baroptions.args.bartexture = options.windowoptions.args.height
	options.baroptions.args.bartexture.order = 12
	options.baroptions.args.bartexture.max = 1
	options.baroptions.args.barspacing = nil
	options.titleoptions.args.texture = nil
	options.titleoptions.args.bordertexture = nil
	options.titleoptions.args.thickness = nil
	options.titleoptions.args.margin = nil
	options.titleoptions.args.color = nil
	options.windowoptions = nil
	options.baroptions.args.barfont = nil
	options.titleoptions.args.font = nil
end

local barmod = Skada.displays["bar"]
barmod.AddDisplayOptions_ = barmod.AddDisplayOptions
barmod.AddDisplayOptions = function(self, win, options)
	self:AddDisplayOptions_(win, options)
	StripOptions(options)
end

for k, options in pairs(Skada.options.args.windows.args) do
	if options.type == "group" then
		StripOptions(options.args)
	end
end

-- Size height correctly
barmod.AdjustBackgroundHeight = function(self,win)
	local numbars = 0
	if win.bargroup:GetBars() ~= nil then
		if win.db.background.height == 0 then
			for name, bar in pairs(win.bargroup:GetBars()) do if bar:IsShown() then numbars = numbars + 1 end end
		else
			numbars = win.db.barmax
		end
		if win.db.enabletitle then numbars = numbars + 1 end
		if numbars < 1 then numbars = 1 end
		local height = numbars * (win.db.barheight + barSpacing) + barSpacing + borderWidth
		if win.bargroup.bgframe:GetHeight() ~= height then
			win.bargroup.bgframe:SetHeight(height)
		end
	end
end

-- Override settings from in-game GUI
local titleBG = {
	bgFile = C["media"].normTex,
	tile = false,
	tileSize = 0
}

barmod.ApplySettings_ = barmod.ApplySettings
barmod.ApplySettings = function(self, win)
	win.db.enablebackground = true
	win.db.background.borderthickness = borderWidth
	barmod:ApplySettings_(win)

	if win.db.enabletitle then
		win.bargroup.button:SetBackdrop(titleBG)
	end
	
	win.bargroup:SetTexture(C["media"].normTex)
	win.bargroup:SetSpacing(barSpacing)
	win.bargroup:SetFont(C["media"].font, C["general"].fontscale)
	win.bargroup:SetFrameLevel(5)
	
	local titlefont = CreateFont("TitleFont"..win.db.name)
	titlefont:SetFont(C["media"].font, C["general"].fontscale)
	win.bargroup.button:SetNormalFontObject(titlefont)
	win.bargroup.button:SetFrameStrata("HIGH")
	win.bargroup.button:SetFrameLevel(5)
	
	
	local color = win.db.title.color
	win.bargroup.button:SetBackdropColor(unpack(C["media"].bordercolor))
	if win.bargroup.bgframe then
		win.bargroup.bgframe:SetTemplate("Transparent")
		if win.db.reversegrowth then
			win.bargroup.bgframe:SetPoint("BOTTOM", win.bargroup.button, "BOTTOM", 0, -1 * (win.db.enabletitle and 2 or 1))
		else
			win.bargroup.bgframe:SetPoint("TOP", win.bargroup.button, "TOP", 0,1 * (win.db.enabletitle and 2 or 1))
		end
	end
	
	win.bargroup.bgframe:SetFrameStrata("HIGH")
	win.bargroup:SetFrameStrata("HIGH")
	
	self:AdjustBackgroundHeight(win)
	win.bargroup:SetMaxBars(win.db.barmax)
	win.bargroup:SortBars()
end

local function EmbedWindow(window, width, height, max, point, relativeFrame, relativePoint, ofsx, ofsy)
	window.db.barwidth = width
	window.db.barheight = height
	window.db.barmax = (floor(max / window.db.barheight) - (window.db.enabletitle and 1 or 0))
	window.db.background.height = 1
	window.db.spark = false
	window.db.barslocked = true
	window.bargroup:ClearAllPoints()
	window.bargroup:SetPoint(point, relativeFrame, relativePoint, ofsx, ofsy)
	
	barmod.ApplySettings(barmod, window)
end

local windows = {}
function EmbedSkada()
	if #windows == 1 then
		EmbedWindow(windows[1], C["chat"].chatwidth - 4, (C["chat"].chatheight - (barSpacing * 5)) / 8, C["chat"].chatheight, "TOPRIGHT", ChatRBackground2, "TOPRIGHT", -2, -2)
	elseif #windows == 2 then
		EmbedWindow(windows[1], ((C["chat"].chatwidth - 4) / 2) - (borderWidth + E.mult), (C["chat"].chatheight - (barSpacing * 5)) / 8, C["chat"].chatheight,  "TOPRIGHT", ChatRBackground2, "TOPRIGHT", -2, -2)
		EmbedWindow(windows[2], ((C["chat"].chatwidth - 4) / 2) - (borderWidth + E.mult), (C["chat"].chatheight - (barSpacing * 5)) / 8, C["chat"].chatheight,  "TOPLEFT", ChatRBackground2, "TOPLEFT", 2, -2)
	elseif #windows > 2 then
		EmbedWindow(windows[1], ((C["chat"].chatwidth - 4) / 2) - (borderWidth + E.mult), (C["chat"].chatheight - (barSpacing * 5)) / 8, C["chat"].chatheight,  "TOPRIGHT", ChatRBackground2, "TOPRIGHT", -2, -2)
		EmbedWindow(windows[2], ((C["chat"].chatwidth - 4) / 2) - (borderWidth + E.mult), (C["chat"].chatheight - (barSpacing * 8)) / 8, C["chat"].chatheight / 2,  "TOPLEFT", ChatRBackground2, "TOPLEFT", 2, -2)
		EmbedWindow(windows[3], windows[2].db.barwidth, (C["chat"].chatheight - (barSpacing * 8)) / 8, C["chat"].chatheight / 2,  "TOPLEFT", windows[2].bargroup.bgframe, "BOTTOMLEFT", 2, -2)
	end
end

-- Update pre-existing displays
for _, window in ipairs(Skada:GetWindows()) do
	window:UpdateDisplay()
	tinsert(windows, window)
end

if C["skin"].embedright == "Skada" then
	Skada.CreateWindow_ = Skada.CreateWindow
	function Skada:CreateWindow(name, db)
		Skada:CreateWindow_(name, db)
		
		windows = {}
		for _, window in ipairs(Skada:GetWindows()) do
			tinsert(windows, window)
		end	
		
		EmbedSkada()
	end

	Skada.DeleteWindow_ = Skada.DeleteWindow
	function Skada:DeleteWindow(name)
		Skada:DeleteWindow_(name)
		
		windows = {}
		for _, window in ipairs(Skada:GetWindows()) do
			tinsert(windows, window)
		end	
		
		EmbedSkada()
	end

	local Skada_Skin = CreateFrame("Frame")
	Skada_Skin:RegisterEvent("PLAYER_ENTERING_WORLD")
	Skada_Skin:SetScript("OnEvent", function(self)
		self:UnregisterAllEvents()
		self = nil
		
		EmbedSkada()
	end)	
end