class HWAT_MobBase:HDMobBase replaces HDMobBase{
	void Arrest(){
		if(CountInv("HWAT_RestrainFactor",0) >= 10)
			SetStateLabel("ArrestMe",0);
	}
}
class HWAT_ZombieStormtrooper:ZombieStormTrooper replaces ZombieStormTrooper {
	int maxwill;
	actor subby;
	override void PostBeginPlay()
	{
		A_GiveInventory("HWAT_ResistanceFactor",2,0);
		A_GiveInventory("HWAT_WillFactor",10,0);
		ACS_NamedExecuteAlways("DeSubmit",0);
		maxwill = CountInv("HWAT_WillFactor",0);
		Super.PostBeginPlay();
	}
	states
	{
	ArrestMe:
        #### # 1
		{
			if(health == 0)
			{
				SetStateLabel("super::death",0);
			}
			else{
				subby = Spawn("HWAT_R_ZombieStormTrooper",pos);
				subby = Spawn("HealthBonus",pos);
				SetStateLabel("Null",0);
			}
		}
	pain:
		#### # 0 A_SetInventory("HWAT_WillFactor",(health/10)-(10-maxwill),0,0);
		goto super::pain;
	}
}
class HWAT_R_ZombieStormTrooper : ScriptedMarine
{
	default
	{
		Health 100;
		PainChance 255;
		Height 40;
		ReactionTime -1;
		-ISMONSTER;
		+SHOOTABLE;
		+LOOKALLAROUND;
		tag "Restrained zombie";
	}
	States
	{
	SAVEME:
		//Sees player. I will scream at monsters instead from now on
		HOST CC 7 A_SpawnItem("HD68_ExclamationMark",1,50);
		HOST C 0 A_ChangeFlag("FRIENDLY",1);
		Goto Spawn;
	Spawn:
		//I wait attentive for you, player.
		TNT1 A 0 A_ClearTarget;
		HOST AB 45 A_Look;
		TNT1 A 0 A_Jump(20,"Spawn2");
		Loop;
	Spawn2:
		//I wait attentive for you, player. (alt animation)
		TNT1 A 0 A_ClearTarget;
		HOST CD 45 A_Look;
		TNT1 A 0 A_Jump(20,"Spawn");
		Loop;
	See:
		//If I've seen the player before, I shall scream at this monster I just looked at.
		HOST E 1;
		TNT1 A 0 A_CheckFlag("FRIENDLY","Spooked");
		TNT1 A 0 A_CheckRange(1,"SAVEME",0);
		Goto Frights;
	Spooked:
		//AAAAAAAAAAAA
		HOST E 60 A_Scream;
		Goto Frights;
	Frights:
		HOST CDCDCD 11;
		TNT1 A 0 A_JumpIfTargetInLOS(1, 359, JLOSF_DEADNOJUMP|JLOSF_ALLYNOJUMP);
		Goto Spawn;
		HOST ABABABABACDCDCD 11;
		HOST CDCD 11 A_Jump(120,"Panic1","Panic2","Panic3");
		Goto Panic1;
	//Pretty much just animations and SCREAMING
	Panic1:
		TNT1 A 0 A_Pain();
		HOST ACACACBDBDBD 4;
		TNT1 A 0 A_ChangeVelocity((random(-1,1)),(random(-1,1)),1,0,0);
		HOST E 35 A_Scream;
		goto Frights;
	Panic2:
		HOST C 6 A_Pain();
		HOST E 6 A_ChangeVelocity((random(-1,1)),(random(-1,1)),1,0,0);
		HOST A 6 A_Pain();
		HOST E 6 A_ChangeVelocity((random(-1,1)),(random(-1,1)),1,0,0);
		HOST C 6 A_Pain();
		HOST E 6 A_ChangeVelocity((random(-1,1)),(random(-1,1)),1,0,0);
		HOST E 35;
		HOST A 6 A_Pain();
		HOST E 6 A_ChangeVelocity((random(-1,1)),(random(-1,1)),1,0,0);
		HOST C 6 A_Pain();
		HOST E 6 A_ChangeVelocity((random(-1,1)),(random(-1,1)),1,0,0);
		goto Frights;
	Panic3:
		TNT1 A 0 A_Pain();
		TNT1 A 0 A_ChangeVelocity((random(-1,1)),(random(-1,1)),1,0,0);
		HOST ECCCCDD 4;
		TNT1 A 0 A_Pain();
		TNT1 A 0 A_ChangeVelocity((random(-1,1)),(random(-1,1)),1,0,0);
		HOST EAAAABB 4;
		TNT1 A 0 A_ChangeVelocity((random(-1,1)),(random(-1,1)),1,0,0);
		HOST E 35 A_Scream();
		goto Frights;
	Pain:
		HOST E 10 A_Pain();
		Goto See;
	Missile:
		HOST ACAC 4;
		Goto Spawn;
	Melee:
		HOST BDBD 4;
		Goto Spawn;
	IAMSAVED:
		HOST C 4 A_ChangeFlag("SOLID",0);
		TNT1 A 0 A_StartSound("game/lemuntear");
		TNT1 A 4 ACS_ExecuteAlways(10679);
		TNT1 A 1 A_FadeOut(1.0);
		Stop;
	XDeath:
		PLAY O 5;
		TNT1 A 0 ACS_Execute(10672,0,0,0,0);
		PLAY P 5 A_XScream;
		PLAY Q 5 A_NoBlocking;
		PLAY RSTUV 5;
		PLAY W -1;
    Stop;
	Death:
		PLAY H 27 A_PlaySound("game/lemundeath");
		//TODO Perhaps make an ARG to decide whether or not hostage death results in loss
		//TODO Make script do a UNAUTHORIZED DEADLY FORCE
		TNT1 A 0 ACS_Execute(10672,0,0,0,0);
		PLAY IJKLM 8;
		PLAY N -1;
	Raise:
		stop;
	}
}
class HWAT_HideousShotgunGuy:HideousShotgunGuy replaces HideousShotgunGuy {
	int maxwill;
	override void PostBeginPlay()
	{
		A_GiveInventory("HWAT_ResistanceFactor",7,0);
		A_GiveInventory("HWAT_WillFactor",0,0);
		ACS_NamedExecuteAlways("DeSubmit",0);
		maxwill = CountInv("HWAT_WillFactor",0);
		Super.PostBeginPlay();
		if(wep<0){
			bhashelmet=true;
			sprite=GetSpriteIndex("PLAYA1");
			A_SetTranslation("HattedJackboot");
			gunloaded=random(10,50);
			givearmour(1.,0.06,-0.4);
		}else{
			sprite=GetSpriteIndex("SPOSA1");
			A_SetTranslation("ShotgunGuy");
			gunloaded=wep?random(1,2):random(3,8);
			if(random(0,7))choke=(wep?(7+8*7):1);else{
				choke=random(0,7);
				//set second barrel
				if(wep)choke+=8*random(0,7);
			}
		}
	}
	states
	{
	ArrestMe:
        #### # 0
		{
			sprite = GetSpriteIndex("HOST");
			frame = 0;
			A_SetTics(10);
		}
        wait;
	see:
		#### # 0 A_JumpIfInventory("HWAT_ArrestedFactor",1,"ArrestMe",0);
		goto super::see;
	missile:
		#### # 0 A_JumpIfInventory("HWAT_ArrestedFactor",1,"ArrestMe",0);
		goto super::missile;
	melee:
		#### # 0 A_JumpIfInventory("HWAT_ArrestedFactor",1,"ArrestMe",0);
		goto super::melee;
	//MobMan
	//End of Mobman >:(
	pain:
		#### # 0 A_SetInventory("HWAT_WillFactor",(health/10)-(10-maxwill),0,0);
		goto super::pain;
	}
}