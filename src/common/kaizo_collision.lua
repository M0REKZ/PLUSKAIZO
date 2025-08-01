-- PLUSKAIZO (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the PLUSKAIZO directory for license

KaizoLocation = {}

--[[

0 = air
1 = solid
2 = player death/npc solid collision
3 = player should kill it
4 = player call entity OnInteract() if it can do it
5 = DIE 100%

--]]

function KaizoLocation:new(x,y)
    local o = {}
    o.x = x or 0
    o.y = y or 0
    return o
end

KaizoSquareCollision = {}

function KaizoSquareCollision:new(up, down, left, right)
    local o = {}
    o.up = up or 0
    o.down = down or 0
    o.left = left or 0
    o.right = right or 0
    return o
end

KaizoTriangleCollision = {
    ab = 0,
    bc = 0,
    ca = 0,
}

function TileToCollision(tile_id)

    if tile_id == -1 then
        return {up = 1, down = 1, left = 1, right = 1} -- section limit
    elseif tile_id == -2 then
        return {up = 5, down = 5, left = 5, right = 5} -- section limit (death)
    end
    if tile_id == 0 then
        return {up = 0, down = 0, left = 0, right = 0} -- air
    end    

	if tile_id == 10 then
		return {up = 2, down = 1, left = 1, right = 1} --spike up
	end

    return {up = 1, down = 1, left = 1, right = 1}
end


function DetectSquareToSquareCollisionQB64OldNew(oldx, oldy, x, y, w, h, x2, y2, w2, h2, coltypes)
    local collision = {up = 0, down = 0, left = 0, right = 0}
    collision = DetectSquareToSquareCollisionQB64Old(oldx, oldy, x, y, w, h, x2, y2, w2, h2, coltypes)
    if collision.up == 0 and collision.down == 0 and collision.left == 0 and collision.right == 0 then
        collision = DetectSquareToSquareCollisionQB64(x, y, w, h, x2, y2, w2, h2, coltypes)
    end
    return collision
end

function DetectSquareToSquareCollisionQB64Old(oldx, oldy, x, y, w, h, x2, y2, w2, h2, coltypes)
    local SquareOneOldCoor = {x = oldx,y = oldy}
    local SquareOneCoor = {x = x,y = y}
	local SquareOneSize = {x = w,y = h}
	local SquareTwoCoor = {x = x2,y = y2}
	local SquareTwoSize = {x = w2,y = h2}

    local collision = {up = 0, down = 0, left = 0, right = 0}
	
	if (SquareOneCoor.y <= (SquareTwoCoor.y + SquareTwoSize.y) and (SquareOneCoor.y + SquareOneSize.y) >= SquareTwoCoor.y and SquareOneCoor.x <= (SquareTwoCoor.x + SquareTwoSize.x) and (SquareOneCoor.x + SquareOneSize.x) >= SquareTwoCoor.x) then
	
		local calcmyx = SquareOneOldCoor.x - (SquareTwoCoor.x + (SquareTwoSize.x / 2)) + (SquareOneSize.x / 2)

		local calcmyy = SquareOneOldCoor.y - (SquareTwoCoor.y + (SquareTwoSize.y / 2)) + (SquareOneSize.y / 2)
		
		
		
		if(SquareTwoSize.x > SquareTwoSize.y) then

			calcmyy = calcmyy * (((SquareTwoSize.x / 2.0) + (SquareOneSize.x / 2.0)) / ((SquareTwoSize.y / 2.0) + (SquareOneSize.y / 2.0)))
		
        elseif (SquareTwoSize.x < SquareTwoSize.y) then
		
			calcmyx = calcmyx * (((SquareTwoSize.y / 2.0) + (SquareOneSize.y / 2.0)) / ((SquareTwoSize.x / 2.0) + (SquareOneSize.x / 2.0)))
        end
		
		
		
		if(not (calcmyx == calcmyy or -calcmyx == calcmyy)) then
		
			if(calcmyx > 0) then
			
				if(calcmyy > 0) then
				
					if(calcmyx > calcmyy) then
					
						collision.left = coltypes.right
		
					else
					
						collision.up = coltypes.down
                    end
				
				else
				
					if(calcmyx > -calcmyy) then
					
						collision.left = coltypes.right
					
					else
					
						collision.down = coltypes.up
                    end
				end
			
			else
			
				if(calcmyy > 0) then
				
					if(-calcmyx > calcmyy) then
					
						collision.right = coltypes.left
					
					else
					
						collision.up = coltypes.down
                    end
				
				else
				
					if(-calcmyx > -calcmyy) then
					
						collision.right = coltypes.left
					
					else
					
						collision.down = coltypes.up
                    end
				end
			end
		end
	end

	return collision
end

function DetectSquareToSquareCollisionQB64(x, y, w, h, x2, y2, w2, h2, coltypes)
    --local SquareOneOldCoor = {x = oldx,y = oldy}
    local SquareOneCoor = {x = x,y = y}
	local SquareOneSize = {x = w,y = h}
	local SquareTwoCoor = {x = x2,y = y2}
	local SquareTwoSize = {x = w2,y = h2}

    local collision = {up = 0, down = 0, left = 0, right = 0}
	
	if (SquareOneCoor.y <= (SquareTwoCoor.y + SquareTwoSize.y) and (SquareOneCoor.y + SquareOneSize.y) >= SquareTwoCoor.y and SquareOneCoor.x <= (SquareTwoCoor.x + SquareTwoSize.x) and (SquareOneCoor.x + SquareOneSize.x) >= SquareTwoCoor.x) then
	
		local calcmyx = SquareOneCoor.x - (SquareTwoCoor.x + (SquareTwoSize.x / 2)) + (SquareOneSize.x / 2)

		local calcmyy = SquareOneCoor.y - (SquareTwoCoor.y + (SquareTwoSize.y / 2)) + (SquareOneSize.y / 2)
		
		
		
		if(SquareTwoSize.x > SquareTwoSize.y) then

			calcmyy = calcmyy * (((SquareTwoSize.x / 2.0) + (SquareOneSize.x / 2.0)) / ((SquareTwoSize.y / 2.0) + (SquareOneSize.y / 2.0)))
		
        elseif (SquareTwoSize.x < SquareTwoSize.y) then
		
			calcmyx = calcmyx * (((SquareTwoSize.y / 2.0) + (SquareOneSize.y / 2.0)) / ((SquareTwoSize.x / 2.0) + (SquareOneSize.x / 2.0)))
        end
		
		
		
		if(not (calcmyx == calcmyy or -calcmyx == calcmyy)) then
		
			if(calcmyx > 0) then
			
				if(calcmyy > 0) then
				
					if(calcmyx > calcmyy) then
					
						collision.left = coltypes.right
		
					else
					
						collision.up = coltypes.down
                    end
				
				else
				
					if(calcmyx > -calcmyy) then
					
						collision.left = coltypes.right
					
					else
					
						collision.down = coltypes.up
                    end
				end
			
			else
			
				if(calcmyy > 0) then
				
					if(-calcmyx > calcmyy) then
					
						collision.right = coltypes.left
					
					else
					
						collision.up = coltypes.down
                    end
				
				else
				
					if(-calcmyx > -calcmyy) then
					
						collision.right = coltypes.left
					
					else
					
						collision.down = coltypes.up
                    end
				end
			end
		end
	end

	return collision
end

function DetectVerticalSquareCollision(x, y, vely, w, h, x2, y2, w2, h2, coltypes)
    local SquareOneCoor = {x = x,y = y + vely}
	local SquareOneSize = {x = w,y = h}
	local SquareTwoCoor = {x = x2,y = y2}
	local SquareTwoSize = {x = w2,y = h2}

    local collision = {up = 0, down = 0, left = 0, right = 0}
    if (SquareOneCoor.y <= (SquareTwoCoor.y + SquareTwoSize.y) and (SquareOneCoor.y + SquareOneSize.y) >= SquareTwoCoor.y and SquareOneCoor.x < (SquareTwoCoor.x + SquareTwoSize.x) and (SquareOneCoor.x + SquareOneSize.x) > SquareTwoCoor.x) then
        if SquareOneCoor.y + SquareOneSize.y/2 < SquareTwoCoor.y + SquareTwoSize.y/2 then
            collision.down = coltypes.up
        else
            collision.up = coltypes.down
        end
    end

    return collision
end

function DetectHorizontalSquareCollision(x, y, velx, w, h, x2, y2, w2, h2, coltypes)
    local SquareOneCoor = {x = x + velx,y = y}
	local SquareOneSize = {x = w,y = h}
	local SquareTwoCoor = {x = x2,y = y2}
	local SquareTwoSize = {x = w2,y = h2}

    local collision = {up = 0, down = 0, left = 0, right = 0}
    if (SquareOneCoor.y < (SquareTwoCoor.y + SquareTwoSize.y) and (SquareOneCoor.y + SquareOneSize.y) > SquareTwoCoor.y and SquareOneCoor.x <= (SquareTwoCoor.x + SquareTwoSize.x) and (SquareOneCoor.x + SquareOneSize.x) >= SquareTwoCoor.x) then
        if SquareOneCoor.x + SquareOneSize.x/2 < SquareTwoCoor.x + SquareTwoSize.x/2 then
            collision.right = coltypes.left
        else
            collision.left = coltypes.right
        end
    end

    return collision
end

function IsInCamera(x, y, w, h)
    
    if (x <= Camera.x + WindowSize.x) and (x + w >= Camera.x) and (y <= Camera.y + WindowSize.y) and (y + h >= Camera.y) then
        return true
    end
    return false
end

function IsPointInsideSquare(x, y, x2, y2,w2, h2)
    if (x <= x2 + w2) and (x >= x2) and (y <= y2 + h2) and (y >= y2) then
        return true
    end
    return false
end

function IsPosInCamera(pos, size)
    return IsInCamera(pos.x, pos.y, size.x, size.y)
end