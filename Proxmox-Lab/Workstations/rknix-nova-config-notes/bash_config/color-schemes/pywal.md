# Pywal

Pywal is a tool that generates a color palette from the dominant colors in an image. It then applies the colors system-wide and on-the-fly in all of your favourite programs.

## Files

- Color scheme directory: `~/.cache/wal/schemes/`
- Solar Canyon Theme:  `~/.cache/wal/schemes/_home_ricky_Pictures_Wallpapers_solar_canyon_jpg_dark_None_None_1.1.0.json`
- Garden Pathway: `~/.cache/wal/schemes/_home_ricky_Pictures_Wallpapers_louis-thai-unsplash_jpg_dark_None_None_1.1.0.json`
- Autumn Glow: `~/.cache/wal/shemes/_home_ricky_Pictures_Wallpapers_freepik__pixel-art-8bits-a-dimly-lit-forest-path-with-a-glo__36965_png_dark_None_None_1.1.0.json`

## PyWalFox Themes

### Garden Pathway

#### Palette

    body,
    body.light,
    body.dark {
      --background:#090D06;
      --background-light:#1a2511;
      --background-extra:#141d0e;
      --text:#E2B58D;
      --text-focus:#E0A063;
      --accent-primary:#A9652D;
      --accent-secondary:#1a2511;
    }

## Help File Output

`$ wal -h`

    usage: wal [-h] [-a "alpha"] [-b background] [--backend [backend]]
               [--theme [/path/to/file or theme_name]] [--iterative]
               [--saturate 0.0-1.0] [--preview] [--vte] [-c]
               [-i "/path/to/img.jpg"] [-l] [-n] [-o "script_name"] [-q] [-r] [-R]
               [-s] [-t] [-v] [-e]

wal - Generate colorschemes on the fly

options:

| option                           | description                                                                                                     |
| :------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| -h, --help                       | show this help message and exit                                                                                 |
| -a "alpha"                       | Set terminal background transparency. *Only works in URxvt*                                                     |
| -b background                    | Custom background color to use.                                                                                 |
| --backend [backend]              | Which color backend to use. Use 'wal --backend' to list backends.                                               |
| --theme                          | [/path/to/file or theme_name],                                                                                  |
| -f [/path/to/file or theme_name] | Which colorscheme file to use. Use 'wal --theme' to list builtin themes.                                        |
| --iterative                      | When pywal is given a directory as input and this flag is used: Go through images in order instead of shuffled. |
| --saturate 0.0-1.0               | Set the color saturation.                                                                                       |
| --preview                        | Print the current color palette.                                                                                |
| --vte                            | Fix text-artifacts printed in VTE terminals.                                                                    |
| -c                               | Delete all cached colorschemes.                                                                                 |
| -i "/path/to/img.jpg"            | Which image or directory to use.                                                                                |
| -l                               | Generate a light colorscheme.                                                                                   |
| -n                               | Skip setting the wallpaper.                                                                                     |
| -o "script_name"                 | External script to run after "wal".                                                                             |
| -q                               | Quiet mode, don't print anything.                                                                               |
| ~~-r~~                           | 'wal -r' is deprecated: Use (cat ~/.cache/wal/sequences &) instead.                                             |
| -R                               | Restore previous colorscheme.                                                                                   |
| -s                               | Skip changing colors in terminals.                                                                              |
| -t                               | Skip changing colors in tty.                                                                                    |
| -v                               | Print "wal" version.                                                                                            |
| -e                               | Skip reloading gtk/xrdb/i3/sway/polybar                                                                         |
