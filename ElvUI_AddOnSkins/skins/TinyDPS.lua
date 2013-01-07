local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "TinyDPSSkin"
local function SkinTinyDps(self)
	local frame = tdpsFrame
	local anchor = tdpsAnchor
	local status = tdpsStatusBar
	local tdps = tdps
	local font = tdpsFont
	local position = tdpsPosition
	local template
	if AS:CheckOption("EmbedTDPS") then template = "Default" else template = "Transparent" end
	frame:SetTemplate(template, true)
	
	if(tdps) then
		tdps.width = Minimap:GetWidth()
		tdps.spacing = 1
		tdps.barHeight = 14
		--font.name = AS:x.datatext_font
		--font.size = 12
		--font.outline = "OUTLINE"
	end

	if(status) then
		tdpsStatusBar:SetBackdrop( {
			bgFile = E["media"].normTex,
			edgeFile = E["media"].blank,
			tile = false,
			tileSize = 0,
			edgeSize = 1,
			insets = {
				left = 0,
				right = 0,
				top = 0,
				bottom = 0
			}
		})
		tdpsStatusBar:SetStatusBarTexture(AS.LSM:Fetch("statusbar",E.private.general.normTex))
	end

	if(AS:CheckOption("EmbedTDPS")) then
		AS:EmbedTDPS()
	end	
end
AS:RegisterSkin(name,SkinTinyDps)