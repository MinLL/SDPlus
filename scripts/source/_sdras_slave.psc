Scriptname _SDRAS_slave extends ReferenceAlias
{ USED }
Import Utility

_SDQS_snp Property snp Auto
_SDQS_enslavement Property enslavement  Auto
_SDQS_functions Property funct  Auto
_SDQS_fcts_outfit Property fctOutfit  Auto
_SDQS_fcts_slavery Property fctSlavery  Auto
_SDQS_fcts_constraints Property fctConstraints  Auto

MiscObject Property _SDMOP_lockpick  Auto  

Quest Property _SDQP_enslavement_tasks  Auto
Quest Property _SDQP_thug_slave  Auto

Quest Property _SD_dreamQuest  Auto

ReferenceAlias Property Alias__SDRA_lust_m  Auto
ReferenceAlias Property Alias__SDRA_lust_f  Auto

Cell[] Property _SDCP_sanguines_realms  Auto  

GlobalVariable Property _SDGVP_config_lust auto
GlobalVariable Property _SDGV_leash_length  Auto
GlobalVariable Property _SDGV_free_time  Auto
GlobalVariable Property _SDGVP_positions  Auto  
GlobalVariable Property _SDGVP_demerits  Auto  
GlobalVariable Property _SDGVP_demerits_join  Auto  
GlobalVariable Property _SDGVP_config_verboseMerits  Auto
GlobalVariable Property _SDGVP_escape_radius  Auto  
GlobalVariable Property _SDGVP_escape_timer  Auto  
GlobalVariable Property _SDGVP_state_caged  Auto  
GlobalVariable Property _SDGVP_config_safeword  Auto  
GlobalVariable Property _SDKP_trust_hands  Auto  
GlobalVariable Property _SDKP_trust_feet   Auto  
GlobalVariable Property _SDKP_snp_busy   Auto  
GlobalVariable Property _SDGVP_punishments  Auto  

ReferenceAlias Property _SDRAP_cage  Auto
ReferenceAlias Property _SDRAP_masters_key  Auto
ReferenceAlias Property _SDRAP_slave  Auto
ReferenceAlias Property _SDRAP_master  Auto
ReferenceAlias Property _SDRAP_bindings  Auto
ReferenceAlias Property _SDRAP_shackles  Auto
Float Property _SDFP_bindings_health = 10.0 Auto

FormList Property _SDFLP_master_items  Auto
FormList Property _SDFLP_sex_items  Auto
FormList Property _SDFLP_punish_items  Auto  
FormList Property _SDFLP_trade_items  Auto
FormList Property _SDFLP_slave_clothing  Auto
FormList Property _SDFLP_banned_locations  Auto  
FormList Property _SDFLP_banned_worldspaces  Auto  

Keyword Property _SDKP_enslave  Auto
Keyword Property _SDKP_sex  Auto
Keyword Property _SDKP_arrest  Auto
Keyword Property _SDKP_gagged  Auto
Keyword Property _SDKP_bound  Auto
Keyword Property _SDKP_wrists  Auto
Keyword Property _SDKP_ankles  Auto
; these keywords are usually associated with quest items.
; i.e. prevent selling or disenchanting them.
Keyword Property _SDKP_noenchant  Auto  
Keyword Property _SDKP_nosale  Auto  
Keyword Property _SDKP_food  Auto  
Keyword Property _SDKP_food_raw  Auto  
Keyword Property _SDKP_food_vendor  Auto  

Faction Property _SDFP_slaversFaction  Auto  
Spell Property _SDSP_SelfShockShield  Auto  
Spell Property _SDSP_SelfShockEffect  Auto  
Spell Property _SDSP_SelfVibratingEffect  Auto  
Spell Property _SDSP_SelfTinglingEffect  Auto  
Spell Property _SDSP_Weak  Auto  


; LOCAL
Int iuType
Float fCalcLeashLength
Float fCalcOOCLimit = 10.0
Float fDamage
Float fDistance
Float fBlackoutRatio
Float fEscapeTime
Float fEscapeUpdateTime
Float fOutOfCellTime
int daysPassed
int iGameDateLastCheck = -1
int iDaysSinceLastCheck
int iCountSinceLastCheck

Float fLastIngest
Float fLastEscape

Actor kMaster
Actor kSlave
Actor kCombatTarget
Actor kLeashCenter
ObjectReference kBindings
ObjectReference kShackles
ObjectReference kCollar
ObjectReference kGag

Float fRFSU = 0.5

Int iuIdx
Int iuCount
Form kAtIdx
Float fTime

Bool[] uiSlotDevice
Int iWristsDevice = 0 ;59  Bindings
Int iCollarDevice = 1 ;45  Collar
Int iAnklesDevice = 2 ;53  Ankles
Int iGagDevice = 4 ;44  DD Gag
Form fGagDevice = None

Function freedomTimer( Float afTime )
	If ( afTime >= 60.0 )
		; Debug.Notification( Math.Floor( afTime / 60.0 ) + " min.," + ( Math.Floor( afTime ) % 60 ) + " sec. and you're free!" )
		Debug.Notification("The collar is vibrating. " + Math.Floor( afTime / 60.0 ) + " min.," + ( Math.Floor( afTime ) % 60 ) + " sec. remaining.")
		_SDSP_SelfVibratingEffect.Cast(kSlave as Actor)
	ElseIf ( afTime >= 0.0 )
		; Debug.Notification( Math.Floor( afTime ) + " sec. and you're free!" )
		Debug.Notification("The collar is tingling. " + Math.Floor( afTime ) + " sec. remaining.")
		_SDSP_SelfTinglingEffect.Cast(kSlave as Actor)
	Else 
		; Debug.Notification( Math.Floor( afTime ) + " sec. and you're free!" )
		Debug.Notification("The collar is sending shocks." )
		; _SDSP_SelfShockEffect.Cast(kSlave as Actor)
	EndIf
EndFunction


Event OnInit()
 
	If ( Self.GetOwningQuest() )
		RegisterForSingleUpdate( fRFSU )
	EndIf
	GoToState("waiting")
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	If ( _SDFLP_banned_locations.HasForm( akNewLoc ) )
		Debug.Trace("[_sdras_slave] Banned location - Stop enslavement")
		SendModEvent("SDFree") ; Self.GetOwningQuest().Stop()
		Wait( fRFSU * 5.0 )
	EndIf
	If ( _SDFLP_banned_worldspaces.HasForm( kSlave.GetWorldSpace() ) )

		Debug.Trace("[_sdras_slave] Banned worldspace - Stop enslavement")
		SendModEvent("SDFree") ; Self.GetOwningQuest().Stop()
		Wait( fRFSU * 5.0 )
	EndIf
EndEvent

Event OnAnimationEvent(ObjectReference akSource, string asEventName)
	; If ( akSource == Self.GetReference() && asEventName == "weaponDraw" && Self.GetOwningQuest().GetStage() >= 90 )
	; 	Debug.Trace("[_sdras_slave] Weapon draw - Stop enslavement")
	; 	Self.GetOwningQuest().Stop()			
	; EndIf

EndEvent

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
	; If ( aeCombatState == 0 )
	; 	GoToState("monitor")
	; Else
	; 	GoToState("escape")
	; EndIf
EndEvent

Event OnItemAdded(Form akBaseItem, Int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	If ( Self.GetOwningQuest().GetStage() >= 90 || _SDFLP_sex_items.Find( akBaseItem ) >= 0 || _SDFLP_punish_items.Find( akBaseItem ) >= 0 || _SDFLP_slave_clothing.Find( akBaseItem ) >= 0 )
		Return
	EndIf
	If ( akBaseItem.HasKeyword(_SDKP_noenchant) || akBaseItem.HasKeyword(_SDKP_nosale) )
		Return
	EndIf
	
	iuType = akBaseItem.GetType()
	
	If ( akItemReference == _SDRAP_masters_key.GetReference() )
		; escape
		Debug.Trace("[_sdras_slave] Master key - Stop enslavement")

		fctOutfit.setDeviousOutfitArms ( bDevEquip = False, sDevMessage = "")
		fctOutfit.setDeviousOutfitLegs ( bDevEquip = False, sDevMessage = "")
;		fctOutfit.removePunishment( bDevGag = True,  bDevBlindfold = True,  bDevBelt = True,  bDevPlugAnal = True,  bDevPlugVaginal = True)
		fctOutfit.setDeviousOutfitBlindfold ( bDevEquip = False, sDevMessage = "")
		fctOutfit.setDeviousOutfitGag ( bDevEquip = False, sDevMessage = "")
	
		if (Utility.RandomInt(0,100) < 60)
			fctOutfit.setDeviousOutfitCollar ( bDevEquip = False, sDevMessage = "")
			Debug.Messagebox("Your Master's Key helps you break free of your chains.")
		Else
			Debug.MessageBox("Your Master's Key helps you break free of your chains but the key snapped as you tried to force your collar open.")
		EndIf

		kSlave.RemoveItem(akItemReference, aiItemCount)

 		SendModEvent("SDFree")
		; Self.GetOwningQuest().Stop()
		; Utility.Wait(2.0)
		Return

		; Slave picks up a weapon
	ElseIf  ( iuType == 41 || iuType == 42 ) 

		If (!fctSlavery.CheckSlavePrivilege(kSlave, "_SD_iEnableFight")) ; ( GetCurrentRealTime() - fLastEscape < 5.0 )
			; Debug.Notification( "$SD_MESSAGE_WAIT_5_SEC" )
			Debug.MessageBox("You collar gives you a small shock to remind you that you are not allowed to use a weapon. Try asking your owner for permission.")
			; kSlave.DropObject(akBaseItem, aiItemCount)
		
		ElseIf (0==1); disabled for now - slave should be able to pick up a weapon to defend master
			fDamage = ( akBaseItem as Weapon ).GetBaseDamage() as Float

			If ( fDamage <= 0.0 )
				fDamage = Utility.RandomFloat( 1.0, 4.0 )
			EndIf

			_SDFP_bindings_health -= fDamage
			enslavement.ufBindingsHealth = _SDFP_bindings_health
			If ( _SDFP_bindings_health < 0.0 && !_SDGVP_state_caged.GetValueInt() )
				Debug.Trace("[_sdras_slave] Broken chains - Stop enslavement")
				Debug.Messagebox("You manage to break your chains with a weapon.")

				fctOutfit.setDeviousOutfitArms ( bDevEquip = False, sDevMessage = "")
				fctOutfit.setDeviousOutfitLegs ( bDevEquip = False, sDevMessage = "")
				fctOutfit.setDeviousOutfitBlindfold ( bDevEquip = False, sDevMessage = "")

				fLastEscape = GetCurrentRealTime()
 				SendModEvent("SDFree")
				; Self.GetOwningQuest().Stop()
				Return
			Else
				kSlave.DropObject(akBaseItem, aiItemCount)
			EndIf
		EndIf
		

	EndIf
EndEvent

State waiting
	Event OnUpdate()
		If ( Self.GetOwningQuest().IsRunning() )
			GoToState("monitor")
		EndIf
		If ( Self.GetOwningQuest() )
			RegisterForSingleUpdate( fRFSU )
		EndIf
	EndEvent
EndState

State monitor
	Event OnBeginState()

		kMaster = _SDRAP_master.GetReference() as Actor
		kSlave = _SDRAP_slave.GetReference() as Actor
;		kBindings = _SDRAP_bindings.GetReference() as ObjectReference
;		kShackles = _SDRAP_shackles.GetReference() as ObjectReference
;		kCollar = _SDRAP_collar.GetReference() as ObjectReference

		fOutOfCellTime = GetCurrentRealTime()
		fLastEscape = GetCurrentRealTime() - 5.0
		fLastIngest = GetCurrentRealTime() - 5.0

		; If ( RegisterForAnimationEvent(kSlave, "weaponDraw") )
		; EndIf
	EndEvent
	
	Event OnEndState()
		; If ( UnregisterForAnimationEvent(kSlave, "weaponDraw") )
		; EndIf
	EndEvent

	Event OnUpdate()
		While ( !Game.GetPlayer().Is3DLoaded() )
		EndWhile

	 	daysPassed = Game.QueryStat("Days Passed")

	 	if (iGameDateLastCheck == -1)
	 		iGameDateLastCheck = daysPassed
	 	EndIf

	 	iDaysSinceLastCheck = (daysPassed - iGameDateLastCheck ) as Int

		If (iDaysSinceLastCheck == 0) ; same day - incremental updates
			iCountSinceLastCheck += 1

			if (iCountSinceLastCheck >= 100)
				; Debug.Notification( "[SD] Slavery status - hourly update")
				iCountSinceLastCheck = 0
				; Disabled for now - daily update makes more sense
				; fctSlavery.UpdateStatusHourly( kMaster, kSlave)
			EndIf

		Else ; day change - full update
			Debug.Notification( "[SD] Slavery status - daily update")
			iGameDateLastCheck = daysPassed
			iCountSinceLastCheck = 0
			fctSlavery.UpdateStatusDaily( kMaster, kSlave)

		EndIf

		enslavement.UpdateSlaveState(kMaster ,kSlave)
		enslavement.UpdateSlaveFollowerState(kSlave)
		
		; Add a new quest Alias for PlayerReference
		; Create functions under fct_constraints: SetLeashReference(objectreference)
		; 			Update alias to Master or another nearby object / actor
		; Calculate distance to reference
		kLeashCenter =  StorageUtil.GetFormValue(kSlave, "_SD_LeashCenter") as Actor

		if (kLeashCenter == None)
			fctConstraints.setLeashCenterRef(kMaster as ObjectReference)
			kLeashCenter = kMaster
		EndIf

		fDistance = kSlave.GetDistance( kLeashCenter )
		kCombatTarget = kSlave.GetCombatTarget()

		; Debug.Notification("[_sdras_slave] Distance:" + fDistance + " > " + _SDGVP_escape_radius.GetValue())
		; Debug.Notification("[_sdras_slave] DefaultStance:" + StorageUtil.GetStringValue(kSlave, "_SD_sDefaultStance"))
		; Debug.Notification("[_sdras_slave] EnableLeash:" + fctSlavery.CheckSlavePrivilege(kSlave, "_SD_iEnableLeash"))
		; Debug.Notification("[_sdras_slave] MasterFollow:" + StorageUtil.GetIntValue(kSlave, "_SD_iFollowSlave"))
		; Debug.Notification("[_sdras_slave] AutoKneelingOFF:" + StorageUtil.GetIntValue(kSlave, "_SD_iDisablePlayerAutoKneeling"))


		If (_SDGVP_config_safeword.GetValue() as bool)
			Debug.MessageBox( "Safeword: You are released from enslavement.")
			_SDGVP_state_joined.SetValue( 0 )
			_SDGVP_config_safeword.SetValue(0)

			SendModEvent("PCSubFree")
			; Self.GetOwningQuest().Stop()

		ElseIf (_SDGVP_demerits.GetValue()>200) && (_SD_dreamQuest.GetStage() != 0) && (SexLab.ValidateActor( SexLab.PlayerRef ) > 0)
			_SD_dreamQuest.SetStage(20)

		ElseIf ( Self.GetOwningQuest().IsStopping() || Self.GetOwningQuest().IsStopped() )
			GoToState("waiting")

		ElseIf ( _SDGV_leash_length.GetValue() == -10) ; escape trigger in some situations
		;	If (RandomInt( 0, 100 ) > 80 )
		;		Debug.Notification( "Keep running!...")
		;	EndIf
		;	enslavement.bEscapedSlave = False
		;	enslavement.bSearchForSlave = False
		;	Self.GetOwningQuest().Stop()
			_SDGV_leash_length.SetValue( StorageUtil.GetIntValue(kSlave, "_SD_iLeashLength") )

		ElseIf ( Self.GetOwningQuest().GetStage() >= 90 )
			fOutOfCellTime = GetCurrentRealTime()
			enslavement.bEscapedSlave = False
			enslavement.bSearchForSlave = False

		ElseIf ( _SDCP_sanguines_realms.Find( kSlave.GetParentCell() ) > -1 )
			fOutOfCellTime = GetCurrentRealTime()
			enslavement.bEscapedSlave = False
			enslavement.bSearchForSlave = False

		ElseIf ( !Game.IsMovementControlsEnabled() || kSlave.GetCurrentScene() )
			fOutOfCellTime = GetCurrentRealTime()
			enslavement.bEscapedSlave = False
			enslavement.bSearchForSlave = False

		ElseIf ( _SDGVP_state_caged.GetValueInt() )
			GoToState("caged")

		ElseIf ((kSlave.GetParentCell() == kMaster.GetParentCell()) && (kMaster.GetParentCell().IsInterior())) && (StorageUtil.GetIntValue(kSlave, "_SD_iTrust") > 0)
			; If (RandomInt( 0, 100 ) > 95 )
			; 	Debug.Notification( "Your collar weighs around your neck..." )
			; EndIf
			GoToState("waiting")	

		ElseIf ( fDistance > (_SDGVP_escape_radius.GetValue() * 0.7) ) && ( fDistance < _SDGVP_escape_radius.GetValue() )
			If fctSlavery.CheckSlavePrivilege(kSlave, "_SD_iEnableLeash") && (StorageUtil.GetIntValue(kSlave, "_SD_iFollowSlave") == 0)
				Debug.Notification( "Your collar tightens around your throat..." )
				_SD_CollarStrangleImod.Remove()
			EndIf

		ElseIf ( fDistance > _SDGVP_escape_radius.GetValue() )

			If fctSlavery.CheckSlavePrivilege(kSlave, "_SD_iEnableLeash") && (StorageUtil.GetIntValue(kSlave, "_SD_iFollowSlave") == 0)

				fBlackoutRatio = ( funct.floatMin( fDistance, _SDGVP_escape_radius.GetValue() * 2.0 ) - _SDGVP_escape_radius.GetValue() ) / _SDGVP_escape_radius.GetValue()


				If (fBlackoutRatio < 0.3)
					_SD_CollarStrangleImod.Remove()
					Debug.Notification( "You are too far from your master..." )
					_SD_CollarStrangleImod.Apply(fBlackoutRatio)
				ElseIf (fBlackoutRatio < 0.6)
					;_SD_CollarStrangleImod.Remove()
					Debug.Notification( "Your breathing is painful..." )
					_SD_CollarStrangleImod.PopTo(_SD_CollarStrangleImod,fBlackoutRatio)
				Else
					;_SD_CollarStrangleImod.Remove()
					Debug.Notification( "Your collar is choking you..." )
					_SD_CollarStrangleImod.PopTo(_SD_CollarStrangleImod,fBlackoutRatio)
				EndIf

				If (fBlackoutRatio >= 0.95)
				;	Debug.Notification("You should blackout here.")
					_SD_CollarStrangleImod.Remove()
					_SDSMP_choke.Play( Game.GetPlayer() )

	                Game.FadeOutGame(true, true, 0.5, 5)
					kSlave.MoveTo( kMaster )
					Game.FadeOutGame(false, true, 2.0, 20)

					Utility.Wait( 1.0 )

					Debug.MessageBox( "After being choked by the collar, you wake up next to your owner." )

					If (!kMaster.IsDead()) && (!kMaster.IsInCombat())
						if (Utility.RandomInt(0,100)>50)
							; Punishment
							enslavement.PunishSlave(kMaster,kSlave)
							_SDKP_sex.SendStoryEvent(akRef1 = kMaster, akRef2 = kSlave, aiValue1 = 3, aiValue2 = RandomInt( 0, _SDGVP_punishments.GetValueInt() ) )
						Else
							; Whipping
							_SDKP_sex.SendStoryEvent(akRef1 = kMaster, akRef2 = kSlave, aiValue1 = 5 )
						EndIf
					EndIf
				EndIf
				; Check if snp = 1 scene is not running already
				; Game.DisablePlayerControls( abMovement = true )
				; Game.SetPlayerAIDriven()
				; _SDKP_sex.SendStoryEvent(akRef1 = kMaster, akRef2 = kSlave, aiValue1 = 1) ; move back to master
			Else
				GoToState("escape")
			EndIf

		ElseIf ( kMaster.IsInCombat() )
			; GoToState("escape")

			Debug.Notification( "Your master is in combat. Stay close..." )

		Else
			; Not sure what this is doing - disabling for now since kBindings are treated differently now
			If (0==1) && ( kBindings && !kSlave.IsEquipped( kBindings.GetBaseObject() ) )
				fOutOfCellTime = GetCurrentRealTime()
				iuIdx = 0
				While iuIdx < _SDFLP_trade_items.GetSize()
					kAtIdx  = _SDFLP_trade_items.GetAt( iuIdx )
					iuCount = kSlave.GetItemCount( kAtIdx )
					iuType  = kAtIdx.GetType()
					If ( iuCount && !kSlave.IsEquipped( kAtIdx ) && ( iuType == 26 || ( iuType == 41 && !( kAtIdx as Weapon ).IsDagger() ) ) )
						kSlave.DropObject( kAtIdx, iuCount )
					EndIf
					iuIdx += 1
				EndWhile
			EndIf

			; Clean up chocking effect if leash is on
			If fctSlavery.CheckSlavePrivilege(kSlave, "_SD_iEnableLeash") && (StorageUtil.GetIntValue(kSlave, "_SD_iFollowSlave") == 0)
				_SD_CollarStrangleImod.Remove()
			EndIf

			fCalcLeashLength = _SDGV_leash_length.GetValue() * 1.5		

			; If (kMaster.GetParentCell().IsInterior()) 
				; Debug.Notification( "Master inside") 
			; Else
				; Debug.Notification( "Master outside")
			; EndIf

			; If (kMaster.GetParentCell() == kSlave.GetParentCell()) 
				; Debug.Notification( "Slave and master in same cell ") 
			; Else
				; Debug.Notification( "Slave and master in diff cells ") 
			; EndIf

			If (( fDistance > fCalcLeashLength ) && ( kMaster.GetSleepState() == 0 )  && (kMaster.GetParentCell() == kSlave.GetParentCell()) && (!kMaster.GetParentCell().IsInterior()) && ( _SDGV_leash_length.GetValue() > 0))

				If ( fDistance < fCalcLeashLength * 2 )
					; Up to twice the leash, Master will walk towards slave
					; Debug.Notification( "$SD_MESSAGE_STAY_CLOSE_TO_MASTER" )
					; Debug.Notification( "[Master follows you]" )

					fOutOfCellTime = GetCurrentRealTime()
					; _SDSP_SelfShock.Cast(kSlave as Actor, kSlave as Actor)
					; _SDKP_sex.SendStoryEvent(akRef1 = kMaster, akRef2 = kSlave, aiValue1 = 10)

				ElseIf ( kMaster.HasLOS( kSlave ))
					; Debug.notification( "Escape auto detected -  _SDRAS_slave 1" )
					; Debug.Notification( "[Master can see you leave]" )
					; Self.GetOwningQuest().ModObjectiveGlobal( 1.0, _SDGVP_demerits, -1, _SDGVP_demerits_join.GetValue() as Float, False, True, _SDGVP_config_verboseMerits.GetValueInt() as Bool )

					fOutOfCellTime = GetCurrentRealTime()
					; _SDKP_sex.SendStoryEvent(akRef1 = kMaster, akRef2 = kSlave, aiValue1 = 10)

				ElseIf ( GetCurrentRealTime() - fOutOfCellTime > fCalcOOCLimit )
					; Debug.Notification( "[Master did not see you]" )
;						Self.GetOwningQuest().ModObjectiveGlobal( 3.0, _SDGVP_demerits, -1, _SDGVP_demerits_join.GetValue() as Float, False, True, _SDGVP_config_verboseMerits.GetValueInt() as Bool )
					fOutOfCellTime = GetCurrentRealTime() + 30
					; _SDKP_sex.SendStoryEvent(akRef1 = kMaster, akRef2 =  kSlave, aiValue1 = 10)

				Else
					; Debug.Notification( "[Master ignores you]" )
				EndIf

			Else
				; Debug.Notification( "[Master is busy]" )
			EndIf

		EndIf

		If ( Self.GetOwningQuest() )
			RegisterForSingleUpdate( fRFSU )
		EndIf
	EndEvent

	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, Bool abPowerAttack, Bool abSneakAttack, Bool abBashAttack, Bool abHitBlocked)
		If ( akAggressor != kMaster && Self.GetOwningQuest().GetStage() < 90)
			kSlave.StopCombatAlarm()
			kSlave.StopCombat()
			If ( ( akAggressor as Actor ).IsHostileToActor( kMaster ) )
				kMaster.StartCombat( akAggressor as Actor )
			EndIf

		EndIf
	EndEvent
	
	Event OnItemAdded(Form akBaseItem, Int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
		If ( Self.GetOwningQuest().GetStage() >= 90 ) || ( akBaseItem.HasKeyword(_SDKP_noenchant) || akBaseItem.HasKeyword(_SDKP_nosale) )
			Return
		EndIf

;		Debug.Notification("[_sdras_slave] Adding item: " + akBaseItem)
;		Debug.Notification("[_sdras_slave] Slave bound status: " + kSlave.WornHasKeyword( _SDKP_bound ) )

		iuType = akBaseItem.GetType()
		_SDFLP_trade_items.AddForm( akBaseItem )

;		Debug.Notification("[_sdras_slave] Item type: " + iuType)

		If ( akItemReference == _SDRAP_masters_key.GetReference() )
			; escape
			Debug.Trace("[_sdras_slave] Master key stolen - Stop enslavement")

			fctOutfit.setDeviousOutfitArms ( bDevEquip = False, sDevMessage = "")
			fctOutfit.setDeviousOutfitLegs ( bDevEquip = False, sDevMessage = "")
			fctOutfit.setDeviousOutfitBlindfold ( bDevEquip = False, sDevMessage = "")
		
			if (Utility.RandomInt(0,100) < 60)
				fctOutfit.setDeviousOutfitCollar ( bDevEquip = False, sDevMessage = "")
				Debug.Messagebox("Your Master's Key helps you break free of your chains.")
			Else
				Debug.MessageBox("Your Master's Key helps you break free of your chains but the key snapped as you tried to force your collar open.")
			EndIf
			
			; Self.GetOwningQuest().Stop()
			kSlave.RemoveItem(akItemReference, aiItemCount)
			_SDKP_trust_hands.SetValue(1) 
			_SDKP_trust_feet.SetValue(1) 

			SendModEvent("SDFree")

			Return
		ElseIf ( kSlave.WornHasKeyword( _SDKP_bound ) )
			Debug.Notification( "$SD_MESSAGE_MASTER_AWARE" )
			
			; kPotion = 46
			If ( iuType == 46 || akBaseItem.HasKeyword( _SDKP_food ) || akBaseItem.HasKeyword( _SDKP_food_raw ) || akBaseItem.HasKeyword( _SDKP_food_vendor ) )

				If ( GetCurrentRealTime() - fLastIngest > 5.0 && !fctOutfit.isGagEquipped(kSlave) )
					If ( aiItemCount - 1 > 0 )
						kSlave.DropObject(akBaseItem, aiItemCount - 1)
					EndIf
					kSlave.EquipItem(akBaseItem, True, True)
				Else
					If ( kSlave.WornHasKeyword( _SDKP_gagged ) )
						Debug.Notification( "$SD_MESSAGE_GAGGED" )
					EndIf
					If ( GetCurrentRealTime() - fLastIngest <= 5.0 )
						Debug.Notification( "$SD_MESSAGE_WAIT_5_SEC" )
					EndIf
					kSlave.DropObject(akBaseItem, aiItemCount)
				EndIf

				fLastIngest = GetCurrentRealTime()

			ElseIf ( iuType == 41 || iuType == 42 ) && (fctSlavery.CheckSlavePrivilege(kSlave, "_SD_iEnableWeaponEquip") ) ; weapon or ammo

				;If ( GetCurrentRealTime() - fLastEscape < 5.0 )
				;	Debug.Notification( "$SD_MESSAGE_WAIT_5_SEC" )
				;	kSlave.DropObject(akBaseItem, aiItemCount)
				;
				; Else
				If ( _SDGVP_state_caged.GetValueInt() )
					If ( kSlave.GetActorValue("Lockpicking") > Utility.RandomInt(0, 100) )
						Debug.Notification( "$SD_MESSAGE_MAKE_LOCKPICK" )
						kSlave.AddItem( _SDMOP_lockpick, 1 )
					Else
						Debug.Notification( "$SD_MESSAGE_FAIL_LOCKPICK" )
					EndIf
					kSlave.RemoveItem( akBaseItem, aiItemCount, False )

					; Disabling 'braking chains with weapon' for now.
				ElseIf (0 == 1) && ( kMaster.GetSleepState() == 3 || !kMaster.HasLOS( kSlave ) )
					fDamage = ( akBaseItem as Weapon ).GetBaseDamage() as Float

					If ( fDamage <= 0.0 )
						fDamage = Utility.RandomFloat( 1.0, 4.0 )
					EndIf

					_SDFP_bindings_health -= fDamage
					If ( _SDFP_bindings_health < 0.0 )
						Debug.Trace("[_sdras_slave] Weak chains - Stop enslavement")
						Debug.Messagebox("You manage to break your chains with a weapon.")

						fctOutfit.setDeviousOutfitArms ( bDevEquip = False, sDevMessage = "")
						fctOutfit.setDeviousOutfitLegs ( bDevEquip = False, sDevMessage = "")
						fctOutfit.setDeviousOutfitBlindfold ( bDevEquip = False, sDevMessage = "")

						SendModEvent("SDFree") ; Self.GetOwningQuest().Stop()
						Return
					Else
						kSlave.DropObject(akBaseItem, aiItemCount)
					EndIf
				EndIf
				fLastEscape = GetCurrentRealTime()

			ElseIf ( iuType == 41 || iuType == 42 ) && (!fctSlavery.CheckSlavePrivilege(kSlave, "_SD_iEnableWeaponEquip") )
					; Debug.Notification( "$SD_MESSAGE_CAUGHT" )
					Debug.MessageBox( "You are not allowed to hold a weapon. Your owner takes that away from you." )

;					Self.GetOwningQuest().ModObjectiveGlobal( 2.0, _SDGVP_demerits, -1, _SDGVP_demerits_join.GetValue() as Float, False, True, _SDGVP_config_verboseMerits.GetValueInt() as Bool )

					kSlave.RemoveItem( akBaseItem, aiItemCount, False, kMaster )

			ElseIf ( iuType == 26 )  &&  (fctSlavery.CheckSlavePrivilege(kSlave, "_SD_iEnableArmorEquip") || fctSlavery.CheckSlavePrivilege(kSlave, "_SD_iEnableClothingEquip"))  ; Armor
				If ( !akBaseItem.HasKeywordString("SOS_Underwear") &&  !akBaseItem.HasKeywordString("SOS_Genitals"))
					; kSlave.DropObject(akBaseItem, aiItemCount)
					; kSlave.EquipItem(akBaseItem, True, True)
				Else
					Debug.Trace( "[_sdras_slave] Could not equip clothing." )
				EndIf

			ElseIf ( kMaster.GetSleepState() != 0 && kMaster.HasLOS( kSlave ) ) &&  fctSlavery.CheckSlavePrivilege(kSlave, "_SD_iEnableInventory")
				If ( !akBaseItem.HasKeywordString("SOS_Underwear") &&  !akBaseItem.HasKeywordString("SOS_Genitals"))
					Debug.MessageBox( "You are not allowed to pick something up yet. Your owner takes that away from you." )

					kSlave.RemoveItem( akBaseItem, aiItemCount, False, kMaster )
				EndIf
			EndIf
		EndIf
	EndEvent

EndState

State escape
	Event OnBeginState()
		; Debug.Notification( "$SD_MESSAGE_ESCAPE_NOW" )

		freedomTimer ( _SDGVP_escape_timer.GetValue() )
		fEscapeTime = GetCurrentRealTime() + _SDGVP_escape_timer.GetValue()
		fEscapeUpdateTime = GetCurrentRealTime() + 60

		; _SDSP_SelfShock.Cast(kSlave as Actor)
		; _SDSP_Weak.Cast(kSlave as Actor)

;		Self.GetOwningQuest().ModObjectiveGlobal( 3.0, _SDGVP_demerits, -1, _SDGVP_demerits_join.GetValue() as Float, False, True, _SDGVP_config_verboseMerits.GetValueInt() as Bool )

 		; _SDKP_hunt.SendStoryEvent(akRef1 = kMaster, akRef2 =  kSlave, aiValue1 = 10)

	EndEvent
	
	Event OnEndState()
		; Debug.Notification( "$SD_MESSAGE_ESCAPE_GONE" )


		If (kSlave.GetDistance(kMaster)< 200) && (!kMaster.IsDead()) && (!kMaster.IsInCombat())
			_SDSP_SelfShockEffect.Cast(kSlave as Actor)
			kSlave.DispelSpell( _SDSP_Weak )

			SendModEvent("SDEscapeStop") 
			Debug.Notification( "Where did you think you were going?" )

;			Self.GetOwningQuest().ModObjectiveGlobal( 5.0, _SDGVP_demerits, -1, _SDGVP_demerits_join.GetValue() as Float, False, True, _SDGVP_config_verboseMerits.GetValueInt() as Bool )

			if (Utility.RandomInt(0,100)>50)
				; Punishment
				enslavement.PunishSlave(kMaster,kSlave)
				_SDKP_sex.SendStoryEvent(akRef1 = kMaster, akRef2 = kSlave, aiValue1 = 3, aiValue2 = RandomInt( 0, _SDGVP_punishments.GetValueInt() ) )
			Else
				; Whipping
				_SDKP_sex.SendStoryEvent(akRef1 = kMaster, akRef2 = kSlave, aiValue1 = 5 )
			EndIf
		EndIf
	EndEvent

	Event OnUpdate()
		While ( !Game.GetPlayer().Is3DLoaded() )
		EndWhile

		fDistance = kSlave.GetDistance( kMaster )

		If (_SDGVP_config_safeword.GetValue() as bool)
			Debug.MessageBox( "Safeword: You are released from enslavement.")
			_SDGVP_state_joined.SetValue( 0 )
			_SDGVP_config_safeword.SetValue(0)

			SendModEvent("PCSubFree")
			; Self.GetOwningQuest().Stop()

		ElseIf ((kSlave.GetParentCell() == kMaster.GetParentCell()) && (kMaster.GetParentCell().IsInterior()) )
			
			If (RandomInt( 0, 100 ) > 70 )
				Debug.Notification( "Your captors are watching. Don't stray too far...")
			EndIf
			If (kMaster.GetParentCell().IsInterior()) 
				; Debug.Notification( "Master inside") 
			Else
				; Debug.Notification( "Master outside")
			EndIf
			If (kMaster.GetParentCell() == kSlave.GetParentCell()) 
				; Debug.Notification( "Slave and master in same cell ") 
			Else
				; Debug.Notification( "Slave and master in diff cells ") 
			EndIf

			GoToState("monitor")
		Else

			If ( Self.GetOwningQuest().IsStopping() || Self.GetOwningQuest().IsStopped() )
				GoToState("waiting")
			; ElseIf ( !enslavement.bEscapedSlave )
			; 	GoToState("monitor")
			ElseIf ( _SDCP_sanguines_realms.Find( kSlave.GetParentCell() ) >= 0 )
				GoToState("monitor")
			; ElseIf ( !Game.IsMovementControlsEnabled() )
			;	kSlave.PathToReference( kMaster, 1.0 )
			;	GoToState("monitor")
			ElseIf ( (fDistance > _SDGVP_escape_radius.GetValue()) && ((kSlave.GetParentCell() != kMaster.GetParentCell()) || (!kMaster.GetParentCell().IsInterior())) )

				; Escape timer is running
				If ( GetCurrentRealTime() > fEscapeUpdateTime )
					; Debug.Notification( "Run!" )
					fTime = fEscapeTime - GetCurrentRealTime()
					fEscapeUpdateTime = GetCurrentRealTime() + 60
					freedomTimer ( fTime ) ; - Displays "x minutes and you are free...

	;				Self.GetOwningQuest().ModObjectiveGlobal( 3.0, _SDGVP_demerits, -1, _SDGVP_demerits_join.GetValue() as Float, False, True, _SDGVP_config_verboseMerits.GetValueInt() as Bool )

				ElseIf ( GetCurrentRealTime() >= fEscapeTime )
					; Escape timer is exceeded - player has escaped
					; Debug.Trace("[_sdras_slave] Escaped from master - collar will send random shocks")
					_SDFP_slaversFaction.ModCrimeGold( 1000 )
					enslavement.bEscapedSlave = True
					enslavement.bSearchForSlave = True

					SendModEvent("SDEscapeStart") 

					; SendModEvent("SDFree") ; Self.GetOwningQuest().Stop()
					; Return

					If (Utility.RandomInt(0,100)>=90)

						_SDSP_SelfShockEffect.Cast(kSlave as Actor)

						If (Utility.RandomInt(0,100)>=95)
							_SDSP_Weak.Cast(kSlave as Actor)
						EndIf
					EndIf

				EndIf
			EndIf
		EndIf

		If ( Self.GetOwningQuest() ) && (!enslavement.bEscapedSlave)
			RegisterForSingleUpdate( fRFSU )
		ElseIf ( Self.GetOwningQuest() ) && (enslavement.bEscapedSlave)
			RegisterForSingleUpdate( fRFSU / 4.0 )
		EndIf
	EndEvent
EndState

State caged
	Event OnBeginState()
		enslavement.bEscapedSlave = False
		enslavement.bSearchForSlave = False
	EndEvent
	
	Event OnEndState()
	EndEvent

	Event OnUpdate()
		While ( !Game.GetPlayer().Is3DLoaded() )
		EndWhile
		
		If ( !_SDGVP_state_caged.GetValueInt() )
			GoToState("monitor")
		ElseIf ( _SDRAP_cage.GetReference().GetDistance( kSlave ) > 768 )
			GoToState("escape")
			_SDGVP_state_caged.SetValue( 0 )
		EndIf

		If ( Self.GetOwningQuest() )
			RegisterForSingleUpdate( fRFSU )
		EndIf
	EndEvent
EndState


GlobalVariable Property _SDGVP_state_joined  Auto  
GlobalVariable Property _SDGVP_state_housekeeping  Auto   

SexLabFramework Property SexLab  Auto  

Keyword Property _SDKP_collar  Auto  
Keyword Property _SDKP_gag  Auto  

ReferenceAlias Property _SDRAP_collar  Auto  

Armor Property _SDA_gag  Auto  
Armor Property _SDA_collar  Auto  
Armor Property _SDA_bindings  Auto  
Armor Property _SDA_shackles  Auto  

Keyword Property _SDKP_hunt  Auto  
Sound Property _SDSMP_choke  Auto  

ImageSpaceModifier Property _SD_CollarStrangleImod  Auto  
