clearScreen.
copyPath("0:/lib/", "1:/lib/").
copyPath("0:/cmd/", "1:/cmd/").

run once "/lib/commands".
launch(3).
lko(75000).