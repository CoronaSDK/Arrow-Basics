-- 
-- Arrow sample project
-- Demonstrates proper arrow functionality
-- Coded by Nick Homme
-- 


local physics = require("physics")
physics.start()
physics.setDrawMode( "hybrid" ) -- overlays collision outlines on normal Corona objects
physics.setGravity( 0, 9.8 ) -- overhead view, therefore no gravity vector

display.setStatusBar( display.HiddenStatusBar )



-- The final "true" parameter overrides Corona's auto-scaling of large images
local background = display.newRect( 0, 0, 480, 320 )
background.x = display.contentWidth / 2
background.y = display.contentHeight / 2
background:setFillColor (0, 191, 255, 255)

local bow = display.newImage( "bow.png", 0, 0, true )
bow.x = display.contentWidth / 2
bow.y = display.contentHeight / 2


local ground = display.newRect( 0, 0, 480, 57 )
ground.x = 240; ground.y = 310;
ground:setFillColor (50, 205, 50, 255)
physics.addBody( ground, "static", { friction=0.5 } )


local ballBody = { density=0.8, friction=0.2, bounce=0.5 }
--

-- Create arrow
local arrow = display.newImage( "arrow.png" )
arrow.x = display.contentWidth/2
arrow.y = display.contentHeight/2

physics.addBody( arrow, ballBody )
arrow.linearDamping = 0.3
arrow.angularDamping = 0.8
arrow.isBullet = true -- force continuous collision detection, to stop really fast shots from passing through other balls
arrow.color = "white"
arrow.bodyType = "kinematic"
arrow.myName = "arrow"
arrow.filter=arrowCollisionFilter 

local tip = display.newRect( 0, 0, 1, 1 )
physics.addBody( tip, "dynamic", { density = 10, friction=0.5 } )

tip.x = arrow.x + arrow.width/2
tip.y = arrow.y
physics.addBody(tip)



local turner = display.newRect( 0, 0, 21, 21 )
turner.x = display.contentWidth/2
turner.y = display.contentHeight/2
turner:setFillColor (0, 0, 204, 50)
turner.isSensor = true

myJoint10 = physics.newJoint( "weld", arrow, tip, arrow.x+30,arrow.y )


-- Shoot the arrow, using a visible force vector
local function arrowShot( event )
        local t = event.target
 
        local phase = event.phase
        if "began" == phase then
                display.getCurrentStage():setFocus( t )
                t.isFocus = true
            	arrow.bodyType = "kinematic"

                -- Stop current arrow motion, if any
                t:setLinearVelocity( 0, 0 )
                t.angularVelocity = 0

				arrow.x = t.x
				arrow.y = t.y
                

        elseif t.isFocus then
                if "moved" == phase then
	
	                arrow.bodyType = "kinematic"
		
					-- get distance 							--------------------------------------
					dX = bow.x-arrow.x						------Thank canupa.com from the forums for the-----
					dY = bow.y-arrow.y 						------------arrow rotating with touch--------------
					-- calculate rotation						--------------------------------------
					arrow.rotation = math.atan2(dY, dX)/(math.pi/180);    
					
						-- Boundary for the arrow when grabbed			
						local bounds = event.target.stageBounds;
						bounds.xMax = 0;
						bounds.yMax = 275;

						if(event.y > bounds.yMax) then
							event.y = 275;
						else
						end
						if(event.x < bounds.xMax) then
							event.x = 0;
						else
							-- Do nothing
						end	
					arrow.x = event.x
					arrow.y = event.y
                        
 
 
                elseif "ended" == phase or "cancelled" == phase then
                        display.getCurrentStage():setFocus( nil )
                        t.isFocus = false
                                         
                        -- Strike the arrow!
                        arrow.bodyType = "dynamic"
                        t:applyForce( -(t.x - bow.x)*8, -(t.y - bow.y)*8, t.x, t.y )
 						
 
                end
        end
 
        -- Stop further propagation of touch event
        return true
end
 
arrow:addEventListener( "touch", arrowShot )

function distance( a, b )
	local width, height = b.x-a.x, b.y-a.y
	return math.sqrt( width*width + height*height )
end


local tmax = distance( {x=0,y=0}, {x=display.contentWidth,y=display.contentHeight} )
local strength = 1000 --The smaller the number the more force the magnet has
local magnet = nil

function touch( event )
	if (event.phase == "began" or event.phase == "moved") then
		magnet = event
	else
		magnet = nil
	end
end

function doMagnet( event )

			local dist = distance( turner, tip )
			
			local power = tmax/dist / strength
			
			local xmove = (turner.x-tip.x) * power
			local ymove = (turner.y-tip.y) * power
			
			tip:applyForce( 0,ymove , tip.x,tip.y )

end

Runtime:addEventListener( "enterFrame", doMagnet )


local function updateRotation()	
		
		turner.x = tip.x+30; 
		
		
			if(tip.x > bow.x) then
				turner.x = tip.x+30; 
			else
			end
			if(tip.x < bow.x) then
				turner.x = tip.x-30;
			end
			
		turner.y = 270

end

updateRotation()



-- Update the turner position once per second
local arrowRotater = timer.performWithDelay( 1, updateRotation, -1 )