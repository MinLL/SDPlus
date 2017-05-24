;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname _sdtif_dreamworld_03 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE

Int randomNum = Utility.RandomInt(0, 100)
; StorageUtil.SetFormValue( Game.getPlayer() , "_SD_TempAggressor", akSpeaker)

If (randomNum > 70)
	akSpeaker.SendModEvent("PCSubPunish") ; Punishment
ElseIf (randomNum > 30)
	akSpeaker.SendModEvent("PCSubWhip") ; Whipping
Else
	akSpeaker.SendModEvent("PCSubSex") ; Sex
EndIf


;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

GlobalVariable Property _SDGV_SanguineBlessing  Auto  

Keyword Property _SDKP_sex  Auto  

GlobalVariable Property _SDGVP_punishments  Auto  

SexLabFramework Property SexLab  Auto  

_sdqs_functions Property funct  Auto  

Message Property _SD_rapeMenu  Auto  
