/***********************************************
 * Base Character Controller Class  (For Individuals)
 * **********************************************/
class AGDCHController extends GameAIController;

struct EntityStorage
{
	var int Rock;
	var int Wood;
	var int Food;
};

struct Skill
{
	var int lvl;
	var int totalExperience;
};

enum SkillType
{ 
	Null,
	Hunting,
	Gathering,
	Exploration
};
var int levelRequirements[5]; // How much experience required for each next consecutive level in a skill. levelRequirements[0] gives the exp requirement for level 2.

var AudioComponent _audiocomponent;
var array<SoundCue> _clicks; // Sounds for when the character is clicked on.
var array<SoundCue> _going; // Sounds for when the character is told to go somewhere.

var Skill skillHunting;
var Skill skillGathering;
var Skill skillExploration;

var EntityStorage CharacterStorage;

var Vector Destination;     // The destination of the character used in MovingToLocation
var Vector MidDestination;  // Mid points for the destination path used in MovingToLocation

var Actor CharacterTarget;		// Holds info on the target actor
var bool IsMovingToActor;
var bool bActorReached;

var int InventorySize;			// The amount that the character can carry
var int totalAmount;			// The amount of items that the character is currently carrying
var bool collecting;
var float maxGatherPause;
var float maxEatingPause;
var float maxHuntingPause;
var float gatherPause;

var AGDStructureStorage StorageBuilding;
var AGDStructureFire CampFire;

var float happyGauge;
var float hungerGauge;
var int hungerState;	
var float eatingPause;
var bool IsEating;

var AGDGFxCharacterStatus GFxStatus;
var AGDGFxCharacterInfo GFxInfo;

var AGDMeshSelectedChar SelectedMesh; // The selection ring around the selected char
var bool Selected; // Is the character currently selected?

var AGDPlayerController AGDPlayerCont;
var SkillType CurrentSkill;

defaultproperties
{
	NavigationHandleClass=class'NavigationHandle'
	InventorySize = 10
	totalAmount = 0			//amount of resources the character is carrying.
	maxGatherPause = 6;
	maxHuntingPause = 6;
	maxEatingPause = 6;
	gatherPause = 6;		//tick between item collection when a character is collecting
	eatingPause = 6;
	happyGauge = 1.0f;
	hungerGauge = 1.0f;
	hungerState = 0;
	IsEating = false;
	CurrentSkill = Null;
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	self._audiocomponent = new class'AudioComponent';
	
	skillHunting.lvl = 1;
	skillHunting.totalExperience = 0;
	skillGathering.lvl = 1;
	skillGathering.totalExperience = 0;
	skillExploration.lvl = 1;
	skillExploration.totalExperience = 0;

	levelRequirements[0] = 0;
	levelRequirements[1] = 10;
	levelRequirements[2] = 35;
	levelRequirements[3] = 60;
	levelRequirements[4] = 100;
}

function PlayCharacterSound(int _soundtype)
{
	switch(_soundtype)
	{

		// Clicked on
		case 0:
			if (_clicks[0] != none)
			{
				_audiocomponent.SoundCue = _clicks[0];
				_audiocomponent.Play();
			}
			else
			{
				`log("AGDCHController::Audio is empty. (Clicks)");
			}
		break;

		// Moving
		case 1:
			if (_going[0] != none)
			{
				_audiocomponent.SoundCue = _going[0];
				_audiocomponent.Play();
			}
			else
			{
				`log("AGDCHController::Audio is empty. (Going)");
			}
		break;
	}
}

function CloseStatusBars()
{
	if(GFxStatus != none)
	{
		GFxStatus.Close(true);
		GFxStatus = none;
	}
}

// Shows the scaleform status bars for happiness and hunger
function ShowStatusBars()
{
	CloseStatusBars();

	GFxStatus = new class'AGDGFxCharacterStatus';
	GFxStatus.SetTimingMode(TM_Real);
	GFxStatus.Init();		
	GFxStatus.SetPriority(0);
}

function CloseInfo()
{
	if(GFxInfo != none)
	{
		GFxInfo.Close(true);
		GFxInfo = none;
	}
}

function ShowInfo()
{
	CloseInfo();

	GFxInfo = new class'AGDGFxCharacterInfo';
	GFxInfo.SetTimingMode(TM_Real);
	GFxInfo.Init();		
	GFxInfo.SetPriority(0);
}
auto state Idle
{
	begin:
		Pawn.ZeroMovementVariables();
		collecting = false;
		IsEating = false;
		AGDCHPawn(Pawn).BlendListNode.SetActiveChild(0, 0);
}
state Eating
{
	function GetStorage()
	{
		local AGDStructureStorage tempStorage;

		//search for the storage to empty your bags
		foreach AllActors(class'AGDStructureStorage', tempStorage)
		{
			StorageBuilding = tempStorage;
		}
	}
	Begin:
		Pawn.ZeroMovementVariables();
		IsEating = true;
		AGDCHPawn(Pawn).BlendListNode.SetActiveChild(6, 0.5);
		if(StorageBuilding == none)
			GetStorage();
		if (StorageBuilding.HugeStorage.Food > 0 && hungerGauge < 1.0)
		{
			`Log("Nom nom nom nom");

			StorageBuilding.HugeStorage.Food--;
			hungerGauge += 0.1f;
				
			if (hungerGauge > 1)
			{
				hungerGauge = 1.0f;
				IsEating = false;
				GoToState('Idle');
			}

			happyGauge += 0.1f;
			if (happyGauge > 1)
			{
				happyGauge = 1.0f;
			}				
		}
		else
		{
			GoToState('Idle');
			IsEating = false;
		}

		eatingPause = maxEatingPause;
}

function CollectingStuff()
{
	if (collecting && gatherPause <= 0)
	{
		`Log("Collecting = " @collecting);
		`Log("gatherPause = " @gatherPause);
		`Log("maxGatherPause = " @maxGatherPause);
		hungerGauge -= 0.005f;
		gatherPause = maxGatherPause;	//set the timer back to 4 to restart the countdown
		GotoState('AGDEntityCollection');
	}
}

// When the character has reached an Entity that needs collecting, do so!
state AGDEntityCollection
{	
	Begin:
		//if the character doesnt have a full bag, do this...
		if (totalAmount != InventorySize)
		{
			// Check that it is a fish entity first, before moving on to generic entities.

			if (AGDFishEntity(CharacterTarget) != none)
			{   
				if (AGDFishEntity(CharacterTarget)._amount == 0)
				{
					collecting = false;
					CharacterTarget.Destroy();
					CharacterTarget = none;
					GoToState('Idle');
					`log("AGDCHController:: Removed fish due to lack of resources.");
				}
				else
				{
					CharacterStorage.Food++;
					skillGathering.totalExperience++;

					totalAmount++;

					// Decrease the amount of resources from the fish.
					AGDFishEntity(CharacterTarget)._amount--;

					if (totalAmount == InventorySize)
					{
						GoToState('Idle');
					}
				}
			} 
			// Rocks, trees & berries
			else if (AGDEntity(CharacterTarget) != None)
			{
				//if the characters target has ran out of resources then stop collecting
				if (AGDEntity(CharacterTarget)._amount == 0)
				{
					collecting = false;
					CharacterTarget.Destroy();
					CharacterTarget = None;
					GoToState('Idle');
					`Log("Removed collecting target!");
				}
				else
				{
					//depending on what type the item is, add 1 to the relevant part
					switch(AGDEntity(CharacterTarget)._type)
					{
						case 0:
							CharacterStorage.Rock++;
						break;

						case 1:
							CharacterStorage.Wood++;
						break;

						case 2:
							CharacterStorage.Food++;
						break;
					}
					
					skillGathering.totalExperience++;
					
					totalAmount++;
					AGDEntity(CharacterTarget)._amount--;
					happyGauge += 0.005f;
					if (happyGauge > 1)
					{
						happyGauge = 1.0f;
					}

					if (totalAmount == InventorySize)
					{
						GoToState('Idle');
					}
				}
			}
			else if (AGDAnimalPawn(CharacterTarget) != none) // It's an animal
			{
				CharacterStorage.Food++;
				skillHunting.totalExperience++;
				
				totalAmount++;
				happyGauge += 0.005f;
				if (happyGauge > 1)
				{
					happyGauge = 1.0f;
				}

				`Log("happyGauge: " @ happyGauge);
				`Log("I hunted the Animal and am now carrying" @ CharacterStorage.Food @ "of Food");
				CharacterTarget.Destroy();				
				GoToState('Idle');
				if (totalAmount == InventorySize)
				{
					GoToState('Idle');
				}
			}
		}
		else
		{
			// If their inventory is full, then go back to the storage.
			GoToState('Idle');
		}
}

// When a character is moving to a given location
state MovingToLocation
{
	function bool FindPath(Vector TargetLocation)
	{
		NavigationHandle.PathConstraintList = none;
		NavigationHandle.PathGoalList = none;

		class'NavMeshPath_Toward'.static.TowardPoint(NavigationHandle, TargetLocation);
		class'NavMeshGoal_At'.static.AtLocation(NavigationHandle, TargetLocation,, true);

		return NavigationHandle.FindPath();
	}

	function float Distance(Vector Location1, Vector Location2)
	{
		local Vector Difference;
		Difference = Location1 - Location2;

		return Sqrt((Difference.X * Difference.X) + (Difference.Y * Difference.Y));
	}

	Begin:
		if(!Pawn.bIsMoving)
		{
			AGDCHPawn(Pawn).BlendListNode.SetActiveChild(0, 0);
		}
	
		AGDCHPawn(Pawn).BlendWalkListNode.SetActiveChild(0, 0);

		//if we are moving we should not be collecting still
		`Log ("MovingToLocation!");
		collecting = false;
		IsEating = false;
		AGDCHPawn(Pawn).Axe.SetHidden(true);
		AGDCHPawn(Pawn).PickAxe.SetHidden(true);
		AGDCHPawn(Pawn).Spear.SetHidden(true);

		if (FindPath(Destination))
		{
			NavigationHandle.SetFinalDestination(Destination);

			while (Pawn != None && !Pawn.ReachedPoint(Destination, None))
			{
				if (NavigationHandle.PointReachable(Destination))
				{	
					Destination.Z = Pawn.Location.Z;
					Pawn.SetRotation(Rotator(Destination - Pawn.Location));
					MoveTo(Destination);
				}
				else
				{
					if (NavigationHandle.GetNextMoveLocation(MidDestination, Pawn.GetCollisionRadius()))
					{
						if (!NavigationHandle.SuggestMovePreparation(MidDestination, self))
						{	
							Destination.Z = Pawn.Location.Z;
							Pawn.SetRotation(Rotator(MidDestination - Pawn.Location));
							MoveTo(MidDestination);						
						}
					}
				}
				if (Pawn.ReachedPoint(Destination, None) || bActorReached)
				{
					//ensure that the character STOPS moving when they reach the destination
					`Log("Destination Reached");
					IsMovingToActor = false;
					bActorReached = false;
					Pawn.ZeroMovementVariables();
					if(CharacterTarget != none)
					{						
						Pawn.SetRotation(Rotator(CharacterTarget.Location - Pawn.Location));
					}
					if (AGDEntity(CharacterTarget) != None)
					{
						if (totalAmount != InventorySize)
						{
							`Log("I have reached the" @ AGDEntity(CharacterTarget)._type @ "and I'm ready to start collecting it!");

							//Changing animation according to resource being collected (berries, wood, rock)
							ChangeAnim(AGDEntity(CharacterTarget)._type);

							collecting = true;
							GoToState('AGDEntityCollection');
						}
					}
					else if (AGDAnimalPawn(CharacterTarget) != None)
					{
						if (totalAmount != InventorySize)
						{
							AGDCHPawn(Pawn).BlendListNode.SetActiveChild(4, 0);
							AGDCHPawn(Pawn).Spear.SetHidden(false);

							collecting = true;							
							AGDAnimalController(AGDAnimalPawn(CharacterTarget).Controller).killed = true;
						}
					}
					else if (AGDStructureStorage(CharacterTarget) != None)
					{
						// this is where we will set a "memory" location goto the base
						// empty the inventory and then return to the "memory" location
						// place the amount of the carryingentity into the storage

						AGDStructureStorage(CharacterTarget).HugeStorage.Rock += CharacterStorage.Rock;
						AGDStructureStorage(CharacterTarget).HugeStorage.Wood += CharacterStorage.Wood;
						AGDStructureStorage(CharacterTarget).HugeStorage.Food += CharacterStorage.Food;

						// then reset the storage amounts and totalAmount
						CharacterStorage.Rock = 0;
						CharacterStorage.Wood = 0;
						CharacterStorage.Food = 0;
						totalAmount = 0;
					}
					else if (AGDFishEntity(CharacterTarget) != none)
					{

						if (totalAmount != InventorySize)
						{
							AGDCHPawn(Pawn).BlendListNode.SetActiveChild(2, 0);
							AGDCHPawn(Pawn).Spear.SetHidden(false);

							collecting = true;
							
							GoToState('AGDEntityCollection');
						}

					}
					else if (AGDStructureFire(CharacterTarget) != None)
					{				
						`Log("Going to eating State");

						GoToState('Eating');
					}
					break;
				}
			}
		}
		else
		{
			`Log("I pity the fool who makes me walk there!");
		}
		
	Pawn.ZeroMovementVariables();
}

function ChangeAnim(int type)
{
	switch(type)
	{
		// Mining
		case 0:
			AGDCHPawn(Pawn).BlendListNode.SetActiveChild(7, 0.5);
			AGDCHPawn(Pawn).PickAxe.SetHidden(false);
			break;

		// Wood cutting
		case 1:
			AGDCHPawn(Pawn).BlendListNode.SetActiveChild(3, 0.5);
			AGDCHPawn(Pawn).Axe.SetHidden(false);
			break;
		// Gathering
		case 2:
			AGDCHPawn(Pawn).BlendListNode.SetActiveChild(8, 0.5);
			break;
		// Fishing
		case 3:
			AGDCHPawn(Pawn).BlendListNode.SetActiveChild(2, 0.5);
			AGDCHPawn(Pawn).Spear.SetHidden(false);
			break;
	}
}
// Moves the character to the given location, passing in a target actor for contextual use (cutting wood, etc)
function MoveToLocation(Vector TargetLocation, Actor TargetActor)
{
	// Play the sound of the character going.
	self.PlayCharacterSound(1);

	Destination = TargetLocation;
	if (AGDEntity(TargetActor) != None)
	{
		CharacterTarget = TargetActor;
	}
	else if (AGDStructure(TargetActor) != None)
	{
		CharacterTarget = TargetActor;
	}
	else if (AGDAnimalPawn(TargetActor) != none)
	{
		CharacterTarget = TargetActor;
	}
	else if (AGDFishEntity(TargetActor) != none)
	{
		CharacterTarget = TargetActor;
	}
	else
	{
		CharacterTarget = None;
	}

	`Log(CharacterTarget);
	if(CharacterTarget != none)
		IsMovingToActor = true;
	else
		IsMovingToActor = false;
	`Log(IsMovingToActor);

	GotoState('MovingToLocation');
}

function Tick(float DeltaTime)
{
	local Vector SelectedCharMeshOffset;	
	local AGDStructureFire tempFire;
	local Vector diff;
	local float dist;
	local float deltaUpdate;
	local Actor tempActor;
	local float radius;
	local float height;
	Pawn.GetBoundingCylinder(radius, height);
	deltaUpdate = DeltaTime * 0.004;

	if (!Selected)
	{
		CloseStatusBars();
		CloseInfo();
	}

	if(!IsEating)
	{
		hungerGauge -= deltaUpdate;
	}
	else
	{
		eatingPause -= DeltaTime;
		if(eatingPause <= 0)
		{
			`Log("Eating state still");
			GoToState('Eating');
		}
	}

	if (hungerGauge < 0)
	{
		hungerGauge = 0.0f;
		happyGauge -= DeltaTime * 0.01;

		if (happyGauge < 0)
			happyGauge = 0;
	}
	else if (hungerGauge > 1.0)
	{
		hungerGauge = 1.0f;
	}		
		
	if (collecting)
	{
		gatherPause -= DeltaTime;
		CollectingStuff();
	}
		
	foreach AllActors(class'AGDStructureFire', tempFire)
	{
		diff = Pawn.Location - tempFire.Location;
		dist = Sqrt((diff.X * diff.X) + (diff.Y * diff.Y));

		if (dist >= 600.0f)
		{
			if (happyGauge > 0)
			{
				happyGauge -= 0.0001;
			}
		}
		else
		{
			if (happyGauge < 1.0)
			{
				happyGauge += 0.0001;
				if (happyGauge > 1.0)
				{
					happyGauge = 1.0;
				}
			}
		}
	}
	if(IsMovingToActor)
	{
		foreach Pawn.CollidingActors(class'Actor', tempActor, 150)
		{
			if(tempActor.Location == CharacterTarget.Location && tempActor.Tag == CharacterTarget.Tag)
			{
				bActorReached = true;
				IsMovingToActor = false;
				Pawn.ZeroMovementVariables();
				AGDCHPawn(Pawn).BlendWalkListNode.SetActiveChild(0, 0);
				`Log("CheckPoint Reached");
				break;
			}
		}
	}
	if (Selected)
	{
		if (SelectedMesh == none)
			SelectedMesh = Spawn(class'AGDMeshSelectedChar', Pawn, 'SelectedCharMesh');

		SelectedCharMeshOffset = Pawn.Location;
		SelectedCharMeshOffset.Z -= 50;
		SelectedMesh.SetLocation(SelectedCharMeshOffset);
	}
	else
	{
		if (SelectedMesh != none)
		{
			SelectedMesh.Destroy();
			SelectedMesh = none;
		}
	}


	// Get the current skill being used
    if (AGDEntity(CharacterTarget) != None) // gathering
		CurrentSkill = Gathering;
    else if (AGDAnimalPawn(CharacterTarget) != none) // It's an anima
		CurrentSkill = Hunting;
	else
		CurrentSkill = Null;


	UpdateSkills();

	if (Selected && GFxStatus == none)
		ShowStatusBars();
	else if (Selected && GFxStatus != none)
	{
		GFxStatus.Update(self);
	}

	if (Selected && GFxInfo == none)
		ShowInfo();
	else if (Selected && GFxInfo != none)
	{
		GFxInfo.Update(self);
	}
}

// Update the skills of the character
function UpdateSkills()
{
	local int i;

	for (i = 0; i < 5; i++)
	{
		if (skillHunting.totalExperience >= levelRequirements[i])
		{
			skillHunting.lvl = i + 1;
			maxHuntingPause = 5 - i + 1;		
		}

		if (skillGathering.totalExperience >= levelRequirements[i])
		{
			skillGathering.lvl = i + 1;
			maxGatherPause = 5 - i + 1;
			InventorySize = 10 + i + 1;
		}

		if (skillExploration.totalExperience >= levelRequirements[i])
		{
			//What is dis I'm 12 
			skillExploration.lvl = i + 1;
		}
	}
}