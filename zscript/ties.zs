
//I'm so sorry

// ------------------------------------------------------------
// Zipties
// ------------------------------------------------------------

class HWAT_RestrainFactor:Inventory{default{inventory.maxamount 11;}}
class HWAT_ResistanceFactor:Inventory{default{inventory.maxamount 10;}}
class HWAT_WillFactor:Inventory{default{inventory.maxamount 10;}}
class HWAT_ArrestedFactor:Inventory{default{inventory.maxamount 1;}}
//Straight ripped from Potetobloke's Weps pack (with some edits)
class HD_HWAT_UnarmedWeapon:HDFist{
	default{
		+WEAPON.MELEEWEAPON +WEAPON.NOALERT +WEAPON.NO_AUTO_SWITCH
		+weapon.cheatnotweapon
		+forcepain
		attacksound "*";
		weapon.selectionorder 100;
		weapon.kickback 120;
		weapon.bobstyle "Alpha";
		weapon.bobspeed 2.6;
		weapon.bobrangex 0.1;
		weapon.bobrangey 0.5;
	}
	
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}
	
	override Inventory CreateTossable (int amt)
	{
		// If self actor lacks a SpawnState, don't drop it. (e.g. A base weapon
		// like the fist can't be dropped because you'll never see it.)
		if (SpawnState == GetDefaultByType("Actor").SpawnState || SpawnState == NULL)
		{
			return NULL;
		}
		if (bUndroppable || bUntossable || Owner == NULL || Amount <= 0 || amt == 0)
		{
			return NULL;
		}
		if (Amount == 1 && !bKeepDepleted)
		{
			BecomePickup ();
			DropTime = 30;
			bSpecial = bSolid = false;
			return self;
		}
		let copy = Inventory(Spawn (GetClass(), Owner.Pos, NO_REPLACE));
		if (copy != NULL)
		{
			amt = clamp(amt, 1, Amount);
			
			copy.MaxAmount = MaxAmount;
			copy.Amount = amt;
			copy.DropTime = 30;
			copy.bSpecial = copy.bSolid = false;
			Amount -= amt;
		}
		return copy;
	}
	states{
	}
}
	
class HDZiptiePuff:HDBulletPuff{
	default{
		stamina 5;scale 0.6;
		hdbulletpuff.scarechance 0;
	}
	override void postbeginplay(){
		super.postbeginplay();
		if(max(abs(pos.x),abs(pos.y),abs(pos.z))>=32768){destroy();return;}
		if(!random(0,scarechance)){
			actor fff=spawn("idledummy",pos,ALLOW_REPLACE);
			fff.stamina=random(60,120);
			hdmobai.frighten(fff,256);
		}
		A_StartSound("misc/bullethit",0,0,0.5*stamina*stamina);
		A_StartSound("weapons/smack",CHAN_7,0,1.02*stamina*stamina);
		A_ChangeVelocity(-0.4,0,frandom(0.1,0.4),CVF_RELATIVE);
		trymove(pos.xy+vel.xy,false);
		int stm=stamina;
		fadeafter=frandom(0,1);
		scale*=frandom(0.9,1.1);
		for(int i=0;i<stamina;i++){
			A_SpawnParticle("gray",
				SPF_RELATIVE,70,frandom(4,20)*getdefaultbytype((class<actor>)(missilename)).scale.x,0,
				frandom(-3,3),frandom(-3,3),frandom(0,4),
				frandom(-0.4,0.4)*stm,frandom(-0.4,0.4)*stm,frandom(0.4,1.2)*stm,
				frandom(-0.1,0.1),frandom(-0.1,0.1),-1.
			);

//			actor ch=spawn(missilename,self.pos,ALLOW_REPLACE);
//			ch.vel=self.vel+(random(-stm,stm),random(-stm,stm),random(-2,12));
		}
	}
	states{
	spawn:
		TNT1 A 1 nodelay{
			if(tracer){
				//if(tracer.bcorpse)hdf.give(tracer,"SawGib",random(5,10));
				if(tracer.bnoblood)
				{
				HDBleedingWound.inflict(tracer,10);
				}
				else 
				{
				HDBleedingWound.inflict(tracer,10);
				}
			}
		}stop;
	crash:
		TNT1 A 1;
		stop;
	}
}
	
class Hwat_Zipties : HDWeapon
{
	int subfactor;
	int resfactor;
	int wilfactor;
	name resname;
	string hwattiesstring;
	int targettimer;
	int targethealth;
	int targetspawnhealth;
	bool flicked;
	bool washolding;
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "Fire Axe"
		//$Sprite "SLH0Z0"
		+WEAPON.MELEEWEAPON +WEAPON.NOALERT +WEAPON.NO_AUTO_SWITCH
		-weapon.cheatnotweapon
		-nointeraction
		-inventory.untossable
		+forcepain
		+forceXYbillboard
		+rollsprite
		+rollcenter
		inventory.pickupmessage "Picked up Zipties.";
		attacksound "game/lemuntear";
		weapon.selectionorder 200;
		weapon.slotpriority 0.75;
		weapon.kickback 0;
		weapon.bobstyle "Alpha";
		weapon.bobspeed 2.6;
		weapon.bobrangex 2.0;
		weapon.bobrangey 0.5;
		weapon.slotnumber 1;
		DamageFunction (random(1,1));
		scale 0.75;
		//hdweapon.barrelsize 21,3,1;
		Obituary "%k took %o in.";
		tag "Ties";
	}
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse);}
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		let ww=Hwat_Zipties(hdw);
		if(ww.targethealth)sb.drawwepnum(ww.targethealth,ww.targetspawnhealth);
	}
	//for throwing a weapon
	override inventory CreateTossable(int amount){
		let onr=hdplayerpawn(owner);
		bool isreadyweapon=onr&&onr.player&&onr.player.readyweapon==self;
		let thrown=super.createtossable(amount);
		if(!thrown)return null;
		let newwep=GetSpareWeapon(onr,doselect:isreadyweapon);
		hdweapon(thrown).bjustchucked=true;
		thrown.target=onr;
		
		return thrown;
	}
	//an override is needed because DropInventory will undo anything done in CreateTossable
	double throwvel;
	//string hwatn;
	override void Tick(){
		super.Tick();
		if(bjustchucked&&target){
			double cp=cos(target.pitch);
		}
		if(owner){
			if(amount<1){
				destroy();
				return;
			}else{
				//update count
				actualamount=1;
				if(owner&&owner.findinventory("SpareWeapons")){
					let spw=spareweapons(owner.findinventory("SpareWeapons"));
					string gcn=getclassname();
					for(int i=0;i<spw.weapontype.size();i++){
						if(spw.weapontype[i]==gcn)actualamount++;
					}
				}
			}
			let onr=hdplayerpawn(owner);
			if(
				!bwimpy_weapon
				&&!hdfist(self)
				&&onr
				&&onr.player
				&&onr.player.readyweapon==self
				&&!onr.barehanded
				&&(
					onr.player.cmd.buttons&BT_ATTACK
					||onr.player.cmd.buttons&BT_ALTATTACK
					||onr.player.cmd.buttons&BT_ZOOM
					||bweaponbusy
					||onr.vel.xy==(0,0)
				)
				&&!random(0,511)
			){
				onr.A_StartSound(random(0,5)?"*xdeath":"*taunt",CHAN_VOICE);
				onr.A_AlertMonsters();
				onr.dropinventory(self);
			}
		}
	}
	
	override string,double getpickupsprite(){return "SLH0Z0",1.;}
	
	override string gethelptext(){
		return
		WEPHELP_FIRE.."  Attempt Restrain\n"
		;
	}
	override void DoEffect(){
		
		super.DoEffect();
		if(targettimer<70)targettimer++;else{
			tracer=null;
			targettimer=0;
			targethealth=0;
		}
	}
	action void HDPunch(int dmg){
		flinetracedata punchline;
		bool punchy=linetrace(
			angle,70,pitch,
			TRF_NOSKY,
			offsetz:height-12,
			data:punchline
		);
		if(!punchy)return;
			doordestroyer.destroydoor(
				self,dmg*1,dmg*0.07,48,height-75,
			angle,pitch);
		setweaponstate("IGOTEM",5);

		if(!punchline.hitactor){
			HDF.Give(self,"WallChunkAmmo",1);
			return;
		}
		actor punchee=punchline.hitactor;

		//charge!
		if(invoker.flicked)dmg*=1.5;
		else dmg+=HDMath.TowardsEachOther(self,punchee)*2;

		//come in swinging
		let onr=hdplayerpawn(self);
		if(onr){
			int iy=max(abs(player.cmd.pitch),abs(player.cmd.yaw));
			if(iy>0)iy*=100;
			else if(iy<0)iy*=200;
			dmg+=min(abs(iy),dmg*2);

			//need to be well grounded
			if(floorz<pos.z)dmg*=0.5;
		}

		//shit happens
		dmg*=frandom(0.85,1.5);


		//other effects
		if(
			onr
			&&!punchee.bdontthrust
			&&(
				punchee.mass<200
				||(
					punchee.radius*2<punchee.height
					&& punchline.hitlocation.z>punchee.pos.z+punchee.height*0.6
				)
			)
		){
			double iyaw=player.cmd.yaw*(65535./360.);
			if(abs(iyaw)>(0.5)){
				punchee.A_SetAngle(punchee.angle-iyaw*100,SPF_INTERPOLATE);
			}
			double ipitch=player.cmd.pitch*(65535./360.);
			if(abs(ipitch)>(0.5*65535/360)){
				punchee.A_SetPitch(punchee.angle+ipitch*100,SPF_INTERPOLATE);
			}
		}
		
		//hit sound
		if(punchee.bnoblood)
		{
		if(dmg*2>punchee.health)punchee.A_StartSound("weapons/smack",CHAN_BODY,0,1.25);
		}
		else 
		{
		punchee.A_StartSound("game/lemuntear",CHAN_BODY,0,0.5);
		if(dmg*1>punchee.health)punchee.A_StartSound("game/lemuntear",CHAN_7,0,1);
		}
		
		hdmobbase.forcepain(punchee);
		punchee.InStateSequence(curstate,resolvestate("falldown"));
		//punchee.InStateSequence(curstate,resolvestate("falldown"));
		
		if(punchee.health>0)punchee.damagemobj(self,self,dmg,"SmallArms3");
		//else HDF.Give(punchee,"SawGib",dmg*0.2);
		
		LineAttack(angle,70,pitch,punchline.hitline?(countinv("PowerStrength")?random(50,120):random(5,15)):0,"none",
			countinv("PowerStrength")?"HDZiptiePuff":"HDZiptiePuff",
			flags:LAF_NORANDOMPUFFZ|LAF_OVERRIDEZ,
			offsetz:height-12);

		if(!punchee)invoker.targethealth=0;else{
			invoker.targethealth=punchee.health;
			invoker.targetspawnhealth=punchee.spawnhealth();
			invoker.targettimer=0;
		}
	}
	
	action void A_Lunge(){
		hdplayerpawn hdp=hdplayerpawn(self);
		if(hdp){
			if(hdp.fatigue>=30){setweaponstate("hold");return;}
			else hdp.fatigue+=3;
		}
		A_Recoil(-3);
	}
	void HWAT_UpdateResText(){
		string hwattiesstring2=string.format("\cm=8= \cnTies \cm=8=\c-\n\n\nGet close and aim at suspect.\n\nPress fire to attempt restrain\n\n");
		hwattiesstring=hwattiesstring2;
		//hwattiesstring=hwattiesstring..string.format("\ca")..resname..string.format(" \cucompliance /10: ")..string.format("\cn")..subfactor;
	}
	void HWAT_UpdateResText2(){
		string hwattiesstring2=string.format("\cm=8= \cnTies \cm=8=\c-\n\n");
		hwattiesstring=hwattiesstring2;
		hwattiesstring=hwattiesstring..string.format("\ca")..resname..string.format("'s \custats: ");
		hwattiesstring=hwattiesstring..string.format("\n\n\cusubmission: ")..string.format("\cn")..subfactor;
		hwattiesstring=hwattiesstring..string.format("\n\curesistance: ")..string.format("\cp")..resfactor;
		hwattiesstring=hwattiesstring..string.format("\n\cuwill: ")..string.format("\ck")..wilfactor;
	}
	action void HWAT_CheckR(int rdist){
		FLineTraceData ZipRay;
            LineTrace(
               angle,
               rdist,
               pitch,
               offsetz: height-12,
               data: ZipRay
            );

            if (ZipRay.HitType == TRACE_HitActor)
			{
				let targetptr = HDMobBase(ZipRay.HitActor);
				if (targetptr && targetptr.health != 0)
					{
						invoker.subfactor = targetptr.CountInv("HWAT_RestrainFactor",0);
						invoker.resfactor = targetptr.CountInv("HWAT_ResistanceFactor",0);
						invoker.wilfactor = targetptr.CountInv("HWAT_WillFactor",0);
						invoker.resname = targetptr.GetTag("Suspect");
						invoker.HWAT_UpdateResText2();
					}
				else
					{
					}
				}
			}
	override double weaponbulk(){
		return 30;
	}
	override double gunmass(){
		return 6;
	}
	
	states{
		droop:
		TNT1 A 1{}loop;
	unf:
		ZIPT YY 4 A_WeaponOffset(random(-2,2),random(30,34),WOF_INTERPOLATE);
		TNT1 A 0
		{
		if(hdplayerpawn(self))hdplayerpawn(self).barehanded==1;
		}
		loop;
	select0:
		ZIPT Y 0 {
		A_Overlay(2,"droop");
		}
		goto select0small;
	deselect0:
		ZIPT Y 0;
		---- Y 0 A_ClearOverlays(2,3);
		goto deselect0small;
	firemode:
		ZIPT Y 1;
		goto nope;
	ready:
		ZIPT Y 0 A_WeaponMessage(string.format(invoker.hwattiesstring,210));
		ZIPT Y 0;
		ZIPT Y 0 A_ClearOverlays(3,3);
		ZIPT Y 0 
		{
			console.printf("Hate target set with a TID of %d",pitch);
			invoker.HWAT_UpdateResText();
		}
		ZIPT Y 1{
				{//length manipulation
				invoker.barrellength = 1.0;
				invoker.barrelwidth = 1.0;
				invoker.barreldepth = 1.0;
				}
			if(invoker.washolding&&pressingfire()){
				setweaponstate("nope");
				return;
			}
			A_WeaponReady(WRF_ALL);
			invoker.flicked=false;
			invoker.washolding=false;
			HWAT_CheckR(512);
		}goto readyend;
	fire:
	ZIPT Y 1;
	ZIPT Y 2;
	startfire:
		#### A 0 A_JumpIfInventory("PowerStrength",1,"zerkswingstart");
		ZIPT Y 0 A_StartSound("weapons/pocket",CHAN_6);
		//SLH0 A 0 A_WeaponBusy();
		ZIPT Y 1;
		goto arrest;
	zerkswingstart:
		ZIPT Y 0 A_StartSound("weapons/pocket",CHAN_6);
		//SLH0 A 0 A_WeaponBusy();
		ZIPT Y 1;
		ZIPT Y 1; // A_WeaponBusy();
		TNT1 A 2 offset(-10,32);
	goto arrest;
	swingreturn:
	arrest:
		#### A 0 A_JumpIfInventory("PowerStrength",1,"zerkswing");
		#### A 0 
		{
		if(hdplayerpawn(self))hdplayerpawn(self).fatigue+=(random(1,2));
		}
		TNT1 A 0 A_StartSound("bandage/rustle",CHAN_BODY);
		//TNT1 A 0 A_Overlay(5,"hitcheck",false);
		TNT1 A 1;
		TNT1 AAAA 1 {
			A_WeaponMessage(string.format(invoker.hwattiesstring,210));
			A_SetTics(hdplayerpawn(self).fatigue/20+(2+(hdplayerpawn(self).fatigue/20)+(-health/20)+5));
			A_MuzzleClimb(frandom(-0.8,0.8),
			frandom(0.1,clamp(1-pitch,0.4,0.9)));
		}
		ZIPT Y 0 //same thing as ready
		{
			invoker.HWAT_UpdateResText();
		}
		ZIPT Y 0{
				{//length manipulation
				invoker.barrellength = 1.0;
				invoker.barrelwidth = 1.0;
				invoker.barreldepth = 1.0;
				}
			if(invoker.washolding&&pressingfire()){
				setweaponstate("nope");
				return;
			}
			A_WeaponReady(WRF_ALL);
			invoker.flicked=false;
			invoker.washolding=false;
			HWAT_CheckR(512);
		}
		//TNT1 A 0 A_ReFire("holdswing");
		ZIPT Y 0
		{
            FLineTraceData ZipRay;
            LineTrace(
               angle,
               48,
               pitch,
               offsetz: height-12,
               data: ZipRay
            );

            if (ZipRay.HitType == TRACE_HitActor)
			{
				let targetptr = HDMobBase(ZipRay.HitActor);
				if (targetptr)
					{
					//if (!(invoker.resfactor+invoker.resfactor >= 10))
						targetptr.GiveInventory("HWAT_RestrainFactor",10-(invoker.resfactor+invoker.wilfactor),0);
					}
				}
			
        }
		goto ready;
	zerkswing:
		ZIPT Y 0 A_StartSound("bandage/rustle",CHAN_BODY);
		ZIPT Y 1;
		#### Y 0 A_Overlay(5,"hitcheckzerk",false);
		//#### A 0 A_JumpIf(pressingaltfire(),"altfire");
		TNT1 AAAAAAA 1 {
			A_MuzzleClimb(frandom(-0.2,0.2),
			frandom(0.1,clamp(1-pitch,0.1,0.3)));
		}
		#### A 0 A_JumpIf(pressingfire(),"ready");
		ZIPT Y 0 A_WeaponBusy;
		goto ready;
	
	unload:
	YEET:
		---- A 1
		{
		if(player&&hdweapon(player.readyweapon)){
		 player.cmd.buttons|=BT_ZOOM;
		 DropInventory(player.readyweapon);
		}
		}
		TNT1 A 0;
		goto nope;
	whoops:
		ZIPT Y 2;
		ZIPT Y 1;
		TNT1 A 5;
		#### A 0 A_JumpIf(pressingfire(),"swingreturn");
		#### A 0 A_JumpIf(pressingaltfire(),"lungealt");
		TNT1 A 0 A_ReFire("holdswing");
		ZIPT Y 0 A_WeaponBusy;
		goto ready;
		
	hitcheck:
		TNT1 A 1 HDPunch(1);
	stop;
	
	hitcheckzerk:
		TNT1 AAA 1 HDPunch(invoker.flicked?200:150);
	stop;
	
	IGOTEM:TNT1 A 1;stop;
		
	spawn:
		ZIPT Z -1;
		stop;
	}
}