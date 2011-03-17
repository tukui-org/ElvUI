local E, C, L, DB = unpack(ElvUI) -- Import Functions/Constants, Config, Locales


if not C["unitframes"].enable == true then return end

E.CreatedMoveEleFrames = {}
local FramesDefault = {}

local function CreateFrameOverlay(parent, name)
	if not parent then return end
	
	--Old, cleanup in saved variables aisle 3
	DPSElementsCharPos = nil
	HealElementsCharPos = nil
	
	--Setup Variables
	if not ElementsPos then ElementsPos = {} end
	if not ElementsPos[name] or type(ElementsPos[name]) ~= "table" then ElementsPos[name] = {} end
	if not ElementsPos[name]["moved"] then ElementsPos[name]["moved"] = false end
	
	local p, p2, p3, p4, p5 = parent:GetPoint()
	
	if ElementsPos[name]["moved"] ~= true then
		ElementsPos[name]["p"] = nil
		ElementsPos[name]["p2"] = nil
		ElementsPos[name]["p3"] = nil
		ElementsPos[name]["p4"] = nil
	end
	
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
	  bgFile = C["media"].blank, 
	  edgeFile = C["media"].blank, 
	  tile = false, tileSize = 0, edgeSize = 2, 
	  insets = { left = 0, right = 0, top = 0, bottom = 0}
	})	
	f:SetBackdropBorderColor(0, 0, 0, 1)
	f:SetBackdropColor(0, 1, 0, 0.75)
	_G[name.."Move"] = false
	E.CreatedMoveEleFrames[name] = true
	
	f:RegisterForDrag("LeftButton", "RightButton")
	f:SetScript("OnDragStart", function(self) 
		if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
		self:StartMoving() 
	end)
	
	f:SetScript("OnDragStop", function(self) 
		if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
		self:StopMovingOrSizing() 
		ElementsPos[name]["moved"] = true
		local p, _, p2, p3, p4 = self:GetPoint()
		ElementsPos[name]["p"] = p
		ElementsPos[name]["p2"] = p2
		ElementsPos[name]["p3"] = p3
		ElementsPos[name]["p4"] = p4
	end)
		
	local x = tostring(name)
	if not FramesDefault[x] then FramesDefault[x] = {} end
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
	
	if ElementsPos[name]["moved"] == true then
		f2:ClearAllPoints()
		f2:SetPoint(ElementsPos[name]["p"], UIParent, ElementsPos[name]["p3"], ElementsPos[name]["p4"], ElementsPos[name]["p5"])
	end
	
	
	local fs = f:CreateFontString(nil, "OVERLAY")
	fs:SetFont(C["media"].font, C["unitframes"].auratextscale, "THINOUTLINE")
	fs:SetJustifyH("CENTER")
	fs:SetShadowColor(0, 0, 0, 0.4)
	fs:SetShadowOffset(E.mult, -E.mult)
	fs:SetPoint("CENTER")
	fs:SetText(name)
end

function E.LoadMoveElements(layout)
	CreateFrameOverlay(_G["Elv"..layout.."_player"].Castbar, layout.."PlayerCastBar")
	CreateFrameOverlay(_G["Elv"..layout.."_target"].Castbar, layout.."TargetCastBar")
	CreateFrameOverlay(_G["Elv"..layout.."_focus"].Castbar, layout.."FocusCastBar")
	CreateFrameOverlay(_G["Elv"..layout.."_target"].CPoints, layout.."ComboBar")
	CreateFrameOverlay(_G["Elv"..layout.."_player"].Buffs, layout.."PlayerBuffs")
	CreateFrameOverlay(_G["Elv"..layout.."_target"].Buffs, layout.."TargetBuffs")
	CreateFrameOverlay(_G["Elv"..layout.."_player"].Debuffs, layout.."PlayerDebuffs")
	CreateFrameOverlay(_G["Elv"..layout.."_target"].Debuffs, layout.."TargetDebuffs")
	CreateFrameOverlay(_G["Elv"..layout.."_focus"].Debuffs, layout.."FocusDebuffs")
	CreateFrameOverlay(_G["Elv"..layout.."_targettarget"].Debuffs, layout.."TargetTargetDebuffs")	
end

local function ShowCBOverlay()
	if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
	local tab = E.CreatedMoveEleFrames
	for frame, _ in pairs(tab) do
		if _G[frame.."Move"] == false then
			_G[frame.."Move"] = true
			_G[frame]:SetAlpha(1)
			_G[frame]:EnableMouse(true)
		else
			if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
			_G[frame.."Move"] = false
			_G[frame]:SetAlpha(0)
			_G[frame]:EnableMouse(false)
			StaticPopup_Show("RELOAD_UI")
		end
	end
end
SLASH_SHOWCBOVERLAY1 = "/moveele"
SlashCmdList["SHOWCBOVERLAY"] = ShowCBOverlay

local function ResetElements(arg1)
	if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
	if arg1 == "" then
		local tab = E.CreatedMoveEleFrames
		for frame, _ in pairs(tab) do
			local name = _G[frame]:GetName()
			_G[frame]:ClearAllPoints()
			_G[frame]:SetPoint(FramesDefault[name]["p"], FramesDefault[name]["p2"], FramesDefault[name]["p3"], FramesDefault[name]["p4"], FramesDefault[name]["p5"])
			ElementsPos[name]["moved"] = false
			ElementsPos[name]["p"] = nil
			ElementsPos[name]["p2"] = nil
			ElementsPos[name]["p3"] = nil
			ElementsPos[name]["p4"] = nil
		end
		StaticPopup_Show("RELOAD_UI")
	else
		if not _G[arg1] then return end
		local tab = E.CreatedMoveEleFrames		
		for i, frame in pairs(tab) do
			if frame == arg1 then
				local name = _G[arg1]:GetName()
				_G[arg1]:ClearAllPoints()
				_G[arg1]:SetPoint(FramesDefault[name]["p"], FramesDefault[name]["p2"], FramesDefault[name]["p3"], FramesDefault[name]["p4"], FramesDefault[name]["p5"])	
				ElementsPos[name]["moved"] = false	
				ElementsPos[name]["p"] = nil
				ElementsPos[name]["p2"] = nil
				ElementsPos[name]["p3"] = nil
				ElementsPos[name]["p4"] = nil		
				break	
			end
		end
		StaticPopup_Show("RELOAD_UI")
	end
end
SLASH_RESETELEMENTS1 = "/resetele"
SlashCmdList["RESETELEMENTS"] = ResetElements
