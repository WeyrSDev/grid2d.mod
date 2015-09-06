
Private

'returns a 'proper' rounded up or down integer. 0.5 = 1, not 0
Function Round:Float(value:Float)
	Local decimal:Float = value - Floor(value)
	If decimal < 0.5 Return Floor(value) Else Return Ceil(value)
EndFunction


Public

'render types
Const GRID_RENDER_LINES:Int = 1
Const GRID_RENDER_POINTS:Int = 2


Rem
bbdoc:2d coordinate based grid
endrem
Type TGrid2D

	'grid size in pixels
	Field gridSize:Int

	'zoom value
	Field zoomLevel:Float

	'bool. you can zoom if this is set to true
	Field zoomActive:Int

	'render here
	Field canvas:TGadget

	'friendly name
	Field label:String

	'grid render type. lines or points
	Field renderMethod:Int

	'status display text
	Field statusLine:String

	'bool
	Field visible:Int
	Field snapToGrid:Int

	'buttons, bool
	Field leftMouseDown:Int
	Field rightMouseDown:Int


	'current position of mouse (on grid)
	Field mouseGridPosition:TVector2D

	'previous position of mouse (on grid)
	Field prev_MouseGridPosition:TVector2D

	'position of mouse on canvas
	Field mouseCanvasPosition:TVector2D

	'previous position of mouse on canvas
	Field prev_MouseCanvasPosition:TVector2D

	' grid draw offset
	Field renderOffset:TVector2D

	'bool
	'true if mouse is over the grid canvas
	Field mouseOnCanvas:Int

	'background color
	Field backColor:Int[3]

	'grid lines color
	Field gridColor:Int[3]

	'horizontal and vertical axis color
	Field axisColor:Int[3]

	'grid size change keycodes
	Field keyGridSizeDown:Int = KEY_OPENBRACKET
	Field keyGridSizeUp:Int = KEY_CLOSEBRACKET



	Rem
	bbdoc: Constructor
	endrem
	Method New()
		backColor[0] = 140
		backColor[1] = 140
		backColor[2] = 140
		gridColor[0] = 120
		gridColor[1] = 120
		gridColor[2] = 120
		axisColor[0] = 90
		axisColor[1] = 90
		axisColor[2] = 90

		mouseGridPosition = New TVector2D
		prev_MouseGridPosition = New TVector2D
		mouseCanvasPosition = New TVector2D
		prev_MouseCanvasPosition = New TVector2D
		renderOffset = New TVector2D
		renderMethod = GRID_RENDER_LINES
		zoomActive = True
		Reset()

		AddHook(EmitEventHook, EventHandler, Self,0)
	End Method



	Function eventHandler:Object(id:Int, data:Object, context:Object)
		Local m:TGrid2D = TGrid2D(context)
		If m Then data = m.EventHook(id, data, context)
		Return data
	End Function


	Rem
	bbdoc: event handle for grid
	about: an application can react to the raised gadgetpaint event
	endrem
	Method eventHook:Object(id:Int, data:Object, context:Object)
		Local tmpEvent:TEvent = TEvent(data)
		If Not tmpEvent Then Return data
		Select tmpEvent.source
			Case canvas
				Select tmpEvent.id
					Case EVENT_MOUSELEAVE
						SetMouseOnCanvas(False)
						ShowMouse()

					Case EVENT_MOUSEENTER
						SetMouseOnCanvas(True)
						HideMouse()

					Case EVENT_MOUSEWHEEL
						If zoomActive Then ChangeZoom(tmpEvent.data)

					Case EVENT_MOUSEMOVE
						OnMouseMove(tmpEvent.x, tmpEvent.y)

					Case EVENT_MOUSEDOWN
						If tmpEvent.data = 1 Then leftMouseDown = True
						If tmpEvent.data = 2 Then rightMouseDown = True

					Case EVENT_MOUSEUP
						If tmpEvent.data = 1 Then leftMouseDown = False
						If tmpEvent.data = 2 Then rightMouseDown = False

					Case EVENT_KEYDOWN
						Select tmpEvent.data
							Case keyGridSizeDown
								SetGridSize( GetGridSize()/2 )
							Case keyGridSizeUp
								SetGridSize( GetGridSize()*2 )
						End Select

					Default
						'it is an event we're not interested in.
						Return data
				End Select


				'emit event to notify any apps of a needed redraw.
				EmitEvent CreateEvent(EVENT_GADGETPAINT, canvas)

			Default
				'no event for this item
				Return data
		End Select

		Return data
	End Method



	rem
	bbdoc: Set to true to activate zooming with mousewheel.
	endrem
	Method SetZoomActive(bool:Int)
		zoomActive = bool
	End Method

	rem
	bbdoc: Returns current zoom active flag.
	endrem
	Method GetZoomActive:Int()
		Return zoomActive
	End Method

	Rem
	bbdoc: Changes mouseoncanvas bool flag.
	endrem
	Method SetMouseOnCanvas(bool:Int)
		mouseOnCanvas=bool
	End Method

	Rem
	bbdoc: Returns the mouse position on the canvas
	returns: TVector2D
	endrem
	Method GetMouseCanvasPosition:TVector2D()
		Return mouseCanvasPosition
	End Method

	Rem
	bbdoc: Returns the mouse position on the grid
	returns: TVector2D
	endrem
	Method GetMouseGridPosition:TVector2D()
		Return mouseGridPosition
	End Method

	Rem
	bbdoc: Returns the previous mouse position on the grid.
	returns: TVector2D
	endrem
	Method GetPreviousMouseGridPosition:TVector2D()
		Return prev_MouseGridPosition
	End Method

	Rem
	bbdoc: Sets canvas to render to.
	endrem
	Method SetCanvas(gadget:TGadget)
		canvas = gadget

		'let it emit events
		ActivateGadget(canvas)
	End Method

	Rem
	bbdoc: Returns the canvas for this grid.
	returns: TGadget
	endrem
	Method GetCanvas:TGadget()
		Return canvas
	End Method

	Rem
	bbdoc: Sets the name of the grid.
	endrem
	Method SetLabel(newName:String)
		label = newName
	End Method

	Rem
	bbdoc: Returns the name of the grid.
	endrem
	Method GetLabel:String()
		Return label
	End Method

	rem
	bbdoc: Returns the grid size.
	endrem
	Method GetGridSize:Int()
		Return gridSize
	End Method

	rem
	bbdoc: Sets the grid size, in a range of 1-32
	endrem
	Method SetGridSize(s:Int)
		If s <= 1 Then s = 1
		If s > 32 Then s = 32
		gridSize = s
	End Method

	rem
	bbdoc: Returns the grid zoom level.
	endrem
	Method GetZoomLevel:Float()
		Return zoomLevel
	End Method

	Rem
	bbdoc: Sets the grid zoom level.
	endrem
	Method SetZoomLevel(z:Float)
		zoomLevel = z
	End Method

	Rem
	bbdoc: Set visible flag.
	endrem
	Method SetVisible(bool:Int)
		visible = bool
	End Method

	Rem
	bbdoc: Returns visible flag.
	endrem
	Method GetVisible:Int()
		Return visible
	End Method

	rem
	bbdoc: Sets grid snap option.
	endrem
	Method SetGridSnap(bool:Int)
		snapToGrid = bool
	End Method

	rem
	bbdoc: Returns grid snap option value.
	endrem
	Method GetGridSnap:Int()
		Return snapToGrid
	End Method

	Rem
	bbdoc: Changes zoom up or down.
	endrem
	Method ChangeZoom(amount:Float)

		Local canvasCenter:TVector2D = New TVector2D.Create(ClientWidth(canvas) / 2,  ..
			ClientHeight(canvas) / 2)
		Local gridCenter:TVector2D = CanvasToGrid(canvasCenter)

		zoomLevel:+amount
		If zoomLevel >= 12 Then zoomLevel = 12
		If zoomLevel <= 0.5 Then zoomLevel = 0.5
		If zoomLevel > 0.5 Then zoomLevel = Floor(zoomLevel)

		Select zoomLevel
			Case 0.5, 1, 2
				gridSize = 16
			Case 3, 4
				gridSize = 8
			Case 5, 6
				gridSize = 4
			Case 7, 8, 9
				gridSize = 2
			Case 10, 11, 12
				gridSize = 1
		End Select

		CenterOnGridLocation(gridCenter)

		Local result:TVector2D = MouseToGrid()
		mouseGridPosition.Copy(result)
	End Method

	rem
	bbdoc: Centers grid on passed grid location.
	endrem
	Method CenterOnGridLocation(gridLocation:TVector2D)
		renderOffset.Set( (-gridLocation.GetX() * zoomLevel) + ClientWidth(canvas) / 2, ..
							(-gridLocation.GetY() * zoomLevel) + ClientHeight(canvas) / 2)
	End Method

	Rem
	bbdoc: Increases the grid size.
	about: Grid is changed by its grid size.
	endrem
	Method IncreaseGrid()
		gridSize:+gridSize
		If gridSize > 16 Then gridSize = 16
	End Method

	Rem
	bbdoc: Decreases the grid size.
	about: Grid is changed by its grid size.
	endrem
	Method DecreaseGrid()
		gridSize:-(gridSize / 2)
		If gridSize < 1 Then gridSize = 1
	End Method

	Rem
	bbdoc: Resets grid to default values.
	endrem
	Method Reset()
		SetVisible(True)
		SetGridSnap(True)
		SetZoomLevel(2)
		SetGridSize(8)
	End Method

	Rem
	bbdoc: Moves grid offset by vector.
	endrem
	Method Move(amount:TVector2D)
		renderOffset.AddV(amount)
	End Method

	Rem
	bbdoc: Updates the status text.
	endrem
	Method UpdateStatusText()
		Local result:TVector2D = MouseToGrid()

		Local zoom:String
		If zoomLevel = 0.5
			zoom = "0.5"
		Else
			zoom = String(Int(zoomLevel))
		EndIf

		statusLine = "Grid size: " + gridSize + ". Zoom level: " + zoom + ..
			". Position: " + Int(result.GetX()) + "," + Int(result.GetY()) + "."
	End Method

	rem
	bbdoc: Returns status text.
	endrem
	Method GetStatusText:String()
		Return statusLine
	End Method

	Rem
	bbdoc: Called when the mouse is moved over the canvas.
	endrem
	Method OnMouseMove( newX:Int, newY:Int)
		If mouseOnCanvas = False Then Return

		'scroll when right mouse button is held
		If rightMouseDown
			renderOffset.Add( newX - mouseCanvasPosition.GetX(), ..
								newY - mouseCanvasPosition.GetY())
		End If

		prev_MouseCanvasPosition.Copy(mouseCanvasPosition)
		mouseCanvasPosition.Set(newX, newY)

		prev_MouseGridPosition.Copy(mouseGridPosition)
		Local result:TVector2D = MouseToGrid()
		mouseGridPosition.Copy(result)
	End Method


	Rem
	bbdoc: Transforms grid position to canvas position.
	returns: TVector2D
	endrem
	Method GridToCanvas:TVector2D(gridPosition:TVector2D)'gridx:Float, gridy:Float)
		Local result:TVector2D = New TVector2D
		result.Set( gridPosition.GetX() * zoomLevel + renderOffset.GetX(), ..
					gridPosition.GetY() * zoomLevel + renderOffset.GetY())
		Return result
	End Method


	Rem
	bbdoc: Transforms canvas position to grid position.
	returns: TVector2D
	endrem
	Method CanvasToGrid:TVector2D(canvasPosition:TVector2D)'canvasX:Float, canvasY:Float)
		Local result:TVector2D = New TVector2D
		result.Set( (canvasPosition.GetX() / zoomLevel) - (renderOffset.GetX() / zoomLevel), ..
					(canvasPosition.GetY() / zoomLevel) - (renderOffset.GetY() / zoomLevel))
		Return result
	End Method


	rem
	bbdoc: Transforms mouse position to grid position.
	endrem
	Method MouseToGrid:TVector2D()
		Local result:TVector2D = New TVector2D
		Local pointx:Float = (mouseCanvasPosition.GetX() - renderOffset.GetX()) / zoomLevel
		Local pointy:Float = (mouseCanvasPosition.GetY() - renderOffset.GetY()) / zoomLevel

		If snapToGrid = False
			pointx = Round(pointx)
			pointy = Round(pointy)

			result.Set(pointx, pointy)
			Return result
		EndIf

		'snap to grid
		'this should be simpler. for now, it works
		Local leftOverX:Float = Abs(pointx Mod gridSize)
		If pointx > 0
			If leftOverX <= gridSize / 2
				pointx:-leftOverX
			Else
				pointx:+(gridSize - leftOverX)
			EndIf
		Else
			If leftOverX <= gridSize / 2
				pointx:+leftOverX
			Else
				pointx:-(gridSize - leftOverX)
			EndIf
		EndIf

		Local leftOverY:Float = Abs(pointy Mod gridSize)
		If pointy > 0
			If leftOverY <= gridSize / 2
				pointy:-leftOverY
			Else
				pointy:+(gridSize - leftOverY)
			EndIf
		Else
			If leftOverY <= gridSize / 2
				pointy:+leftOverY
			Else
				pointy:-(gridSize - leftOverY)
			EndIf
		EndIf

		pointx = Round(pointx)
		pointy = Round(pointy)

		result.Set(pointx, pointy)
		Return result
	End Method


	Rem
	bbdoc: Draws the grid.
	endrem
	Method Render()
		SetGraphics(CanvasGraphics(canvas))
		SetViewport 0, 0, GadgetWidth(canvas), GadgetHeight(canvas)

		SetClsColor backColor[0], backColor[1], backColor[2]
		Cls

		If Not visible Return

		If renderMethod = GRID_RENDER_LINES
			SetLineWidth 1
			SetOrigin 0,0
			SetScale 1,1

			'draw the grid lines
			If zoomLevel * gridSize > 2
				SetColor(gridColor[0], gridColor[1], gridColor[2])
				RenderLines(gridSize)
			EndIf

			'draw fixed 32 sized grid
			SetColor(gridColor[0] - 30, gridColor[1] - 30, gridColor[2] - 30)
			RenderLines(32)

			'draw center axises
			SetLineWidth(2)
			SetColor axisColor[0], axisColor[1], axisColor[2]
			DrawLine 0, renderOffset.GetY(), GadgetWidth(canvas), renderOffset.GetY()
			DrawLine renderOffset.GetX(), 0, renderOffset.GetX(), GadgetHeight(canvas)
		EndIf

		'draw axis indicators
		'window must be created with clientcoords option
		Local x:Int = renderOffset.GetX()
		Local y:Int = renderOffset.GetY()

		If x < 0 Then x = 0
		If x > GadgetWidth(canvas) - 20 Then x = GadgetWidth(canvas) - 20
		If y < 0 Then y = 0
		If y > GadgetHeight(canvas) - 16 Then y = GadgetHeight(canvas) - 16

		DrawText("-X", 1, y)
		DrawText("+X", GadgetWidth(canvas) - 20, y)
		DrawText("-Y", x, 0)
		DrawText("+Y", x, GadgetHeight(canvas) - 16)

		'render friendly name
		SetColor 255,255,255
		DrawText(label, 5,5)
	End Method


	rem
	bbdoc: Draws the mouse position. White cross is drawn by default.
	endrem
	Method RenderMouse(drawCross:Int=true)
		If Not mouseOnCanvas Return

		SetGraphics(CanvasGraphics(canvas))

		SetLineWidth 1
		SetColor 255, 255, 50
		Local result:TVector2D = GridToCanvas(mouseGridPosition)
		Local x:Float = result.GetX()
		Local y:Float = result.GetY()

		DrawLine x - 3, y - 3, x + 3, y - 3
		DrawLine x - 3, y + 3, x + 3, y + 3
		DrawLine x - 3, y - 3, x - 3, y + 3
		DrawLine x + 3, y - 3, x + 3, y + 3
		
		If Not drawCross Return

		SetColor 255,255,255
		x = mouseCanvasPosition.GetX()
		y = mouseCanvasPosition.GetY()
		DrawLine x-12, y, x-4, y
		DrawLine x+4, y, x+12, y

		DrawLine x, y-12, x, y-4
		DrawLine x, y+4, x, y+12
	End Method


	Rem
	bbdoc: Renders grid lines at the passed size.
	endrem
	Method RenderLines(size:Int)

		'start drawing from the center of the grid
		Local x:Int
		Local y:Int
		Local width:Int = GadgetWidth(canvas)
		Local height:Int = GadgetHeight(canvas)

		'positive vertical lines
		x = renderOffset.GetX()
		While x <= width
			DrawLine x, 0, x, height
			x:+zoomLevel * size
		Wend

		'negative vertical lines
		x = renderOffset.GetX()
		While x >= 0
			DrawLine x, 0, x, height
			x:-zoomLevel * size
		Wend

		'positive horizontal lines
		y = renderOffset.GetY()
		While y <= height
			DrawLine 0, y, width, y
			y:+zoomLevel * size
		Wend

		'negative horizontal lines
		y = renderOffset.GetY()
		While y >= 0
			DrawLine 0, y, width, y
			y:-zoomLevel * size
		Wend
	End Method

End Type
