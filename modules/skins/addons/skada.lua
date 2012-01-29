local E, L, DF = unpack(select(2, ...)); --Engine
local S = E:GetModule('Skins')
L.addons_toggle = "Toggle"
-- Used to strip unecessary options from the in-game config
local function StripOptions(options)
	--options.baroptions.args.barspacing = nil
	options.titleoptions.args.texture = nil
	options.titleoptions.args.bordertexture = nil
	options.titleoptions.args.thickness = nil
	options.titleoptions.args.margin = nil
	options.titleoptions.args.color = nil
	options.windowoptions = nil
	--options.baroptions.args.barfont = nil
	--options.titleoptions.args.font = nil
end

local function LoadSkin()
	if E.db.skins.skada.enable ~= true then return end
	local Skada = Skada
	local barSpacing = 1
	local borderWidth = 1
	local barmod = Skada.displays["bar"]
	local windows = Skada:GetWindows()
	
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

	local titleBG = {
		bgFile = E["media"].normTex,
		tile = false,
		tileSize = 0
	}

	barmod.ApplySettings_ = barmod.ApplySettings
	barmod.ApplySettings = function(self, win)
		barmod.ApplySettings_(self, win)

		local skada = win.bargroup

		if win.db.enabletitle then
			skada.button:SetBackdrop(titleBG)
		end

		skada:SetSpacing(barSpacing)
		skada:SetFrameLevel(5)
		
		local titlefont = CreateFont("TitleFont"..win.db.name)
		win.bargroup.button:SetNormalFontObject(titlefont)

		win.bargroup.button:SetBackdropColor(unpack(E["media"].backdropcolor))

		skada:SetBackdrop(nil)
		if not skada.backdrop then
			skada:CreateBackdrop('Transparent')
		end
		skada.backdrop:ClearAllPoints()
		if win.db.enabletitle then
			skada.backdrop:Point('TOPLEFT', win.bargroup.button, 'TOPLEFT', -2, 2)
		else
			skada.backdrop:Point('TOPLEFT', win.bargroup, 'TOPLEFT', -2, 2)
		end
		skada.backdrop:Point('BOTTOMRIGHT', win.bargroup, 'BOTTOMRIGHT', 2, -2)
		
		if E.db['skins']['embedRight'] == "Skada" then
			win.bargroup.button:SetFrameStrata("MEDIUM")
			win.bargroup.button:SetFrameLevel(5)
			win.bargroup:SetFrameStrata("MEDIUM")
		end
	end

	if E.db['skins']['embedRight'] == "Skada" then

		local function EmbedWindow(window, width, barheight, height, point, relativeFrame, relativePoint, ofsx, ofsy)
			local barheight = 16
			window.db.barwidth = width
			window.db.barheight = barheight
			if window.db.enabletitle then
				height = height - barheight
			end
			window.db.background.height = height
			window.db.spark = false
			window.db.barslocked = true
			window.bargroup:ClearAllPoints()
			--window.bargroup:SetPoint(point, relativeFrame, relativePoint, ofsx-5, ofsy+30)
			window.bargroup:SetPoint(point, relativeFrame, relativePoint, ofsx, ofsy)

			barmod.ApplySettings(barmod, window)
		end

		local mwidth = E.db['core'].panelWidth - 14
		local mheight = E.db['core'].panelHeight - 63

		function EmbedSkada()
			if #windows == 1 then
				EmbedWindow(windows[1], mwidth, (mheight - (barSpacing * 6)) / 11, (mheight + 1), "BOTTOMRIGHT", RightChatToggleButton, "TOPRIGHT", -2, 4)
			elseif #windows == 2 then
				EmbedWindow(windows[1], ((mwidth / 3)*2) - (borderWidth + E.mult) -1, (mheight - (barSpacing * 10)) / 10, mheight + 1,  "BOTTOMRIGHT", RightChatToggleButton, "TOPRIGHT", -2, 4)
				EmbedWindow(windows[2], (mwidth / 3) - (borderWidth + E.mult) -1, (mheight - (barSpacing * 10)) / 10, mheight + 1,  "BOTTOMLEFT", RightChatDataPanel, "TOPLEFT", 2, 4)
			elseif #windows > 2 then
				EmbedWindow(windows[1], ((mwidth / 3)*2) - (borderWidth + E.mult) -1, (mheight - (barSpacing * 10)) / 10, mheight + 1,  "BOTTOMRIGHT", RightChatToggleButton, "TOPRIGHT", -2, 4)
				EmbedWindow(windows[2], (mwidth / 3) - (borderWidth + E.mult) -1, ((mheight/2) - (barSpacing * 6)) / 4, mheight / 2 - 2,  "BOTTOMLEFT", RightChatDataPanel, "TOPLEFT", 2, 4)
				EmbedWindow(windows[3], windows[2].db.barwidth, ((mheight/2) - (barSpacing * 6)) / 4, mheight / 2 - 2,  "BOTTOMLEFT", windows[2].bargroup.backdrop, "TOPLEFT", 2, 3)
			end
		end



		-- Update pre-existing displays
		for _, window in ipairs(Skada:GetWindows()) do
			window:UpdateDisplay()
		end

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
		Skada_Skin:RegisterEvent('PLAYER_ENTERING_WORLD', 'Initialize')
		Skada_Skin:SetScript("OnEvent", function(self)
			self:UnregisterAllEvents()
			self = nil
			EmbedSkada()
		end)

		if RightChatTab then
			local button = CreateFrame('Button', 'SkadaToggleSwitch', RightChatTab)
			button:Width(16)
			button:Height(RightChatTab:GetHeight() - 4)
			button:Point("RIGHT", RightChatTab, "RIGHT", -2, 0)

			button.tex = button:CreateTexture(nil, 'OVERLAY')
			button.tex:SetTexture([[Interface\AddOns\ElvUI\media\textures\vehicleexit.tga]])
			button.tex:Point('TOPRIGHT', -2, -2)
			button.tex:Height(button:GetHeight() - 4)
			button.tex:Width(16)

			button:SetScript('OnMouseDown', function(self) self.tex:Point('TOPRIGHT', -4, -4) end)
			button:SetScript('OnMouseUp', function(self) self.tex:Point('TOPRIGHT', -2, -2) end)
			button:SetScript('OnClick', function(self) Skada:ToggleWindow() end)
		end
		
		-- Set up button toggle script
		-- local toggle = RightChatToggleButton
		-- toggle:HookScript(OnMouseDown, function(self,button)
			-- if button == "RightButton" then
				-- Skada:ToggleWindow()
			-- end
		-- end)
	end
end

S:RegisterSkin('Skada', LoadSkin)