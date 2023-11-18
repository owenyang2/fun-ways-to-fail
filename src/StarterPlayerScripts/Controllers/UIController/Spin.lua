local Spin = {}
Spin.__index = Spin

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Knit = require(RepStorage.Packages.Knit)

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

function Spin:SetupWinSections()
    for i, data in ipairs(self.Sections) do
        local sectionFrame = self.spinUI.SpinWheel["Section" .. tostring(i)]
        sectionFrame.Percent.Text = tostring(data.Percent * 100) .. "%"
    end
end

function Spin:PlaySpinAnim()
    -- yeah
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

        SpinService = Knit.GetService("SpinService"),
        _trove = Trove.new()
    }), Spin)

    self.Sections = self.SpinService:GetSections()

    return self
end

return Spin