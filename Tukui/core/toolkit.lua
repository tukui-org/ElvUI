local TukuiCF = TukuiCF
local TukuiDB = TukuiDB

-- setup shadow border texture.
local shadows = {
	edgeFile = TukuiCF["media"].glowTex, 
	edgeSize = 3.7,
	insets = { left = TukuiDB.mult, right = TukuiDB.mult, top = TukuiDB.mult, bottom = TukuiDB.mult }
}

-- create shadow frame
function TukuiDB.CreateShadow(f)
	if f.shadow then return end
	local shadow = CreateFrame("Frame", nil, f)
	shadow:SetFrameLevel(0)
	shadow:SetFrameStrata(f:GetFrameStrata())
	shadow:SetPoint("TOPLEFT", -TukuiDB.Scale(4), TukuiDB.Scale(4))
	shadow:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(4), TukuiDB.Scale(-4))
	shadow:SetBackdrop(shadows)
	shadow:SetBackdropColor(0, 0, 0, 0)
	shadow:SetBackdropBorderColor(0, 0, 0, .75)
	f.shadow = shadow
	return shadow
end

function TukuiDB.SetTemplate(f)
	local r, g, b = RAID_CLASS_COLORS[TukuiDB.myclass].r, RAID_CLASS_COLORS[TukuiDB.myclass].g, RAID_CLASS_COLORS[TukuiDB.myclass].b
	f:SetBackdrop({
	  bgFile = TukuiCF["media"].blank, 
	  edgeFile = TukuiCF["media"].blank, 
	  tile = false, tileSize = 0, edgeSize = TukuiDB.mult, 
	  insets = { left = -TukuiDB.mult, right = -TukuiDB.mult, top = -TukuiDB.mult, bottom = -TukuiDB.mult}
	})
	f:SetBackdropColor(unpack(TukuiCF["media"].backdropcolor))
	if TukuiCF["general"].classcolortheme == true then
		f:SetBackdropBorderColor(r, g, b)
	else
		f:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
	end
end

function TukuiDB.SetNormTexTemplate(f)
	local r, g, b = RAID_CLASS_COLORS[TukuiDB.myclass].r, RAID_CLASS_COLORS[TukuiDB.myclass].g, RAID_CLASS_COLORS[TukuiDB.myclass].b
	f:SetBackdrop({
	  bgFile = TukuiCF["media"].normTex, 
	  edgeFile = TukuiCF["media"].blank, 
	  tile = false, tileSize = 0, edgeSize = TukuiDB.mult, 
	  insets = { left = -TukuiDB.mult, right = -TukuiDB.mult, top = -TukuiDB.mult, bottom = -TukuiDB.mult}
	})
	f:SetBackdropColor(unpack(TukuiCF["media"].backdropcolor))
	if TukuiCF["general"].classcolortheme == true then
		f:SetBackdropBorderColor(r, g, b)
	else
		f:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
	end
end

function TukuiDB.SetTransparentTemplate(f)
    f:SetFrameLevel(1)
    f:SetFrameStrata("BACKGROUND")
    f:SetBackdrop({
      bgFile = TukuiCF["media"].blank,
      edgeFile = TukuiCF["media"].blank,
      tile = false, tileSize = 0, edgeSize = TukuiDB.mult,
      insets = { left = -TukuiDB.mult, right = -TukuiDB.mult, top = -TukuiDB.mult, bottom = -TukuiDB.mult}
    })
    f:SetBackdropColor(unpack(TukuiCF["media"].backdropfadecolor))
    f:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
end

function TukuiDB.CreatePanel(f, w, h, a1, p, a2, x, y)
	local _, class = UnitClass("player")
	local r, g, b = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b
	sh = TukuiDB.Scale(h)
	sw = TukuiDB.Scale(w)
	f:SetFrameLevel(1)
	f:SetHeight(sh)
	f:SetWidth(sw)
	f:SetFrameStrata("BACKGROUND")
	f:SetPoint(a1, p, a2, TukuiDB.Scale(x), TukuiDB.Scale(y))
	TukuiDB.SetTemplate(f)
end

TukuiDB.SetFontString = function(parent, fontName, fontHeight, fontStyle)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(fontName, fontHeight, fontStyle)
	fs:SetJustifyH("LEFT")
	fs:SetShadowColor(0, 0, 0)
	fs:SetShadowOffset(TukuiDB.mult, -TukuiDB.mult)
	return fs
end

function TukuiDB.Kill(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
	end
	object.Show = TukuiDB.dummy
	object:Hide()
end