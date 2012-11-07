package  {
	import flash.display.Sprite;
	import starling.core.Starling;
	
	
    [SWF(width="800", height="600", frameRate="60", backgroundColor="#999999")]
	public class MaxPerformanceTester extends flash.display.Sprite {
		
		public function MaxPerformanceTester() {
			var _starling:Starling = new Starling(StarlingGame, stage);
			_starling.start();
		}
	}
}

import dragonBones.Armature;
import dragonBones.factorys.StarlingFactory;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.text.TextField;


class StarlingGame extends Sprite {
	[Embed(source = "../assets/DragonWithClothes.png", mimeType = "application/octet-stream")]
	private static const ResourcesData:Class;
	
	private var factory:StarlingFactory;
	private var allArmatureNameList:Array;
	private var armatures:Array;
	
	
	private const WAIT_FRAME:int = 10;
	private const PADDING:int = 60;
	
	private var elapsedTime:Number = 0;
	private var elapsedFrame:int = 0;
	private var failCount:int = 0;
	
	private var stageWidth:int;
	private var stageHeight:int;
	
	public function StarlingGame() {
		factory = new StarlingFactory();
		factory.fromRawData(new ResourcesData(), textureCompleteHandler);
	}
	
	private function addObject():void
	{
		var _armature:Armature = factory.buildArmature("Dragon");
		_armature.display.scaleX = _armature.display.scaleY = 0.3;
		_armature.display.x = Math.random() * (stageWidth - PADDING);
		_armature.display.y = Math.random() * (stageHeight - PADDING);
		var _randomMovement:String = _armature.animation.movementList[int(Math.random() * _armature.animation.movementList.length)];
		_armature.animation.gotoAndPlay(_randomMovement);
		addChild(_armature.display as Sprite);
		armatures.push(_armature);
	}
	
	private function textureCompleteHandler():void {
		allArmatureNameList = factory.skeletonData.getSearchList();
		armatures = [];
		stageWidth = stage.stageWidth;
		stageHeight = stage.stageHeight;
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
	}
	
	private function onEnterFrameHandler(_e:EnterFrameEvent):void {
		for each(var _armature:Armature in armatures) {
			_armature.update();
		}
		
		elapsedTime += _e.passedTime;
		elapsedFrame++;
		if (elapsedFrame % WAIT_FRAME == 0)
		{
			var fps:Number = elapsedFrame / elapsedTime;
			if (Math.ceil(fps) >= 60)
			{
				failCount = 0;
				addObject();
			}
			else
			{
				failCount++;
				if (failCount == 30)
					benchmarkComplete();
			}
			
			elapsedTime = elapsedFrame = 0;
		}
	}
	
	private function benchmarkComplete():void
	{
		var desc:String = "total " + armatures.length + " objects with 60fps";
		var mResultText:starling.text.TextField = new starling.text.TextField(200, 100, desc);
		mResultText.fontSize = 20;
		mResultText.color = 0xffff0000;
		mResultText.x = stageWidth/2 - mResultText.width / 2;
		mResultText.y = stageHeight/2 - mResultText.height / 2;
		addChild(mResultText);
	}
}
