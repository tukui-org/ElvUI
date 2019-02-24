local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = E.Libs.LSM
local M = "Interface\\AddOns\\ElvUI\\Media\\"

function E:TextureString(texString, dataString)
	return "|T"..texString..(dataString or '').."|t"
end

E.Media = {
	Fonts = {
		['ActionMan'] = M..[[Fonts\ActionMan.ttf]],
		['ContinuumMedium'] = M..[[Fonts\ContinuumMedium.ttf]],
		['DieDieDie'] = M..[[Fonts\DieDieDie.ttf]],
		['Expressway'] = M..[[Fonts\Expressway.ttf]],
		['Homespun'] = M..[[Fonts\Homespun.ttf]],
		['Invisible'] = M..[[Fonts\Invisible.ttf]],
		['PTSansNarrow'] = M..[[Fonts\PTSansNarrow.ttf]]
	},
	Sounds = {
		['AwwCrap'] = M..[[Sounds\AwwCrap.ogg]],
		['BbqAss'] = M..[[Sounds\BbqAss.ogg]],
		['DumbShit'] = M..[[Sounds\DumbShit.ogg]],
		['HarlemShake'] = M..[[Sounds\HarlemShake.ogg]],
		['HelloKitty'] = M..[[Sounds\HelloKitty.ogg]],
		['MamaWeekends'] = M..[[Sounds\MamaWeekends.ogg]],
		['RunFast'] = M..[[Sounds\RunFast.ogg]],
		['StopRunningSlimeBall'] = M..[[Sounds\StopRunningSlimeBall.ogg]],
		['Warning'] = M..[[Sounds\Warning.ogg]],
		['Whisper'] = M..[[Sounds\Whisper.ogg]],
		['YankieBangBang'] = M..[[Sounds\YankieBangBang.ogg]]
	},
	ChatEmojis = {
		['Angry'] = M..[[Textures\ChatEmojis\Angry.tga]],
		['Blush'] = M..[[Textures\ChatEmojis\Blush.tga]],
		['BrokenHeart'] = M..[[Textures\ChatEmojis\BrokenHeart.tga]],
		['CallMe'] = M..[[Textures\ChatEmojis\CallMe.tga]],
		['Cry'] = M..[[Textures\ChatEmojis\Cry.tga]],
		['Facepalm'] = M..[[Textures\ChatEmojis\Facepalm.tga]],
		['Grin'] = M..[[Textures\ChatEmojis\Grin.tga]],
		['Heart'] = M..[[Textures\ChatEmojis\Heart.tga]],
		['HeartEyes'] = M..[[Textures\ChatEmojis\HeartEyes.tga]],
		['Joy'] = M..[[Textures\ChatEmojis\Joy.tga]],
		['Kappa'] = M..[[Textures\ChatEmojis\Kappa.tga]],
		['Meaw'] = M..[[Textures\ChatEmojis\Meaw.tga]],
		['MiddleFinger'] = M..[[Textures\ChatEmojis\MiddleFinger.tga]],
		['Murloc'] = M..[[Textures\ChatEmojis\Murloc.tga]],
		['OkHand'] = M..[[Textures\ChatEmojis\OkHand.tga]],
		['OpenMouth'] = M..[[Textures\ChatEmojis\OpenMouth.tga]],
		['Poop'] = M..[[Textures\ChatEmojis\Poop.tga]],
		['Rage'] = M..[[Textures\ChatEmojis\Rage.tga]],
		['SadKitty'] = M..[[Textures\ChatEmojis\SadKitty.tga]],
		['Scream'] = M..[[Textures\ChatEmojis\Scream.tga]],
		['ScreamCat'] = M..[[Textures\ChatEmojis\ScreamCat.tga]],
		['SemiColon'] = M..[[Textures\ChatEmojis\SemiColon.tga]],
		['SlightFrown'] = M..[[Textures\ChatEmojis\SlightFrown.tga]],
		['Smile'] = M..[[Textures\ChatEmojis\Smile.tga]],
		['Smirk'] = M..[[Textures\ChatEmojis\Smirk.tga]],
		['Sob'] = M..[[Textures\ChatEmojis\Sob.tga]],
		['StuckOutTongue'] = M..[[Textures\ChatEmojis\StuckOutTongue.tga]],
		['StuckOutTongueClosedEyes'] = M..[[Textures\ChatEmojis\StuckOutTongueClosedEyes.tga]],
		['Sunglasses'] = M..[[Textures\ChatEmojis\Sunglasses.tga]],
		['Thinking'] = M..[[Textures\ChatEmojis\Thinking.tga]],
		['ThumbsUp'] = M..[[Textures\ChatEmojis\ThumbsUp.tga]],
		['Wink'] = M..[[Textures\ChatEmojis\Wink.tga]],
		['ZZZ'] = M..[[Textures\ChatEmojis\ZZZ.tga]]
	},
	ChatLogos = {
		['Bathrobe'] = M..[[Textures\ChatLogos\Bathrobe.tga]],
		['ElvBlue'] = M..[[Textures\ChatLogos\ElvBlue.tga]],
		['ElvGreen'] = M..[[Textures\ChatLogos\ElvGreen.tga]],
		['ElvOrange'] = M..[[Textures\ChatLogos\ElvOrange.tga]],
		['ElvPink'] = M..[[Textures\ChatLogos\ElvPink.tga]],
		['ElvPurple'] = M..[[Textures\ChatLogos\ElvPurple.tga]],
		['ElvRainbow'] = M..[[Textures\ChatLogos\ElvRainbow.tga]],
		['ElvRed'] = M..[[Textures\ChatLogos\ElvRed.tga]],
		['HelloKitty'] = M..[[Textures\ChatLogos\HelloKitty.tga]],
		['Illuminati'] = M..[[Textures\ChatLogos\Illuminati.tga]],
		['MrHankey'] = M..[[Textures\ChatLogos\MrHankey.tga]],
		['TyroneBiggums'] = M..[[Textures\ChatLogos\TyroneBiggums.tga]]
	},
	Textures = {
		['Arrow'] = M..[[Textures\Arrow.tga]],
		['ArrowRight'] = M..[[Textures\ArrowRight.tga]],
		['ArrowUp'] = M..[[Textures\ArrowUp.tga]],
		['BagNewItemGlow'] = M..[[Textures\BagNewItemGlow.tga]],
		['BagQuestIcon'] = M..[[Textures\BagQuestIcon.tga]],
		['BagUpgradeIcon'] = M..[[Textures\BagUpgradeIcon.tga]],
		['BubbleTex'] = M..[[Textures\BubbleTex.tga]],
		['ChatEmojis'] = M..[[Textures\ChatEmojis]],
		['ChatLogos'] = M..[[Textures\ChatLogos]],
		['Close'] = M..[[Textures\Close.tga]],
		['Combat'] = M..[[Textures\Combat.tga]],
		['Copy'] = M..[[Textures\Copy.tga]],
		['Cross'] = M..[[Textures\Cross.tga]],
		['DPS'] = M..[[Textures\DPS.tga]],
		['GlowTex'] = M..[[Textures\GlowTex.tga]],
		['Healer'] = M..[[Textures\Healer.tga]],
		['HelloKitty'] = M..[[Textures\HelloKitty.tga]],
		['HelloKittyChat'] = M..[[Textures\HelloKittyChat.tga]],
		['Highlight'] = M..[[Textures\Highlight.tga]],
		['Leader'] = M..[[Textures\Leader.tga]],
		['Logo'] = M..[[Textures\Logo.tga]],
		['Mail'] = M..[[Textures\Mail.tga]],
		['Melli'] = M..[[Textures\Melli.tga]],
		['Minimalist'] = M..[[Textures\Minimalist.tga]],
		['Minus'] = M..[[Textures\Minus.tga]],
		['MinusButton'] = M..[[Textures\MinusButton.tga]],
		['NormTex'] = M..[[Textures\NormTex.tga]],
		['NormTex2'] = M..[[Textures\NormTex2.tga]],
		['Pause'] = M..[[Textures\Pause.tga]],
		['PhaseIcons'] = M..[[Textures\PhaseIcons.tga]],
		['Play'] = M..[[Textures\Play.tga]],
		['Plus'] = M..[[Textures\Plus.tga]],
		['PlusButton'] = M..[[Textures\PlusButton.tga]],
		['Reset'] = M..[[Textures\Reset.tga]],
		['Resting'] = M..[[Textures\Resting.tga]],
		['Resting1'] = M..[[Textures\Resting1.tga]],
		['RoleIcons'] = M..[[Textures\RoleIcons.tga]],
		['SkullIcon'] = M..[[Textures\SkullIcon.tga]],
		['Smooth'] = M..[[Textures\Smooth.tga]],
		['Spark'] = M..[[Textures\Spark.tga]],
		['Tank'] = M..[[Textures\Tank.tga]],
		['TukuiLogo'] = M..[[Textures\TukuiLogo.tga]],
		['VehicleExit'] = M..[[Textures\VehicleExit.tga]]
	}
}

LSM:Register("border", "ElvUI GlowBorder", E.Media.Textures.GlowTex)
LSM:Register("font", "Continuum Medium", E.Media.Fonts.ContinuumMedium)
LSM:Register("font","Die Die Die!", E.Media.Fonts.DieDieDie)
LSM:Register("font","Action Man", E.Media.Fonts.ActionMan)
LSM:Register("font", "Expressway", E.Media.Fonts.Expressway, LSM.LOCALE_BIT_ruRU+LSM.LOCALE_BIT_western)
LSM:Register("font","PT Sans Narrow", E.Media.Fonts.PTSansNarrow, LSM.LOCALE_BIT_ruRU+LSM.LOCALE_BIT_western)
LSM:Register("font", "Homespun", E.Media.Fonts.Homespun,LSM.LOCALE_BIT_ruRU+LSM.LOCALE_BIT_western)
LSM:Register("sound", "Awww Crap", E.Media.Sounds.AwwCrap)
LSM:Register("sound", "BBQ Ass", E.Media.Sounds.BbqAss)
LSM:Register("sound", "Big Yankie Devil", E.Media.Sounds.YankieBangBang)
LSM:Register("sound", "Dumb Shit", E.Media.Sounds.DumbShit)
LSM:Register("sound", "Mama Weekends", E.Media.Sounds.MamaWeekends)
LSM:Register("sound", "Runaway Fast", E.Media.Sounds.RunFast)
LSM:Register("sound", "Stop Running", E.Media.Sounds.StopRunningSlimeBall)
LSM:Register("sound","Warning", E.Media.Sounds.Warning)
LSM:Register("sound","Whisper Alert", E.Media.Sounds.Whisper)
LSM:Register("statusbar","Melli", E.Media.Textures.Melli)
LSM:Register("statusbar","ElvUI Gloss", E.Media.Textures.NormTex)
LSM:Register("statusbar","ElvUI Norm", E.Media.Textures.NormTex2)
LSM:Register("statusbar","Minimalist", E.Media.Textures.Minimalist)
LSM:Register("statusbar","ElvUI Blank", [[Interface\BUTTONS\WHITE8X8]])
LSM:Register("background","ElvUI Blank", [[Interface\BUTTONS\WHITE8X8]])
