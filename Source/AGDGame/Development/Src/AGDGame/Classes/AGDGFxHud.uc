class AGDGFxHud extends GFxMoviePlayer;

var AGDPlayerController PCGfx;

function Init( optional LocalPlayer LocPlay )
{
	Start();
	Advance(0.0f);	
}

function SetPlayerController(AGDPlayerController gfxPlayerController)
{
	PCGfx = gfxPlayerController;
}

DefaultProperties
{
	bDisplayWithHudOff = false	
	bEnableGammaCorrection=false	 
    bIgnoreMouseInput = false
    bPauseGameWhileActive = false
    bCaptureInput = false

	MovieInfo = SwfMovie'AGDHUD.MouseCursor'
}
