local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not LibStub then return end
if not IsAddOnLoaded("CLCProt") or C["skin"].clcprot ~= true or E.myclass ~= "PALADIN" then return end
local clcprot = LibStub("AceAddon-3.0"):GetAddon("clcprot")



function clcprot:CreateButton(name, size, point, parent, pointParent, offsetx, offsety, bfGroup, isChecked)
	local db = self.db.profile
	clcprotFrame:SetScale(1)
	clcprotFrame.SetScale = E.dummy
	
	name = "clcprot" .. name
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
		self.LBF:Group("clcprot", bfGroup):AddButton(button)
	end
		
	button:Hide()
	return button
end

function clcprot:UpdateButtonLayout(button, opt)
	button:Size(opt.size)
	button:ClearAllPoints()
	button:SetPoint(opt.point, clcprotFrame, opt.pointParent, opt.x, opt.y)
	button:SetAlpha(opt.alpha)

	button.stack:ClearAllPoints()
	button.stack:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4, 0)	
end