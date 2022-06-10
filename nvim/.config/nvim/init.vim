""" Vim-Plug
call plug#begin()
  Plug 'scrooloose/nerdtree'
  Plug 'scrooloose/nerdcommenter'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'


  """ LSP Configs
  Plug 'neovim/nvim-lspconfig'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'onsails/lspkind-nvim'
  Plug 'jose-elias-alvarez/null-ls.nvim'
  Plug 'jose-elias-alvarez/nvim-lsp-ts-utils'
  Plug 'L3MON4D3/LuaSnip'
  Plug 'rafamadriz/friendly-snippets'


" QOL plugins
  Plug 'easymotion/vim-easymotion'
  Plug 'junegunn/vim-easy-align'
  Plug 'tpope/vim-surround'
  " Plug 'junegunn/rainbow_parentheses.vim'

  " Development
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'editorconfig/editorconfig-vim' " Use editorconfig if it is available
  Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
  " Plug 'W0rp/ale'
  Plug 'ryanoasis/vim-devicons'
  Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
  Plug 'mbbill/undotree'
  Plug 'tpope/vim-fugitive'
  Plug 'keith/swift.vim'
  Plug 'towolf/vim-helm'


  "" Syntax highlighting
  Plug 'vim-ruby/vim-ruby'

  "" Javascript & Typescript
  Plug 'HerringtonDarkholme/yats.vim'

  " Graphql 
  Plug 'jparise/vim-graphql'

  " Colors
  Plug 'morhetz/gruvbox'

  " Vim viki
  " Plug 'vimwiki/vimwiki'

  Plug 'ruanyl/vim-gh-line'


  Plug 'github/copilot.vim'


call plug#end()

let g:python3_host_prog = expand('/usr/bin/python3')

autocmd BufNewFile,BufRead .eslintrc set filetype=javascript

"general
let mapleader=","
filetype plugin on
set mouse=""
set hidden
set nowrap
set cursorline
set switchbuf=useopen
set backspace=indent,eol,start
set timeout
set timeoutlen=450
set inccommand=nosplit
set clipboard+=unnamedplus
set smartindent
set noerrorbells
set expandtab
set undodir=~/.vim/undodir
set re=0
set nomodeline
set modelines=0
syntax on
set pyx=3


" Set the chdir to the current open file
" set autochdir

"tab settings
set ai
set et
set sta
set ts=2
set sw=2
set sts=2

" set cmdheight=2
set nobackup
set nowritebackup
set updatetime=300

set encoding=utf-8

"searching
set showmatch
set ignorecase
set smartcase

"line numbers
set number
set relativenumber
set ruler 
set numberwidth=2

"listchars
set nolist

" necessary for language servers
" don't give |ins-completion-menu| messages.
set shortmess+=c

set updatetime=300
set nobackup
set nowritebackup


autocmd BufEnter *.ts :setlocal filetype=typescript
autocmd BufEnter *.js :setlocal filetype=javascript

autocmd BufEnter *.{js,jsx,ts,tsx} :syntax sync fromstart
autocmd BufLeave *.{js,jsx,ts,tsx} :syntax sync clear
autocmd FileType json syntax match Comment +\/\/.\+$+
autocmd BufNewFile,BufRead .eslintrc set filetype=javascript

lua require("klyve")
lua << EOF
require('telescope').setup{
  defaults = { 
    file_ignore_patterns = {"node_modules"},
  },
  pickers = {
    git_branch = {
      prompt = "Git branch: ",
      git_command = "git branch --color=always",
      parse_function = function(line)
        return line:match("%* (.+)")
      end
    },
  }
}
EOF

""" find_command = { "ag", "--ignore", "node_modules", "--follow", "-g"},
""" ag --follow --nocolor --ignore node_modules -g "" "ProvideUser"

" Color settings
" Opaque Background (Comment out to use terminal's profile)
set termguicolors
set background=light
" set background=dark
colorscheme gruvbox
let g:gruvbox_termcolors=16
" set guifont=Fura\ Code:h12
set guifont=FiraCode\ Nerd\ Font:h12

" quickly open a terminal
nmap <leader>vs <C-w>v<C-w>l:terminal<CR>
nmap <leader>sp <C-w>s<C-w>j:terminal<CR>

" Neovim :Terminal
tmap <Esc> <C-\><C-n>
tmap <C-w> <Esc><C-w>
"tmap <C-d> <Esc>:q<CR>
autocmd BufWinEnter,WinEnter term://* startinsert
autocmd BufLeave term://* stopinsert

" typing jk quickly will escape
inoremap jk <ESC>

" Quality of life
vnoremap < <gv
vnoremap > >gv

" I find myself misstyping these all the time, norwegian keyboard shift to :
cmap :W :w
cmap :WQ :wq
cmap :Wq :wq
cmap :wQ :wq
cmap :X :x

map  <Leader>t <Plug>(easymotion-bd-f)
nmap <Leader>t <Plug>(easymotion-overwin-f)

" s{char}{char} to move to {char}{char}
nmap s <Plug>(easymotion-overwin-f2)

" Move to line
map <Leader>L <Plug>(easymotion-bd-jk)
nmap <Leader>L <Plug>(easymotion-overwin-line)

" Move to word
map  <Leader>W <Plug>(easymotion-bd-w)
nmap <Leader>W <Plug>(easymotion-overwin-w)

" Nerd tree
let NERDTreeShowHidden=1
let g:NERDTreeIgnore = ['^node_modules$']
nmap <leader>q :NERDTreeToggle<CR>
nmap \ <leader>q

" Nerd commenter
let g:NERDSpaceDelims = 1
let g:NERDTrimTrailingWhitespace = 1

" Check if NERDTree is open or active
function! IsNERDTreeOpen()        
  return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
endfunction

" Call NERDTreeFind iff NERDTree is active, current window contains a modifiable
" file, and we're not in vimdiff
function! SyncTree()
  if &modifiable && IsNERDTreeOpen() && strlen(expand('%')) > 0 && !&diff
    NERDTreeFind
    wincmd p
  endif
endfunction

" Highlight currently open buffer in NERDTree
" autocmd BufEnter * call SyncTree()

" Focus mode
" nmap <leader>g :Goyo<CR>

" noh
nmap <silent><Esc><Esc> :noh<CR>

" Convenience move maps
nmap <Tab> :bnext<CR>
nmap <S-Tab> :bprevious<CR>
nmap <C-h> <C-w>h
nmap <C-l> <C-w>l
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-x> <C-w>x

" FZF
" xmap <leader>f :FZF<CR>
" nmap <leader>f :FZF<CR>
" let g:fzf_buffers_jump = 1
" [[B]Commits] Customize the options used by 'git log':
" let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'
"

nnoremap <leader>f <cmd>Telescope find_files hidden=true<cr>
nnoremap <leader>ff <cmd>Telescope find_files hidden=true<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" fugitive
nmap <leader>gs :G<CR>
nmap <leader>gc :Gcommit<CR>
nmap <leader>gf :diffget //2<CR>
nmap <leader>gj :diffget //3<CR>



nmap <leader>gl :Git log<cr>

" Reload VIMRC in all windows on save
if !exists("*ReloadVimrc")
    function! ReloadVimrc()
        let save_cursor = getcurpos()
        source $MYVIMRC
        call setpos('.', save_cursor)
    endfunction
    com! ReloadVimrc :call ReloadVimrc()
endif
autocmd! BufWritePost $MYVIMRC call ReloadVimrc()

" Enable limelight in goyo
" function! s:goyo_enter()
  " if executable('tmux') && strlen($TMUX)
    " silent !tmux set status off
    " silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
  " endif
  " set noshowmode
  " set noshowcmd
  " set scrolloff=999
  " Limelight
" endfunction

" function! s:goyo_leave()
  " if executable('tmux') && strlen($TMUX)
    " silent !tmux set status on
    " silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
  " endif
  " set showmode
  " set showcmd
  " set scrolloff=5
  " Limelight!
" endfunction

" autocmd! User GoyoEnter nested call <SID>goyo_enter()
" autocmd! User GoyoLeave nested call <SID>goyo_leave()
"

" Transparent VIM mode
let t:is_transparent = 1


" Set the transparency based on the default value
if t:is_transparent == 1
  hi Normal guibg=NONE ctermbg=NONE
endif

function! Toggle_transparent_background()                                                       
  if    t:is_transparent == 1
    hi  Normal guibg=#292929
    let t:is_transparent = 0
  else
    hi  Normal guibg=NONE ctermbg=NONE
    let t:is_transparent = 1
  endif
endfunction

nnoremap <C-x><C-t> :call Toggle_transparent_background()<CR>

vmap <leader>r :normal @

" cheat.sh mapping
" let g:CheatSheetDoNotMap=1
" set runtimepath+=,/some/absolute/path/to/sql_runner.vim
" set runtimepath+=/Users/bjarte/.go/src/github.com/klyve/cheatsh.vim

let g:copilot_filetypes = { "markdown": 1, "yaml": 1 }


" VimWiki
" let g:vimwiki_list = [{'path': '~/vimwiki', 'syntax': 'markdown', 'ext': '.md'},
      " \ {'path': '~/.go/src/github.com/rakentaa/services/wiki', 'syntax': 'markdown', 'ext': '.md'}]


" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "c",
    "lua",
    "rust",
    "go",
    "bash",
    "cpp",
    "dockerfile",
    "graphql",
    "html",
    "http",
    "javascript",
    "json",
    "make",
    "python",
    "ruby",
    "typescript",
    "css"
  },

  ignore_install = {}, -- List of parsers to ignore installing
  highlight = {
    enable = true,              -- false will disable the whole extension
    disable = {},  -- list of language that will be disabled
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  }, }
EOF
