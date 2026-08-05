# GNOME Night Light Command & Control

*Control GNOME Night Light Settings With Commands & Keyboard Shortcuts*

## Commands

First, let's have a look at the commands we can use to control, schedule, and adjust the Night Light settings in GNOME. 

### On

#### Command to turn Night Light on:

```
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
```
### Off

#### To turn Night Light off:

```
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled false
```
### Scheduling

#### To schedule Night Light ON at a specific time
*Here I want to schedule night light to turn on from 23:06 hrs (that is 06/60=0.1):*

```
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 23.1
```

#### To schedule Night Light OFF at a specific time
*I want to schedule night light off at 23:25 hrs (that is 25/60=0.416666666):*

```
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 23.416666666
```
### Adjust Temprature (brightness)

You can also set the night light temperature which will increase and decrease the brightness, `4000` is the default value for Ubuntu 18.04, you can try different values for example `2000`, `3000`, `5000`, `6000`, `10000` and set the preferred ones:

```
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000
```
### Get (View) Current Values
To get the current values for above commands, run the below commands

```
gsettings get org.gnome.settings-daemon.plugins.color night-light-enabled 

gsettings get org.gnome.settings-daemon.plugins.color night-light-schedule-from

gsettings get org.gnome.settings-daemon.plugins.color night-light-schedule-to

gsettings get org.gnome.settings-daemon.plugins.color night-light-temperature
```
## Setup GNOME Night Light Keyboard Shortcut

Now that we are familiar with the commands we can use to control Night Light settings, we can take it one step further and set up some keyboard shortcuts to execute these commands for us.

1.  Open your systems **Settings** application. Either press the `SUPER` key and type `settings` or press `SUPER + A` and look for the **Settings** application.
2.  Now scroll through the left sidebar of your **Settings** application until you see a list item named **Keyboard**. Click on it. ![](https://res.cloudinary.com/practicaldev/image/fetch/s--jI6DsNJG--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_800/https://i.ibb.co/tmBgqwD/e9827b710888.png)
3.  Scroll down and you'll find a section named **Keyboard Shortcuts**. Click on the button that says **View and Customize Shortcuts**. Click on it. ![](https://res.cloudinary.com/practicaldev/image/fetch/s--04rcZbqc--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_800/https://i.ibb.co/3YCFTgH/524aa13b3b1e.png)
4.  Scroll to the very bottom of the new modal screen that popped up after your last action. ![](https://res.cloudinary.com/practicaldev/image/fetch/s--T6BKh2hZ--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_800/https://i.ibb.co/yQG9n07/5faf96a1f745.png)
5.  You'll see an item named **Custom Shortcuts**. Click on it.
6.  Click on the **plus icon button** on the new screen and a new modal titled **Add Custom Shortcut** will show up.
7.  Enter an appropriate name for the shortcut in **Name** input field. _Example: Turn Night Light On_. ![](https://res.cloudinary.com/practicaldev/image/fetch/s--hvhgi8vL--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_800/https://i.ibb.co/PrRzLnJ/ffa662006942.png)
8.  Now in the **Command** input field, enter this command:

```
gsettings <span class="nb">set </span>org.gnome.settings-daemon.plugins.color night-light-enabled true
```