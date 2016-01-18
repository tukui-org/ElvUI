local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local format = format

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.mirrorTimers ~= true then return end
	--Mirror Timers (Underwater Breath etc.), credit to Azilroka
	
	--Add .maxvalue to MirrorTimers for easy access
	local function MirrorTimer_Show(timer, value, maxvalue, scale, paused, label)
		-- Pick a free dialog to use
		local dialog = nil;
		if ( not dialog ) then
			-- Find an open dialog of the requested type
			for index = 1, MIRRORTIMER_NUMTIMERS, 1 do
				local frame = _G["MirrorTimer"..index];
				if ( frame:IsShown() and (frame.timer == timer) ) then
					dialog = frame;
					break;
				end
			end
		end
		if ( not dialog ) then
			-- Find a free dialog
			for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
				local frame = _G["MirrorTimer"..index];
				if ( not frame:IsShown() ) then
					dialog = frame;
					break;
				end
			end
		end
		if ( not dialog ) then
			return nil;
		end

		dialog.maxvalue = (maxvalue / 1000)
	end
	hooksecurefunc("MirrorTimer_Show", MirrorTimer_Show)

	local function MirrorTimer_OnUpdate(frame, elapsed)
		if ( frame.paused ) then
			return;
		end
		
		if frame.timeSinceUpdate >= 0.3 then
			local curMin = frame.value/60
			local curSec = frame.value%60
			local maxMin = frame.maxvalue/60
			local maxSec = frame.maxvalue%60

			frame.CurrentValue:SetText(format("%d:%02d", curMin, curSec))
			frame.MaxValue:SetText(format("%d:%02d", maxMin, maxSec))

			frame.timeSinceUpdate = 0
		else
			frame.timeSinceUpdate = frame.timeSinceUpdate + elapsed
		end
	end

	for i = 1, MIRRORTIMER_NUMTIMERS do
		local mirrorTimer = _G['MirrorTimer'..i]
		local statusBar = _G['MirrorTimer'..i..'StatusBar']
		local text = _G['MirrorTimer'..i.."Text"]

		mirrorTimer:StripTextures()
		mirrorTimer:Size(222, 18)
		statusBar:SetStatusBarTexture(E["media"].normTex)
		statusBar:CreateBackdrop()
		statusBar:Size(222, 18)
		text:ClearAllPoints()
		text:SetPoint('CENTER', statusBar, 'CENTER', 0, 0)

		local CurrentValue = mirrorTimer:CreateFontString(nil, 'OVERLAY')
		CurrentValue:FontTemplate()
		CurrentValue:Point("LEFT", statusBar, "LEFT", 4, 0)
		mirrorTimer.CurrentValue = CurrentValue
		
		local MaxValue = mirrorTimer:CreateFontString(nil, 'OVERLAY')
		MaxValue:FontTemplate()
		MaxValue:Point("RIGHT", statusBar, "RIGHT", -4, 0)
		mirrorTimer.MaxValue = MaxValue

		mirrorTimer.timeSinceUpdate = 0.3 --Make sure timer value updates right away on first show
		mirrorTimer:HookScript("OnUpdate", MirrorTimer_OnUpdate)

		E:CreateMover(mirrorTimer, "MirrorTimer"..i.."Mover", L["MirrorTimer"]..i, nil, nil, nil, "ALL,SOLO")
	end
end

S:RegisterSkin('ElvUI', LoadSkin)