SuperStrict

Framework bah.maxunit

Import wdw.grid2d

Include "source/grid_test.bmx"

'Global w:TGadget = CreateWindow("test",0,0,400,400,Null, WINDOW_HIDDEN | WINDOW_CLIENTCOORDS)
'Global c:TGadget = CreateCanvas(0,0,400,400, w)

New TTestSuite.run()

'c = Null
'w = Null
