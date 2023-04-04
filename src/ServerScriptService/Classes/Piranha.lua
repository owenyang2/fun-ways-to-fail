local PiranhaClass = {}
PiranhaClass.__index = PiranhaClass

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Trove = require(RepStorage.Packages.Trove)

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

function PiranhaClass:DefaultMovement()
    self._trove:Connect(RunService.Heartbeat, function(dt) -- in the future, maybe use perlin noise to make fish swim left/right, up/down random
        if self.Instance.Deg == 360 then
            self.Instance.Deg = 0
        end

        local x = self.Instance.Radius * math.cos(math.rad(self.Instance.Deg))
        local z = self.Instance.Radius * math.sin(math.rad(self.Instance.Deg))

        self.Instance.AlignPosition.Position = self.ParentInst.Water.Position + Vector3.new(-x, 0, -z) + self.Instance.Offset
        self.Instance.AlignOrientation.CFrame = CFrame.Angles(0, math.rad(-self.Instance.Deg), 0)
        
        self.Instance.Deg += self.Instance.DegInc

        -- check plr in radius

        local parts = game.Workspace:GetPartBoundsInRadius(self.Instance, self.DetectionRad, getOverlapParams())

        for _, part in ipairs(parts) do
            local plr = game.Players:GetPlayerFromCharacter(part:FindFirstAncestorOfClass("Model"))

            if not plr then continue end


        end
    end)
end

function PiranhaClass:Setup()
    self:DefaultMovement()
end

function PiranhaClass.new(model, parentInst)
	local self = setmetatable({
        DefaultBehaviour = {
            Radius = math.random(40, 45),
            Deg = math.random(0, 359),
            DegInc = math.random(50, 150) / 100,
            Offset = Vector3.new(math.random(-50, 50), math.random(-2, 2), math.random(-50, 50))
        },

        FollowBehaviour = {
            DetectionRad = 10,
            FollowingPlr = nil,
        },

        Instance = model,
        ParentInst = parentInst,
        _trove = Trove.new()
    }, PiranhaClass)

	self:Setup()

	return self
end

return PiranhaClass