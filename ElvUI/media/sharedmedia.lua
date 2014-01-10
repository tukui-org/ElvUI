local LSM = LibStub("LibSharedMedia-3.0")
if LSM == nil then return end

local function RegisterFont(name, file)
	LSM:Register("font", name, "Interface\\AddOns\\ElvUI\\media\\fonts\\" .. file)
end

local function RegisterSound(name, file)
	LSM:Register("sound", name, "Interface\\AddOns\\ElvUI\\media\\sounds\\" .. file)
end

local function RegisterStatusbar(name, file)
	LSM:Register("statusbar", name, "Interface\\AddOns\\ElvUI\\media\\textures\\" .. file)
end

local function RegisterBorder(name, file)
	LSM:Register("border", name, "Interface\\AddOns\\ElvUI\\media\\textures\\" .. file)
end

LSM:Register("background","ElvUI Blank", [[Interface\BUTTONS\WHITE8X8]])
LSM:Register("font","ElvUI Font", [[Interface\AddOns\ElvUI\media\fonts\PT_Sans_Narrow.ttf]], LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western)
LSM:Register("font", "ElvUI Pixel", [[Interface\AddOns\ElvUI\media\fonts\Homespun.ttf]],LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western)

RegisterFont("PF Tempesta Seven Bold", "pf_tempesta_seven_bold.ttf")
RegisterFont("ElvUI Alt-Font", "Continuum_Medium.ttf")
RegisterFont("ElvUI Alt-Combat", "DieDieDie.ttf")
RegisterFont("ElvUI Combat", "Action_Man.ttf")
RegisterFont("DorisPP", "DORISBR.TTF")
RegisterFont("AgencyFB Bold", "AgencyFBBold.ttf")

RegisterSound("Awww Crap", "awwcrap.mp3")
RegisterSound("BBQ Ass", "bbqass.mp3")
RegisterSound("Big Yankie Devil", "yankiebangbang.mp3")
RegisterSound("Dumb Shit", "dumbshit.mp3")
RegisterSound("Mama Weekends", "mamaweekends.mp3")
RegisterSound("Runaway Fast", "runfast.mp3")
RegisterSound("Stop Running", "stoprunningslimball.mp3")
RegisterSound("Warning", "warning.mp3")
RegisterSound("Whisper Alert", "whisper.mp3")

RegisterStatusbar("ElvUI Gloss", "normTex.tga")
RegisterStatusbar("ElvUI Norm", "normTex2.tga")
RegisterStatusbar("Minimalist", "Minimalist.tga")
RegisterStatusbar("Melli", "Melli.tga")
RegisterStatusbar("Melli Dark", "MelliDark.tga")
RegisterStatusbar("Melli Dark Rough", "MelliDarkRough.tga")
RegisterStatusbar("Perl", "Perl.tga")

RegisterBorder("ElvUI GlowBorder", "glowTex.tga")