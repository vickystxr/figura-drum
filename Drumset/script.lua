require("utils")
require("tables")
local drums = {}
local debug = false
local playerRaycastRange = 3

models.Drum.SKULL.DrumSet:setPrimaryRenderType("TRANSLUCENT_CULL")

function events.skull_render(delta, block, item, entity, mode)
    -- scans through every key and resets the position
--[[     for k, pianoID in pairs(pianos) do
        for keyID, timecode in pairs(pianoID.playingKeys) do
            models.Drum.SKULL.DrumSet   .Keys["C" .. string.sub(keyID, -1, -1)][keyID]:setRot(0, 0, 0)
        end
    end ]]

    -- sets the scale of piano items to be small, and blocks to be large
    if mode == "BLOCK" then
        models.Drum.SKULL.DrumSet   :setScale(1, 1, 1)
    else
        models.Drum.SKULL.DrumSet   :setScale(0.3, 0.3, 0.3)
        -- models:setPrimaryTexture("CUSTOM",textures['PierraNovaPiano'])
        return
    end

    -- creates piano table element when a piano is first placed down
    local pos = block:getPos()
    local drumID = tostring(pos)

    -- changes the piano texture if there's a gold 2 blocks under the player head
    if world.getBlockState(pos.x, pos.y - 2, pos.z):getID() == "minecraft:gold_block" then
        -- models:setPrimaryTexture("CUSTOM",textures['ToastPiano'])
    else
        -- models:setPrimaryTexture("CUSTOM",textures['PierraNovaPiano'])
    end

    -- creats new piano entry if head was just placed
    if drums[drumID] == nil then
        drums[drumID] = { pos = pos, playingKeys = {} }
    end

    -- checks table for checked keys, and presses the key if the key press was less than 3 ticks ago
    for keyID, keyPresstime in pairs(drums[drumID].playingKeys) do
        if world.getTime() < keyPresstime + 3 then
            --models.Drum.SKULL.DrumSet   .Keys["C" .. string.sub(keyID, -1, -1)][keyID]:setRot(-4, 0, 0)
        else
            -- clears the keypress data for keys that were pressed more than 3 ticks ago
            drums[drumID].playingKeys[keyID] = nil
        end
    end
end

-- plays note ^^
function playNote(pianoID, keyID, doesPlaySound, notePos)
    if drums[pianoID].playingKeys[keyID] == nil then
        drums[pianoID].playingKeys[keyID] = {}
    end
    drums[pianoID].playingKeys[keyID] = world.getTime()
    if not doesPlaySound then return end
    if notePos then
        sounds:playSound(keyPitches[keyID][2], notePos, 2, keyPitches[keyID][1])
    else
        sounds:playSound('sounds.'..keyID, drums[pianoID].pos, 2)
    end
end

-- stores important functions so that other avatars can access them through avatarVars() in the world API
avatar:store("playNote", playNote)
avatar:store("validPos", function(pianoID) return drums[pianoID] ~= nil end)
avatar:store("getPlayingKeys",
    function(drumID) return drums[drumID] ~= nil and drums[drumID].playingKeys or nil end)

-- the tick function >~>
function events.world_tick()
    for i, v in pairs(drums) do
        if world.getBlockState(v.pos).id ~= "minecraft:player_head" then
            drums[i] = nil
        end
    end

    -- runs this code for every player
    for k, player in pairs(world.getPlayers()) do
        repeat
            if not (player:isUsingItem() or player:getSwingTime() == 1 or debug) then break end
            local pos = player:getPos()

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

                    local eyePos = rotateAroundPivot(-drumRot,
                        vec(pos.x, pos.y + player:getEyeHeight(), pos.z) - worldOffset, vec(0, 0, 0))
                    local lookDir = rotateAroundPivot(-drumRot, player:getLookDir(), vec(0, 0, 0))

                    local ray = { origin = eyePos, dir = lookDir }
                    rayIntersections = {}

                    for boxID, bounding in pairs(boundingBoxes) do
                        local box = bounding
                        local intersection = boxRayIntersection(box, ray)
                        rayIntersections[boxID] = intersection
                        ---- debug ----
                        if debug then
                            -- spawn box corner particles
                            for cornerID, corner in pairs(computeCorners(box)) do
                                particles:newParticle("minecraft:dust 0 0.7 0.7 0.2",
                                    worldOffset + rotateAroundPivot(drumRot, corner, vec(0, 0, 0)))
                            end
                        end
                        ---------------
                    end
                    ------------------------------------------- end of section -------------------------------------------------

                    keyID = nil
                    if rayIntersections.bassDrum then
                        keyID = 'B1'
                    end
                    if rayIntersections.snareCrossStick then
                        keyID = 'C#2'
                    end
                    if rayIntersections.snareDrum then
                        keyID = 'D2'
                    end
                    if rayIntersections.floorTom then
                        keyID = 'F2'
                    end
                    if rayIntersections.lowTom then
                        keyID = 'A2'
                    end
                    if rayIntersections.highTom then
                        keyID = 'B2'
                    end
                    if rayIntersections.rideCymbal then
                        keyID = 'D#3'
                    end
                    if rayIntersections.crashCymbal then
                        keyID = 'C#3'
                    end
                    if rayIntersections.hiHats then
                        if player:isCrouching() then
                            keyID = 'F#2'
                        else
                            keyID = 'A#2'
                        end
                        
                    end
                   
                    if keyID == nil then break end
                    playNote(drumID, keyID, drums[drumID].playingKeys[keyID] == nil)
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
