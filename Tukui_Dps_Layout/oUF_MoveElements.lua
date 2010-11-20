if not TukuiCF["unitframes"].enable == true then return end

local Frames = {}
local FramesDefault = {}

do 
	if not DPSElementsCharPos then DPSElementsCharPos = {} end
end

local function CreateFrameOverlay(parent, name)
	if not parent then return end
	
	--Setup Variables
	if not DPSElementsCharPos[name] then DPSElementsCharPos[name] = false end
	
	local p, p2, p3, p4, p5 = parent:GetPoint()
	local f2 = CreateFrame("Frame", nil, UIParent)
	f2:SetPoint(p, p2, p3, p4, p5)
	f2:SetWidth(parent:GetWidth())
	f2:SetHeight(parent:GetHeight())
	
	local f = CreateFrame("Frame", name, UIParent)
	f:SetFrameLevel(parent:GetFrameLevel() + 1)
	f:SetWidth(parent:GetWidth())
	f:SetHeight(parent:GetHeight())
	f:SetFrameStrata("DIALOG")
	f:SetPoint("CENTER", f2, "CENTER")
	f:SetBackdrop({
	  bgFile = TukuiCF["media"].blank, 
	  edgeFile = TukuiCF["media"].blank, 
	  tile = false, tileSize = 0, edgeSize = 2, 
	  insets = { left = 0, right = 0, top = 0, bottom = 0}
	})	
	f:SetBackdropBorderColor(0, 0, 0, 1)
	f:SetBackdropColor(0, 1, 0, 0.75)
	_G[name.."Move"] = false
	tinsert(Frames, name)
		
	f:RegisterForDrag("LeftButton", "RightButton")
	f:SetScript("OnDragStart", function(self) 
		if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
		self:StartMoving() 
	end)
	f:SetScript("OnDragStop", function(self) 
		if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
		self:StopMovingOrSizing() 
		DPSElementsCharPos[name] = true
	end)
		
	local x = tostring(name)
	if not FramesDefault[x] then FramesDefault[x] = { } end
	if not FramesDefault[x]["p"] then FramesDefault[x]["p"] = p end
	if not FramesDefault[x]["p2"] then FramesDefault[x]["p2"] = p2 end
	if not FramesDefault[x]["p3"] then FramesDefault[x]["p3"] = p3 end
	if not FramesDefault[x]["p4"] then FramesDefault[x]["p4"] = p4 end
	if not FramesDefault[x]["p5"] then FramesDefault[x]["p5"] = p5 end

	f:SetAlpha(0)
	f:SetMovable(true)
	f:EnableMouse(false)

	parent:ClearAllPoints()
	parent:SetAllPoints(f)
	
	
	local fs = f:CreateFontString(nil, "OVERLAY")
	fs:SetFont(TukuiCF["media"].font, TukuiCF["auras"].auratextscale, "THINOUTLINE")
	fs:SetJustifyH("CENTER")
	fs:SetShadowColor(0, 0, 0)
	fs:SetShadowOffset(TukuiDB.mult, -TukuiDB.mult)
	fs:SetPoint("CENTER")
	fs:SetText(name)
end

do 
	CreateFrameOverlay(oUF_TukzDPS_player.Castbar, "PlayerCastBar")
	CreateFrameOverlay(oUF_TukzDPS_target.Castbar, "TargetCastBar")
	CreateFrameOverlay(oUF_TukzDPS_focus.Castbar, "FocusCastBar")
	CreateFrameOverlay(oUF_TukzDPS_target.CPoints, "ComboBar")
	CreateFrameOverlay(oUF_TukzDPS_player.Buffs, "PlayerBuffs")
	CreateFrameOverlay(oUF_TukzDPS_target.Buffs, "TargetBuffs")
	CreateFrameOverlay(oUF_TukzDPS_player.Debuffs, "PlayerDebuffs")
	CreateFrameOverlay(oUF_TukzDPS_target.Debuffs, "TargetDebuffs")
	CreateFrameOverlay(oUF_TukzDPS_focus.Debuffs, "FocusDebuffs")
	CreateFrameOverlay(oUF_TukzDPS_targettarget.Debuffs, "TargetTargetDebuffs")
	CreateFrameOverlay(AutoButton, "Auto_Button")
end

StaticPopupDialogs["RELOAD"] = {
	text = SLASH_RELOAD1.."?",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI() end,
	timeout = 0,
	whileDead = 1,
}

local function ShowCBOverlay()
	if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
	for i, Frames in pairs(Frames) do
		if _G[Frames.."Move"] == false then
			_G[Frames.."Move"] = true
			_G[Frames]:SetAlpha(1)
			_G[Frames]:EnableMouse(true)
		else
			if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
			_G[Frames.."Move"] = false
			_G[Frames]:SetAlpha(0)
			_G[Frames]:EnableMouse(false)	
		end
	end
end
SLASH_SHOWCBOVERLAY1 = "/moveele"
SlashCmdList["SHOWCBOVERLAY"] = ShowCBOverlay

local function ResetElements(arg1)
	if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
	if arg1 == "" then
		for i, Frames in pairs(Frames) do
			local name = _G[Frames]:GetName()
			_G[Frames]:ClearAllPoints()
			_G[Frames]:SetPoint(FramesDefault[name]["p"], FramesDefault[name]["p2"], FramesDefault[name]["p3"], FramesDefault[name]["p4"], FramesDefault[name]["p5"])
			DPSElementsCharPos[name] = false
		end
		StaticPopup_Show("RELOAD")
	else
		if not _G[arg1] then return end
		for i, Frames in pairs(Frames) do
			if Frames == arg1 then
				local name = _G[arg1]:GetName()
				_G[arg1]:ClearAllPoints()
				_G[arg1]:SetPoint(FramesDefault[name]["p"], FramesDefault[name]["p2"], FramesDefault[name]["p3"], FramesDefault[name]["p4"], FramesDefault[name]["p5"])	
				DPSElementsCharPos[name] = false	
				break	
			end
		end
		StaticPopup_Show("RELOAD")
	end
end
SLASH_RESETELEMENTS1 = "/resetele"
SlashCmdList["RESETELEMENTS"] = ResetElements
