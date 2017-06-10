--[[
Matt Kirk's SMB Q-Learning agent using original SMB ROM

]]--


--------------------------------
--Player's Inputs Mapping Table.
--------------------------------

-- TODO: figure out how to make sure you're not doing actions while not in a
-- map
actions = {}
clear_input = {right=false,A=false,B=false}
currentAction = 1
actions[1] = {right=false,A=false,B=false} --stay_put
actions[2] = {right=true,B=true,A=true} -- sprint_jump
actions[3] = {right=true,B=true} --springright
actions[4] = {left=true,B=true} --sprint_left
actions[5] = {right=true,B=true} --rightfire
actions[6] = {left=true,B=true} --leftfire
actions[7] = {A=true} --jump
actions[8] = {B=true} --fire
actions[9] = {right=true} --right
actions[10] = {left=true} --left
actions[11] = {down=true} --down


---------------------------
--Defining Colors Constants.
---------------------------
backGroundColorRGB = "#5C94FC"
foreGroundColorRGB = "#000000"
stateGridColorRGB = "#F0F0F0"

-----------------
--Player's States.
-----------------
FireMario = false
SuperMario = false
SmallMario = false
marioX = 0
lastMarioX = 0

--------------------------
--Bool to Check Direction.
--------------------------
continue_forward = true

-------------------
--Player's Velocity.
-------------------
velocity = 0x009F


-------------------
--Setting Velocity.
-------------------
function setVelocity(speed)
    memory.writebyte(velocity, speed)
end

-----------------------------
--Delays for n amount of time.
-----------------------------
function delayFrameInterval(n)
    local t = os.clock()
    while os.clock() - t <= n do

		--Dont Skip Printing.
        printBotName()
        printEnemyNameAndState()

        -- skips frame.
        emu.frameadvance()
    end
end


------------------------
--Enemy object constants
------------------------
GreenKoopa = 0x0
BuzzyBeetle = 0x2
RedKoopa = 0x3
HammerBro = 0x5
Goomba = 0x6
Bloober = 0x7
BulletBill_FrenzyVar = 0x8
StaticParatroopa = 0x09
GreyCheepCheep = 0x0a
RedCheepCheep = 0x0b
Podoboo = 0x0c
PiranhaPlant = 0x0d
GreenParatroopaJump = 0x0e
RedParatroopa = 0x0f
GreenParatroopaFly = 0x10
Lakitu = 0x11
Spiny = 0x12
FlyCheepCheepFrenzy = 0x14
FlyingCheepCheep = 0x14
BowserFlame = 0x15
Fireworks = 0x16
BBill_CCheep_Frenzy = 0x17
Stop_Frenzy = 0x18
Bowser = 0x2d
PowerUpObject = 0x2e
VineObject = 0x2f
FlagpoleFlagObject = 0x30
StarFlagObject = 0x31
JumpspringObject = 0x32
BulletBill_CannonVar = 0x33
RetainerObject = 0x35
UpLift			 = 0x26
DownLift = 0x27
Half_lift_Up		 = 0x2B
Half_lift_Down = 0x2C

-----------------------
--Names of All Enemies.
-----------------------
EnemyNameslist = {}
EnemyNameslist[GreenKoopa] = "Koopa"
EnemyNameslist[BuzzyBeetle] = "BuzzyBeetle"
EnemyNameslist[RedKoopa] = "Koopa"
EnemyNameslist[HammerBro] = "HammerBro"
EnemyNameslist[Goomba] = "Goomba"
EnemyNameslist[Bloober] = "Bloober"
EnemyNameslist[BulletBill_FrenzyVar] = "BulletBill"
EnemyNameslist[StaticParatroopa] = "Paratroopa"
EnemyNameslist[GreyCheepCheep] = "CheepCheep"
EnemyNameslist[RedCheepCheep] = "CheepCheep"
EnemyNameslist[Podoboo] = "Podoboo"
EnemyNameslist[PiranhaPlant] = "Piranha Plant"
EnemyNameslist[GreenParatroopaJump] = "Paratroopa Jump"
EnemyNameslist[RedParatroopa] = "Paratroopa"
EnemyNameslist[GreenParatroopaFly] = "Paratroopa Fly"
EnemyNameslist[Lakitu] = "Lakitu"
EnemyNameslist[Spiny] = "Spiny"
EnemyNameslist[FlyCheepCheepFrenzy] = "Fly CheepCheep"
EnemyNameslist[FlyingCheepCheep] = "Fly CheepCheep"
EnemyNameslist[BowserFlame] = "Bowser's Flame"
EnemyNameslist[BBill_CCheep_Frenzy] = "BulletBill"
EnemyNameslist[Bowser] = "Bowser"
EnemyNameslist[BulletBill_CannonVar] = "BulletBill"

------------------------
--Enemy states Constants.
------------------------
alive_enemy = 0x0 --Enemy drawn / Alive.
falling_enemy = 0x01 -- or Bullet_Bill drawn(not killed yet).
enemy_stomped_1 = 0x02 --Goomba Stomped while falling.
enemy_stomped_2 = 0x03 --Goomba Stomped while falling.
enemy_stomped_3 = 0x04 --Goomba Stomped while falling.
spiny_falling = 0x05 --Spiny Falling from Lakitu.
hammerbro_Moving_1 = 0x8 --HammerBro Moving back & forth.
hammerbro_Moving_2 = 0x9 --HammerBro Moving back & forth.
bullet_cheep_hammer_stomped = 0x20 --BulletBill/HammerBro/Cheep stopmed or Real Bowser Killed
killed_with_fire_star = 0x22 --Killed with FireBall or by StarMan.
fakeBowser_killed = 0x23 --FakeBowser Appears in world 1 to world 7.
koopa_stomped_falling = 0xC4 --Koopa Stomped while falling from Paratroopa state.
koopa_stomped_moving_upsideDown = 0x83 --Koopa Moving upside down.
koopa_buzzyBeetle_stomped_moving = 0x84 --Koopa or BuzzyBeetle stopmed and pushed.

----------------------------
--Names of All Enemies State.
----------------------------

EnemyStatelist = {}
EnemyStatelist[alive_enemy] = "Alive"
EnemyStatelist[falling_enemy] = "Alive"
-- Technically speaking koopas can get stomped and still be alive...
EnemyStatelist[enemy_stomped_1] = "Killed"
EnemyStatelist[enemy_stomped_2] = "Killed"
EnemyStatelist[enemy_stomped_3] = "Killed"
EnemyStatelist[spiny_falling] = "Alive"
EnemyStatelist[hammerbro_Moving_1] = "Alive"
EnemyStatelist[hammerbro_Moving_2] = "Alive"
EnemyStatelist[bullet_cheep_hammer_stomped] = "Alive"
EnemyStatelist[killed_with_fire_star] = "Killed"
EnemyStatelist[fakeBowser_killed] = "Killed"
EnemyStatelist[koopa_stomped_falling] = "Alive"
EnemyStatelist[koopa_stomped_moving_upsideDown] = "Alive"
EnemyStatelist[koopa_buzzyBeetle_stomped_moving] = "Alive"

function killDelta(_eState)
  for slot=0,4 do
    enemy_state_slot = 0x001E -- enemy states range from 0x001E to 0x0023
    local enemy_state = memory.readbyte(enemy_state_slot + slot)

    local killedThisFrame = (enemy_state == enemy_stomped_1)
        or (enemy_state == enemy_stomped_2)
        or (enemy_state == enemy_stomped_3)
        or (enemy_state == bullet_cheep_hammer_stomped)
        or (enemy_state == killed_with_fire_star)
        or (enemy_state == fakeBowser_killed)

    if (killedThisFrame) then
      return 1
    end
  end
  return 0
end

-------------------------
--Checking State of Enemy.
-------------------------
function checkEnemyState(_eState)

    enemy_state_slot = 0x001E -- 5x Enemy States Range from (0x001E to 0x0023)
    local enemy_state = memory.readbyte(enemy_state_slot + _eState)

    --C-Type Ternary Operators.
    return
	   (enemy_state == alive_enemy) and alive_enemy
    or (enemy_state == falling_enemy) and falling_enemy
    or (enemy_state == enemy_stomped_1) and enemy_stomped_1
    or (enemy_state == enemy_stomped_2) and enemy_stomped_2
    or (enemy_state == enemy_stomped_3) and enemy_stomped_3
    or (enemy_state == spiny_falling ) and spiny_falling
    or (enemy_state == hammerbro_Moving_1 ) and hammerbro_Moving_1
    or (enemy_state == hammerbro_Moving_2) and hammerbro_Moving_2
    or (enemy_state == bullet_cheep_hammer_stomped) and bullet_cheep_hammer_stomped
    or (enemy_state == killed_with_fire_star) and killed_with_fire_star
    or (enemy_state == fakeBowser_killed) and fakeBowser_killed
    or (enemy_state == koopa_stomped_falling) and koopa_stomped_falling
    or (enemy_state == koopa_buzzyBeetle_stomped_moving) and koopa_buzzyBeetle_stomped_moving
end

----------------------------------------
--Get EnemyStateName from EnemyStatelist.
----------------------------------------
function getEnemyStateName(enemy_state)

    return EnemyStatelist[enemy_state]

end

-------------------------
--Checking Type of Enemy.
-------------------------
function checkEnemyID(_enemy_id)

    local Enemy_ID = memory.readbyte(0x0016 + _enemy_id)

    --C-Type Ternary Operators.
    return
	   (Enemy_ID == Goomba) and Goomba
    or (Enemy_ID == GreenKoopa) and GreenKoopa
    or (Enemy_ID == RedKoopa) and RedKoopa
    or (Enemy_ID == BuzzyBeetle) and BuzzyBeetle
    or (Enemy_ID == GreenParatroopaFly) and GreenParatroopaFly
    or (Enemy_ID == GreenParatroopaJump) and GreenParatroopaJump
    or (Enemy_ID == RedParatroopa) and RedParatroopa
    or (Enemy_ID == PiranhaPlant) and PiranhaPlant
    or (Enemy_ID == BulletBill_CannonVar) and BulletBill_CannonVar
    or (Enemy_ID == HammerBro) and HammerBro
    or (Enemy_ID == Lakitu) and Lakitu
    or (Enemy_ID == Bowser) and Bowser
    or (Enemy_ID == UpLift) and UpLift
    or (Enemy_ID == DownLift) and DownLift
    or (Enemy_ID == JumpspringObject) and JumpspringObject
    or (Enemy_ID == FlagpoleFlagObject) and FlagpoleFlagObject
end

-----------------------------------
--Get EnemyName from EnemyNameslist.
------------------------------------
function getEnemyName(Enemy_ID)

    return EnemyNameslist[Enemy_ID]

end


-- -----------------------------------------------------
-- --Get Enemy's x and y position if they are drawn yet.
-- -----------------------------------------------------
-- function getEnemySprites()
--     local EnemySprites = {}
--     for slot=0,4 do
--         local enemy = memory.readbyte(0xF+slot)
--         if enemy ~= 0 then
--             local ex = memory.readbyte(0x6E + slot)*0x100 + memory.readbyte(0x87+slot)
--             local ey = memory.readbyte(0xCF + slot)+24
--             EnemySprites[#EnemySprites+1] = {["x"]=ex,["y"]=ey}
--         end
--     end
--
--     return EnemySprites
-- end

LastCoins = 0
function getCoinDelta()
  local p1_coins_x9 = memory.readbyte(0x07ED)
  local p1_coins_9x = memory.readbyte(0x07EE)

  local currentCoins = (p1_coins_x9 * 10 + p1_coins_9x)
  local coinDelta = currentCoins - LastCoins
  LastCoins = currentCoins
  return coinDelta
end

---------------------------------------------------
--Get Player's x and y position with screen offset.
---------------------------------------------------
function getPlayerPosition()
    if (marioX > lastMarioX) then
      lastMarioX = marioX
    end
    marioX = memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86)
    marioY = memory.readbyte(0x03B8)+16


    screenX = memory.readbyte(0x03AD)
    screenY = memory.readbyte(0x03B8)
    emu.print(string.format("screenX: %d screeny: %d enemyx: %d", screenX, screenY, memory.readbyte(0x0087)))
    --emu.print(screenX - marioX)
    --emu.print(screenY - marioY)
end

---------------------------------------------------
--Checking for Collision with Object Pipe / Brick ?
---------------------------------------------------
function playerObjectCollision()

    local playerCollisionBits = memory.readbyte(0x0490)
    local collided = 0xFE

    if(playerCollisionBits == collided)then
        return true
    end

    --OtherWise.
    return false
end


---------------------------------
--Checking Miscellaneous Objects.
---------------------------------
function checkMiscObj()

    for misc_slot = 0,4 do
        if(checkEnemyID(misc_slot) == JumpspringObject or checkEnemyID(misc_slot) == StarFlagObject or
		   checkEnemyID(misc_slot) == FlagpoleFlagObject or checkEnemyID(misc_slot) == RetainerObject or
		   checkEnemyID(misc_slot) == Fireworks) then

		 return true
        end
    end

	--OtherWise
	return false
end


------------------
--Prints Bot Name.
------------------
function printBotName()
    gui.text(19,16,"Q", "white" , "#5C94FC")
    gui.text(68,16,"BOT", "white" , "#5C94FC")
end

-----------------
-- Print Reward for State
-- Calculated as
-- Reward = 0
-- Reward += 0.75 Positive Progress Delta
-- Reward += -Negative Progress Delta
-- Reward += 50 * MarioStatusDelta
-- Reward += 50 * EnemyKillsDelta
-- Reward += 50 * PowerupsDelta
-- Reward += 25 * CoinsDelta
-- Reward -= 1000 * IfDied
-- Reward -= 0.5 (Don't wait around ya dingus)
-----------------

-- TODO: Make this transfer across levels.
LastPlayerStatus = 0

function printReward()
  getPlayerPosition()

  --Small Mario : Size = 1, Status = 0
  --Super Mario : Size = 0, Status = 1
  --Fire Mario : Size = 0, Status = 2

  -- local PlayerSize = memory.readbyte(0x0754)
  local PlayerStatus = memory.readbyte(0x0756)

  local statusChange = PlayerStatus - LastPlayerStatus
  LastPlayerStatus = PlayerStatus

  local reward = 0.0
  local progress = marioX - lastMarioX

  -- Progress in level
  if (progress > 0) then
    reward = reward + 0.75 * progress
  else
    reward = reward + progress
  end

  reward = reward + (50 * statusChange)

  -- Reward += 50 * EnemyKillsDelta

  -- Reward += 50 * PowerupsDelta

  if (isPlayerDead()) then
    reward = reward - 1000
  end

  local coinDelta = getCoinDelta()

  -- TODO: Koopas incorrectly are marked as killed when they can come back to life
  -- Also killing goombas with a koopa doesn't seem to work either.
  -- Lastly the kill delta seems to hang around for a while.
  local killDelta = killDelta()

  reward = reward + (50 * killDelta)

  reward = reward + (25 * coinDelta)

  reward = reward - 0.5

  gui.text(8, 36, string.format("Reward: %d State: %s, KillDelta: %d", reward, PlayerStatus, killDelta),foreGroundColorRGB,backGroundColorRGB)
  return reward
end


------------------------------
-- Print Current Map State
-----------------------------
function sumf(a, ...) return a and a + sumf(...) or 0 end
function sumt(t) return sumf(unpack(t)) end

function printCurrentMapState()
  -- 0x0500-0x069F
  local p = 16777619
  local hash = 2166136261

  getPlayerPosition()

  local stateVector = {}

  for tile=0x0500, 0x069F do
    hash = hash * p
    hash = bit.bxor(hash, memory.readbyte(tile))
    -- hash = (hash ^ memory.readbyte(tile)) * p
    -- stateVector[tile - 0x0500] = memory.readbyte(tile)
  end

  -- for enemy=0x006E,0x0072 do
  --   hash = hash * p
  --   hash = bit.bxor(hash, memory.readbyte(enemy))
  -- end

  for enemy=0x0087,0x008B do
    hash = hash * p
    hash = bit.bxor(hash, memory.readbyte(enemy))
  end

  hash = hash * p
  hash = bit.bxor(hash, screenX)
  -- hash = hash * p
  -- hash = bit.bxor(hash, screenY)

  --hash = hash + bit.lshift(hash, 13)
  --hash = hash ^ bit.rshift(hash,7)
  --hash = hash + bit.lshift(hash,3)
  --hash = hash ^ bit.rshift(hash, 17)
  --hash = hash + bit.lshift(hash, 5)

  gui.text(8, 36 + 8, string.format("MapState: %s", hash), foreGroundColorRGB, backGroundColorRGB)

  return hash
end

------------------------------
--Prints Enemy Name And State.
------------------------------
function printEnemyNameAndState()
    for slot = 0,4 do --5 Enemies per page.
        if (memory.readbyte(0x0F + slot) > 0) then
            eType = memory.readbyte(0x0016 + slot)
            eName = (getEnemyName(eType) ~= nil or (checkMiscObj() == false)) and getEnemyName(eType) or "No Enemy" --For Miscellaneous/Unknown Objects.

			    if (eName ~= "No Enemy") then
				    state = memory.readbyte(0x001E + slot)
				    eState = getEnemyStateName(state) and getEnemyStateName(state) or "Void State" --For Miscellaneous/Unknown States.
          end

          if (eState == "Void State")then
            emu.print("Void State : ",state)
          end

			  else
				  --For Empty Enemy Slots.
				  eName = "No Enemy"
				  eState = "Nil State"
			  end

		    --Prints Enemy name and state.
        gui.text(8, 36 + ((slot + 1) * 8), string.format("Enemy %d : %s, State : %s", slot + 1, eName, eState), foreGroundColorRGB, backGroundColorRGB)
   end
end

----------------------------
--Checking Here for PowerUp.
----------------------------
function checkPowerUp()

    --Powerup type (when on screen)
    --0 - Mushroom
    --1 - Flower
    --2 - Star
    --3 - 1up

    --PowerUpDrawn
    --0 - No
    --1 - Yes

    --[[
    Powerup on screen
    0x00 - No
    0x2E - Yes
    ]]--

    --[[
    Shroom heading
    1 - Right
    2 - Left
    ]]--

    --.db $47, $47, $47, $47 brick (power-up)


    local PowerUpType = 0x0039
    local PowerUpObject = 0x002e
    local PowerUpDrawn = 0x0014
    local ShroomHeading = 0x004B
    local Powerup_on_screen = 0x001B
	  local shroom_left = 0x02
	  local shroom_right = 0x01

	--------------------------------
	--Checking For Mushroom PowerUp.
	--------------------------------
    if(memory.readbyte(PowerUpDrawn) == 0x1 and memory.readbyte(PowerUpType) == 0x00 and memory.readbyte(Powerup_on_screen) == 0x2E)then

        continue_forward = false
		memory.writebyte(0x0057,0x0) --Set Player's Speed to 0.

        if(memory.readbyte(ShroomHeading) == shroom_right and memory.readbyte(PowerUpDrawn) == 0x1)then

            while(checkPlayerState() ~= SuperMario and memory.readbyte(PowerUpDrawn) == 0x1) do

                joypad.set(1,sprint_right)
				emu.frameadvance()

				if(memory.readbyte(ShroomHeading) == shroom_left)then
					break
				end

				----------------------------------------------------
				--Checking if Enemy is present while taking PowerUp.
				----------------------------------------------------
				if(checkEnemyState(0x0) == alive_enemy or checkEnemyState(0x01) == alive_enemy)then
					joypad.set(1,sprint_jump)

				emu.frameadvance()
				end

            end

        else if(memory.readbyte(ShroomHeading) == shroom_left and memory.readbyte(PowerUpDrawn) == 0x1)then

                while(checkPlayerState() ~= SuperMario and memory.readbyte(PowerUpDrawn) == 0x1) do

                    joypad.set(1,sprint_left)
                    emu.frameadvance()

					if(memory.readbyte(ShroomHeading) == shroom_right)then
						break
					end

					----------------------------------------------------
					--Checking if Enemy is present while taking PowerUp.
					----------------------------------------------------
					if(checkEnemyState(0x0) == alive_enemy or checkEnemyState(0x01) == alive_enemy)then
						joypad.set(1,sprint_jump)

					 emu.frameadvance()
				 end

                end

            end

        end

		else
        continue_forward = true
    end

    --TODO Check for other PowerUps also.
end

---------------------------
--Clearig JoyPad on Death.
---------------------------
function clearJoyPad()

 local OperMode_Task = 0x0772

 --Clear Joypad untill loading screen appears.
 while(memory.readbyte(OperMode_Task)~= 0x0) do
	joypad.set(1,clear_input)
	emu.frameadvance()
  end

 end

-----------------------------
--Checking if player is dead
-----------------------------
function isPlayerDead()

local deathMusicLoaded = 0x0712
local playerState = 0x000E

 if(memory.readbyte(deathMusicLoaded) == 0x01 or memory.readbyte(playerState) == 0x0B)then
 return true

 else
 return false

 end
end


function notActiveMap()
  sum = 0
  for tile=0x0500, 0x069F do
    sum = sum + memory.readbyte(tile)
  end

  return sum == 0
end

function distanceToLedge()
  getPlayerPosition()


end
-----------------
--Main Game Loop.
-----------------
Q = {}
e = {}
lastState = printCurrentMapState()
Q[lastState] = {0,0,0,0,0,0,0,0,0,0,0}
deaths = 0
reward = 0
-- Initialize Q(s,a) and e(s,a) = 0, for all s,a
-- A sparse matrix for Q and E
while(true)do
    local epsilon = 0.005
    local gamma = 0.98
    local lambda = 0.9
    local alpha = 0.1
    -- Terminal States: Win level, die.
  --  printEpisodeNum()
    printBotName()
    local state = printCurrentMapState()

    -- printEnemyNameAndState()
    memory.writebyte(0x075A,0x03)--Set Lives to 10

	  -----------------------
    --Clear Input on Death.
    -----------------------
    if (isPlayerDead()) then
       deaths = deaths + 1
       emu.print(string.format("Player Died: %d", deaths))
       lastMarioX = 0
       clearJoyPad()
    else
      local nextAction
      -- Q is the quality of actions
      Q[state] = Q[state] or {0,0,0,0,0,0,0,0,0,0,0}
      -- E is an eligibility trace
      e[state] = e[state] or {0,0,0,0,0,0,0,0,0,0,0}

      local maxQ = Q[state][1]
      local maxQi = nil
      local astar = nil


      for i in pairs(Q[state]) do
        local v = Q[state][i]
        if (v > maxQ) then
          maxQi = i
          maxQ = v
        end
      end

      if (maxQi ~= nil) then
        astar = maxQi
      else
        astar = math.random(#actions)
      end

      if (math.random() <= epsilon) then
        aprime = math.random(#actions)
      else
        aprime = astar
      end

      delta = reward + gamma * Q[state][astar] - Q[lastState][currentAction]
      e[lastState][currentAction] = 1

      for s, actions in pairs(e) do
        if (astar ~= aprime) then
          e = {}
          e[state] = {0,0,0,0,0,0,0,0,0,0,0}
        else
          for a, act in ipairs(actions) do
            Q[s][a] = Q[s][a] + alpha * delta * e[s][a]
            e[s][a] = gamma * lambda * e[s][a]
          end
        end
      end

      currentAction = aprime
      lastState = state
    end

    reward = 0
    for z=0,7 do
      printBotName()
      reward = reward + printReward()
      printCurrentMapState()
      joypad.set(1, actions[currentAction])
      emu.frameadvance()
    end
end
