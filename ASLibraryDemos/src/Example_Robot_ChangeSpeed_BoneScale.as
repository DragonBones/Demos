package  {
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import starling.core.Starling;

    [SWF(width="800", height="600", frameRate="30", backgroundColor="#cccccc")]
	public class Example_Robot_ChangeSpeed_BoneScale extends flash.display.Sprite {

		public function Example_Robot_ChangeSpeed_BoneScale() {
			starlingInit();
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseHandler);
		}

		private function mouseHandler(e:MouseEvent):void 
		{
			switch(e.type) {
				case MouseEvent.MOUSE_WHEEL:
					StarlingGame.instance.changeAnimationScale(e.delta > 0?1: -1);
					break;
			}
		}

		private function starlingInit():void {
			Starling.handleLostContext = true;
			var _starling:Starling = new Starling(StarlingGame, stage);
			//_starling.antiAliasing = 1;
			_starling.showStats = true;
			_starling.start();
		}
	}
}

import flash.events.Event;
import flash.utils.Dictionary;

import starling.display.Sprite;
import starling.events.Event;
import starling.events.EnterFrameEvent;
import starling.text.TextField;

import feathers.controls.Slider;
import feathers.controls.Button;
import feathers.themes.AeonDesktopTheme;

import dragonBones.Armature;
import dragonBones.Bone;
import dragonBones.animation.WorldClock;
import dragonBones.factorys.StarlingFactory;

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
		//
		factory.scaleForTexture = 2;
		
		factory.parseData(new ResourcesData());
		factory.addEventListener(flash.events.Event.COMPLETE, textureCompleteHandler);
	}

	private function textureCompleteHandler(_e:flash.events.Event):void {
		armature = factory.buildArmature("robot");
		var _display:Sprite = armature.display as Sprite;
		_display.x = 400;
		_display.y = 300;
		
		addChild(_display);
		armature.animation.gotoAndPlay("stop");
		WorldClock.clock.add(armature);
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
		
		textField = new TextField(700, 30, "Scroll mouse wheel to change speed.", "Verdana", 16, 0, true);
		textField.x = 60;
		textField.y = 5;
		addChild(textField);
		
		createUI();
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
	
	private function createUI():void
	{
		var _slidersDic:Dictionary = new Dictionary();
		var _theme:AeonDesktopTheme = new AeonDesktopTheme(this.stage);
		
		var _bones:Vector.<Bone> = armature.getBones();
		var _i:uint = 1;
		
		
		this.addChild(createTextField((_bones[6] as Bone).name));
		this.addChild(createSlider((_bones[6] as Bone).name));
		_i++;
		this.addChild(createTextField((_bones[11] as Bone).name));
		this.addChild(createSlider((_bones[11] as Bone).name));
		_i++;
		this.addChild(createTextField((_bones[14] as Bone).name));
		this.addChild(createSlider((_bones[14] as Bone).name));
		_i++;
		var _button:Button = new Button();
		_button.x = 20;
		_button.y = _i * 30;
		_button.label = "Switch postures";
		this.addChild(_button);
		
		_button.addEventListener(starling.events.Event.TRIGGERED, buttonTriggeredHandler);
		
		
		function createTextField(text:String):TextField
		{
			var textField:TextField = new TextField(70, 30, text, "Verdana", 10, 0, true);
			textField.x = 10;
			textField.y = _i*30;
			return textField;
		}
	
		function createSlider(name:String):Slider
		{
			var _slider:Slider = new Slider();
			_slider.minimum = 0.5;
			_slider.maximum = 2;
			_slider.step = 0.1;
			_slider.value = 1;
			_slider.liveDragging = true;
			_slider.addEventListener(starling.events.Event.CHANGE, sliderChangeHandler);
			_slider.x = 80;
			_slider.y = _i * 30 + 15;
			_slidersDic[_slider] = armature.getBone(name);
			return _slider;
		}
		
		function sliderChangeHandler(_e:starling.events.Event):void
		{
			var _slider:Slider = _e.target as Slider;
			var _bone:Bone = _slidersDic[_slider];
			_bone.node.scaleX = _bone.node.scaleY = _slider.value;
		}
		
		function buttonTriggeredHandler(_e:starling.events.Event):void
		{
			changeMovement();
		}
	}
	
	private function onEnterFrameHandler(_e:EnterFrameEvent):void {
		WorldClock.clock.advanceTime(-1);
	}
}