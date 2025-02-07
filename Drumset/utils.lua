function rotateAroundPivot(rot,pos,pivot) 
  local rotationMatrix = matrices.mat4()
  rotationMatrix:translate(pos) --pos
  rotationMatrix:rotate(rot) --rot
  return (rotationMatrix*pivot:augmented()).xyz
end

function computeCorners(box)
  -- Initialize the list of corners
  local corners = {}

  -- Iterate over the dimensions of the box
  for x = 0, 1 do
    for y = 0, 1 do
      for z = 0, 1 do
        -- Compute the corner position using the min or max values of the box
        local xpos = x == 0 and box.min.x or box.max.x
        local ypos = y == 0 and box.min.y or box.max.y
        local zpos = z == 0 and box.min.z or box.max.z
        local corner = vec(xpos, ypos, zpos)

        -- Add the corner to the list
        table.insert(corners, corner)
      end
    end
  end

  -- Return the list of corners
  return corners
end