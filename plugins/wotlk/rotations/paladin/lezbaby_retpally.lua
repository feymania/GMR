if UnitClass("player") == "Paladin" then
  --user variables
  AoWHealHP = 50 --Use AoW buff to heal below this % (0 to disable)
  HoFEnable = 1 --Use Hand of Freedom when slowed (0 to disable)
  HoJInterrupt = 1 --Use HoJ as an interrupt (0 to disable)
  ATInterrupt = 1 --Use Arcane Torrent as an interrupt (0 to disable)
  
  --spell IDs
  CrusaderStrike = GetSpellInfo(35395)
  JudgementWisdom = GetSpellInfo(53408)
  JudgementLight = GetSpellInfo(20271)
  DivineStorm = GetSpellInfo(53385)
  HammerWrath = GetSpellInfo(48806)
  Consecration = GetSpellInfo(48819)
  Exorcism = GetSpellInfo(48801)
  HolyWrath = GetSpellInfo(48817)
  ArtOfWar = GetSpellInfo(59578)
  Freedom = GetSpellInfo(66115)
  FlashOfLight = GetSpellInfo(48785)
  HammerJustice = GetSpellInfo(66613)
  ArcaneTorrent = GetSpellInfo(28730)
  

  C_Timer.NewTicker(0.1, function()
  if not mounted and GMR.IsExecuting() then
  --healing and utility spells
  
	--Hand of Freedom
    if GetSpellInfo(Freedom) and IsUsableSpell(Freedom) and GMR.IsCastable(Freedom) and GetUnitSpeed("player") > 0 and GetUnitSpeed("player") < 7 and HoFEnable == 1 then
      GMR.Cast(Freedom)
	end
	
	--AoW Flash
	if GetSpellInfo(FlashOfLight) and IsUsableSpell(FlashOfLight) and AuraUtil.FindAuraByName(ArtOfWar, "player", "HELPFUL") and  GMR.GetHealth("player") <= AoWHealHP then
	  GMR.Cast(FlashOfLight)
	end
	
	--Casting Interrupt HoJ
	if GetSpellInfo(HammerJustice) and IsUsableSpell(HammerJustice) and GMR.IsCastable(HammerJustice, "target") and GMR.InLoS("target") and UnitExists("target") and GMR.IsInterruptable("target") and GMR.UnitCastingTime("target", 2.5) and HoJInterrupt == 1 then
	  GMR.Cast(HammerJustice)
	end
	
	--casting Interrupt Arcane Torrent
	if GetSpellInfo(ArcaneTorrent) and IsUsableSpell(ArcaneTorrent) and GMR.IsCastable(ArcaneTorrent, "target") and GMR.InLoS("target") and UnitExists("target") and GMR.IsInterruptable("target") and GMR.UnitCastingTime("target", 0.5)
	and GMR.GetDistance("player", "target", "<", 6.5) and ATInterrupt == 1 then
	  GMR.Cast(ArcaneTorrent)
	end
  
  end
  if not mounted and GMR.IsExecuting() and GMR.InLoS("target") and UnitExists("target") and GMR.GetHealth("target") > 0 then
  --combat spells
    --determine if single or multiple targets
    mobcount = 0
    for i = 1, #GMR.Tables.Attackables do
      local enemyunit = GMR.Tables.Attackables[i][1]
      local enemytar = GMR.UnitTarget(enemyunit)
      if GMR.ObjectExists(enemyunit)
      and not GMR.UnitIsPlayer(enemyunit)
      and GMR.UnitIsPlayer(enemytar)
      and GMR.GetDistance("player", enemyunit, "<", 10)
      then mobcount = mobcount + 1
	  end
    end
  --debug aoe counter
  --if mobcount > 1 then print(mobcount) end

  if mobcount > 1 then
    --AOE Rotation

    --Consecration
    if GetSpellInfo(Consecration) and IsUsableSpell(Consecration) and GMR.IsCastable(Consecration, "target") and GMR.GetDistance("player", "target", "<", 6.5) and GetUnitSpeed("player") == 0 then
      GMR.Cast(Consecration)
    end

    --Divine Storm
    if GetSpellInfo(DivineStorm) and IsUsableSpell(DivineStorm) and GMR.IsCastable(DivineStorm, "target") and GMR.GetDistance("player", "target", "<", 6.5) then
      GMR.Cast(DivineStorm)
    end

    --Judgement
    if GetSpellInfo(JudgementWisdom) and IsUsableSpell(JudgementWisdom) and GMR.IsCastable(JudgementWisdom, "target") then
      GMR.Cast(JudgementWisdom)
    end

    --Holy Wrath
    if GetSpellInfo(HolyWrath) and IsUsableSpell(HolyWrath) and GMR.IsCastable(HolyWrath, "target") and (UnitCreatureType("target") == "Demon" or UnitCreatureType("target") == "Undead") then
      GMR.Cast(HolyWrath)
    end

    --Crusader Strike
    if GetSpellInfo(CrusaderStrike) and IsUsableSpell(CrusaderStrike) and GMR.IsCastable(CrusaderStrike, "target") then
      GMR.Cast(CrusaderStrike)
    end

    --Hammer of Wrath
    if GetSpellInfo(HammerWrath) and IsUsableSpell(HammerWrath) and GMR.IsCastable(HammerWrath, "target") then
      GMR.Cast(HammerWrath)
    end

    --Exorcism
    if GetSpellInfo(Exorcism) and IsUsableSpell(Exorcism) and GMR.IsCastable(Exorcism, "target") and AuraUtil.FindAuraByName(ArtOfWar, "player", "HELPFUL") then
      GMR.Cast(Exorcism)
    end

  else
    --Single Target Rotation

    --Crusader Strike
    if GetSpellInfo(CrusaderStrike) and IsUsableSpell(CrusaderStrike) and GMR.IsCastable(CrusaderStrike, "target") then
      GMR.Cast(CrusaderStrike)
    end

    --Judgement
    if GetSpellInfo(JudgementWisdom) and IsUsableSpell(JudgementWisdom) and GMR.IsCastable(JudgementWisdom, "target") then
      GMR.Cast(JudgementWisdom)
    end

    --Divine Storm
    if GetSpellInfo(DivineStorm) and IsUsableSpell(DivineStorm) and GMR.IsCastable(DivineStorm, "target") and GMR.GetDistance("player", "target", "<", 6.5) then
      GMR.Cast(DivineStorm)
    end

    --Hammer of Wrath
    if GetSpellInfo(HammerWrath) and IsUsableSpell(HammerWrath) and GMR.IsCastable(HammerWrath, "target") then
      GMR.Cast(HammerWrath)
    end

    --Consecration
    if GetSpellInfo(Consecration) and IsUsableSpell(Consecration) and GMR.IsCastable(Consecration, "target") and GMR.GetDistance("player", "target", "<", 6.5) and GetUnitSpeed("player") == 0 then
      GMR.Cast(Consecration)
    end

    --Exorcism
    if GetSpellInfo(Exorcism) and IsUsableSpell(Exorcism) and GMR.IsCastable(Exorcism, "target") and AuraUtil.FindAuraByName(ArtOfWar, "player", "HELPFUL") then
      GMR.Cast(Exorcism)
    end

    --Holy Wrath
    if GetSpellInfo(HolyWrath) and IsUsableSpell(HolyWrath) and GMR.IsCastable(HolyWrath, "target") and (UnitCreatureType("target") == "Demon" or UnitCreatureType("target") == "Undead") then
      GMR.Cast(HolyWrath)
    end
  end

  end
 end)
end