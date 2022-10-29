local Ragdoll = {}
Ragdoll.__index = Ragdoll

local RepStorage = game:GetService("ReplicatedStorage")

local Trove = require(RepStorage.Packages.Trove)

Ragdoll.GlobalRagdolls = {}

local hinges = { --LowerAngle and UpperAngle
	[{"LeftWrist", "RightWrist", "LeftAnkle", "RightAnkle"}] = {5, 5},
	[{"LeftElbow", "RightElbow"}] = {0, 135},
	[{"LeftKnee", "RightKnee"}] = {-140, 0},
}

local sockets = { -- UpperAngle, TwistLowerAngle, TwistUpperAngle and MaxFrictionTorque
	[{"Neck"}] = {60, -75, 60, 10},
	[{"RightShoulder", "LeftShoulder"}] = {45, -90, 150},
	[{"Waist"}] = {30, -55, 25},
	--[{"LeftHip", "RightHip"}] = {50, 100, -45},
	[{"LeftHip", "RightHip"}] = {90, -180, 180},
}

local function findReplacementJoint(targetMotor)
	for motors, properties in pairs(hinges) do
		if table.find(motors, targetMotor) then
			local hinge = Instance.new("HingeConstraint")
			hinge.Name = targetMotor
			hinge.LimitsEnabled = true
			
			hinge.LowerAngle = properties[1]
			hinge.UpperAngle = properties[2]
			
			return hinge
		end
	end
	
	for motors, properties in pairs(sockets) do
		if table.find(motors, targetMotor) then
			local socket = Instance.new("BallSocketConstraint")
			socket.Name = targetMotor
			--socket.LimitsEnabled = true
			--socket.TwistLimitsEnabled = true
			
			socket.UpperAngle = properties[1]
			socket.TwistLowerAngle = properties[2]
			socket.TwistUpperAngle = properties[3]
			
			if properties[4] then
				socket.MaxFrictionTorque = properties[4]
			end
			
			return socket
		end
	end
end

local function createAtt(name, cf, parent)
	local att = Instance.new("Attachment")
	att.Name = name
	att.CFrame = cf
	att.Parent = parent
	
	return att
end

function Ragdoll:CreateJoints()
	if not self.Player.Character then warn("Could not create ragdoll joints for " .. self.Player.Name) return end

	local jointFolder = Instance.new("Folder")
	jointFolder.Name = "RagdollJoints"
	jointFolder.Parent = self.Player.Character

	for _, motor in ipairs(self.Player.Character:GetDescendants()) do
		if not motor:IsA("Motor6D") then continue end

		local ragdollJoint = findReplacementJoint(motor.Name)
		if not ragdollJoint then continue end
		
		-- add motor to motor table
		table.insert(self.Motor6DJoints, motor)
		self._trove:Connect(motor.Destroying, function()
			table.remove(self.Motor6DJoints, table.find(self.Motor6DJoints, motor))
		end)
		
		ragdollJoint.Attachment0 = createAtt("RagdollAtt0", motor.C0, motor.Part0)
		ragdollJoint.Attachment1 = createAtt("RagdollAtt1", motor.C1, motor.Part1)			
		ragdollJoint.Parent = jointFolder
		ragdollJoint.Enabled = false
		
		table.insert(self.RagdollJoints, ragdollJoint)
		self._trove:Connect(ragdollJoint.Destroying, function()
			table.remove(self.RagdollJoints, table.find(self.RagdollJoints, ragdollJoint))
		end)
	end
end

function Ragdoll:Toggle(enable)
	-- using enable and disable should be easier, but made this as enable/disable are just inverses

	local chr = self.Player.Character

	if not chr or not chr:FindFirstChild("HumanoidRootPart") or not self.CanRagdoll then return end
	
	enable = if enable ~= nil then enable else not self.Ragdolled

	self.Ragdolled = enable
	
	chr.HumanoidRootPart.CanCollide = not enable
	chr.HumanoidRootPart.Massless = enable
	
	for _, motor in ipairs(self.Motor6DJoints) do
		motor.Enabled = not enable
	end

	for _, ragdollJoint in ipairs(self.RagdollJoints) do
		ragdollJoint.Enabled = enable
	end

	if enable then
		-- legs tended to remain stuck together, so seperate them using force for better vfx (or maybe try using the motor6ds in the future)
		self._vfTrove:Clean()

		if chr.LeftUpperLeg then
			local vfLeft = Instance.new("VectorForce")
			vfLeft.Attachment0 = chr.LeftUpperLeg.RagdollAtt0
			vfLeft.Force = Vector3.new(-500, 0, 0)
			vfLeft.Parent = chr.LeftUpperLeg
			self._vfTrove:Add(vfLeft)	

			task.delay(0.2, function()
				self._vfTrove:Remove(vfLeft)
			end)	
		end
	
		if chr.RightUpperLeg then
			local vfRight = Instance.new("VectorForce")
			vfRight.Attachment0 = chr.RightUpperLeg.RagdollAtt0
			vfRight.Force = Vector3.new(500, 0, 0)
			vfRight.Parent = chr.RightUpperLeg
			self._vfTrove:Add(vfRight)

			task.delay(0.2, function()
				self._vfTrove:Remove(vfRight)
			end)
		end
	
		game.Workspace.CurrentCamera.CameraSubject = chr.UpperTorso -- hrp tends to move a lot more in weird ways than uppertorso
	else
		game.Workspace.CurrentCamera.CameraSubject = chr.Humanoid
	end
end

function Ragdoll:EditCanRagdoll(canRagdoll)
	self.CanRagdoll = canRagdoll
end

function Ragdoll:Destroy()
	self:Toggle(false)
	self._trove:Destroy() -- clean up on death connections
	Ragdoll.GlobalRagdolls[self.Player] = nil
end

function Ragdoll:Setup()
	self._trove:Connect(self.Player.CharacterAdded, function(chr) -- should be disconnected when cleaned up
		self:EditCanRagdoll(true)
		self:CreateJoints()
		chr.Humanoid.BreakJointsOnDeath = false
		self._trove:Connect(chr.Humanoid.Died, function() -- setup ragdoll on death
			self:Toggle(true)
			self:EditCanRagdoll(false)
		end)
	end)
end

function Ragdoll.new(plr)
	local newRagdoll = setmetatable({
		Player = plr,
		_trove = Trove.new(),
		_vfTrove = Trove.new(),
		Ragdolled = false,
		
		RagdollJoints = {}, -- ragdoll joints
		Motor6DJoints = {}, -- normal motor6d joints
		
		CanRagdoll = true
	}, Ragdoll)

	Ragdoll.GlobalRagdolls[plr] = newRagdoll

	newRagdoll:Setup()

	return newRagdoll
end

return Ragdoll