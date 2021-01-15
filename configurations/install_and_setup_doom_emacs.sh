#!/bin/env bash

if [ -d $HOME/.doom.d ]; then
    echo "Doom already installed. Exiting."
    exit 1
fi

backup () {
        echo "Backing up: $1"
        mv -v "${1}"{,-OLD}
}

if [ -d ~/.emacs.d ] ; then
        backup ~/.emacs.d
fi

echo "Cloning emacs doom ..."
git clone https://github.com/hlissner/doom-emacs.git --depth 1 -b develop ~/.emacs.d

echo "CONFIGURING doom emacs ..."

mkdir -p ~/.doom.d 2>/dev/null

FNAME=~/.doom.d/packages.el
echo "-> ${FNAME}"
backup_file "${FNAME}"
cat <<EOF > "${FNAME}"
(package! modus-vivendi-theme)
(package! modus-operandi-theme)
(package! try)
EOF


FNAME=~/.doom.d/config.el
echo "-> ${FNAME}"
backup_file "${FNAME}"
cat <<EOF > "${FNAME}"
(setq user-full-name "NAME"
      user-mail-address "EMAIL@gmail.com")
;;(setq doom-theme 'doom-one)
(setq org-directory "~/Dropbox/TODO/")
(setq display-line-numbers-type t)
(add-hook 'org-mode-hook 'turn-on-auto-fill)
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(setq doom-theme 'modus-vivendi)
(add-to-list 'exec-path "/usr/local/bin/")
(setq enable-local-variables :safe)
(menu-bar-mode 1)
(setq confirm-kill-emacs nil)
;;(setq ccls-executable "/usr/local/bin/ccls")
EOF

FNAME=~/.doom.d/init.el
echo "-> ${FNAME}"
backup_file "${FNAME}"
cat <<EOF > "${FNAME}"
(doom! :completion
        company
        ivy
        :ui
        doom
        doom-dashboard
        doom-quit
        hl-todo
        hydra
        minimap
        modeline
        ;ophints
        ;(popup +defaults)
        neotree
        :editor
        file-templates
        fold
        snippets
        :emacs
        dired
        electric
        undo
        :term
        vterm
        :checkers
        syntax
        :tools
        (eval +overlay)
        lsp
        magit
        make
        pdf
        :lang 
        (cc)
        emacs-lisp
        latex
        markdown
        org
        python
        sh
        :email
        :app
        calendar
        :config
        (default +smartparens)
)
EOF

echo "Installing emacs doom ..."
cd $HOME
yes y | ~/.emacs.d/bin/doom install

#echo "Running sync and build"
#~/.emacs.d/bin/doom sync
#~/.emacs.d/bin/doom build

echo "Done."
