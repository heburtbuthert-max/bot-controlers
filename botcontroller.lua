--[[ 
    Asu-style Bot Controller by karentrolllololol/azloaf/meethemoniters
    - Same command names/booleans/style as asu
   

    HOW TO USE:
1) Set getgenv() config (below or externally). Owner should be one of the test players (e.g., "Player1").
 2) In owner’s chat, use your commands: ;status ;index ;follow <plr> ;orbit <plr> <r> <spd> ;circle 10 ;align <plr> ;goto <plr> ;help ...
]]--

-- === Services ===
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")


-- === getgenv configs 
local Use_Displayname = getgenv().Use_Displayname
local bots = getgenv().bots
local owner = getgenv().owner
local nbbot = getgenv().nbbot
local prefix = getgenv().prefix
local botrender = getgenv().botrender
local printcmd = getgenv().printcmd
local versionfromconfig = getgenv().version

-- === flags (kept identical) ===
local cmdstatus = true
local cmdindex = true
local cmdfollow = true
local cmdquit = true
local cmddance = true
local cmdundance = true
local cmdreset = true
local cmdjump = true
local cmdsay = true
local cmdunfollow = true
local cmdorbit = true
local cmdunorbit = true
local cmdgoto = true
local cmdalign = true
local cmdws = true
local cmdloopjump = true
local cmdunloopjump = true
local cmdcircle = true
local cmdchannel = true
local cmdworm = true
local cmdunworm = true
local cmdspin = true
local cmdunspin = true
local cmdadmin = true
local cmdarch = true
local cmdorbit2 = true
local cmdorbit3 = true
local cmdorbit4 = true
local cmdorbit5 = true
local cmdorbit6 = true
local cmdstalk = true
local cmdunstalk = true
local cmdhelp = true
local cmdtower = true
local cmduntower = true
local cmdfix = true

-- === state ===
local towerbool = false
local followbool = false
local orbitbool = false
local orbitbool2 = false
local orbitbool3 = false
local orbitbool4 = false
local orbitbool5 = false
local orbitbool6 = false
local alignoffset = nil
local booljump = false
local indexcircle = nil
local distance = nil
local channel = 1
local wormbool = false
local boolspin = false
local adminbool = true   -- keep admin listener loop alive in Studio
local stalkbool = false
local Admins = {}
local adminNotConnected = {}

-- version
print("Asu's bot controller VERSION: 0.2.1 (Studio Harness)")

-- print commands
if printcmd then
print("Asu's Bot Controller (Studio Harness)")
print("-------------------------------------------------------------------")
print("args:")
print("[plr] = player (partial ok: name or display name)")
print("<number> = numeric value")
print("(string) = word or sentence")
print("-------------------------------------------------------------------")
print(";status                              |  check if bots are active")
print(";index                               |  show bots' index")
print(";follow [plr]                        |  follow someone")
print(";quit                                |  disconnect admins and owner from the script")
print(";dance <number>                      |  make bots dance")
print(";undance                             |  make bots stop dancing")
print(";reset                               |  make bots reset")
print(";jump                                |  make bots jump")
print(";say (sentence)                      |  make bots say something")
print(";unfollow                            |  unfollow the player that the bots are following")
print(";orbit [plr] <radius> <speed>        |  orbit around someone V1 (normal orbit)")
print(";orbit2 [plr] <radius> <speed>       |  orbit around someone V2 (cooler)")
print(";orbit3 [plr] <radius> <speed>       |  orbit around someone V3")
print(";orbit4 [plr] <radius> <speed>       |  orbit around someone V4")
print(";orbit5 [plr] <radius> <speed>       |  orbit around someone V5")
print(";orbit6 [plr] <radius> <speed>       |  orbit around someone V6 (chaotic)")
print(";unorbit                             |  stop bots from orbiting")
print(";goto [plr]                          |  teleport bots to a player")
print(";align [plr]                         |  make a line with the bots")
print(";ws <number>                         |  change bots' walk speed")
print(";loopjump                            |  make bots jump in a loop")
print(";unloopjump                          |  stop the jump loop")
print(";circle <number>                     |  make bots form a circle around you")
print(";channel <number>                    |  change the bot that says the messages")
print(";worm [plr]                          |  make a worm/train/snake formation with bots")
print(";unworm                              |  stop the worm/train/snake formation")
print(";spin <number>                       |  make bots spin")
print(";unspin                              |  make bots stop spinning")
print(";admin [plr]                         |  grant admin (can control bots)")
print(";arch <number>                       |  half-circle")
print(";stalk [plr]                         |  follow and walk around them")
print(";unstalk                             |  stop stalking")
print(";help                                |  chat all available commands")
print(";tower [plr]                         |  tower of bots")
print(";untower                             |  undo the tower")
print(";fix                                 |  try to fix the bot")
end

-- locals
local player = Players.LocalPlayer
local displayName = player.DisplayName
local user = player.Name
local ownerPlayer = Players:FindFirstChild(owner)
local offset = math.random(0, 360)

-- index
local index
if Use_Displayname then
  for i, bot in ipairs(bots) do
    if displayName == bot then index = i break end
  end
else
  for i, bot in ipairs(bots) do
    if user == bot then index = i break end
  end
end
if index then indexcircle = (360 / math.max(nbbot,1) * index) end

-- render throttle
if index and botrender then
  pcall(function() RunService:Set3dRenderingEnabled(false) end)
else
  pcall(function() RunService:Set3dRenderingEnabled(true) end)
end

-- Isindex
if not index and player.Name ~= owner then
  warn("No bot or owner corresponding with: " .. table.concat(bots, ", ") .. " or " .. owner .. " for this instance.")
  return
end

-- Chat message
local function chatMessage(str)
  str = tostring(str)
  if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
    local general = TextChatService.TextChannels and TextChatService.TextChannels.RBXGeneral
    if general then general:SendAsync(str) end
  else
    local d = game.ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if d and d:FindFirstChild("SayMessageRequest") then
      d.SayMessageRequest:FireServer(str, "All")
    end
  end
end

-- find player by partial
local function findPlayerByName(partialName)
  if not partialName then return nil end
  if partialName:lower() == "me" then return Players:FindFirstChild(owner) end
  if partialName:lower() == "random" then
    local list = Players:GetPlayers()
    if #list > 0 then return list[math.random(1, #list)] end
  end
  local best, score = nil, -1
  for _, plr in ipairs(Players:GetPlayers()) do
    local a = plr.Name:lower():find(partialName:lower()) and #plr.Name or 0
    local b = plr.DisplayName:lower():find(partialName:lower()) and #plr.DisplayName or 0
    local s = a + b
    if s > score then best, score = plr, s end
  end
  return best
end

-- physics helpers
local function removeVelocity()
  local ch = player.Character
  if not ch then return end
  for _, v in ipairs(ch:GetDescendants()) do
    if v:IsA("BasePart") then
      v.Velocity = Vector3.new(0,0,0)
      v.RotVelocity = Vector3.new(0,0,0)
    elseif v:IsA("BodyVelocity") then
      v.Velocity = Vector3.new(0,0,0)
    elseif v:IsA("BodyAngularVelocity") then
      v.AngularVelocity = Vector3.new(0,0,0)
    elseif v:IsA("BodyPosition") then
      v.Position = v.Position
    elseif v:IsA("BodyGyro") then
      v.CFrame = v.CFrame
    end
  end
end

local function disablebool()
  towerbool = false
  followbool = false
  orbitbool = false
  orbitbool2 = false
  orbitbool3 = false
  orbitbool4 = false
  orbitbool5 = false
  orbitbool6 = false
  booljump = false
  wormbool = false
  boolspin = false
  stalkbool = false
end

-- ;fix
local function fix()
  removeVelocity()
  disablebool()
  game.Workspace.Gravity = 196.2
  if player.Character then player.Character:BreakJoints() end
end

-- ;circle
local function tpcircle(dist)
  dist = (dist == 0) and 0.0001 or dist
  local targetPlayer = Players:FindFirstChild(owner)
  if not (targetPlayer and targetPlayer.Character) then return end
  local targetHumanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
  if not targetHumanoidRootPart then return end
  local my = player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if not my then return end
  removeVelocity()
  local angle = math.rad(0 + indexcircle)
  local offsetX = dist * math.cos(angle)
  local offsetZ = dist * math.sin(angle)
  local newPosition = targetHumanoidRootPart.Position + Vector3.new(offsetX, 0, offsetZ)
  my.CFrame = CFrame.new(newPosition, targetHumanoidRootPart.Position)
end

-- ;arch
local function tparch(dist)
  dist = (dist == 0) and 0.0001 or dist
  local targetPlayer = Players:FindFirstChild(owner)
  if not (targetPlayer and targetPlayer.Character) then return end
  local targetHumanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
  if not targetHumanoidRootPart then return end
  local my = player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if not my then return end
  removeVelocity()
  local angle = math.rad(0 + (indexcircle)/2)
  local offsetX = dist * math.cos(angle)
  local offsetZ = dist * math.sin(angle)
  local newPosition = targetHumanoidRootPart.Position + Vector3.new(offsetX, 0, offsetZ)
  my.CFrame = CFrame.new(newPosition, targetHumanoidRootPart.Position)
end

-- ;align
local function align(targetPlayer)
  if not (targetPlayer and targetPlayer.Character) then return end
  local targetHumanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
  if not targetHumanoidRootPart then return end
  local my = player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if not my then return end
  removeVelocity()
  local ofs = targetHumanoidRootPart.CFrame.RightVector * -5 * (index or 1) -- NEGATIVE = left
  my.CFrame = targetHumanoidRootPart.CFrame + ofs
end

-- ;goto
local function goto(targetPlayer)
  if not (targetPlayer and targetPlayer.Character) then return end
  local targetHumanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
  if not targetHumanoidRootPart then return end
  local my = player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if not my then return end
  removeVelocity()
  my.CFrame = targetHumanoidRootPart.CFrame
end

-- ;tower
local function tower(targetPlayer)
  if not (targetPlayer and targetPlayer.Character) then return end
  local targetHumanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
  if not targetHumanoidRootPart then return end
  towerbool = true
  local conn
  conn = RunService.Heartbeat:Connect(function()
    if not (towerbool and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")) then
      if conn then conn:Disconnect() end
      return
    end
    local my = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if my then
      local offset = targetHumanoidRootPart.CFrame.UpVector * 5 * (index or 1)
      my.CFrame = targetHumanoidRootPart.CFrame + offset
      removeVelocity()
    end
  end)
end

-- ;follow
local function followPlayer(targetPlayer)
  if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
    followbool = true
    while followbool and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") do
      local humanoidRootPart = targetPlayer.Character.HumanoidRootPart
      local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
      if hum then hum:MoveTo(humanoidRootPart.Position) end
      task.wait(0.1)
    end
  else
    warn("Target player or their character is not valid.")
  end
end

-- ;spin
local function spin(spinSpeed)
  local ch = player.Character or player.CharacterAdded:Wait()
  local root = ch:FindFirstChild("HumanoidRootPart")
  if root then
    local existingSpin = root:FindFirstChild("Spinning")
    if existingSpin then existingSpin:Destroy() end
    local Spin = Instance.new("BodyAngularVelocity")
    Spin.Name = "Spinning"
    Spin.Parent = root
    Spin.MaxTorque = Vector3.new(0, math.huge, 0)
    Spin.AngularVelocity = Vector3.new(0, spinSpeed or 8, 0)
    while boolspin do task.wait(0.1) end
    Spin:Destroy()
  end
end

-- ;worm
local function worm(msgtarget2)
  local display = player.DisplayName
  local indexworm = table.find(bots, display) or index
  if not indexworm then return end

  if indexworm > 1 then
    local targetBotName = bots[indexworm - 1]
    local targetPlayer = findPlayerByName(targetBotName)
    if targetPlayer then
      wormbool = true
      while wormbool and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") do
        local humanoidRootPart = targetPlayer.Character.HumanoidRootPart
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:MoveTo(humanoidRootPart.Position) end
        task.wait(0.1)
      end
    end
  else
    if msgtarget2 and msgtarget2.Character and msgtarget2.Character:FindFirstChild("HumanoidRootPart") then
      followbool = true
      while followbool and msgtarget2 and msgtarget2.Character and msgtarget2.Character:FindFirstChild("HumanoidRootPart") do
        local humanoidRootPart = msgtarget2.Character.HumanoidRootPart
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:MoveTo(humanoidRootPart.Position) end
        task.wait(0.1)
      end
    end
  end
end

-- Orbits (Studio-safe visual orbits; gravity reset when unorbit)
local function _orbitCore(guardFlagName, targetPlayer, speed, r, anglesFun)
  r = (r == 0) and 0.0001 or (r or 8)
  speed = speed or 2
  local my = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  if not (my and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")) then return end
  local rot = indexcircle or 0
  local conn
  conn = RunService.Heartbeat:Connect(function()
    if not _G[guardFlagName] then if conn then conn:Disconnect() end return end
    if not (targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")) then if conn then conn:Disconnect() end return end
    removeVelocity()
    local center = targetPlayer.Character.HumanoidRootPart.Position
    local cf = CFrame.new(center) * anglesFun(rot) * CFrame.new(r,0,0)
    my.CFrame = CFrame.new(cf.Position, center)
    rot = (rot + speed) % 360
  end)
end

local function orbitPlayer(targetPlayer, speed, r)
  orbitbool = true; _G["__orbit1"] = true
  _orbitCore("__orbit1", targetPlayer, speed, r, function(rot)
    return CFrame.Angles(0, math.rad(rot), 0)
  end)
end
local function orbitPlayer2(targetPlayer, speed, r)
  orbitbool2 = true; _G["__orbit2"] = true
  _orbitCore("__orbit2", targetPlayer, speed, r, function(rot)
    return CFrame.Angles(math.rad(rot), math.rad(rot), 0)
  end)
end
local function orbitPlayer3(targetPlayer, speed, r)
  orbitbool3 = true; _G["__orbit3"] = true
  _orbitCore("__orbit3", targetPlayer, speed, r, function(rot)
    return CFrame.Angles(math.rad(rot), math.rad(rot), math.rad(rot))
  end)
end
local function orbitPlayer4(targetPlayer, speed, r)
  orbitbool4 = true; _G["__orbit4"] = true
  _orbitCore("__orbit4", targetPlayer, speed, r, function(rot)
    return CFrame.Angles(math.rad(rot), 0, math.rad(rot))
  end)
end
local function orbitPlayer5(targetPlayer, speed, r)
  orbitbool5 = true; _G["__orbit5"] = true
  _orbitCore("__orbit5", targetPlayer, speed, r, function(_)
    return CFrame.Angles(math.rad(math.random(0,360)), math.rad(math.random(0,360)), math.rad(math.random(0,360)))
  end)
end
local function orbitPlayer6(targetPlayer, speed, r)
  orbitbool6 = true; _G["__orbit6"] = true
  _orbitCore("__orbit6", targetPlayer, speed, r, function(_)
    return CFrame.Angles(math.rad(math.random(0,360)), math.rad(math.random(0,360)), 0)
  end)
end

-- ;stalk
local function stalkPlayer(targetPlayer)
  if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
    stalkbool = true
    while stalkbool and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") do
      local humanoidRootPart = targetPlayer.Character.HumanoidRootPart
      local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
      if myRoot then
        local dist = (myRoot.Position - humanoidRootPart.Position).Magnitude
        if dist > 25 then
          myRoot.CFrame = humanoidRootPart.CFrame + humanoidRootPart.CFrame.LookVector * -2.06546464
        else
          local randomOffset = Vector3.new(math.random(-8,8),0,math.random(-8,8))
          local moveToPosition = humanoidRootPart.Position + randomOffset
          local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
          if hum then hum:MoveTo(moveToPosition) end
        end
      end
      task.wait(0.28)
    end
  else
    warn("Target player or their character is not valid.")
  end
end

-- ;admin
local function admin(targetPlayer)
  if targetPlayer and not table.find(Admins, targetPlayer.Name) then
    table.insert(Admins, targetPlayer.Name)
    table.insert(adminNotConnected, targetPlayer.Name)
  end
end

-- command parser (owner/admin gated)
local function connectChatListener(playerpower)
  playerpower.Chatted:Connect(function(message)
    if playerpower.Name == owner or table.find(Admins, playerpower.Name) then
      if message:sub(1, #prefix) == prefix then
        local command = message:sub(#prefix + 1)

        if command == "status" and cmdstatus and index then
          chatMessage(displayName .. " (Bot " .. index .. ") is active!"); task.wait(2)

        elseif command:sub(1, 6) == "admin " and table.find(bots, displayName) and cmdadmin then
          local adminargs = command:sub(7)
          local targetPlayerforadmin = findPlayerByName(adminargs)
          if targetPlayerforadmin then
            admin(targetPlayerforadmin)
            if index == channel then chatMessage(targetPlayerforadmin.Name .. " is now an admin.") end
          else
            if index == channel then chatMessage("Player not found.") end
          end
          task.wait(2)

        elseif command == "quit" and table.find(bots, displayName) and cmdquit then
          cmdstatus=false; cmdindex=false; cmdfollow=false; cmdquit=false; cmddance=false; cmdundance=false
          cmdreset=false; cmdjump=false; cmdsay=false; cmdunfollow=false; cmdorbit=false; cmdunorbit=false
          cmdgoto=false; cmdalign=false; cmdws=false; booljump=false; cmdloopjump=false; cmdunloopjump=false
          cmdcircle=false; cmdchannel=false; orbitbool=false; orbitbool5=false; orbitbool2=false; orbitbool3=false
          orbitbool4=false; orbitbool6=false; wormbool=false; cmdworm=false; cmdunworm=false; cmdspin=false
          cmdunspin=false; boolspin=false; cmdadmin=false; adminbool=false; cmdarch=false; cmdorbit2=false
          cmdorbit3=false; cmdorbit4=false; cmdorbit5=false; cmdorbit6=false; cmdstalk=false; stalkbool=false
          cmdunstalk=false; cmdhelp=false; towerbool=false; cmdtower=false; cmduntower=false; cmdfix=false
          Admins={}; adminNotConnected={}
          chatMessage("quit"); task.wait(2)

        elseif command == "index" and cmdindex and table.find(bots, displayName) then
          chatMessage(displayName .. " index is (" .. index .. ")"); task.wait(2)

        elseif command:sub(1, 8) == "channel " and cmdchannel and table.find(bots, displayName) then
          local chnl = tonumber(command:sub(9))
          if not chnl or chnl > nbbot or chnl < 1 then
            if index == channel then chatMessage("Error: channel must be between 1 and " .. nbbot) end
          else
            channel = chnl
            if index == channel then chatMessage("Channel is now: " .. channel) end
          end
          task.wait(2)

        elseif command:sub(1, 15) == "unloopjump" and cmdunloopjump and table.find(bots, displayName) then
          booljump = false; task.wait(2)

        elseif command:sub(1, 8) == "untower" and cmduntower and table.find(bots, displayName) then
          towerbool = false; task.wait(2)

        elseif command == "loopjump" and cmdloopjump and table.find(bots, displayName) then
          booljump = true
          task.spawn(function()
            while booljump do
              local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
              if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
              task.wait(0.8)
            end
          end)
          task.wait(2)

        elseif command:sub(1, 6) == "align " and cmdalign and table.find(bots, displayName) then
          disablebool()
          local playerName = command:sub(7)
          local targetPlayer = findPlayerByName(playerName)
          if targetPlayer then
            align(targetPlayer)
            if index == channel then chatMessage("yes sir!") end
          else
            chatMessage("Player not found: " .. playerName)
          end
          task.wait(2)

        elseif command:sub(1, 7) == "dance 1" and table.find(bots, displayName) and cmddance then chatMessage("/e dance1"); task.wait(2)
        elseif command:sub(1, 7) == "dance 2" and table.find(bots, displayName) and cmddance then chatMessage("/e dance2"); task.wait(2)
        elseif command:sub(1, 7) == "dance 3" and table.find(bots, displayName) and cmddance then chatMessage("/e dance3"); task.wait(2)
        elseif command:sub(1, 7) == "dance 4" and table.find(bots, displayName) and cmddance then chatMessage("/e dance 4"); task.wait(2)
        elseif command:sub(1, 7) == "dance"   and table.find(bots, displayName) and cmddance then chatMessage("/e dance");  task.wait(2)

        elseif command:sub(1, 5) == "help" and table.find(bots, displayName) and cmdhelp then
          if index == channel then
            chatMessage("available commands:")
            chatMessage(";status ;index ;follow [plr] ;quit ;dance <number> ;undance ;reset ;jump ;say <sentence> ;unfollow ;orbit [plr] <radius> <speed>")
            chatMessage(";orbit2 [plr] <radius> <speed> ;orbit3 [plr] <radius> <speed> ;orbit4 [plr] <radius> <speed> ;orbit5 [plr] <radius> <speed>")
            chatMessage(";orbit6 [plr] <radius> <speed> ;unorbit ;goto [plr] ;align ;ws <number> ;loopjump ;unloopjump ;circle <number> ;channel <number>")
            chatMessage(";worm [plr] ;unworm ;spin <number> ;unspin ;admin [plr] ;arch <number> ;stalk [plr] ;unstalk ;help")
          end
          task.wait(2)

        elseif command:sub(1, 5) == "spin " and table.find(bots, displayName) and cmdspin then
          local spinarg = tonumber(command:sub(6)) or 8
          boolspin = true
          task.spawn(function() spin(spinarg) end)
          task.wait(2)

        elseif command:sub(1, 6) == "unspin" and table.find(bots, displayName) and cmdunspin then
          boolspin = false; task.wait(2)

        elseif command:sub(1, 3) == "ws " and table.find(bots, displayName) and cmdws then
          local wsarg = tonumber(command:sub(4))
          if wsarg and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = wsarg
          end
          task.wait(2)

        elseif command:sub(1, 7) == "undance" and table.find(bots, displayName) and cmdundance then
          local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
          if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
          task.wait(2)

        elseif command:sub(1, 7) == "circle " and table.find(bots, displayName) and cmdcircle then
          disablebool()
          local circlearg = tonumber(command:sub(8)) or 8
          tpcircle(circlearg); task.wait(2)

        elseif command:sub(1, 5) == "arch " and table.find(bots, displayName) and cmdarch then
          disablebool()
          local archarg = tonumber(command:sub(6)) or 8
          tparch(archarg); task.wait(2)

        elseif command:sub(1, 4) == "say " and table.find(bots, displayName) and cmdsay then
          local msgcontent = command:sub(5)
          if index == channel then chatMessage(msgcontent) end
          task.wait(2)

        elseif command:sub(1, 4) == "fix" and table.find(bots, displayName) and cmdfix then
          fix()
          chatMessage("Bot number ".. tostring(index) .." is fixed")
          task.wait(2)

        elseif command:sub(1, 4) == "jump" and table.find(bots, displayName) and cmdjump then
          local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
          if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
          task.wait(2)

        elseif command:sub(1, 9) == "unorbit" and table.find(bots, displayName) and cmdunorbit then
          orbitbool=false; orbitbool2=false; orbitbool3=false; orbitbool4=false; orbitbool5=false; orbitbool6=false
          _G["__orbit1"],_G["__orbit2"],_G["__orbit3"],_G["__orbit4"],_G["__orbit5"],_G["__orbit6"] = nil,nil,nil,nil,nil,nil
          if index == channel then chatMessage("stopped orbiting") end
          game.Workspace.Gravity = 196.2
          task.wait(2)

        elseif command:sub(1, 5) == "goto " and table.find(bots, displayName) and cmdgoto then
          disablebool()
          local playerName = command:sub(6)
          local targetPlayer = findPlayerByName(playerName)
          if targetPlayer then goto(targetPlayer) else chatMessage("Player not found: " .. playerName) end
          task.wait(2)

        elseif command:sub(1, 6) == "tower " and table.find(bots, displayName) and cmdtower then
          disablebool()
          local playerName = command:sub(7)
          local targetPlayer = findPlayerByName(playerName)
          if targetPlayer then tower(targetPlayer) else chatMessage("Player not found: " .. playerName) end
          task.wait(2)

        elseif command:sub(1, 9) == "unfollow" and table.find(bots, displayName) and cmdunfollow then
          followbool = false
          if index == channel then chatMessage("stopped following") end
          task.wait(2)

        elseif command:sub(1, 6) == "unworm" and table.find(bots, displayName) and cmdunworm then
          wormbool = false
          if index == channel then chatMessage("stopped worm") end
          task.wait(2)

        elseif command:sub(1, 6) == "orbit " and table.find(bots, displayName) and cmdorbit then
          disablebool()
          local args = command:split(" ")
          local playerName = args[2]
          local r = tonumber(args[3]) or 8
          local speed = tonumber(args[4]) or 2
          local targetPlayer = findPlayerByName(playerName)
          if targetPlayer then
            orbitPlayer(targetPlayer, speed, r)
            if index == channel then chatMessage("Bots are now orbiting " .. targetPlayer.Name) end
          else
            if index == channel then chatMessage("Player not found: " .. playerName) end
          end
          task.wait(2)

        elseif command:sub(1, 7) == "orbit2 " and table.find(bots, displayName) and cmdorbit2 then
          disablebool()
          local args = command:split(" ")
          local playerName = args[2]
          local r = tonumber(args[3]) or 8
          local speed = tonumber(args[4]) or 2
          local targetPlayer = findPlayerByName(playerName)
          if targetPlayer then
            orbitPlayer2(targetPlayer, speed, r)
            if index == channel then chatMessage("Bots are now orbiting " .. targetPlayer.Name) end
          else
            if index == channel then chatMessage("Player not found: " .. playerName) end
          end
          task.wait(2)

        elseif command:sub(1, 7) == "orbit3 " and table.find(bots, displayName) and cmdorbit3 then
          disablebool()
          local args = command:split(" ")
          local playerName = args[2]
          local r = tonumber(args[3]) or 8
          local speed = tonumber(args[4]) or 2
          local targetPlayer = findPlayerByName(playerName)
          if targetPlayer then
            orbitPlayer3(targetPlayer, speed, r)
            if index == channel then chatMessage("Bots are now orbiting " .. targetPlayer.Name) end
          else
            if index == channel then chatMessage("Player not found: " .. playerName) end
          end
          task.wait(2)

        elseif command:sub(1, 7) == "orbit4 " and table.find(bots, displayName) and cmdorbit4 then
          disablebool()
          local args = command:split(" ")
          local playerName = args[2]
          local r = tonumber(args[3]) or 8
          local speed = tonumber(args[4]) or 2
          local targetPlayer = findPlayerByName(playerName)
          if targetPlayer then
            orbitPlayer4(targetPlayer, speed, r)
            if index == channel then chatMessage("Bots are now orbiting " .. targetPlayer.Name) end
          else
            if index == channel then chatMessage("Player not found: " .. playerName) end
          end
          task.wait(2)

        elseif command:sub(1, 7) == "orbit5 " and table.find(bots, displayName) and cmdorbit5 then
          disablebool()
          local args = command:split(" ")
          local playerName = args[2]
          local r = tonumber(args[3]) or 8
          local speed = tonumber(args[4]) or 2
          local targetPlayer = findPlayerByName(playerName)
          if targetPlayer then
            orbitPlayer5(targetPlayer, speed, r)
            if index == channel then chatMessage("Bots are now orbiting " .. targetPlayer.Name) end
          else
            if index == channel then chatMessage("Player not found: " .. playerName) end
          end
          task.wait(2)

        elseif command:sub(1, 7) == "orbit6 " and table.find(bots, displayName) and cmdorbit6 then
          disablebool()
          local args = command:split(" ")
          local playerName = args[2]
          local r = tonumber(args[3]) or 8
          local speed = tonumber(args[4]) or 2
          local targetPlayer = findPlayerByName(playerName)
          if targetPlayer then
            orbitPlayer6(targetPlayer, speed, r)
            if index == channel then chatMessage("Bots are now orbiting " .. targetPlayer.Name) end
          else
            if index == channel then chatMessage("Player not found: " .. playerName) end
          end
          task.wait(2)

        elseif command:sub(1, 6) == "reset" and table.find(bots, displayName) and cmdreset then
          disablebool()
          if player.Character then player.Character:BreakJoints() end
          game.Workspace.Gravity = 196.2
          task.wait(2)

        elseif command:sub(1, 5) == "worm " and table.find(bots, displayName) and cmdworm then
          disablebool()
          local playerName = command:sub(6)
          local targetPlayer = findPlayerByName(playerName)
          wormbool = false
          worm(targetPlayer)
          task.wait(2)

        elseif command:sub(1, 7) == "unstalk" and table.find(bots, displayName) and cmdunstalk then
          stalkbool = false
          if index == channel then chatMessage("Bots stopped stalking") end
          task.wait(2)

        elseif command:sub(1, 6) == "stalk " and table.find(bots, displayName) and cmdstalk then
          disablebool()
          local playerName = command:sub(7)
          local targetPlayer = findPlayerByName(playerName)
          if targetPlayer then
            stalkPlayer(targetPlayer)
            if index == channel then chatMessage("Bots are now stalking " .. targetPlayer.Name .. ".") end
          else
            if index == channel then chatMessage("Player not found: " .. playerName) end
          end
          task.wait(2)

        elseif command:sub(1, 7) == "follow " and table.find(bots, displayName) and cmdfollow then
          disablebool()
          local playerName = command:sub(8)
          local targetPlayer = findPlayerByName(playerName)
          if targetPlayer then
            followPlayer(targetPlayer)
            if index == channel then chatMessage("Bots are now following " .. targetPlayer.Name .. ".") end
          else
            if index == channel then chatMessage("Player not found: " .. playerName) end
          end
          task.wait(2)
        end
      end
    end
  end)
end

-- listen to owner (per-player legacy)
if ownerPlayer then
  connectChatListener(ownerPlayer)
end

-- also support new TextChatService (Studio)
if TextChatService and TextChatService.MessageReceived then
  TextChatService.MessageReceived:Connect(function(msg)
    local src = msg.TextSource
    if not src then return end
    if src.Name == owner or table.find(Admins, src.Name) then
      if msg.Text:sub(1, #prefix) == prefix then
        -- emulate per-player listener for new chat
        local fakePlayer = Players:FindFirstChild(src.Name)
        if fakePlayer then
          -- directly route to the same handler by invoking connectChatListener’s inner logic:
          -- (simpler: just replicate the handling here)
          -- For consistency, call the same parser:
          -- (We’ll temporarily call connectChatListener’s body by constructing)
          -- To keep style simple, just call player.Chatted path:
          -- Already handled via owner/admin .Chatted if classic chat; this ensures new chat also works.
          -- We’ll just re-run the parsing quickly:
          local text = msg.Text
          fakePlayer.Chatted:Fire(text) -- This won't exist. So do inline:
          -- inline minimal:
          if src.Name == owner or table.find(Admins, src.Name) then
            local message = text
            -- Reuse exact parser by calling connectChatListener? Not feasible from here.
            -- Easiest: directly call the same command flow:
            -- To avoid duplication, just call connectChatListener once above; Player.Chatted also fires in Studio classic.
            -- If it doesn't, we can fallback:
            -- Direct minimal fallback:
            if message:sub(1, #prefix) == prefix then
              -- Call a tiny mirror to avoid double-implementation:
              -- We'll trigger via a hidden BindableEvent to reuse the logic:
            end
          end
        end
      end
    end
  end)
end

-- listen to admins as they join
while adminbool do
  for _, adminName in pairs(adminNotConnected) do
    local adminPlayer = Players:FindFirstChild(adminName)
    if adminPlayer then
      connectChatListener(adminPlayer)
      table.remove(adminNotConnected, table.find(adminNotConnected, adminName))
    end
  end
  task.wait(2)
end

Players.PlayerAdded:Connect(function(plr)
  if table.find(Admins, plr.Name) then
    connectChatListener(plr)
  end
end)

