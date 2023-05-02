local RepStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Knit = require(RepStorage.Packages.Knit)
local Component = require(RepStorage.Packages.Component)
local MachineFuncs = require(RepStorage.Common.MachineFunctions)
local Trove = require(RepStorage.Packages.Trove)

local Piranha = Component.new {
    Tag = "Piranha"
}

local function getOverlapParams()
    local op = OverlapParams.new()
    op.FilterType = Enum.RaycastFilterType.Whitelist

    local t = {}

    for _, plr in ipairs(game.Players:GetPlayers()) do
        table.insert(t, plr.Character)
    end

    op.FilterDescendantsInstances = t
    
    return op
end

function Piranha:TargetMovement()
    self.Instance.AlignPosition.Enabled = false
    self.Instance.AlignOrientation.Enabled = false

    self.Instance.FollowPos.Enabled = true
    self.Instance.FollowOrient.Enabled = true
    
    self._trove:Connect(RunService.Heartbeat, function(dt)
        self.Instance.FollowPos.Position = self.FollowBehaviour.FollowingPlr.Character.HumanoidRootPart.Position
    end)
end

function Piranha:DefaultMovement()
    self._trove:Connect(RunService.Heartbeat, function(dt) -- in the future, maybe use perlin noise to make fish swim left/right, up/down random
        if self.DefaultBehaviour.Deg == 360 then
            self.DefaultBehaviour.Deg = 0
        end

        local x = self.DefaultBehaviour.Radius * math.cos(math.rad(self.DefaultBehaviour.Deg))
        local z = self.DefaultBehaviour.Radius * math.sin(math.rad(self.DefaultBehaviour.Deg))

        self.Instance.AlignPosition.Position = self.ParentInst.Water.Position + Vector3.new(-x, 0, -z) + self.DefaultBehaviour.Offset
        self.Instance.AlignOrientation.CFrame = CFrame.Angles(0, math.rad(-self.DefaultBehaviour.Deg), 0)
        
        self.DefaultBehaviour.Deg += self.DefaultBehaviour.DegInc

        -- check plr in radius

        local parts = game.Workspace:GetPartBoundsInRadius(self.Instance.Position, self.FollowBehaviour.DetectionRad, getOverlapParams())

        for _, part in ipairs(parts) do
            local plr = game.Players:GetPlayerFromCharacter(part:FindFirstAncestorOfClass("Model"))
            if not plr then continue end

            self.FollowBehaviour.FollowingPlr = plr
            self._trove:Clean()
            self:TargetMovement()

            return
        end
    end)
end

function Piranha:Setup()
    self:DefaultMovement()
end

function Piranha:Start(part, parentInst)
    self.ParentInst = game.Workspace.PlaceModels.Piranhas
    self.DefaultBehaviour = {
        Radius = math.random(40, 45),
        Deg = math.random(0, 359),
        DegInc = math.random(50, 150) / 100,
        Offset = Vector3.new(math.random(-50, 50), math.random(-2, 2), math.random(-50, 50))
    }

    self.FollowBehaviour = {
        DetectionRad = 10,
        FollowingPlr = nil,
        TweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    }
    self._trove = Trove.new()

	self:Setup()
end

return Piranha