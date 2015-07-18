set nocompatible

call plug#begin('~/.vim/plugged')
Plug 'junegunn/vim-easy-align'
call plug#end()

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
set cursorline     "Highlight current line
set wildmenu       "Visual autocomplete for command menu

filetype plugin indent on "proper indents depending on file type

set ruler	
highlight ColorColumn ctermbg=magenta
call matchadd('ColorColumn', '\%81v', 100) "Set a grey ruler at 80 chars       >

colorscheme monokai
syntax enable
set so=998 "set scroll off so cursor is always as near as possible to centered
set backspace=indent,eol,start " make backspace behave in a sane manner

set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set undodir=~/.vim/undo//
set autoread

"keys to wrap lines on
set whichwrap+=<,>,h,l,[,]

vmap a <Plug>(LiveEasyAlign)
nmap ga <Plug>(LiveEasyAlign)
