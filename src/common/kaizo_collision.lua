--[[
    PLUSKAIZO
    Copyright (c) Benjamín Gajardo All rights reserved

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

KaizoLocation = {}

--[[

Collision types

0 = air
1 = solid
2 = player death/npc solid collision
3 = player should kill it
4 = player call entity OnInteract() if it can do it
5 = DIE 100%
6 = entity call OnInteract if can do it

Slope rotation

0 = up
1 = right
2 = down
3 = left


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
	elseif tile_id == 14 then
		return {up = 1, down = 1, left = 2, right = 1} --spike left
	elseif tile_id == 15 then
		return {up = 1, down = 2, left = 1, right = 1} --spike down
	elseif tile_id == 16 then
		return {up = 1, down = 1, left = 2, right = 2} --spike right
	end

    return {up = 1, down = 1, left = 1, right = 1}
end

function GetSlopeInfo(tile_id)

	--- altitude left, altitude right, rotation
	if tile_id == 12 then
		return 32,0,0
	elseif tile_id == 13 then
		return 0,32,0
	elseif tile_id == 18 then
		return 32,16,0
	elseif tile_id == 19 then
		return 16,0,0
	elseif tile_id == 20 then
		return 0,16,0
	elseif tile_id == 21 then
		return 16,32,0
	end
	return nil
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

function DetectVerticalSquareCollision(x, y, vely, w, h, x2, y2, w2, h2, coltypes, id)
    local SquareOneCoor = {x = x,y = y + vely}
	local SquareOneSize = {x = w,y = h}
	local SquareTwoCoor = {x = x2,y = y2}
	local SquareTwoSize = {x = w2,y = h2}

    local collision = {up = 0, down = 0, left = 0, right = 0}
	local collidepoint = nil

	local alt1, alt2, rotation = GetSlopeInfo(id)

	if alt1 then
		SquareTwoCoor.x, SquareTwoCoor.y, SquareTwoSize.x, SquareTwoSize.y = ManipulateTileSizeForSlopes(alt1, alt2, rotation, x, y + vely, w, h, x2, y2, w2, h2)
	end

	if (SquareOneCoor.y <= (SquareTwoCoor.y + SquareTwoSize.y) and (SquareOneCoor.y + SquareOneSize.y) >= SquareTwoCoor.y and SquareOneCoor.x < (SquareTwoCoor.x + SquareTwoSize.x) and (SquareOneCoor.x + SquareOneSize.x) > SquareTwoCoor.x) then
        if SquareOneCoor.y + SquareOneSize.y/2 < SquareTwoCoor.y + SquareTwoSize.y/2 then
            collision.down = coltypes.up
			collidepoint = SquareTwoCoor.y
        else
            collision.up = coltypes.down
			collidepoint = SquareTwoCoor.y
        end
    end

    return collision, collidepoint
end

function DetectHorizontalSquareCollision(x, y, velx, w, h, x2, y2, w2, h2, coltypes, id)
    local SquareOneCoor = {x = x + velx,y = y}
	local SquareOneSize = {x = w,y = h}
	local SquareTwoCoor = {x = x2,y = y2}
	local SquareTwoSize = {x = w2,y = h2}

    local collision = {up = 0, down = 0, left = 0, right = 0}

	local collidepoint = nil

	local verticalmovement = 0

	local alt1, alt2, rotation = GetSlopeInfo(id)

	if alt1 then
		SquareTwoCoor.x, SquareTwoCoor.y, SquareTwoSize.x, SquareTwoSize.y = ManipulateTileSizeForSlopes(alt1, alt2, rotation, x + velx, y, w, h, x2, y2, w2, h2)
	end

    if (SquareOneCoor.y < (SquareTwoCoor.y + SquareTwoSize.y) and (SquareOneCoor.y + SquareOneSize.y) > SquareTwoCoor.y and SquareOneCoor.x <= (SquareTwoCoor.x + SquareTwoSize.x) and (SquareOneCoor.x + SquareOneSize.x) >= SquareTwoCoor.x) then

		if alt1 and rotation == 0 and SquareOneCoor.y + SquareOneSize.y/2 < SquareTwoCoor.y then
			verticalmovement = SquareTwoCoor.y - (SquareOneCoor.y + SquareOneSize.y)
			collidepoint = SquareOneCoor.x + velx
		elseif SquareOneCoor.x + SquareOneSize.x/2 < SquareTwoCoor.x + SquareTwoSize.x/2 then
            collision.right = coltypes.left
			collidepoint = SquareTwoCoor.x
        else
            collision.left = coltypes.right
			collidepoint = SquareTwoCoor.x
        end
    end

    return collision, collidepoint, verticalmovement
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

function IsEntityColliding(ent1, ent2)
	if ent1.pos.x > ent2.pos.x + ent2.size.x then
		return false
	end

	if ent1.pos.x + ent1.size.x < ent2.pos.x then
		return false
	end

	if ent1.pos.y > ent2.pos.y + ent2.size.y then
		return false
	end

	if ent1.pos.y + ent1.size.y < ent2.pos.y then
		return false
	end

	return true
end

function ManipulateTileSizeForSlopes(alt1, alt2, rotation, x, y, w, h, x2, y2, w2, h2, id)

	local tempx = x2
	local tempy = y2
	local tempw = w2
	local temph = h2

	local altoffset = 0
	if rotation == 0 then
		tempy = tempy
		local xpoint = 0
		local altdifference = 0
		local mult = 0
		if alt1 > alt2 then
			xpoint = x
			altdifference = alt1 - alt2
			mult = altdifference / 32
			altoffset = h2 - alt1

			if xpoint <= x2 then
				--dont change tile size
			elseif xpoint >= x2 + w2 then
				tempy = tempy + altdifference
				temph = temph - altdifference
			else
				tempy = tempy + ((xpoint - x2) * mult)
				temph = temph - ((xpoint - x2) * mult)
			end
		else
			xpoint = x + w + 1 -- +1 since otherwise we never get alt2 on slope calculation and slope is lower than it should
			altdifference = alt2 - alt1
			mult = altdifference / 32
			altoffset = h2 - alt2

			if xpoint <= x2 then
				tempy = tempy + altdifference
				temph = temph - altdifference
			elseif xpoint >= x2 + w2 then
				--dont change tile size
			else
				tempy = tempy + ((x2 + w2) - xpoint) * mult
				temph = temph - ((x2 + w2) - xpoint) * mult
			end
		end

		tempy = tempy + altoffset
	end

	return tempx, tempy, tempw, temph
end