local RepStorage = game:GetService("ReplicatedStorage")

local Ragdoll = require(script.Parent.Classes.Ragdoll)

local Knit = require(RepStorage.Packages.Knit)
local ServerComm = require(RepStorage.Packages.Comm).ServerComm

local ProfileManager = Knit.GetService("ProfileManager")

local serverComm = ServerComm.new(RepStorage)

game.Players.PlayerAdded:Connect(function(plr)
    local ragdoll = Ragdoll.new(plr)
    ragdoll:Enable()
end)

game.Players.PlayerRemoving:Connect(function(plr)
    if Ragdoll.GlobalRagdolls[plr] then
        Ragdoll.GlobalRagdolls[plr]:Destroy()
    end
end)

local function toggleRagdoll(plr, enable)
    local ragdollInst = Ragdoll.GlobalRagdolls[plr]

    if not ragdollInst then warn("Could not find player's ragdoll instance.") return end

    if enable then
        ragdollInst:Enable()
    else
        ragdollInst:Disable()
    end
end

serverComm:CreateSignal("EnableRagdoll"):Connect(function(plr)
    toggleRagdoll(true)
end)

serverComm:CreateSignal("DisableRagdoll"):Connect(function(plr)
    toggleRagdoll(false)
end)