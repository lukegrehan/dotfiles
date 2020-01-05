call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'ntpeters/vim-better-whitespace'
Plug 'romainl/vim-cool'
Plug 'ajh17/VimCompletesMe'
Plug 'kyoz/purify', { 'rtp': 'vim' }
call plug#end()

colorscheme purify
let g:purify_italic = 0

set number         "Absolute line number on current line
set relativenumber "Relative numbers elsewhere
set linebreak      "Break long lines
set showbreak=\\   "Add a '\' to the start of a wrapped line
set showmatch      "Show matching brackets
set visualbell     "Use a visual bell (makes awesome mark window as 'urgent')
set incsearch      "Incremental search
set hlsearch       "Highlight search terms
set smartcase	   "Having smart and ignore case means a query with an uppercase
set ignorecase     "  letter will use the exact case of the query and will
                   "  ignore case otherwise
set autoindent	   "Auto indent on newline
set tabstop=4      "Number of visual spaces/<Tab>
set softtabstop=2  "Number of spaces entered by <Tab>
set shiftwidth=2   "spaces/<<<>
set expandtab      "Tabs are spaces
set wildmenu       "Visual autocomplete for command menu
set gdefault       "Global replace by default
set confirm        "Confirm save on exit
set termguicolors  "True colour support
set exrc           "Project specific .vimrc files
set secure
set hidden         "Open buffers without neccessarily saving

if &term =~# '^screen' "tmux magic
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

let mapleader = " " "<Leader> = <Space>

let g:netrw_banner=0    "No banner
let g:netrw_liststyle=3 "Tree style

filetype plugin indent on "proper indents depending on file type

set ruler
call matchadd('ColorColumn', '\%81v', 300) "Set a grey ruler at 80 chars       >

syntax enable
set so=999 "set scroll off so cursor is always as near as possible to centered
set backspace=indent,eol,start " make backspace behave in a sane manner

set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set undodir=~/.vim/undo//

"keys to wrap lines on
set whichwrap+=<,>,h,l,[,]

"Unhighlight searches
nnoremap <leader><space> :noh<cr>

"Dual of J; split line at cursor
nnoremap K i<CR><Esc>

"Next buffer
nnoremap <leader>n :bn<cr>

"Allow . in visual mode
vnoremap . :norm.<CR>

"Allow global filters
nnoremap g! :%!

function! MkScratch()
 setlocal buftype=nofile
 setlocal bufhidden=hide
 setlocal noswapfile
 setlocal buflisted
endfunction
nnoremap <leader>s :call MkScratch()<cr>

