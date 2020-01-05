silent execute "!mpv --no-terminal --force-window" . shellescape(expand("%:p")) . "&" | buffer# | bdelete# | redraw! | syntax on
