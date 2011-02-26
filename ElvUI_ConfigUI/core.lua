-- This will filter everythin NON user config data out of DB

local myPlayerRealm = GetCVar("realmName");
local myPlayerName  = UnitName("player");

ALLOWED_GROUPS = {
	["general"]=1,
	["media"]=1,
	["unitframes"]=1,
	["arena"]=1,
	["actionbar"]=1,
	["nameplate"]=1,
	["loot"]=1,
	["cooldown"]=1,
	["datatext"]=1,
	["chat"]=1,
	["tooltip"]=1,
	["buffreminder"]=1,
	["others"]=1,
	["classtimer"]=1,
	["skin"]=1,
	["castbar"]=1,
	["raidframes"]=1,
	["auras"]=1,
	["framesizes"]=1,
	["debug"]=1,
}

--List of "Options" that we do not want to show in the config
local Filter = {
	["font"]=1,
	["uffont"]=1,
	["dmgfont"]=1,
	["normTex"]=1,
	["glowTex"]=1,
	["blank"]=1,
	["raidicons"]=1,
	["whisper"]=1,
	["warning"]=1,
	["normTex2"]=1,
}

local function Local(o)
	local E, C, L = unpack(ElvUI) -- Import Functions/Constants, Config, Locales
	
	-- general
	if o == "ElvuiConfigUIgeneral" then o = ElvuiL.option_general end
	if o == "ElvuiConfigUIgeneralautoscale" then o = ElvuiL.option_general_uiscale end
	if o == "ElvuiConfigUIgeneralresolutionoverride" then o = ElvuiL.option_general_override end
	if o == "ElvuiConfigUIgeneralmultisampleprotect" then o = ElvuiL.option_general_multisample end
	if o == "ElvuiConfigUIgeneraluiscale" then o = ElvuiL.option_general_customuiscale end
	if o == "ElvuiConfigUIgeneralclasscolortheme" then o = ElvuiL.option_general_classtheme end
	if o == "ElvuiConfigUIgeneralautocustomlagtolerance" then o = ElvuiL.option_general_autocustomlagtolerance end
	if o == "ElvuiConfigUIgeneralfontscale" then o = ElvuiL.option_general_fontscale end 
	if o == "ElvuiConfigUIgenerallayoutoverride" then o = ElvuiL.option_general_layoutoverride end
	
	--Media
	if o =="ElvuiConfigUImedia" then o = ElvuiL.option_media end
	if o =="ElvuiConfigUImediafont" then o = ElvuiL.option_media_font end
	if o =="ElvuiConfigUImediauffont" then o = ElvuiL.option_media_uffont end
	if o =="ElvuiConfigUImediadmgfont" then o = ElvuiL.option_media_dmgfont end
	if o =="ElvuiConfigUImedianormTex" then o = ElvuiL.option_media_normTex end
	if o =="ElvuiConfigUImediaglowTex" then o = ElvuiL.option_media_glowTex end
	if o =="ElvuiConfigUImediabubbleTex" then o = ElvuiL.option_media_bubbleTex end
	if o =="ElvuiConfigUImediablank" then o = ElvuiL.option_media_blank end
	if o =="ElvuiConfigUImediabordercolor" then o = ElvuiL.option_media_bordercolor end
	if o =="ElvuiConfigUImediaaltbordercolor" then o = ElvuiL.option_media_altbordercolor end
	if o =="ElvuiConfigUImediabackdropcolor" then o = ElvuiL.option_media_backdropcolor end
	if o =="ElvuiConfigUImediabackdropfadecolor" then o = ElvuiL.option_media_backdropfadecolor end
	if o =="ElvuiConfigUImediabuttonhover" then o = ElvuiL.option_media_buttonhover end
	if o =="ElvuiConfigUImediavaluecolor" then o = ElvuiL.option_media_valuecolor end
	if o =="ElvuiConfigUImediaraidicons" then o = ElvuiL.option_media_raidicons end
	if o =="ElvuiConfigUImediawhisper" then o = ElvuiL.option_media_whisper end
	if o =="ElvuiConfigUImediawarning" then o = ElvuiL.option_media_warning end
	if o =="ElvuiConfigUImediaglossyTexture" then o = ElvuiL.option_media_glossy end
	
	--Skin
	if o =="ElvuiConfigUIskin" then o = ElvuiL.option_skin end
	if o =="ElvuiConfigUIskinkle" then o = ElvuiL.option_skin_kle end
	if o =="ElvuiConfigUIskinomen" then o = ElvuiL.option_skin_omen end
	if o =="ElvuiConfigUIskinrecount" then o = ElvuiL.option_skin_recount end
	if o =="ElvuiConfigUIskinskada" then o = ElvuiL.option_skin_skada end
	if o == "ElvuiConfigUIskinhookkleright" then o = ElvuiL.option_hookkleright end
	if o == "ElvuiConfigUIskinembedright" then o = ElvuiL.option_general_embedright end
	
	--Classtimers
	if o == "ElvuiConfigUIclasstimer" then o = ElvuiL.option_classtimer end
	if o == "ElvuiConfigUIclasstimerenable" then o = ElvuiL.option_classtimer_enable end
	if o == "ElvuiConfigUIclasstimerbar_height" then o = ElvuiL.option_classtimer_bar_height end
	if o == "ElvuiConfigUIclasstimerbar_spacing" then o = ElvuiL.option_classtimer_bar_spacing end
	if o == "ElvuiConfigUIclasstimericon_position" then o = ElvuiL.option_classtimer_icon_position end
	if o == "ElvuiConfigUIclasstimerlayout" then o = ElvuiL.option_classtimer_layout end
	if o == "ElvuiConfigUIclasstimershowspark" then o = ElvuiL.option_classtimer_showspark end
	if o == "ElvuiConfigUIclasstimercast_suparator" then o = ElvuiL.option_classtimer_cast_suparator end
	if o == "ElvuiConfigUIclasstimerclasscolor" then o = ElvuiL.option_classtimer_classcolor end
	if o == "ElvuiConfigUIclasstimerdebuffcolor" then o = ElvuiL.option_classtimer_debuffcolor end
	if o == "ElvuiConfigUIclasstimerbuffcolor" then o = ElvuiL.option_classtimer_buffcolor end
	if o == "ElvuiConfigUIclasstimerproccolor" then o = ElvuiL.option_classtimer_proccolor end
	
	-- nameplate
	if o == "ElvuiConfigUInameplate" then o = ElvuiL.option_nameplates end
	if o == "ElvuiConfigUInameplateenable" then o = ElvuiL.option_nameplates_enable end
	if o == "ElvuiConfigUInameplateshowhealth" then o = ElvuiL.option_nameplates_showhealth end
	if o == "ElvuiConfigUInameplateenhancethreat" then o = ElvuiL.option_nameplates_enhancethreat end
	if o == "ElvuiConfigUInameplateoverlap" then o = UNIT_NAMEPLATES_ALLOW_OVERLAP end
	if o == "ElvuiConfigUInameplatecombat" then o = ElvuiL.option_nameplates_combat end
	if o == "ElvuiConfigUInameplategoodcolor" then o = ElvuiL.option_nameplates_goodcolor end
	if o == "ElvuiConfigUInameplatebadcolor" then o = ElvuiL.option_nameplates_badcolor end
	if o == "ElvuiConfigUInameplatetransitioncolor" then o = ElvuiL.option_nameplates_transitioncolor end
	if o == "ElvuiConfigUInameplatetrackauras" then o = ElvuiL.option_nameplates_trackauras end
	if o == "ElvuiConfigUInameplatetrackccauras" then o = ElvuiL.option_nameplates_trackccauras end
	
	-- datatext
	if o == "ElvuiConfigUIdatatext" then o = ElvuiL.option_datatext end
	if o == "ElvuiConfigUIdatatexttime24" then o = ElvuiL.option_datatext_24h end
	if o == "ElvuiConfigUIdatatextlocaltime" then o = ElvuiL.option_datatext_localtime end
	if o == "ElvuiConfigUIdatatextbattleground" then o = ElvuiL.option_datatext_bg end
	if o == "ElvuiConfigUIdatatextguild" then o = ElvuiL.option_datatext_guild end
	if o == "ElvuiConfigUIdatatextmem" then o = ElvuiL.option_datatext_mem end
	if o == "ElvuiConfigUIdatatextfontsize" then o = ElvuiL.option_datatext_fontsize end
	if o == "ElvuiConfigUIdatatextsystem" then o = ElvuiL.option_datatext_system end
	if o == "ElvuiConfigUIdatatextfriends" then o = ElvuiL.option_datatext_friend end
	if o == "ElvuiConfigUIdatatextwowtime" then o = ElvuiL.option_datatext_time end
	if o == "ElvuiConfigUIdatatextgold" then o = ElvuiL.option_datatext_gold end
	if o == "ElvuiConfigUIdatatextdur" then o = ElvuiL.option_datatext_dur end	
	if o == "ElvuiConfigUIdatatextstat1" then o = ElvuiL.option_datatext_stat1 end
	if o == "ElvuiConfigUIdatatextstat2" then o = ElvuiL.option_datatext_stat2 end
	if o == "ElvuiConfigUIdatatextbags" then o = ElvuiL.option_datatext_bags end
	if o == "ElvuiConfigUIdatatexthps_text" then o = ElvuiL.option_datatext_hps end
	if o == "ElvuiConfigUIdatatextdps_text" then o = ElvuiL.option_datatext_dps end
	if o == "ElvuiConfigUIdatatexthaste" then o = SPELL_HASTE_ABBR end
	if o == "ElvuiConfigUIdatatextcurrency" then o = CURRENCY end
	
	--auras
	if o == "ElvuiConfigUIauras" then o = ElvuiL.option_auras end
	if o == "ElvuiConfigUIaurasminimapauras" then o = ElvuiL.option_auras_minimapauras end
	if o == "ElvuiConfigUIaurasarenadebuffs" then o = ElvuiL.option_auras_arenadebuffs end
	if o == "ElvuiConfigUIaurasauratimer" then o = ElvuiL.option_auras_auratimer end
	if o == "ElvuiConfigUIaurastargetauras" then o = ElvuiL.option_auras_targetaura end
	if o == "ElvuiConfigUIaurasplayerauras" then o = ElvuiL.option_auras_playeraura end
	if o == "ElvuiConfigUIaurasauratextscale" then o = ElvuiL.option_auras_aurascale end
	if o == "ElvuiConfigUIaurastotdebuffs" then o = ElvuiL.option_auras_totdebuffs end
	if o == "ElvuiConfigUIaurasplayershowonlydebuffs" then o = ElvuiL.option_auras_playershowonlydebuffs end
	if o == "ElvuiConfigUIaurasplayerdebuffsonly" then o = ElvuiL.option_auras_playerdebuffsonly end
	if o == "ElvuiConfigUIaurasfocusdebuffs" then o = ElvuiL.option_auras_focusdebuff end
	if o == "ElvuiConfigUIaurasraidunitbuffwatch" then o = ElvuiL.option_auras_RaidUnitBuffWatch end
	if o == "ElvuiConfigUIaurasplaytarbuffperrow" then o = ElvuiL.option_auras_playtarbuffperrow end
	if o == "ElvuiConfigUIaurassmallbuffperrow" then o = ElvuiL.option_auras_smallbuffperrow end
	if o == "ElvuiConfigUIaurasbuffindicatorsize" then o = ElvuiL.option_auras_buffindicatorsize end
	
	--castbars
	if o == "ElvuiConfigUIcastbar" then o = ElvuiL.option_castbar end
	if o == "ElvuiConfigUIcastbarnointerruptcolor" then o = ElvuiL.option_castbar_nointerruptcolor end
	if o == "ElvuiConfigUIcastbarcastbarcolor" then o = ElvuiL.option_castbar_castbarcolor end
	if o == "ElvuiConfigUIcastbarunitcastbar" then o = ElvuiL.option_castbar_castbar end
	if o == "ElvuiConfigUIcastbarcblatency" then o = ElvuiL.option_castbar_latency end
	if o == "ElvuiConfigUIcastbarcbicons" then o = ElvuiL.option_castbar_icon end
	if o == "ElvuiConfigUIcastbarcastermode" then o = ElvuiL.option_castbar_castermode end
	if o == "ElvuiConfigUIcastbarclasscolor" then o = ElvuiL.option_castbar_classcolor end
	
	--raidframes
	if o == "ElvuiConfigUIraidframes" then o = ElvuiL.option_raidframes end
	if o == "ElvuiConfigUIraidframesenable" then o = ElvuiL.option_raidframes_enable end
	if o == "ElvuiConfigUIraidframesgridonly" then o = ElvuiL.option_raidframes_gridonly end
	if o == "ElvuiConfigUIraidframeshealcomm" then o = DISPLAY_INCOMING_HEALS end
	if o == "ElvuiConfigUIraidframesshowboss" then o = ElvuiL.option_raidframes_boss end
	if o == "ElvuiConfigUIraidframesgridhealthvertical" then o = ElvuiL.option_raidframes_hpvertical end
	if o == "ElvuiConfigUIraidframesshowrange" then o = ElvuiL.option_raidframes_enablerange end
	if o == "ElvuiConfigUIraidframesraidalphaoor" then o = ElvuiL.option_raidframes_range end
	if o == "ElvuiConfigUIraidframesmaintank" then o = ElvuiL.option_raidframes_maintank end
	if o == "ElvuiConfigUIraidframesmainassist" then o = ElvuiL.option_raidframes_mainassist end
	if o == "ElvuiConfigUIraidframesnogriddps" then o = ElvuiL.option_raidframes_NoGridDps end
	if o == "ElvuiConfigUIraidframescenterheallayout" then o = ElvuiL.option_raidframes_CenterHealLayout end
	if o == "ElvuiConfigUIraidframesshowplayerinparty" then o = ElvuiL.option_raidframes_playerparty end
	if o == "ElvuiConfigUIraidframeshidenonmana" then o = ElvuiL.option_raidframes_hidenonmana end 
	if o == "ElvuiConfigUIraidframesfontsize" then o = ElvuiL.option_raidframes_fontsize end 
	if o == "ElvuiConfigUIraidframesscale" then o = ElvuiL.option_raidframes_scale end 
	if o == "ElvuiConfigUIraidframesdisableblizz" then o = ElvuiL.option_raidframes_disableblizz end
	if o == "ElvuiConfigUIraidframespartypets" then o = DISPLAY_RAID_PETS.." ("..HEALER.." "..PARTY..")" end
	if o == "ElvuiConfigUIraidframeshealthdeficit" then o = SHOW.." "..RAID_HEALTH_TEXT_LOSTHEALTH end
	if o == "ElvuiConfigUIraidframesgriddps" then o = ElvuiL.option_raidframes_griddps end
	if o == "ElvuiConfigUIraidframesrole" then o = TRACKER_FILTER_LABEL.." "..RAID_SORT_GROUP.." "..RAID_SORT_ROLE end
	if o == "ElvuiConfigUIraidframespartytarget" then o = ElvuiL.option_raidframes_partytarget end
	
	-- unit frames
	if o == "ElvuiConfigUIunitframes" then o = ElvuiL.option_unitframes_unitframes end
	if o == "ElvuiConfigUIunitframeshealthcolor" then o = ElvuiL.option_unitframes_healthcolor end
	if o == "ElvuiConfigUIunitframescombatfeedback" then o = ElvuiL.option_unitframes_combatfeedback end
	if o == "ElvuiConfigUIunitframesshowtotalhpmp" then o = ElvuiL.option_unitframes_totalhpmp end
	if o == "ElvuiConfigUIunitframesshowplayerinparty" then o = ElvuiL.option_unitframes_playerparty end
	if o == "ElvuiConfigUIunitframespositionbychar" then o = ElvuiL.option_unitframes_saveperchar end
	if o == "ElvuiConfigUIunitframesplayeraggro" then o = ElvuiL.option_unitframes_playeraggro end
	if o == "ElvuiConfigUIunitframesshowsmooth" then o = ElvuiL.option_unitframes_smooth end
	if o == "ElvuiConfigUIunitframescharportrait" then o = ElvuiL.option_unitframes_portrait end
	if o == "ElvuiConfigUIunitframesportraitonhealthbar" then o = ElvuiL.option_unitframes_portraitonhealthbar end
	if o == "ElvuiConfigUIunitframesenable" then o = ElvuiL.option_unitframes_enable end
	if o == "ElvuiConfigUIunitframestargetpowerplayeronly" then o = ElvuiL.option_unitframes_enemypower end
	if o == "ElvuiConfigUIunitframesaggro" then o = ElvuiL.option_unitframes_raidaggro end
	if o == "ElvuiConfigUIunitframesshowsymbols" then o = ElvuiL.option_unitframes_symbol end
	if o == "ElvuiConfigUIunitframesshowthreat" then o = ElvuiL.option_unitframes_threatbar end
	if o == "ElvuiConfigUIunitframesshowfocustarget" then o = ElvuiL.option_unitframes_focus end
	if o == "ElvuiConfigUIunitframeslowThreshold" then o = ElvuiL.option_unitframes_manalow end
	if o == "ElvuiConfigUIunitframesclasscolor" then o = ElvuiL.option_unitframes_classcolor end
	if o == "ElvuiConfigUIunitframesswingbar" then o = ElvuiL.option_unitframes_SwingBar end
	if o == "ElvuiConfigUIunitframesdebuffhighlight" then o = ElvuiL.option_unitframes_DebuffHighlight end
	if o == "ElvuiConfigUIunitframesfontsize" then o = ElvuiL.option_unitframes_fontsize end
	if o == "ElvuiConfigUIunitframesmendpet" then o = ElvuiL.option_unitframes_mendpet end
	if o == "ElvuiConfigUIunitframespoweroffset" then o = ElvuiL.option_unitframes_unitframes_poweroffset end
	if o == "ElvuiConfigUIunitframesclassbar" then o = ElvuiL.option_unitframes_classbar end
	if o == "ElvuiConfigUIunitframeshealthbackdropcolor" then o = ElvuiL.option_unitframes_healthbackdropcolor end
	if o == "ElvuiConfigUIunitframeshealthcolorbyvalue" then o = ElvuiL.option_unitframes_healthcolorbyvalue end
	if o == "ElvuiConfigUIunitframescombat" then o = ElvuiL.option_unitframes_combat end
	if o == "ElvuiConfigUIunitframespettarget" then o = ElvuiL.option_unitframes_pettarget end
	
	-- frame sizes
	if o == "ElvuiConfigUIframesizes" then o = ElvuiL.option_framesizes end
	if o == "ElvuiConfigUIframesizesplaytarwidth" then o = ElvuiL.option_framesizes_playtarwidth end
	if o == "ElvuiConfigUIframesizesplaytarheight" then o = ElvuiL.option_framesizes_playtarheight end
	if o == "ElvuiConfigUIframesizessmallwidth" then o = ElvuiL.option_framesizes_smallwidth end
	if o == "ElvuiConfigUIframesizessmallheight" then o = ElvuiL.option_framesizes_smallheight end
	if o == "ElvuiConfigUIframesizesarenabosswidth" then o = ElvuiL.option_framesizes_arenabosswidth end
	if o == "ElvuiConfigUIframesizesarenabossheight" then o = ElvuiL.option_framesizes_arenabossheight end
	if o == "ElvuiConfigUIframesizesassisttankwidth" then o = ElvuiL.option_framesizes_assisttankwidth end
	if o == "ElvuiConfigUIframesizesassisttankheight" then o = ElvuiL.option_framesizes_assisttankheight end
	
	-- loot
	if o == "ElvuiConfigUIloot" then o = ElvuiL.option_loot end
	if o == "ElvuiConfigUIlootlootframe" then o = ElvuiL.option_loot_enableloot end
	if o == "ElvuiConfigUIlootautogreed" then o = ElvuiL.option_loot_autogreed end
	if o == "ElvuiConfigUIlootrolllootframe" then o = ElvuiL.option_loot_enableroll end
	
	-- tooltip
	if o == "ElvuiConfigUItooltip" then o = ElvuiL.option_tooltip end
	if o == "ElvuiConfigUItooltipenable" then o = ElvuiL.option_tooltip_enable end
	if o == "ElvuiConfigUItooltiphidecombat" then o = ElvuiL.option_tooltip_hidecombat end
	if o == "ElvuiConfigUItooltiphidebuttons" then o = ElvuiL.option_tooltip_hidebutton end
	if o == "ElvuiConfigUItooltiphideuf" then o = ElvuiL.option_tooltip_hideuf end
	if o == "ElvuiConfigUItooltipcursor" then o = ElvuiL.option_tooltip_cursor end
	if o == "ElvuiConfigUItooltiphidecombatraid" then o = ElvuiL.option_tooltip_combatraid end
	if o == "ElvuiConfigUItooltipcolorreaction" then o = ElvuiL.option_tooltip_colorreaction end
	if o == "ElvuiConfigUItooltipxOfs" then o = ElvuiL.option_tooltip_xOfs end
	if o == "ElvuiConfigUItooltipyOfs" then o = ElvuiL.option_tooltip_yOfs end
	if o == "ElvuiConfigUItooltipitemid" then o = ElvuiL.option_tooltip_itemid end
	if o == "ElvuiConfigUItooltipwhotargetting" then o = ElvuiL.option_tooltip_whotargetting end
	
	-- others
	if o == "ElvuiConfigUIothers" then o = ElvuiL.option_others end
	if o == "ElvuiConfigUIotherspvpautorelease" then o = ElvuiL.option_others_bg end
	if o == "ElvuiConfigUIotherssellgrays" then o = ElvuiL.option_others_autosell end
	if o == "ElvuiConfigUIothersautorepair" then o = ElvuiL.option_others_autorepair end
	if o == "ElvuiConfigUIothersenablebag" then o = ElvuiL.option_others_bagenable end
	if o == "ElvuiConfigUIotherssoulbag" then o = ElvuiL.option_others_soulbag end	
	if o == "ElvuiConfigUIotherserrorenable" then o = ElvuiL.option_others_errorhide end
	if o == "ElvuiConfigUIothersmovable" then o = ElvuiL.option_others_questmovable end
	if o == "ElvuiConfigUIothersenablemap" then o = ElvuiL.option_others_enablemap end
	if o == "ElvuiConfigUIothersautoacceptinv" then o = ElvuiL.option_others_autoinvite end
	if o == "ElvuiConfigUIotherstotembardirection" then o = ElvuiL.option_others_totembardirection end
	if o == "ElvuiConfigUIothersportals" then o = ElvuiL.option_others_portals end
	if o == "ElvuiConfigUIothersannounceinterrupt" then o = ElvuiL.option_others_announceinterrupt end
	
	-- reminder
	if o == "ElvuiConfigUIbuffreminder" then o = ElvuiL.option_reminder end
	if o == "ElvuiConfigUIbuffreminderenable" then o = ElvuiL.option_reminder_enable end
	if o == "ElvuiConfigUIbuffremindersound" then o = ElvuiL.option_reminder_sound end
	if o == "ElvuiConfigUIbuffreminderraidbuffreminder" then o = ElvuiL.option_reminder_RaidBuffReminder end
	
	-- action bar
	if o == "ElvuiConfigUIactionbar" then o = ElvuiL.option_actionbar end
	if o == "ElvuiConfigUIactionbarhideshapeshift" then o = ElvuiL.option_actionbar_hidess end
	if o == "ElvuiConfigUIactionbarshowgrid" then o = ElvuiL.option_actionbar_showgrid end
	if o == "ElvuiConfigUIactionbarenable" then o = ElvuiL.option_actionbar_enable end
	if o == "ElvuiConfigUIactionbarrightbarmouseover" then o = ElvuiL.option_actionbar_rb end
	if o == "ElvuiConfigUIactionbarhotkey" then o = ElvuiL.option_actionbar_hk end
	if o == "ElvuiConfigUIactionbarshapeshiftmouseover" then o = ElvuiL.option_actionbar_ssmo end
	if o == "ElvuiConfigUIactionbarbottompetbar" then o = ElvuiL.option_actionbar_bottompetbar end
	if o == "ElvuiConfigUIactionbarbuttonsize" then o = ElvuiL.option_actionbar_buttonsize end
	if o == "ElvuiConfigUIactionbarbuttonspacing" then o = ElvuiL.option_actionbar_buttonspacing end
	if o == "ElvuiConfigUIactionbarpetbuttonsize" then o = ElvuiL.option_actionbar_petbuttonsize end
	if o == "ElvuiConfigUIactionbarswaptopbottombar" then o = ElvuiL.option_actionbar_swaptopbottombar end
	if o == "ElvuiConfigUIactionbarmacrotext" then o = ElvuiL.option_actionbar_macrotext end
	if o == "ElvuiConfigUIactionbarverticalstance" then o = ElvuiL.option_actionbar_verticalstance end
	if o == "ElvuiConfigUIactionbarmicrobar" then o = ElvuiL.option_actionbar_microbar end
	if o == "ElvuiConfigUIactionbarmousemicro" then o = ElvuiL.option_actionbar_mousemicro end
	
	-- arena
	if o == "ElvuiConfigUIarena" then o = ElvuiL.option_arena end
	if o == "ElvuiConfigUIarenaspelltracker" then o = ElvuiL.option_arena_st end
	if o == "ElvuiConfigUIarenaunitframes" then o = ElvuiL.option_arena_uf end
	
	-- cooldowns
	if o == "ElvuiConfigUIcooldown" then o = ElvuiL.option_cooldown end
	if o == "ElvuiConfigUIcooldownenable" then o = ElvuiL.option_cooldown_enable end
	if o == "ElvuiConfigUIcooldowntreshold" then o = ElvuiL.option_cooldown_th end
	if o == "ElvuiConfigUIcooldownexpiringcolor" then o = ElvuiL.option_cooldown_expiringcolor end
	if o == "ElvuiConfigUIcooldownsecondscolor" then o = ElvuiL.option_cooldown_secondscolor end
	if o == "ElvuiConfigUIcooldownminutescolor" then o = ElvuiL.option_cooldown_minutescolor end
	if o == "ElvuiConfigUIcooldownhourscolor" then o = ElvuiL.option_cooldown_hourscolor end
	if o == "ElvuiConfigUIcooldowndayscolor" then o = ElvuiL.option_cooldown_dayscolor end
	
	-- chat
	if o == "ElvuiConfigUIchat" then o = ElvuiL.option_chat end
	if o == "ElvuiConfigUIchatbubbles" then o = ElvuiL.option_chat_bubbles end
	if o == "ElvuiConfigUIchatenable" then o = ElvuiL.option_chat_enable end
	if o == "ElvuiConfigUIchatwhispersound" then o = ElvuiL.option_chat_whispersound end
	if o == "ElvuiConfigUIchatchatwidth" then o = ElvuiL.option_chat_chatwidth end
	if o == "ElvuiConfigUIchatshowbackdrop" then o = ElvuiL.option_chat_backdrop end
	if o == "ElvuiConfigUIchatfadeoutofuse" then o = ElvuiL.option_chat_fadeoutofuse end
	if o == "ElvuiConfigUIchatchatheight" then o = ElvuiL.option_chat_chatheight end
	if o == "ElvuiConfigUIchatsticky" then o = ElvuiL.option_chat_sticky end
	if o == "ElvuiConfigUIchatrightchat" then o = ElvuiL.option_chat_rightchat end
	if o == "ElvuiConfigUIchatcombathide" then o = ElvuiL.option_chat_combathide end
	
	--debug
	if o == "ElvuiConfigUIdebug" then o = ElvuiL.option_debug end
	if o == "ElvuiConfigUIdebugenabled" then o = ElvuiL.option_debug_enabled end
	if o == "ElvuiConfigUIdebugevents" then o = ElvuiL.option_debug_events end
	
	
	E.option = o
end

local NewButton = function(text,parent)
	local E, C, L = unpack(ElvUI) -- Import Functions/Constants, Config, Locales
	
	local result = CreateFrame("Button", nil, parent)
	local label = result:CreateFontString(nil,"OVERLAY",nil)
	label:SetFont(C.media.font,C["general"].fontscale)
	label:SetText(text)
	result:SetWidth(label:GetWidth())
	result:SetHeight(label:GetHeight())
	result:SetFontString(label)

	return result
end

local login = CreateFrame("Frame")
login:RegisterEvent("PLAYER_ENTERING_WORLD")
login:SetScript("OnEvent", function(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	
	local E, C, L = unpack(ElvUI) -- Import Functions/Constants, Config, Locales
	if ElvuiConfigAll[myPlayerRealm][myPlayerName] == true then
		print(L.core_welcome1..E.version.." (Loaded "..myPlayerName.."'s settings)")
	else
		print(L.core_welcome1..E.version.." (Loaded default settings)")
	end
end)

StaticPopupDialogs["PERCHAR"] = {
	text = ElvuiL.option_perchar,
	OnAccept = function() 
		local myPlayerRealm = GetCVar("realmName");
		local myPlayerName  = UnitName("player");
		if ElvuiConfigAllCharacters:GetChecked() then 
			ElvuiConfigAll[myPlayerRealm][myPlayerName] = true
		else 
			ElvuiConfigAll[myPlayerRealm][myPlayerName] = false
		end 	
		ReloadUI() 
	end,
	OnCancel = function() 
		ElvuiConfigCover:Hide()
		if ElvuiConfigAllCharacters:GetChecked() then 
			ElvuiConfigAllCharacters:SetChecked(false)
		else 
			ElvuiConfigAllCharacters:SetChecked(true)
		end 		
	end,
	button1 = ACCEPT,
	button2 = CANCEL,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["RESET_PERCHAR"] = {
	text = ElvuiL.option_resetchar,
	OnAccept = function() 
		ElvuiConfig = ElvuiConfigSettings
		ReloadUI() 
	end,
	OnCancel = function() ElvuiConfigCover:Hide() end,
	button1 = ACCEPT,
	button2 = CANCEL,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["RESET_ALL"] = {
	text = ElvuiL.option_resetall,
	OnAccept = function() 
		ElvuiConfigSettings = nil
		ElvuiConfig = nil
		ReloadUI() 
	end,
	OnCancel = function() ElvuiConfigCover:Hide() end,
	button1 = ACCEPT,
	button2 = CANCEL,
	timeout = 0,
	whileDead = 1,
}

--Determine if we should be copying our default settings to our player settings, this only happens if we're not using player settings by default
local mergesettings
if ElvuiConfig == ElvuiConfigSettings then
	mergesettings = true
else
	mergesettings = false
end

-- We wanna make sure we have all needed tables when we try add values
local function SetValue(group,option,value)
	local myPlayerRealm = GetCVar("realmName");
	local myPlayerName  = UnitName("player");
		
	if ElvuiConfigAll[myPlayerRealm][myPlayerName] == true then
		if not ElvuiConfig then ElvuiConfig = {} end	
		if not ElvuiConfig[group] then ElvuiConfig[group] = {} end
		ElvuiConfig[group][option] = value
	else
		--Set PerChar settings to the same as our settings if theres no per char settings
		if mergesettings == true then
			if not ElvuiConfig then ElvuiConfig = {} end	
			if not ElvuiConfig[group] then ElvuiConfig[group] = {} end
			ElvuiConfig[group][option] = value
		end
		
		if not ElvuiConfigSettings then ElvuiConfigSettings = {} end
		if not ElvuiConfigSettings[group] then ElvuiConfigSettings[group] = {} end
		ElvuiConfigSettings[group][option] = value
	end
end

local VISIBLE_GROUP = nil
local function ShowGroup(group)	
	local E, C, L = unpack(ElvUI) -- Import Functions/Constants, Config, Locales
	
	if(VISIBLE_GROUP) then
		_G["ElvuiConfigUI"..VISIBLE_GROUP]:Hide()
	end
	if _G["ElvuiConfigUI"..group] then
		local o = "ElvuiConfigUI"..group
		Local(o)
		_G["ElvuiConfigUITitle"]:SetText(E.option)
		local height = _G["ElvuiConfigUI"..group]:GetHeight()
		_G["ElvuiConfigUI"..group]:Show()
		local scrollamntmax = 305
		local scrollamntmin = scrollamntmax - 10
		local max = height > scrollamntmax and height-scrollamntmin or 1
		
		if max == 1 then
			_G["ElvuiConfigUIGroupSlider"]:SetValue(1)
			_G["ElvuiConfigUIGroupSlider"]:Hide()
		else
			_G["ElvuiConfigUIGroupSlider"]:SetMinMaxValues(0, max)
			_G["ElvuiConfigUIGroupSlider"]:Show()
			_G["ElvuiConfigUIGroupSlider"]:SetValue(1)
		end
		_G["ElvuiConfigUIGroup"]:SetScrollChild(_G["ElvuiConfigUI"..group])
		
		local x
		if ElvuiConfigUIGroupSlider:IsShown() then 
			_G["ElvuiConfigUIGroup"]:EnableMouseWheel(true)
			_G["ElvuiConfigUIGroup"]:SetScript("OnMouseWheel", function(self, delta)
				if ElvuiConfigUIGroupSlider:IsShown() then
					if delta == -1 then
						x = _G["ElvuiConfigUIGroupSlider"]:GetValue()
						_G["ElvuiConfigUIGroupSlider"]:SetValue(x + 10)
					elseif delta == 1 then
						x = _G["ElvuiConfigUIGroupSlider"]:GetValue()			
						_G["ElvuiConfigUIGroupSlider"]:SetValue(x - 30)	
					end
				end
			end)
		else
			_G["ElvuiConfigUIGroup"]:EnableMouseWheel(false)
		end
		VISIBLE_GROUP = group
	end
end

local function CreateElvuiConfigUI()
	local E, C, L = unpack(ElvUI) -- Import Functions/Constants, Config, Locales
	
	if ElvuiConfigUI then
		ShowGroup("general")
		ElvuiConfigUI:Show()
		return
	end
	
	-- MAIN FRAME
	local ElvuiConfigUI = CreateFrame("Frame","ElvuiConfigUI",UIParent)
	ElvuiConfigUI:SetPoint("CENTER", UIParent, "CENTER", 90, 0)
	ElvuiConfigUI:SetWidth(550)
	ElvuiConfigUI:SetHeight(300)
	ElvuiConfigUI:SetFrameStrata("DIALOG")
	ElvuiConfigUI:SetFrameLevel(20)
	
	-- TITLE 2
	local ElvuiConfigUITitleBox = CreateFrame("Frame","ElvuiConfigUI",ElvuiConfigUI)
	ElvuiConfigUITitleBox:SetWidth(570)
	ElvuiConfigUITitleBox:SetHeight(24)
	ElvuiConfigUITitleBox:SetPoint("TOPLEFT", -10, 42)
	ElvuiConfigUITitleBox:SetTemplate("Default")
	
	local title = ElvuiConfigUITitleBox:CreateFontString("ElvuiConfigUITitle", "OVERLAY")
	title:SetFont(C.media.font, C["general"].fontscale)
	title:SetPoint("LEFT", ElvuiConfigUITitleBox, "LEFT",5, 0)
		
	local ElvuiConfigUIBG = CreateFrame("Frame","ElvuiConfigUI",ElvuiConfigUI)
	ElvuiConfigUIBG:SetPoint("TOPLEFT", -10, 10)
	ElvuiConfigUIBG:SetPoint("BOTTOMRIGHT", 10, -10)
	ElvuiConfigUIBG:SetTemplate("Default")
	
	-- GROUP SELECTION ( LEFT SIDE )
	local groups = CreateFrame("ScrollFrame", "ElvuiCatagoryGroup", ElvuiConfigUI)
	groups:SetPoint("TOPLEFT",-180,0)
	groups:SetWidth(150)
	groups:SetHeight(300)

	local ElvuiConfigCover = CreateFrame("Frame", "ElvuiConfigCover", ElvuiConfigUI)
	ElvuiConfigCover:SetPoint("TOPLEFT", ElvuiCatagoryGroup, "TOPLEFT")
	ElvuiConfigCover:SetPoint("BOTTOMRIGHT", ElvuiConfigUI, "BOTTOMRIGHT")
	ElvuiConfigCover:SetFrameLevel(ElvuiConfigUI:GetFrameLevel() + 20)
	ElvuiConfigCover:EnableMouse(true)
	ElvuiConfigCover:SetScript("OnMouseDown", function(self) print(ElvuiL.option_makeselection) end)
	ElvuiConfigCover:Hide()
	
	local groupsBG = CreateFrame("Frame","ElvuiConfigUI",ElvuiConfigUI)
	groupsBG:SetPoint("TOPLEFT", groups, -10, 10)
	groupsBG:SetPoint("BOTTOMRIGHT", groups, 10, -10)
	groupsBG:SetTemplate("Default")
		
	local slider = CreateFrame("Slider", "ElvuiConfigUICatagorySlider", groups)
	slider:SetPoint("TOPRIGHT", 0, 0)
	slider:SetWidth(20)
	slider:SetHeight(300)
	slider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
	slider:SetOrientation("VERTICAL")
	slider:SetValueStep(20)
	slider:SetScript("OnValueChanged", function(self,value) groups:SetVerticalScroll(value) end)
	slider:SetTemplate("Default")
	local r,g,b,a = unpack(C["media"].bordercolor)
	slider:SetBackdropColor(r,g,b,0.2)
	local child = CreateFrame("Frame",nil,groups)
	child:SetPoint("TOPLEFT")
	local offset=5
	
	for group in pairs(ALLOWED_GROUPS) do
		local o = "ElvuiConfigUI"..group
		Local(o)
		local button = NewButton(E.option, child)
		button:SetHeight(16)
		button:SetWidth(125)
		button:SetPoint("TOPLEFT", 5,-(offset))
		button:SetScript("OnClick", function(self) ShowGroup(group) end)		
		offset=offset+20
	end
	child:SetWidth(125)
	child:SetHeight(offset)
	slider:SetMinMaxValues(0, (offset == 0 and 1 or offset-12*25))
	slider:SetValue(1)
	groups:SetScrollChild(child)

	local x
	_G["ElvuiCatagoryGroup"]:EnableMouseWheel(true)
	_G["ElvuiCatagoryGroup"]:SetScript("OnMouseWheel", function(self, delta)
		if _G["ElvuiConfigUICatagorySlider"]:IsShown() then
			if delta == -1 then
				x = _G["ElvuiConfigUICatagorySlider"]:GetValue()
				_G["ElvuiConfigUICatagorySlider"]:SetValue(x + 10)
			elseif delta == 1 then
				x = _G["ElvuiConfigUICatagorySlider"]:GetValue()			
				_G["ElvuiConfigUICatagorySlider"]:SetValue(x - 20)	
			end
		end
	end)

	-- GROUP SCROLLFRAME ( RIGHT SIDE)
	local group = CreateFrame("ScrollFrame", "ElvuiConfigUIGroup", ElvuiConfigUI)
	group:SetPoint("TOPLEFT",0,5)
	group:SetWidth(550)
	group:SetHeight(300)
	local slider = CreateFrame("Slider", "ElvuiConfigUIGroupSlider", group)
	slider:SetPoint("TOPRIGHT",0,0)
	slider:SetWidth(20)
	slider:SetHeight(300)
	slider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
	slider:SetOrientation("VERTICAL")
	slider:SetValueStep(20)
	slider:SetTemplate("Default")
	local r,g,b,a = unpack(C["media"].bordercolor)
	slider:SetBackdropColor(r,g,b,0.2)
	slider:SetScript("OnValueChanged", function(self,value) group:SetVerticalScroll(value) end)
	
	for group in pairs(ALLOWED_GROUPS) do
		local frame = CreateFrame("Frame","ElvuiConfigUI"..group,ElvuiConfigUIGroup)
		frame:SetPoint("TOPLEFT")
		frame:SetWidth(325)

		local offset=5
		for option,value in pairs(C[group]) do
			
			if type(value) == "boolean" then
				local button = CreateFrame("CheckButton", "ElvuiConfigUI"..group..option, frame, "InterfaceOptionsCheckButtonTemplate")
				local o = "ElvuiConfigUI"..group..option
				Local(o)
				_G["ElvuiConfigUI"..group..option.."Text"]:SetText(E.option)
				_G["ElvuiConfigUI"..group..option.."Text"]:SetFont(C.media.font, C["general"].fontscale)
				button:SetChecked(value)
				button:SetScript("OnClick", function(self) SetValue(group,option,(self:GetChecked() and true or false)) end)
				button:SetPoint("TOPLEFT", 5, -(offset))
				offset = offset+25
			elseif (type(value) == "number" or type(value) == "string") and not Filter[option] then
				local label = frame:CreateFontString(nil,"OVERLAY",nil)
				label:SetFont(C.media.font,C["general"].fontscale)
				local o = "ElvuiConfigUI"..group..option
				Local(o)
				label:SetText(E.option)
				label:SetWidth(420)
				label:SetHeight(20)
				label:SetJustifyH("LEFT")
				label:SetPoint("TOPLEFT", 5, -(offset))
				local editbox = CreateFrame("EditBox", nil, frame)
				editbox:SetAutoFocus(false)
				editbox:SetMultiLine(false)
				editbox:SetWidth(280)
				editbox:SetHeight(20)
				editbox:SetMaxLetters(255)
				editbox:SetTextInsets(3,0,0,0)
				editbox:SetBackdrop({
					bgFile = [=[Interface\Addons\ElvUI\media\textures\blank]=], 
					tiled = false,
				})
				editbox:SetBackdropColor(0,0,0,0.5)
				editbox:SetBackdropBorderColor(0,0,0,1)
				editbox:SetFontObject(GameFontHighlight)
				editbox:SetPoint("TOPLEFT", 5, -(offset+20))
				editbox:SetText(value)
				editbox:SetTemplate("Default")
				local okbutton = CreateFrame("Button", nil, frame)
				okbutton:SetHeight(editbox:GetHeight())
				okbutton:SetWidth(editbox:GetHeight())
				okbutton:SetTemplate("Default")
				okbutton:SetPoint("LEFT", editbox, "RIGHT", 2, 0)
				local oktext = okbutton:CreateFontString(nil,"OVERLAY",nil)
				oktext:SetFont(C.media.font,12)
				oktext:SetText("OK")
				oktext:SetPoint("CENTER")
				oktext:SetJustifyH("CENTER")
				okbutton:Hide()
				
				if type(value) == "number" then
					editbox:SetScript("OnEscapePressed", function(self) okbutton:Hide() self:ClearFocus() self:SetText(value) end)
					editbox:SetScript("OnChar", function(self) okbutton:Show() end)
					editbox:SetScript("OnEnterPressed", function(self) okbutton:Hide() self:ClearFocus() SetValue(group,option,tonumber(self:GetText())) end)
					okbutton:SetScript("OnMouseDown", function(self) editbox:ClearFocus() self:Hide() SetValue(group,option,tonumber(editbox:GetText())) end)
				else
					editbox:SetScript("OnEscapePressed", function(self) okbutton:Hide() self:ClearFocus() self:SetText(value) end)
					editbox:SetScript("OnChar", function(self) okbutton:Show() end)
					editbox:SetScript("OnEnterPressed", function(self) okbutton:Hide() self:ClearFocus() SetValue(group,option,tostring(self:GetText())) end)	
					okbutton:SetScript("OnMouseDown", function(self) editbox:ClearFocus() self:Hide() SetValue(group,option,tostring(editbox:GetText())) end)					
				end

				offset = offset+45
			elseif type(value) == "table" then
				local label = frame:CreateFontString(nil,"OVERLAY",nil)
				label:SetFont(C.media.font,C["general"].fontscale)
				local o = "ElvuiConfigUI"..group..option
				Local(o)
				label:SetText(E.option)
				label:SetWidth(420)
				label:SetHeight(20)
				label:SetJustifyH("LEFT")
				label:SetPoint("TOPLEFT", 5, -(offset))
				
				colorbuttonname = (label:GetText().."ColorPicker")
				local colorbutton = CreateFrame("Button", colorbuttonname, frame)
				colorbutton:SetHeight(20)
				colorbutton:SetWidth(50)
				colorbutton:SetTemplate("Default")
				colorbutton:SetBackdropBorderColor(unpack(value))
				colorbutton:SetPoint("LEFT", label, "RIGHT", 2, 0)
				local colortext = colorbutton:CreateFontString(nil,"OVERLAY",nil)
				colortext:SetFont(C.media.font,C["general"].fontscale)
				colortext:SetText("Set Color")
				colortext:SetPoint("CENTER")
				colortext:SetJustifyH("CENTER")
				
				
				local function round(number, decimal)
					return (("%%.%df"):format(decimal)):format(number)
				end	
				
				colorbutton:SetScript("OnMouseDown", function(button) 
					if ColorPickerFrame:IsShown() then return end
					local oldr, oldg, oldb, olda = unpack(value)

					local function ShowColorPicker(r, g, b, a, changedCallback, sameCallback)
						HideUIPanel(ColorPickerFrame)
						ColorPickerFrame.button = button
						ColorPickerFrame:SetColorRGB(r,g,b)
						ColorPickerFrame.hasOpacity = (a ~= nil and a < 1)
						ColorPickerFrame.opacity = a
						ColorPickerFrame.previousValues = {oldr, oldg, oldb, olda}
						ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = changedCallback, changedCallback, sameCallback;
						ShowUIPanel(ColorPickerFrame)
					end
										
					local function ColorCallback(restore)
						-- Something change
						if restore ~= nil or button ~= ColorPickerFrame.button then return end

						local newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB()
						
						value = { newR, newG, newB, newA }
						SetValue(group,option,(value)) 
						button:SetBackdropBorderColor(newR, newG, newB, newA)	
					end
					
					local function SameColorCallback()
						value = { oldr, oldg, oldb, olda }
						SetValue(group,option,(value))
						button:SetBackdropBorderColor(oldr, oldg, oldb, olda)
					end
										
					ShowColorPicker(oldr, oldg, oldb, olda, ColorCallback, SameColorCallback)
				end)
				
				offset = offset+25
			end
		end
				
		frame:SetHeight(offset)
		frame:Hide()
	end

	local reset = NewButton(ElvuiL.option_button_reset, ElvuiConfigUI)
	reset:SetWidth(100)
	reset:SetHeight(20)
	reset:SetPoint("BOTTOMLEFT",-10, -38)
	reset:SetScript("OnClick", function(self) 
		ElvuiConfigCover:Show()
		if ElvuiConfigAll[myPlayerRealm][myPlayerName] == true then
			StaticPopup_Show("RESET_PERCHAR")
		else
			StaticPopup_Show("RESET_ALL")
		end
	end)
	reset:SetTemplate("Default")
	
	local close = NewButton(ElvuiL.option_button_close, ElvuiConfigUI)
	close:SetWidth(100)
	close:SetHeight(20)
	close:SetPoint("BOTTOMRIGHT", 10, -38)
	close:SetScript("OnClick", function(self) ElvuiConfigUI:Hide() end)
	close:SetTemplate("Default")
	
	local load = NewButton(ElvuiL.option_button_load, ElvuiConfigUI)
	load:SetHeight(20)
	load:SetPoint("LEFT", reset, "RIGHT", 15, 0)
	load:SetPoint("RIGHT", close, "LEFT", -15, 0)
	load:SetScript("OnClick", function(self) ReloadUI() end)
	load:SetTemplate("Default")

	if ElvuiConfigAll then
		local button = CreateFrame("CheckButton", "ElvuiConfigAllCharacters", ElvuiConfigUITitleBox, "InterfaceOptionsCheckButtonTemplate")
		
		local myPlayerRealm = GetCVar("realmName");
		local myPlayerName  = UnitName("player");
		
		button:SetScript("OnClick", function(self) StaticPopup_Show("PERCHAR") ElvuiConfigCover:Show() end)
		
		button:SetPoint("RIGHT", ElvuiConfigUITitleBox, "RIGHT",-3, 0)	
		
		local label = ElvuiConfigAllCharacters:CreateFontString(nil,"OVERLAY",nil)
		label:SetFont(C.media.font,C["general"].fontscale)
		
		label:SetText(ElvuiL.option_setsavedsetttings)
		label:SetPoint("RIGHT", button, "LEFT")
		
		
		
		if ElvuiConfigAll[myPlayerRealm][myPlayerName] == true then
			button:SetChecked(true)
		else
			button:SetChecked(false)
		end
	end
	
	ShowGroup("general")
end

do
	SLASH_CONFIG1 = '/ec'
	SLASH_CONFIG2 = '/elvui'
	function SlashCmdList.CONFIG(msg, editbox)
		if not ElvuiConfigUI or not ElvuiConfigUI:IsShown() then
			CreateElvuiConfigUI()
		else
			ElvuiConfigUI:Hide()
		end
	end
end

