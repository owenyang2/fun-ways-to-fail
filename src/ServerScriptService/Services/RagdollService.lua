local RepStorage = game:GetService("ReplicatedStorage")

local Ragdoll = require(script.Parent.Parent.Classes.Ragdoll)

local Knit = require(RepStorage.Packages.Knit)

local RagdollService = Knit.CreateService {
    Name = "RagdollService",
    Client = {}
}

function RagdollService.Client:ToggleRagdoll(plr, enable)
    local ragdollInst = Ragdoll.GlobalRagdolls[plr]

    if not ragdollInst then warn("Could not find player's ragdoll instance.") return end

    if enable ~= nil then
        ragdollInst:Toggle(enable)
    else
        ragdollInst:Toggle()
    end
end

function RagdollService.Client:GetRagdollStatus(plr)
    -- returns if ragdolled or not
    local ragdollInst = Ragdoll.GlobalRagdolls[plr]

    if not ragdollInst then warn("Could not find player's ragdoll instance.") return end

    return ragdollInst.Ragdolled
end

function RagdollService:KnitStart()
    self.ProfileManager = Knit.GetService("ProfileManager")
    
    game.Players.PlayerAdded:Connect(function(plr)
        local ragdoll = Ragdoll.new(plr)
        ragdoll:Toggle(true)
    end)
    
    game.Players.PlayerRemoving:Connect(function(plr)
        if Ragdoll.GlobalRagdolls[plr] then
            Ragdoll.GlobalRagdolls[plr]:Destroy()
        end
    end)
end

return RagdollService