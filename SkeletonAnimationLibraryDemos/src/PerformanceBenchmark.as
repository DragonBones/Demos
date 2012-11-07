package  {
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	
	import starling.core.Starling;
	
    [SWF(width="800", height="600", frameRate="60", backgroundColor="#999999")]
	public class PerformanceBenchmark extends flash.display.Sprite {
		
		public static var changeHandler:Function;
		
		private var input:TextField;
		
		public function PerformanceBenchmark() {
			starlingInit();
			addInputText();
		}
		
		private function addInputText():void
		{
			input = new TextField();
			input.border = true;
			input.height = 20;
			input.borderColor = 0xffff0000;
			input.textColor = 0xffff0000;
			input.type = TextFieldType.INPUT;
			input.y = 20;
			input.x = 250;
			addChild(input);
			var description:TextField = new TextField();
			description.x = input.x;
			description.y = 20;
			description.width = 0;
			description.height = 20;
			description.autoSize = TextFieldAutoSize.RIGHT;
			description.text = "input the number, then press the Enter:";
			addChild(description);
			
			input.addEventListener(KeyboardEvent.KEY_UP, onKey);
		}
		
		private function onKey(e:KeyboardEvent):void
		{
			if (e.charCode == Keyboard.ENTER && changeHandler != null)
			{
				if (int(input.text) < 0)
					input.text = "0";
				changeHandler(int(input.text));
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

import flash.geom.Point;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Touch;
import starling.events.TouchPhase;
import starling.events.TouchEvent;

import dragonBones.Armature;
import dragonBones.factorys.StarlingFactory;

class StarlingGame extends Sprite {
	[Embed(source = "../assets/Knight_output.png", mimeType = "application/octet-stream")]
	private static const ResourcesData:Class;
	
	private var factory:StarlingFactory;
	private var allArmatureNameList:Array;
	private var armatures:Array;
	public function StarlingGame() {
		factory = new StarlingFactory();
		factory.fromRawData(new ResourcesData(), textureCompleteHandler);
	}
	
	private function changeNum(num:int):void
	{
		var i:int;
		var _armature:Armature;
		

		if (armatures.length == num)
			return;
			
		if (armatures.length > num)
		{
			for (i = armatures.length - 1; i >= num; i--)
			{
				armatures[i].dispose();
				removeChild(armatures[i].display as Sprite);
			}
			armatures.length = num;
		}
		else
		{
			var stageWidth:int = stage.stageWidth;
			var stageHeight:int = stage.stageHeight;
			for (i = armatures.length; i < num; i++)
			{
				_armature = factory.buildArmature("knight");
				_armature.display.x = Math.random() * stageWidth;
				_armature.display.y = Math.random() * stageHeight;
				var _randomMovement:String = _armature.animation.movementList[int(Math.random() * _armature.animation.movementList.length)];
				_armature.animation.gotoAndPlay(_randomMovement);
				addChild(_armature.display as Sprite);
				armatures.push(_armature);
			}
		}
	}
	
	private function textureCompleteHandler():void {
		allArmatureNameList = factory.skeletonData.getSearchList();
		armatures = [];
		PerformanceBenchmark.changeHandler = changeNum;
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
	}
	
	private function onEnterFrameHandler(_e:EnterFrameEvent):void {
		for each(var _armature:Armature in armatures) {
			_armature.update();
		}
	}
}
