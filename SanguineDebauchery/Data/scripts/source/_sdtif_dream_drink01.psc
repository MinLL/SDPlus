;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname _sdtif_dream_drink01 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
Actor kPlayer = Game.GetPlayer()

kPlayer.RemoveItem(FoodHonningbrewMead, 1 )
akSpeaker.AddItem(FoodHonningbrewMead, 1 )
akSpeaker.EquipItem(FoodHonningbrewMead, 1 )

Self.GetOwningQuest().SetStage(202)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Potion Property FoodHonningbrewMead  Auto  
