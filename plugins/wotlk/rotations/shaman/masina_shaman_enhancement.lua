if UnitClass("player") == "Shaman" then
  FlameShock = GetSpellInfo(49233)
  FeralSpirit = GetSpellInfo(51533)
  Lavalash = GetSpellInfo(60103)
  Lightningbolt = GetSpellInfo(10391)
  MaelstromWeapon = GetSpellInfo(51528)
  HealingWave = GetSpellInfo(49273)
  Calloftheelements = GetSpellInfo(66842)
  StrengthofEarth = GetSpellInfo(8161)
  Manaspringtotem = GetSpellInfo(10497)
  Windfurytotem = GetSpellInfo(65990)
  TotemicRecall = GetSpellInfo(36936)

  playerHealth = 20

  C_Timer.NewTicker(0.1, function()
    if not mounted and GMR.IsExecuting() and GMR.InLoS("target") and UnitExists("target") then

      -- FeralSpirit
      if GetSpellInfo(FeralSpirit) and IsUsableSpell(FeralSpirit)
      and GetSpellCooldown(FeralSpirit) == 0 and UnitAffectingCombat("player") and GMR.GetHealth("target") < 100 then
        GMR.Cast(FeralSpirit)
        -- print('FeralSpirit!')
      end

      -- Flameshock magii
      if GetSpellInfo(FlameShock) and GetSpellCooldown(FlameShock) == 0 and
      IsUsableSpell(FlameShock) and IsSpellInRange(FlameShock, "target") then
         GMR.Cast(FlameShock)
         -- print("Flameshock!")
      end

      -- HealingWave
      local _, _, count = AuraUtil.FindAuraByName(MaelstromWeapon, "player", "HELPFUL")
      if count == 5 and 
      GMR.GetHealth("player") <= playerHealth then
        if GetSpellInfo(HealingWave) and IsUsableSpell(HealingWave) then
          GMR.Cast(HealingWave)
          -- print("HealingWave!")
        end
      -- Lightningbolt
      elseif count == 5 then
        if GetSpellInfo(Lightningbolt) and IsUsableSpell(Lightningbolt) and 
        IsSpellInRange(Lightningbolt, "target") then
          GMR.Cast(Lightningbolt)
          -- print("Lightningbolt!")
        end
      end

      -- Lavalash
      if GetSpellInfo(Lavalash) and IsUsableSpell(Lavalash) and
      IsSpellInRange(Lavalash) and GetSpellCooldown(Lavalash) == 0 then
        GMR.Cast(Lavalash)
        -- print('Lavalash!')
      end

     -- Totems
      if AuraUtil.FindAuraByName("Strength of Earth", "player", "HELPFUL") and
      AuraUtil.FindAuraByName("Mana Spring", "player", "HELPFUL") and
      AuraUtil.FindAuraByName("Windfury Totem", "player", "HELPFUL") then
        if not UnitAffectingCombat("player") and GetSpellInfo(TotemicRecall) and
        IsUsableSpell(TotemicRecall)then
          GMR.Cast(TotemicRecall)
          -- print("Totemic Recall!")
        end
      elseif UnitAffectingCombat("player") and GetSpellInfo(Calloftheelements) and
      IsUsableSpell(Calloftheelements) then
        GMR.Cast(Calloftheelements)
        -- print("Calloftheelements")
      end
    end
  end)
end
