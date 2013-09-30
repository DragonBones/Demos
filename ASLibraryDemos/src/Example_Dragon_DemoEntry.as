package
{
	import flash.display.Sprite;
	
	import starling.core.Starling;
	
	[SWF(width="800", height="600", frameRate="30", backgroundColor="#cccccc")]
	
	public class Example_Dragon_DemoEntry extends Sprite
	{
		public function Example_Dragon_DemoEntry()
		{
			var _starling:Starling = new Starling(Dragon_SwitchClothes, stage);
			//var _starling:Starling = new Starling(Dragon_ChaseStarling, stage);
			
			//_starling.antiAliasing = 1;
			_starling.showStats = true;
			_starling.start();
		}
	}
}