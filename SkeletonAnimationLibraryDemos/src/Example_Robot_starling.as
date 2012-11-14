package  {
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import starling.core.Starling;

    [SWF(width="800", height="600", frameRate="30", backgroundColor="#999999")]
	public class Example_Robot_starling extends flash.display.Sprite {

		public function Example_Robot_starling() {
			starlingInit();
			stage.addEventListener(MouseEvent.CLICK, mouseHandler);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseHandler);
		}

		private function mouseHandler(e:MouseEvent):void 
		{
			switch(e.type) {
				case MouseEvent.CLICK:
					StarlingGame.instance.changeMovement();
					break;
				case MouseEvent.MOUSE_WHEEL:
					StarlingGame.instance.changeAnimationScale(e.delta > 0?1: -1);
					break;
			}
		}

		private function starlingInit():void {
			var _starling:Starling = new Starling(StarlingGame, stage);
			//_starling.antiAliasing = 1;
			_starling.showStats = true;
			_starling.start();
		}
	}
}

import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.text.TextField;

import dragonBones.Armature;
import dragonBones.factorys.StarlingFactory;
import flash.events.Event;

class StarlingGame extends Sprite {
	[Embed(source = "../assets/Robot_output.swf", mimeType = "application/octet-stream")]
	private static const ResourcesData:Class;

	public static var instance:StarlingGame;

	private var factory:StarlingFactory;
	private var armature:Armature;
	private var textField:TextField;

	public function StarlingGame() {
		instance = this;


		factory = new StarlingFactory();
		factory.parseData(new ResourcesData());
		factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
	}

	private function textureCompleteHandler(e:Event):void {
		armature = factory.buildArmature("robot");
		var _display:Sprite = armature.display as Sprite;
		_display.x = 400;
		_display.y = 300;
		addChild(_display);
		armature.animation.gotoAndPlay("stop");
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
		
		textField = new TextField(700, 30, "Click mouse to switch robot's postures. Scroll mouse wheel to change speed.", "Verdana", 16, 0, true);
		textField.x = 60;
		textField.y = 5;
		addChild(textField);
	}

	public function changeMovement():void 
	{
		do{
			var _movement:String = armature.animation.movementList[int(Math.random() * armature.animation.movementList.length)];
		}while (_movement == armature.animation.movementID);
		armature.animation.gotoAndPlay(_movement);
	}

	public function changeAnimationScale(_dir:int):void 
	{
		if (_dir > 0) {
			if (armature.animation.timeScale < 10) {
				armature.animation.timeScale += 0.1;
			}
		}else {
			if (armature.animation.timeScale > 0.2) {
				armature.animation.timeScale -= 0.1;
			}
		}
	}

	private function onEnterFrameHandler(_e:EnterFrameEvent):void {
		armature.update();
	}
}