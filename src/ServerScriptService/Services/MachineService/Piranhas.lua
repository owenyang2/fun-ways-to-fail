local Piranhas = {}
Piranhas.__index = Piranhas

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

local Ragdoll = require(ServerScriptService.Server.Classes.Ragdoll)

Piranhas.AvailableInstances = {
    game.Workspace.PlaceModels:FindFirstChild("Piranhas")
}

function Piranhas:SpawnPiranhas()
    local template = RepStorage.Assets.Piranha

    for i = 1, self.PiranhasToSpawn do
        local newP = template:Clone()
        newP.Parent = self.Instance.Fish

        self.Piranhas[newP] = {
            Radius = math.random(40, 45),
            Deg = math.random(0, 359),
            DegInc = math.random(50, 150) / 100
        }
    end
end

function Piranhas:Start()
    self:SpawnPiranhas()

    self._trove:Connect(RunService.Heartbeat, function(dt) -- in the future, maybe use perlin noise to make fish swim left/right, up/down random
        for p, info in pairs(self.Piranhas) do
            if info.Deg == 360 then
                info.Deg = 0
            end

            local x = info.Radius * math.cos(math.rad(info.Deg))
            local z = info.Radius * math.sin(math.rad(info.Deg))

            p.AlignPosition.Position = self.Instance.Water.Position + Vector3.new(-x, 0, -z)
            p.AlignOrientation.CFrame = CFrame.Angles(0, math.rad(-info.Deg), 0)
            
            info.Deg += info.DegInc
        end
    end)
end

function Piranhas.new(baseTbl)
    local newInst = baseTbl.MachineFuncs.GetAvailableInst(Piranhas.AvailableInstances)
    if not newInst then return end

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        Instance = newInst,
        Piranhas = {},
        PiranhasToSpawn = 5,

        _trove = Trove.new()
    }), Piranhas)

    return self
end

return Piranhas