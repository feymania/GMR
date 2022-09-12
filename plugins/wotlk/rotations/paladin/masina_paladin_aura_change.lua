
if UnitClass("player") == "Paladin" then
  CrusaderAura = GetSpellInfo(32223)
  RetributionAura = GetSpellInfo(27150)    
    
  C_Timer.NewTicker(0.1, function()
    if IsMounted() and not UnitAffectingCombat("player") and GetSpellInfo(CrusaderAura) and
    IsUsableSpell(CrusaderAura) and not AuraUtil.FindAuraByName(CrusaderAura, "player", "HELPFUL") then
      GMR.Cast(CrusaderAura)  
  	end 

    if not IsMounted() and UnitAffectingCombat("player") and GetSpellInfo(RetributionAura) and
    IsUsableSpell(RetributionAura) and not AuraUtil.FindAuraByName(RetributionAura, "player", "HELPFUL") then
      GMR.Cast(RetributionAura)
  	end
  end)
end 

    