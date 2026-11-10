# Genre guide (one profile per genre in genres.txt)

SETUP.md step 4 reads the profile of the chosen genre and builds the game idea and the task files from it, so the game plays like its genre. Read one block only (Grep for its `## ` heading), never the whole file.

Each profile has seven lines:
- `Traits:` any of Feel, Several players, No currency, Building, or None. SETUP.md step 4 says what each trait changes in the plan.
- `Loop:` the core loop. The idea adds its own twist but keeps this shape.
- `Must have:` what the game needs to count as this genre. Each one becomes a tested line in the GENRE CHECKLIST of `01_build.md`.
- `Progress:` what long-term progress means in this genre.
- `With friends:` co-op or social ideas that fit. None may be needed to progress.
- `Keep it:` the mistake to avoid, usually turning the game into a shop with upgrades.
- `Prove:` what Claude's own tests must show before the fun check.

After adding a genre to `genres.txt`, add its block here and run `py -I setup/check_genres.py`.

## Simulator
Traits: None
Loop: do the main action (dig, swing, gather) -> fill the bag -> sell -> buy a better tool or bag -> unlock the next area
Must have: one main action that is satisfying to repeat; a bag or limit that sends the player back to sell; tools and bags in tiers; areas gated by a price or a stat; a rebirth that resets progress for a lasting bonus
Progress: tool tiers, bag sizes, areas, helpers, rebirths
With friends: a small boost for playing near friends; a server goal everyone adds to
Keep it: the main action stays the centre of the screen. Menus and shops support it.
Prove: one full loop alone from a new save; a locked area refuses a player who can't afford it; a rebirth resets the right things and keeps its bonus; a rejoin keeps everything

## Tycoon
Traits: Building
Loop: collect income -> buy the next machine or room -> income rises -> expand
Must have: a plot per player, claimed on join and freed on leave; buttons or a build menu that add pieces in a set order; income that builds up and is collected; earnings while away worked out from saved time; a plot that rebuilds itself from the save
Progress: floors or wings, better machines, upgrades to income, a rebirth
With friends: visit each other's plots; leave a like
Keep it: give the player something to do between purchases (serve customers, make things, fix breakdowns), so it is more than pressing buttons.
Prove: buy the first ten pieces from a new save; leave and rejoin and the plot is rebuilt the same; a purchase without enough money is refused; two players get different plots

## Obby
Traits: Feel, No currency
Loop: run a stage -> reach its checkpoint -> next stage; fall -> respawn at the last checkpoint
Must have: stages in rising difficulty, one checkpoint each; the stage reached saved per player; kill parts and moving parts that behave the same for every player; a stage counter on screen and on the leaderboard; every gap and jump possible for a default avatar
Progress: stages, worlds with their own look, stars for finishing a world without falling, cosmetic trails
With friends: see each other on the course; bonus stages with buttons that need two players
Keep it: the jumping is the game. A player needs no shop to reach the last stage, and no stage can be skipped for Robux.
Prove: a checkpoint saves and survives a rejoin; a checkpoint can't be claimed from far away; every gap is within the jump distance in Config/Feel; a test character can be moved through every stage

## Tower defense
Traits: None
Loop: place defenders -> a wave walks the path -> earn coins per defeat -> place or upgrade -> next wave; lose a life for each invader that reaches the end
Must have: a path with waypoints; waves read from a config table; defenders with range, rate and damage, placed only on allowed spots; upgrade and sell; lives and a clear win or lose; placement and damage decided on the server
Progress: new defenders unlocked between matches, harder maps, a best-wave record
With friends: up to four players defend one map, each placing their own defenders
Keep it: a match has a start and an end. What carries over between matches is unlocks and records.
Prove: a full match alone, once won and once lost; placing on the path or without coins is refused; every wave in the table runs without errors; unlocks survive a rejoin

## Pet collecting
Traits: None
Loop: explore and do tasks -> earn an egg or meet a pet -> hatch it -> the team helps earn more -> reach an area with new pets
Must have: pets saved as items with a species and a level; a team of equipped pets that follow the player; hatching with every chance shown to the player first; a collection book; eggs earned by playing, never bought with Robux or with a currency sold for Robux
Progress: pet levels, team size, areas, the collection book, rarer pets
With friends: show off teams; a boost when friends hatch near each other
Keep it: the pets are the point. Each species looks and moves differently, and the player sees them all the time.
Prove: hatch 1,000 eggs in a test and the results match the shown chances; an equipped pet follows and a stored one doesn't; the collection and levels survive a rejoin

## Farming and gardening
Traits: None
Loop: plant seeds -> water and wait -> harvest -> sell -> buy better seeds and more plots
Must have: plots that remember what is planted and when; growth worked out from saved time, also while the player is away; seeds in tiers; a place to sell; tools that speed up planting or watering
Progress: seed tiers, more plots, tools, garden decorations, a crop book
With friends: water a friend's crops for a small reward to both; visit gardens
Keep it: growing is visible. Crops change shape as they grow and the garden looks different from one day to the next.
Prove: plant, fake the clock forward, harvest; a crop planted before leaving is ready after a rejoin; harvesting too early gives nothing; watering twice gives no extra

## Fishing
Traits: Feel
Loop: cast -> wait for a bite -> play the catch minigame -> keep or sell the fish -> buy a better rod or reach new water
Must have: a cast and a bite with a short timing minigame; fish tables per water with rarities and sizes; rods and bait in tiers that change what can be caught; a fish book; a sell point
Progress: rods, bait, waters, the fish book, biggest-catch records
With friends: a shared boat; a boost when friends fish at the same spot; a board with the server's biggest catch
Keep it: the catch is the fun part. Every cast ends in a short moment of skill.
Prove: 1,000 test casts match the fish table; a catch reported without the minigame being played is refused; the book and records survive a rejoin

## Cooking and restaurant
Traits: Feel
Loop: an order arrives -> fetch ingredients -> chop, cook and plate in the right order -> serve before the timer ends -> earn tips -> buy recipes and kitchen upgrades
Must have: orders made from recipe steps in a config table; stations for each step, each with a short action; a timer per order and a result for late or wrong dishes; the number of orders scaled to the number of players; earnings spent on recipes and stations
Progress: recipes, stations, kitchen size, restaurant decoration, a star rating
With friends: one kitchen where each player can take a station; a combo bonus for dishes served together
Keep it: the rush of the kitchen is the game. A player alone gets a full, fair shift.
Prove: one order from start to served, alone; a wrong step order is rejected; the timer ending fails the order; the order rate with one player can be kept up with

## Mining and digging
Traits: None
Loop: dig down -> collect ore until the pack is full -> return and sell -> buy a better pick or pack -> dig deeper
Must have: a mine made of blocks with ore that gets rarer with depth; blocks that take hits by hardness; a pack limit; picks and packs in tiers; a quick way back to the surface; a mine that refills
Progress: pick tiers, pack sizes, depth reached, an ore book, rebirths
With friends: dig the same mine together; a small bonus for ore found near a friend
Keep it: digging down and finding things is the fun. Depth is the main measure of progress.
Prove: dig to the first rare ore from a new save; a block can't be broken from out of reach or faster than the pick allows; the mine refills; depth and gear survive a rejoin

## Idle clicker
Traits: None
Loop: tap to earn -> buy something that earns by itself -> buy multipliers -> prestige for a lasting bonus
Must have: one big tap target; generators that earn per second; a cost that rises with each purchase; earnings while away from saved time, with a cap; a prestige; large numbers shown in short form (1.2M)
Progress: generators, multipliers, prestige levels, milestones
With friends: a server goal; a leaderboard of prestige levels
Keep it: the numbers must always be moving, and there is always something to buy within a minute.
Prove: tap, buy a generator, wait and the total rises at the shown rate; taps faster than a person can tap are refused; time away gives the capped amount; prestige resets the right things

## Merge
Traits: None
Loop: get a new item -> drag two of the same together -> they become the next tier -> the board fills -> sell or use the best items to grow
Must have: a board with a fixed number of spaces; items in a chain of tiers; a source of new items on a timer or for a cost; two equal items merge into the next tier; the board saved exactly
Progress: the highest tier found, board size, faster sources, new chains, a tier book
With friends: visit boards; send a friend a boost (never an item)
Keep it: the board is the game. The player always has a merge to look for.
Prove: merge up one whole chain in a test; two different items don't merge; a full board refuses new items; the board survives a rejoin exactly

## Racing
Traits: Feel, Several players
Loop: pick a ride -> race a track for one to two minutes -> earn by place and time -> upgrade or unlock -> next track
Must have: tracks with checkpoints, laps and a finish order decided on the server; a countdown start; a reset when stuck or off the track; computer racers so a race alone has opponents; best times saved; speed and handling numbers in Config/Feel
Progress: rides, upgrades, tracks, cups
With friends: race each other; a team cup where places add up
Keep it: the racing is the game. The garage exists to make the next race different.
Prove: a full race alone against computer racers; a skipped checkpoint doesn't count the lap; a finish faster than possible is refused; best times and unlocks survive a rejoin

## Battle arena
Traits: Feel, Several players
Loop: join a short round -> use abilities to knock others out of the arena -> score points -> pick a new ability or look -> next round
Must have: rounds of two to three minutes with a score; two or three abilities with cooldowns, checked on the server; knockback, no blood and no bodies; a safe respawn; computer opponents when few players are on; teams or free-for-all balanced by the game
Progress: abilities, cosmetic looks, arenas, a rank from points
With friends: join the same team; team rounds
Keep it: friendly and quick. Nothing bought with Robux makes a player stronger.
Prove: a full round alone against computer opponents; a hit from out of range or during a cooldown is refused; scores are right at the end; a player who joins mid-round is placed fairly

## Survival
Traits: Building
Loop: gather wood and food by day -> craft tools and a shelter -> get through the night -> explore further for better materials
Must have: a day and night cycle; needs that drop over time (hunger, warmth); resources that respawn; crafting from recipes in a config table; a shelter built from set pieces that protects at night; friendly-looking dangers that knock the player back
Progress: tool tiers, recipes, a bigger base, days survived, new regions
With friends: build one base together; share a campfire's warmth
Keep it: day by day pressure is the game. There is always a need to plan for before nightfall.
Prove: gather, craft a tool and build a shelter in a test day; a night outside costs health and a night inside doesn't; a recipe without the materials is refused; the base and day count survive a rejoin

## Adventure and quests
Traits: None
Loop: talk to a character -> take a quest -> travel and do the task -> return for a reward -> the story opens a new place
Must have: quests as data (steps, targets, rewards) run by one quest system; a quest log with a marker to follow; characters with short speech; areas opened by story progress; quest progress saved step by step
Progress: story chapters, areas, gear or abilities from rewards, side quests
With friends: do a quest step together and both get credit
Keep it: the story and the places are the reward. Quests vary (find, deliver, solve, escort) and are more than "collect ten".
Prove: play the first quest chain from a new save; a step can't be finished from far away or out of order; a rejoin continues mid-quest; a locked area stays locked until its quest is done

## Puzzle
Traits: No currency
Loop: enter a level -> work out the rule -> move the pieces to solve it -> next level with a new idea
Must have: levels as data with a start state and a goal; a few mechanics (switches, blocks, doors, beams) that combine; a reset for the level; the solved levels saved; every level checked to be solvable
Progress: levels, worlds that each add a mechanic, stars for few moves or no hints
With friends: optional two-player levels; a hint from a friend
Keep it: each level teaches or tests one idea. Nothing is solved by buying something.
Prove: a stored solution for every level plays back to the goal; a level reports solved only when the goal state is real on the server; reset restores the start exactly; progress survives a rejoin

## Escape room
Traits: No currency, Several players
Loop: enter a room -> search for clues -> solve the puzzles in a chain -> the door opens before the timer ends -> next room
Must have: rooms with a chain of clues and locks as data; codes and answers checked on the server; a timer and a hint system; rooms that can be solved by one player; a fresh room for each group; rooms finished and best times saved
Progress: rooms, harder versions, best times, badges for no hints
With friends: split up to search; puzzles with an optional second role that saves time
Keep it: finding out is the fun. The answer to a puzzle is never sold.
Prove: the stored solution opens every room; a wrong code is refused and guessing is rate limited; the timer ending ends the run; one player alone can finish every room

## Hide and seek
Traits: Several players
Loop: a round starts -> hiders hide during a countdown -> seekers search -> found hiders are out or join the seekers -> the round ends on a timer -> roles change
Must have: rounds with roles handed out by the game; a hiding countdown while seekers wait; a tag checked on the server by distance and line of sight; computer hiders and seekers to fill a round; a map with many hiding places; a result screen
Progress: maps, cosmetic looks, small tools (a decoy, a short sprint), wins and found counts
With friends: play the same round; friends can be put on one side
Keep it: the tension of hiding and the search is the game. A round works with one real player.
Prove: a full round alone with computer players, once as hider and once as seeker; a tag through a wall or from far away is refused; roles change between rounds; a player joining mid-round waits for the next

## Party minigames
Traits: Feel, Several players, No currency
Loop: a minigame is picked -> everyone plays for about a minute -> scores are shown -> the next minigame -> a winner after several rounds
Must have: a round system that loads and cleans up one minigame at a time; at least six minigames of different kinds at launch; the same scoring rules for all; computer players to fill places; a lobby between games
Progress: more minigames, cosmetic looks, wins, a rank
With friends: this genre is social already; add team minigames
Keep it: variety is the game. Every minigame is explained in one line and understood in ten seconds.
Prove: every minigame runs alone with computer players and ends with a score; nothing from one minigame is left behind in the next; a session of several rounds names a winner; a late joiner enters at the next round

## Roleplay town
Traits: Building
Loop: pick a job -> do its short tasks around town -> get paid -> furnish a home, buy outfits and vehicles -> try another job
Must have: a town with places that have a purpose; at least four jobs, each with its own tasks; a home plot per player furnished from set pieces; vehicles or fast travel; emotes and props for acting things out
Progress: job ranks, home size and furniture, outfits, vehicles
With friends: visit homes; jobs that work together (cook and waiter)
Keep it: a place to act out daily life. Jobs are light and nobody is forced to grind.
Prove: one shift of every job pays the right amount; a task can't be finished from far away; the home loads from the save the same; two players get different home plots

## Sports
Traits: Feel, Several players
Loop: join a match -> play a short half -> score -> the match ends -> earn by result -> new looks or stadiums
Must have: one ball moved by the server; simple controls (move, pass or shoot, tackle or jump); goals, a score and a clock; rules kept by the game (out of play, kick-off); computer players to fill both teams; teams balanced by the game
Progress: cosmetic kits and celebrations, stadiums, a rank
With friends: be on the same team
Keep it: easy to pick up, and fair. No purchase makes a player faster or stronger.
Prove: a full match alone with computer players; a goal counts once and only when the ball crosses the line; the ball can't be moved by a client; the clock ending ends the match

## Parkour and movement
Traits: Feel, No currency
Loop: run a course using wall-runs, slides and long jumps -> reach the end -> get a time and a medal -> try again for a better one -> next course
Must have: a movement set of three or four moves that chain together; courses built for those moves; a timer with medals per course; a quick restart; best times saved and shown; moves checked on the server for impossible speeds
Progress: courses, medals, cosmetic trails, harder versions
With friends: race a friend's best time as a ghost; run side by side
Keep it: moving well is its own reward. The moves are all available from the start or learned by playing, never bought.
Prove: every move triggers from its input in a test; a time faster than the course allows is refused; restart puts the player at the start with the clock at zero; best times survive a rejoin

## Building and sandbox
Traits: Building, No currency
Loop: pick pieces -> place, turn and colour them on your plot -> save -> share or visit others -> unlock more pieces by building
Must have: a plot per player; a catalogue of set pieces with placing on a grid, turning, colouring and deleting; an undo; a piece limit per plot; save and load of the whole plot; visiting other plots without being able to change them
Progress: more pieces unlocked by building and by likes, bigger plots, build challenges
With friends: visit and like; build on a friend's plot when the owner allows it
Keep it: freedom to build is the game. Pieces are easy to get, and players write no free text on builds unless it goes through Roblox's text filter.
Prove: place, edit and delete pieces, save, rejoin and the plot is the same; the piece limit holds; a visitor can't change a plot; a piece can't be placed outside the plot

## Zoo and park management
Traits: Building
Loop: place an enclosure or ride -> visitors arrive and pay -> look after animals or rides -> earn -> expand the park
Must have: a park plot with paths and placed attractions; computer visitors that walk the paths and react to what they see; things that need care on a timer; income from visitors; a park rating; the park saved exactly
Progress: attractions, animals, park size, the rating, decorations
With friends: visit parks and rate them; help with a friend's chores for a small reward to both
Keep it: a living park. Visitors and animals move around and show whether the park is doing well.
Prove: place an attraction and visitors reach it by path; neglect lowers the rating and care raises it; the park loads from the save the same; visitor numbers stay within a limit a phone can run

## Delivery and driving
Traits: Feel
Loop: take a job -> pick up the load -> drive to the drop-off before the timer ends -> get paid -> upgrade the vehicle or buy a new one
Must have: a town with roads and named places; vehicles that are stable and easy to steer, also on a phone; jobs from a table with pay by distance; a timer and a route marker; a flip or reset button; driving numbers in Config/Feel
Progress: vehicles, upgrades, new districts, harder jobs
With friends: convoy jobs with a bonus; a board of today's best drivers
Keep it: the drive is the game. Routes have something to them: shortcuts, hills, traffic.
Prove: one delivery from pickup to pay, alone; a drop-off can't be claimed from far away or without the load; the reset button works when flipped; vehicles and money survive a rejoin

## Sailing and islands
Traits: Feel
Loop: load up at a port -> sail to another island -> sell to the island's shop or explore for a secret -> upgrade the boat -> sail further
Must have: a sea with islands far enough apart to make a trip; a boat that is steady and simple to steer; a shop on each island with its own prices; cargo space; a map that fills in; secrets to find on islands
Progress: boats, cargo size, the map, an island book, treasure found
With friends: crew one boat; sail in a group
Keep it: the voyage and the discovery are the game. Selling is to the game's island shops, never to other players.
Prove: one trip from port to port with a sale; a sale can't be made from out at sea; the boat rights itself after tipping; the map and cargo survive a rejoin

## Card battler
Traits: Several players
Loop: build a deck -> play a turn-based match against the game -> win cards or card pieces -> improve the deck -> a harder opponent
Must have: cards as data (cost, power, effect); a deck with a size limit; a turn system run by the server with a resource that grows each turn; a computer opponent with levels; matches against other players as an option; cards earned by playing, with any random reward's chances shown
Progress: the card collection, deck slots, a ladder of opponents, a rank
With friends: friendly matches; show a deck
Keep it: the choices in a match are the game. Cards are never traded or bought in random packs for Robux.
Prove: a full match against the computer, once won and once lost; a card played out of turn or without the resource is refused; a deck over the limit is refused; the collection survives a rejoin

## Dungeon crawler
Traits: Feel, Several players
Loop: enter a dungeon -> clear rooms of monsters -> beat the boss -> take the loot -> equip it -> a harder dungeon
Must have: dungeons made of rooms that open when cleared; friendly-looking monsters with simple attack patterns; two or three player abilities checked on the server; loot with stats and tiers; difficulty scaled to the number of players so one player can finish; a boss per dungeon
Progress: gear tiers, levels, dungeons, harder modes
With friends: up to four in one dungeon, each with their own loot
Keep it: fighting through rooms is the game. Loot comes from playing, and no dungeon needs a second player.
Prove: one dungeon cleared alone, boss included; damage from out of range or during a cooldown is refused; each player gets their own loot roll; gear survives a rejoin

## Rhythm
Traits: Feel, No currency
Loop: pick a song -> hit the notes in time -> get a score and a grade -> unlock the next song or a harder chart
Must have: note charts as data made from each track's tempo and start offset; hits judged against the music's clock; a timing setting the player can adjust; scores and grades saved per song; tracks only from the allowed audio creators (the `add-asset` skill); large tap targets
Progress: songs, difficulty levels, grades, cosmetic note looks
With friends: play the same song side by side and compare scores
Keep it: the music and the timing are the game. Whether notes line up with the beat is a feel check, because Claude can't hear.
Prove: a stored perfect run scores full marks and a stored late run scores less; a score higher than the chart allows is refused; the timing setting shifts the judgement; scores survive a rejoin

## Pet care
Traits: None
Loop: check on your pet -> feed, wash and play with it -> it gets happier and grows -> earn rewards -> buy food, toys and outfits
Must have: one main pet with needs that change over time, also while away, from saved time; care actions with short activities; growth stages; a home for the pet; outfits; a pet that is never lost or harmed by neglect
Progress: growth stages, tricks, outfits, home decoration, more pets
With friends: playdates where pets meet; visit homes
Keep it: the bond with one pet is the game. It reacts to the player and is animated at all times.
Prove: needs drop with faked time and each care action raises the right one; time away never makes the pet worse than a set floor; growth happens at its thresholds; everything survives a rejoin

## Space exploration
Traits: None
Loop: land on a planet -> gather its resources -> return to base -> build or upgrade -> reach a new planet
Must have: several small planets with their own look and resources, all in one place; travel by ship or launch pad; a base built from modules; an oxygen or fuel limit that sets how far a trip can go; a planet log
Progress: planets, ship and suit upgrades, base modules, the log
With friends: explore the same planet; add to a shared station
Keep it: going somewhere new is the game. Each planet has something to find that the others don't.
Prove: one trip out and back with resources; a trip beyond the fuel limit is refused or ends safely; a locked planet stays locked; the base and log survive a rejoin

## Magic school
Traits: None
Loop: go to a lesson -> learn a spell or recipe through a short activity -> use it around the school -> earn house points -> open a new year with new lessons
Must have: a school with classrooms; lessons as short activities of different kinds; spells that do something in the world (light, lift, grow); potions made from ingredients found around the grounds; school years opened by progress; friendly magic only
Progress: spells, potion recipes, school years, a wand and robe, house points
With friends: lessons with a partner task; a house cup the server adds to
Keep it: learning and using magic is the game. A new spell changes what the player can do or reach.
Prove: finish a lesson and the spell works on the right things; a spell not yet learned can't be cast; a potion needs its ingredients; spells and the year reached survive a rejoin
