if status is-interactive
    # Commands to run in interactive sessions can go here
end

function fish_greeting
    if set -q PIPENV_ACTIVE
    else
        fortune -as
    end
end

######################################### Alias #########################################

## open
alias open="xdg-open"

# wifi
alias wifi="nmtui"

## neovim
alias vim="nvim"
alias v="nvim"
alias nv="neovide"
set -gx EDITOR nvim
set -gx MANPAGER "nvim +Man!"

alias zj="zellij"

alias srm="trash"

alias lla="ls -lah"

# line count lc
alias lc="wc -l"
# back
alias b="cd -"

function lsd --description "ls that display folder first"
    eza -l --group-directories-first $argv
end

function lt --description "Dispaly tree like format for 'ls'"
    if test -z $argv[1]
        eza -T --level=1 --icons
    else
        eza -T --icons --level=$argv[1] $argv[2]
    end
end

function ytb --description "See Youtube video"
    if test -z $argv[1]
        echo "Usage: ytb <url>"
    else
        mpv $argv[1] --ytdl-format='bestvideo[height<=?1080][fps<=?30][vcodec!=?vp9]+bestaudio/bestaudio'
    end
end

function clone --description "Clone a github repository"
    if test -z $argv[1]
        echo "Usage: clone <repo_url> or <user/repo> if you have gh installed and logged in with gh auth login"
    else
        if string match -q http $argv[1]
            git clone $argv[1] $argv[2..-1]
        else
            gh repo clone $argv[1] $argv[2..-1]
        end
    end
end

function ntmp-help
    echo "Usage: ntemp <extension|options>"
    echo "   Create a new temporary file in the temp dir and open it in $EDITOR"
    echo ""
    echo "   Options:"
    echo "      -l           Get a list of all temporary files"
    echo "      -h           Show the current help"
end

function ntmp --description "Create a new temporary file in the temp dir and open it in $EDITOR"
    if test -z $argv[1]
        ntmp-help
    else if string match -q -r -- -l $argv[1]
        mkdir -p /tmp/ntmp
        lla /tmp/ntmp
    else if string match -q -r -- -h $argv[1]
        ntmp-help
    else
        mkdir -p /tmp/ntmp
        set name /tmp/ntmp/(uuidgen).$argv[1]
        touch $name
        $EDITOR $name
    end
end

function compareBin
    if test -z $argv[1]
        echo "Usage: compareBin <file1> <file2>\n\tShow diff between two bin files"
    else
        cmp -l $argv[1] $argv[2] | awk 'function oct2dec(oct,    dec) {
                  for (i = 1; i <= length(oct); i++) {
                      dec *= 8
                      dec += substr(oct, i, 1)
                }
                return dec
            }
            {
                printf "%08X %02X %02X\n", $1, oct2dec($2), oct2dec($3)
            }'
    end
end

function compareBinH
    if test -z $argv[1]
        echo "Usage: compareBinH <file1> <file2>\n\tShow diff between two bin files"
    else
        set uuid1 (uuidgen)
        set uuid2 (uuidgen)
        hexyl $argv[1] >/tmp/hexyl-$uuid1
        hexyl $argv[2] >/tmp/hexyl-$uuid2
        diff /tmp/hexyl-$uuid1 /tmp/hexyl-$uuid2
    end
end

alias cbin="compareBin"
alias cbinh="compareBinH"

function mkcd --description "Create a directory and cd into it"
    if test -z $argv[1]
        echo "Usage: mkcd <directory>"
        echo "Create a directory and cd into it"
        echo ""
    else
        mkdir -vp $argv[1]; and cd $argv[1]
    end
end

function soft-slugify
    echo $argv[1] | iconv -t ascii//TRANSLIT | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+\|-+$//g' | sed -E 's/^-+//g' | sed -E 's/-+$//g'
end

function hard-slugify
    echo $argv[1] | iconv -t ascii//TRANSLIT | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+\|-+$//g' | sed -E 's/^-+//g' | sed -E 's/-+$//g' | tr A-Z a-z
end

function slugify --description "Convert a string to a slug"
    if test -z $argv[1]
        echo "Usage: slugify [-s] <string>"
        echo "    Convert a string to a slug"
        echo "  -s: soft slugify, don't convert to lowercase"
    else if string match -q -r -- -s $argv[1]
        if test -z $argv[2]
            echo "Usage: slugify [-s] <string>"
            echo "    Convert a string to a slug"
            echo "  -s: soft slugify, don't convert to lowercase"
            echo "\nNo string given\n"
        else
            soft-slugify $argv[2]
        end
    else
        hard-slugify $argv[1]
    end
end

function add-font-usage
    echo "Usage: add-font <fontdir>"
    echo "    Add a font to the user fonts directory"
    echo ""
end

function acnew
    if test -z $argv[1]
        echo "acnew <sketch_name>"
    else
        arduino-cli sketch new $argv[1]
    end
end

function acup
    if test -z $argv[1]
        echo "acup <sketch_name> [arch] [port]"
    else
        set -x arch "arduino:avr:uno"
        set -x port /dev/ttyUSB0

        if test -z $argv[2]
        else
            set arch $argv[2]
        end
        if test -z $argv[3]
        else
            set port $argv[3]
        end

        if test -e sketch.yaml
        else
            echo ">> GENERATING SKETCH CONFIGURATION"
            arduino-cli board attach $argv[1] -b "$arch" --port $port
        end

        echo ">> COMPILING - $argv[1]"
        arduino-cli compile $argv[1] --build-path=./build --verbose | tee build.log

        echo ">> UPDATATING COMPILE FLAGS"
        grep -oP '(?<=\bg\+\+ ).*' build.log | head -n 1 | tr ' ' '\n' >compile_flags.txt
        rm -rf build.log

        echo ">> UPLOADING - $argv[1]"
        arduino-cli upload $argv[1] --build-path=./build --verbose --verify

    end
end

function add-font --description "Add a font to the user fonts directory"
    set add_fontFontDir /usr/local/share/fonts/
    set add_fontFonDirOtf /usr/local/share/fonts/otf/
    set add_fontFonDirTtf /usr/local/share/fonts/ttf/

    if test -z $argv[1]
        add-font-usage
    else
        sudo mkdir -p $add_fontFonDirTtf
        sudo mkdir -p $add_fontFonDirOtf
        set fontDir $argv[1]
        set fontName (basename $fontDir)
        set fontNameSlug (soft-slugify $fontName)

        set fontDirTtf $add_fontFonDirTtf$fontNameSlug
        set fontDirOtf $add_fontFonDirOtf$fontNameSlug

        for fontFile in $fontDir/*
            switch $fontFile
                case "*.ttf"
                    if not test -d $fontDirTtf
                        sudo mkdir -p $fontDirTtf
                    end
                    sudo cp -v $fontFile $fontDirTtf
                case "*.otf"
                    if not test -d $fontDirOtf
                        sudo mkdir -p $fontDirOtf
                    end
                    sudo cp -v $fontFile $fontDirOtf
                case '*'
                    echo "Unknown font file extension for $fontFile"
            end
        end
        fc-cache -f -v
    end
end

function vmrss --description "Show the memory usage of a process"
    set p $argv[1]
    if test -z $p
        echo "Usage: vmrss <pid>"
    else
        echo "pid: $p"
        while true
            cat /proc/$p/status | grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox} VmRSS | grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox} -o '[0-9]*' | awk '{print $1/1024 " MB";}'
            sleep 1
        end
    end
end

function test-wall --description "Test A Wallpaper"
    if test -z $argv[1]
        echo "Usage: test-wall <url>"
    else
        wget $argv[1] -O /tmp/test-wall
        awww img /tmp/test-wall --transition-type grow --transition-pos 0.854,0.977 --transition-step 90
    end
end

function dotnew --description "Create a new dotnet console project"
    if test -z $argv[1]
        echo "Usage: dotnew <project_name>"
    else
        dotnet new console -o $argv[1] && cd $argv[1] && slngen
    end
end

function ccc --description "Conventional Commits Cheatsheet"
    echo "# Quick examples
* `feat: new feature`
* `fix(scope): bug in scope`
* `feat!: breaking change` / `feat(scope)!: rework API`
* `chore(deps): update dependencies`

# Commit types
* `build`: Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
* `ci`: Changes to CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)
* **`chore`: Changes which doesn't change source code or tests e.g. changes to the build process, auxiliary tools, libraries**
* `docs`: Documentation only changes
* **`feat`: A new feature**
* **`fix`: A bug fix**
* `perf`: A code change that improves performance
* `refactor`:  A code change that neither fixes a bug nor adds a feature
* `revert`: Revert something
* `style`: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
* `test`: Adding missing tests or correcting existing tests

# Reminders
* Put newline before extended commit body
* More details at **[conventionalcommits.org](https://www.conventionalcommits.org/)** " | glow
end

alias pnpx='pnpm dlx'

alias nand2tetrisSimulator="$N2T_DIR/HardwareSimulator.sh"
alias nand2tetrisAssembler="$N2T_DIR/Assembler.sh"
alias nand2tetrisVMEmulator="$N2T_DIR/VMEmulator.sh"
alias nand2tetrisCompiler="$N2T_DIR/JackCompiler.sh"
alias nand2tetrisCPUEmulator="$N2T_DIR/CPUEmulator.sh"
alias nand2tetrisTextComparer="$N2T_DIR/TextComparer.sh"

# http-server
alias httpserve="npx http-server -p 5000 -a localhost"

# unimatrix
alias matrix="unimatrix -c red -s 96 -b -u '愛してる我喜欢你좋아해요'"

# moc
alias mocpg="mocp -T ~/.moc/themes/gruvbox_theme"

# reset gnome parameters
alias reset-gnome-param="dconf reset -f /org/gnome"

########################################### paths ###################################

function set_pkg_cfg_path
    set toadd /usr/local/lib/pkgconfig
    set initial (pkg-config --variable pc_path pkg-config)
    if not contains -- $toadd $initial
        set -gx PKG_CONFIG_PATH $initial:$toadd
    end
end

fish_add_path $HOME/.local/bin
fish_add_path $HOME/.config/emacs/bin

# set -gx RUST_LOG trace

# set -gx SOFTWARES_DIR $HOME/.bin/

# set -gx TUMUXIFIER_BIN $HOME/.config/tmux/plugins/tmuxifier/bin
# set -gx PATH $TUMUXIFIER_BIN $PATH
# eval (tmuxifier init - fish)

set -gx CHROME_EXECUTABLE /usr/bin/chromium-browser

set -gx GOPATH $HOME/go

set -gx N2T_DIR $HOME/Softwares/nand2tetris/tools

set -gx LESS -R

set -gx GPG_TTY (tty)

set -gx XDG_CONFIG_HOME $HOME/.config

set -gx GDK_BACKEND wayland

set_pkg_cfg_path

# tabtab source for packages
# uninstall by removing these lines
[ -f ~/.config/tabtab/fish/__tabtab.fish ]; and . ~/.config/tabtab/fish/__tabtab.fish; or true

# pnpm
set -gx PNPM_HOME "/home/luxluth/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

set -gx DOTNET_CLI_TELEMETRY_OPTOUT 1

# set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME
# set -gx PATH $HOME/.cabal/bin $PATH /home/luxluth/.ghcup/bin # ghcup-env

fish_add_path $HOME/.dotnet/tools # dotnet_tools

# bun
set --export BUN_INSTALL "$HOME/.bun"
fish_add_path $BUN_INSTALL/bin

# android sdk
set --export ANDROID_HOME "$HOME/Android/Sdk"

# # dbus-launch
# export $(dbus-launch)
# fish_add_path /home/luxluth/.pixi/bin
