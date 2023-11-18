local Spin = {}
Spin.__index = Spin

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

function Spin:SpinWheel()
    local sectionNum = math.random(1, 100)

    local currBounds = 0

    for count, data in ipairs(self.Sections) do
        currBounds += data.Percent * 100
        if sectionNum <= currBounds then -- in the correct section, since within the bounds
            return data.Reward
        end
    end
end

function Spin:SetupWinSections()
    for i, data in ipairs(self.Sections) do
        local sectionFrame = self.spinUI.SpinWheel["Section" .. tostring(i)]
        sectionFrame.Percent.Text = tostring(data.Percent * 100) .. "%"
    end
end

function Spin:SetupSpinUI()
    self.spinUI.Close.Activated:Connect(function()
        self.spinUI.Visible = false
    end)
    self:SetupWinSections()
    self.spinUI.SpinButton.Activated:Connect(function()
        local result = self:SpinWheel()
        print(result)
    end)
end

function Spin:SetupAnims()
    self.UIFuncs.ApplyButtonClickAnim(self.spinUI.Close)

    local animatedButtons = {
        self.spinUI.Buy15,
        self.spinUI.Buy35,
        self.spinUI.SpinButton,
    }

    for _, button in ipairs(animatedButtons) do
        self.UIFuncs.ApplyButtonClickAnim(button, nil, 1.05, 1.05)
    end
end

function Spin:Start()
    self:SetupAnims()
    self:SetupSpinUI()
end

function Spin.new(baseTbl)
    --[[ 
    baseTbl comes with:
        UIFuncs : ModuleScript
        MainUI : ScreenGui
        Player : Player
    --]]

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        spinUI = baseTbl.MainUI.Menus.SpinFrame,
        
        Sections = { -- must add up to 100%
            {Reward = "UGC Item", Percent = 0.01},
            {Reward = "Boink Hammer", Percent = 0.05},
            {Reward = "100 Deaths", Percent = 0.1},
            {Reward = "50 Deaths", Percent = 0.15},
            {Reward = "30 Deaths", Percent = 0.19},
            {Reward = "10 Deaths", Percent = 0.5},
        },

        _trove = Trove.new()
    }), Spin)

    return self
end

return Spin