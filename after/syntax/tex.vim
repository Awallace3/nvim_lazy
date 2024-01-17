syn match latexEqPattern "eq:\w\+"
syn match latexTabPattern "tab:\w\+"
syn match latexFigPattern "fg:\w\+"
syn match latexCitePattern "cite{\w*.*}"
syn match latexRefPattern "ref{\w*.*}" containedin=texComment

syn match latexEqPatternComment "eq:\w\+" containedin=texComment
syn match latexTabPatternComment "tab:\w\+" containedin=texComment
syn match latexFigPatternComment "fg:\w\+" containedin=texComment
syn match latexCitePatternComment "cite{\w*.*}" containedin=texComment
syn match latexRefPatternComment "ref{\w*.*}" containedin=texComment

syn match latexTabularPatternComment "{tabular*.*" containedin=texComment

hi link latexEqPattern SpecialComment
hi link latexTabPattern SpecialComment
hi link latexFigPattern SpecialComment
hi link latexCitePattern SpecialComment
hi link latexRefPattern SpecialComment
hi link latexEqPatternComment SpecialComment
hi link latexTabPatternComment SpecialComment
hi link latexFigPatternComment SpecialComment
hi link latexCitePatternComment SpecialComment
hi link latexRefPatternComment SpecialComment
hi link latexTabularPatternComment SpecialComment
