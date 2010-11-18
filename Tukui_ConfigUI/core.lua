-- This will filter everythin NON user config data out of TukuiDB
local myPlayerRealm = GetCVar("realmName");
local myPlayerName  = UnitName("player");

ALLOWED_GROUPS = {
	["general"]=1,
	["media"]=1,
	["unitframes"]=1,
	["arena"]=1,
	["combattext"]=1,
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
}

local function Local(o)
	-- general
	if o == "TukuiConfigUIgeneral" then o = TukuiL.option_general end
	if o == "TukuiConfigUIgeneralautoscale" then o = TukuiL.option_general_uiscale end
	if o == "TukuiConfigUIgeneraloverridelowtohigh" then o = TukuiL.option_general_override end
	if o == "TukuiConfigUIgeneralmultisampleprotect" then o = TukuiL.option_general_multisample end
	if o == "TukuiConfigUIgeneraluiscale" then o = TukuiL.option_general_customuiscale end
	if o == "TukuiConfigUIgeneralembedright" then o = TukuiL.option_general_embedright end
	if o == "TukuiConfigUIgeneralclasscolortheme" then o = TukuiL.option_general_classtheme end
	if o == "TukuiConfigUIgeneralautocustomlagtolerance" then o = TukuiL.option_general_autocustomlagtolerance end
	
	--Media
	if o =="TukuiConfigUImedia" then o = TukuiL.option_media end
	if o =="TukuiConfigUImediafont" then o = TukuiL.option_media_font end
	if o =="TukuiConfigUImediauffont" then o = TukuiL.option_media_uffont end
	if o =="TukuiConfigUImediadmgfont" then o = TukuiL.option_media_dmgfont end
	if o =="TukuiConfigUImedianormTex" then o = TukuiL.option_media_normTex end
	if o =="TukuiConfigUImediaglowTex" then o = TukuiL.option_media_glowTex end
	if o =="TukuiConfigUImediabubbleTex" then o = TukuiL.option_media_bubbleTex end
	if o =="TukuiConfigUImediablank" then o = TukuiL.option_media_blank end
	if o =="TukuiConfigUImediabordercolor" then o = TukuiL.option_media_bordercolor end
	if o =="TukuiConfigUImediaaltbordercolor" then o = TukuiL.option_media_altbordercolor end
	if o =="TukuiConfigUImediabackdropcolor" then o = TukuiL.option_media_backdropcolor end
	if o =="TukuiConfigUImediabackdropfadecolor" then o = TukuiL.option_media_backdropfadecolor end
	if o =="TukuiConfigUImediabuttonhover" then o = TukuiL.option_media_buttonhover end
	if o =="TukuiConfigUImediavaluecolor" then o = TukuiL.option_media_valuecolor end
	if o =="TukuiConfigUImediaraidicons" then o = TukuiL.option_media_raidicons end
	if o =="TukuiConfigUImediawhisper" then o = TukuiL.option_media_whisper end
	if o =="TukuiConfigUImediawarning" then o = TukuiL.option_media_warning end
	if o =="TukuiConfigUImediaglossyTexture" then o = TukuiL.option_media_glossy end
	
	--Skin
	if o =="TukuiConfigUIskin" then o = TukuiL.option_skin end
	if o =="TukuiConfigUIskindxe" then o = TukuiL.option_skin_dxe end
	if o =="TukuiConfigUIskinomen" then o = TukuiL.option_skin_omen end
	if o =="TukuiConfigUIskinrecount" then o = TukuiL.option_skin_recount end
	if o =="TukuiConfigUIskinskada" then o = TukuiL.option_skin_skada end
	
	--Combat Text
	if o == "TukuiConfigUIcombattext" then o = TukuiL.option_combattext end
	if o == "TukuiConfigUIcombattextshowoverheal" then o = TukuiL.option_combattext_showoverheal end
	if o == "TukuiConfigUIcombattextshowhots" then o = TukuiL.option_combattext_showhots end
	
	--Classtimers
	if o == "TukuiConfigUIclasstimer" then o = TukuiL.option_classtimer end
	if o == "TukuiConfigUIclasstimerenable" then o = TukuiL.option_classtimer_enable end
	if o == "TukuiConfigUIclasstimerbar_height" then o = TukuiL.option_classtimer_bar_height end
	if o == "TukuiConfigUIclasstimerbar_spacing" then o = TukuiL.option_classtimer_bar_spacing end
	if o == "TukuiConfigUIclasstimericon_position" then o = TukuiL.option_classtimer_icon_position end
	if o == "TukuiConfigUIclasstimerlayout" then o = TukuiL.option_classtimer_layout end
	if o == "TukuiConfigUIclasstimershowspark" then o = TukuiL.option_classtimer_showspark end
	if o == "TukuiConfigUIclasstimercast_suparator" then o = TukuiL.option_classtimer_cast_suparator end
	if o == "TukuiConfigUIclasstimerclasscolor" then o = TukuiL.option_classtimer_classcolor end
	if o == "TukuiConfigUIclasstimerdebuffcolor" then o = TukuiL.option_classtimer_debuffcolor end
	if o == "TukuiConfigUIclasstimerbuffcolor" then o = TukuiL.option_classtimer_buffcolor end
	if o == "TukuiConfigUIclasstimerproccolor" then o = TukuiL.option_classtimer_proccolor end
	
	-- nameplate
	if o == "TukuiConfigUInameplate" then o = TukuiL.option_nameplates end
	if o == "TukuiConfigUInameplateenable" then o = TukuiL.option_nameplates_enable end
	if o == "TukuiConfigUInameplateshowhealth" then o = TukuiL.option_nameplates_showhealth end
	if o == "TukuiConfigUInameplateenhancethreat" then o = TukuiL.option_nameplates_enhancethreat end
	if o == "TukuiConfigUInameplateoverlap" then o = UNIT_NAMEPLATES_ALLOW_OVERLAP end
	if o == "TukuiConfigUInameplatecombat" then o = TukuiL.option_nameplates_combat end
	
	-- datatext
	if o == "TukuiConfigUIdatatext" then o = TukuiL.option_datatext end
	if o == "TukuiConfigUIdatatexttime24" then o = TukuiL.option_datatext_24h end
	if o == "TukuiConfigUIdatatextlocaltime" then o = TukuiL.option_datatext_localtime end
	if o == "TukuiConfigUIdatatextbattleground" then o = TukuiL.option_datatext_bg end
	if o == "TukuiConfigUIdatatextguild" then o = TukuiL.option_datatext_guild end
	if o == "TukuiConfigUIdatatextmem" then o = TukuiL.option_datatext_mem end
	if o == "TukuiConfigUIdatatextfontsize" then o = TukuiL.option_datatext_fontsize end
	if o == "TukuiConfigUIdatatextsystem" then o = TukuiL.option_datatext_system end
	if o == "TukuiConfigUIdatatextfriends" then o = TukuiL.option_datatext_friend end
	if o == "TukuiConfigUIdatatextwowtime" then o = TukuiL.option_datatext_time end
	if o == "TukuiConfigUIdatatextgold" then o = TukuiL.option_datatext_gold end
	if o == "TukuiConfigUIdatatextdur" then o = TukuiL.option_datatext_dur end	
	if o == "TukuiConfigUIdatatextstat1" then o = TukuiL.option_datatext_stat1 end
	if o == "TukuiConfigUIdatatextstat2" then o = TukuiL.option_datatext_stat2 end
	if o == "TukuiConfigUIdatatextbags" then o = TukuiL.option_datatext_bags end
	if o == "TukuiConfigUIdatatexthps_text" then o = TukuiL.option_datatext_hps end
	if o == "TukuiConfigUIdatatextdps_text" then o = TukuiL.option_datatext_dps end
	if o == "TukuiConfigUIdatatexthaste" then o = SPELL_HASTE_ABBR end
	if o == "TukuiConfigUIdatatextcurrency" then o = CURRENCY end
	
	--auras
	if o == "TukuiConfigUIauras" then o = TukuiL.option_auras end
	if o == "TukuiConfigUIaurasminimapauras" then o = TukuiL.option_auras_minimapauras end
	if o == "TukuiConfigUIaurasarenadebuffs" then o = TukuiL.option_auras_arenadebuffs end
	if o == "TukuiConfigUIaurasauratimer" then o = TukuiL.option_auras_auratimer end
	if o == "TukuiConfigUIaurastargetauras" then o = TukuiL.option_auras_targetaura end
	if o == "TukuiConfigUIaurasplayerauras" then o = TukuiL.option_auras_playeraura end
	if o == "TukuiConfigUIaurasauratextscale" then o = TukuiL.option_auras_aurascale end
	if o == "TukuiConfigUIaurastotdebuffs" then o = TukuiL.option_auras_totdebuffs end
	if o == "TukuiConfigUIaurasplayershowonlydebuffs" then o = TukuiL.option_auras_playershowonlydebuffs end
	if o == "TukuiConfigUIaurasplayerdebuffsonly" then o = TukuiL.option_auras_playerdebuffsonly end
	if o == "TukuiConfigUIaurasfocusdebuffs" then o = TukuiL.option_auras_focusdebuff end
	if o == "TukuiConfigUIaurasraidunitbuffwatch" then o = TukuiL.option_auras_RaidUnitBuffWatch end
	if o == "TukuiConfigUIaurasplaytarbuffperrow" then o = TukuiL.option_auras_playtarbuffperrow end
	if o == "TukuiConfigUIaurassmallbuffperrow" then o = TukuiL.option_auras_smallbuffperrow end
	
	--castbars
	if o == "TukuiConfigUIcastbar" then o = TukuiL.option_castbar end
	if o == "TukuiConfigUIcastbarnointerruptcolor" then o = TukuiL.option_castbar_nointerruptcolor end
	if o == "TukuiConfigUIcastbarcastbarcolor" then o = TukuiL.option_castbar_castbarcolor end
	if o == "TukuiConfigUIcastbarunitcastbar" then o = TukuiL.option_castbar_castbar end
	if o == "TukuiConfigUIcastbarcblatency" then o = TukuiL.option_castbar_latency end
	if o == "TukuiConfigUIcastbarcbicons" then o = TukuiL.option_castbar_icon end
	if o == "TukuiConfigUIcastbarcastermode" then o = TukuiL.option_castbar_castermode end
	if o == "TukuiConfigUIcastbarclasscolor" then o = TukuiL.option_castbar_classcolor end
	
	--raidframes
	if o == "TukuiConfigUIraidframes" then o = TukuiL.option_raidframes end
	if o == "TukuiConfigUIraidframesenable" then o = TukuiL.option_raidframes_enable end
	if o == "TukuiConfigUIraidframesgridonly" then o = TukuiL.option_raidframes_gridonly end
	if o == "TukuiConfigUIraidframeshealcomm" then o = DISPLAY_INCOMING_HEALS end
	if o == "TukuiConfigUIraidframesshowboss" then o = TukuiL.option_raidframes_boss end
	if o == "TukuiConfigUIraidframesgridhealthvertical" then o = TukuiL.option_raidframes_hpvertical end
	if o == "TukuiConfigUIraidframesshowrange" then o = TukuiL.option_raidframes_enablerange end
	if o == "TukuiConfigUIraidframesraidalphaoor" then o = TukuiL.option_raidframes_range end
	if o == "TukuiConfigUIraidframesmaintank" then o = TukuiL.option_raidframes_maintank end
	if o == "TukuiConfigUIraidframesmainassist" then o = TukuiL.option_raidframes_mainassist end
	if o == "TukuiConfigUIraidframesnogriddps" then o = TukuiL.option_raidframes_NoGridDps end
	if o == "TukuiConfigUIraidframescenterheallayout" then o = TukuiL.option_raidframes_CenterHealLayout end
	if o == "TukuiConfigUIraidframesshowplayerinparty" then o = TukuiL.option_raidframes_playerparty end
	if o == "TukuiConfigUIraidframeshidenonmana" then o = TukuiL.option_raidframes_hidenonmana end 
	if o == "TukuiConfigUIraidframesfontsize" then o = TukuiL.option_raidframes_fontsize end 
	if o == "TukuiConfigUIraidframesscale" then o = TukuiL.option_raidframes_scale end 
	if o == "TukuiConfigUIraidframesdisableblizz" then o = TukuiL.option_raidframes_disableblizz end
	if o == "TukuiConfigUIraidframespartypets" then o = DISPLAY_RAID_PETS.." ("..HEALER.." "..PARTY..")" end
	if o == "TukuiConfigUIraidframeshealthdeficit" then o = SHOW.." "..RAID_HEALTH_TEXT_LOSTHEALTH end
	
	-- unit frames
	if o == "TukuiConfigUIunitframes" then o = TukuiL.option_unitframes_unitframes end
	if o == "TukuiConfigUIunitframeshealthcolor" then o = TukuiL.option_unitframes_healthcolor end
	if o == "TukuiConfigUIunitframescombatfeedback" then o = TukuiL.option_unitframes_combatfeedback end
	if o == "TukuiConfigUIunitframesshowtotalhpmp" then o = TukuiL.option_unitframes_totalhpmp end
	if o == "TukuiConfigUIunitframesshowplayerinparty" then o = TukuiL.option_unitframes_playerparty end
	if o == "TukuiConfigUIunitframespositionbychar" then o = TukuiL.option_unitframes_saveperchar end
	if o == "TukuiConfigUIunitframesplayeraggro" then o = TukuiL.option_unitframes_playeraggro end
	if o == "TukuiConfigUIunitframesshowsmooth" then o = TukuiL.option_unitframes_smooth end
	if o == "TukuiConfigUIunitframescharportrait" then o = TukuiL.option_unitframes_portrait end
	if o == "TukuiConfigUIunitframesenable" then o = TukuiL.option_unitframes_enable end
	if o == "TukuiConfigUIunitframestargetpowerplayeronly" then o = TukuiL.option_unitframes_enemypower end
	if o == "TukuiConfigUIunitframesaggro" then o = TukuiL.option_unitframes_raidaggro end
	if o == "TukuiConfigUIunitframesshowsymbols" then o = TukuiL.option_unitframes_symbol end
	if o == "TukuiConfigUIunitframesshowthreat" then o = TukuiL.option_unitframes_threatbar end
	if o == "TukuiConfigUIunitframesshowfocustarget" then o = TukuiL.option_unitframes_focus end
	if o == "TukuiConfigUIunitframeslowThreshold" then o = TukuiL.option_unitframes_manalow end
	if o == "TukuiConfigUIunitframesclasscolor" then o = TukuiL.option_unitframes_classcolor end
	if o == "TukuiConfigUIunitframesswingbar" then o = TukuiL.option_unitframes_SwingBar end
	if o == "TukuiConfigUIunitframesdebuffhighlight" then o = TukuiL.option_unitframes_DebuffHighlight end
	if o == "TukuiConfigUIunitframesfontsize" then o = TukuiL.option_unitframes_fontsize end
	if o == "TukuiConfigUIunitframesmendpet" then o = TukuiL.option_unitframes_mendpet end
	if o == "TukuiConfigUIunitframespoweroffset" then o = TukuiL.option_unitframes_unitframes_poweroffset end
	if o == "TukuiConfigUIunitframesclassbar" then o = TukuiL.option_unitframes_classbar end
	if o == "TukuiConfigUIunitframeshealthbackdropcolor" then o = TukuiL.option_unitframes_healthbackdropcolor end
	if o == "TukuiConfigUIunitframeshealthcolorbyvalue" then o = TukuiL.option_unitframes_healthcolorbyvalue end
	
	-- frame sizes
	if o == "TukuiConfigUIframesizes" then o = TukuiL.option_framesizes end
	if o == "TukuiConfigUIframesizesplaytarwidth" then o = TukuiL.option_framesizes_playtarwidth end
	if o == "TukuiConfigUIframesizesplaytarheight" then o = TukuiL.option_framesizes_playtarheight end
	if o == "TukuiConfigUIframesizessmallwidth" then o = TukuiL.option_framesizes_smallwidth end
	if o == "TukuiConfigUIframesizessmallheight" then o = TukuiL.option_framesizes_smallheight end
	if o == "TukuiConfigUIframesizesarenabosswidth" then o = TukuiL.option_framesizes_arenabosswidth end
	if o == "TukuiConfigUIframesizesarenabossheight" then o = TukuiL.option_framesizes_arenabossheight end
	if o == "TukuiConfigUIframesizesassisttankwidth" then o = TukuiL.option_framesizes_assisttankwidth end
	if o == "TukuiConfigUIframesizesassisttankheight" then o = TukuiL.option_framesizes_assisttankheight end
	
	-- loot
	if o == "TukuiConfigUIloot" then o = TukuiL.option_loot end
	if o == "TukuiConfigUIlootlootframe" then o = TukuiL.option_loot_enableloot end
	if o == "TukuiConfigUIlootautogreed" then o = TukuiL.option_loot_autogreed end
	if o == "TukuiConfigUIlootrolllootframe" then o = TukuiL.option_loot_enableroll end
	
	-- tooltip
	if o == "TukuiConfigUItooltip" then o = TukuiL.option_tooltip end
	if o == "TukuiConfigUItooltipenable" then o = TukuiL.option_tooltip_enable end
	if o == "TukuiConfigUItooltiphidecombat" then o = TukuiL.option_tooltip_hidecombat end
	if o == "TukuiConfigUItooltiphidebuttons" then o = TukuiL.option_tooltip_hidebutton end
	if o == "TukuiConfigUItooltiphideuf" then o = TukuiL.option_tooltip_hideuf end
	if o == "TukuiConfigUItooltipcursor" then o = TukuiL.option_tooltip_cursor end
	if o == "TukuiConfigUItooltiphidecombatraid" then o = TukuiL.option_tooltip_combatraid end
	if o == "TukuiConfigUItooltipcolorreaction" then o = TukuiL.option_tooltip_colorreaction end
	if o == "TukuiConfigUItooltipxOfs" then o = TukuiL.option_tooltip_xOfs end
	if o == "TukuiConfigUItooltipyOfs" then o = TukuiL.option_tooltip_yOfs end
	if o == "TukuiConfigUItooltipitemid" then o = TukuiL.option_tooltip_itemid end
	
	-- others
	if o == "TukuiConfigUIothers" then o = TukuiL.option_others end
	if o == "TukuiConfigUIotherspvpautorelease" then o = TukuiL.option_others_bg end
	if o == "TukuiConfigUIotherssellgrays" then o = TukuiL.option_others_autosell end
	if o == "TukuiConfigUIothersautorepair" then o = TukuiL.option_others_autorepair end
	if o == "TukuiConfigUIothersenablebag" then o = TukuiL.option_others_bagenable end
	if o == "TukuiConfigUIotherssoulbag" then o = TukuiL.option_others_soulbag end	
	if o == "TukuiConfigUIotherserrorenable" then o = TukuiL.option_others_errorhide end
	if o == "TukuiConfigUIothersmovable" then o = TukuiL.option_others_questmovable end
	if o == "TukuiConfigUIothersenablemap" then o = TukuiL.option_others_enablemap end
	if o == "TukuiConfigUIothersautoacceptinv" then o = TukuiL.option_others_autoinvite end
	if o == "TukuiConfigUIotherstotembardirection" then o = TukuiL.option_others_totembardirection end
	if o == "TukuiConfigUIothersportals" then o = TukuiL.option_others_portals end
	if o == "TukuiConfigUIothersspincam" then o = TukuiL.option_others_spincam end
	if o == "TukuiConfigUIothersmendpet" then o = TukuiL.option_others_mendpet end
	
	-- reminder
	if o == "TukuiConfigUIbuffreminder" then o = TukuiL.option_reminder end
	if o == "TukuiConfigUIbuffreminderenable" then o = TukuiL.option_reminder_enable end
	if o == "TukuiConfigUIbuffremindersound" then o = TukuiL.option_reminder_sound end
	if o == "TukuiConfigUIbuffreminderraidbuffreminder" then o = TukuiL.option_reminder_RaidBuffReminder end
	
	-- action bar
	if o == "TukuiConfigUIactionbar" then o = TukuiL.option_actionbar end
	if o == "TukuiConfigUIactionbarhideshapeshift" then o = TukuiL.option_actionbar_hidess end
	if o == "TukuiConfigUIactionbarshowgrid" then o = TukuiL.option_actionbar_showgrid end
	if o == "TukuiConfigUIactionbarenable" then o = TukuiL.option_actionbar_enable end
	if o == "TukuiConfigUIactionbarrightbarmouseover" then o = TukuiL.option_actionbar_rb end
	if o == "TukuiConfigUIactionbarhotkey" then o = TukuiL.option_actionbar_hk end
	if o == "TukuiConfigUIactionbarshapeshiftmouseover" then o = TukuiL.option_actionbar_ssmo end
	if o == "TukuiConfigUIactionbarbottomrows" then o = TukuiL.option_actionbar_rbn end
	if o == "TukuiConfigUIactionbarrightbars" then o = TukuiL.option_actionbar_rn end
	if o == "TukuiConfigUIactionbarsplitbar" then o = TukuiL.option_actionbar_splitbar end
	if o == "TukuiConfigUIactionbarbottompetbar" then o = TukuiL.option_actionbar_bottompetbar end
	if o == "TukuiConfigUIactionbarbuttonsize" then o = TukuiL.option_actionbar_buttonsize end
	if o == "TukuiConfigUIactionbarbuttonspacing" then o = TukuiL.option_actionbar_buttonspacing end
	if o == "TukuiConfigUIactionbarpetbuttonsize" then o = TukuiL.option_actionbar_petbuttonsize end
	if o == "TukuiConfigUIactionbarpetbuttonspacing" then o = TukuiL.option_actionbar_petbuttonspacing end
	
	-- arena
	if o == "TukuiConfigUIarena" then o = TukuiL.option_arena end
	if o == "TukuiConfigUIarenaspelltracker" then o = TukuiL.option_arena_st end
	if o == "TukuiConfigUIarenaunitframes" then o = TukuiL.option_arena_uf end
	
	-- cooldowns
	if o == "TukuiConfigUIcooldown" then o = TukuiL.option_cooldown end
	if o == "TukuiConfigUIcooldownenable" then o = TukuiL.option_cooldown_enable end
	if o == "TukuiConfigUIcooldowntreshold" then o = TukuiL.option_cooldown_th end
	if o == "TukuiConfigUIcooldownexpiringcolor" then o = TukuiL.option_cooldown_expiringcolor end
	if o == "TukuiConfigUIcooldownsecondscolor" then o = TukuiL.option_cooldown_secondscolor end
	if o == "TukuiConfigUIcooldownminutescolor" then o = TukuiL.option_cooldown_minutescolor end
	if o == "TukuiConfigUIcooldownhourscolor" then o = TukuiL.option_cooldown_hourscolor end
	if o == "TukuiConfigUIcooldowndayscolor" then o = TukuiL.option_cooldown_dayscolor end
	
	-- chat
	if o == "TukuiConfigUIchat" then o = TukuiL.option_chat end
	if o == "TukuiConfigUIchatbubbles" then o = TukuiL.option_chat_bubbles end
	if o == "TukuiConfigUIchatenable" then o = TukuiL.option_chat_enable end
	if o == "TukuiConfigUIchatwhispersound" then o = TukuiL.option_chat_whispersound end
	if o == "TukuiConfigUIchatchatwidth" then o = TukuiL_option_chat_chatwidth end
	if o == "TukuiConfigUIchatshowbackdrop" then o = TukuiL_option_chat_backdrop end
	if o == "TukuiConfigUIchatfadeoutofuse" then o = TukuiL_option_chat_fadeoutofuse end
	if o == "TukuiConfigUIchatchatheight" then o = TukuiL_option_chat_chatheight end
	if o == "TukuiConfigUIchatsticky" then o = TukuiL_option_chat_sticky end
	
	TukuiDB.option = o
end

local NewButton = function(text,parent)
	local result = CreateFrame("Button", nil, parent)
	local label = result:CreateFontString(nil,"OVERLAY",nil)
	label:SetFont(TukuiCF.media.font,12,"OUTLINE")
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

	if TukuiConfigAll[myPlayerRealm][myPlayerName] == true then
		print(tukuilocal.core_welcome1..TukuiDB.version.." (Loaded "..myPlayerName.."'s settings)")
	else
		print(tukuilocal.core_welcome1..TukuiDB.version.." (Loaded default settings)")
	end
end)

StaticPopupDialogs["PERCHAR"] = {
	text = TukuiL_option_perchar,
	OnAccept = function() 
		local myPlayerRealm = GetCVar("realmName");
		local myPlayerName  = UnitName("player");
		if TukuiConfigAllCharacters:GetChecked() then 
			TukuiConfigAll[myPlayerRealm][myPlayerName] = true
		else 
			TukuiConfigAll[myPlayerRealm][myPlayerName] = false
		end 	
		ReloadUI() 
	end,
	OnCancel = function() 
		TukuiConfigCover:Hide()
		if TukuiConfigAllCharacters:GetChecked() then 
			TukuiConfigAllCharacters:SetChecked(false)
		else 
			TukuiConfigAllCharacters:SetChecked(true)
		end 		
	end,
	button1 = ACCEPT,
	button2 = CANCEL,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["RESET_PERCHAR"] = {
	text = TukuiL.option_resetchar,
	OnAccept = function() 
		TukuiConfig = TukuiConfigSettings
		ReloadUI() 
	end,
	OnCancel = function() TukuiConfigCover:Hide() end,
	button1 = ACCEPT,
	button2 = CANCEL,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["RESET_ALL"] = {
	text = TukuiL.option_resetall,
	OnAccept = function() 
		TukuiConfigSettings = nil
		TukuiConfig = nil
		ReloadUI() 
	end,
	OnCancel = function() TukuiConfigCover:Hide() end,
	button1 = ACCEPT,
	button2 = CANCEL,
	timeout = 0,
	whileDead = 1,
}

--Determine if we should be copying our default settings to our player settings, this only happens if we're not using player settings by default
local mergesettings
if TukuiConfig == TukuiConfigSettings then
	mergesettings = true
else
	mergesettings = false
end

-- We wanna make sure we have all needed tables when we try add values
local function SetValue(group,option,value)
	local myPlayerRealm = GetCVar("realmName");
	local myPlayerName  = UnitName("player");
		
	if TukuiConfigAll[myPlayerRealm][myPlayerName] == true then
		if not TukuiConfig then TukuiConfig = {} end	
		if not TukuiConfig[group] then TukuiConfig[group] = {} end
		TukuiConfig[group][option] = value
	else
		--Set PerChar settings to the same as our settings if theres no per char settings
		if mergesettings == true then
			if not TukuiConfig then TukuiConfig = {} end	
			if not TukuiConfig[group] then TukuiConfig[group] = {} end
			TukuiConfig[group][option] = value
		end
		
		if not TukuiConfigSettings then TukuiConfigSettings = {} end
		if not TukuiConfigSettings[group] then TukuiConfigSettings[group] = {} end
		TukuiConfigSettings[group][option] = value
	end
end

local VISIBLE_GROUP = nil
local function ShowGroup(group)	
	if(VISIBLE_GROUP) then
		_G["TukuiConfigUI"..VISIBLE_GROUP]:Hide()
	end
	if _G["TukuiConfigUI"..group] then
		local o = "TukuiConfigUI"..group
		Local(o)
		_G["TukuiConfigUITitle"]:SetText(TukuiDB.option)
		local height = _G["TukuiConfigUI"..group]:GetHeight()
		_G["TukuiConfigUI"..group]:Show()
		local scrollamntmax = 305
		local scrollamntmin = scrollamntmax - 10
		local max = height > scrollamntmax and height-scrollamntmin or 1
		
		if max == 1 then
			_G["TukuiConfigUIGroupSlider"]:SetValue(1)
			_G["TukuiConfigUIGroupSlider"]:Hide()
		else
			_G["TukuiConfigUIGroupSlider"]:SetMinMaxValues(0, max)
			_G["TukuiConfigUIGroupSlider"]:Show()
			_G["TukuiConfigUIGroupSlider"]:SetValue(1)
		end
		_G["TukuiConfigUIGroup"]:SetScrollChild(_G["TukuiConfigUI"..group])
		
		local x
		if TukuiConfigUIGroupSlider:IsShown() then 
			_G["TukuiConfigUIGroup"]:EnableMouseWheel(true)
			_G["TukuiConfigUIGroup"]:SetScript("OnMouseWheel", function(self, delta)
				if TukuiConfigUIGroupSlider:IsShown() then
					if delta == -1 then
						x = _G["TukuiConfigUIGroupSlider"]:GetValue()
						_G["TukuiConfigUIGroupSlider"]:SetValue(x + 10)
					elseif delta == 1 then
						x = _G["TukuiConfigUIGroupSlider"]:GetValue()			
						_G["TukuiConfigUIGroupSlider"]:SetValue(x - 30)	
					end
				end
			end)
		else
			_G["TukuiConfigUIGroup"]:EnableMouseWheel(false)
		end
		VISIBLE_GROUP = group
	end
end

local function CreateTukuiConfigUI()
	if TukuiConfigUI then
		ShowGroup("general")
		TukuiConfigUI:Show()
		return
	end
	
	-- MAIN FRAME
	local TukuiConfigUI = CreateFrame("Frame","TukuiConfigUI",UIParent)
	TukuiConfigUI:SetPoint("CENTER", UIParent, "CENTER", 90, 0)
	TukuiConfigUI:SetWidth(550)
	TukuiConfigUI:SetHeight(300)
	TukuiConfigUI:SetFrameStrata("DIALOG")
	TukuiConfigUI:SetFrameLevel(20)
	
	-- TITLE 2
	local TukuiConfigUITitleBox = CreateFrame("Frame","TukuiConfigUI",TukuiConfigUI)
	TukuiConfigUITitleBox:SetWidth(570)
	TukuiConfigUITitleBox:SetHeight(24)
	TukuiConfigUITitleBox:SetPoint("TOPLEFT", -10, 42)
	TukuiDB.SetTemplate(TukuiConfigUITitleBox)
	
	local title = TukuiConfigUITitleBox:CreateFontString("TukuiConfigUITitle", "OVERLAY")
	title:SetFont(TukuiCF.media.font, 12)
	title:SetPoint("LEFT", TukuiConfigUITitleBox, "LEFT",5, 0)
		
	local TukuiConfigUIBG = CreateFrame("Frame","TukuiConfigUI",TukuiConfigUI)
	TukuiConfigUIBG:SetPoint("TOPLEFT", -10, 10)
	TukuiConfigUIBG:SetPoint("BOTTOMRIGHT", 10, -10)
	TukuiDB.SetTemplate(TukuiConfigUIBG)
	

	
	-- GROUP SELECTION ( LEFT SIDE )
	local groups = CreateFrame("ScrollFrame", "TukuiCatagoryGroup", TukuiConfigUI)
	groups:SetPoint("TOPLEFT",-180,0)
	groups:SetWidth(150)
	groups:SetHeight(300)

	
	local TukuiConfigCover = CreateFrame("Frame", "TukuiConfigCover", TukuiConfigUI)
	TukuiConfigCover:SetPoint("TOPLEFT", TukuiCatagoryGroup, "TOPLEFT")
	TukuiConfigCover:SetPoint("BOTTOMRIGHT", TukuiConfigUI, "BOTTOMRIGHT")
	TukuiConfigCover:SetFrameLevel(TukuiConfigUI:GetFrameLevel() + 20)
	TukuiConfigCover:EnableMouse(true)
	TukuiConfigCover:SetScript("OnMouseDown", function(self) print(TukuiL_option_makeselection) end)
	TukuiConfigCover:Hide()
	
	local groupsBG = CreateFrame("Frame","TukuiConfigUI",TukuiConfigUI)
	groupsBG:SetPoint("TOPLEFT", groups, -10, 10)
	groupsBG:SetPoint("BOTTOMRIGHT", groups, 10, -10)
	TukuiDB.SetTemplate(groupsBG)
		
	local slider = CreateFrame("Slider", "TukuiConfigUICatagorySlider", groups)
	slider:SetPoint("TOPRIGHT", 0, 0)
	slider:SetWidth(20)
	slider:SetHeight(300)
	slider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
	slider:SetOrientation("VERTICAL")
	slider:SetValueStep(20)
	slider:SetScript("OnValueChanged", function(self,value) groups:SetVerticalScroll(value) end)
	TukuiDB.SetTemplate(slider)
	local r,g,b,a = unpack(TukuiCF["media"].bordercolor)
	slider:SetBackdropColor(r,g,b,0.2)
	local child = CreateFrame("Frame",nil,groups)
	child:SetPoint("TOPLEFT")
	local offset=5
	
	for group in pairs(ALLOWED_GROUPS) do
		local o = "TukuiConfigUI"..group
		Local(o)
		local button = NewButton(TukuiDB.option, child)
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
	_G["TukuiCatagoryGroup"]:EnableMouseWheel(true)
	_G["TukuiCatagoryGroup"]:SetScript("OnMouseWheel", function(self, delta)
		if _G["TukuiConfigUICatagorySlider"]:IsShown() then
			if delta == -1 then
				x = _G["TukuiConfigUICatagorySlider"]:GetValue()
				_G["TukuiConfigUICatagorySlider"]:SetValue(x + 10)
			elseif delta == 1 then
				x = _G["TukuiConfigUICatagorySlider"]:GetValue()			
				_G["TukuiConfigUICatagorySlider"]:SetValue(x - 20)	
			end
		end
	end)

	-- GROUP SCROLLFRAME ( RIGHT SIDE)
	local group = CreateFrame("ScrollFrame", "TukuiConfigUIGroup", TukuiConfigUI)
	group:SetPoint("TOPLEFT",0,5)
	group:SetWidth(550)
	group:SetHeight(300)
	local slider = CreateFrame("Slider", "TukuiConfigUIGroupSlider", group)
	slider:SetPoint("TOPRIGHT",0,0)
	slider:SetWidth(20)
	slider:SetHeight(300)
	slider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
	slider:SetOrientation("VERTICAL")
	slider:SetValueStep(20)
	TukuiDB.SetTemplate(slider)
	local r,g,b,a = unpack(TukuiCF["media"].bordercolor)
	slider:SetBackdropColor(r,g,b,0.2)
	slider:SetScript("OnValueChanged", function(self,value) group:SetVerticalScroll(value) end)
	
	for group in pairs(ALLOWED_GROUPS) do
		local frame = CreateFrame("Frame","TukuiConfigUI"..group,TukuiConfigUIGroup)
		frame:SetPoint("TOPLEFT")
		frame:SetWidth(325)

		local offset=5
		for option,value in pairs(TukuiCF[group]) do
			
			if type(value) == "boolean" then
				local button = CreateFrame("CheckButton", "TukuiConfigUI"..group..option, frame, "InterfaceOptionsCheckButtonTemplate")
				local o = "TukuiConfigUI"..group..option
				Local(o)
				_G["TukuiConfigUI"..group..option.."Text"]:SetText(TukuiDB.option)
				_G["TukuiConfigUI"..group..option.."Text"]:SetFont(TukuiCF.media.font, 12, "OUTLINE")
				button:SetChecked(value)
				button:SetScript("OnClick", function(self) SetValue(group,option,(self:GetChecked() and true or false)) end)
				button:SetPoint("TOPLEFT", 5, -(offset))
				offset = offset+25
			elseif type(value) == "number" or type(value) == "string" then
				local label = frame:CreateFontString(nil,"OVERLAY",nil)
				label:SetFont(TukuiCF.media.font,12,"OUTLINE")
				local o = "TukuiConfigUI"..group..option
				Local(o)
				label:SetText(TukuiDB.option)
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
					bgFile = [=[Interface\Addons\Tukui\media\textures\blank]=], 
					tiled = false,
				})
				editbox:SetBackdropColor(0,0,0,0.5)
				editbox:SetBackdropBorderColor(0,0,0,1)
				editbox:SetFontObject(GameFontHighlight)
				editbox:SetPoint("TOPLEFT", 5, -(offset+20))
				editbox:SetText(value)
				TukuiDB.SetTemplate(editbox)	
				local okbutton = CreateFrame("Button", nil, frame)
				okbutton:SetHeight(editbox:GetHeight())
				okbutton:SetWidth(editbox:GetHeight())
				TukuiDB.SetTemplate(okbutton)
				okbutton:SetPoint("LEFT", editbox, "RIGHT", 2, 0)
				local oktext = okbutton:CreateFontString(nil,"OVERLAY",nil)
				oktext:SetFont(TukuiCF.media.font,12,"OUTLINE")
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
				label:SetFont(TukuiCF.media.font,12,"OUTLINE")
				local o = "TukuiConfigUI"..group..option
				Local(o)
				label:SetText(TukuiDB.option)
				label:SetWidth(420)
				label:SetHeight(20)
				label:SetJustifyH("LEFT")
				label:SetPoint("TOPLEFT", 5, -(offset))
				
				colorbuttonname = (label:GetText().."ColorPicker")
				local colorbutton = CreateFrame("Button", colorbuttonname, frame)
				colorbutton:SetHeight(20)
				colorbutton:SetWidth(50)
				TukuiDB.SetTemplate(colorbutton)
				colorbutton:SetBackdropBorderColor(unpack(value))
				colorbutton:SetPoint("LEFT", label, "RIGHT", 2, 0)
				local colortext = colorbutton:CreateFontString(nil,"OVERLAY",nil)
				colortext:SetFont(TukuiCF.media.font,12,"OUTLINE")
				colortext:SetText("Set Color")
				colortext:SetPoint("CENTER")
				colortext:SetJustifyH("CENTER")
				
				local oldvalue = value
				
				local function round(number, decimal)
					return (("%%.%df"):format(decimal)):format(number)
				end	
				
				colorbutton:SetScript("OnMouseDown", function(self) 
					if ColorPickerFrame:IsShown() then return end
					local newR, newG, newB, newA
					local fired = 0
					
					local r,g,b,a = self:GetBackdropBorderColor();
					r,g,b,a = round(r, 2),round(g, 2),round(b, 2),round(a, 2)
					local originalR,originalG,originalB,originalA = r,g,b,a
					
					local function ShowColorPicker(r, g, b, a, changedCallback)
						ColorPickerFrame:SetColorRGB(r,g,b)
						a = tonumber(a)
						ColorPickerFrame.hasOpacity = (a ~= nil and a ~= 1)
						ColorPickerFrame.opacity = a
						ColorPickerFrame.previousValues = {originalR,originalG,originalB,originalA}
						ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = changedCallback, changedCallback, changedCallback;
						ColorPickerFrame:Hide()
						ColorPickerFrame:Show()
					end
										
					local function myColorCallback(restore)
						fired = fired + 1
						if restore ~= nil then
							-- The user bailed, we extract the old color from the table created by ShowColorPicker.
							newR, newG, newB, newA = unpack(restore)
						else
							-- Something changed
							newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB()
						end
						
						--Kinda a cheesy way to fix setting the value in the wrong place.. oh well
						if fired > 3 then
							value = { newR, newG, newB, newA }
							SetValue(group,option,(value)) 
							self:SetBackdropBorderColor(newR, newG, newB, newA)
							fired = 0
						end
					end
										
					ShowColorPicker(originalR, originalG, originalB, originalA, myColorCallback)
				end)
				
				offset = offset+25
			end
		end
				
		frame:SetHeight(offset)
		frame:Hide()
	end

	local reset = NewButton(TukuiL.option_button_reset, TukuiConfigUI)
	reset:SetWidth(100)
	reset:SetHeight(20)
	reset:SetPoint("BOTTOMLEFT",-10, -38)
	reset:SetScript("OnClick", function(self) 
		TukuiConfigCover:Show()
		if TukuiConfigAll[myPlayerRealm][myPlayerName] == true then
			StaticPopup_Show("RESET_PERCHAR")
		else
			StaticPopup_Show("RESET_ALL")
		end
	end)
	TukuiDB.SetTemplate(reset)
	
	local close = NewButton(TukuiL.option_button_close, TukuiConfigUI)
	close:SetWidth(100)
	close:SetHeight(20)
	close:SetPoint("BOTTOMRIGHT", 10, -38)
	close:SetScript("OnClick", function(self) TukuiConfigUI:Hide() end)
	TukuiDB.SetTemplate(close)
	
	local load = NewButton(TukuiL.option_button_load, TukuiConfigUI)
	load:SetHeight(20)
	load:SetPoint("LEFT", reset, "RIGHT", 15, 0)
	load:SetPoint("RIGHT", close, "LEFT", -15, 0)
	load:SetScript("OnClick", function(self) ReloadUI() end)
	TukuiDB.SetTemplate(load)

	if TukuiConfigAll then
		local button = CreateFrame("CheckButton", "TukuiConfigAllCharacters", TukuiConfigUITitleBox, "InterfaceOptionsCheckButtonTemplate")
		
		local myPlayerRealm = GetCVar("realmName");
		local myPlayerName  = UnitName("player");
		
		button:SetScript("OnClick", function(self) StaticPopup_Show("PERCHAR") TukuiConfigCover:Show() end)
		
		button:SetPoint("RIGHT", TukuiConfigUITitleBox, "RIGHT",-3, 0)	
		
		local label = TukuiConfigAllCharacters:CreateFontString(nil,"OVERLAY",nil)
		label:SetFont(TukuiCF.media.font,12,"OUTLINE")
		
		label:SetText(TukuiL.option_setsavedsetttings)
		label:SetPoint("RIGHT", button, "LEFT")
		
		
		
		if TukuiConfigAll[myPlayerRealm][myPlayerName] == true then
			button:SetChecked(true)
		else
			button:SetChecked(false)
		end
	end
	
	ShowGroup("general")
end

do
	SLASH_CONFIG1 = '/tc'
	SLASH_CONFIG2 = '/tukui'
	function SlashCmdList.CONFIG(msg, editbox)
		if not TukuiConfigUI or not TukuiConfigUI:IsShown() then
			CreateTukuiConfigUI()
		else
			TukuiConfigUI:Hide()
		end
	end
end

