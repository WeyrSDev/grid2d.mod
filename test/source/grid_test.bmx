
'unit tests for wdw.grid2d

Type TTestGrid Extends TTest

	Field g:TGrid2D


	Method SetUp() {before}
		g = New TGrid2D
'		g.SetCanvas(c)
	End Method

	Method CleanUp() {after}
		g = Null
	End Method

	Method Constructor() {test}
		assertNotNull(g)
		assertNotNull(g.mouseGridPosition)
		assertNotNull(g.prev_MouseGridPosition)
		assertNotNull(g.mouseCanvasPosition)
		assertNotNull(g.prev_MouseCanvasPosition)
		assertNotNull(g.renderOffset)
	End Method

	Method DefaultSettings() {test}
		assertEqualsI(2, g.GetZoomLevel())
		assertEqualsI(8, g.GetGridSize())
		assertEqualsI(GRID_RENDER_LINES, g.renderMethod)
	End Method

	Method SetAndGetLabel() {test}
		g.SetLabel("yo")
		assertEquals("yo", g.GetLabel())
	End Method

	'can we change zoom
	Method testZoom() {test}
'		g.ChangeZoom(5)

		'default zoom is 6
'		assertEqualsI(11, g.zoomLevel)
	End Method

	'can we increase grid
	Method testIncreaseGrid() {test}
		g.IncreaseGrid()
		'default = 8. max size is 16
		assertEqualsI(16, g.gridSize)
	End Method

	'can we decrease grid
	Method testDecreaseGrid() {test}
		g.DecreaseGrid()

		'default size is 8
		assertEqualsI(4, g.gridSize)
	End Method

	'can we move grid
	Method testMoveGrid() {test}
		g.Move(TVector2D.Create(10, 15))

		assertEqualsI(10, g.renderOffset.GetX())
		assertEqualsI(15, g.renderOffset.GetY())
	End Method

'	can we set visible flag
	Method testSetVisible() {test}
		g.SetVisible(False)
		assertFalse(g.GetVisible())
	End Method

End Type
