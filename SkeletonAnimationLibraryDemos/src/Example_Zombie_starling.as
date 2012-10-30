package  {
	import flash.display.Sprite;
	
	import starling.core.Starling;
	
    [SWF(width="800", height="600", frameRate="30", backgroundColor="#999999")]
	public class Example_Zombie_starling extends flash.display.Sprite {
		
		public function Example_Zombie_starling() {
			starlingInit();
		}
		
		private function starlingInit():void {
			var _starling:Starling = new Starling(StarlingGame, stage);
			//_starling.antiAliasing = 1;
			_starling.showStats = true;
			_starling.start();
		}
	}
}

import flash.geom.Point;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Touch;
import starling.events.TouchPhase;
import starling.events.TouchEvent;

import dragonBones.Armature;
import dragonBones.factorys.StarlingFactory;

class StarlingGame extends Sprite {
	[Embed(source = "../assets/Zombie.swf", mimeType = "application/octet-stream")]
	private static const ResourcesData:Class;
	
	private var factory:StarlingFactory;
	private var allArmatureNameList:Array;
	private var armatures:Array;
	public function StarlingGame() {
		factory = new StarlingFactory();
		factory.fromRawData(new ResourcesData(), textureCompleteHandler);
	}
	
	private function textureCompleteHandler():void {
		allArmatureNameList = factory.skeletonData.getSearchList();
		armatures = [];
		
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
	}
	
	private function onMouseClickHandler(_e:TouchEvent):void {
		var _touch:Touch = _e.getTouch(stage, TouchPhase.ENDED);
		if (!_touch) {
			return;
		}
		var _p:Point = _touch.getLocation(stage);
		
		var _randomID:String = allArmatureNameList[int(Math.random() * allArmatureNameList.length)];
		var _armature:Armature = factory.buildArmature(_randomID);
		
		_armature.display.x = _p.x;
		_armature.display.y = _p.y;
		
		var _randomMovement:String = _armature.animation.movementList[int(Math.random() * _armature.animation.movementList.length)];
		_armature.animation.play(_randomMovement);
		addChild(_armature.display as Sprite);
		armatures.push(_armature);
	}
	
	private function onEnterFrameHandler(_e:EnterFrameEvent):void {
		if (stage && !stage.hasEventListener(TouchEvent.TOUCH)) {
			stage.addEventListener(TouchEvent.TOUCH, onMouseClickHandler);
		}
		for each(var _armature:Armature in armatures) {
			_armature.update();
		}
	}
}
