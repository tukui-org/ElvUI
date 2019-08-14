local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Lua functions
local min, max, abs, floor = min, max, abs, floor
local format, tonumber = format, tonumber
--WoW API / Variables
local UIParent = UIParent

function E:IsEyefinity(width, height)
	if E.global.general.eyefinity and width >= 3840 then
		--HQ resolution
		if width >= 9840 then return 3280 end					--WQSXGA
		if width >= 7680 and width < 9840 then return 2560 end	--WQXGA
		if width >= 5760 and width < 7680 then return 1920 end	--WUXGA & HDTV
		if width >= 5040 and width < 5760 then return 1680 end	--WSXGA+

		--adding height condition here to be sure it work with bezel compensation because WSXGA+ and UXGA/HD+ got approx same width
		if width >= 4800 and width < 5760 and height == 900 then return 1600 end --UXGA & HD+

		--low resolution screen
		if width >= 4320 and width < 4800 then return 1440 end	--WSXGA
		if width >= 4080 and width < 4320 then return 1360 end	--WXGA
		if width >= 3840 and width < 4080 then return 1224 end	--SXGA & SXGA (UVGA) & WXGA & HDTV
	end
end

function E:UIScale(init)
	local scale = E.global.general.UIScale
	if init then --E.OnInitialize
		--Set variables for pixel scaling
		local pixel, ratio = 1, 768 / E.screenheight
		E.mult = (pixel / scale) - ((pixel - ratio) / scale)
		E.Spacing = (E.PixelMode and 0) or E.mult
		E.Border = ((not E.twoPixelsPlease) and E.PixelMode and E.mult) or E.mult*2
	else --E.Initialize
		UIParent:SetScale(scale)

		--Check if we are using `E.eyefinity`
		local width, height = E.screenwidth, E.screenheight
		E.eyefinity = E:IsEyefinity(width, height)

		--Resize E.UIParent if Eyefinity is on.
		local testingEyefinity = false
		if testingEyefinity then
			--Eyefinity Test: Resize the E.UIParent to be smaller than it should be, all objects inside should relocate.
			--Dragging moveable frames outside the box and reloading the UI ensures that they are saving position correctly.
			local uiWidth, uiHeight = UIParent:GetSize()
			width, height = uiWidth-250, uiHeight-250
		elseif E.eyefinity then
			--find a new width value of E.UIParent for screen #1.
			local uiHeight = UIParent:GetHeight()
			width, height = E.eyefinity / (height / uiHeight), uiHeight
		else
			width, height = UIParent:GetSize()
		end

		E.UIParent:SetSize(width, height)
		E.UIParent.origHeight = E.UIParent:GetHeight()

		--Calculate potential coordinate differences
		E.diffGetLeft = E:Round(abs(UIParent:GetLeft() - E.UIParent:GetLeft()))
		E.diffGetRight = E:Round(abs(UIParent:GetRight() - E.UIParent:GetRight()))
		E.diffGetBottom = E:Round(abs(UIParent:GetBottom() - E.UIParent:GetBottom()))
		E.diffGetTop = E:Round(abs(UIParent:GetTop() - E.UIParent:GetTop()))
	end
end

function E:PixelBestSize()
	return max(0.4, min(1.15, 768 / E.screenheight))
end

function E:PixelClip(num)
	return tonumber(format('%.5f', num))
end

function E:PixelScaleChanged(event, skip)
	E:UIScale(true) -- repopulate variables
	E:UIScale() -- setup the scale

	E:UpdateConfigSize(true) -- reposition config

	if skip or E.global.general.ignoreScalePopup then return end

	if event == 'UISCALE_CHANGE' then
		E:Delay(0.5, E.StaticPopup_Show, E, event)
	else
		E:StaticPopup_Show('UISCALE_CHANGE')
	end
end

function E:Scale(x)
	local mult = E.mult
	return mult * floor(x / mult + 0.5)
end
