local HydraulicPress = {}
HydraulicPress.__index = HydraulicPress

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
    table.remove(HydraulicPress.AvailablePresses, #HydraulicPress.AvailablePresses)
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

local function findPartNormal(part)
    -- find which side of the part is being pressed (facing up) by casting a straight ray down above it, and checking the result's normal
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Whitelist
    params.FilterDescendantsInstances = {part}

    local result = workspace:Raycast(part.Position + Vector3.new(0, 1, 0), Vector3.new(0, -10, 0), params)

    if not result then return end

    return result.Normal
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
    
    self._trove:Connect(RunService.Heartbeat, function(dt)
        local parts = game.Workspace:GetPartsInPart(self.Instance.Press, getHitboxParams())

        local dirToScale = {
            RightVector = "BodyWidthScale",
            UpVector = "BodyHeightScale",
            LookVector = "BodyDepthScale",
        }

        local doneChrs = {}

        for _, part in ipairs(parts) do
            local chr = part.Parent
            if not game.Players:GetPlayerFromCharacter(chr) and not table.find(doneChrs, chr) then return end

            table.insert(doneChrs, chr)

            local current = {}

            for _, dir in ipairs({"LookVector", "UpVector", "RightVector"}) do
                local yAmt = math.abs(chr.HumanoidRootPart.CFrame[dir].Y) -- how much the part's face is facing up, use abs in case is facing down

                if current.Dir == nil or current.Amt < yAmt then
                    current.Amt = yAmt
                    current.Dir = dir
                end
            end

            local dir = current.Dir
            local scaleVal = chr.Humanoid:FindFirstChild(dirToScale[dir])

            if scaleVal.Value - self.Config.PressSizeDecrease > self.Config.PressLimit then
                scaleVal.Value -= self.Config.PressLimit
            else
                scaleVal.Value = self.Config.PressLimit
            end

            local average = 0

            for _, scale in pairs(dirToScale) do -- get averages of scaled down proportions to set head to
                average += chr.Humanoid:FindFirstChild(scale).Value
            end

            average /= 3

            chr.Humanoid:FindFirstChild("HeadScale").Value = average
        end
    end)

    self._tweens.Press.Completed:Wait()

    task.wait(self.Config.PressTime)

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
    local info = TweenInfo.new(self.Config.LowerTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

    self._tweens = {
        Press = TweenService:Create(self.Instance.Press, info, {CFrame = self.Instance.Press.CFrame + Vector3.new(0, -14.75, 0)}), -- -15.27 is fully closed
        Reset = TweenService:Create(self.Instance.Press, info, {CFrame = self.Instance.Press.CFrame})
    }
end

function HydraulicPress.new()
    local press = getAvailablePress()
    if not press then return end

    local newHydraulicPress = setmetatable({
        Instance = press,
        State = nil, -- Idle, Active, Resetting
        
        _trove = Trove.new(),

        Config = {
            MinPressAmt = 0.5, -- minimum lookvector component magnitude to compress that part's appropriate size
            PressSizeDecrease = 0.001, -- by how many studs should the part being pressed shrink
            LowerTime = 5,
            PressTime = 1,

            PressLimit = 0.2
        }
    }, HydraulicPress)

    newHydraulicPress:CreateTweens()

    return newHydraulicPress
end

return HydraulicPress