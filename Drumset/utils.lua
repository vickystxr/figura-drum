local utils = {}
function utils.rotateAroundPivot(rot,pos,pivot) 
  local rotationMatrix = matrices.mat4()
  rotationMatrix:translate(pos) --pos
  rotationMatrix:rotate(rot) --rot
  return (rotationMatrix*pivot:augmented()).xyz
end

function utils.computeCorners(box)
  -- Initialize the list of corners
  local corners = {}

  -- Iterate over the dimensions of the box
  for x = 0, 1 do
    for y = 0, 1 do
      for z = 0, 1 do
        -- Compute the corner position using the min or max values of the box
        local xpos = x == 0 and box[1].x or box[2].x
        local ypos = y == 0 and box[1].y or box[2].y
        local zpos = z == 0 and box[1].z or box[2].z
        local corner = vec(xpos, ypos, zpos)

        -- Add the corner to the list
        table.insert(corners, corner)
      end
    end
  end

  -- Return the list of corners
  return corners
end

function utils.getSin(delta, min,max,period,phaseShift)
  return math.abs((min-max)/2) * math.sin((2*math.pi*(delta+phaseShift))/(period+(math.pi/2))) + ((min+max)/2)
end

return utils