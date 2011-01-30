
local DB, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

-- setup shadow border texture.
local shadows = {
	edgeFile = C["media"].glowTex, 
	edgeSize = 3.7,
	insets = { left = DB.mult, right = DB.mult, top = DB.mult, bottom = DB.mult }
}

-- create shadow frame
function DB.CreateShadow(f)
	if f.shadow then return end
	local shadow = CreateFrame("Frame", nil, f)
	shadow:SetFrameLevel(0)
	shadow:SetFrameStrata(f:GetFrameStrata())
	shadow:SetPoint("TOPLEFT", -DB.Scale(4), DB.Scale(4))
	shadow:SetPoint("BOTTOMRIGHT", DB.Scale(4), DB.Scale(-4))
	shadow:SetBackdrop(shadows)
	shadow:SetBackdropColor(0, 0, 0, 0)
	shadow:SetBackdropBorderColor(0, 0, 0, .75)
	f.shadow = shadow
	return shadow
end

function DB.SetTemplate(f)
	local r, g, b = RAID_CLASS_COLORS[DB.myclass].r, RAID_CLASS_COLORS[DB.myclass].g, RAID_CLASS_COLORS[DB.myclass].b
	f:SetBackdrop({
	  bgFile = C["media"].blank, 
	  edgeFile = C["media"].blank, 
	  tile = false, tileSize = 0, edgeSize = DB.mult, 
	  insets = { left = -DB.mult, right = -DB.mult, top = -DB.mult, bottom = -DB.mult}
	})
	f:SetBackdropColor(unpack(C["media"].backdropcolor))
	if C["general"].classcolortheme == true then
		f:SetBackdropBorderColor(r, g, b)
	else
		f:SetBackdropBorderColor(unpack(C["media"].bordercolor))
	end
end

function DB.SetNormTexTemplate(f)
	local r, g, b = RAID_CLASS_COLORS[DB.myclass].r, RAID_CLASS_COLORS[DB.myclass].g, RAID_CLASS_COLORS[DB.myclass].b
	f:SetBackdrop({
	  bgFile = C["media"].normTex, 
	  edgeFile = C["media"].blank, 
	  tile = false, tileSize = 0, edgeSize = DB.mult, 
	  insets = { left = -DB.mult, right = -DB.mult, top = -DB.mult, bottom = -DB.mult}
	})
	f:SetBackdropColor(unpack(C["media"].backdropcolor))
	if C["general"].classcolortheme == true then
		f:SetBackdropBorderColor(r, g, b)
	else
		f:SetBackdropBorderColor(unpack(C["media"].bordercolor))
	end
end

function DB.SetTransparentTemplate(f)
	local r, g, b = RAID_CLASS_COLORS[DB.myclass].r, RAID_CLASS_COLORS[DB.myclass].g, RAID_CLASS_COLORS[DB.myclass].b
    f:SetFrameLevel(1)
    f:SetFrameStrata("BACKGROUND")
    f:SetBackdrop({
      bgFile = C["media"].blank,
      edgeFile = C["media"].blank,
      tile = false, tileSize = 0, edgeSize = DB.mult,
      insets = { left = -DB.mult, right = -DB.mult, top = -DB.mult, bottom = -DB.mult}
    })
    f:SetBackdropColor(unpack(C["media"].backdropfadecolor))
	if C["general"].classcolortheme == true then
		f:SetBackdropBorderColor(r, g, b)
	else
		f:SetBackdropBorderColor(unpack(C["media"].bordercolor))
	end
end

function DB.CreatePanel(f, w, h, a1, p, a2, x, y)
	local _, class = UnitClass("player")
	local r, g, b = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b
	sh = DB.Scale(h)
	sw = DB.Scale(w)
	f:SetFrameLevel(1)
	f:SetHeight(sh)
	f:SetWidth(sw)
	f:SetFrameStrata("BACKGROUND")
	f:SetPoint(a1, p, a2, DB.Scale(x), DB.Scale(y))
	DB.SetTemplate(f)
end

DB.SetFontString = function(parent, fontName, fontHeight, fontStyle)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(fontName, fontHeight, fontStyle)
	fs:SetJustifyH("LEFT")
	fs:SetShadowColor(0, 0, 0)
	fs:SetShadowOffset(DB.mult, -DB.mult)
	return fs
end

function DB.Kill(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
	end
	object.Show = DB.dummy
	object:Hide()
end