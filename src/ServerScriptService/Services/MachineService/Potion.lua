local Potion = {}
Potion.__index = Potion

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

local Ragdoll = require(ServerScriptService.Server.Classes.Ragdoll)

Potion.AvailableInstances = {
    game.Workspace.PlaceModels:FindFirstChild("Potion")
}

function Potion:Start()
    self.Instance.Potion.ProximityPrompt.Triggered:Connect(function(plr)
        local newPotion = RepStorage.Assets.Potion:Clone()
        newPotion.Parent = plr.Character
        newPotion.Anchored = false
        newPotion.CFrame = plr.Character.RightHand.CFrame + (plr.Character.RightHand.CFrame.UpVector * -0.5)
        newPotion.CFrame *= CFrame.Angles(math.rad(270), 0, 0)
        
        local newWeld = Instance.new("WeldConstraint")
        newWeld.Part0 = newPotion
        newWeld.Part1 = plr.Character.RightHand
        newWeld.Parent = newPotion
    end)
end

function Potion.new(baseTbl)
    local newInst = baseTbl.MachineFuncs.GetAvailableInst(Potion.AvailableInstances)
    if not newInst then return end

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        Instance = newInst,
        
        _trove = Trove.new()
    }), Potion)

    print("new potion")

    return self
end

return Potion