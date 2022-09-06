local HydraulicPress = {}
HydraulicPress.__index = {}

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Trove = require(RepStorage.Packages.Trove)

HydraulicPress.AvailablePresses = { -- available presses
    game.Workspace.PlaceModels:FindFirstChild("Hydraulic Press")
} 

local function getAvailablePress()
    if #HydraulicPress.AvailablePresses == 0 then warn("No available hydraulic presses to set up.") return end

    local press = HydraulicPress.AvailablePresses[#HydraulicPress.AvailablePresses]
    table.remove(HydraulicPress.AvailablePresses[#HydraulicPress.AvailablePresses])
    return press
end

local function getHitboxParams() -- returns updated overlap params for press hitbox
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Whitelist
    
    local filterDesc = {}

    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr.Character then
            table.insert(filterDesc, plr.Character)
        end
    end

    params.FilterDescendantsInstances = filterDesc

    return params
end

function HydraulicPress:Idle()
    self._trove:Connect(RunService.Heartbeat, function(dt)
        local parts = game.Workspace:GetPartsInPart(self.Instance.Hitbox, getHitboxParams())
        local foundChrs = {}

        for _, part in ipairs(parts) do
            local chr = part:FindFirstAncestorOfClass("Model")

            if not game.Players:GetPlayerFromCharacter(chr) and not table.find(foundChrs, chr) then continue end

            table.insert(foundChrs, chr)
        end

        if #foundChrs > 0 then
            self:ChangeState("Pressing")
        end
    end)
end

function HydraulicPress:Press()
    self._tweens.Press:Play()

    -- TODO: constantly detect player limbs facing up and squish them
    
    self._tweens.Press.Completed:Wait()

    self:ChangeState("Resetting")
end

function HydraulicPress:Reset()
    self._tweens.Reset:Play()
    self._tweens.Reset.Completed:Wait()

    self:ChangeState("Idle")
end

function HydraulicPress:ChangeState(state)
    task.spawn(function() -- incase there is a wait, prevent freezing of main thread
        self._trove:Clean()

        if state == "Idle" then
            self:Idle()
        elseif state == "Pressing" then
            self:Press()
        elseif state == "Resetting" then
            self:Reset()
        end    
    end)
end

function HydraulicPress:Start()
    self:ChangeState("Idle")
end

function HydraulicPress:CreateTweens()
    local info = TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

    self._tweens = {
        Press = TweenService:Create(self.Instance.Press, info, {CFrame = self.Instance.Press.CFrame + Vector3.new(0, -20, 0)}),
        Reset = TweenService:Create(self.Instance.Press, info, {CFrame = self.Instance.Press.CFrame})
    }
end

function HydraulicPress.new()
    local press = getAvailablePress()
    if not press then return end

    local newHydraulicPress = setmetatable({
        Instance = press,
        State = nil, -- Idle, Active, Resetting
        
        _trove = Trove.new()
    }, HydraulicPress)

    newHydraulicPress:CreateTweens()

    return newHydraulicPress
end

return HydraulicPress