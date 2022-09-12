local f = CreateFrame("frame")
f:SetScript("OnUpdate", function()
  local itemId = 12345 -- replace with item id
  local itemName = GetItemInfo(itemId)
  if IsEquippedItem(itemId) 
  and IsUsableItem(itemId) 
  and GetItemCooldown(itemId) == 0
  and UnitExists("target")
  and UnitCanAttack("player", "target")
  and GMR.InCombat("player")
  and GMR.InCombat("target")
  and GMR.GetHealth("target") > 50 
  and GMR.GetDistance("player", "target", "<", GMR.GetCombatRange())
  and not GMR.IsCasting()
  and not IsFlying()
  and not IsMounted() then
    GMR.RunMacroText("/use "..itemName)
  end
  local itemId = 123456 -- replace with item id
  local itemName = GetItemInfo(itemId)
  if IsEquippedItem(itemId) 
  and IsUsableItem(itemId) 
  and GetItemCooldown(itemId) == 0
  and UnitExists("target")
  and UnitCanAttack("player", "target")
  and GMR.InCombat("player")
  and GMR.InCombat("target")
  and GMR.GetHealth("target") > 50 
  and GMR.GetDistance("player", "target", "<", GMR.GetCombatRange())
  and not GMR.IsCasting()
  and not IsFlying()
  and not IsMounted() then
    GMR.RunMacroText("/use "..itemName)
  end
end)