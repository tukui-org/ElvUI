local ElvCF = ElvCF
local ElvDB = ElvDB

-- setup shadow border texture.
local shadows = {
	edgeFile = ElvCF["media"].glowTex, 
	edgeSize = 3.7,
	insets = { left = ElvDB.mult, right = ElvDB.mult, top = ElvDB.mult, bottom = ElvDB.mult }
}

-- create shadow frame
function ElvDB.CreateShadow(f)
	if f.shadow then return end
	local shadow = CreateFrame("Frame", nil, f)
	shadow:SetFrameLevel(0)
	shadow:SetFrameStrata(f:GetFrameStrata())
	shadow:SetPoint("TOPLEFT", -ElvDB.Scale(4), ElvDB.Scale(4))
	shadow:SetPoint("BOTTOMRIGHT", ElvDB.Scale(4), ElvDB.Scale(-4))
	shadow:SetBackdrop(shadows)
	shadow:SetBackdropColor(0, 0, 0, 0)
	shadow:SetBackdropBorderColor(0, 0, 0, .75)
	f.shadow = shadow
	return shadow
end

function ElvDB.SetTemplate(f)
	local r, g, b = RAID_CLASS_COLORS[ElvDB.myclass].r, RAID_CLASS_COLORS[ElvDB.myclass].g, RAID_CLASS_COLORS[ElvDB.myclass].b
	f:SetBackdrop({
	  bgFile = ElvCF["media"].blank, 
	  edgeFile = ElvCF["media"].blank, 
	  tile = false, tileSize = 0, edgeSize = ElvDB.mult, 
	  insets = { left = -ElvDB.mult, right = -ElvDB.mult, top = -ElvDB.mult, bottom = -ElvDB.mult}
	})
	f:SetBackdropColor(unpack(ElvCF["media"].backdropcolor))
	if ElvCF["general"].classcolortheme == true then
		f:SetBackdropBorderColor(r, g, b)
	else
		f:SetBackdropBorderColor(unpack(ElvCF["media"].bordercolor))
	end
end

function ElvDB.SetNormTexTemplate(f)
	local r, g, b = RAID_CLASS_COLORS[ElvDB.myclass].r, RAID_CLASS_COLORS[ElvDB.myclass].g, RAID_CLASS_COLORS[ElvDB.myclass].b
	f:SetBackdrop({
	  bgFile = ElvCF["media"].normTex, 
	  edgeFile = ElvCF["media"].blank, 
	  tile = false, tileSize = 0, edgeSize = ElvDB.mult, 
	  insets = { left = -ElvDB.mult, right = -ElvDB.mult, top = -ElvDB.mult, bottom = -ElvDB.mult}
	})
	f:SetBackdropColor(unpack(ElvCF["media"].backdropcolor))
	if ElvCF["general"].classcolortheme == true then
		f:SetBackdropBorderColor(r, g, b)
	else
		f:SetBackdropBorderColor(unpack(ElvCF["media"].bordercolor))
	end
end

function ElvDB.SetTransparentTemplate(f)
	local r, g, b = RAID_CLASS_COLORS[ElvDB.myclass].r, RAID_CLASS_COLORS[ElvDB.myclass].g, RAID_CLASS_COLORS[ElvDB.myclass].b
    f:SetFrameLevel(1)
    f:SetFrameStrata("BACKGROUND")
    f:SetBackdrop({
      bgFile = ElvCF["media"].blank,
      edgeFile = ElvCF["media"].blank,
      tile = false, tileSize = 0, edgeSize = ElvDB.mult,
      insets = { left = -ElvDB.mult, right = -ElvDB.mult, top = -ElvDB.mult, bottom = -ElvDB.mult}
    })
    f:SetBackdropColor(unpack(ElvCF["media"].backdropfadecolor))
	if ElvCF["general"].classcolortheme == true then
		f:SetBackdropBorderColor(r, g, b)
	else
		f:SetBackdropBorderColor(unpack(ElvCF["media"].bordercolor))
	end
end

function ElvDB.CreatePanel(f, w, h, a1, p, a2, x, y)
	local _, class = UnitClass("player")
	local r, g, b = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b
	sh = ElvDB.Scale(h)
	sw = ElvDB.Scale(w)
	f:SetFrameLevel(1)
	f:SetHeight(sh)
	f:SetWidth(sw)
	f:SetFrameStrata("BACKGROUND")
	f:SetPoint(a1, p, a2, ElvDB.Scale(x), ElvDB.Scale(y))
	ElvDB.SetTemplate(f)
end

ElvDB.SetFontString = function(parent, fontName, fontHeight, fontStyle)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(fontName, fontHeight, fontStyle)
	fs:SetJustifyH("LEFT")
	fs:SetShadowColor(0, 0, 0)
	fs:SetShadowOffset(ElvDB.mult, -ElvDB.mult)
	return fs
end

function ElvDB.Kill(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
	end
	object.Show = ElvDB.dummy
	object:Hide()
end