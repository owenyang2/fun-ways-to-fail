local ProfileService = require(script.ProfileService)

local RepStorage = game:GetService("ReplicatedStorage")

local Knit = require(RepStorage.Packages.Knit)
local Comm = require(RepStorage.Packages.Comm)

local ProfileManager = Knit.CreateService {
    Name = "ProfileManager",
    Client = {}
}

local ProfileStore = ProfileService.GetProfileStore(
    "PlayerDataTest1",
    {
        -- Defaults
        Deaths = 0
    }
)

local createLeaderstats = { -- which keys to create leaderstats for
    "Deaths"
}

local valueToInstVal = { -- value of data to value instance required to store
    Instance = "ObjectValue",
    string = "StringValue",
    number = "NumberValue",
    Vector3 = "Vector3Value",
    Color3 = "Color3Value",
    CFrame = "CFrameValue"
}

local Profiles = {}

local function createLeaderstatInst(plr, key)
    local val = Profiles[plr].Data[key]
    
    print(key, Profiles[plr].Data[key])

    if val ~= nil then
        local valInst = Instance.new(valueToInstVal[typeof(val)])
        valInst.Name = key
        valInst.Value = val
        valInst.Parent = plr.leaderstats
    end
end

local function onDataLoad(plr)
    --Network:FireClient(plr, "DataLoaded")
    local leaderstatsFolder = Instance.new("Folder")
    leaderstatsFolder.Name = "leaderstats"
    leaderstatsFolder.Parent = plr

    for _, key in pairs(createLeaderstats) do
        createLeaderstatInst(plr, key)
    end
end

local function onDataUpdate(plr, key)
    --Network:FireClient(plr, "DataUpdated")

    local valInst = plr.leaderstats:FindFirstChild(key)

    if not valInst and not table.find(createLeaderstats, key) then
        warn("Could not update leaderstats for " .. key .. ". Try adding to leaderstats whitelist.")
        return
    end

    valInst.Value = Profiles[plr].Data[key]
end

local function DeepCopyTable(t)
    local copy = {}
    for key, val in pairs(t) do
        if type(val) == "table" then
            copy[key] = DeepCopyTable(val)
        else
            copy[key] = val
        end
    end
    return copy
end

-- Connections
game.Players.PlayerAdded:Connect(function(plr)
    local profile = ProfileStore:LoadProfileAsync("Player_" .. plr.UserId, "ForceLoad")

    if profile then
        profile:Reconcile() -- adding new keys to template will add it to data
        profile:ListenToRelease(function()
            Profiles[plr] = nil
            plr:Kick() -- should be already gone though
        end)

        if plr:IsDescendantOf(game.Players) then
            Profiles[plr] = profile
            onDataLoad(plr)
        else
            -- if player left during profile loading
            profile:Release()
        end
    else
        -- failed to load
        plr:Kick()
    end
end)

game.Players.PlayerRemoving:Connect(function(plr)
    local profile = Profiles[plr]

    if profile then
        profile:Release()
    end
end)

function ProfileManager:GetData(plr)
    return DeepCopyTable(Profiles[plr].Data)
end

function ProfileManager.Client:GetData(plr)
    return self.Server:GetData(plr)
end

function ProfileManager:WriteData(plr, key, val)
    local data = Profiles[plr].Data

    local targetIndex = nil

    if type(key) == "table" then
        for _, subKey in ipairs(key) do
            if not targetIndex then
                targetIndex = data[subKey]
            else
                targetIndex = targetIndex[subKey]
            end
        end
    else
        targetIndex = data[key]
    end

    targetIndex = val

    onDataUpdate(plr, key)
end

function ProfileManager:IncrementData(plr, key, increment)
    local data = Profiles[plr].Data
    local targetIndex = nil

    if type(key) == "table" then
        for _, subKey in ipairs(key) do
            if not targetIndex then
                targetIndex = data[subKey]
            else
                targetIndex = targetIndex[subKey]
            end
        end
    else
        targetIndex = data[key]
    end

    self:WriteData(plr, key, targetIndex + increment)
end

function ProfileManager:InsertData(plr, key, val)
    local data = Profiles[plr].Data
    local targetIndex = nil

    if type(key) == "table" then
        for _, subKey in ipairs(key) do
            if not targetIndex then
                targetIndex = data[subKey]
            else
                targetIndex = targetIndex[subKey]
            end
        end
    else
        targetIndex = data[key]
    end

    local tCopy = DeepCopyTable(targetIndex)
    table.insert(tCopy, val)

    self:WriteData(plr, key, tCopy)
end

return ProfileManager