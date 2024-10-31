/***********************************************
 * Base Character Controller Class  (For Individuals)
 * **********************************************/
class AGDAnimalController extends GameAIController;

var Vector SpawnPoint;    // The point at which the animal originally spawned


var Vector Destination;     // The destination of the character used in MovingToLocation
var Vector MidDestination;  // Mid points for the destination path used in MovingToLocation
var bool MovingToDestination; // Is the animal currently moving to a destination?
var float TimeToWait;         // Time to wait before generating the next destination

var float RespawnTime;

var bool killed;
var bool spawned;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	SpawnPoint = Location;

	spawned = true;
}

event Tick(float DeltaTime)
{
	local AGDBoarPawn newPawn;

	if (!killed && spawned && !MovingToDestination && TimeToWait > 0) // If not currently moving and there is still time to wait
		TimeToWait -= DeltaTime;
	else if (!killed && spawned && !MovingToDestination && TimeToWait <= 0)
		GenerateDestination();
	
	if (RespawnTime <= 0 && killed)
	{
		Pawn.ZeroMovementVariables();
		RespawnTime = Rand(5) + 5;
		killed = false;
		spawned = false;
	}
	else if (RespawnTime > 0 && !spawned)
	{
		RespawnTime -= DeltaTime;
	}
	else if (RespawnTime <= 0 && !spawned)
	{
		killed = false;

		newPawn = Spawn(class'AGDBoarPawn');
		newPawn.SetLocation(SpawnPoint);
		spawned = true;

		Destroy();
	}
	
}

// Generates a new random destination for the animal
function GenerateDestination()
{
	local Vector TargetLocation;

	// Generate a point within 1024x1024 of the spawn point
	TargetLocation.X = SpawnPoint.X + (Rand(512) - 256);
	TargetLocation.Y = SpawnPoint.Y + (Rand(512) - 256);
	TargetLocation.Z = SpawnPoint.Z;
	MovingToDestination = true;
	TimeToWait = Rand(4) + 1;
	Destination = TargetLocation;
	GotoState('MovingToLocation');
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
		if (FindPath(Destination))
		{
			NavigationHandle.SetFinalDestination(Destination);
			while (Pawn != None && !Pawn.ReachedPoint(Destination, None))
			{
				if (!spawned)
					break;
				
				if (NavigationHandle.PointReachable(Destination))
				{					
					SetRotation(Rotator(Destination - Pawn.Location)); 					
					MoveTo(Destination);
				}
				else
				{
					if (NavigationHandle.GetNextMoveLocation(MidDestination, Pawn.GetCollisionRadius()))
					{
						if (!NavigationHandle.SuggestMovePreparation(MidDestination, self))
						{	
							SetDesiredRotation(Rotator(MidDestination - Pawn.Location)); 
							if(Pawn.ReachedDesiredRotation())
								MoveTo(MidDestination);						
						}
					}
				}
				if (Pawn.ReachedPoint(Destination, None) || Distance(Destination, Pawn.Location) < 256)
				{
					//ensure that the character STOPS moving when they reach the destination
					Pawn.ZeroMovementVariables();
					break;
				}
			}
		}
		else
		{
			`Log("AGDAnimalController:: Unable to find a path to the location - Animal: " $ self.Name);
		}

	MovingToDestination = false;
	Pawn.ZeroMovementVariables();
}