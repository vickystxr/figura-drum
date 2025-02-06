boundingBoxes = {
    { -- bassDrum
        [1] = vec(-6/16,0/16,-8/16),
        [2] = vec(6/16,12/16,7/16),
        key = function() return "B1" end
    },
    { -- snareCrossStick
        [1] = vec(-15/16,12/16,2/16),
        [2] = vec(-5/16,17/16,12/16),
        key = function() return "C#2" end
    },
    { -- snareDrum
        [1] = vec(-15/16,17/16,2/16),
        [2] = vec(-5/16,18/16,12/16),
        key = function() return "D2" end
    },
    { -- floorTom
        [1] = vec(7/16,13/16,2/16),
        [2] = vec(17/16,18/16,12/16),
        key = function() return "F2" end
    },
    { -- lowTom
        [1] = vec(0/16,13/16,-7/16),
        [2] = vec(9/16,21/16,2/16),
        key = function() return "A2" end
    },
    { -- highTom
        [1] = vec(-9/16,13/16,-7/16),
        [2] = vec(-1/16,21/16,1/16),
        key = function() return "B2" end
    },
    { -- rideCymbal
        [1] = vec(9/16,22/16,-8/16),
        [2] = vec(20/16,25/16,4/16),
        key = function() return "D#3" end
    },
    { -- crashCymbal
        [1] = vec(-5/16,25/16,-15/16),
        [2] = vec(-17/16,28/16,-1/16),
        key = function() return "C#3" end
    },
    { -- hiHatss
        [1] = vec(-9/16,19/16,-5/16),
        [2] = vec(-20/16,22/16,5/16),
        key = function()
                if player:isCrouching() then
                    return "F#2"
                else
                    return "A#2"
                end
            end
    },
    
}