local Food = {}
Food.__index = Food

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

local ServerComm = require(RepStorage.Packages.Comm).ServerComm
local serverComm = ServerComm.new(RepStorage, "Food")
local enlargeSignal = serverComm:CreateSignal("EnlargePlayer")

local Ragdoll = require(ServerScriptService.Server.Classes.Ragdoll)

Food.AvailableInstances = {
    game.Workspace.PlaceModels:FindFirstChild("Food")
}

function Food:GrowPlayer(plr)
    plr.Character.Humanoid.BodyWidthScale.Value *= 1.2

    if plr.Character.Humanoid.BodyWidthScale.Value > 2 then
        plr.Character.Humanoid.Health = 0
        
        local explosion = Instance.new("Explosion")
        explosion.DestroyJointRadiusPercent = 0
        explosion.ExplosionType = Enum.ExplosionType.NoCraters
        explosion.Visible = true
        explosion.Position = plr.Character.HumanoidRootPart.Position
        explosion.Parent = plr.Character
    end
end

function Food:Start()
    enlargeSignal:Connect(function(...)
        self:GrowPlayer(...)
    end)
end

function Food.new(baseTbl)
    local newInst = baseTbl.MachineFuncs.GetAvailableInst(Food.AvailableInstances)
    if not newInst then return end

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        Instance = newInst,
        
        _trove = Trove.new()
    }), Food)

    return self
end

return Food