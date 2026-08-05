# Useful Commands

## SSH Management Commands

### `tmux`

tmux detaches your program from your SSH client, not from the server. Once rsync is running in a tmux pane on the Proxmox host, it keeps running even if your SSH connection from your laptop drops. You can reconnect later and reattach to the same tmux session.

You do not need to launch your SSH session with `nohup` if you plan to run `rsync` inside `tmux` on your Proxmox server. The proper workflow is:

- SSH into Proxmox normally (no need for nohup).

- Start or attach to a tmux session.

- Run your rsync command directly inside tmux.

- Detach from tmux with Ctrl+b d and logout if needed.

tmux keeps your session and processes running even if your SSH disconnects, so nohup is redundant here. Nohup would be needed if you ran rsync outside tmux and wanted it to survive logout, but using tmux alone is the recommended, more flexible approach for long-running commands like rsync on Proxmox.

### Reattach to tmux session

1. SSH to your Proxmox host:

   ```bash
   ssh root@192.168.1.100
   ```

2. List active tmux sessions:

   ```bash
   tmux list-sessions
   ```

   Output example:

   ```
   0: 1 windows (created Mon Dec 1 10:00:00 2025) [80x24]
   ```

3. Reattach to the session (replace `0` with your session number/name):

   ```bash
   tmux attach-session -t 0
   ```

   Or simply:

   ```bash
   tmux attach
   ```

   (attaches to the most recent session if only one exists)

## Check rsync progress

Once reattached, you'll see exactly where rsync left off—its `--progress` output continues live.

- **If rsync is still running**: You'll see the real-time transfer stats (files transferred, speed, ETA).
- **If rsync finished**: You'll see the final summary stats.

## Common tmux controls while monitoring

- `Ctrl+b d` → Detach from tmux (rsync keeps running)
- `Ctrl+b :` → Enter tmux command mode
- `Ctrl+b ?` → Show all tmux key bindings

## If you have multiple sessions

```bash
tmux list-sessions -F '#{session_name} #{session_windows} #{session_attached}'
```

Then attach to a specific one:

```bash
tmux attach -t movies-rsync
```

## Kill rsync if needed

If you need to stop it:

- `Ctrl+C` (sends SIGINT to rsync)
- Or find the PID and kill:

  ```bash
  ps aux | grep rsync
  kill <PID>
  ```

The beauty of tmux is you get back to exactly where you left off, with rsync's live progress display intact.

### `nohup`

nohup (“no hangup”) is a small Unix command that lets a process keep running even after you close the terminal or your SSH session logs out. It does this by making the process ignore the SIGHUP (“hang up”) signal that is normally sent when a controlling terminal goes away.

### What nohup does

- Prevents the wrapped command from being killed when you log out or your SSH connection drops (because SIGHUP is ignored).
- Redirects output to a file (by default nohup.out in the current directory) if you don’t specify your own redirection.
- Is usually combined with & so the command runs in the background and releases your terminal prompt.

Importantly, nohup does not make the process immortal: it still dies if the system reboots, or if it gets SIGTERM/SIGKILL from an admin or the kernel.

### Basic usage pattern

Common syntax:

- Foreground (keeps running after logout, output to nohup.out):
  - nohup your-command arg1 arg2
- Background, freeing your shell:
  - nohup your-command arg1 arg2 &

Typical example for a long copy:

- nohup rsync -av /source/ /dest/ > rsync.log 2>&1 &  

Here:

- \> rsync.log sends stdout to rsync.log.  
- 2>&1 sends stderr to the same place as stdout.  
- & runs it in the background so you get your prompt back.

### Where the output goes

If you do not redirect anything:

- nohup your-command &  

nohup prints a one-line message and writes all output to nohup.out (in the current directory, or $HOME if it cannot write there).
You can watch progress from another terminal with:

- tail -f nohup.out

Because nohup.out can grow large, it is good practice to explicitly redirect to a log file you choose.

### Checking and stopping a nohup job

After starting a nohup background job, you will normally see a PID printed. To manage it later:

- List your running processes:
  - ps aux | grep your-command  
- Or use pgrep:
  - pgrep -a your-command
- Stop it:
  - kill <PID>  
  - If it won’t stop gracefully, use:
    - kill -9 <PID>

nohup does not change how you manage or signal the process; it only protects it from SIGHUP.

### When to use nohup vs tmux/screen

nohup is ideal when:

- You want to fire off a long, non-interactive command (rsync, backup, encoding script) and safely disconnect.  
- You don’t need to interact with the command again, only maybe read its log.  

For interactive work (shells where you type commands, editors, REPLs), a terminal multiplexer like tmux/screen is usually better, because you can reattach and see the session exactly as you left it. nohup alone cannot reattach an interactive TTY; it just keeps the process running.

## Backup & File Copy Commands

### `rsync`

### Options `a` and `--delete`

`rsync -a --delete` does two related but different things: `-a` makes rsync compare and preserve metadata so it can skip files that are already identical, and `--delete` makes the destination a true mirror of the source by removing extra files. Together they let you re‑run the same command after an interruption and have rsync only transfer what’s needed, instead of re-copying everything.

### What `-a` (archive) does for resuming

`-a` is shorthand for a bundle of options (recursive copy, preserve permissions/ownership/timestamps, etc.). The key parts for resuming are:

- rsync builds a file list on both sides (source and destination) and compares metadata like size and modification time for each path.  
- If a file on the destination has the same size and timestamp (and some other attributes) as on the source, rsync marks it as “up to date” and skips sending its contents.  
- If a file is missing, changed in size, or differs in timestamp, rsync transfers only that file.  

So if your first run is interrupted halfway through, a second `rsync -a` over the same source and destination will:

- Quickly scan through the directory tree.  
- Skip all files that were fully copied the first time.  
- Only send the ones that never got copied or have changed since.  

This is why re-running `rsync -a` doesn’t “start from scratch” in terms of data transfer—it only re-walks the tree, then selectively copies.

### Where `--delete` fits in

By default, rsync *does not* remove anything from the destination. If you delete or move files on the source, they would linger on the destination unless you clean them up manually.

`--delete` changes that behavior:

- After deciding which files to copy or update, rsync also removes any files/directories in the destination that no longer exist in the source.  
- The end result is that the destination becomes an exact mirror of the source: same files, same metadata, and no extras.  

This is especially useful when you repeatedly run rsync as a “sync” job rather than a “just copy new stuff” job.

## How this works when you re-run after an interruption

Imagine:

- First run: `rsync -a --delete /src/ /dest/`  
  - It starts copying lots of files, then the connection dies halfway.

- Second run: you use the *same* command again.

On the second run:

1. rsync walks `/src` and `/dest` again to build the file lists.  
2. For each path:
   - If `/dest/file` already matches `/src/file` (same size and mtime), rsync does nothing for that file.  
   - If `/dest/file` is missing or different, rsync transfers it.  
3. With `--delete`, rsync also removes any files that are in `/dest` but not in `/src`.  

So:

- Already-completed copies are not retransferred.  
- Partially copied files might be retransferred (rsync can use its delta algorithm, but from your point of view it just “fixes” them).  
- Any extra junk on the destination side is cleaned up to match the source.  

That’s what is meant by “resume/finish copying only the missing or changed files rather than starting from scratch”: rsync always does a fresh comparison, but thanks to `-a` it can skip unchanged files, and thanks to `--delete` it can also remove any extra files so the destination truly reflects your source.

### Two practical tips

- Always test with `--dry-run` first when using `--delete`, so you see what would be removed:
  - `rsync -av --delete --dry-run /src/ /dest/`  
- For long-running transfers you expect to resume, use the same source and destination paths and the same options each time; rsync’s logic depends on being able to compare “like with like.”
