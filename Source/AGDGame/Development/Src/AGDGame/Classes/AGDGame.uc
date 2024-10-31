/*******************************************************************
AGDGame
*******************************************************************/
class AGDGame extends GameInfo;

var AGDMinimap GameMinimap;

function InitGame( string Options, out string ErrorMessage )
{
	local AGDMinimap ThisMinimap;

	Super.InitGame(Options,ErrorMessage);

	foreach AllActors(class'AGDMinimap',ThisMinimap)
	{
		GameMinimap = ThisMinimap;
		break;
	}
}

defaultproperties
{
	DefaultPawnClass = class'AGDGame.AGDPawn'
	PlayerControllerClass = class'AGDGame.AGDPlayerController'
	HUDType = class'AGDGame.AGDHUD'
	PlayerReplicationInfoClass=class'UTGame.UTPlayerReplicationInfo'
	GameReplicationInfoClass=class'UTGame.UTGameReplicationInfo'
	//bRestartLevel=False
	bDelayedStart=False
	//bUseSeamlessTravel=true
}