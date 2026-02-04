Roblox game: https://www.roblox.com/games/87217609253271/WKEY-games-takehome-work

#How to play
Change speed & spawn speed with the two sliders near the conveyor.
Only one player can change spawn speed at a time. This player is the first player that joined the game. A new player will be chosen by the server when the current player leaves.

#architecture
The system is simulated both on the server & client. The server simulates only what is needed. This means that I spawn the bag, and then I know when the bag will reach the end. Nothing is therefore done on the bag before it reaches the end.
If speed is changed on the conveyor, then all bags recalculate when they'll reach the end of the conveyor.
The client simulates the system to make it smooth and nice. They take the input of when a bag spawns in from the server.
When a player spawns in the current state from the server is sent to the player. This recalculates where all the bags on a conveyor is etc. and is then sent to the client.

#approach
I wanted to make a performant system for the server. In many tycoons you'd want a huge amount of bags (or parts) on the conveyors. It would not be performant to simulate every one of those on the server, and it is therefore only simulated to the bare minumum.
I started by laying out that main system and how I wanted that to work. I then made the core functionality of the server first.
I then made the client simulate the things so I could debug the system easier.
And animations etc. were added at the very end.

I have not used any external libraries while creating this system. All the systems are made by me. In a normal game I'd however probably use libraries that Comm by Sleitnick and a cleanup module like Maid or Janitor.