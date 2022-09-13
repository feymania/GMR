-- BloodFurnaceLever
-- Author: Mons#0885
-- Version: 0.1.0

-- Usage, run with blood_furnace profile

-- Pulls the lever in Blood Furnace to reach second boss
-- hasPulled is to check if we interacted with the lever, resets once entering Hellfire Peninsula
-- So after every death, reset or sell

-- Feedback appreaciated
-- Profile has sell unstucks and center points for whole BF and Honor Hold

local f = CreateFrame("frame")
local hasPulled = false
f:SetScript("OnUpdate", function()
    local x, y, z = 455.765, 61.142, 9.614 -- Exact lever position

	-- TODO: Fix localization text for non english clients
    if GetZoneText() == "Hellfire Peninsula" then
        hasPulled = false
    end
	if GMR.IsPlayerPosition(x, y, z, 10) and not hasPulled then 
		local object = GMR.GetObjectWithInfo({ id = 181982, rawType = 8, isInteractable = true })
		if object then 
		    GMR.SetDelay("Execute", 5)
			if not GMR.IsPlayerPosition(x, y, z, 3) then
				GMR.Mesh(x, y, z)
			elseif GMR.IsMoving() then
				GMR.StopMoving()
            else
				GMR.Interact(object)
                hasPulled = true
			end
		end
	end
end)