
'test setup to try the grid2d

Import wdw.grid2d

Local app:TMyApp = New TMyApp
app.GridRender()

While WaitEvent()
	app.Update()
Wend


Type TMyApp

	'window
	Field w:TGadget
	'render canvas
	Field c:TGadget
	'the grid
	Field g:TGrid2D

	Method New()
		w = CreateWindow("grid",0,0,400,400,Null, ..
				WINDOW_MENU|WINDOW_CENTER|WINDOW_TITLEBAR|WINDOW_STATUS|WINDOW_RESIZABLE|WINDOW_CLIENTCOORDS)
		c = CreateCanvas(0,0,400,400,w)
		SetGadgetLayout(c, EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED)
		g = New TGrid2D
		g.SetCanvas(c)
		g.SetLabel("Example Grid")

		'add a hook so we can get modal events as well (resizing window)
		AddHook(EmitEventHook, MyEventHandler, Self)
	End Method


	Method Update()
		Select EventID()
			Case EVENT_APPTERMINATE, EVENT_WINDOWCLOSE
				End
		End Select
	End Method


	Function MyEventHandler:Object(id:Int, data:Object, context:Object)

		' call the OnMyEvent() method in this TMyApp
		If data Then TMyApp(context).OnMyEvent(TEvent(data))
		' allow event to be processed by other handlers
		Return data
	End Function


	Method OnMyEvent(event:TEvent)
		If event.source = c And event.id = EVENT_GRID_REDRAW
			GridRender()
		EndIf
	End Method


	Method GridRender()
		g.Render()

		'render application objects on grid
		' ...

		g.RenderMouse()
		g.UpdateStatusText()
		SetStatusText(w, g.GetStatusText())

		Flip
	End Method


End Type
