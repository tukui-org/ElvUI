local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Cache global variables
--Lua functions
local abs, floor, min, max = math.abs, math.floor, math.min, math.max
--WoW API / Variables
local GetCVar, SetCVar = GetCVar, SetCVar

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: UIParent

--Determine if Eyefinity is being used, setup the pixel perfect script.
function E:UIScale(event, loginFrame)
	local width = E.screenwidth
	local height = E.screenheight
	local scale

	local uiScaleCVar = GetCVar('uiScale')
	if uiScaleCVar then
		E.global.uiScale = uiScaleCVar
	end

	local minScale = E.global.general.minUiScale or 0.64
	if E.global.general.autoScale then
		scale = max(minScale, min(1.15, 768/height))
	else
		scale = max(minScale, min(1.15, E.global.uiScale or (height > 0 and (768/height)) or UIParent:GetScale()))
	end

	if width < 1600 then
		E.lowversion = true
	elseif width >= 3840 and E.global.general.eyefinity then
		-- because some user enable bezel compensation, we need to find the real width of a single monitor.
		-- I don't know how it really work, but i'm assuming they add pixel to width to compensate the bezel. :P

		-- HQ resolution
		if width >= 9840 then width = 3280; end							-- WQSXGA
		if width >= 7680 and width < 9840 then width = 2560; end		-- WQXGA
		if width >= 5760 and width < 7680 then width = 1920; end		-- WUXGA & HDTV
		if width >= 5040 and width < 5760 then width = 1680; end		-- WSXGA+

		-- adding height condition here to be sure it work with bezel compensation because WSXGA+ and UXGA/HD+ got approx same width
		if width >= 4800 and width < 5760 and height == 900 then width = 1600; end	-- UXGA & HD+

		-- low resolution screen
		if width >= 4320 and width < 4800 then width = 1440; end		-- WSXGA
		if width >= 4080 and width < 4320 then width = 1360; end		-- WXGA
		if width >= 3840 and width < 4080 then width = 1224; end		-- SXGA & SXGA (UVGA) & WXGA & HDTV

		-- yep, now set ElvUI to lower resolution if screen #1 width < 1600
		if width < 1600 then
			E.lowversion = true
		end

		-- register a constant, we will need it later for launch.lua
		E.eyefinity = width
	end

	E.mult = 768/height/scale
	E.Spacing = (E.PixelMode and 0) or E.mult
	E.Border = (E.PixelMode and E.mult) or E.mult*2

	if E.global.general.autoScale then
		--Set UIScale, NOTE: SetCVar for UIScale can cause taints so only do this when we need to..
		if E.Round and event == 'PLAYER_LOGIN' and (E:Round(UIParent:GetScale(), 5) ~= E:Round(scale, 5)) then
			SetCVar("useUiScale", 1)
			SetCVar("uiScale", scale)
		end

		--SetCVar for UI scale only accepts value as low as 0.64, so scale UIParent if needed
		if scale < 0.64 then
			UIParent:SetScale(scale)
		end
	end

	if event == 'PLAYER_LOGIN' or event == 'UI_SCALE_CHANGED' then
		--Resize E.UIParent if Eyefinity is on.
		if E.eyefinity then
			-- if autoscale is off, find a new width value of E.UIParent for screen #1.
			if not E.global.general.autoScale or height > 1200 then
				local h = UIParent:GetHeight()
				local ratio = (height / h)
				local w = (width / ratio)

				width = w
				height = h
			end
			--[[ Eyefinity Test mode
					--Resize the E.UIParent to be smaller than it should be, all objects inside should relocate.
					--Dragging moveable frames outside the box and reloading the UI ensures that they are saving position correctly.
				E.UIParent:SetSize(UIParent:GetWidth() - 250, UIParent:GetHeight() - 250)
			]]
		else
			width, height = UIParent:GetSize()
		end

		E.UIParent:SetSize(width, height)
		E.UIParent.origHeight = E.UIParent:GetHeight()
		E.UIParent:ClearAllPoints()

		if E.global.general.commandBarSetting == "ENABLED_RESIZEPARENT" then
			E.UIParent:Point("BOTTOM")
		else
			E.UIParent:Point("CENTER")
		end

		--Calculate potential coordinate differences
		E.diffGetLeft = E:Round(abs(UIParent:GetLeft() - E.UIParent:GetLeft()))
		E.diffGetRight = E:Round(abs(UIParent:GetRight() - E.UIParent:GetRight()))
		E.diffGetTop = E:Round(abs(UIParent:GetTop() - E.UIParent:GetTop()))
		E.diffGetBottom = E:Round(abs(UIParent:GetBottom() - E.UIParent:GetBottom()))

		local change
		if E.Round then
			change = abs((E:Round(UIParent:GetScale(), 5) * 100) - (E:Round(scale, 5) * 100))
		end

		if event == 'UI_SCALE_CHANGED' and (change and change > 1) then
			if E.global.general.autoScale then
				E:StaticPopup_Show('FAILED_UISCALE')
			else
				E:StaticPopup_Show('CONFIG_RL')
			end
		end

		if loginFrame and event == 'PLAYER_LOGIN' then
			loginFrame:UnregisterEvent('PLAYER_LOGIN')
		end
	end
end

-- pixel perfect script of custom ui scale.
function E:Scale(x)
	return E.mult * floor(x/E.mult+.5)
end
