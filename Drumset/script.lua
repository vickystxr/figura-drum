local utils = require("utils")
local boundingBoxes = require("tables")
local drums = {}
local debug = false
local clock = 0
local playerRaycastRange = 3
local DrumSet = models.Drum.SKULL.DrumSet

local anims = {
    B1 = function(animFrame,drumID)
        if animFrame < 4 then
            DrumSet.BassDrum.KickPedal.Pedal:setRot(0)
            DrumSet.BassDrum.KickPedal.Beater:setRot(utils.getSin(animFrame,-45,0,4,0))
            DrumSet.BassDrum.BDrum:setScale(utils.getSin(animFrame,1,1.03,4,0))
        else
            drums[drumID].playingKeys.B1 = nil
        end
    end,
    ["C#2"] = function(animFrame,drumID)
        if animFrame < 3 then
            local rot = utils.getSin(animFrame,-0.5,0,1.5,0)
            DrumSet.Snare:setRot(0,0,rot)
        else
            drums[drumID].playingKeys["C#2"] = nil
        end
    end,
    D2 = function(animFrame,drumID)
        if animFrame < 4 then
            DrumSet.Snare.SDrum:setScale(utils.getSin(animFrame,1,1.03,4,0))
        else
            drums[drumID].playingKeys["D2"] = nil
        end
    end,
    F2 = function(animFrame,drumID)
        if animFrame < 4 then
            DrumSet.FloorTom.FTDrum:setScale(utils.getSin(animFrame,1,1.03,4,0))
        else
            drums[drumID].playingKeys["F2"] = nil
        end
    end,
    A2 = function(animFrame,drumID)
        if animFrame < 4 then
            DrumSet.MediumTom.MDrum:setScale(utils.getSin(animFrame,1,1.03,4,0))
        else
            drums[drumID].playingKeys["A2"] = nil
        end
    end,
    B2 = function(animFrame,drumID)
        if animFrame < 4 then
            DrumSet.HiTom.HDrum:setScale(utils.getSin(animFrame,1,1.03,4,0))
        else
            drums[drumID].playingKeys["B2"] = nil
        end
    end,
    ["D#3"] = function(animFrame,drumID)
        if animFrame < 40 then
            local mod = 1 - animFrame/40
            local rot = utils.getSin(animFrame,-5,5,20,10)*mod
            DrumSet.RideCymbal.RCStand.RCDrum:setRot(rot-35,0,rot/3)
        else
            drums[drumID].playingKeys["D#3"] = nil
        end
    end,
    ["C#3"] = function(animFrame,drumID)
        if animFrame < 80 then
            local mod = 1 - animFrame/80
            local rot = utils.getSin(animFrame,-10,10,20,10)*mod
            DrumSet.CrashCymbal.CCStand.CCCymbal:setRot(rot-35,0,-rot/3)
        else
            drums[drumID].playingKeys["C#3"] = nil
        end
    end,
    ["A#2"] = function(animFrame,drumID)
        if animFrame < 20 then
            local mod = 1 - animFrame/20
            local rot = utils.getSin(animFrame,-2,2,10,5)*mod
            DrumSet.HiHats.HHCymbal:setRot(rot,-45,-rot)
        else
            drums[drumID].playingKeys["A#2"] = nil
        end
    end,
    ["F#2"] = function(animFrame,drumID)
        if animFrame < 15 then
            local mod = 1 - animFrame/15
            local rot = utils.getSin(animFrame,-2,2,10,5)*mod
            DrumSet.HiHats.HHCymbal:setRot(rot,-45,-rot)
            DrumSet.HiHats.HHCymbal:setScale(1,0.5,1)
            DrumSet.HiHats.Pedal:setRot(0,45,0)
        else
            drums[drumID].playingKeys["F#2"] = nil
        end
    end,
    ["G#2"] = function(animFrame,drumID)
        if animFrame < 4 then
            DrumSet.HiHats.HHCymbal:setScale(1,0.5,1)
            DrumSet.HiHats.Pedal:setRot(0,45,0)
        else
            drums[drumID].playingKeys["G#2"] = nil
        end
    end
}

local resetVals = {
    B1 = function()
        DrumSet.BassDrum.KickPedal.Pedal:setRot(-15)
        DrumSet.BassDrum.KickPedal.Beater:setRot(-45)
        DrumSet.BassDrum.BDrum:setScale(1)
    end,
    ["C#2"] = function()
        DrumSet.Snare:setRot(0,0,0)
    end,
    D2 = function()
        DrumSet.Snare.SDrum:setScale(1)
    end,
    F2 = function()
        DrumSet.FloorTom.FTDrum:setScale(1)
    end,
    A2 = function()
        DrumSet.MediumTom.MDrum:setScale(1)
    end,
    B2 = function()
        DrumSet.HiTom.HDrum:setScale(1)
    end,
    ['D#3'] = function()
        DrumSet.RideCymbal.RCStand.RCDrum:setRot(-35,0,0)
    end,
    ['C#3'] = function()
        DrumSet.CrashCymbal.CCStand.CCCymbal:setRot(-35,0,0)
    end,
    ['A#2'] = function()
        DrumSet.HiHats.HHCymbal:setRot(0,-45,0)
    end,
    ['F#2'] = function()
        DrumSet.HiHats.HHCymbal:setRot(0,-45,0)
        DrumSet.HiHats.HHCymbal:setScale(1,1,1)
            DrumSet.HiHats.Pedal:setRot(-15,45,0)
    end,
    ['G#2'] = function()
        DrumSet.HiHats.HHCymbal:setScale(1,1,1)
        DrumSet.HiHats.Pedal:setRot(-15,45,0)
    end
}

function events.skull_render(delta, block, item, entity, mode)
    -- scans through every key and resets the position
    for k, drumID in pairs(drums) do
        for keyID, timecode in pairs(drumID.playingKeys) do
            if resetVals[keyID] then
                resetVals[keyID]()
            end
        end
    end

    -- sets the scale of piano items to be small, and blocks to be large
    if mode == "BLOCK" then
        models.Drum.SKULL.DrumSet:setScale(1, 1, 1)
    else
        models.Drum.SKULL.DrumSet:setScale(0.3, 0.3, 0.3)
        return
    end

    -- creates piano table element when a piano is first placed down
    local pos = block:getPos()
    local drumID = tostring(pos)

    -- creats new piano entry if head was just placed
    if drums[drumID] == nil then
        drums[drumID] = { pos = pos, playingKeys = {} }
    end

    -- checks table for checked keys, and presses the key if the key press was less than 3 ticks ago
    --logTable(drums[drumID].playingKeys)
    for keyID, keyPresstime in pairs(drums[drumID].playingKeys) do
        local animFrame = clock - keyPresstime + delta
        --log('a')
        anims[keyID](animFrame,drumID)
--[[         if world.getTime() < keyPresstime + 3 then
            --models.Drum.SKULL.DrumSet   .Keys["C" .. string.sub(keyID, -1, -1)][keyID]:setRot(-4, 0, 0)
        else
            -- clears the keypress data for keys that were pressed more than 3 ticks ago
            drums[drumID].playingKeys[keyID] = nil
        end ]]
    end
end

-- plays note ^^
function playNote(drumID, keyID, doesPlaySound, notePos, noteVolume)
    if drums[drumID].playingKeys[keyID] == nil then
        drums[drumID].playingKeys[keyID] = {}
    end
    if not noteVolume then
        noteVolume = 2
    end
    drums[drumID].playingKeys[keyID] = clock
    if not doesPlaySound then return end
    if notePos then
        sounds:playSound('sounds.'..keyID, notePos, noteVolume)
    else
        sounds:playSound('sounds.'..keyID, drums[drumID].pos, noteVolume)
    end
end

function playSound(keyID,notePos,noteVolume)
    sounds:playSound('sounds.'..keyID,notePos,noteVolume)
  end

-- stores important functions so that other avatars can access them through avatarVars() in the world API
avatar:store("playNote", playNote)
avatar:store("playSound",playSound)
avatar:store("validPos", function(pianoID) return drums[pianoID] ~= nil end)
avatar:store("getPlayingKeys",
    function(drumID) return drums[drumID] ~= nil and drums[drumID].playingKeys or nil end)

-- the tick function >~>
function events.world_tick()
    clock = clock + 1
    -- runs this code for every player
    for k, player in pairs(world.getPlayers()) do
        repeat
            if not (player:isUsingItem() or player:getSwingTime() == 1 or debug) then break end
            local pos = player:getPos()
            local avatarVars = world:avatarVars()[player:getUUID()]
            local eyeOffset
            if avatarVars then 
                eyeOffset = avatarVars.eyePos
            end
            if not eyeOffset then eyeOffset = 0 end
            -- run this code for every piano
            for drumID, drumData in pairs(drums) do
                repeat
                    local pianoPos = drumData.pos

                    -- escapes if the piano has been placed on a wall
                    if world.getBlockState(pianoPos).properties == nil then break end

                    ------ calculates raycast abd returns intersection with main bounding boxes for black and white notes ------
                    local drumRot = vec(0,
                        -world.getBlockState(pianoPos).properties.rotation * 22.5 + 180, 0)
                    local pivot = vec(0.5, 0, 0.5)
                    local worldOffset = pianoPos + pivot

                    local eyePos = utils.rotateAroundPivot(-drumRot,
                        vec(pos.x, pos.y + player:getEyeHeight(), pos.z) - worldOffset + eyeOffset, vec(0, 0, 0))
                    local endPos = utils.rotateAroundPivot(-drumRot, player:getLookDir(), vec(0, 0, 0)) * 10 + eyePos

                    local keyID
                    local raycast = raycast:aabb(eyePos,endPos,boundingBoxes)
                    if raycast and raycast.key then
                        keyID = raycast.key
                    end
                    

                    if debug then
                        for boxID, box in pairs(boundingBoxes) do
                                -- spawn box corner particles
                                for cornerID, corner in pairs(utils.computeCorners(box)) do
                                    particles:newParticle("minecraft:dust 0 0.7 0.7 0.2",
                                        worldOffset + utils.rotateAroundPivot(drumRot, corner, vec(0, 0, 0)))
                                end
                        end
                    end
                   
                    if keyID == nil then break end
                    playNote(drumID, keyID,true)
                until true
            end
        until true
    end

    -- clears any piano table elements if there's not a head there anymore
    for k, v in pairs(drums) do 
        if world.getBlockState(v.pos).id ~= "minecraft:player_head" then
            drums[k] = nil
        end
    end
end
