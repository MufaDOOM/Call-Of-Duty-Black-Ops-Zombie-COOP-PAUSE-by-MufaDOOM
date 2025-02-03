#include maps\_utility;
#include common_scripts\utility; 
#include maps\_zombiemode_utility;


init()
{
	setdvar( "player_backSpeedScale", 1 );
	setdvar( "player_strafeSpeedScale", 1 );
	level thread onPlayerConnect();
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");
	self.initial_spawn = 1;
	for(;;)
	{
		self waittill("spawned_player");
		wait_network_frame();
		if (self.initial_spawn == 1)
		{
			self.initial_spawn = 0;
			self thread watch_for_respawn();
			self iprintlnbold("COOP PAUSE Activated , Enjoy :)");
			self iprintln( "[{+speed_throw}] ^1& [{+melee}] ^6To Pause" );
			self coop_pause();

		}
	}
}



watch_for_respawn()
{
	self endon("disconnect");
	while(1)
	{
		self waittill_either( "spawned_player", "player_revived" ); 
		wait_network_frame();
	}
}

coop_pause()
{	
	level endon("disconnect");
	level endon("end_game");

	setDvar( "coop_pause", 0 );

	paused_time = 0;
	paused_start_time = 0;
	paused = false;

	start_time = int(getTime() / 1000);

	players = get_players();

	while(players.size > 0)
	{
if( self meleebuttonpressed() && self adsbuttonpressed() )	
{
setDvar( "coop_pause", 1 );
}
		if( getDvarInt( "coop_pause" ) == 1 )
		{	
			
			self iprintln( "[{+speed_throw}] ^1& [{+melee}] ^6To Unpause" );
			players[0] SetClientDvar( "ai_disableSpawn", "1" );
			players[0] SetClientDvar( "g_ai", "0" );

			black_hud = newhudelem();
			black_hud.horzAlign = "fullscreen";
			black_hud.vertAlign = "fullscreen";
			black_hud SetShader( "black", 640, 480 );
			black_hud.alpha = 0;

			black_hud FadeOverTime( 1.0 );
			black_hud.alpha = 0.7;

			paused_hud = newhudelem();
			paused_hud.horzAlign = "center";
			paused_hud.vertAlign = "middle";
			paused_hud setText("THE GAME IS IN PAUSE YOU CAN GO AWAY !");
			paused_hud.foreground = true;
			paused_hud.fontScale = 2.3;
			paused_hud.x -= 150;
			paused_hud.y -= 20;
			paused_hud.alpha = 0;
			paused_hud.color = ( 1.0, 1.0, 1.0 );

			paused_hud FadeOverTime( 1.0 );
			paused_hud.alpha = 0.85;
			level.zombie_total = 0;
			players = get_players();
			for(i = 0; players.size > i; i++)
			{
				players[i] EnableInvulnerability();
				players[i] freezecontrols(true);
				players[i].ignoreme = 1;				
			}

			paused = true;
			paused_start_time = int(getTime() / 1000);
			total_time = 0 - (paused_start_time - level.paused_time) - (start_time - 0.05);
			previous_paused_time = level.paused_time;

			while(paused)
			{	
				players = get_players();
				for(i = 0; players.size > i; i++)
				{
					players[i].timer_hud SetTimerUp(total_time);
					players[i] EnableInvulnerability();
					players[i] freezecontrols(true);
					players[i].ignoreme = 1;
				}
				
				wait 0.2;

				current_time = int(getTime() / 1000);
				current_paused_time = current_time - paused_start_time;
				level.paused_time = previous_paused_time + current_paused_time;
if( self meleebuttonpressed() && self adsbuttonpressed() )	
{
setDvar( "coop_pause", 0 );
}


				if( getDvarInt( "coop_pause" ) == 0 )
				{
					paused = false;
					paused_hud FadeOverTime( 0.5 );
					paused_hud.alpha = 0;
					black_hud FadeOverTime( 0.5 );
					black_hud.alpha = 0;
					wait 0.5;
					black_hud destroy();
					paused_hud destroy();	

					for(i = 0; players.size > i; i++)
					{
						players[i] freezecontrols(false);
						wait 3;
						players[i] DisableInvulnerability();					
						players[i].ignoreme = 0;
					}

					players[0] SetClientDvar( "ai_disableSpawn", "0");
					players[0] SetClientDvar( "g_ai", "1" );


				}
			}
		}
		wait 0.05;
	}
}
