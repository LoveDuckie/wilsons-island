class AGDCHTrait extends Actor;

var int _traitType;

var bool _selectedtrait;

function PostBeginPlay()
{

}

event Tick(float DeltaTime)
{
	if (_selectedtrait == false)
	{
		
		_selectedtrait = true;
	}
}

function PostRender()
{

}

DefaultProperties
{

	// Don't spawn anything
}
