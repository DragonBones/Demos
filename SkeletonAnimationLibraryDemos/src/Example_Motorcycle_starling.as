package  {
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;

	import starling.core.Starling;

    [SWF(width="800", height="600", frameRate="30", backgroundColor="#999999")]
	public class Example_Motorcycle_starling extends flash.display.Sprite {

		public function Example_Motorcycle_starling() {
			starlingInit();
		}

		private function starlingInit():void {
			var _starling:Starling = new Starling(StarlingGame, stage);
			//_starling.antiAliasing = 1;
			_starling.showStats = true;
			_starling.start();

			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyEventHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyEventHandler);
		}

		private var left:Boolean;
		private var right:Boolean;

		private function onKeyEventHandler(e:KeyboardEvent):void {
			switch (e.keyCode) {
				case 37 :
				case 65 :
					left = e.type == KeyboardEvent.KEY_DOWN;
					updateMove(-1);
					break;
				case 39 :
				case 68 :
					right = e.type == KeyboardEvent.KEY_DOWN;
					updateMove(1);
					break;
			}
		}

		private function updateMove(_dir:int):void {
			if (left && right) {
				StarlingGame.instance.move(_dir);
			}else if (left){
				StarlingGame.instance.move(-1);
			}else if (right){
				StarlingGame.instance.move(1);
			}else {
				StarlingGame.instance.move(0);
			}
		}
	}
}

import starling.display.Sprite;
import starling.events.EnterFrameEvent;

import dragonBones.Armature;
import dragonBones.factorys.StarlingFactory;
import flash.events.Event;

class StarlingGame extends Sprite {
	[Embed(source = "../assets/Motorcycle_output.png", mimeType = "application/octet-stream")]
	private static const ResourcesData:Class;

	public static var instance:StarlingGame;

	private var factory:StarlingFactory;
	private var armature:Armature;
	private var armatureClip:Sprite;

	public function StarlingGame() {
		instance = this;

		factory = new StarlingFactory();
		factory.parseData(new ResourcesData());
		factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
	}

	private function textureCompleteHandler(e:Event):void {
		armature = factory.buildArmature("motorcycleMan");
		armatureClip = armature.display as Sprite;
		armatureClip.x = 400;
		armatureClip.y = 400;
		addChild(armatureClip);
		updateMovement();
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
	}

	private function onEnterFrameHandler(_e:EnterFrameEvent):void {
		updateSpeed();
		armature.update();
	}

	private var moveDir:int;

	private var speedX:Number = 0;

	public function move(_dir:int):void {
		if (moveDir == _dir) {
			return;
		}
		moveDir = _dir;
		updateMovement();
	}

	private function updateMovement():void {
		if (moveDir == 0) {
			speedX = 0;
			armature.animation.gotoAndPlay("stay");
		}else {
			speedX = moveDir * 20;
			if (moveDir > 0) {
				armature.animation.gotoAndPlay("right");
			}else {
				armature.animation.gotoAndPlay("left");
			}
		}
	}

	private function updateSpeed():void {
		if (speedX != 0) {
			//armatureClip.x += speedX;
			if (armatureClip.x < 0) {
				armatureClip.x = 0;
			}else if (armatureClip.x > 800) {
				armatureClip.x = 800;
			}
		}
	}
}