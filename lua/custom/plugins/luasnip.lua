return {
    "L3MON4D3/LuaSnip",
    requires = "garbas/vim-snipmate",
    config = function()
        local ls = require("luasnip")
        local s = ls.snippet
        local sn = ls.snippet_node
        local t = ls.text_node
        local i = ls.insert_node
        local f = ls.function_node
        local c = ls.choice_node
        local d = ls.dynamic_node
        local r = ls.restore_node
        local l = require("luasnip.extras").lambda
        local rep = require("luasnip.extras").rep
        local p = require("luasnip.extras").partial
        local m = require("luasnip.extras").match
        local n = require("luasnip.extras").nonempty
        local dl = require("luasnip.extras").dynamic_lambda
        local fmt = require("luasnip.extras.fmt").fmt
        local fmta = require("luasnip.extras.fmt").fmta
        local types = require("luasnip.util.types")
        local conds = require("luasnip.extras.expand_conditions")

        local date = function() return { os.date('%Y-%m-%d') } end
        local f_path = function() return { vim.fn.expand("%:p") } end

        ls.add_snippets(nil, {
            all = {
                s({
                    trig = "date",
                    namr = "Date",
                    dscr = "Date in the form of YYYY-MM-DD"
                }, { f(date, {}) }),
                s({ trig = "fpath", namr = "filePath", dscr = "gets current file path" },
                    { f(f_path, {}) })
            }
        })

        -- snip_lua
        ls.add_snippets("lua", {
            s({ trig = "snp", namr = "snippet", dscr = "luasnip snippet" }, {
                t({ "s({", 'trig = "' }), i(1, "trigger"), t({ '",', 'namr = "' }),
                i(2, 'name'), t({ '",', 'dscr = "' }), i(3, 'description'),
                t({ '",', "}, {", '    t({"' }), i(4, "text"),
                t({ '"}),', "    i(0)", "})" })
            })
        }, { key = "lua" })

        -- snip_markdown
        ls.add_snippets('markdown', {
            s({ trig = "homework", namr = "homework", dscr = "markdown homework setup" },
                {
                    t({ "---", "title: " }), i(1, "hw_title"), t({ "", "date: " }), f(date, {}),
                    t({ "", "author: " }), i(2, "author"), t({
                    "", 'reference-section-title: "References"', 'link-citations: true',
                    'link-bibliography: true', 'header-includes:',
                    '- \\usepackage{cancel}', '- \\usepackage{fancyvrb}',
                    '- \\usepackage{listings}', '- \\usepackage{amsmath}',
                    '- \\usepackage[version=4]{mhchem}', '- \\usepackage{xcolor}',
                    '- \\lstset{breaklines=true}',
                    '- \\lstset{language=[Motorola68k]Assembler}',
                    '- \\lstset{basicstyle=\\small\\ttfamily}',
                    '- \\lstset{extendedchars=true}', '- \\lstset{tabsize=2}',
                    '- \\lstset{columns=fixed}', '- \\lstset{showstringspaces=false}',
                    '- \\lstset{frame=trbl}', '- \\lstset{frameround=tttt}',
                    '- \\lstset{framesep=4pt}', '- \\lstset{numbers=left}',
                    '- \\lstset{numberstyle=\\tiny\\ttfamily}',
                    '- \\lstset{postbreak=\\raisebox{0ex}[0ex][0ex]{\\ensuremath{\\color{red}\\hookrightarrow\\space}}}',
                    '- \\lstset{keywordstyle=\\color[rgb]{0.13,0.29,0.53}\\bfseries}',
                    '- \\lstset{stringstyle=\\color[rgb]{0.31,0.60,0.02}}',
                    '- \\lstset{commentstyle=\\color[rgb]{0.56,0.35,0.01}\\itshape}',

                    "---", ""
                }), i(0)
                }), s({
            trig = "hqpart",
            namr = "homeworkQuestionPart",
            dscr = "md hw question part"
        }, {
            t({ "#### Q " }), i(1, "a"), t({ "):", "", "", "#### A " }), i(2, "a"),
            t({ ":", "" }), i(0)
        }), s({
            trig = "python",
            namr = "pythoncodeblock",
            dscr = "Create Markdown Python codeblock"
        }, {
            t({ "<!-- target: " }), i(1, "targ"),
            t({ "-->", "```python", "import sympy as sp", "", "" }),
            i(0, "start coding"), t({ "", "", "```" })
        }), s({
            trig = "partials",
            namr = "partialDerivatives",
            dscr = "partial derivatives thermo"
        }, {
            t({ "(\\frac{\\partial " }), i(1, "num"), t({ "}{\\partial " }),
            i(2, "den"), t({ "})_{" }), i(3, "constants"), t({ "}" }), i(0)
        }), s({ trig = "hq", namr = "homeworkQuestion", dscr = "md hw question" }, {
            t({ "# Question " }), i(1, "number"),
            t({ "", "### Q:", "" }), i(2, ""), t({ "", "### A:", "" }), i(0)
        }), s({
            trig = "partials",
            namr = "partialDerivatives",
            dscr = "partial derivatives thermo"
        }, {
            t({ "(\\frac{\\partial " }), i(1, "num"), t({ "}{\\partial " }),
            i(2, "den"), t({ "})_{" }), i(3, "constants"), t({ "}" }), i(0)
        }), s({ trig = "frac", namr = "fraction", dscr = "latex math frac" },
            { t({ "\\frac{" }), i(1, "num"), t({ "}{" }), i(2, "dem"), t({ "}" }), i(0) }),
            s({ trig = "math", namr = "dollars", dscr = "double dollar" },
                { t({ "$$", "" }), i(1, "x = 0"), t({ "", "$$", "" }), i(0) }),
            s({ trig = "sum", namr = "summation", dscr = "summation math" },
                { t({ "\\sum_{" }), i(1, "i"), t({ "}^{" }), i(2, "N"), t({ "}" }), i(0) }),
            s({ trig = "int", namr = "integral", dscr = "integral" }, {
                t({ "\\int_{" }), i(1, "-\\infty"), t({ "}^{" }), i(2, "\\infty"), t({ "}" }),
                i(0)
            }), s({ trig = "angs", namr = "angles", dscr = "langle i rangle" },
            { t({ "\\langle " }), i(1, "X"), t({ " \\rangle " }), i(0) }),
            s({ trig = "exp", namr = "exp", dscr = "exp" },
                { t({ "e^{" }), i(1, "x"), t({ "}" }), i(0) }),
            s({ trig = "boltz", namr = "boltzmanexp", dscr = "boltzmanexp" },
                { t({ "e^{-\\beta E_{" }), i(1, "i"), t({ "}}" }), i(0) }),
            s({ trig = "choose", namr = "choose", dscr = "choose" },
                { t({ "{{" }), i(1, "n"), t({ "}\\choose{" }), i(2, "k"), t({ "}}" }), i(0) }),
            s({ trig = "bold", namr = "bold", dscr = "bold" },
                { t({ "**" }), i(1, "Word"), t({ "**" }), i(0) }),
            s({ trig = "emph", namr = "emph", dscr = "emph" },
                { t({ "*" }), i(1, "Word"), t({ "*" }), i(0) }),
            s({ trig = "img", namr = "img", dscr = "image" },
                { t({ "![](./images/" }), i(1, "image.png"), t({ ")" }), i(0) }),
            s({ trig = "bra", namr = "bra", dscr = "bra" },
                { t({ "\\langle " }), i(1, "\\psi"), t({ " | " }), i(0) }),
            s({ trig = "ket", namr = "ket", dscr = "ket" },
                { t({ " | " }), i(1, "\\psi"), t({ " \\rangle " }), i(0) }),
            s({ trig = "bk", namr = "bk", dscr = "bk" }, {
                t({ "\\langle " }), i(1, "\\psi_i"), t({ " | " }), i(2, "\\psi_j"),
                t({ "\\rangle " }), i(0)
            }), s({ trig = "bka", namr = "bka", dscr = "bka" }, {
            t({ "\\langle " }), i(1, "\\psi_i"), t({ " | " }), i(2, "A"), t({ " | " }),
            i(3, "\\psi_j"), t({ " \\rangle " }), i(0)
        }), s({ trig = "sub", namr = "subscript", dscr = "subscript" },
            { t({ "_{ " }), i(1, "i"), t({ " } " }), i(0) }),
            s({ trig = "sup", namr = "superscript", dscr = "superscript" },
                { t({ "^{ " }), i(1, "i"), t({ " } " }), i(0) }),
            s({ trig = "schr", namr = "schr", dscr = "schrodinger equation" },
                { t({ "Schrodinger Equation" }), i(0) }),
            s({ trig = "equation", namr = "equation", dscr = "simple equation" }, {
                t({ "\\begin{equation}", "    " }), i(1, "math_mode"),
                t({ "", "    \\label{eq:" }), i(2, "label"), t({ "}", "\\end{equation}" })
            })

        }, { key = 'markdown' })

        -- snip_latex
        ls.add_snippets('tex', {
            s({ trig = "equation", namr = "equation", dscr = "simple equation" }, {
                t({ "\\begin{equation}", "    " }), i(1, "math_mode"),
                t({ "", "    \\label{eq:" }), i(2, "label"), t({ "}", "\\end{equation}" })
            }), s({
            trig = "partials",
            namr = "partialDerivatives",
            dscr = "partial derivatives thermo"
        }, {
            t({ "(\\frac{\\partial " }), i(1, "num"), t({ "}{\\partial " }),
            i(2, "den"), t({ "})_{" }), i(3, "constants"), t({ "}" }), i(0)
        }), s({ trig = "fig", namr = "figure", dscr = "simple figure" }, {
            t({ "\\begin{figure}", '\\includegraphics{./figures/' }), i(1, "i.png"),
            t({ '}', '\\label{fg:' }), i(2, "label"), t({ "}", "\\caption{" }),
            i(3, "caption..."), t({ "}", "\\end{figure}" }), i(0)
        }), s({ trig = "itemize", namr = "itemize", dscr = "itemize" }, {
            t({ "\\begin{itemize}", "    \\item " }), i(1, "first"),
            t({ "", "\\end{itemize}" }), i(0)
        }), s({ trig = "enumerate", namr = "enumerate", dscr = "enumerate" }, {
            t({ "\\begin{enumerate}", "    \\item " }), i(1, "first"),
            t({ "", "\\end{enumerate}" }), i(0)
        }), s({
            trig = "partials",
            namr = "partialDerivatives",
            dscr = "partial derivatives thermo"
        }, {
            t({ "(\\frac{\\partial " }), i(1, "num"), t({ "}{\\partial " }),
            i(2, "den"), t({ "})_{" }), i(3, "constants"), t({ "}" }), i(0)
        }), s({ trig = "hq", namr = "homeworkQuestion", dscr = "md hw question" }, {
            t({ "# Question " }), i(1, "number"),
            t({ "", "### Q:", "", "", "### A:", "" }), i(0)
        }), s({
            trig = "partials",
            namr = "partialDerivatives",
            dscr = "partial derivatives thermo"
        }, {
            t({ "(\\frac{\\partial " }), i(1, "num"), t({ "}{\\partial " }),
            i(2, "den"), t({ "})_{" }), i(3, "constants"), t({ "}" }), i(0)
        }), s({ trig = "frac", namr = "fraction", dscr = "latex math frac" },
            { t({ "\\frac{" }), i(1, "num"), t({ "}{" }), i(2, "dem"), t({ "}" }), i(0) }),
            s({ trig = "math", namr = "dollars", dscr = "double dollar" },
                { t({ "$$", "" }), i(1, "x = 0"), t({ "", "$$", "" }), i(0) }),
            s({ trig = "sum", namr = "summation", dscr = "summation math" },
                { t({ "\\sum_{" }), i(1, "i"), t({ "}^{" }), i(2, "N"), t({ "}" }), i(0) }),
            s({ trig = "int", namr = "integral", dscr = "integral" }, {
                t({ "\\int_{" }), i(1, "-\\infty"), t({ "}^{" }), i(2, "\\infty"), t({ "}" }),
                i(0)
            }), s({ trig = "angs", namr = "angles", dscr = "langle i rangle" },
            { t({ "\\langle " }), i(1, "X"), t({ " \\rangle " }), i(0) }),
            s({ trig = "exp", namr = "exp", dscr = "exp" },
                { t({ "e^{" }), i(1, "x"), t({ "}" }), i(0) }),
            s({ trig = "boltz", namr = "boltzmanexp", dscr = "boltzmanexp" },
                { t({ "e^{-\\beta E_{" }), i(1, "i"), t({ "}}" }), i(0) }),
            s({ trig = "choose", namr = "choose", dscr = "choose" },
                { t({ "{{" }), i(1, "n"), t({ "}\\choose{" }), i(2, "k"), t({ "}}" }), i(0) }),
            s({ trig = "bold", namr = "bold", dscr = "bold" },
                { t({ "**" }), i(1, "Word"), t({ "**" }), i(0) }),
            s({ trig = "emph", namr = "emph", dscr = "emph" },
                { t({ "*" }), i(1, "Word"), t({ "*" }), i(0) }),
            s({ trig = "img", namr = "img", dscr = "image" },
                { t({ "![](./images/" }), i(1, "image.png"), t({ ")" }), i(0) }),
            s({ trig = "bra", namr = "bra", dscr = "bra" },
                { t({ "\\langle " }), i(1, "\\psi"), t({ " | " }), i(0) }),
            s({ trig = "ket", namr = "ket", dscr = "ket" },
                { t({ " | " }), i(1, "\\psi"), t({ " \\rangle " }), i(0) }),
            s({ trig = "bk", namr = "bk", dscr = "bk" }, {
                t({ "\\langle " }), i(1, "\\psi_i"), t({ " | " }), i(2, "\\psi_j"),
                t({ "\\rangle " }), i(0)
            }), s({ trig = "bka", namr = "bka", dscr = "bka" }, {
            t({ "\\langle " }), i(1, "\\psi_i"), t({ " | " }), i(2, "A"), t({ " | " }),
            i(3, "\\psi_j"), t({ " \\rangle " }), i(0)
        }), s({ trig = "sub", namr = "subscript", dscr = "subscript" },
            { t({ "_{ " }), i(1, "i"), t({ " } " }), i(0) }),
            s({ trig = "sup", namr = "superscript", dscr = "superscript" },
                { t({ "^{ " }), i(1, "i"), t({ " } " }), i(0) }),
            s({ trig = "schr", namr = "schr", dscr = "schrodinger equation" },
                { t({ "Schrodinger Equation" }), i(0) }),
            s({ trig = "equation", namr = "equation", dscr = "simple equation" }, {
                t({ "\\begin{equation}", "    " }), i(1, "math_mode"),
                t({ "", "    \\label{eq:" }), i(2, "label"), t({ "}", "\\end{equation}" })
            }),
            s({
                trig = "rq",
                namr = "ref equation",
                dscr = "reference equation in latex",
            }, {
                t({ "Equation \\ref{eq:" }),
                i(1, "eqLabel"),
                t({ "} " }),
                i(0)
            })

        }, { key = 'tex' })

        ls.add_snippets('cpp', {
            s({ trig = "for", namr = "for", dscr = "for" }, {
                t({ "for (int " }), i(1, "i"), t({ "; " }), i(2, "i"), t({ "< " }),
                i(3, "size"), t({ "; " }), i(4, "i"), t({ "++) {", "" }), i(0), t({ "", "}" })
            })
        }, { key = "cpp" })
        ls.autosnippets = { all = { s("autotrigger", { t("autosnippet") }) } }
    end,
}
