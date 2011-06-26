local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not LibStub then return end
if not IsAddOnLoaded("CLCRet") or C["skin"].clcret ~= true or E.myclass ~= "PALADIN" then return end
local clcret = LibStub("AceAddon-3.0"):GetAddon("clcret")



function clcret:CreateButton(name, size, point, parent, pointParent, offsetx, offsety, bfGroup, isChecked)
	local db = self.db.profile
	clcretFrame:SetScale(1)
	clcretFrame.SetScale = E.dummy
	
	name = "clcret" .. name
	local button
	if isChecked then
		button = CreateFrame("CheckButton", name , parent)
		button:SetTemplate("Default")
		button:StyleButton(true)
	else
		button = CreateFrame("Button", name , parent)
		button:SetTemplate("Default")
	end
	button:EnableMouse(false)
	
	button:Size(size)
	
	button.texture = button:CreateTexture("$parentIcon", "OVERLAY")
	button.texture:Point("TOPLEFT", 2, -2)
	button.texture:Point("BOTTOMRIGHT", -2, 2)
	button.texture:SetTexture(BGTEX)
	button.texture:SetTexCoord(.08, .92, .08, .92)
	button.texture.SetTexCoord = E.dummy
	
	button.border = button:CreateTexture(nil, "BORDER")
	button.border:Kill()
	
	button.cooldown = CreateFrame("Cooldown", "$parentCooldown", button)
	button.cooldown:Point("TOPLEFT", 2, -2)
	button.cooldown:Point("BOTTOMRIGHT", -2, 2)
	
	button.stack = button:CreateFontString("$parentCount", "OVERLAY", "TextStatusBarText")
	
	local fontFace, _, fontFlags = button.stack:GetFont()
	button.stack:SetFont(fontFace, 30, fontFlags)
	button.stack:SetJustifyH("RIGHT")
	button.stack:ClearAllPoints()
	button.stack:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4, 0)
	
	button.defaultSize = button:GetWidth()
	
	button.SetScale = E.dummy
	button:ClearAllPoints()
	button:SetPoint(point, parent, pointParent, offsetx, offsety)
	
	if self.LBF then
		self.LBF:Group("clcret", bfGroup):AddButton(button)
	end
		
	button:Hide()
	return button
end

function clcret:UpdateButtonLayout(button, opt)
	button:Size(opt.size)
	button:ClearAllPoints()
	button:SetPoint(opt.point, clcretFrame, opt.pointParent, opt.x, opt.y)
	button:SetAlpha(opt.alpha)

	button.stack:ClearAllPoints()
	button.stack:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4, 0)	
end