function! SetUp()
  call vimspector#test#setup#SetUpWithMappings( v:none )
endfunction

function! ClearDown()
  call vimspector#test#setup#ClearDown()
endfunction

function! SetUp_Test_Go_Simple()
  let g:vimspector_enable_mappings = 'HUMAN'
endfunction

function! Test_Go_Simple()
  let fn='hello-world.go'
  lcd ../support/test/go/hello_world
  exe 'edit ' . fn
  call setpos( '.', [ 0, 4, 1 ] )

  call vimspector#test#signs#AssertCursorIsAtLineInBuffer( fn, 4, 1 )
  call vimspector#test#signs#AssertSignGroupEmptyAtLine( 'VimspectorBP', 4 )

  " Add the breakpoint
  call feedkeys( "\<F9>", 'xt' )
  call vimspector#test#signs#AssertSignGroupSingletonAtLine( 'VimspectorBP',
                                                           \ 4,
                                                           \ 'vimspectorBP',
                                                           \ 9 )

  call setpos( '.', [ 0, 1, 1 ] )

  " Here we go. Start Debugging
  call feedkeys( "\<F5>", 'xt' )
  call vimspector#test#signs#AssertCursorIsAtLineInBuffer( fn, 4, 1 )

  " Step
  call feedkeys( "\<F10>", 'xt' )

  call vimspector#test#signs#AssertCursorIsAtLineInBuffer( fn, 5, 1 )
  call WaitForAssert( {->
        \ vimspector#test#signs#AssertPCIsAtLineInBuffer( fn, 5 )
        \ } )

  call vimspector#test#setup#Reset()

  lcd -
  %bwipeout!
endfunction

function! Test_Go_Simple_Adhoc_Config()
  let fn='hello-world.go'
  lcd ../support/test/go/hello_world
  exe 'edit ' . fn
  call setpos( '.', [ 0, 4, 1 ] )

  call vimspector#test#signs#AssertCursorIsAtLineInBuffer( fn, 4, 1 )
  call vimspector#test#signs#AssertSignGroupEmptyAtLine( 'VimspectorBP', 4 )

  " Add the breakpoint
  call feedkeys( "\<F9>", 'xt' )
  call vimspector#test#signs#AssertSignGroupSingletonAtLine( 'VimspectorBP',
                                                           \ 4,
                                                           \ 'vimspectorBP',
                                                           \ 9 )

  call setpos( '.', [ 0, 1, 1 ] )

  " Here we go. Start Debugging
  call vimspector#LaunchWithConfigurations({
  \  'run': {
  \    'adapter': 'vscode-go',
  \    'default': v:true,
  \    'configuration': {
  \      'request': 'launch',
  \      'program': '${workspaceRoot}/hello-world.go',
  \      'mode': 'debug',
  \      'dlvToolPath': '$HOME/go/bin/dlv',
  \      'trace': v:true,
  \      'env': { 'GO111MODULE': 'off' }
  \    }
  \  },
  \ })
  call vimspector#test#signs#AssertCursorIsAtLineInBuffer( fn, 4, 1 )

  " Step
  call feedkeys( "\<F10>", 'xt' )

  call vimspector#test#signs#AssertCursorIsAtLineInBuffer( fn, 5, 1 )
  call WaitForAssert( {->
        \ vimspector#test#signs#AssertPCIsAtLineInBuffer( fn, 5 )
        \ } )

  call vimspector#test#setup#Reset()

  lcd -
  %bwipeout!
endfunction


function! Test_Run_To_Cursor()
  let fn='hello-world.go'
  lcd ../support/test/go/hello_world
  exe 'edit ' . fn

  call vimspector#SetLineBreakpoint( fn, 4 )
  call vimspector#Launch()
  call vimspector#test#signs#AssertCursorIsAtLineInBuffer( fn, 4, 1 )
  call WaitForAssert( {->
        \ vimspector#test#signs#AssertPCIsAtLineInBuffer( fn, 4 )
        \ } )

  call cursor( 5, 1 )
  call vimspector#RunToCursor()
  call vimspector#test#signs#AssertCursorIsAtLineInBuffer( fn, 5, 1 )
  call WaitForAssert( {->
        \ vimspector#test#signs#AssertPCIsAtLineInBuffer( fn, 5 )
        \ } )

  call vimspector#test#setup#Reset()
  lcd -
  %bwipeout!
endfunction
