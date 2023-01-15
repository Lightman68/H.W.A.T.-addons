//#include "zscript/Omniwand_Spawner.zs"
class HDOmniHandlers:HDHandlers{}
class OmniwandCam:HDActor{
default{
		height 4;radius 4;+nogravity;+noteleport;-solid;
		-shootable;+nodamage;+noblooddecals;
		-pushable;mass 9999;
		bloodtype "HDSmokeChunk";
		scale 0.5;
	}
	states{
	spawn:
		FSKU AB 2 bright light("FSKUL"){
		}loop;
	death:
		FSKU A 1 A_FadeOut(0.1);
		loop;
	}
}
class HD1_Omniwand:HDWeapon{
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "HD1_Omniwand"
		//$Sprite "RIGLA0"

		+hdweapon.fitsinbackpack
		weapon.selectionorder 20;
		weapon.slotnumber 1;
		weapon.slotpriority 2;
		inventory.pickupsound "misc/w_pkup";
		inventory.pickupmessage "You got the hyper tacticool HD1 Omniwand.";
		scale 0.7;
		weapon.bobrangex 0.3;
		weapon.bobrangey 0.1;
		obituary "%o was spotted by %k.";
		hdweapon.refid "HZM";
		tag "HD1 Omniwand";
		inventory.icon "RIGLA0";
		+inventory.invbar
		hdweapon.barrelsize 32,2.1,2;
		hdweapon.refid HWAT_HDLD_OMNIWAND;
	}
	Actor spawnedcam;
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
		..WEPHELP_ALTFIRE.."  Work bolt\n"
		..WEPHELP_RELOAD.."  Reload rounds/clip\n"
		..WEPHELP_ZOOM.."+"..WEPHELP_FIREMODE.."  Zoom\n"
		..WEPHELP_ZOOM.."+"..WEPHELP_USE.."  Bullet drop\n"
		..WEPHELP_ZOOM.."+"..WEPHELP_DROPONE.."  Force drop non-recast\n"
		..WEPHELP_ZOOM.."+"..WEPHELP_ALTRELOAD.."  Force load recast\n"
		..WEPHELP_ALTFIRE.."+"..WEPHELP_UNLOAD.."  Unload chamber/Clean rifle\n"
		..WEPHELP_UNLOADUNLOAD
		;
	}
	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl, //these could mean to get infos from either the weapon or playerpawn?
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc//, string whichdot
	){
		/*
		int cx,cy,cw,ch;
		[cx,cy,cw,ch]=screen.GetClipRect();
		sb.SetClipRect(
			-12+bob.x,-54+bob.y,84,84,
			sb.DI_SCREEN_CENTER
		);
		*/
		/* null check maybe
		if(
			!derps.size()
			||weaponstatus[DRPCS_INDEX]>=derps.size()
		)return;
		*/
		
		let omnicam=spawnedcam;
		if(!omnicam)return;

		int scaledyoffset=0;
		name ctex="EEEEEEEE";
		texman.setcameratotexture(spawnedcam,ctex,60);
		let damagedcam=HD1W_HEALTH;
		sb.drawimage(
			ctex,(0,scaledyoffset)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_CENTER,
			alpha:0.5?frandom[derpyderp](1.0,1.0):1.,scale:((1.0/1.0),1.0)
		);
		sb.drawimage(
			"tbwindow",(0,scaledyoffset)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_CENTER,
			scale:(1,1)
		);
		/*
		if(!damagedcam)sb.drawimage(
			"redpxl",(0,scaledyoffset)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.4,scale:(2,2)
		);
		*/
	}
	/*
	override string pickupmessage(){
		if(weaponstatus[1]&AT4S_CHAMBER)return string.format("%s It is used.",super.pickupmessage());
		else return string.format("%s It has a round.",super.pickupmessage());
		return super.pickupmessage();
	*/
	
	override void tick(){
		super.tick();
		//drainheat(AT4S_HEAT,6);
	}
	override void postbeginplay(){
		super.postbeginplay();
		}
	override double gunmass(){
		return 20;
	}
	override double weaponbulk(){
		int ext=weaponstatus[HD1W_STATUS];
		if(ext==0)return 200;
		else return 266;
	}
	override string,double getpickupsprite(){return "AT4PA0",0.7;}
	
	action void A_FireAT4(){
		A_StartSound("weapons/grenadeshot",CHAN_WEAPON);
	}
	action void A_OmnicamCameraOffset(){
		let hdp=hdplayerpawn(self);
		if (!hdp)return;
		vector3 cpos=pos+gunpos(); //gunpos is the guns position
		spawn("OmniwandCam",cpos,ALLOW_REPLACE);
		If (!Level.IsPointInLevel(Invoker.spawnedcam.Pos) || !Invoker.spawnedcam.TestMobjLocation()){
				Invoker.spawnedcam.Destroy();
			}
			//Otherwise
			Else{
				//Invoker.spawnedcam.Angle = Angle; //Face the same direction as the player.
						
				//Invoker.spawnedcam.bFriendly = True; //Make the demon friendly.
				//Invoker.spawnedcam.SetFriendPlayer(Player);
			}
	}
	
	states{
	select0:
		AT4G A 0;
		goto select0small;
	deselect0:
		AT4G A 0;
		goto deselect0small;
	ready:
		AT4G A 1 A_WeaponReady(WRF_ALL);
		goto readyend;
	fire:
		AT4G A 1;
		AT4G AAAAAAAAAAAAA 1 A_MuzzleClimb(0,1,0,0);
		AT4G A 1{
			invoker.spawnedcam = A_SpawnItemEx("OmniwandCam");
			Spawn ("TeleportFog",invoker.gunpos());
			}
		AT4G A 1 bright{
			//A_FireAT4();
			//A_GunFlash();
			A_StartSound("weapons/AT4fire",CHAN_WEAPON);
			A_StartSound("weapons/rockignite",CHAN_AUTO);
			A_StartSound("weapons/rockboom",5);
			}
		AT4G B 1;
		AT4G A 5 A_Refire;
		goto readyend;
	flash:
		TNT1 A 1 bright{
			HDFlashAlpha(0,true);
			A_Light1();
		}
		TNT1 A 2{
			A_ZoomRecoil(0.5);
			A_Light0();
		}
		stop;
	unload:
	---- A 0 A_JumpIfInventory("HDIncapWeapon",1,"Incapped");
	YEET:
		---- A 1
		{
		if(player&&hdweapon(player.readyweapon)){
		 player.cmd.buttons|=BT_ZOOM;
		 DropInventory(player.readyweapon);
		}
		}
		TNT1 A 0;
	spawn:
		AT4P AB -1 nodelay{
			if(invoker.weaponstatus[HD1W_STATUS]==0)frame=1;
		}
	}
	override void InitializeWepStats(){
		weaponstatus[HD1W_STATUS]=0;
	}
}
enum HD1WStatus{

	HD1W_STATUS=0, //0 retracted, 1 extended
	HD1W_HEALTH=99
};